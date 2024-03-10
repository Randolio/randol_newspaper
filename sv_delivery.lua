local Config = lib.require('shared')
local Server = lib.require('sv_config')
local workers = {}
local ox_inventory = exports.ox_inventory

local function createBicycle(source)
    -- If you change the Config.BikeModel to something that isn't a bike, be sure to change the 'type' in the native below to match.
    -- https://docs.fivem.net/natives/?_0x6AE51D4B
    local veh = CreateVehicleServerSetter(joaat(Config.BikeModel), 'bike', Config.BikeSpawn.x, Config.BikeSpawn.y, Config.BikeSpawn.z, Config.BikeSpawn.w)
    local ped = GetPlayerPed(source)

    while not DoesEntityExist(veh) do Wait(0) end 

    while GetVehiclePedIsIn(ped, false) ~= veh do TaskWarpPedIntoVehicle(ped, veh, -1) Wait(0) end

    return NetworkGetNetworkIdFromEntity(veh)
end

lib.callback.register('randol_paperboy:server:beginWork', function(source)
    if workers[source] then return false end

    local src = source
    local player = GetPlayer(src)

    TriggerClientEvent('ox_inventory:disarm', src, true)

    local count = ox_inventory:GetItemCount(src, 'WEAPON_ACIDPACKAGE') -- Incase they disconnected and still have some. I wanna reset.
    if count > 0 then
        ox_inventory:RemoveItem(src, 'WEAPON_ACIDPACKAGE', count)
    end
    
    local index = math.random(#Server.Areas)
    local generatedLocs = {}

    for i = 1, #Server.Areas[index].Locations do
        generatedLocs[#generatedLocs+1] = Server.Areas[index].Locations[i]
    end

    workers[src] = {
        locations = generatedLocs,
        payout = Server.Areas[index].Payout,
        bonusPay = Server.Areas[index].bonusPay or 0,
        totalPay = 0,
        entity = 0,
    }

    local amount = #workers[src].locations
    local netid = createBicycle(src)
    workers[src].entity = NetworkGetEntityFromNetworkId(netid)
    ox_inventory:AddItem(src, 'WEAPON_ACIDPACKAGE', amount)

    return workers[src], netid
end)

lib.callback.register('randol_paperboy:server:validateDrop', function(source, location, netid)
    if not workers[source] then return false end

    local src = source
    local pos = GetEntityCoords(GetPlayerPed(src))
    local isValid = false

    if #(pos - location.xyz) > 35.0 then return false end

    for i = 1, #workers[src].locations do
        if workers[src].locations[i] == location then
            table.remove(workers[src].locations, i)
            isValid = true
            break
        end
    end

    if not isValid then return false end
    local skillLevel = exports.OT_skills:getSkill(source, 'newspaper')
    local bonusPay = (workers[src].bonusPay * skillLevel.level) or 0
    local payout = math.random(workers[src].payout.min, workers[src].payout.max) + bonusPay

    if NetworkGetNetworkIdFromEntity(GetVehiclePedIsIn(GetPlayerPed(source))) ~= netid then
        payout = 1
        DoNotification(src, ('This is the wrong vehicle. Pay reduced'), 'error')
    end

    workers[src].totalPay += payout

    DoNotification(src, ('$%s was added on to your total pay. New Total: $%s'):format(payout, workers[src].totalPay), 'success')

    return true, #workers[src].locations
end)

lib.callback.register('randol_paperboy:server:clockOut', function(source)
    if not workers[source] then
        DoNotification(source, 'You do not have any active deliveries.', 'error')
        return false 
    end

    local src = source
    local player = GetPlayer(src)
    local pos = GetEntityCoords(GetPlayerPed(src))

    if workers[src].totalPay > 0 then
        AddMoney(player, 'cash', workers[src].totalPay)
        DoNotification(src, ('You received $%s for completing your deliveries.'):format(workers[src].totalPay), 'success')
        exports.OT_skills:addXP(src, 'newspaper', math.random(10))
    end

    if DoesEntityExist(workers[src].entity) then DeleteEntity(workers[src].entity) end

    TriggerClientEvent('ox_inventory:disarm', src, true)

    local count = ox_inventory:GetItemCount(src, 'WEAPON_ACIDPACKAGE')
    
    if count > 0 then
        ox_inventory:RemoveItem(src, 'WEAPON_ACIDPACKAGE', count)
    end

    workers[src] = nil
    return true
end)

function OnServerPlayerUnload(src)
    if workers[src] then
        if DoesEntityExist(workers[src].entity) then DeleteEntity(workers[src].entity) end
        workers[src] = nil
    end
end

local hookId = ox_inventory:registerHook('swapItems', function(payload)
    return false
end, {
    print = false,
    itemFilter = {
        WEAPON_ACIDPACKAGE = true,
    },
    inventoryFilter = {
        '^glove[%w]+',
        '^trunk[%w]+',
        '^drop-[%w]+',
        '^newdrop$'
    }
})

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
		exports.ox_inventory:removeHooks(hookId)
    end
end)

local data = {
    name = 'newspaper',
    label = 'Newspaper',
    description = 'Showcase your newspaper throwing skills',
    multiplier = 1.2,
    maxlevel = 10,
    maxReward = 50,
    maxDeduction = 50,
    icon = 'newspaper',
    iconColor = '#29c785'
}
exports.OT_skills:registerSkill(data)