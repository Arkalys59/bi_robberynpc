local pedTargets = {}

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local radius = 50.0
        local peds = GetGamePool('CPed')

        for _, ped in pairs(peds) do
            local pedModel = GetEntityModel(ped)

            if not isBlacklisted(pedModel) and DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) and #(playerCoords - GetEntityCoords(ped)) < radius then
                if not pedTargets[ped] then
                    exports.ox_target:addLocalEntity(ped, {
                        {
                            name = 'rob_ped',
                            icon = 'fa-solid fa-hand-holding',
                            label = 'Voler à l\'arraché',
                            onSelect = function(data)
                                TryRobPed(ped)
                            end
                        }
                    })
                    pedTargets[ped] = true
                end
            end
        end

        Wait(1000)
    end
end)

function TryRobPed(ped)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local pedCoords = GetEntityCoords(ped)

    if #(playerCoords - pedCoords) < 5.0 then
        FreezeEntityPosition(ped, true)
        TaskHandsUp(ped, 5000, playerPed, -1, true)
        TaskTurnPedToFaceEntity(playerPed, ped, -1)

        local moveToNPC = true
        local moveSpeed = 1.5
        local stopDistance = 1.5 -- Distance d'arrêt ajustée pour éviter les collisions

        while moveToNPC do
            playerCoords = GetEntityCoords(playerPed)
            local distanceToPed = #(playerCoords - pedCoords)
            if distanceToPed > stopDistance then
                local offsetX = pedCoords.x + math.cos(math.rad(GetEntityHeading(ped))) * 0.5
                local offsetY = pedCoords.y + math.sin(math.rad(GetEntityHeading(ped))) * 0.5
                TaskGoStraightToCoord(playerPed, offsetX, offsetY, pedCoords.z, moveSpeed, 500, GetEntityHeading(ped), 0.1)
                Wait(100)
            else
                moveToNPC = false
            end
        end

        loadAnimDict('mp_common')

        TaskTurnPedToFaceEntity(ped, playerPed, 1000)
        TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 49, 0, false, false, false)

        Wait(3000)

        local zoneName = GetLabelText(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z))
        local moneyStolen = CalculateStolenAmount(zoneName)

        local success = math.random(1, 100)

        if success <= Config.ChanceToReceiveItem then
            ClearPedTasksImmediately(playerPed)
            local randomItem = Config.RobberyItems[math.random(1, #Config.RobberyItems)]
            TriggerServerEvent('bibiModz:giveItem', randomItem)
            ShowNotification("Objet reçu", "Vous avez reçu " .. randomItem.quantity .. "x " .. randomItem.name, "success")

        elseif success <= Config.ChanceToStealMoney + Config.ChanceToReceiveItem then
            ClearPedTasksImmediately(playerPed)
            TriggerServerEvent('bibiModz:robSuccess', moneyStolen, zoneName, true)
            ShowNotification("Succès", "Vous avez volé $" .. moneyStolen .. " dans la zone : " .. zoneName, "success")

        else
            ClearPedTasksImmediately(playerPed)
            TriggerServerEvent('bibiModz:robSuccess', 0, zoneName, false)
            ShowNotification("Échec", "Le vol a échoué, le NPC s'échappe!", "error")
        end

        FreezeEntityPosition(ped, false)
        TaskReactAndFleePed(ped, playerPed)

        local alertPolice = math.random(1, 100) <= Config.PoliceAlertChance
        if alertPolice then
            AlertPolice(playerCoords)
        end

        exports.ox_target:removeLocalEntity(ped)
    else
        ShowNotification("Erreur", "Vous êtes trop loin du NPC!", "error")
    end
end

function AlertPolice(coords)
    TriggerServerEvent('bibiModz:alertPolice', coords, Config.PoliceJobName)
    ShowNotification("Alerte", "La police a été alertée!", "error")
end

function isBlacklisted(pedModel)
    for _, model in ipairs(Config.BlacklistedModels) do
        if GetHashKey(model) == pedModel then
            return true
        end
    end
    return false
end

function CalculateStolenAmount(zone)
    if contains(Config.RichZones, zone) then
        return math.random(Config.RichZoneMoney.min, Config.RichZoneMoney.max)
    elseif contains(Config.PoorZones, zone) then
        return math.random(Config.PoorZoneMoney.min, Config.PoorZoneMoney.max)
    else
        return math.random(Config.MiddleClassZoneMoney.min, Config.MiddleClassZoneMoney.max)
    end
end

function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

function ShowNotification(title, description, type)
    lib.notify({
        title = title,
        description = description,
        type = type,
        duration = 5000
    })
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
end

CreateThread(function()
    loadAnimDict('mp_common')
end)

RegisterNetEvent('bibiModz:createBlipForPolice')
AddEventHandler('bibiModz:createBlipForPolice', function(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipScale(blip, 1.2)
    SetBlipColour(blip, 1)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Lieu du vol")
    EndTextCommandSetBlipName(blip)

    Wait(120000)
    RemoveBlip(blip)
end)

RegisterNetEvent('bibiModz:notifyReputation')
AddEventHandler('bibiModz:notifyReputation', function(reputation)
    if reputation >= Config.GoodReputationThreshold then
        ShowNotification("Réputation", "Vous avez une bonne réputation.", "success")
    elseif reputation <= Config.BadReputationThreshold then
        ShowNotification("Réputation", "Vous avez une mauvaise réputation.", "error")
    end
end)
