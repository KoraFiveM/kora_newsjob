QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
CurrentPlate = {}
Blip = nil

local function removeBlip()
    if Blip then
        QB.blips.remove(Blip)
        Blip = nil
    end
end
local function spawnBlips()
    if exports.qbcore:getPlayerData().job.name ~= 'news' then return end
    Blip = QB.blips.create(Config.Locations.vehicle.coords, {
        label = QB.lang('text.vehicle'),
        sprite = 225,
        color = 1,
        scale = 0.6,
        shortRange = true
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnBlips()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUpdated', function(key, val)
    removeBlip()
    spawnBlips()
end)

local function returnVec3(coords)
    return vector3(coords.x, coords.y, coords.z)
end


CreateThread(function()
    QB.interact.addBoxZone('news_garage', 
    returnVec3(Config.Locations.vehicle.coords),
    vector3(4.0, 4.0, 4.0), {
        {
            label = QB.lang('text.vehicles'),
            icon = "fas fa-car",
            action = function()
                menuGarage('vehicle')
            end,
            canInteract = function()
                return exports.qbcore:getPlayerData().job.name == 'news'
            end
        }
    })
    QB.interact.addBoxZone('news_heli', returnVec3(Config.Locations.heli.coords), vector3(4.0, 4.0, 4.0), {
        {
            label = QB.lang('text.helicopters'),
            icon = "fas fa-helicopter",
            action = function()
                menuGarage('heli')
            end,
            canInteract = function()
                return exports.qbcore:getPlayerData().job.name == 'news'
            end
        }
    })
end)

QB.interact.addBoxZone('news_equipment_shop', returnVec3(Config.Locations.shop), vector3(2.0, 2.0, 2.0), {
    {
        label = 'Take news camera', icon = 'fas fa-camera',
        action = function() TriggerServerEvent('qb-newsjob:server:requestedEquipment', 'newscam') end,
        canInteract = function() return exports.qbcore:getPlayerData().job.name == 'news' end,
    },
    {
        label = 'Take boom mic', icon = 'fas fa-microphone',
        action = function() TriggerServerEvent('qb-newsjob:server:requestedEquipment', 'newsmic') end,
        canInteract = function() return exports.qbcore:getPlayerData().job.name == 'news' end,
    },
    {
        label = 'Take hand mic', icon = 'fas fa-microphone',
        action = function() TriggerServerEvent('qb-newsjob:server:requestedEquipment', 'newsbmic') end,
        canInteract = function() return exports.qbcore:getPlayerData().job.name == 'news' end,
    },
})

local function returnOptions(targCoords, text, teleCoords)
    exports.qbtarget:addBoxZone({
        coords = targCoords,
        size = vector3(1.5, 1.5, 1.5),
        rotation = 0,
        debug = false,
        options = {
            {
                icon = "fas fa-door-open",
                label = text,
                onSelect = function()
                    QB.visuals.fade(teleCoords, 500)
                end,
                canInteract = function()
                    if exports.qbcore:getPlayerData().job.name ~= 'news' then
                        return false
                    end
                    return true
                end
            }
        }
    })
end
if Config.Locations.outside then
    returnOptions(Config.Locations.outside, QB.lang('text.enter'), Config.Locations.inside)
end
if Config.Locations.inside then
    returnOptions(Config.Locations.inside, QB.lang('text.exit'), Config.Locations.outside)
end
