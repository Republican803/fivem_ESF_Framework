-- Police Client
RegisterCommand('deploySpike', function()
    local pos = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('esf:police:deploySpike', pos)
end, false)

RegisterNetEvent('esf:police:spikeSync')
AddEventHandler('esf:police:spikeSync', function(netId)
    local spike = NetworkGetEntityFromNetworkId(netId)
    -- Render spike prop client-side
end)

RegisterCommand('pitManeuver', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local targetVeh = GetClosestVehicle(...)  -- Custom get closest
    if IsDrivingClose(targetVeh) then
        ApplyForceToEntity(targetVeh, 1, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    end
end, false)

-- EMS Client
RegisterCommand('treatPed', function()
    local ped = GetClosestPed(...)  -- Custom raycast
    TriggerServerEvent('esf:ems:treatPed', NetworkGetNetworkIdFromEntity(ped), 'defib')
end, false)

RegisterNetEvent('esf:ems:loadPed')
AddEventHandler('esf:ems:loadPed', function(pedNetId, vehNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    local veh = NetworkGetEntityFromNetworkId(vehNetId)
    AttachEntityToEntity(ped, veh, GetEntityBoneIndexByName(veh, 'seat_pside_r'), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    TaskPlayAnim(ped, 'missheistdockssetup1ig_12@base', 'victim_base', 8.0, -8.0, -1, 1, 0, false, false, false)  -- Injured anim
end)

-- Fire Client
RegisterCommand('deployHose', function()
    -- Particle effect for water jet
    UseParticleFxAssetNextCall("core")
    local ptfx = StartParticleFxLoopedAtCoord("water_cannon_jet", GetEntityCoords(PlayerPedId()), 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    -- Aim raycast to extinguish
    local hit, pos = GetRaycastResult(...)
    TriggerServerEvent('esf:fire:extinguish', pos)
end, false)

RegisterNetEvent('esf:fire:rescueAnim')
AddEventHandler('esf:fire:rescueAnim', function(pedNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    TaskPlayAnim(PlayerPedId(), 'missfbi5ig_0', 'lift_hands_in_air_loop', 8.0, -8.0, -1, 1, 0, false, false, false)
    -- Carry ped
end)