fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Event Generation Engine for Emergency Services Sim'
version '1.0.0'

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
    'config.json'
}

dependencies {
    'unit_management'  -- For assignments
}