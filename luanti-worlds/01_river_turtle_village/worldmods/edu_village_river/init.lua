local storage = core.get_mod_storage()
local spawn = {x = -12, y = 1, z = 0}
local bridge_start = {x = -4, y = 1, z = 0}
local scene_min = {x = -32, y = -4, z = -24}
local scene_max = {x = 32, y = 16, z = 24}
local ready, building = false, false

-- Applies when opened from the regular menu as well as from play.sh.
local original_settings = {}
for _, name in ipairs({"enable_damage", "enable_pvp", "mcl_enable_hunger", "mobs_spawn",
  "mcl_doWeatherCycle", "time_speed", "static_spawnpoint"}) do
  original_settings[name] = {value = core.settings:get(name)}
end
core.register_on_shutdown(function()
  for name, original in pairs(original_settings) do
    if original.value ~= nil then core.settings:set(name, original.value)
    else core.settings:remove(name) end
  end
end)
core.settings:set_bool("enable_damage", false)
core.settings:set_bool("enable_pvp", false)
core.settings:set_bool("mcl_enable_hunger", false)
core.settings:set_bool("mobs_spawn", false)
core.settings:set_bool("mcl_doWeatherCycle", false)
core.settings:set("time_speed", "0")
core.settings:set("static_spawnpoint", core.pos_to_string(spawn))
mcl_hunger.set_active(false)

core.register_on_mods_loaded(function()
  for _, name in ipairs({"gamerule:doMobSpawning", "gamerule:doWeatherCycle"}) do
    local setting = vl_tuning.registered_settings[name]
    if setting then setting:set(false) end
  end
  core.after(0, function()
    mcl_weather.change_weather("none", nil, "Programming Village")
    core.set_timeofday(0.5)
  end)
end)

local function node(x, y, z, name, param2)
  core.set_node({x = x, y = y, z = z}, {name = name, param2 = param2 or 0})
end

local function fill(x1, y1, z1, x2, y2, z2, name)
  for z = z1, z2 do
    for y = y1, y2 do
      for x = x1, x2 do node(x, y, z, name) end
    end
  end
end

local function house(x, z)
  fill(x, 0, z, x + 6, 0, z + 6, "mcl_core:wood")
  fill(x, 1, z, x + 6, 4, z + 6, "mcl_core:wood")
  fill(x + 1, 1, z + 1, x + 5, 4, z + 5, "air")
  fill(x + 2, 1, z, x + 3, 3, z, "air")
  fill(x, 2, z + 2, x, 3, z + 3, "mcl_core:glass")
  fill(x + 6, 2, z + 2, x + 6, 3, z + 3, "mcl_core:glass")
  for layer = 0, 3 do
    fill(x - 1 + layer, 5 + layer, z - 1,
      x + 7 - layer, 5 + layer, z + 7, "mcl_core:stonebrick")
  end
end

core.register_node("edu_village_river:lesson_board", {
  description = "Programming Village lesson board",
  tiles = {"default_wood.png"},
  groups = {handy = 1, axey = 1},
  _mcl_hardness = 1,
  on_rightclick = function(_, _, player)
    core.show_formspec(player:get_player_name(), "edu_village_river:help",
      "formspec_version[4]size[12,9]" ..
      "textarea[0.5,0.5;11,7.5;help;Programming Village;" .. core.formspec_escape(
        "Welcome! Right-click a robot to open its programming sheet.\n\n" ..
        "The bridge robot faces the other bank (+X). Put oak planks in its Storage.\n" ..
        "Start with: Place forward, down + an oak plank marker; then Move forward.\n" ..
        "Repeat those two lines six times. Items in the sheet are markers;\n" ..
        "the actual blocks must be in Storage. Press the power button to run.\n\n" ..
        "Next: Loop + Counter is less than + Number 6, with the two action\n" ..
        "lines indented one column. Set Number to 6 using the top Value slot.\n\n" ..
        "Sneak + punch a running robot to stop it.\n" ..
        "/edu_check - check the six bridge blocks\n" ..
        "/edu_kit - get a robot, cassette and oak planks\n" ..
        "/edu_home - return to the village\n" ..
        "/edu_reset_bridge - clear the bridge and reset its robot\n" ..
        "The flat stone area south of the village is for free experiments.") ..
      "]button_exit[4,8;4,0.7;close;Let's program]")
  end,
})

local function robot(pos, param2, label)
  core.set_node(pos, {name = "lwscratch:robot", param2 = param2})
  local def = core.registered_nodes["lwscratch:robot"]
  def.after_place_node(pos, nil, ItemStack("lwscratch:robot"), nil)
  local meta = core.get_meta(pos)
  meta:set_string("name", label)
  meta:set_string("infotext", label .. " - right-click to program")
  meta:get_inventory():add_item("storage", "mcl_core:wood 64")
end

local function bridge_reset()
  -- Also removes robots on the bridge after an earlier attempt.
  fill(-4, 1, -1, 3, 2, 1, "air")
  fill(-3, 0, -1, 2, 0, 1, "air")
  robot(bridge_start, 3, "Bridge robot (faces the far bank)")
end

local function build_scene()
  for _, pos in ipairs(core.find_nodes_with_meta(scene_min, scene_max)) do
    core.get_meta(pos):from_table(nil)
    core.get_node_timer(pos):stop()
  end
  local vm = VoxelManip()
  local emin, emax = vm:read_from_map(scene_min, scene_max)
  local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
  local data = vm:get_data()
  local air = core.get_content_id("air")
  for z = scene_min.z, scene_max.z do
    for y = scene_min.y, scene_max.y do
      for x = scene_min.x, scene_max.x do
        data[area:index(x, y, z)] = air
      end
    end
  end
  vm:set_data(data)
  vm:write_to_map()
  fill(-30, -4, -22, 30, -3, 22, "mcl_core:stone")
  fill(-30, -2, -22, 30, -1, 22, "mcl_core:dirt")
  fill(-30, 0, -22, 30, 0, 22, "mcl_core:dirt_with_grass")
  fill(-3, -2, -21, 2, -2, 21, "mcl_core:sand")
  fill(-3, -1, -21, 2, -1, 21, "mcl_core:water_source")
  fill(-3, 0, -21, 2, 0, 21, "air")
  fill(-28, 0, -1, -4, 0, 1, "mcl_core:stonebrick")
  fill(3, 0, -1, 28, 0, 1, "mcl_core:stonebrick")
  house(-24, -12)
  house(-14, -12)
  house(12, -12)
  fill(-25, 0, 8, -8, 0, 19, "mcl_core:stonebrick")
  fill(-30, 1, -22, 30, 2, -22, "mcl_core:glass")
  fill(-30, 1, 22, 30, 2, 22, "mcl_core:glass")
  fill(-30, 1, -22, -30, 2, 22, "mcl_core:glass")
  fill(30, 1, -22, 30, 2, 22, "mcl_core:glass")
  node(-10, 1, -3, "edu_village_river:lesson_board")
  core.get_meta({x = -10, y = 1, z = -3}):set_string("infotext", "Programming Village: right-click for lessons")
  bridge_reset()
  robot({x = -18, y = 1, z = 11}, 2, "Practice robot (faces +Z)")
  storage:set_int("scene_version", 1)
  core.set_timeofday(0.5)
  core.log("action", "[edu_village_river] Village scene ready")
end

local function generate(rebuild, done)
  if building then return false end
  building = true
  core.emerge_area(scene_min, scene_max, function(_, _, remaining)
    if remaining ~= 0 then return end
    core.after(0, function()
      if rebuild or storage:get_int("scene_version") ~= 1 then
        -- Remove existing robots normally to release persistence and runtime state.
        for _, pos in ipairs(core.find_nodes_in_area(scene_min, scene_max,
          {"lwscratch:robot", "lwscratch:robot_on"})) do core.remove_node(pos) end
        build_scene()
      end
      building, ready = false, true
      if done then done() end
    end)
  end)
  return true
end

local function kit(player)
  local inv = player:get_inventory()
  for _, item in ipairs({"lwscratch:robot", "lwscratch:cassette", "mcl_core:wood 64"}) do
    local leftover = inv:add_item("main", item)
    if not leftover:is_empty() then core.add_item(player:get_pos(), leftover) end
  end
end

local function home(player)
  player:set_pos(spawn)
  player:set_look_horizontal(-math.pi / 2)
end

core.register_on_joinplayer(function(player)
  home(player)
  if player:get_meta():get_int("edu_received_kit") == 0 then
    kit(player)
    player:get_meta():set_int("edu_received_kit", 1)
  end
  core.chat_send_player(player:get_player_name(), "Welcome to Programming Village! Right-click the lesson board. /edu_home /edu_kit /edu_check")
end)
core.register_on_respawnplayer(function(player) home(player) return true end)

local function check_bridge()
  local count = 0
  for x = -3, 2 do
    if core.get_node({x = x, y = 0, z = 0}).name == "mcl_core:wood" then count = count + 1 end
  end
  return count == 6, count .. "/6 oak bridge blocks placed." .. (count == 6 and " Bridge complete!" or " Keep programming!")
end

core.register_chatcommand("edu_check", {
  description = "Check the bridge's six oak plank blocks", func = function()
    if not ready then return false, "The village is still loading." end
    local _, message = check_bridge()
    return true, message
  end,
})
core.register_chatcommand("edu_home", {description = "Return to the village", func = function(name)
  local player = core.get_player_by_name(name)
  if not player then return false, "Join the world first." end
  home(player) return true, "Back at the village."
end})
core.register_chatcommand("edu_kit", {description = "Get a robot, cassette and oak planks", privs = {interact = true}, func = function(name)
  local player = core.get_player_by_name(name)
  if not player then return false, "Join the world first." end
  kit(player) return true, "Robot kit added to your inventory."
end})
core.register_chatcommand("edu_reset_bridge", {description = "Clear the bridge and reset its robot", privs = {server = true}, func = function()
  if not ready or building then return false, "The village is still loading." end
  bridge_reset() return true, "Bridge reset; its robot has a fresh empty program and 64 planks."
end})
core.register_chatcommand("edu_rebuild_village", {description = "Reset the entire scene, including all builds and robots", privs = {server = true}, func = function()
  if not generate(true) then return false, "A rebuild is already running." end
  return true, "Rebuilding the village; all builds in the scene will be reset."
end})

core.after(0, function()
  generate(false, function()
    if core.settings:get_bool("edu_selftest", false) then
      dofile(core.get_modpath("edu_village_river") .. "/selftest.lua")
    end
  end)
end)
