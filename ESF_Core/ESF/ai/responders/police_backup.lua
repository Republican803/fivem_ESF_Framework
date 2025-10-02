function PoliceBackupTree(ped, loc)
    Citizen.CreateThread(function()
        Citizen.Wait(10000)  -- ETA
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped), 0)
        TaskGoToCoordAnyMeans(ped, loc.x, loc.y, loc.z, 2.0, 0, 0, 786603, 0xbf800000)
        Citizen.Wait(5000)
        TaskGuardCurrentPosition(ped, 5.0, 5.0, true)
        local suspect = GetClosestSuspect(loc)  -- Custom func
        if suspect then
            TaskArrestPed(ped, suspect)
        end
    end)
end