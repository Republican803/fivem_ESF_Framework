RegisterServerEvent('esf:ems:treatPed')
AddEventHandler('esf:ems:treatPed', function(pedNetId, tool)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    if tool == 'defib' and GetEntityHealth(ped) == 0 then
        RevivePed(ped, true, true)
        TriggerClientEvent('esf:mdt:newAlert', source, 'Patient revived')
    elseif tool == 'bandage' then
        SetEntityMetadata(ped, 'bleeding', false)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for _, ped in ipairs(GetAllPedsWithMetadata('injured')) do
            ApplyDamageToPed(ped, 1, false)
            if GetEntityHealth(ped) <= 0 then
                TriggerEvent('esf:callout:update', GetPedCallout(ped), {escalateTo = '9'})
            end
        end
    end
end)