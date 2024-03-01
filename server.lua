--- Version 1.0.4 ---

--- Code ---

RegisterServerEvent("RPRevive:CheckPermission")
AddEventHandler("RPRevive:CheckPermission", function()
    local src = source
    TriggerClientEvent("RPRevive:CheckPermission:Return", src, true) -- Always return true for permission (bypassing Discord role check)
end)
