if not lib.checkDependency('ND_Core', '2.0.0') then return end

local NDCore = exports["ND_Core"]

RegisterNetEvent('ND:characterLoaded', function(character)
    LocalPlayer.state.isLoggedIn = true
    createStartPoint()
end)

RegisterNetEvent('ND:characterUnloaded', function()
    LocalPlayer.state.isLoggedIn = false
    OnPlayerLogout()
end)

function handleVehicleKeys(veh)
    SetTimeout(1000, function()
        SetVehicleDoorsLocked(veh, 0)
    end)
end

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, nType)
    NDCore:notify({ title = "Notification", description = text, type = nType, })
end
