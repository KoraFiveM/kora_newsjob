function storeCurrentVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end

    local plate = exports['qb-core']:GetPlate(veh)
    if not CurrentPlate[plate] then return end

    TriggerServerEvent('qb-vehiclekeys:server:RemoveVehicleKeys', plate)
    CurrentPlate[plate] = nil
    DeleteVehicle(veh)
end

local function spawnReporterVehicle(args)
    if exports.qbcore:getPlayerData().job.name ~= 'news' then return end
    local coords = Config.Locations[args.location].coords

    exports['qb-core']:TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
        local veh = NetToVeh(netId)
        local plate = 'WZNW' .. math.random(1000, 9999)
        SetVehicleNumberPlateText(veh, plate)
        CurrentPlate[plate] = true
        SetEntityHeading(veh, coords.w)
        exports.qbfuel:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent('vehiclekeys:client:SetOwner', plate)
        SetVehicleEngineOn(veh, true, true, false)
        if args.modLivery then
            local livery = GetVehicleLiveryCount(veh) < 0 and args.modLivery - 1 or args.modLivery
            exports['qb-core']:SetVehicleProperties(veh, { modLivery = livery })
        end
        if Config.VehicleItems and args.location == 'vehicle' then
            TriggerServerEvent('qb-newsjob:server:addVehicleItems', plate)
        end
    end, args.vehicle, coords, true)
end

local garageAppId = 'qb-newsjob:garage'
local spawnVehicleAction = 'qb-newsjob:spawn-vehicle'
local vehicleChoices = {}

local function buildGarageNavigation()
    local navigation = {}

    for _, location in ipairs({ 'vehicle', 'heli' }) do
        local garage = Config.Locations[location]
        local vehicles = garage and garage.vehicles or {}
        local items = {}

        for index, vehicle in pairs(vehicles) do
            local id = ('%s:%s'):format(location, index)
            vehicleChoices[id] = { vehicle = vehicle.name, location = location, modLivery = vehicle.modLivery }
            items[#items + 1] = {
                id = id,
                label = vehicle.label,
                action = { id = spawnVehicleAction, label = 'Take vehicle' },
            }
        end

        navigation[#navigation + 1] = {
            id = location,
            label = QB.lang('text.' .. location),
            icon = location == 'vehicle' and 'Car' or 'Helicopter',
            content = {
                title = QB.lang('text.' .. location),
                blocks = #items > 0 and { { type = 'list', id = location, items = items } }
                    or { { type = 'empty', title = 'No vehicles available', icon = 'CircleOff' } },
            },
        }
    end

    return navigation
end

QB.nui.registerApp({
    id = garageAppId,
    title = 'Weazel News Garage',
    icon = 'Newspaper',
    layout = 'compact',
    navigation = buildGarageNavigation(),
    onAction = function(actionId, context)
        if actionId ~= spawnVehicleAction then return end

        local vehicle = vehicleChoices[context and context.itemId]
        if vehicle then spawnReporterVehicle(vehicle) end
    end,
})

function menuGarage(location)
    if not Config.Locations[location] or not Config.Locations[location].vehicles then return end
    QB.nui.openApp(garageAppId, { viewId = location })
end
