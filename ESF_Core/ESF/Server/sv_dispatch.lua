local units = {}
local callQueue = {}

-- Utility Functions
local function GenerateUniqueCallId()
    return 'CALL_' .. math.random(1000, 9999) .. os.time()
end

local function GetDistanceBetweenCoords(pos1, pos2)
    return #(vector3(pos1.x, pos1.y, pos1.z) - vector3(pos2.x, pos2.y, pos2.z))
end

local function IsInJurisdiction(unit, loc)
    local zone = PolyZone:GetZoneAtCoords(loc.x, loc.y, loc.z)
    local primaries = Config.Zones[zone].primary
    local secondaries = Config.Zones[zone].secondary or {}
    return table.contains(primaries, unit.agency) or table.contains(secondaries, unit.agency)
end

local function GetSpecificAgency(category, zone)
    local primaries = Config.Zones[zone].primary
    for _, dept in ipairs(primaries) do
        if table.contains(Config.Departments[category], dept) then return dept end
    end
    return Config.Departments[category][1] -- Fallback to first dept in category
end

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then return true end
    end
    return false
end

-- Unit Management
function RegisterUnit(playerId, agency, callsign)
    local ped = GetPlayerPed(playerId)
    units[playerId] = {playerId = playerId, agency = agency, callsign = callsign, pos = GetEntityCoords(ped), status = 'available', entity = ped, callCount = 0}
end

RegisterServerEvent('esf:playerSpawn')
AddEventHandler('esf:playerSpawn', function()
    local playerId = source
    -- Dynamic agency/callsign assignment via menu or config (e.g., LSPD_Adam1)
    RegisterUnit(playerId, 'LSPD', 'Adam1') -- Placeholder, replace with dynamic logic
end)

-- Trigger Handler
local function TriggerCallout(zone, codeId)
    local callData = Config.Codes[codeId]
    local spawnCoords = vector3(0, 0, 0) -- Replace with GetRandomHotspotInZone(zone) impl
    local pedsRange = {tonumber(callData.peds:match("(%d+)-(%d+)"))}
    local pedCount = math.random(pedsRange[1], pedsRange[2] or pedsRange[1])
    local peds = {} -- Replace with SpawnPedsForCallout(pedCount, spawnCoords)
    local call = {
        id = GenerateUniqueCallId(),
        code = codeId,
        priority = callData.priority,
        location = spawnCoords,
        desc = callData.desc,
        agency = callData.primaryAgency,
        specificAgency = GetSpecificAgency(callData.primaryAgency, zone),
        entities = {peds = peds}
    }
    TriggerEvent('esf:dispatch:newCall', call)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.PulseInterval * 1000)
        for zone, data in pairs(Config.Zones) do
            if math.random() < data.hotspotDensity then
                local codeIds = {}
                for code, data in pairs(Config.Codes) do
                    if data.primaryAgency == "POLICE" or data.primaryAgency == "FIRE" or data.primaryAgency == "EMS" then
                        table.insert(codeIds, code)
                    end
                end
                local codeId = codeIds[math.random(1, #codeIds)]
                TriggerCallout(zone, codeId)
            end
        end
    end
end)

-- Dispatch Logic
RegisterServerEvent('esf:dispatch:newCall')
AddEventHandler('esf:dispatch:newCall', function(call)
    local eligibleUnits = {}
    for _, unit in pairs(units) do
        if unit.agency == call.specificAgency and unit.status == 'available' and IsInJurisdiction(unit, call.location) then
            unit.distance = GetDistanceBetweenCoords(unit.pos, call.location)
            if unit.distance < Config.ProxThreshold then table.insert(eligibleUnits, unit) end
        end
    end
    table.sort(eligibleUnits, function(a, b) return a.distance < b.distance end)
    local assigned = eligibleUnits[1]
    local zone = PolyZone:GetZoneAtCoords(call.location.x, call.location.y, call.location.z)
    if not assigned and Config.Zones[zone].secondary then
        TriggerEvent('esf:dispatch:mutualAid', call)
    elseif not assigned and #eligibleUnits == 0 then
        assigned = {callsign = 'AI_' .. math.random(100, 999), agency = call.specificAgency} -- Spawn AI placeholder
    end
    if assigned then
        if assigned.playerId then
            TriggerClientEvent('esf:dispatch:assign', assigned.playerId, call)
            BroadcastDispatch("Unit " .. assigned.callsign .. ", assigned to " .. call.code .. ". 10-97?", -1)
        else
            BroadcastDispatch("AI Unit " .. assigned.callsign .. " dispatched to " .. call.code .. ".", -1)
            -- Implement AI spawn logic here
        end
    else
        AddToQueue(call)
    end
end)

RegisterServerEvent('esf:dispatch:mutualAid')
AddEventHandler('esf:dispatch:mutualAid', function(call)
    local zone = PolyZone:GetZoneAtCoords(call.location.x, call.location.y, call.location.z)
    local secondary = Config.Zones[zone].secondary
    if secondary then
        for _, secDept in ipairs(secondary) do
            if table.contains(Config.Departments[call.agency], secDept) then
                call.specificAgency = secDept
                break
            end
        end
        BroadcastDispatch("Mutual aid: " .. call.desc .. ". " .. call.specificAgency .. " units, accept?", -1)
        -- Wait for accept event (timeout 30s), else spawn AI
    end
end)

function AddToQueue(call)
    table.insert(callQueue, {call = call, time = GetGameTimer(), priority = call.priority})
    table.sort(callQueue, function(a, b) return a.priority < b.priority end)
    TriggerClientEvent('esf:dispatch:updateQueue', -1, callQueue)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(120000)
        for i = #callQueue, 1, -1 do
            local elapsed = (GetGameTimer() - callQueue[i].time) / 60000
            if elapsed > 10 then
                if math.random() < 0.3 then
                    table.remove(callQueue, i)
                    BroadcastDispatch(callQueue[i].call.code .. " cleared by off-duty. 10-74 negative.", -1)
                else
                    callQueue[i].priority = math.max(1, callQueue[i].priority - 1)
                    TriggerEvent('esf:dispatch:newCall', callQueue[i].call)
                end
            end
        end
    end
end)

-- Unit Availability Checks
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(30000)
        for _, unit in pairs(units) do
            unit.pos = GetEntityCoords(unit.entity or GetPlayerPed(unit.playerId))
            if unit.status == 'busy' and IsCallComplete(unit.currentCall) then
                unit.status = 'available'
                -- StartPaperworkMiniGame(unit.playerId) -- Client event placeholder
            end
            -- ApplyFatigue(unit) -- Placeholder for AI slowdown
        end
        TriggerClientEvent('esf:updateUnits', -1, units)
    end
end)

function IsCallComplete(call)
    -- Placeholder: Implement logic to check if call objectives are met (e.g., PEDs treated)
    return true -- Default for now
end

function BroadcastDispatch(message, target)
    TriggerClientEvent('chat:addMessage', target or -1, {
        color = {255, 255, 0},
        multiline = true,
        args = {"Dispatch", message}
    })
end