RegisterServerEvent('esf:fire:useEquipment')
AddEventHandler('esf:fire:useEquipment', function(tool, pos)
    if tool == 'hose' then
        TriggerServerEvent('esf:fire:extinguish', pos)
        -- Deplete tank metadata
    elseif tool == 'ladder' then
        -- Spawn ladder prop, attach to truck
    end
end)