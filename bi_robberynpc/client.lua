local pedTargets = {}

local Config = Config or {}

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local radius = 50.0
        local peds = GetGamePool('CPed')

        for _, ped in pairs(peds) do
            if DoesEntityExist(ped) and not IsPedAPlayer(ped) and not IsPedDeadOrDying(ped) and #(playerCoords - GetEntityCoords(ped)) < radius then
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

    if #(playerCoords - pedCoords) < 2.0 then
        TaskTurnPedToFaceEntity(ped, playerPed, 1000)
        TaskPlayAnim(playerPed, 'mp_common', 'givetake1_a', 8.0, -8.0, -1, 49, 0, false, false, false)
        TaskHandsUp(ped, 2000, playerPed, -1, true)

        local zoneName = GetLabelText(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z))
        local moneyStolen = CalculateStolenAmount(zoneName)

        local success = math.random(1, 100)

        if success <= Config.ChanceToReceiveItem then
            ClearPedTasksImmediately(playerPed) 
            local randomItem = Config.RobberyItems[math.random(1, #Config.RobberyItems)]
            TriggerServerEvent('bibiModz:giveItem', randomItem)
            ShowNotification("Objet reçu", "Vous avez reçu " .. randomItem.quantity .. "x " .. randomItem.name, "success")
            TaskReactAndFleePed(ped, playerPed)

        elseif success <= Config.ChanceToStealMoney + Config.ChanceToReceiveItem then
            ClearPedTasksImmediately(playerPed) 
            TriggerServerEvent('bibiModz:robSuccess', moneyStolen, zoneName, true)
            ShowNotification("Vol", "Vous avez volé $" .. moneyStolen .. " dans la zone : " .. zoneName, "success")
            TaskReactAndFleePed(ped, playerPed)

        else
            ClearPedTasksImmediately(playerPed) 
            TriggerServerEvent('bibiModz:robSuccess', 0, zoneName, false)
            ShowNotification("Échec", "Le vol a échoué, le citoyen s'échappe!", "error")
            TaskReactAndFleePed(ped, playerPed)
        end

        exports.ox_target:removeLocalEntity(ped)
    else
        ShowNotification("Échec", "Vous êtes trop loin du citoyen!", "error")
    end
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

RegisterNetEvent('bibiModz:notifyReputation')
AddEventHandler('bibiModz:notifyReputation', function(reputation)
    if reputation >= Config.GoodReputationThreshold then
        ShowNotification("Réputation", "Vous avez une bonne réputation.", "success")
    elseif reputation <= Config.BadReputationThreshold then
        ShowNotification("Réputation", "Vous avez une mauvaise réputation.", "error")
    end
end)
