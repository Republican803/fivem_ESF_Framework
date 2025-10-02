local isMDTOpen = false
local isDriving = false
local isParked = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 57) then  -- F10
            ToggleMDT()
        end
    end
end)

function ToggleMDT()
    if not isMDTOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({action = 'openMDT', agency = GetPlayerAgency()})
        PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
        isMDTOpen = true
    else
        SetNuiFocus(false, false)
        SendNUIMessage({action = 'closeMDT'})
        isMDTOpen = false
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        isDriving = veh ~= 0 and GetPedInVehicleSeat(veh, -1) == PlayerPedId()
        isParked = IsVehicleStopped(veh)
        if isMDTOpen and isDriving and not isParked then
            SendNUIMessage({action = 'limitAccess'})
        elseif isMDTOpen and (not isDriving or isParked) then
            SendNUIMessage({action = 'fullAccess'})
        end
    end
end)

RegisterNetEvent('esf:mdt:updateCalls')
AddEventHandler('esf:mdt:updateCalls', function(calls)
    SendNUIMessage({action = 'updateActiveCalls', data = calls})
end)

RegisterNetEvent('esf:mdt:updateUnits')
AddEventHandler('esf:mdt:updateUnits', function(unitData)
    SendNUIMessage({action = 'updateUnitStatus', data = unitData})
end)

RegisterNetEvent('esf:mdt:newAlert')
AddEventHandler('esf:mdt:newAlert', function(alert)
    SendNUIMessage({action = 'showAlert', data = alert})
    PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end)

RegisterNUICallback('updateStatus', function(data, cb)
    TriggerServerEvent('esf:mdt:updateStatus', data.status)
    cb('ok')
end)

RegisterNUICallback('runQuery', function(data, cb)
    TriggerServerEvent('esf:mdt:runQuery', data.type, data.input)
    cb('ok')
end)

RegisterNUICallback('requestResource', function(data, cb)
    TriggerServerEvent('esf:mdt:requestResource', data.type)
    cb('ok')
end)

RegisterNUICallback('sendRadio', function(data, cb)
    TriggerServerEvent('esf:radio:send', data.message)
    cb('ok')
end)

RegisterNetEvent('esf:mdt:queryResult')
AddEventHandler('esf:mdt:queryResult', function(result)
    SendNUIMessage({action = 'showQueryResult', data = result})
end)

RegisterNetEvent('esf:radio:receive')
AddEventHandler('esf:radio:receive', function(message)
    SendNUIMessage({action = 'updateRadioLog', data = message})
end)

function GetPlayerAgency()
    return 'police'  -- From metadata
end