local powerSatRecipe = {
  category = "crafting",
  enabled = false,
  energy_required = 5,
  ingredients = {
    {
      type = "item",
      name = "electronic-circuit",
      amount = 10
    },
    {
      type = "item",
      name = "low-density-structure",
      amount = 10
    },
    {
      type = "item",
      name = "rocket-fuel",
      amount = 5
    },
    {
      type = "item",
      name = "solar-panel",
      amount = 10
    }
  },
  name = "powerSat",
  --result = "powerSat",
  results = {{type = "item", name = "powerSat", amount = 1}},
  requester_paste_multiplier = 1,
  type = "recipe",
  order = "m[satellite]-power",
  icons = {
    {
      icon = "__PowerSats__/graphics/technology/powerSat.png",
      tint = { a = 1.0, b = 1.0, g = 0.75, r = 0.75 },
      icon_size = 256
    }
  }
}

data:extend({ powerSatRecipe })

local groundStationRecipe = {
  type = "recipe",
  name = "powersat-ground-station-recipe",
  ingredients = {
    { type = "item", name = "steel-plate", amount = 500 },
    { type = "item", name = "concrete", amount = 500 },
    { type = "item", name = "processing-unit", amount = 100 },
    { type = "item", name = "substation", amount = 10 }
  },
  --result = "powersat-ground-station-item",
  results = {{type = "item", name = "powersat-ground-station-item", amount = 1}},
  energy_required = 60,
  enabled = false
}

data:extend({ groundStationRecipe })

local powerSatCombinatorRecipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])
powerSatCombinatorRecipe.name = "powersat-combinator"
powerSatCombinatorRecipe.enabled = false
powerSatCombinatorRecipe.results = {
  {
    type = "item",
    name = "powersat-combinator",
    amount = 1,
    probability = 1
  }
}

data:extend({ powerSatCombinatorRecipe })