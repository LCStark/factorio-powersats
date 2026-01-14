data.extend({
{
  type = "item",
  name = "satellite",
  icon = "__base__/graphics/icons/satellite.png",
  subgroup = "space-related",
  order = "d[rocket-parts]-e[satellite]",
  stack_size = 1,
  weight = 1 * tons,
  rocket_launch_products = {{type = "item", name = "space-science-pack", amount = 1000}},
  send_to_orbit_mode = "automated",
  hidden = false,
  hidden_in_factoriopedia = true
}
})

if mods["space-exploration"] then
  data.raw["electric-energy-interface"]["powersat-ground-station"].se_allow_in_space = false
  data.raw["electric-energy-interface"]["powersat-ground-station"]["collision_mask"]["layers"][space_collision_layer] = true
  local se_data_util = require("__space-exploration__/data_util")
  se_data_util.collision_description(data.raw["electric-energy-interface"]["powersat-ground-station"])
end