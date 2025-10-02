-- Event Generation Engine - Client Side

local activeEvents = {}  -- Local copy for effects

-- Event: Spawn Event
RegisterNetEvent('event_generation:spawnEvent')
AddEventHandler('event_generation:spawnEvent', function(eventId, role, evType, coords)
    activeEvents[eventId] = {role = role, type = evType, coords = coords, entities = {}}
    
    -- Spawn PEDs/Hazards (PED-centric)
    if role == "Police" then
        if evType == "Pursuit" then
            -- Spawn fleeing PED in vehicle
            local vehModel = "adder"  -- Random vehicle
            RequestModel(GetHashKey(vehModel))
            while not HasModelLoaded(GetHashKey(vehModel)) do Wait(0) end
            local veh = CreateVehicle(GetHashKey(vehModel), coords.x, coords.y, coords.z, 0.0, true, false)
            local pedModel = "g_m_y_lost_01"
            RequestModel(GetHashKey(pedModel))
            while not HasModelLoaded(GetHashKey(pedModel)) do Wait(0) end
            local ped = CreatePed(pedModel, coords.x + 5, coords.y, coords.z, 0.0, true, false)
            TaskWarpPedIntoVehicle(ped, veh, -1)
            TaskVehicleDriveWander(ped, veh, 50.0, 787263)  -- Flee
            table.insert(activeEvents[eventId].entities, ped)
            table.insert(activeEvents[eventId].entities, veh)
        elseif evType == "Fight" then
            -- Spawn brawling PEDs
            for i=1, 2 do
                local ped = CreatePed("g_m_y_mexgoon_01", coords.x + i*2, coords.y, coords.z, 0.0, true, false)
                TaskCombatPed(ped, GetPlayerPed(-1), 0, 16)  -- But vs. environment; adjust
                table.insert(activeEvents[eventId].entities, ped)
            end
        end
        -- etc. for other types
    elseif role == "EMS" then
        -- Injured PED
        local ped = CreatePed("a_m_y_skater_01", coords.x, coords.y, coords.z, 0.0, true, false)
        SetEntityHealth(ped, 50)  -- Injured
        TaskPlayAnim(ped, "missheistdockssetup1ig_5@base", "worker_injured_base", 8.0, -8.0, -1, 1, 0, false, false, false)
        table.insert(activeEvents[eventId].entities, ped)
    elseif role == "Fire" then
        -- Fire particles
        RequestNamedPtfxAsset("core")
        while not HasNamedPtfxAssetLoaded("core") do Wait(0) end
        UseParticleFxAssetNextCall("core")
        local fire = StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        table.insert(activeEvents[eventId].entities, fire)
        -- Visible smoke afar
    end
    
    -- Immersion: Distant audio if far
    local playerCoords = GetEntityCoords(PlayerPedId())
    if #(playerCoords - coords) > 100 then
        PlaySoundFromCoord(-1, "SIREN_ALPHA", coords.x, coords.y, coords.z, "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true, 200, false)
    end
end)

-- Event: Escalate Event
RegisterNetEvent('event_generation:escalateEvent')
AddEventHandler('event_generation:escalateEvent', function(eventId)
    if activeEvents[eventId] then
        -- e.g., Grow fire
        if activeEvents[eventId].role == "Fire" then
            -- Scale particles or add more
        end
        -- PED behaviors: e.g., more aggressive
    end
end)

-- Event: Cleanup
RegisterNetEvent('event_generation:cleanupEvent')
AddEventHandler('event_generation:cleanupEvent', function(eventId)
    if activeEvents[eventId] then
        for _, ent in ipairs(activeEvents[eventId].entities) do
            if DoesEntityExist(ent) then
                if IsEntityAPed(ent) or IsEntityAVehicle(ent) then
                    DeleteEntity(ent)
                else
                    StopParticleFxLooped(ent, true)  -- For fires
                end
            end
        end
        activeEvents[eventId] = nil
    end
end)

-- Player Resolution (Example: On-scene interaction)
Citizen.CreateThread(function()
    while true do
        Wait(0)
        for eventId, data in pairs(activeEvents) do
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - data.coords) < 10 then
                -- Display help: E to resolve
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('event_generation:resolveEvent', eventId)
                    -- Update status via unit_management
                    local unitId = GetUnitIdForPlayer()  -- From previous client.lua
                    if unitId then
                        TriggerServerEvent('unit_management:updateStatus', unitId, "OnScene")
                    end
                end
            end
        end
    end
end)