local powerSatItem = table.deepcopy(data.raw["item"]["satellite"]) 

powerSatItem["name"] = "powerSat"
powerSatItem["rocket_launch_products"] = {}
powerSatItem["icons"] = {
  {
    icon = "__PowerSats__/graphics/technology/powerSat.png",
    tint = { a = 1.0, b = 1.0, g = 0.75, r = 0.75 },
    icon_size = 256
  },
}

data:extend({powerSatItem})

local powerSatGroundStationItem  = {
  type = "item",
  name = "powersat-ground-station-item",
  icon = "__PowerSats__/graphics/icon/groundStationMock3Icon.png",
  icon_size = 64,
  subgroup = "energy",
  order = "z",
  place_result = "powersat-ground-station-entity",
  stack_size = 10,
}

data:extend({powerSatGroundStationItem})

local powerSatCombinatorItem = table.deepcopy(data.raw["item"]["constant-combinator"])
powerSatCombinatorItem.name = "powersat-combinator"
powerSatCombinatorItem.icon = "__PowerSats__/graphics/icon/powersat-combinator-icon.png"
powerSatCombinatorItem.place_result = "powersat-combinator"
powerSatCombinatorItem.order = "c[combinators]-p[powersat-combinator]"

data:extend({ powerSatCombinatorItem })