RegisterServerEvent('esf:police:deploySpike')
AddEventHandler('esf:police:deploySpike', function(pos)
    local spikeModel = GetHashKey('p_ld_stinger_s')
    local spike = CreateObject(spikeModel, pos.x, pos.y, pos.z - 1.0, true, true, false)
    TriggerClientEvent('esf:police:spikeSync', -1, NetworkGetNetworkIdFromEntity(spike))
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        for _, veh in ipairs(GetAllVehicles()) do
            if IsVehicleNearSpike(veh) then  -- Dist check to spikes
                SetVehicleTyreBurst(veh, math.random(0, 5), true, 1000.0)
            end
        end
    end
end)

function IsVehicleNearSpike(veh)
    -- Logic to check dist to all spawned spikes
    return false  -- Placeholder
end

-- Pursuit Trigger from Callout
AddEventHandler('esf:callout:update', function(callId, update)
    if update.escalateTo == '10-80' then
        local ped = GetCalloutPed(callId)  -- From entities
        local veh = GetVehiclePedIsIn(ped)
        TaskVehicleDriveWander(ped, veh, 100.0, 786603)  -- Evasive driving
    end
end)