fx_version 'cerulean'
game 'gta5'
lua54 'yes'
-- Keep the legacy resource name resolvable for exports['qbnewsjob'] callers.
provide 'qbnewsjob'
author 'Kakarot'
description 'Simple news job equipment and vehicle spawns'
version '1.5.0'

dependency 'kora_lib'
dependency 'kora_core'

shared_scripts {
    '@kora_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/spawner.lua',
    'client/camera.lua',
}

server_script 'server/main.lua'

files { 'locales/*.lua' }
