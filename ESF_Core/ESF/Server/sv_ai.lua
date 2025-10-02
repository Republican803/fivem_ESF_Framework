local aiUnits = {}
local activePEDs = {}

-- AI Responder Spawn
function SpawnAIResponder(agency, loc, role)
    local vehModel = GetHashKey(agency == 'police' and 'police' or agency == 'fire' and 'firetruk' or 'ambulance')
    local pedModel = GetHashKey('s_m_y_cop_01')  -- Agency-specific
    local spawnPos = vector3(loc.x + math.random(-50,50), loc.y + math.random(-50,50), loc.z)
    local veh = CreateVehicle(vehModel, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
    local ped = CreatePed('MISSION', pedModel, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
    SetPedAsCop(ped, true)  -- For police AI
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetVehicleSiren(veh, true)
    TaskVehicleDriveToCoord(ped, veh, loc.x, loc.y, loc.z, 50.0, 0, vehModel, 786603, 1.0, true)
    local netId = NetworkGetNetworkIdFromEntity(ped)
    aiUnits[netId] = {agency = agency, role = role, ped = ped, veh = veh}
    TriggerClientEvent('esf:ai:sync', -1, NetworkGetNetworkIdFromEntity(veh), netId)
    ExecuteBehaviorTree(agency, role, ped, loc)
    UpdateMDTForAll('updateUnits', aiUnits)
end

-- Behavior Tree Executor
function ExecuteBehaviorTree(agency, role, ped, loc)
    if agency == 'police' and role == 'backup' then
        PoliceBackupTree(ped, loc)
    elseif agency == 'ems' and role == 'first_aid' then
        EMSFirstAidTree(ped, loc)
    elseif agency == 'fire' and role == 'secure' then
        FireSecureTree(ped, loc)
    end
end

-- Scalability
AddEventHandler('esf:dispatch:needBackup', function(call)
    local playerCount = #GetPlayers()
    local density = playerCount <= 1 and Config.AIDensity.solo or Config.AIDensity.multi
    for i = 1, density do
        SpawnAIResponder(call.agency, call.location, 'backup')
    end
end)

-- PED Citizen AI Application
AddEventHandler('esf:callout:start', function(call)
    for _, ped in ipairs(call.entities.peds) do
        ApplyCitizenBehavior(ped, call.code)  -- e.g., '10-80' = flee
        activePEDs[NetworkGetNetworkIdFromEntity(ped)] = ped
    end
    -- Crowd
    local crowdSize = call.priority * Config.CrowdBaseSize
    SpawnCrowd(call.location, crowdSize)
end)

-- Cleanup on Resolution
AddEventHandler('esf:callout:resolve', function(callId)
    -- Delete AI/PEDs
end)