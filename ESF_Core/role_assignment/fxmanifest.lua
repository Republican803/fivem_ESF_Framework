fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Role and Agency Assignment System for Emergency Services Sim'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- Assuming oxmysql is installed
    'server.lua'
}

client_scripts {
    'client.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/script.js',
    'nui/style.css'
}

dependencies {
    'oxmysql'
}