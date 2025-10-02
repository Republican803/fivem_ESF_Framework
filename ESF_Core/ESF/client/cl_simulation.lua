-- Weather/Time Effects Client
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local rain = GetRainLevel()
        if rain > 0.5 then
            -- Visual slip (e.g., reduced traction via SetVehicleReduceGrip)
            local veh = GetVehiclePedIsIn(PlayerPedId())
            if veh then SetVehicleReduceGrip(veh, true) end
        end
    end
end)

-- Dash Cam Mode
RegisterCommand('dashcam', function()
    -- First-person view with overlay (RenderScriptCams)
    local cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    AttachCamToVehicleBone(cam, GetVehiclePedIsIn(PlayerPedId()), GetEntityBoneIndexByName(veh, 'windscreen'), true, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
end, false)

-- Audio Immersion
RegisterNetEvent('esf:sim:playRadioChatter')
AddEventHandler('esf:sim:playRadioChatter', function(sound)
    PlaySoundFrontend(-1, sound, "POLICE_SCANNER_SOUNDS", true)
end)