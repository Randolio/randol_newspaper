if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    ESX.PlayerLoaded = true
    createStartPoint()
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    ESX.PlayerLoaded = false
    OnPlayerLogout()
end)

function handleVehicleKeys(veh)
    --??
end

function hasPlyLoaded()
    return ESX.PlayerLoaded
end

function DoNotification(text, nType)
    ESX.ShowNotification(text, nType)
end