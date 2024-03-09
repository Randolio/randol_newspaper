local Config = lib.require('shared')
local startPed, pedInteract
local delay, clockedIn = false
local myData = {}
local workZones = {}
local blipStore = {}

if Config.EnableBlip then
    local NEWS_BLIP = AddBlipForCoord(Config.PedCoords.xyz)
    SetBlipSprite(NEWS_BLIP, 590)
    SetBlipDisplay(NEWS_BLIP, 4)
    SetBlipScale(NEWS_BLIP, 0.80)
    SetBlipAsShortRange(NEWS_BLIP, true)
    SetBlipColour(NEWS_BLIP, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName('Newspaper Delivery')
    EndTextCommandSetBlipName(NEWS_BLIP)
end

local function resetJob()
    clockedIn = false
    if next(workZones) then
        for i = 1, #workZones do
            if workZones[i] then
                workZones[i]:remove()
            end
        end
    end
    if next(blipStore) then
        for k, _ in pairs(blipStore) do
            if DoesBlipExist(blipStore[k]) then
                RemoveBlip(blipStore[k])
                blipStore[k] = nil
            end
        end
    end
    table.wipe(workZones)
    table.wipe(myData)
end

local function validateDrop(point)
    local success, num = lib.callback.await('randol_paperboy:server:validateDrop', 1500, point.coords)
    if success then
        point:remove()
        if next(blipStore) then
            if DoesBlipExist(blipStore[point.blip]) then
                RemoveBlip(blipStore[point.blip])
                blipStore[point.blip] = nil
            end
        end
        if num > 0 then
            DoNotification(('Newspaper delivered. %s remaining'):format(num))
        end
    end
    Wait(1000) 
    delay = false
end

local function createPaperRoute(netid)
    if clockedIn then return end

    local vehicle = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(netid) then
            return NetToVeh(netid)
        end
    end, 'Could not load entity in time.', 5000)

    handleVehicleKeys(vehicle)
    
    for k,v in pairs(myData.locations) do
        local zone = lib.points.new({ 
            coords = vec3(v.x, v.y, v.z), 
            distance = 30,
            blip = k, 
            nearby = function(point)
                DrawMarker(1, point.coords.x, point.coords.y, point.coords.z - 1.5, 0, 0, 0, 0, 0, 0, 4.0, 4.0, 2.0, 227, 14, 88, 165, 0, 0, 0,0)
                
                if point.isClosest and IsProjectileTypeWithinDistance(point.coords.x, point.coords.y, point.coords.z, `WEAPON_ACIDPACKAGE`, 3.0, true) and not delay then
                    delay = true
                    validateDrop(point)
                end
            end,
        })
        workZones[#workZones+1] = zone
        
        blipStore[k] = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blipStore[k], 40)
        SetBlipDisplay(blipStore[k], 4)
        SetBlipScale(blipStore[k], 0.65)
        SetBlipAsShortRange(blipStore[k], true)
        SetBlipColour(blipStore[k], 61)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName('Delivery')
        EndTextCommandSetBlipName(blipStore[k])
    end
    clockedIn = true
    DoNotification('Your delivery locations have been assigned.', 'success')
end

local function spawnPed()
    if DoesEntityExist(startPed) then return end

    local model = joaat(Config.Ped)
    lib.requestModel(model, 5000)
    startPed = CreatePed(0, model, Config.PedCoords, false, false)

    SetEntityAsMissionEntity(startPed, true, true)
    SetPedFleeAttributes(startPed, 0, 0)
    SetBlockingOfNonTemporaryEvents(startPed, true)
    SetEntityInvincible(startPed, true)
    FreezeEntityPosition(startPed, true)
    SetPedDefaultComponentVariation(startPed)
    SetModelAsNoLongerNeeded(model)

    lib.requestAnimDict('timetable@ron@ig_3_couch')
    TaskPlayAnim(startPed, 'timetable@ron@ig_3_couch', 'base', 3.0, 3.0, -1, 01, 0, false, false, false)

    exports['qb-target']:AddTargetEntity(startPed, { 
        options = {
            { 
                icon = 'fa-solid fa-newspaper',
                label = 'Start Work',
                canInteract = function() 
                    return not clockedIn 
                end,
                action = function()
                    if IsAnyVehicleNearPoint(Config.BikeSpawn.x, Config.BikeSpawn.y, Config.BikeSpawn.z, 5.0) then 
                        DoNotification('A bike is blocking the spawn.', 'error') 
                        return 
                    end
                    myData, netid = lib.callback.await('randol_paperboy:server:beginWork', false)
                    if myData and netid then
                        createPaperRoute(netid)
                    end
                end,
            },
            { 
                icon = 'fa-solid fa-clipboard-check',
                label = 'Finish Delivery',
                action = function()
                    local success = lib.callback.await('randol_paperboy:server:clockOut', false)
                    if not success then return end
                    resetJob()
                end,
            },
        }, 
        distance = 1.5, 
    })
end

local function yeetPed()
    if DoesEntityExist(startPed) then
        exports['qb-target']:RemoveTargetEntity(startPed, {'Start Work', 'Finish Delivery'})
        DeleteEntity(startPed)
        startPed = nil
    end
end

function createStartPoint()
    pedInteract = lib.points.new({
        coords = Config.PedCoords.xyz,
        distance = 30,
        onEnter = spawnPed,
        onExit = yeetPed,
    })
end

function OnPlayerLogout()
    resetJob() yeetPed()
    if pedInteract then pedInteract:remove() end
end

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() ~= resource or not hasPlyLoaded() then return end
    createStartPoint()
end)

AddEventHandler('onResourceStop', function(resourceName) 
    if GetCurrentResourceName() == resourceName then
        OnPlayerLogout()
    end 
end)

-- https://overextended.dev/ox_inventory/Events/Client#ox_inventoryitemcount
-- Docs state it doesn't work for ESX but I tried it and it does? Will avoid for ESX until I have confirmation.
if GetResourceState('es_extended') == 'started' then
    RegisterNetEvent('esx:removeInventoryItem', function(item, count)
        if item == 'WEAPON_ACIDPACKAGE' and clockedIn and count == 0 then
            DoNotification('You are all out of newspapers.')
            resetJob()
        end
    end)
else
    AddEventHandler('ox_inventory:itemCount', function(item, count)
        if item == 'WEAPON_ACIDPACKAGE' and clockedIn and count == 0 then
            DoNotification('You are all out of newspapers.')
            resetJob()
        end
    end)
end
