-- Opt-in integration check. Run ONLY in a disposable copy of the world.
local t = ...
local function fake(name, is_player)
  return {is_player = function() return is_player end, get_player_name = function() return name end}
end
local function last() return t.sent[#t.sent] end

assert(not core.settings:get_bool("enable_damage"), "Damage must be off")
assert(not core.settings:get_bool("enable_pvp"), "PvP must be off")
assert(not mcl_hunger.get_active(), "Hunger must be off")
assert(vl_tuning.registered_settings["gamerule:doMobSpawning"]:get_string() == "false")
assert(vl_tuning.registered_settings["gamerule:doWeatherCycle"]:get_string() == "false")

assert(#t.sent == 2 and t.sent[1] == "GROUP|7" and t.sent[2] == "RESET",
  "Startup must send GROUP|7 then RESET, got: " .. table.concat(t.sent, ","))
assert(#core.find_nodes_in_area(t.hill_min, t.hill_max, t.gold) == 36, "The hill must hold 36 gold ores")
assert(#core.find_nodes_in_area(t.hill_min, t.hill_max, t.iron) == 0, "The hill must hold no iron")
assert(#core.find_nodes_in_area(t.scene_min, t.scene_max, t.iron) == 40, "Rocks must hold 40 iron ores")
assert(#core.find_nodes_in_area(t.scene_min, t.scene_max, "mcl_core:tree") == 40, "Trees must give 40 logs")
local west_iron = #core.find_nodes_in_area(t.scene_min, {x = -1, y = t.scene_max.y, z = t.scene_max.z}, t.iron)
assert(west_iron == 20, "Both halves must hold the same iron, west has " .. west_iron)
for _, spawn in ipairs(t.spawns) do
  assert(core.get_node(spawn).name == "air", "Spawn must be free: " .. core.pos_to_string(spawn))
  assert(core.get_node({x = spawn.x, y = spawn.y - 1, z = spawn.z}).name == "mcl_core:dirt_with_grass",
    "Spawn must stand on grass: " .. core.pos_to_string(spawn))
end

local found = false
for _, callback in ipairs(core.registered_on_dignodes) do found = found or callback == t.on_dig end
assert(found, "The gold callback must be registered with core.register_on_dignode")

local pos = {x = 0, y = 1, z = 0}
local modry, zeleny = fake("modry", true), fake("zeleny", true)
t.on_dig(pos, {name = "mcl_core:stone"}, modry)
assert(t.scores.modry == nil and #t.sent == 2, "Stone must not score")
t.on_dig(pos, {name = t.gold}, modry)
assert(t.scores.modry == 1 and last() == "GOLD|modry|1", "First gold must score 1")
t.on_dig(pos, {name = t.gold}, zeleny)
t.on_dig(pos, {name = t.gold}, zeleny)
assert(t.scores.zeleny == 2 and last() == "GOLD|zeleny|2", "Second player must reach 2")
t.on_dig(pos, {name = t.gold}, fake("robot", false))
t.on_dig(pos, {name = t.gold}, nil)
assert(#t.sent == 5 and t.scores.robot == nil, "Only players may score")

local ok, message = core.registered_chatcommands.gold_score.func("modry", "")
assert(ok and message == "Pořadí: zeleny 2, modry 1", "Unexpected standings: " .. tostring(message))

core.log("action", "[edu_selftest] PASS: peaceful settings, arena with 36 gold, 40 iron and 10 trees, startup GROUP/RESET, gold scoring per player, standings")
core.request_shutdown("Gold world integration check complete", false, 0)
