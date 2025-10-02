local callouts = {}

Citizen.CreateThread(function()
    local paths = {'/callouts/base/', '/callouts/custom/'}
    for _, path in ipairs(paths) do
        local files = -- Get files logic (use os or exports)
        for _, file in ipairs(files) if file:endswith('.json') then
            local data = json.decode(LoadResourceFile(GetCurrentResourceName(), path .. file))
            callouts[data.id] = data
            local luaFile = path .. file:gsub('.json', '.lua')
            if DoesFileExist(luaFile) then
                data.script = load(LoadResourceFile(GetCurrentResourceName(), luaFile))
            end
        end
    end
end)

AddEventHandler('esf:callout:trigger', function(callId, loc, variantIdx)
    local data = callouts[callId]
    if data then
        local selectedVariant = data.variants[variantIdx or math.random(1, #data.variants)]
        -- Spawn PEDs, props
        -- TriggerClientEvent('esf:callout:start', -1, {id = callId, objectives = data.objectives, entities = ...})
        if data.script then data.script() end
        UpdateMDTForAll('updateCalls', {id = callId, desc = data.desc})
    end
end)

RegisterServerEvent('esf:callout:resolve')
AddEventHandler('esf:callout:resolve', function(callId, success)
    local playerId = source
    local unit = units[playerId]
    if success then
        unit.xp = (unit.xp or 0) + 50
    else
        unit.status = 'suspended'
    end
    -- Cleanup
end)

AddEventHandler('onResourceChange', function(res)
    if res == GetCurrentResourceName() then
        -- Reload callouts
    end
end)