local skills = {}  -- Per player {driving = 1, medical = 0, etc.}

AddEventHandler('esf:callout:resolve', function(callId, success, playerId)
    if success then
        skills[playerId] = skills[playerId] or {}
        local skillType = GetCallSkill(call.code)  -- e.g., 'driving' for 10-80
        skills[playerId][skillType] = (skills[playerId][skillType] or 0) + 1
        if skills[playerId][skillType] > 10 then
            -- Unlock: e.g., better PIT success (mod chance in client)
            TriggerClientEvent('esf:sim:unlockSkill', playerId, skillType)
        end
    end
end)