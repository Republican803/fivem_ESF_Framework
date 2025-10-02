RegisterNetEvent('esf:callout:start')
AddEventHandler('esf:callout:start', function(data)
    -- Client-side PED behaviors (e.g., SetBlockingOfNonTemporaryEvents)
    -- Show objective checklist UI (NUI or DrawText)
    -- GPS blip on loc
    AddBlipForCoord(data.location.x, data.location.y, data.location.z)
end)

RegisterNetEvent('esf:callout:update')
AddEventHandler('esf:callout:update', function(callId, update)
    -- Handle evolution (e.g., PED flee animation)
end)

RegisterNetEvent('esf:callout:fail')
AddEventHandler('esf:callout:fail', function(reason)
    -- Show failure UI
end)