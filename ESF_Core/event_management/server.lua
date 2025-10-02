-- Event Generation Engine - Server Side

local config = json.decode(LoadResourceFile(GetCurrentResourceName(), 'config.json'))
local activeEvents = {}  -- {eventId = {type, coords, role, status, startTime, entities}}
local eventCounter = 0

-- Helper: Get World State
function GetWorldState()
    local weather = GetWeatherTypeTransition()  -- Native for current weather
    local hour = GetClockHours()
    local isRain = (weather == 'RAIN' or weather == 'THUNDER')
    local isNight = (hour >= 20 or hour < 6)
    return {isRain = isRain, isNight = isNight}
end

-- Helper: Get Zone Density (Urban check)
function IsUrbanZone(coords)
    local zone = GetNameOfZone(coords.x, coords.y, coords.z)
    -- Placeholders: Add more urban zones from GTA map
    local urbanZones = {'LOSPUER', 'ALTA', 'MIRR'}  -- e.g., Los Santos areas
    for _, z in ipairs(urbanZones) do
        if zone == z then return true end
    end
    return false
end

-- Procedural Event Generator (Coroutine)
local function GenerateEvent()
    while true do
        if #activeEvents >= config.maxActiveEvents then
            coroutine.yield()  -- Wait if max reached
        end
        
        local worldState = GetWorldState()
        local spawnChance = math.random()
        local eventRole = math.random() < config.commonChance and 'Common' or (math.random() < config.rareChance and 'Rare' or 'Medium')
        -- Select role randomly, weighted
        local roles = {"Police", "EMS", "Fire"}
        local role = roles[math.random(1, #roles)]
        
        -- Select event type with modifiers
        local pool = config.eventPools[role]
        local selectedType = nil
        local maxProb = 0
        for evType, data in pairs(pool) do
            local mod = 1.0
            if worldState.isRain and config.modifiers.rain[evType] then mod = config.modifiers.rain[evType] end
            if worldState.isNight and config.modifiers.night[evType] then mod = config.modifiers.night[evType] end
            local prob = data.probability * mod
            if prob > maxProb then
                maxProb = prob
                selectedType = evType
            end
        end
        
        if selectedType then
            -- Random coords (GTA world bounds; refine with map data)
            local coords = vector3(math.random(-2000, 2000), math.random(-2000, 2000), 30.0)
            if IsUrbanZone(coords) and config.modifiers.urban[selectedType] then
                -- Apply urban mod if applicable
            end
            
            eventCounter = eventCounter + 1
            local eventId = "EVENT-" .. eventCounter
            activeEvents[eventId] = {
                type = selectedType,
                coords = coords,
                role = role,
                status = "Active",
                startTime = GetGameTimer(),
                entities = {}  -- PEDs, vehicles, etc.
            }
            
            -- Spawn event entities (server-side create, client sync)
            TriggerClientEvent('event_generation:spawnEvent', -1, eventId, role, selectedType, coords)
            
            -- Assign via unit_management
            TriggerEvent('unit_management:assignToEvent', eventId, coords, role)  -- Event type as role for suitability
            
            -- Immersion: Broadcast radio
            TriggerClientEvent('unit_management:playRadioChatter', -1, "New " .. role .. " event: " .. selectedType .. " at coords.")
            
            print("[Event Gen] Spawned: " .. eventId .. " - " .. selectedType)
        end
        
        Wait(config.baseSpawnInterval)
        coroutine.yield()
    end
end

-- Start Generator
Citizen.CreateThread(function()
    local co = coroutine.create(GenerateEvent)
    while true do
        coroutine.resume(co)
        Wait(0)  -- Non-blocking
    end
end)

-- Evolution Loop: Escalate/Chain
Citizen.CreateThread(function()
    while true do
        for eventId, data in pairs(activeEvents) do
            if data.status == "Active" and (GetGameTimer() - data.startTime > config.escalationTime) then
                -- Escalate
                data.status = "Escalated"
                TriggerClientEvent('event_generation:escalateEvent', -1, eventId)
                -- Chain reaction? 10% chance
                if math.random() < 0.1 then
                    -- e.g., Crash → Fire
                    if data.type == "Accident" then
                        data.role = "Fire"
                        data.type = "VehicleFire"
                        TriggerClientEvent('event_generation:spawnEvent', -1, eventId, "Fire", "VehicleFire", data.coords)
                    end
                end
                -- Re-assign if needed
                TriggerEvent('unit_management:assignToEvent', eventId, data.coords, data.role)
            end
        end
        Wait(60000)  -- Check every min
    end
end)

-- Event Resolution (e.g., from unit arrival/on-scene)
RegisterServerEvent('event_generation:resolveEvent')
AddEventHandler('event_generation:resolveEvent', function(eventId)
    if activeEvents[eventId] then
        -- Cleanup entities
        TriggerClientEvent('event_generation:cleanupEvent', -1, eventId)
        activeEvents[eventId] = nil
        print("[Event Gen] Resolved: " .. eventId)
    end
end)