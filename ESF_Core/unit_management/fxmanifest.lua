fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Unit Management System for Emergency Services Sim'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',  -- If needed for persistence
    'server.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'oxmysql',  -- Optional
    'role_assignment'  -- For integration
}