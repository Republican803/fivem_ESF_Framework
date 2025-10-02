function ApplyCitizenBehavior(ped, eventType)
    local rand = math.random()
    local behavior = rand < 0.4 and 'flee' or rand < 0.8 and 'comply' or 'panic'
    TriggerClientEvent('esf:ai:pedReact', -1, NetworkGetNetworkIdFromEntity(ped), behavior)
    if eventType:match('fire') or eventType:match('explosion') then
        TaskReactAndFleePed(ped, GetClosestResponder(ped))
    end
    -- Injury sim
    if math.random() < 0.2 then
        SetEntityHealth(ped, GetEntityHealth(ped) - 50)
        SetPedMetadata(ped, 'injured', true)
    end
end