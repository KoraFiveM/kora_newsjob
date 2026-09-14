local QBCore = exports['qb-core']:GetCoreObject({ 'Functions', 'Commands' })

RegisterNetEvent('qb-newsjob:server:addVehicleItems', function(plate)
    local src = source
    local Player = exports['qb-core']:GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
    if not exports['qb-vehiclekeys']:HasKeys(src, plate) then return end

    exports['qb-inventory']:CreateInventory('trunk-' .. plate)

    for slot, item in pairs(Config.VehicleItems) do
        exports['qb-inventory']:AddItem('trunk-' .. plate, item.name, item.amount, slot, item.info, 'qb-newsjob:vehicleItems')
    end
end)

exports['qb-core']:CreateUseableItem('newscam', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
    TriggerClientEvent('Cam:ToggleCam', source)
end)
exports['qb-core']:CreateUseableItem('newsmic', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
    TriggerClientEvent('Mic:ToggleMic', source)
end)
exports['qb-core']:CreateUseableItem('newsbmic', function(source)
    local Player = exports['qb-core']:GetPlayer(source)
    if not Player or Player.PlayerData.job.name ~= 'reporter' then return end
    TriggerClientEvent('Mic:ToggleBMic', source)
end)