-- Opt-in integration check. Run ONLY in a disposable copy of the world.
local start = {x = -4, y = 1, z = 0}
local def = core.registered_nodes["lwscratch:robot"]
core.registered_chatcommands.edu_reset_bridge.func("")
local sender = {is_player = function() return true end,
  get_player_name = function() return "edu_selftest" end}
assert(def and core.get_modpath("xcompat"), "LWScratch and xcompat must load")
assert(not core.settings:get_bool("enable_damage"), "Damage must be off")
assert(not core.settings:get_bool("enable_pvp"), "PvP must be off")
assert(not mcl_hunger.get_active(), "Hunger must be off")
assert(vl_tuning.registered_settings["gamerule:doMobSpawning"]:get_string() == "false")
assert(vl_tuning.registered_settings["gamerule:doWeatherCycle"]:get_string() == "false")
assert(core.get_node({x = 0, y = -1, z = 0}).name == "mcl_core:water_source")
assert(core.get_meta(start):get_string("formspec") ~= "", "Robot UI must exist")
local inv = core.get_meta(start):get_inventory()
assert(inv:get_size("program") >= 120 and inv:get_size("storage") == 32)
local mode = core.settings:get("edu_selftest_mode") or "sequence"
if mode == "loop" then
  local number = ItemStack("lwscratch:cmd_value_number")
  number:get_meta():set_string("value", "6")
  inv:set_stack("program", 1, "lwscratch:cmd_stat_loop")
  inv:set_stack("program", 2, "lwscratch:cmd_cond_counter_less")
  inv:set_stack("program", 3, number)
  inv:set_stack("program", 12, "lwscratch:cmd_act_place_front_down")
  inv:set_stack("program", 13, "mcl_core:wood")
  inv:set_stack("program", 22, "lwscratch:cmd_act_move_front")
else
  for step = 0, 5 do
    inv:set_stack("program", step * 20 + 1, "lwscratch:cmd_act_place_front_down")
    inv:set_stack("program", step * 20 + 2, "mcl_core:wood")
    inv:set_stack("program", step * 20 + 11, "lwscratch:cmd_act_move_front")
  end
end
def.on_receive_fields(start, "", {power = true}, sender)
assert(core.get_meta(start):get_string("error") == "", "Sequence program must compile")
assert(core.get_meta(start):get_int("running") == 1, "Sequence program must start")
core.forceload_block(start, true)
core.forceload_block({x = 2, y = 1, z = 0}, true)
core.after(35, function()
  for x = -3, 2 do
    assert(core.get_node({x = x, y = 0, z = 0}).name == "mcl_core:wood",
      "Robot failed to place bridge plank at x=" .. x)
  end
  local finish = {x = 2, y = 1, z = 0}
  assert(core.get_node(finish).name == "lwscratch:robot", "Robot must finish six steps east")
  assert(core.get_meta(finish):get_inventory():get_stack("storage", 1):get_count() == 58,
    "Six planks must be consumed from robot storage")
  core.log("action", "[edu_selftest] PASS: " .. mode .. ", peaceful settings, robot UI, real execution, 6 bridge planks and inventory consumption")
  core.request_shutdown("Education world integration check complete", false, 0)
end)
core.after(45, function() error("Education integration check timed out") end)
