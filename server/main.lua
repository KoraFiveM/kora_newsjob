local spawnedVehicles = {}

Kora.callback.register('qb-newsjob:server:spawnVehicle', function(src, location, index)
    if location ~= 'vehicle' and location ~= 'heli' then return false end
    if type(index) ~= 'number' and type(index) ~= 'string' then return false end
    if exports.kora_core:getPlayerData(src, { 'job', 'name' }) ~= 'news' then return false end
    local garage = Config.Locations[location]
    local vehicle = garage and garage.vehicles and garage.vehicles[index]
    if not vehicle or not Kora.distance.player(src, garage.coords, 5.0) then return false end

    -- Model and coordinates come from this resource, never the client's spawn request.
    local coords = garage.coords
    local netId = Kora.entities.createVehicle(vehicle.name,
        { x = coords.x, y = coords.y, z = coords.z, w = coords.w },
        location == 'heli' and 'heli' or 'automobile')
    if not netId or netId == 0 then return false end
    local entity = NetworkGetEntityFromNetworkId(netId)
    SetEntityRoutingBucket(entity, GetPlayerRoutingBucket(src))
    spawnedVehicles[netId] = { entity = entity, owner = src, itemsGranted = false }
    return netId
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for netId, veh in pairs(spawnedVehicles) do
        if NetworkGetEntityFromNetworkId(netId) == veh.entity and DoesEntityExist(veh.entity) then
            DeleteEntity(veh.entity)
        end
    end
end)

-- netId identifies a vehicle this resource actually spawned (see spawnVehicle above);
-- plate is only used for the qb-vehiclekeys ownership check, items are granted at most once per netId.
RegisterNetEvent('qb-newsjob:server:addVehicleItems', function(netId, plate)
    local src = source
    local Player = exports.kora_core:getPlayerData(src)
    if not Player or Player.job.name ~= 'news' then return end

    local veh = spawnedVehicles[netId]
    if not veh or veh.owner ~= src or veh.itemsGranted then return end
    if NetworkGetEntityFromNetworkId(netId) ~= veh.entity or not DoesEntityExist(veh.entity) then return end
    if not exports['qb-vehiclekeys']:HasKeys(src, plate) then return end

    veh.itemsGranted = true
    exports['qb-inventory']:CreateInventory('trunk-' .. plate)

    for slot, item in pairs(Config.VehicleItems) do
        exports['qb-inventory']:AddItem('trunk-' .. plate, item.name, item.amount, slot, item.info, 'qb-newsjob:vehicleItems')
    end
end)

local equipment = { newscam = true, newsmic = true, newsbmic = true }
RegisterNetEvent('qb-newsjob:server:requestedEquipment', function(item)
    local Player = exports.kora_core:getPlayerData(source)
    if not Player or Player.job.name ~= 'news' or not equipment[item] then return end
    exports['qb-inventory']:AddItem(source, item, 1, nil, nil, 'qb-newsjob:equipment-shop')
end)

local function createNewsUseable(item, clientEvent)
    exports.kora_core:createUseable(item, function(source)
        local Player = exports.kora_core:getPlayerData(source)
        if not Player or Player.job.name ~= 'news' then return end
        TriggerClientEvent(clientEvent, source)
    end)
end

createNewsUseable('newscam', 'Cam:ToggleCam')
createNewsUseable('newsmic', 'Mic:ToggleMic')
createNewsUseable('newsbmic', 'Mic:ToggleBMic')
