local powerSatItem = {
  name = "powerSat",
  icons = {
    {
      icon = "__PowerSats__/graphics/technology/powerSat.png",
      tint = { a = 1.0, b = 1.0, g = 0.75, r = 0.75 },
      icon_size = 256
    }
  },
  rocket_launch_products = nil,
  order = "d[rocket-parts]-e[satellite]",
  send_to_orbit_mode = "automated",
  stack_size = 1,
  subgroup = "space-related",
  type ="item",
  weight = 1000000,
  pick_sound = {
    filename = "__base__/sound/item/mechanical-inventory-pickup.ogg",
    volume = 0.8
  },
  drop_sound = {
    filename = "__base__/sound/item/mechanical-inventory-move.ogg",
    volume = 0.7
  },
}

data:extend({powerSatItem})

--data.raw["item"]["solar-panel"].send_to_orbit_mode = "manual"
--data.raw["item"]["accumulator"].send_to_orbit_mode = "automated"

local powerSatGroundStationItem  = {
  type = "item",
  name = "powersat-ground-station",
  icon = "__PowerSats__/graphics/icon/groundStationMock3Icon.png",
  icon_size = 64,
  subgroup = "energy",
  order = "z",
  place_result = "powersat-ground-station",
  stack_size = 10
}

data:extend({powerSatGroundStationItem})

local powerSatCombinatorItem = table.deepcopy(data.raw["item"]["constant-combinator"])
powerSatCombinatorItem.name = "powersat-combinator"
powerSatCombinatorItem.icon = "__PowerSats__/graphics/icon/powersat-combinator-icon.png"
powerSatCombinatorItem.place_result = "powersat-combinator"
powerSatCombinatorItem.order = "c[combinators]-p[powersat-combinator]"

data:extend({ powerSatCombinatorItem })