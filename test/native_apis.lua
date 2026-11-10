-- Run from kora_newsjob: lua5.4 test/native_apis.lua
local callbacks, events, useable = {}, {}, {}
local job, near, spawnResult = 'news', true, 71
local spawns, buckets, deleted = {}, {}, {}
vector4 = function(x, y, z, w) return { x = x, y = y, z = z, w = w } end
Kora = {
    callback = { register = function(name, handler) callbacks[name] = handler end },
    distance = { player = function(src, coords, radius)
        assert(src == 12 and radius == 5.0 and coords.x)
        return near
    end },
    entities = { createVehicle = function(model, coords, vehicleType)
        spawns[#spawns + 1] = { model = model, coords = coords, vehicleType = vehicleType }
        return spawnResult
    end },
}
exports = { kora_core = {
    getPlayerData = function(_, src, path)
        assert(src == 12)
        return path and job or { job = { name = job } }
    end,
    createUseable = function(_, item, handler) useable[item] = handler end,
} }
RegisterNetEvent = function(name, handler) events[name] = handler end
AddEventHandler = RegisterNetEvent
GetCurrentResourceName = function() return 'kora_newsjob' end
NetworkGetEntityFromNetworkId = function(netId) return netId + 100 end
GetPlayerRoutingBucket = function(src) assert(src == 12); return 8 end
SetEntityRoutingBucket = function(entity, bucket) buckets[entity] = bucket end
DoesEntityExist = function(entity) return not deleted[entity] end
DeleteEntity = function(entity) deleted[entity] = true end
dofile('config.lua')
dofile('server/main.lua')
assert(useable.newscam and useable.newsmic and useable.newsbmic)
local spawn = assert(callbacks['qb-newsjob:server:spawnVehicle'])
assert(spawn(12, 'vehicle', 1) == 71)
assert(spawns[1].model == 'rumpo' and spawns[1].vehicleType == 'automobile')
assert(spawns[1].coords.x == Config.Locations.vehicle.coords.x and buckets[171] == 8)
spawnResult = 72
assert(spawn(12, 'heli', 1) == 72)
assert(spawns[2].model == 'conada' and spawns[2].vehicleType == 'heli')
assert(not spawn(12, 'shop', 1))
assert(not spawn(12, 'vehicle', 999))
assert(not spawn(12, 'vehicle', {}))
job = 'unemployed'
assert(not spawn(12, 'vehicle', 1))
job, near = 'news', false
assert(not spawn(12, 'vehicle', 1) and #spawns == 2)
near, spawnResult = true, false
assert(not spawn(12, 'vehicle', 1))
events.onResourceStop('another-resource')
assert(not next(deleted))
events.onResourceStop('kora_newsjob')
assert(deleted[171] and deleted[172])

local app, requests, warps = nil, 0, 0
CurrentPlate = {}
exports.kora_core.getPlayerData = function() return job end
exports.kora_fuel = { SetFuel = function(_, entity, fuel) assert(entity == 171 and fuel == 100.0) end }
Kora.lang = function(key) return key end
Kora.nui = { registerApp = function(definition) app = definition end }
Kora.callback.trigger = function(name, location, index)
    assert(name == 'qb-newsjob:server:spawnVehicle' and location == 'vehicle' and index == 1)
    requests = requests + 1
    return spawnResult
end
Kora.loops = { controlled = function(handler) return handler() end }
Kora.vehicle = { requestControl = function() return true end, setProperties = function(entity, props)
    assert(entity == 171 and props.modLivery == 2)
end }
NetToVeh = function(netId) return netId + 100 end
PlayerPedId = function() return 1 end
TaskWarpPedIntoVehicle = function(_, entity) assert(entity == 171); warps = warps + 1 end
SetVehicleNumberPlateText = function() end
SetEntityHeading = function() end
SetVehicleEngineOn = function() end
GetVehicleLiveryCount = function() return 2 end
TriggerEvent = function() end
TriggerServerEvent = function(name) assert(name == 'qb-newsjob:server:addVehicleItems') end
deleted, spawnResult = {}, 71
dofile('client/spawner.lua')
app.onAction('qb-newsjob:spawn-vehicle', { itemId = 'vehicle:1' })
assert(requests == 1 and warps == 1 and next(CurrentPlate))
job = 'unemployed'
app.onAction('qb-newsjob:spawn-vehicle', { itemId = 'vehicle:1' })
assert(requests == 1)
job, spawnResult = 'news', false
app.onAction('qb-newsjob:spawn-vehicle', { itemId = 'vehicle:1' })
assert(warps == 1)
print('kora_newsjob: native spawns, job/location checks, bucket isolation and cleanup passed')
