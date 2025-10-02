RegisterServerEvent('esf:sim:startTraining')
AddEventHandler('esf:sim:startTraining', function(type)
    local playerId = source
    if IsAtStation(GetEntityCoords(GetPlayerPed(playerId))) then
        -- Mini-sim: Spawn dummy PED/callout at station
        local dummy = CreatePed(...)
        TriggerClientEvent('esf:sim:trainingUI', playerId, type)
        Citizen.Wait(60000)  -- Training time
        skills[playerId][type] = (skills[playerId][type] or 0) + 5  -- Fast progression
    end
end)