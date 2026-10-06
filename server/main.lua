local spawnedVehicles = {}

QB.callback.register('qb-newsjob:server:spawnVehicle', function(src, location, index)
    if location ~= 'vehicle' and location ~= 'heli' then return false end
    if type(index) ~= 'number' and type(index) ~= 'string' then return false end
    if exports.qbcore:getPlayerData(src, { 'job', 'name' }) ~= 'news' then return false end
    local garage = Config.Locations[location]
    local vehicle = garage and garage.vehicles and garage.vehicles[index]
    if not vehicle or not QB.distance.player(src, garage.coords, 5.0) then return false end

    -- Model and coordinates come from this resource, never the client's spawn request.
    local coords = garage.coords
    local netId = QB.entities.createVehicle(vehicle.name,
        { x = coords.x, y = coords.y, z = coords.z, w = coords.w },
        location == 'heli' and 'heli' or 'automobile')
    if not netId or netId == 0 then return false end
    local entity = NetworkGetEntityFromNetworkId(netId)
    SetEntityRoutingBucket(entity, GetPlayerRoutingBucket(src))
    spawnedVehicles[netId] = entity
    return netId
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for netId, entity in pairs(spawnedVehicles) do
        if NetworkGetEntityFromNetworkId(netId) == entity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
    end
end)

RegisterNetEvent('qb-newsjob:server:addVehicleItems', function(plate)
    local src = source
    local Player = exports.qbcore:getPlayerData(src)
    if not Player or Player.job.name ~= 'news' then return end
    if not exports['qb-vehiclekeys']:HasKeys(src, plate) then return end

    exports['qb-inventory']:CreateInventory('trunk-' .. plate)

    for slot, item in pairs(Config.VehicleItems) do
        exports['qb-inventory']:AddItem('trunk-' .. plate, item.name, item.amount, slot, item.info, 'qb-newsjob:vehicleItems')
    end
end)

local equipment = { newscam = true, newsmic = true, newsbmic = true }
RegisterNetEvent('qb-newsjob:server:requestedEquipment', function(item)
    local Player = exports.qbcore:getPlayerData(source)
    if not Player or Player.job.name ~= 'news' or not equipment[item] then return end
    exports['qb-inventory']:AddItem(source, item, 1, nil, nil, 'qb-newsjob:equipment-shop')
end)

exports.qbcore:createUseable('newscam', function(source)
    local Player = exports.qbcore:getPlayerData(source)
    if not Player or Player.job.name ~= 'news' then return end
    TriggerClientEvent('Cam:ToggleCam', source)
end)
exports.qbcore:createUseable('newsmic', function(source)
    local Player = exports.qbcore:getPlayerData(source)
    if not Player or Player.job.name ~= 'news' then return end
    TriggerClientEvent('Mic:ToggleMic', source)
end)
exports.qbcore:createUseable('newsbmic', function(source)
    local Player = exports.qbcore:getPlayerData(source)
    if not Player or Player.job.name ~= 'news' then return end
    TriggerClientEvent('Mic:ToggleBMic', source)
end)
