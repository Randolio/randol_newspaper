if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    createStartPoint()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    OnPlayerLogout()
end)

function handleVehicleKeys(veh)
    local plate = GetVehicleNumberPlateText(veh)
    TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
end

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, nType)
    QBCore.Functions.Notify(text, nType)
end