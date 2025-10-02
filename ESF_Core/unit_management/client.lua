-- Unit Management System - Client Side

local units = {}  -- Local copy
local blips = {}  -- For minimap

-- Event: Update Units (Sync Blips)
RegisterNetEvent('unit_management:updateUnits')
AddEventHandler('unit_management:updateUnits', function(serverUnits)
    units = serverUnits
    UpdateBlips()
end)

-- Function: Update Minimap Blips
function UpdateBlips()
    for unitId, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    
    for unitId, data in pairs(units) do
        local blip = AddBlipForCoord(data.position.x, data.position.y, data.position.z)
        SetBlipSprite(blip, 1)  -- Generic unit icon; customize per role
        SetBlipColour(blip, agencyColors[data.agency] or 0)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(data.agency .. " " .. unitId .. " (" .. data.status .. ")")
        EndTextCommandSetBlipName(blip)
        blips[unitId] = blip
    end
end

-- Event: Spawn AI Unit
RegisterNetEvent('unit_management:spawnAIUnit')
AddEventHandler('unit_management:spawnAIUnit', function(unitId, role, agency)
    -- Spawn ped and vehicle (placeholders)
    local pedModel = role == "Police" and "s_m_y_cop_01" or "s_m_m_paramedic_01"
    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do Wait(0) end
    
    local vehModel = role == "Police" and "police" or "ambulance"
    RequestModel(GetHashKey(vehModel))
    while not HasModelLoaded(GetHashKey(vehModel)) do Wait(0) end
    
    local spawnPos = units[unitId].position  -- Set initially
    local veh = CreateVehicle(GetHashKey(vehModel), spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
    local ped = CreatePed(pedModel, spawnPos.x, spawnPos.y, spawnPos.z, 0.0, true, false)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    
    units[unitId].vehicle = NetworkGetNetworkIdFromEntity(veh)
    -- Network sync
end)

-- Event: Route Unit (Pathfinding)
RegisterNetEvent('unit_management:routeUnit')
AddEventHandler('unit_management:routeUnit', function(unitId, coords, isCode3)
    local ped = GetPlayerPed(-1)  -- For player; for AI, use entity
    local veh = GetVehiclePedIsIn(ped, false)
    if veh then
        if isCode3 then
            SetVehicleSiren(veh, true)
            -- Priority pathing: Clear area?
        end
        TaskVehicleDriveToCoordLongrange(ped, veh, coords.x, coords.y, coords.z, 30.0, 787263, 10.0)  -- Realistic driving
        -- Check traffic density? Use GetTrafficDensity or custom
    end
end)

-- Event: Play Radio Chatter (Immersion)
RegisterNetEvent('unit_management:playRadioChatter')
AddEventHandler('unit_management:playRadioChatter', function(message)
    -- Placeholder: Use PlaySoundFrontend or TTS
    PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
    -- Show notification
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end)

-- Periodic Position Update (For Players)
Citizen.CreateThread(function()
    while true do
        Wait(5000)  -- Every 5 secs
        local unitId = GetUnitIdForPlayer()  -- Function to find player's unitId from units table
        if unitId then
            TriggerServerEvent('unit_management:updatePosition', unitId, GetEntityCoords(PlayerPedId()))
        end
    end
end)

-- Helper: Get Player's Unit ID
function GetUnitIdForPlayer()
    for id, data in pairs(units) do
        if data.src == GetPlayerServerId(PlayerId()) then return id end
    end
    return nil
end

-- Vehicle Health/Fuel Sync (Simulation)
Citizen.CreateThread(function()
    while true do
        Wait(10000)  -- Every 10 secs
        local unitId = GetUnitIdForPlayer()
        if unitId and units[unitId].vehicle then
            local veh = NetToVeh(units[unitId].vehicle)
            if veh then
                local health = GetEntityHealth(veh) / 10.0  -- Normalize
                local fuel = GetVehicleFuelLevel(veh)
                if health < units[unitId].health or fuel < units[unitId].fuel then
                    units[unitId].health = health
                    units[unitId].fuel = fuel
                    if health < 50 then
                        TriggerServerEvent('unit_management:updateStatus', unitId, Status.OOS)
                    end
                end
            end
        end
    end
end)

-- Player Commands (Examples)
RegisterCommand('status', function(source, args)
    local newStatus = args[1]
    local unitId = GetUnitIdForPlayer()
    if unitId and Status[newStatus] then
        TriggerServerEvent('unit_management:updateStatus', unitId, Status[newStatus])
    end
end, false)

RegisterCommand('backup', function()
    local unitId = GetUnitIdForPlayer()
    if unitId then
        TriggerServerEvent('unit_management:requestBackup', GetEntityCoords(PlayerPedId()), units[unitId].role)
    end
end, false)