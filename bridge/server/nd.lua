if not lib.checkDependency('ND_Core', '2.0.0') then return end

local NDCore = exports["ND_Core"]

function GetPlayer(id)
    return NDCore:getPlayer(id)
end

function DoNotification(src, text, nType)
    local player = NDCore:getPlayer(src)
    return player and player.notify({ type = nType, description = text })
end

function GetPlyIdentifier(player)
    return player?.id
end

function GetSourceFromIdentifier(cid)
    local players = NDCore:getPlayers()
    for _, info in pairs(players) do
        if info.id == cid then
            return info.source
        end
    end
    return false
end

function GetCharacterName(player)
    return player?.fullname
end

function AddMoney(player, moneyType, amount)
    player.addMoney(moneyType, amount)
end

AddEventHandler('ND:characterUnloaded', function(src, character)
    OnServerPlayerUnload(src)
end)
