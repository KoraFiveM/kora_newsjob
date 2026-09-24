Config = {}

Config.UseableItems = true -- Set to false if you want to use commands instead of usable items

Config.Locations = {
    main =  vector4(-597.89, -929.95, 24.0, 271.5),
    inside = vector4(-77.46, -833.77, 243.38, 67.5),
    outside = vector4(-598.25, -929.86, 23.86, 86.5),
    vehicle = {
        coords = vector4(-552.24, -925.61, 23.86, 242.5),
        vehicles = {
            { name = 'rumpo', label = 'Rumpo', modLivery = 2 },
        },
    },
    heli = {
        coords = vector4(-583.08, -930.55, 36.83, 89.26),
        vehicles = {
            { name = 'conada', label = 'Conada', modLivery = 5},
        }
    },
    shop = vector4(-595.4, -929.9, 23.86, 90.0),
}

Config.VehicleItems = {
    { name = 'newscam', amount = 1,  info = {}},
    { name = 'newsmic', amount = 1,  info = {}},
    { name = 'newsbmic', amount = 1, info = {}},
}

-- Registers this resource-owned configuration with qblib.
if QB and QB.config and QB.config.adopt then Config = QB.config.adopt(Config) end
