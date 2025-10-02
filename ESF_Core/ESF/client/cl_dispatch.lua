RegisterNetEvent('esf:dispatch:assign')
AddEventHandler('esf:dispatch:assign', function(call)
    -- Show UI prompt to accept/decline
    TriggerServerEvent('esf:dispatch:accept', call.id, GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent('esf:dispatch:updateQueue')
AddEventHandler('esf:dispatch:updateQueue', function(queue)
    -- Update MDT queue
end)

RegisterNetEvent('esf:updateUnits')
AddEventHandler('esf:updateUnits', function(unitData)
    -- Sync unit status to MDT
end)