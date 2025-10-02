RegisterServerEvent('esf:fire:start')
AddEventHandler('esf:fire:start', function(pos, size)
    StartScriptFire(pos.x, pos.y, pos.z, size, false)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        local wind = GetWindSpeed()
        for _, fire in ipairs(GetAllFires()) do  -- Custom tracker
            if math.random() < (0.1 + wind * 0.05) then
                StartScriptFire(fire.pos.x + math.random(-5,5), fire.pos.y + math.random(-5,5), fire.pos.z, fire.size + 1, false)
            end
        end
    end
end)

RegisterServerEvent('esf:fire:extinguish')
AddEventHandler('esf:fire:extinguish', function(pos)
    RemoveScriptFire(pos.x, pos.y, pos.z)
end)