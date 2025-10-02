-- Role and Agency Assignment System - Server Side

-- Database Table Creation (Run this once via server console or migration)
MySQL.ready(function()
    MySQL.Sync.execute([[
        CREATE TABLE IF NOT EXISTS player_agencies (
            identifier VARCHAR(50) PRIMARY KEY,
            character_name VARCHAR(100),
            role ENUM('Police', 'EMS', 'Fire'),
            agency VARCHAR(50),
            last_switch TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            cooldown_minutes INT DEFAULT 10,
            switch_count INT DEFAULT 0
        );
    ]])
end)

-- Departments and Spawns (Placeholders - Replace with your document)
local departments = {
    Police = {
        LSPD = { spawn = vector4(425.0, -981.0, 30.7, 90.0), description = "Urban patrol, high-crime response" },
        Sheriff = { spawn = vector4(-448.0, 6013.0, 31.7, 90.0), description = "County-wide enforcement" },
        HighwayPatrol = { spawn = vector4(1540.0, 832.0, 77.7, 90.0), description = "Traffic and pursuit focus" }
    },
    EMS = {
        CentralEMS = { spawn = vector4(300.0, -600.0, 43.3, 90.0), description = "City medical response" },
        RuralEMS = { spawn = vector4(1830.0, 3670.0, 34.3, 90.0), description = "Outlying area support" }
    },
    Fire = {
        LSFD = { spawn = vector4(215.0, -1640.0, 29.8, 90.0), description = "Urban fire and rescue" },
        RuralFire = { spawn = vector4(-100.0, 6300.0, 31.5, 90.0), description = "Wildland and remote ops" }
    }
}

-- Event: Player Joining - Check for existing character
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    local src = source
    local identifier = GetPlayerIdentifier(src, 'license')  -- Or use steam/license as needed

    local result = MySQL.Sync.fetchAll('SELECT * FROM player_agencies WHERE identifier = @identifier', {['@identifier'] = identifier})
    
    if #result > 0 then
        -- Existing character: Auto-assign and spawn
        local data = result[1]
        TriggerClientEvent('role_assignment:spawnPlayer', src, data.role, data.agency, departments[data.role][data.agency].spawn)
        deferrals.done()
    else
        -- New player: Open NUI for creation
        TriggerClientEvent('role_assignment:openNUI', src, true)  -- true for creation mode
        deferrals.done()
    end
end)

-- Callback: Save new character from NUI
RegisterServerEvent('role_assignment:saveCharacter')
AddEventHandler('role_assignment:saveCharacter', function(characterData)
    local src = source
    local identifier = GetPlayerIdentifier(src, 'license')
    
    MySQL.Sync.execute([[
        INSERT INTO player_agencies (identifier, character_name, role, agency, last_switch, cooldown_minutes, switch_count)
        VALUES (@identifier, @name, @role, @agency, CURRENT_TIMESTAMP, 10, 0)
    ]], {
        ['@identifier'] = identifier,
        ['@name'] = characterData.name,
        ['@role'] = characterData.role,
        ['@agency'] = characterData.agency
    })
    
    -- Spawn player
    local spawn = departments[characterData.role][characterData.agency].spawn
    TriggerClientEvent('role_assignment:spawnPlayer', src, characterData.role, characterData.agency, spawn)
end)

-- Event: Open duty menu for switching (Triggered from client at HQs)
RegisterServerEvent('role_assignment:requestSwitch')
AddEventHandler('role_assignment:requestSwitch', function()
    local src = source
    local identifier = GetPlayerIdentifier(src, 'license')
    
    local result = MySQL.Sync.fetchAll('SELECT TIMESTAMPDIFF(MINUTE, last_switch, NOW()) AS time_diff, switch_count FROM player_agencies WHERE identifier = @identifier', {['@identifier'] = identifier})
    
    if #result > 0 then
        local data = result[1]
        if data.time_diff >= 10 then  -- Cooldown check
            TriggerClientEvent('role_assignment:openNUI', src, false)  -- false for switch mode
        else
            TriggerClientEvent('role_assignment:showMessage', src, "Cooldown active: Wait " .. (10 - data.time_diff) .. " minutes.")
        end
    end
end)

-- Callback: Perform switch
RegisterServerEvent('role_assignment:performSwitch')
AddEventHandler('role_assignment:performSwitch', function(newData)
    local src = source
    local identifier = GetPlayerIdentifier(src, 'license')
    
    MySQL.Sync.execute([[
        UPDATE player_agencies SET role = @role, agency = @agency, last_switch = CURRENT_TIMESTAMP, switch_count = switch_count + 1
        WHERE identifier = @identifier
    ]], {
        ['@identifier'] = identifier,
        ['@role'] = newData.role,
        ['@agency'] = newData.agency
    })
    
    -- Apply penalty if frequent switches (e.g., >3 in session)
    local result = MySQL.Sync.fetchScalar('SELECT switch_count FROM player_agencies WHERE identifier = @identifier', {['@identifier'] = identifier})
    if result > 3 then
        TriggerClientEvent('role_assignment:applyDebuff', src, 'fatigue')  -- Client handles debuff
    end
    
    -- Respawn with new agency
    local spawn = departments[newData.role][newData.agency].spawn
    TriggerClientEvent('role_assignment:spawnPlayer', src, newData.role, newData.agency, spawn)
end)

-- Basic AI Spawning (Expand for full sim)
Citizen.CreateThread(function()
    while true do
        local playerCount = #GetActivePlayers()
        -- Spawn AI based on load (e.g., 1 AI per 5 players per agency)
        for role, agencies in pairs(departments) do
            for agency, data in pairs(agencies) do
                -- Example: Spawn AI ped at spawn point
                local aiModel = 's_m_y_cop_01'  -- Customize per role
                local aiPed = CreatePed(aiModel, data.spawn.x, data.spawn.y, data.spawn.z, data.spawn.w, true, false)
                -- Task AI (e.g., wander)
                TaskWanderStandard(aiPed, 10.0, 10)
            end
        end
        Wait(60000)  -- Adjust interval
    end
end)