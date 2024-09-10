local webhook = ""
local VORPcore = exports.vorp_core:GetCore()

if Config.Debug then
    RegisterCommand("scombat", function(source, args)
        local id = tonumber(args[1])
        print(id)
        writelog(id, "Combat Test")
    end, false) 

    RegisterCommand("testlog", function(source)
        writelog(source, "Test") 
    end, false)

end


function writelog(source, reason)
    local user = VORPcore.getUser(source) 
    if not user then 
        return 
    end
    
    local character = user.getUsedCharacter
    local coords = GetEntityCoords(GetPlayerPed(source))
   

    local identifier = Config.UseSteam and GetPlayerIdentifier(source, 0) or GetPlayerIdentifier(source, 1)
    
    TriggerClientEvent("redux_combatlog:client:ToggleCombat", -1, source, coords, identifier, character.charIdentifier, reason)

    

    if Config.LogSystem then
        SendLog(source, coords, identifier, reason)
    end
end


AddEventHandler("playerDropped", function(reason)
    local src = source
    writelog(src, reason)
    exports.redux_logs:AddLog("LEAVE", self.hexid, "Player joined the server", nil)
end)


function SendLog(id, coords, identifier, reason)
    local playerName = GetPlayerName(id)
    local date = os.date('*t')
    
  
    local user = VORPcore.getUser(id) 
    if not user then 
        return 
    end
    
    local character = user.getUsedCharacter

    

  
    local formattedDate = string.format("%02d.%02d.%d - %02d:%02d:%02d", 
                                        date.day, date.month, date.year, 
                                        date.hour, date.min, date.sec)

   
    local embeds = {
        {
            ["title"] = "Player Disconnected",
            ["type"] = "rich",
            ["color"] = 4777493,
            ["fields"] = {
                {["name"] = "Identifier", ["value"] = identifier, ["inline"] = true},
                {["name"] = "Nickname", ["value"] = playerName, ["inline"] = true},
                {["name"] = "Player's ID", ["value"] = tostring(id), ["inline"] = true},
                {["name"] = "Coordinates", ["value"] = string.format("X: %.2f, Y: %.2f, Z: %.2f", coords.x, coords.y, coords.z), ["inline"] = true},
                {["name"] = "Reason", ["value"] = reason, ["inline"] = true},
            },
            ["footer"] = {
                ["icon_url"] = "https://forum.fivem.net/uploads/default/original/4X/7/5/e/75ef9fcabc1abea8fce0ebd0236a4132710fcb2e.png",
                ["text"] = "Sent: " .. formattedDate,
            },
        }
    }

   
    PerformHttpRequest(webhook, function(err, text, headers) end, 
                       'POST', json.encode({username = Config.LogBotName, embeds = embeds}), 
                       { ['Content-Type'] = 'application/json' })
end
