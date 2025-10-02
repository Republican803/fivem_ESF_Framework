RegisterServerEvent('esf:fire:rescuePed')
AddEventHandler('esf:fire:rescuePed', function(pedNetId)
    local ped = NetworkGetEntityFromNetworkId(pedNetId)
    if IsPedInFire(ped) then
        ApplyDamageToPed(ped, 5, false)  -- Smoke damage
    end
    TriggerClientEvent('esf:fire:rescueAnim', source, pedNetId)
end)