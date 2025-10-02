Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000)  -- 10 min tick
        for _, unit in pairs(units) do
            unit.fatigue = (unit.fatigue or 0) + 1
            if unit.fatigue > 5 then
                -- Penalty: Slower speed (client SetRunSprintMultiplierForPlayer)
                TriggerClientEvent('esf:sim:fatiguePenalty', unit.playerId, true)
                TriggerClientEvent('esf:mdt:newAlert', unit.playerId, 'Fatigue high - Take 10-7 break')
            end
        end
    end
end)

RegisterServerEvent('esf:sim:takeBreak')
AddEventHandler('esf:sim:takeBreak', function(playerId)
    units[playerId].fatigue = 0
    units[playerId].status = '10-7'
    Citizen.Wait(300000)  -- 5 min break
    units[playerId].status = '10-8'
    TriggerClientEvent('esf:sim:fatiguePenalty', playerId, false)
end)