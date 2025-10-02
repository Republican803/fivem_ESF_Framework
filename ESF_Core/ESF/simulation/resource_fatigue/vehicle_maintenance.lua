Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10000)  -- 10s tick
        for _, unit in pairs(units) do
            if unit.veh then
                local fuel = GetVehicleFuelLevel(unit.veh) - 0.1  -- Deplete
                SetVehicleFuelLevel(unit.veh, fuel)
                if fuel <= 0 then
                    SetVehicleEngineOn(unit.veh, false, false, true)
                    TriggerClientEvent('esf:mdt:newAlert', unit.playerId, 'Vehicle out of fuel - Return to station')
                end
                -- Damage check
                if GetVehicleBodyHealth(unit.veh) < 500 then
                    TriggerEvent('esf:sim:repairNeeded', unit.veh)
                end
            end
        end
    end
end)

RegisterServerEvent('esf:sim:refuel')
AddEventHandler('esf:sim:refuel', function(vehNetId)
    local veh = NetworkGetEntityFromNetworkId(vehNetId)
    if IsAtStation(GetEntityCoords(veh)) then
        SetVehicleFuelLevel(veh, 100.0)
    end
end)