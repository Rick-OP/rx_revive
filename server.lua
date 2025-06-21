local allowReviveCommand = true -- Set to false to disable the command

--Usage: /reviveplayer [playerId] or /reviveplayer without arguments to revive yourself (admin only)
if allowReviveCommand then
    RegisterCommand("reviveplayer", function(source, args, rawCommand)
        local targetId = tonumber(args[1]) or source
        local targetPlayer = GetPlayerPed(targetId)
        if not targetPlayer then
            TriggerClientEvent("chat:addMessage", source, { args = { "^1No player found with that ID." } })
        else
            TriggerClientEvent("rxrevive:revivePlayerClient", targetId)
        end
    end, true)
end

-- Usage: /respawn [playerId] this will respawn the player at a specific Co-ordinate

RegisterCommand("respawn", function(source, args)
    if args[1] then
        local targetId = tonumber(args[1])
        local coords =  { x = 226.0371, y = -854.9874, z = 29.9661, heading = 344.3221 } -- Example coordinates, change as needed
        if targetId then
            local targetPed = GetPlayerPed(targetId)
            TriggerClientEvent("rxrevive:respawn", targetId, targetPed, coords)
        else
            TriggerClientEvent("chat:addMessage", source, { args = { "^1Invalid target ID." } })
        end
    else
        TriggerClientEvent("chat:addMessage", source, { args = { "^1Usage: /respawn [playerId]" } })
    end
end, true)
