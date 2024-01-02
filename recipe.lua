local powerSatRecipe = {
  category = "crafting",
  enabled = false,
  energy_required = 5,
  ingredients = {
    {
      "electronic-circuit",
      10
    },
    {
      "low-density-structure",
      10
    },
    {
      "rocket-fuel",
      5
    },
    {
      "solar-panel",
      10
    }
  },
  name = "powerSat",
  result = "powerSat",
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
    { "steel-plate", 500 },
    { "concrete", 500 },
    { "processing-unit", 100 },
    { "substation", 10 }
  },
  result = "powersat-ground-station-item",
  energy_required = 60,
  enabled = false
}

data:extend({ groundStationRecipe })

local powerSatCombinatorRecipe = table.deepcopy(data.raw["recipe"]["constant-combinator"])
powerSatCombinatorRecipe.name = "powersat-combinator"
powerSatCombinatorRecipe.enabled = false
powerSatCombinatorRecipe.results = {
  {
    name = "powersat-combinator",
    amount = 1,
    probability = 1
  }
}

data:extend({ powerSatCombinatorRecipe })