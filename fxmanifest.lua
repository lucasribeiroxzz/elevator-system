fx_version 'cerulean'
game 'gta5'

name 'elevator_system'
description 'Sistema de Elevador Premium - vRP / Creative Network'
author 'Lucassx'
version '1.0.0'
repository 'https://github.com/lucasribeiroxzz/elevator_system'

shared_scripts {
    'config.lua',
    'shared/*.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

lua54 'yes'
