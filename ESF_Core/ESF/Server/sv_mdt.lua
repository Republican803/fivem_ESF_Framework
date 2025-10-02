-- Simulated DB
local simulatedDB = {
    vehicles = {},
    peds = {},
    bolos = {}
}

function UpdateMDTForAll(action, data)
    TriggerClientEvent('esf:mdt:' .. action, -1, data)
end

RegisterServerEvent('esf:mdt:updateStatus')
AddEventHandler('esf:mdt:updateStatus', function(status)
    local playerId = source
    local unit = units[playerId]
    if unit then
        unit.status = status
        UpdateMDTForAll('updateUnits', units)
    end
end)

RegisterServerEvent('esf:mdt:runQuery')
AddEventHandler('esf:mdt:runQuery', function(queryType, input)
    local playerId = source
    local result = {}
    if queryType == 'plate' then
        result = simulatedDB.vehicles[input] or {model = 'Unknown', color = 'Unknown', owner = 'No Record'}
    elseif queryType == 'warrant' then
        result = simulatedDB.peds[input] or {name = 'John Doe', dob = '01/01/1990', warrants = 'No Warrants'}
    elseif queryType == 'bolo' then
        result = simulatedDB.bolos
    end
    TriggerClientEvent('esf:mdt:queryResult', playerId, {type = queryType, data = result})
end)

RegisterServerEvent('esf:mdt:requestResource')
AddEventHandler('esf:mdt:requestResource', function(resType)
    local playerId = source
    -- Spawn based on type (tow, air, swat, hazmat)
    BroadcastDispatch("Resource " .. resType .. " requested by Unit " .. units[playerId].callsign, -1)
end)

RegisterServerEvent('esf:radio:send')
AddEventHandler('esf:radio:send', function(message)
    local playerId = source
    local unit = units[playerId]
    local logEntry = {sender = unit.callsign, msg = message, time = os.time()}
    TriggerClientEvent('esf:radio:receive', -1, logEntry)
end)

AddEventHandler('esf:dispatch:newCall', function(call)
    UpdateMDTForAll('updateCalls', callQueue)
end)