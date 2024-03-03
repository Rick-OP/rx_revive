--- Config ---

local reviveWait = 5 -- Change the amount of time to wait before allowing revive (in seconds).
local featureColor = "~y~" -- Game color used as the button key colors.

--- Code ---
local timerCount = reviveWait
local isDead = false
cHavePerms = true -- Set to true we're bypassing Permission check

AddEventHandler('playerSpawned', function()
    local src = source
    TriggerServerEvent("RPRevive:CheckPermission", src)
end)

RegisterNetEvent("RPRevive:CheckPermission:Return")
AddEventHandler("RPRevive:CheckPermission:Return", function(havePerms)
    cHavePerms = havePerms
end)

-- Turn off automatic respawn here instead of updating FiveM file.
AddEventHandler('onClientMapStart', function()
    Citizen.Trace("RPRevive: Disabling the autospawn.")
    exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
    Citizen.Wait(2500)
    exports.spawnmanager:setAutoSpawn(false)
    Citizen.Trace("RPRevive: Autospawn is disabled.")
end)

function respawnPed(ped, coords)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false) 
    SetPlayerInvincible(ped, false) 
    TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
    TriggerEvent('esx:onPlayerSpawn')
    ClearPedBloodDamage(ped)

    -- Replenish food and water by 50%
    TriggerEvent('esx_status:remove', 'hunger', 100)
    TriggerEvent('esx_status:remove', 'thirst', 100)
end

function revivePed(ped)
    TriggerEvent('esx:onPlayerSpawn')
    local playerPos = GetEntityCoords(ped, true)
    isDead = false
    timerCount = reviveWait
    NetworkResurrectLocalPlayer(playerPos.x, playerPos.y, playerPos.z, true, true, false)
    SetPlayerInvincible(ped, false)
    ClearPedBloodDamage(ped)
    TriggerEvent('esx:onPlayerSpawn')

    -- Replenish food and water by 50%
    TriggerEvent('esx_status:remove', 'hunger', 100)
    TriggerEvent('esx_status:remove', 'thirst', 100)
end

function ShowInfoRevive(text1, text2)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text1)
    DrawNotification(true, true)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text2)
    DrawNotification(true, true)
end


Citizen.CreateThread(function()
    local respawnCount = 0
    local spawnPoints = {}
    local playerIndex = NetworkGetPlayerIndex(-1) or 0
    math.randomseed(playerIndex)

    function createSpawnPoint(x, y, z, heading)
        local newObject = {
            x = x + 0.0001,
            y = y + 0.0001,
            z = z + 0.0001,
            heading = heading + 0.0001
        }
        table.insert(spawnPoints, newObject)
    end

    createSpawnPoint(-276, -894.06, 31.08, 344.68) -- Example spawn point

    while true do
        Citizen.Wait(0)
        ped = GetPlayerPed(-1)
        if IsEntityDead(ped) then
            isDead = true
            SetPlayerInvincible(ped, true)
            SetEntityHealth(ped, 1)
            ShowInfoRevive('You are Dead. Use ~y~E ~w~to revive here', 'Use ~y~R ~w~to spawn in main Garage')
            if IsControlJustReleased(0, 38) and GetLastInputMethod(0) then
                if timerCount <= 0 or cHavePerms then
                    revivePed(ped)
                else
                    TriggerEvent('chat:addMessage', {args = {'^*Wait ' .. timerCount .. ' more seconds before reviving.'}})
                end 
            elseif IsControlJustReleased(0, 45) and GetLastInputMethod( 0 ) then
                local coords = spawnPoints[math.random(1, #spawnPoints)]
                respawnPed(ped, coords)
                isDead = false
                timerCount = reviveWait
                respawnCount = respawnCount + 1
                math.randomseed(playerIndex * respawnCount)
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isDead then
            timerCount = timerCount - 1
        end
        Citizen.Wait(1000)          
    end
end)
