Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)  -- 5 min check
        for _, call in ipairs(activeCalls) do
            if not call.resolved then
                EscalateCall(call.id)
            end
        end
    end
end)

function EscalateCall(callId)
    local call = GetCallById(callId)
    local linked = Config.Codes[call.code].linked[math.random(#Config.Codes[call.code].linked)]
    TriggerEvent('esf:dispatch:newCall', {code = linked, location = call.location, escalateFrom = callId})
    TriggerClientEvent('esf:mdt:newAlert', -1, 'Call escalated to ' .. linked)
end