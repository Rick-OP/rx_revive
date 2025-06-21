local reviveWait = 5 -- Change this to set the wait time for revive in seconds
local timer = reviveWait
local isPlayerDead = false
local notificationShown = false
local reviveKeyAllowed = true -- Default value, false to disable revive keybind but keep other functions

function NotifyPlayer(title, message, messageType, position, duration)
    TriggerEvent('ox_lib:notify', {
        title = title,
        type = messageType,
        description = message,
        position = position,
        duration = duration,
    })   -- Needs Dependancy ox_lib. or you can add your own notification system
end

function ShowNotify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(true, true)
end

function respawnPed(ped, coords)
    local ped = PlayerPedId()
    local playerId = GetPlayerServerId(PlayerId())
    if IsEntityDead(ped) then
        TriggerServerEvent('rxrevive:setRoutingBucket', playerId, 0)
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
        SetPlayerInvincible(ped, false)
        TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
        TriggerEvent('esx:onPlayerSpawn')
        ClearPedBloodDamage(ped)
    end
end

RegisterNetEvent('rxrevive:respawn')
AddEventHandler('rxrevive:respawn', function(ped, coords)
    respawnPed(ped, coords)
end)

RegisterNetEvent("rxrevive:revivePlayerClient")
AddEventHandler("rxrevive:revivePlayerClient", function()
    local playerId = PlayerPedId()
    local ped = playerId
    revivePed(ped)
    notificationShown = false
end)

function revivePed(ped)
    TriggerEvent('esx:onPlayerSpawn')

    local playerPos = GetEntityCoords(ped, true)
    isPlayerDead = false
    timer = reviveWait
    SetPlayerInvincible(ped, false)
    NetworkResurrectLocalPlayer(playerPos.x, playerPos.y, playerPos.z, false, true, false)
    ClearPedBloodDamage(ped)
    TriggerEvent('esx:onPlayerSpawn')
end

RegisterCommand('selfRevive', function()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        if reviveKeyAllowed then
            if timer <= 0 then
                revivePed()
            else
                NotifyPlayer('Cooldown', 'Wait ' .. timer .. ' seconds before Revive', 'error', 'bottom-right', '1000')
            end
        end
    end
end, false)

RegisterKeyMapping('selfRevive', 'Revive Key', 'keyboard', 'E')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
            isPlayerDead = true
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
            if not notificationShown then
                if reviveKeyAllowed then
                    ShowNotify("Use ~y~E ~w~or ~y~Revive Keybind ~w~to Revive")
                    NotifyPlayer('You are Dead', 'Wait 5 seconds. Press Revive Key', 'error', 'bottom-right', '5000')
                    notificationShown = true
                else
                    notificationShown = true
                end
            end
        else
            isPlayerDead = false
            notificationShown = false
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isPlayerDead then
            timer = timer - 1
        end
        Citizen.Wait(1000)
    end
end)
