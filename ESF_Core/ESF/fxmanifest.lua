fx_version 'cerulean'
game 'gta5'

author 'Failure Friends Studio'
description 'Emergency Services Framework v1.0'
version '1.0.0'

server_scripts {
    'server/__resource.lua',
    'server/sv_dispatch.lua',
    'server/sv_mdt.lua',
    'server/sv_callouts.lua',
    'server/sv_roles.lua',
    'server/sv_ai.lua',
    'server/sv_simulation.lua',
    'simulation/environmental/weather_time.lua',
    'simulation/environmental/map_enhancements.lua',
    'simulation/resource_fatigue/vehicle_maintenance.lua',
    'simulation/resource_fatigue/personnel_sim.lua',
    'simulation/progression/skill_trees.lua',
    'simulation/progression/training_modes.lua',
    'simulation/audio_visual/sirens_radios.lua',
    'simulation/audio_visual/camera_modes.lua',
    'simulation/events/escalation_chains.lua',
    'server/config.lua'
}

client_scripts {
    'client/__resource.lua',
    'client/cl_dispatch.lua',
    'client/cl_mdt.lua',
    'client/cl_callouts.lua',
    'client/cl_roles.lua',
    'client/cl_ai.lua',
    'client/cl_simulation.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*'
}

shared_scripts {
    'shared/zones.json'
}

dependencies {
    'PolyZone',
    'mumble-voip'
}