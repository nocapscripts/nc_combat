local show3DText = false


RegisterNetEvent("redux_combatlog:client:ToggleShow")
AddEventHandler("redux_combatlog:client:ToggleShow", function()
    show3DText = not show3DText

    if show3DText and Config.AutoDisableDrawing then
        local waitTime = tonumber(Config.AutoDisableDrawingTime) or 15000
        Citizen.Wait(waitTime)
        show3DText = false
    end
end)


RegisterNetEvent("redux_combatlog:client:ToggleCombat")
AddEventHandler("redux_combatlog:client:ToggleCombat", function(id, coords, identifier, rid, reason)
    if id and coords and identifier and reason then
        if not show3DText then
            TriggerEvent('redux_combatlog:client:ToggleShow')
        end
        DisplayCombatLog(id, coords, identifier, rid, reason)
    else
        print("Error: Missing parameters for ToggleCombat event.")
    end
end)


function DisplayCombatLog(id, coords, identifier, rid, reason)
    local isDisplaying = true


    Citizen.CreateThread(function()
        Citizen.Wait(Config.DrawingTime or 5000) 
        isDisplaying = false
    end)

  
    Citizen.CreateThread(function()
        while isDisplaying do
            Citizen.Wait(0) 

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(coords - playerCoords)

            if show3DText and distance < 15.0 then
          
                drawText3d(coords.x, coords.y, coords.z + 0.15, "Player Left Game", Config.AlertTextColor or {r = 255, g = 0, b = 0})
                drawText3d(coords.x, coords.y, coords.z, "ID: " .. id .. " (" .. identifier .. ")\nUID: " .. rid .. "\nReason: " .. reason, Config.TextColor or {r = 255, g = 255, b = 255})
            else
                Citizen.Wait(1000) 
            end
        end
    end)
end


function drawText3d(x, y, z, text, color)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(x, y, z)
    if onScreen then
     
        SetTextScale(0.35, 0.35)
        SetTextFontForCurrentCommand(1)
        SetTextColor(color.r, color.g, color.b, 255)
        SetTextCentre(1)
      
        DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)
    end
end


if Config.Debug then
    RegisterCommand("combat", function(source, args)
        local playerCoords = GetEntityCoords(PlayerPedId())
        local id = tonumber(args[1]) or -1 
        TriggerEvent("redux_combatlog:client:ToggleCombat", id, playerCoords, "test_identifier", id, "test_reason")
    end, false)
end
