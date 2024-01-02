-- entity.lua

local groundStationEntity = {
  type = "electric-energy-interface",
  name = "powersat-ground-station-entity",
  selectable_in_game = true,
  collision_mask = { "item-layer", "object-layer", "player-layer", "water-tile" },
  energy_source = {
    buffer_capacity = "200MJ",
    input_flow_limit = "0kW",
    output_flow_limit = "200MW",
    type = "electric",
    render_no_power_icon = false,
    render_no_network_icon = true,
    usage_priority = "primary-output"
  },
  flags = {'placeable-neutral', 'player-creation'},
  icon = '__PowerSats__/graphics/icon/groundStationMock3Icon.png',
  icon_size = 64,
  minable = {
    mining_time = 0.5,
    result = "powersat-ground-station-item",
  },
  max_health = 2500,
  collision_box = {
    {
      -4.4000000000000004,
      -4.4000000000000004
    },
    {
      4.4000000000000004,
      4.4000000000000004
    }
  },
  selection_box = {
    {
      -4.5,
      -4.5
    },
    {
      4.5,
      4.5
    }
  },
  picture = {
    filename = "__PowerSats__/graphics/entity/groundStationMock3.png",
    priority = "extra-high",
    width = 608,
    height = 596,
    shift = { 0.0, 0.0 },
    scale = 0.5
  },
 
  charge_cooldown = 60,
  discharge_cooldown = 60,
  
  gui_mode = "none",
}

if mods["space-exploration"] then
  collision_mask_util_extended = require("__space-exploration__/collision-mask-util-extended/data/collision-mask-util-extended")
  space_collision_layer = collision_mask_util_extended.get_make_named_collision_mask("space-tile")
  table.insert(groundStationEntity["collision_mask"], space_collision_layer)
  groundStationEntity["se_allow_in_space"] = false
end

data:extend({ groundStationEntity })

local hit_effects = require("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")

local PowerSatCombinatorEntity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"]) 
PowerSatCombinatorEntity.name = "powersat-combinator"
PowerSatCombinatorEntity.sprites = make_4way_animation_from_spritesheet {
  layers = {
    {
      filename = "__PowerSats__/graphics/entity/powersat-combinator.png",
      width = 58,
      height = 52,
      frame_count = 1,
      shift = util.by_pixel(0, 5),
      hr_version = {
        scale = 0.5,
        filename = "__PowerSats__/graphics/entity/hr-powersat-combinator.png",
        width = 114,
        height = 102,
        frame_count = 1,
        shift = util.by_pixel(0, 5)
      }
    },
    {
      filename = "__base__/graphics/entity/combinator/constant-combinator-shadow.png",
      width = 50,
      height = 30,
      frame_count = 1,
      shift = util.by_pixel(9, 6),
      draw_as_shadow = true,
      hr_version = {
        scale = 0.5,
        filename = "__base__/graphics/entity/combinator/hr-constant-combinator-shadow.png",
        width = 98,
        height = 66,
        frame_count = 1,
        shift = util.by_pixel(8.5, 5.5),
        draw_as_shadow = true
      }
    }
  }
}
PowerSatCombinatorEntity.minable = { mining_time = 0.1, result = "powersat-combinator" }
PowerSatCombinatorEntity.fast_replaceable_group = "powersat-combinator"
PowerSatCombinatorEntity.openable = false
PowerSatCombinatorEntity.flags = { "placeable-neutral", "player-creation", "no-copy-paste" }

data:extend({ PowerSatCombinatorEntity })