function EMSFirstAidTree(ped, loc)
    Citizen.CreateThread(function()
        Citizen.Wait(10000)
        TaskLeaveVehicle(ped, GetVehiclePedIsIn(ped), 0)
        TaskGoToCoordAnyMeans(ped, loc.x, loc.y, loc.z, 2.0, 0, 0, 786603, 0xbf800000)
        Citizen.Wait(5000)
        local injured = GetClosestInjured(loc)
        if injured then
            TaskPlayAnim(ped, 'missheistdockssetup1ig_12@base', 'heal', 8.0, -8.0, -1, 1, 0, false, false, false)
            Citizen.Wait(10000)
            RevivePed(injured, true, true)
        end
    end)
end