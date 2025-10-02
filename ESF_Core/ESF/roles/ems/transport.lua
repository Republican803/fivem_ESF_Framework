RegisterServerEvent('esf:ems:loadPed')
AddEventHandler('esf:ems:loadPed', function(pedNetId, vehNetId)
    TriggerClientEvent('esf:ems:loadPed', -1, pedNetId, vehNetId)
end)

RegisterServerEvent('esf:ems:handoverHospital')
AddEventHandler('esf:ems:handoverHospital', function(pedNetId)
    -- Despawn ped, log success
    DeleteEntity(NetworkGetEntityFromNetworkId(pedNetId))
    TriggerClientEvent('esf:mdt:newAlert', source, 'Patient handed over')
end)