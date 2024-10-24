local Config = Config or {}
local playerReputation = {}

function GetPlayerReputation(playerId)
    if not playerReputation[playerId] then
        playerReputation[playerId] = Config.InitialReputation
    end
    return playerReputation[playerId]
end

function AdjustPlayerReputation(playerId, change)
    local reputation = GetPlayerReputation(playerId)
    playerReputation[playerId] = reputation + change
    return playerReputation[playerId]
end

RegisterNetEvent('bibiModz:robSuccess')
AddEventHandler('bibiModz:robSuccess', function(moneyStolen, zone, success)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerId = source
        local playerName = xPlayer.getName()
        local reputationChange = 0

        if success then
            xPlayer.addMoney(moneyStolen)
            reputationChange = 1
            SendDiscordLog(playerName, moneyStolen, zone, "Réussi", GetPlayerReputation(playerId))
        else
            reputationChange = -1
            SendDiscordLog(playerName, 0, zone, "Échoué", GetPlayerReputation(playerId))
        end

        local newReputation = AdjustPlayerReputation(playerId, reputationChange)
        TriggerClientEvent('bibiModz:notifyReputation', playerId, newReputation)

        if newReputation <= Config.BadReputationThreshold then
            TriggerClientEvent('bibiModz:warnBadReputation', playerId)
        elseif newReputation >= Config.GoodReputationThreshold then
            TriggerClientEvent('bibiModz:rewardGoodReputation', playerId)
        end
    end
end)

RegisterNetEvent('bibiModz:giveItem')
AddEventHandler('bibiModz:giveItem', function(item)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        xPlayer.addInventoryItem(item.name, item.quantity)
        TriggerClientEvent('ox_lib:notify', source, {
            title = "Objet reçu",
            description = "Vous avez reçu " .. item.quantity .. "x " .. item.name,
            type = "success",
            duration = 5000
        })
    end
end)

function SendDiscordLog(playerName, amount, zone, status, reputation)
    local message = {
        {
            ["color"] = status == "Réussi" and 3066993 or 15158332,
            ["title"] = "Vol à l'arraché",
            ["description"] = "**Joueur**: " .. playerName .. "\n**Montant volé**: $" .. amount .. "\n**Zone**: " .. zone .. "\n**Statut**: " .. status .. "\n**Réputation**: " .. reputation,
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S"),
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Logs Vol à l'arraché", embeds = message}), { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent('bibiModz:alertPolice')
AddEventHandler('bibiModz:alertPolice', function(coords, policeJob)
    local xPlayers = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(xPlayers) do
        if xPlayer.job.name == policeJob then
            TriggerClientEvent('esx:showNotification', xPlayer.source, "Un vol a été signalé. Allez à la position indiquée.")
            TriggerClientEvent('esx_addons_gcphone:sendMessage', xPlayer.source, "police", "Un vol a été signalé à ces coordonnées : " .. coords.x .. ", " .. coords.y)
        end
    end
end)
