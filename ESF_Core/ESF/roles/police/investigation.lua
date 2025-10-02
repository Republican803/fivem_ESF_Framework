RegisterServerEvent('esf:police:collectEvidence')
AddEventHandler('esf:police:collectEvidence', function(evId)
    -- Add to player inventory
    TriggerClientEvent('esf:mdt:newAlert', source, 'Evidence collected: ' .. evId)
end)

RegisterServerEvent('esf:police:interrogatePed')
AddEventHandler('esf:police:interrogatePed', function(pedNetId)
    local playerId = source
    local pedId = NetworkGetEntityFromNetworkId(pedNetId)
    local pedData = GetPedData(pedId)  -- From sim DB
    local response = math.random() > 0.5 and pedData.warrants or 'No comment'
    TriggerClientEvent('esf:mdt:newAlert', playerId, 'Interrogation: ' .. response)
end)