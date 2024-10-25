local powerSatTechnology = {
  name = "powerSats",
  type = "technology",
  icons = {
    {
      icon = "__PowerSats__/graphics/technology/powerSat.png",
      tint = { a = 1.0, b = 1.0, g = 0.75, r = 0.75 },
      icon_size = 256
    }
  },
  prerequisites = {"space-science-pack"},
  effects = {
    {
      type = "unlock-recipe",
      recipe = "powerSat"
    },
    {
      type = "unlock-recipe",
      recipe = "powersat-ground-station-recipe"
    },
    {
      type = "unlock-recipe",
      recipe = "powersat-combinator"
    },
    {
      type = "nothing",
      effect_description = {"control.powersat-control"},
    },
  },
  research_trigger =
  {
    type = "send-item-to-orbit",
    item = "satellite"
  },
  --unit = {
  --  count = data.raw["technology"]["space-science-pack"]["unit"]["count"] * 0.25,
  --  time = data.raw["technology"]["space-science-pack"]["unit"]["time"] * 2,
  --  ingredients = data.raw["technology"]["space-science-pack"]["unit"]["ingredients"],
  --},
}

data:extend({powerSatTechnology})