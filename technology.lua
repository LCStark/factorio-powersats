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
      recipe = "powersat-ground-station"
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
}

if feature_flags["space_travel"] then
  powerSatTechnology.research_trigger = 
    { 
      type = "send-item-to-orbit", 
      item = "solar-panel"
    }
end

data:extend({powerSatTechnology})