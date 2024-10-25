local PowerSats = {}

function PowerSats.LaunchPowerSat(_force, _surface, _sat_type)
  if PowerSats.SE then
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", { surface_index = _surface.index })
    
    if zone.type == "orbit" and zone.parent and zone.parent.type ~= "star" then
      local parent_zone = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = zone.parent_index })
      if parent_zone.surface_index then
        _surface = game.surfaces[parent_zone.surface_index]
      end
    end
    
    if zone.type ~= "planet" and zone.type ~= "moon" then
      return
    end
  end
  
  local surface_name = _surface.name
  if surface_name == "nauvis" then surface_name = "Nauvis" end

  if storage.powersats["satellite_data"][_force.index] == nil then storage.powersats["satellite_data"][_force.index] = {} end
  local force_table = storage.powersats["satellite_data"][_force.index]
  
  if force_table[_surface.index] == nil then force_table[_surface.index] = {} end
  local surface_table = force_table[_surface.index]
  if surface_table["power_multiplier"] == nil then
    if PowerSats.SE then
      surface_table["power_multiplier"] = PowerSats.SEGetOrbitSolarPercent(_surface.index) * 10
    else 
      surface_table["power_multiplier"] = storage.powersats["data"]["solarSatMultiplier"]
    end
  end
  surface_table["power_generated"] = surface_table["power_generated"] or 0
  
  if surface_table["satellite_data"] == nil then surface_table["satellite_data"] = {} end  
  if surface_table["satellite_data"][_sat_type] == nil then surface_table["satellite_data"][_sat_type] = {} end
  local sat_type_table = surface_table["satellite_data"][_sat_type]
  
  local count = sat_type_table["count"] or 0
  
  if sat_type_table["satellites"] == nil then sat_type_table["satellites"] = {} end
  local satellite_table = sat_type_table["satellites"]

  table.insert(satellite_table, {
    time_added = game.tick,
    lifetime = PowerSats.lifetime[_sat_type],
    time_death = game.tick + PowerSats.lifetime[_sat_type],
    last_checked = game.tick
  })
  
  count = count + 1
  sat_type_table["count"] = count
  
  PowerSats.UpdateCombinators(_force.index, _surface.index)
end

function PowerSats.SEGetOrbitSolarPercent(_surface_index)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", { surface_index = _surface_index })
  local orbit_zone = nil
  local planet_zone = nil
  local star_zone = nil
  
  
  if zone.type == "orbit" and zone.parent and zone.parent.type ~= "star" then
    -- zone is orbit
    orbit_zone = zone
    planet_zone = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = orbit_zone.parent_index })
  elseif zone.type == "planet" or zone.type == "moon" then
    planet_zone = zone
    orbit_zone = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = planet_zone.orbit_index })
  else
    return 0
  end
  
  star_zone = remote.call("space-exploration", "get_zone_from_zone_index", { zone_index = planet_zone.parent_index })
  
  local percent = 1.6 * planet_zone.star_gravity_well / (star_zone.star_gravity_well + 1)
  percent = percent * 5
  percent = percent * (1 - 0.1 * planet_zone.radius / 10000)
  percent = percent + 0.01
  percent = percent * 2
  
  return percent

end

function PowerSats.UpdateTick()
  for k, v in pairs(storage.powersats["satellite_data"]) do
    PowerSats.IterateForce(k, v)
  end
end

function PowerSats.IterateForce(_force_index, _force_table)
  for k, v in pairs(_force_table) do
    PowerSats.IterateSurface(k, v, _force_index)
  end
end

function PowerSats.IterateSurface(_surface_index, _surface_table, _force_index)

  local needToUpdate = false

  local new_power_generated = 0
  for k, v in pairs(_surface_table["satellite_data"]) do
    if PowerSats.IteratePowersatType(k, v) then needToUpdate = true end
    new_power_generated = new_power_generated + _surface_table["satellite_data"][k]["count"] * PowerSats.powerGeneration[k] * PowerSats.GetSurfacePowerMultiplier(_force_index, _surface_index)
  end
  
  _surface_table["power_generated"] = new_power_generated
  
  if needToUpdate then PowerSats.UpdateCombinators(_force_index, _surface_index) end
end

function PowerSats.GetSurfacePowerMultiplier(_force_index, _surface_index)
  return storage.powersats["satellite_data"][_force_index][_surface_index]["power_multiplier"]
end

function PowerSats.IteratePowersatType(_type, _table)

  local needToUpdate = false

  for k, v in pairs(_table["satellites"]) do
    if v.last_checked < game.tick then
      v.last_checked = game.tick
            
      if game.tick >= v.time_death then
        _table["satellites"][k] = nil
        _table["count"] = _table["count"] - 1
        needToUpdate = true
      end
    end
  end

  return needToUpdate

end

function PowerSats.GroundStationBuilt(_entity)
  
  local surface_name = _entity.surface.name
  if surface_name == "nauvis" then surface_name = "Nauvis" end
  
  if storage.powersats["ground_stations"]["station_data"] == nil then storage.powersats["ground_stations"]["station_data"] = {} end
  local stationTable = storage.powersats["ground_stations"]["station_data"]
  
  if stationTable[_entity.force.index] == nil then stationTable[_entity.force.index] = {} end
  local forceTable = stationTable[_entity.force.index]
  
  if forceTable[_entity.surface.index] == nil then forceTable[_entity.surface.index] = {} end
  local surfaceTable = forceTable[_entity.surface.index]
  
  local count = surfaceTable["count"] or 0
  count = count + 1
  
  surfaceTable["count"] = count
  
  if surfaceTable["stations"] == nil then surfaceTable["stations"] = {} end
  
  table.insert(surfaceTable["stations"], _entity)
  
  local totalCount = storage.powersats["ground_stations"]["count"] or 0
  totalCount = totalCount + 1
  storage.powersats["ground_stations"]["count"] = totalCount
  
end

function PowerSats.GroundStationRemoved(_entity)

  local surface_name = _entity.surface.name
  if surface_name == "nauvis" then surface_name = "Nauvis" end

  local surfaceTable = storage.powersats["ground_stations"]["station_data"][_entity.force.index][_entity.surface.index]
  PowerSats.RemoveStation(surfaceTable, _entity)
  surfaceTable["count"] = surfaceTable["count"] - 1
  
  storage.powersats["ground_stations"]["count"] = storage.powersats["ground_stations"]["count"] - 1
end

function PowerSats.RemoveStation(_surfaceTable, _entity)

  
  for k, v in pairs(_surfaceTable["stations"]) do
  
    if v == _entity then
    
      _surfaceTable["stations"][k] = nil
      return
    
    end
  
  end

end

function PowerSats.Tick(_tick)

  local totalCount = storage.powersats["ground_stations"]["count"] or 0

  if totalCount == 0 then return end
  
  for k, v in pairs(storage.powersats["ground_stations"]["station_data"]) do
    PowerSats.GroundStationIterateForce(k, v)
  end

end

function PowerSats.GroundStationIterateForce(_force_index, _force_table)

  for k, v in pairs(_force_table) do
    PowerSats.GroundStationIterateSurface(k, v, _force_index)
  end

end

function PowerSats.GroundStationIterateSurface(_surface_index, _surface_table, _force_index)
  if _surface_table["count"] == 0 then return end
  
  local powerProduced = PowerSats.GetPowerGeneration(_force_index, _surface_index)
    
  local powerPerStation = powerProduced / _surface_table["count"]
  
  for k, v in pairs(_surface_table["stations"]) do
  
    v.energy = powerPerStation
  
  end
  
end

function PowerSats.GetPowerGeneration(_force_index, _surface_index)

  if storage.powersats["satellite_data"][_force_index] == nil then return 0 end
  
  if storage.powersats["satellite_data"][_force_index][_surface_index] == nil then return 0 end

  return storage.powersats["satellite_data"][_force_index][_surface_index]["power_generated"]

end

function PowerSats.CombinatorBuilt(_entity)
  
  local surface_name = _entity.surface.name
  if surface_name == "nauvis" then surface_name = "Nauvis" end
  
  if storage.powersats["combinators"][_entity.force.index] == nil then storage.powersats["combinators"][_entity.force.index] = {} end
  local forceTable = storage.powersats["combinators"][_entity.force.index]
  
  if forceTable[_entity.surface.index] == nil then forceTable[_entity.surface.index] = {} end
  local surfaceTable = forceTable[_entity.surface.index]
  
  table.insert(surfaceTable, _entity)
  
  local behaviour = _entity.get_or_create_control_behavior()
  if (behaviour.sections_count == 0) then behaviour.add_section() end
  local section = behaviour.get_section(1)
  section.set_slot(1, { value = { name = "powerSat", type="item", quality = "normal" }, min = 0, max = 0, import_from = nil }) --, max = 0 })  
  PowerSats.UpdateCombinators(_entity.force.index, _entity.surface.index)
  
end

function PowerSats.CombinatorRemoved(_entity)

  local surface_name = _entity.surface.name
  if surface_name == "nauvis" then surface_name = "Nauvis" end

  local surfaceTable = storage.powersats["combinators"][_entity.force.index][_entity.surface.index]
  PowerSats.RemoveCombinator(surfaceTable, _entity)
  
end

function PowerSats.RemoveCombinator(_surfaceTable, _entity)
  
  for k, v in pairs(_surfaceTable) do
  
    if v == _entity then
    
      _surfaceTable[k] = nil
      return
    
    end
  
  end

end

function PowerSats.UpdateCombinators(_force, _surface)

  if (storage.powersats["combinators"][_force]) == nil then return end
  
  if (storage.powersats["combinators"][_force][_surface]) == nil then return end

  for k,v in pairs(storage.powersats["combinators"][_force][_surface]) do
    if storage.powersats["satellite_data"][_force] ~= nil and storage.powersats["satellite_data"][_force][_surface] ~= nil then
  
      for l,b in pairs(storage.powersats["satellite_data"][_force][_surface]["satellite_data"]) do
        local count = b["count"]        
        local behaviour = v.get_or_create_control_behavior()
        local section = behaviour.get_section(1)
        local slot = section.get_slot(1)
        slot.min = count
        slot.max = count
        section.set_slot(1, slot)
      end
  
    end
  end

end

function PowerSats.EntityBuilt(_entity)
  _entity.operable = false

  local f_tab = {}
  f_tab["powersat-ground-station-entity"] = PowerSats.GroundStationBuilt
  f_tab["powersat-combinator"] = PowerSats.CombinatorBuilt
  
  local func = f_tab[_entity.name]
  if func then
    func(_entity)
  end
end

function PowerSats.EntityRemoved(_entity)
  local f_tab = {}
  f_tab["powersat-ground-station-entity"] = PowerSats.GroundStationRemoved
  f_tab["powersat-combinator"] = PowerSats.CombinatorRemoved
  
  local func = f_tab[_entity.name]
  if func then
    func(_entity)
  end
end

return PowerSats