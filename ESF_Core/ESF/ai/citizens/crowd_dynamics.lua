function SpawnCrowd(loc, count)
    for i = 1, count do
        local model = GetHashKey(math.random() < 0.5 and 'a_m_y_business_01' or 'a_f_y_business_01')
        local ped = CreatePed('PED_TYPE_CIVMALE', model, loc.x + math.random(-30,30), loc.y + math.random(-30,30), loc.z, 0.0, true, false)
        TaskGoToCoordAnyMeans(ped, loc.x, loc.y, loc.z, 1.0, 0, 0, 786603, 0xbf800000)
        if math.random() < 0.1 then
            TriggerClientEvent('esf:ai:crowdInterfere', -1, NetworkGetNetworkIdFromEntity(ped))
        elseif math.random() < 0.2 then
            TaskPlayAnim(ped, 'cellphone@', 'cellphone_call_out', 8.0, -8.0, -1, 1, 0, false, false, false)
            -- Simulate 911 call (trigger new dispatch)
            TriggerEvent('esf:dispatch:newCall', {code = '10-78', location = loc})
        end
    end
end