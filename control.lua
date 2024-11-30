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

function on_cargo_pod_finished_ascending(event)
  if event.cargo_pod and event.cargo_pod.get_item_count({type = "item", name = "powerSat"}) > 0 then
    on_satellite_launched(event.cargo_pod.force, event.cargo_pod.surface, "powerSat")
  end
end
script.on_event(defines.events.on_cargo_pod_finished_ascending, on_cargo_pod_finished_ascending)

function on_init()
  if storage.powersats == nil then storage.powersats = {} end  
  if storage.powersats["satellite_data"] == nil then storage.powersats["satellite_data"] = {} end
  if storage.powersats["data"] == nil then storage.powersats["data"] = {} end
  if storage.powersats["ground_stations"] == nil then storage.powersats["ground_stations"] = {} end
  
  storage.powersats["data"]["baseSolarProduction"] = prototypes.entity["solar-panel"].get_max_energy_production() -- Joules per tick
  storage.powersats["data"]["baseSolarProductionW"] = prototypes.entity["solar-panel"].get_max_energy_production() * 60 -- Joules per second
  storage.powersats["data"]["solarSatMultiplier"] = 100
  
  storage.powersats["data"]["powerGeneration"] = {}
  storage.powersats["data"]["powerGeneration"]["powerSat"] = storage.powersats["data"]["baseSolarProduction"]
  PowerSats.powerGeneration = storage.powersats["data"]["powerGeneration"]
    
  if storage.powersats["data"]["lifetime"] == nil then storage.powersats["data"]["lifetime"] = {} end
  storage.powersats["data"]["lifetime"]["powerSat"] = 4320000
  PowerSats.lifetime = storage.powersats["data"]["lifetime"]
    
  storage.powersats["combinators"] = {}
  
  if storage.powersats["data"]["mod_compat"] == nil then storage.powersats["data"]["mod_compat"] = {} end
  
  if script.active_mods["space-exploration"] then
    PowerSats.SE = true
    storage.powersats["data"]["mod_compat"]["space-exploration"] = true
  else
    PowerSats.SE = false
    storage.powersats["data"]["mod_compat"]["space-exploration"] = false
  end
  
  if script.active_mods["space-age"] then
    PowerSats.SA = true
    storage.powersats["data"]["mod_compat"]["space-age"] = true
  else
    PowerSats.SA = false
    storage.powersats["data"]["mod_compat"]["space-age"] = false
  end
end
script.on_init(on_init)

function on_load()
  PowerSats.powerGeneration = storage.powersats["data"]["powerGeneration"]
  PowerSats.lifetime = storage.powersats["data"]["lifetime"]
  PowerSats.SE = storage.powersats["data"]["mod_compat"]["space-exploration"]
  PowerSats.SA = storage.powersats["data"]["mod_compat"]["space-age"]
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
  
  if script.active_mods["space-exploration"] then
    PowerSats.SE = true
  else
    PowerSats.SE = false
  end
  
  if script.active_mods["space-age"] then
    PowerSats.SA = true
  else
    PowerSats.SA = false
  end
  
  if storage.powersats["data"]["stored_pods"] ~= nil then
    for key, value in pairs(storage.powersats["data"]["stored_pods"]) do
      for _, cargo_pod in pairs(value) do
        on_satellite_launched(cargo_pod.force, cargo_pod.surface, "powerSat")
      end
    end
    storage.powersats["data"]["stored_pods"] = nil
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

  PowerSats.EntityBuilt(data.entity)
  
end, { { filter = "name", name="powersat-ground-station" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_robot_built_entity, function(data)

  PowerSats.EntityBuilt(data.entity)

end, { { filter = "name", name="powersat-ground-station" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_player_mined_entity, function(data)
  
  PowerSats.EntityRemoved(data.entity)
  
end, { { filter = "name", name="powersat-ground-station" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_robot_mined_entity, function(data)
  
  PowerSats.EntityRemoved(data.entity)
  
end, { { filter = "name", name="powersat-ground-station" }, { filter = "name", name="powersat-combinator" } })

script.on_event(defines.events.on_entity_died, function(data)

  PowerSats.EntityRemoved(data.entity)

end, { { filter = "name", name="powersat-ground-station" }, { filter = "name", name="powersat-combinator" } })