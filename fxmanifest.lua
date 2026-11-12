fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Simple news job equipment and vehicle spawns'
version '0.2.1'

dependency 'kora_lib'
dependency 'kora_core'
-- client/main.lua calls exports.kora_target:addBoxZone at load; this forces kora_target to start first.
dependency 'kora_target'

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

-- kora_qa: Gherkin test scenarios (converted legacy tests), see [kora]/kora_qa/README.md
qa_feature 'tests/*.feature'
