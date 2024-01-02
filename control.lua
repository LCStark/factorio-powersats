local PowerSats = require("powersats")

function on_satellite_launched(force, surface, satellite_type)
    local launch_surface = surface.index
    if not launch_surface then
      game.write_file("powersat.log", "on_satellite_launched called on invalid surface: force: `" .. serpent.block(force.name) .. "` - surface: `" .. serpent.block(surface) .. "`\n", true)
      return
    end
    
    if not game.forces[force.name] then
      game.write_file("powersat.log", "on_satellite_launched called on invalid force: force: `" .. serpent.block(force.name) .. "` - surface: `" .. serpent.block(surface) .. "`\n", true)
      return
    end
  
  PowerSats.LaunchPowerSat(force, surface, "powerSat")
end

function on_rocket_launched(event)
  if event.rocket and event.rocket.valid then
    if event.rocket.get_item_count("powerSat") > 0 then
      on_satellite_launched(event.rocket.force, event.rocket.surface, "powerSat")
    end
  end
end
script.on_event(defines.events.on_rocket_launched, on_rocket_launched)

function on_init()
  if global.powersats == nil then global.powersats = {} end  
  if global.powersats["satellite_data"] == nil then global.powersats["satellite_data"] = {} end
  if global.powersats["data"] == nil then global.powersats["data"] = {} end
  if global.powersats["ground_stations"] == nil then global.powersats["ground_stations"] = {} end
  
  global.powersats["data"]["baseSolarProduction"] = game.entity_prototypes["solar-panel"].max_energy_production -- Joules per tick
  global.powersats["data"]["baseSolarProductionW"] = game.entity_prototypes["solar-panel"].max_energy_production * 60 -- Joules per second
  global.powersats["data"]["solarSatMultiplier"] = 100
  
  global.powersats["data"]["powerGeneration"] = {}
  global.powersats["data"]["powerGeneration"]["powerSat"] = global.powersats["data"]["baseSolarProduction"]
  PowerSats.powerGeneration = global.powersats["data"]["powerGeneration"]
    
  if global.powersats["data"]["lifetime"] == nil then global.powersats["data"]["lifetime"] = {} end
  global.powersats["data"]["lifetime"]["powerSat"] = 4320000
  PowerSats.lifetime = global.powersats["data"]["lifetime"]
    
  global.powersats["combinators"] = {}
  
  if global.powersats["data"]["mod_compat"] == nil then global.powersats["data"]["mod_compat"] = {} end
  
  if game.active_mods["space-exploration"] then
    PowerSats.SE = true
    global.powersats["data"]["mod_compat"]["space-exploration"] = true
  else
    PowerSats.SE = false
    global.powersats["data"]["mod_compat"]["space-exploration"] = false
  end
end
script.on_init(on_init)

function on_load()
  PowerSats.powerGeneration = global.powersats["data"]["powerGeneration"]
  PowerSats.lifetime = global.powersats["data"]["lifetime"]
  PowerSats.SE = global.powersats["data"]["mod_compat"]["space-exploration"]
end
script.on_load(on_load)

-- Debug
commands.add_command("switch_orbit", nil, function(command)
  local zone = remote.call("space-exploration", "get_zone_from_surface_index", { surface_index = game.players[1].surface.index })
  if zone.type == "orbit" then
    local parent_zone = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = zone.parent_index })
    if parent_zone.surface_index then
      zone = parent_zone
    end
  elseif zone.type == "planet" or zone.type == "moon" then
    if zone.orbit_index then
      local orbit_zone = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = zone.orbit_index })
      zone = orbit_zone
    end
  end
  remote.call("space-exploration", "teleport_to_zone", {zone_name = zone.name, player=game.players[1]})    
end)
-- End Debug

function on_config_change()
  PowerSats.lifetime = {}
  PowerSats.lifetime["powerSat"] = 4320000
  
  if game.active_mods["space-exploration"] then
    PowerSats.SE = true
  else
    PowerSats.SE = false
  end
end
script.on_configuration_changed(on_config_change)

script.on_nth_tick(60, function(data)
  
  PowerSats.UpdateTick()

end)

script.on_event(defines.events.on_tick, function(data)
  
  PowerSats.Tick(data.tick)
  
end)

-- Combined events
script.on_event(defines.events.on_built_entity, function(data)

  PowerSats.EntityBuilt(data.created_entity)
  
end, { { filter = "name", name="powersat-ground-station-entity" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_robot_built_entity, function(data)

  PowerSats.EntityBuilt(data.created_entity)

end, { { filter = "name", name="powersat-ground-station-entity" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_player_mined_entity, function(data)
  
  PowerSats.EntityRemoved(data.entity)
  
end, { { filter = "name", name="powersat-ground-station-entity" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_robot_mined_entity, function(data)
  
  PowerSats.EntityRemoved(data.entity)
  
end, { { filter = "name", name="powersat-ground-station-entity" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_entity_died, function(data)

  PowerSats.EntityRemoved(data.entity)

end, { { filter = "name", name="powersat-ground-station-entity" }, { filter = "name", name="powersat-combinator" } })