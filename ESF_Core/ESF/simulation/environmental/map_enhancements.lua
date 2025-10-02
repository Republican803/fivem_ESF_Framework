RegisterServerEvent('esf:sim:deployProp')
AddEventHandler('esf:sim:deployProp', function(prop, pos)
    local model = GetHashKey(prop)  -- e.g., 'prop_roadcone02a' for flares
    local obj = CreateObject(model, pos.x, pos.y, pos.z, true, true, false)
    -- Persist during call (cleanup on resolve)
end)