-- Role and Agency Assignment System - Client Side

-- NUI Callbacks
RegisterNUICallback('submitCreation', function(data, cb)
    TriggerServerEvent('role_assignment:saveCharacter', data)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('submitSwitch', function(data, cb)
    TriggerServerEvent('role_assignment:performSwitch', data)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('closeNUI', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Event: Open NUI
RegisterNetEvent('role_assignment:openNUI')
AddEventHandler('role_assignment:openNUI', function(isCreation)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', mode = isCreation and 'creation' or 'switch' })
end)

-- Event: Spawn Player with Agency Assets
RegisterNetEvent('role_assignment:spawnPlayer')
AddEventHandler('role_assignment:spawnPlayer', function(role, agency, spawn)
    local playerPed = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(500)
    
    -- Set spawn location
    SetEntityCoords(playerPed, spawn.x, spawn.y, spawn.z)
    SetEntityHeading(playerPed, spawn.w)
    
    -- Load agency assets (placeholders - integrate EUP/inventory)
    if role == 'Police' then
        -- Example: Set uniform
        SetPedComponentVariation(playerPed, 3, 0, 0, 0)  -- Customize
        GiveWeaponToPed(playerPed, GetHashKey('WEAPON_PISTOL'), 200, false, true)
    elseif role == 'EMS' then
        -- EMS gear
    elseif role == 'Fire' then
        -- Fire gear
    end
    
    -- Audio cue
    PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
    
    DoScreenFadeIn(500)
    
    -- Notification
    TriggerEvent('role_assignment:showMessage', "Assigned to " .. agency .. " as " .. role .. ". Radio check-in complete.")
end)

-- Event: Show Message (Use your notification system)
RegisterNetEvent('role_assignment:showMessage')
AddEventHandler('role_assignment:showMessage', function(msg)
    -- Example: Basic chat message; replace with esx_notify or similar
    AddTextEntry('notification', msg)
    DisplayHelpTextThisFrame('notification', false)
end)

-- Event: Apply Debuff
RegisterNetEvent('role_assignment:applyDebuff')
AddEventHandler('role_assignment:applyDebuff', function(type)
    if type == 'fatigue' then
        -- Example: Reduce stamina
        SetPlayerStamina(PlayerId(), 50.0)  -- Half stamina for 5 mins
        Citizen.Wait(300000)
        ResetPlayerStamina(PlayerId())
    end
end)

-- Duty Menu Access (Example: Key press at HQ - Expand with markers/zones)
Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 38) then  -- E key
            -- Check if near HQ (placeholder coords; use ox_lib zones for production)
            local playerCoords = GetEntityCoords(PlayerPedId())
            if #(playerCoords - vector3(425.0, -981.0, 30.7)) < 5.0 then  -- LSPD example
                TriggerServerEvent('role_assignment:requestSwitch')
            end
        end
    end
end)