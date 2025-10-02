AddEventHandler('esf:dispatch:newCall', function(call)
    TriggerClientEvent('esf:sim:playRadioChatter', -1, 'dispatch_call')  -- Custom sound
end)