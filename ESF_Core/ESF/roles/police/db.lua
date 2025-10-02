-- NCIC Sim (Extend MDT queries)
AddEventHandler('esf:mdt:runQuery', function(queryType, input)
    if queryType == 'ncic' then
        local result = GetNCICRecord(input)  -- RNG/sim DB
        TriggerClientEvent('esf:mdt:queryResult', source, result)
    end
end)

function GetNCICRecord(input)
    return {name = 'John Doe', history = 'Wanted for GTA', vehicles = 'Stolen plate ABC123'}
end