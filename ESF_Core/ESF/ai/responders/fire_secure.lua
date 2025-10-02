function FireSecureTree(ped, loc)
    Citizen.CreateThread(function()
        Citizen.Wait(10000)
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped), 0)
        TaskGoToCoordAnyMeans(ped, loc.x, loc.y, loc.z, 2.0, 0, 0, 786603, 0xbf800000)
        Citizen.Wait(5000)
        TriggerServerEvent('esf:fire:extinguish', loc)
    end)
end