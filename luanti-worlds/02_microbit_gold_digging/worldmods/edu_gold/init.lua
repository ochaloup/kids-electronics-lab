local storage = core.get_mod_storage()
local spawns = {{x = -16, y = 1, z = 0}, {x = 16, y = 1, z = 0}}
local spawn_yaws = {-math.pi / 2, math.pi / 2}
local scene_min = {x = -24, y = -4, z = -24}
local scene_max = {x = 24, y = 16, z = 24}
local hill_min = {x = -8, y = 1, z = -8}
local hill_max = {x = 8, y = 6, z = 8}
local gold = "mcl_core:stone_with_gold"
local scores, sent = {}, {}

local function send(line)
  core.log("action", "[edu_gold] " .. line)
  table.insert(sent, line)
end

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
core.settings:set("static_spawnpoint", core.pos_to_string(spawns[1]))
mcl_hunger.set_active(false)

core.register_on_mods_loaded(function()
  for _, name in ipairs({"gamerule:doMobSpawning", "gamerule:doWeatherCycle"}) do
    local setting = vl_tuning.registered_settings[name]
    if setting then setting:set(false) end
  end
  core.after(0, function()
    mcl_weather.change_weather("none", nil, "Gold Digging")
    core.set_timeofday(0.5)
  end)
end)

local function fill(x1, y1, z1, x2, y2, z2, name)
  for z = z1, z2 do
    for y = y1, y2 do
      for x = x1, x2 do core.set_node({x = x, y = y, z = z}, {name = name}) end
    end
  end
end

local function build_scene()
  fill(-22, -4, -22, 22, -3, 22, "mcl_core:stone")
  fill(-22, -2, -22, 22, -1, 22, "mcl_core:dirt")
  fill(-22, 0, -22, 22, 0, 22, "mcl_core:dirt_with_grass")
  fill(-22, 1, -22, 22, 2, -22, "mcl_core:glass")
  fill(-22, 1, 22, 22, 2, 22, "mcl_core:glass")
  fill(-22, 1, -22, -22, 2, 22, "mcl_core:glass")
  fill(22, 1, -22, 22, 2, 22, "mcl_core:glass")
  for y = hill_min.y, hill_max.y do
    local r = hill_max.x + hill_min.y - y
    fill(-r, y, -r, r, y, r, "mcl_core:stone")
  end
  -- Fixed seed: every fresh round has the same hill, so rounds are fair to compare.
  local random = PcgRandom(42)
  local placed = 0
  while placed < 36 do
    local y = random:next(hill_min.y, hill_max.y)
    local r = hill_max.x + hill_min.y - y
    local pos = {x = random:next(-r, r), y = y, z = random:next(-r, r)}
    if core.get_node(pos).name == "mcl_core:stone" then
      core.set_node(pos, {name = gold})
      placed = placed + 1
    end
  end
  storage:set_int("scene_version", 1)
  core.set_timeofday(0.5)
  core.log("action", "[edu_gold] Arena ready")
end

local joined, home_of = 0, {}

local function home(player)
  local index = home_of[player:get_player_name()]
  player:set_pos(spawns[index])
  player:set_look_horizontal(spawn_yaws[index])
end

core.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  if not home_of[name] then
    joined = joined + 1
    home_of[name] = (joined - 1) % 2 + 1
  end
  home(player)
  if player:get_meta():get_int("edu_gold_kit") == 0 then
    local leftover = player:get_inventory():add_item("main", "mcl_tools:pick_iron")
    if not leftover:is_empty() then core.add_item(player:get_pos(), leftover) end
    player:get_meta():set_int("edu_gold_kit", 1)
  end
  core.chat_send_player(name, "Vítej ve Zlatém dole! Vytěž železným krumpáčem co nejvíc zlata. Pořadí: /gold_score")
end)
core.register_on_respawnplayer(function(player) home(player) return true end)

local function on_dig(_, oldnode, digger)
  if oldnode.name ~= gold or not (digger and digger:is_player()) then return end
  local name = digger:get_player_name()
  scores[name] = (scores[name] or 0) + 1
  core.chat_send_all("Zlato pro " .. name .. "! Skóre: " .. scores[name])
  send("GOLD|" .. name .. "|" .. scores[name])
end
core.register_on_dignode(on_dig)

local function standings()
  local names = {}
  for name in pairs(scores) do table.insert(names, name) end
  if #names == 0 then return "Zatím nikdo nic nevytěžil." end
  table.sort(names, function(a, b)
    if scores[a] ~= scores[b] then return scores[a] > scores[b] end
    return a < b
  end)
  for i, name in ipairs(names) do names[i] = name .. " " .. scores[name] end
  return "Pořadí: " .. table.concat(names, ", ")
end

core.register_chatcommand("gold_score", {description = "Show who mined the most gold", func = function()
  return true, standings()
end})

core.after(0, function()
  core.emerge_area(scene_min, scene_max, function(_, _, remaining)
    if remaining ~= 0 then return end
    core.after(0, function()
      if storage:get_int("scene_version") ~= 1 then build_scene() end
      send("GROUP|" .. (core.settings:get("edu_gold_radio_group") or "7"))
      send("RESET")
      if core.settings:get_bool("edu_selftest", false) then
        assert(loadfile(core.get_modpath("edu_gold") .. "/selftest.lua"))({
          scores = scores, sent = sent, on_dig = on_dig, spawns = spawns,
          hill_min = hill_min, hill_max = hill_max, gold = gold,
        })
      end
    end)
  end)
end)
