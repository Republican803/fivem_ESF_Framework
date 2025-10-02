RegisterNetEvent('esf:ai:sync')
AddEventHandler('esf:ai:sync', function(vehNetId, pedNetId)
    local veh = NetworkGetEntityFromNetworkId(vehNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    SetVehicleSiren(veh, true)
    -- Anim/behavior client-side (e.g., lights)
end)

-- PED Reaction Client
RegisterNetEvent('esf:ai:pedReact')
AddEventHandler('esf:ai:pedReact', function(pedNetId, behavior)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    if behavior == 'flee' then
        TaskReactAndFleePed(ped, PlayerPedId())
    elseif behavior == 'panic' then
        TaskPlayAnim(ped, 'missheist_agency2astumble', 'stumble', 8.0, -8.0, -1, 1, 0, false, false, false)
    elseif behavior == 'comply' then
        TaskHandsUp(ped, 60000, -1, -1, true)
    end
end)

-- Crowd Interference
RegisterNetEvent('esf:ai:crowdInterfere')
AddEventHandler('esf:ai:crowdInterfere', function(pedNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    TaskCombatPed(ped, PlayerPedId(), 0, 16)  -- Rare interference
end)