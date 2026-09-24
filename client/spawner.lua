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

function menuGarage(location)
    local currentGarrage = Config.Locations[location]
    if not currentGarrage or not currentGarrage.vehicles then return end

    local menu = { { header = QB.lang('text.' .. location), isMenuHeader = true } }

    for veh, vehData in pairs(currentGarrage.vehicles) do
        menu[#menu + 1] = {
            header = vehData.label,
            action = function()
                spawnReporterVehicle({ vehicle = vehData.name, location = location, modLivery = vehData.modLivery })
            end
        }
    end
    exports['qb-menu']:openMenu(menu)
end
