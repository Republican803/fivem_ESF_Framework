-- Unit Management System - Server Side

-- Centralized Unit Table: {unitId = {src (player) or 'AI', role, agency, status, position, vehicle, health, fuel, ...}}
local units = {}
local unitCounter = 0  -- For unique unit IDs

-- Status Enum
local Status = {
    Available = "Available",
    EnRoute = "En Route",
    OnScene = "On Scene",
    Code3 = "Code 3",
    OOS = "Out of Service"
}

-- Agency Colors for Blips (RGB)
local agencyColors = {
    LSPD = 3,  -- Blue
    Sheriff = 5,  -- Green
    HighwayPatrol = 1,  -- Red
    CentralEMS = 1,  -- Red
    RuralEMS = 1,
    LSFD = 1,
    RuralFire = 1
}

-- Register New Unit (Triggered from role_assignment)
RegisterServerEvent('unit_management:registerUnit')
AddEventHandler('unit_management:registerUnit', function(role, agency, isAI)
    local src = source
    unitCounter = unitCounter + 1
    local unitId = "UNIT-" .. unitCounter
    
    units[unitId] = {
        src = isAI and 'AI' or src,
        role = role,
        agency = agency,
        status = Status.Available,
        position = isAI and vector3(0,0,0) or GetEntityCoords(GetPlayerPed(src)),  -- Update later
        vehicle = nil,
        health = 100.0,
        fuel = 100.0
    }
    
    -- Broadcast to all clients
    TriggerClientEvent('unit_management:updateUnits', -1, units)
    
    -- Immersion: Radio chatter
    TriggerClientEvent('unit_management:playRadioChatter', -1, "Unit " .. unitId .. " now " .. units[unitId].status)
    
    if isAI then
        -- Spawn AI unit (placeholder coords; tie to agency spawns)
        TriggerClientEvent('unit_management:spawnAIUnit', -1, unitId, role, agency)
    end
end)

-- Update Status
RegisterServerEvent('unit_management:updateStatus')
AddEventHandler('unit_management:updateStatus', function(unitId, newStatus)
    if units[unitId] then
        units[unitId].status = newStatus
        TriggerClientEvent('unit_management:updateUnits', -1, units)
        TriggerClientEvent('unit_management:playRadioChatter', -1, "Unit " .. unitId .. " status update: " .. newStatus)
    end
end)

-- Update Position (Periodic from clients)
RegisterServerEvent('unit_management:updatePosition')
AddEventHandler('unit_management:updatePosition', function(unitId, pos)
    if units[unitId] then
        units[unitId].position = pos
        TriggerClientEvent('unit_management:updateUnits', -1, units)  -- Sync blips
    end
end)

-- Assign Unit to Event (Placeholder for future dispatch system)
RegisterServerEvent('unit_management:assignToEvent')
AddEventHandler('unit_management:assignToEvent', function(eventId, coords, eventType)
    -- Find nearest appropriate unit
    local bestUnit = nil
    local minDist = math.huge
    for unitId, data in pairs(units) do
        if data.status == Status.Available and IsUnitSuitable(data.role, eventType) then
            local dist = #(data.position - coords)
            if dist < minDist then
                minDist = dist
                bestUnit = unitId
            end
        end
    end
    
    if bestUnit then
        units[bestUnit].status = Status.EnRoute
        TriggerClientEvent('unit_management:routeUnit', units[bestUnit].src == 'AI' and -1 or units[bestUnit].src, bestUnit, coords, false)  -- Code3 false by default
        TriggerClientEvent('unit_management:updateUnits', -1, units)
        TriggerClientEvent('unit_management:playRadioChatter', -1, "Dispatching " .. bestUnit .. " to event.")
    end
end)

-- Helper: Is Unit Suitable for Event
function IsUnitSuitable(role, eventType)
    if eventType == "Fire" and role == "Fire" then return true end
    if eventType == "Medical" and role == "EMS" then return true end
    if eventType == "Crime" and role == "Police" then return true end
    return false
end

-- Request Backup
RegisterServerEvent('unit_management:requestBackup')
AddEventHandler('unit_management:requestBackup', function(srcCoords, roleNeeded)
    -- Similar to assign, but multiple units
    local assigned = 0
    for unitId, data in pairs(units) do
        if data.status == Status.Available and data.role == roleNeeded then
            units[unitId].status = Status.EnRoute
            TriggerClientEvent('unit_management:routeUnit', data.src == 'AI' and -1 or data.src, unitId, srcCoords, true)  -- Code3 true
            assigned = assigned + 1
            if assigned >= 2 then break end  -- e.g., 2 backups
        end
    end
    TriggerClientEvent('unit_management:updateUnits', -1, units)
end)

-- AI Simulation Loop (Health, Fuel, OOS)
Citizen.CreateThread(function()
    while true do
        for unitId, data in pairs(units) do
            if data.src == 'AI' then
                -- Simulate degradation
                data.fuel = data.fuel - 0.1  -- Slow drain
                if data.fuel < 20 then
                    data.status = Status.OOS
                    TriggerClientEvent('unit_management:updateUnits', -1, units)
                    TriggerClientEvent('unit_management:playRadioChatter', -1, unitId .. " out of service: Low fuel.")
                end
                -- Vehicle health check (client reports)
            end
        end
        Wait(60000)  -- Every minute
    end
end)

-- Integration: Listen for spawns from role_assignment
AddEventHandler('role_assignment:spawnPlayer', function(src, role, agency)
    TriggerServerEvent('unit_management:registerUnit', role, agency, false)
end)

-- AI Auto-Populate Based on Server Load
Citizen.CreateThread(function()
    local targetAI = #GetActivePlayers() * 2  -- e.g., 2 AI per player
    while true do
        local currentAI = 0
        for _, data in pairs(units) do if data.src == 'AI' then currentAI = currentAI + 1 end end
        if currentAI < targetAI then
            -- Spawn AI (random role/agency)
            local roles = {"Police", "EMS", "Fire"}
            local role = roles[math.random(1,3)]
            local agency = next(departments[role])  -- From previous script
            TriggerServerEvent('unit_management:registerUnit', role, agency, true)
        end
        Wait(300000)  -- Every 5 mins
    end
end)