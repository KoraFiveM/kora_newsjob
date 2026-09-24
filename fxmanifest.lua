fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot'
description 'Simple news job equipment and vehicle spawns'
version '1.5.0'

dependency 'qblib'

ui_page 'web/index.html'
files { 'web/index.html', 'web/app.js', 'web/style.css', 'web/vendor/react.js', 'web/vendor/react-dom.js' }

shared_scripts {
    '@qblib/init.lua',
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/spawner.lua',
    'client/camera.lua',
}

server_script 'server/main.lua'
