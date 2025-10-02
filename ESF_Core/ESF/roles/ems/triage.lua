RegisterServerEvent('esf:ems:triageScene')
AddEventHandler('esf:ems:triageScene', function(sceneId)
    local peds = GetScenePeds(sceneId)
    table.sort(peds, function(a, b) return GetInjuryScore(a) > GetInjuryScore(b) end)
    UpdateMDTForAll('updateTriage', {scene = sceneId, list = peds})
end)

function GetInjuryScore(ped)
    return 100 - GetEntityHealth(ped) / 2  -- Simple score
end