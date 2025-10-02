-- Mutual Aid Integration
AddEventHandler('esf:dispatch:mutualAid', function(call)
    BroadcastDispatch("Mutual aid requested for " .. call.desc .. " - All agencies respond.", -1)
    if call.agency == 'police' then
        -- Secure scene for EMS/Fire (spawn barriers)
    end
end)

-- Cross-Role Handover (e.g., police to EMS)
RegisterServerEvent('esf:roles:handover')
AddEventHandler('esf:roles:handover', function(fromAgency, toAgency, sceneId)
    -- Transfer control, update MDT
    UpdateMDTForAll('updateScene', {id = sceneId, status = 'Handed over to ' .. toAgency})
end)