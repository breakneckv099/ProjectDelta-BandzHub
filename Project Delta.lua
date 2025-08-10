-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
   Name = "Project Delta Script - breakneckv09",
   Icon = 0,
   LoadingTitle = "Project Delta Script...",
   LoadingSubtitle = "by - breakneckv09",
   ShowText = "Toggle Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = true,
   DisableBuildWarnings = true,
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "Big Hub"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = true,
   KeySettings = {
      Title = "Project Delta Script - Key System",
      Subtitle = "by - breakneckv09",
      Note = "The Key Is In Our Discord .gg/faV3GCjebC",
      FileName = "ProjectDeltaKey",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"X7P3K9L2QM6ZBV4N1T8J", "R5Y8N3QWZT1VJ6KMB9PX", "F9L4ZRV6DM0CQW2YJTXN", "BK7HTJZXL5VMRQN9D2YC", "V2XKW9B7TF4PJHM1CLZA", "NZ8DPRMT5LVXQKFYJ0WG", "YCQZ2LJ9NXKB4VS1P7RD", "M6HTVF5YBJCNQWZ9L0RX", "XJ7SM0D6QZRLTCKHVNFY", "GWQVX8BM9CPLDRTZ5NYH"}
   }
})

local combatTab  = Window:CreateTab("Combat", 4483362458)
local visualsTab = Window:CreateTab("Visuals", 4483362458)
local miscTab    = Window:CreateTab("Misc", 4483362458)
local itemTab     = Window:CreateTab("Inv Checker", 4483362458)
local riskyTab     = Window:CreateTab("Risky (Beta)", 4483362458)
local creditsTab = Window:CreateTab("Credits", 4483362458)

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playersFolder = ReplicatedStorage:WaitForChild("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Flags
local playerBoxEnabled, playerNameEnabled = false, false
local npcBoxEnabled = false
local containerBoxEnabled, containerTextEnabled = false, false
local droppedBoxEnabled, droppedTextEnabled = false, false
local exitEspEnabled = false
local selectedFOV = 120
local fullbrightEnabled = false
local autoPickupEnabled = false
local autoPickupSpeed = 1
local aimlockEnabled = false
local fovEnabled = false
local targetNpcsToo = false
local useVisibilityCheck = false
local fovSize = 100
local smoothness = 0.1
local holdingRightClick = false
local lockedTarget = nil

-- Max Range Settings
local playerESPRange = 500
local npcESPRange = 500
local containerESPRange = 500
local droppedESPRange = 500
local exitESPRange = 500
local aimlockMaxRange = 300

-- Lighting Backup
local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
}

-- Colors
local Colors = {
    PlayerBox = Color3.fromRGB(255, 0, 0),
    PlayerText = Color3.fromRGB(255, 255, 255),
    NPCBox = Color3.fromRGB(255, 255, 0),
    NPCText = Color3.fromRGB(255, 255, 0),
    ContainerBox = Color3.fromRGB(255, 128, 0),
    ContainerText = Color3.fromRGB(255, 128, 0),
    DroppedBox = Color3.fromRGB(0, 255, 0),
    DroppedText = Color3.fromRGB(0, 255, 0),
    ExitText = Color3.fromRGB(0, 191, 255),
}

-- Drawing tables to hold ESP lines and text
local Drawings = {
    PlayerBoxLines = {},
    PlayerTexts = {},
    NPCBoxLines = {},
    NPCTexts = {},
    ContainerBoxLines = {},
    ContainerTexts = {},
    DroppedBoxLines = {},
    DroppedTexts = {},
    ExitTexts = {},
}

-- Utility functions --

local function clearBoxLines(tbl)
    for key, lines in pairs(tbl) do
        for _, line in ipairs(lines) do
            if line then line:Remove() end
        end
        tbl[key] = nil
    end
end

local function clearDrawings(tbl)
    for key, drawing in pairs(tbl) do
        if drawing then
            drawing:Remove()
        end
        tbl[key] = nil
    end
end

local function clearAdornments(type)
    if type == "PlayersBox" then
        clearBoxLines(Drawings.PlayerBoxLines)
    elseif type == "PlayersName" then
        clearDrawings(Drawings.PlayerTexts)
    elseif type == "NPCsBox" then
        clearBoxLines(Drawings.NPCBoxLines)
    elseif type == "NPCsName" then
        clearDrawings(Drawings.NPCTexts)
    elseif type == "ContainersBox" then
        clearBoxLines(Drawings.ContainerBoxLines)
    elseif type == "ContainersName" then
        clearDrawings(Drawings.ContainerTexts)
    elseif type == "DroppedItemsBox" then
        clearBoxLines(Drawings.DroppedBoxLines)
    elseif type == "DroppedItemsName" then
        clearDrawings(Drawings.DroppedTexts)
    elseif type == "ExitsName" then
        clearDrawings(Drawings.ExitTexts)
    end
end

local function WorldToScreenPoint(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen and screenPos.Z > 0
end

local function getBoxLines(tbl, key)
    local lines = tbl[key]
    if not lines then
        lines = {}
        for i = 1, 12 do
            lines[i] = Drawing.new("Line")
            lines[i].Thickness = 1.5
            lines[i].Transparency = 1
        end
        tbl[key] = lines
    end
    return lines
end

local function getDrawing(tbl, key, type)
    local drawingObj = tbl[key]
    if not drawingObj then
        drawingObj = Drawing.new(type)
        tbl[key] = drawingObj
    end
    return drawingObj
end

local function isPlayerCharacter(model)
    if not model then return false end
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function getModelCorners(model, scaleMultiplier)
    if not model or not model.PrimaryPart then return nil end
    scaleMultiplier = scaleMultiplier or 1
    local cf = model.PrimaryPart.CFrame
    local size = model.PrimaryPart.Size * scaleMultiplier
    local halfSize = size / 2
    return {
        cf * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),
        cf * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
        cf * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
        cf * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
        cf * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
        cf * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
        cf * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
        cf * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
    }
end

local function draw3DBox(lines, corners3D, color)
    local corners2D = {}
    for i, corner in ipairs(corners3D) do
        local screenPos, onScreen = WorldToScreenPoint(corner)
        if not onScreen then
            for _, line in ipairs(lines) do
                line.Visible = false
            end
            return
        end
        corners2D[i] = screenPos
    end

    local edges = {
        {1,2},{2,4},{4,3},{3,1}, -- top
        {5,6},{6,8},{8,7},{7,5}, -- bottom
        {1,5},{2,6},{3,7},{4,8}  -- sides
    }

    for i, edge in ipairs(edges) do
        local line = lines[i]
        line.Visible = true
        line.From = corners2D[edge[1]]
        line.To = corners2D[edge[2]]
        line.Color = color
    end
end

local function drawNameText(drawTextObj, pos, name, dist, color)
    drawTextObj.Visible = true
    drawTextObj.Position = pos
    drawTextObj.Text = string.format("%s [%dm]", name, math.floor(dist))
    drawTextObj.Color = color
    drawTextObj.Size = 14 -- bigger font
    drawTextObj.Center = true
    drawTextObj.Outline = true
    drawTextObj.OutlineColor = Color3.new(0, 0, 0)
end

-- Main ESP Update loop
RunService.RenderStepped:Connect(function()
    local cameraPos = Camera.CFrame.Position

    -- Player Box ESP + Name ESP
    if playerBoxEnabled or playerNameEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            local char = plr.Character
            if char and char.PrimaryPart and plr ~= LocalPlayer then
                local dist = (char.PrimaryPart.Position - cameraPos).Magnitude
                if dist <= playerESPRange then
                    -- Box
                    if playerBoxEnabled then
                        local corners = getModelCorners(char, 1.8)
                        local lines = getBoxLines(Drawings.PlayerBoxLines, char)
                        draw3DBox(lines, corners, Colors.PlayerBox)
                    elseif Drawings.PlayerBoxLines[char] then
                        clearBoxLines({[char] = Drawings.PlayerBoxLines[char]})
                        Drawings.PlayerBoxLines[char] = nil
                    end

                    -- Name
                    if playerNameEnabled then
                        local text = getDrawing(Drawings.PlayerTexts, char, "Text")
                        local screenPos, onScreen = WorldToScreenPoint(char.PrimaryPart.Position + Vector3.new(0, 3, 0))
                        if onScreen then
                            drawNameText(text, screenPos, plr.Name, dist, Colors.PlayerText)
                        else
                            text.Visible = false
                        end
                    elseif Drawings.PlayerTexts[char] then
                        Drawings.PlayerTexts[char]:Remove()
                        Drawings.PlayerTexts[char] = nil
                    end
                else
                    if Drawings.PlayerBoxLines[char] then
                        clearBoxLines({[char] = Drawings.PlayerBoxLines[char]})
                        Drawings.PlayerBoxLines[char] = nil
                    end
                    if Drawings.PlayerTexts[char] then
                        Drawings.PlayerTexts[char]:Remove()
                        Drawings.PlayerTexts[char] = nil
                    end
                end
            end
        end
    else
        clearBoxLines(Drawings.PlayerBoxLines)
        clearDrawings(Drawings.PlayerTexts)
    end

   -- NPC Box + Name ESP
if npcBoxEnabled then
    local validNpcs = {}

    if Workspace:FindFirstChild("AiZones") then
        for _, npc in pairs(Workspace.AiZones:GetDescendants()) do
            if npc:IsA("Model") and npc.PrimaryPart and npc:FindFirstChildOfClass("Humanoid") and not isPlayerCharacter(npc) then
                local humanoid = npc:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.Health > 0 and npc:IsDescendantOf(Workspace) then
                    validNpcs[npc] = true

                    local dist = (npc.PrimaryPart.Position - cameraPos).Magnitude
                    if dist <= npcESPRange then
                        local corners = getModelCorners(npc, 1.8)
                        local lines = getBoxLines(Drawings.NPCBoxLines, npc)
                        draw3DBox(lines, corners, Colors.NPCBox)

                        local text = getDrawing(Drawings.NPCTexts, npc, "Text")
                        local screenPos, onScreen = WorldToScreenPoint(npc.PrimaryPart.Position + Vector3.new(0, 3, 0))
                        if onScreen then
                            drawNameText(text, screenPos, npc.Name, dist, Colors.NPCText)
                        else
                            text.Visible = false
                        end
                    else
                        -- Out of range
                        if Drawings.NPCBoxLines[npc] then
                            clearBoxLines({[npc] = Drawings.NPCBoxLines[npc]})
                            Drawings.NPCBoxLines[npc] = nil
                        end
                        if Drawings.NPCTexts[npc] then
                            Drawings.NPCTexts[npc]:Remove()
                            Drawings.NPCTexts[npc] = nil
                        end
                    end
                end
            end
        end
    end

    -- Cleanup: remove ESPs for NPCs that no longer exist or died
    for npc in pairs(Drawings.NPCBoxLines) do
        if not validNpcs[npc] then
            clearBoxLines({[npc] = Drawings.NPCBoxLines[npc]})
            Drawings.NPCBoxLines[npc] = nil
        end
    end
    for npc in pairs(Drawings.NPCTexts) do
        if not validNpcs[npc] then
            Drawings.NPCTexts[npc]:Remove()
            Drawings.NPCTexts[npc] = nil
        end
    end
else
    clearBoxLines(Drawings.NPCBoxLines)
    clearDrawings(Drawings.NPCTexts)
end


    -- Container Box ESP
    if containerBoxEnabled then
        if Workspace:FindFirstChild("Containers") then
            for _, container in pairs(Workspace.Containers:GetChildren()) do
                if container:IsA("Model") and container.PrimaryPart then
                    local dist = (container.PrimaryPart.Position - cameraPos).Magnitude
                    if dist <= containerESPRange then
                        local corners = getModelCorners(container, 1)
                        local lines = getBoxLines(Drawings.ContainerBoxLines, container)
                        draw3DBox(lines, corners, Colors.ContainerBox)
                    else
                        if Drawings.ContainerBoxLines[container] then
                            clearBoxLines({[container] = Drawings.ContainerBoxLines[container]})
                            Drawings.ContainerBoxLines[container] = nil
                        end
                    end
                end
            end
        end
    else
        clearBoxLines(Drawings.ContainerBoxLines)
    end

    -- Container Name ESP
    if containerTextEnabled then
        if Workspace:FindFirstChild("Containers") then
            for _, container in pairs(Workspace.Containers:GetChildren()) do
                if container:IsA("Model") and container.PrimaryPart then
                    local dist = (container.PrimaryPart.Position - cameraPos).Magnitude
                    if dist <= containerESPRange then
                        local text = getDrawing(Drawings.ContainerTexts, container, "Text")
                        local screenPos, onScreen = WorldToScreenPoint(container.PrimaryPart.Position + Vector3.new(0, 3, 0))
                        if onScreen then
                            drawNameText(text, screenPos, container.Name, dist, Colors.ContainerText)
                        else
                            text.Visible = false
                        end
                    else
                        if Drawings.ContainerTexts[container] then
                            Drawings.ContainerTexts[container]:Remove()
                            Drawings.ContainerTexts[container] = nil
                        end
                    end
                end
            end
        end
    else
        clearDrawings(Drawings.ContainerTexts)
    end

    -- Dropped Item Box ESP
    if droppedBoxEnabled then
        if Workspace:FindFirstChild("DroppedItems") then
            for _, item in pairs(Workspace.DroppedItems:GetChildren()) do
                if item:IsA("Model") and item.PrimaryPart then
                    local dist = (item.PrimaryPart.Position - cameraPos).Magnitude
                    if dist <= droppedESPRange then
                        local corners = getModelCorners(item, 1)
                        local lines = getBoxLines(Drawings.DroppedBoxLines, item)
                        draw3DBox(lines, corners, Colors.DroppedBox)
                    else
                        if Drawings.DroppedBoxLines[item] then
                            clearBoxLines({[item] = Drawings.DroppedBoxLines[item]})
                            Drawings.DroppedBoxLines[item] = nil
                        end
                    end
                end
            end
        end
    else
        clearBoxLines(Drawings.DroppedBoxLines)
    end

    -- Dropped Item Name ESP
    if droppedTextEnabled then
        if Workspace:FindFirstChild("DroppedItems") then
            for _, item in pairs(Workspace.DroppedItems:GetChildren()) do
                if item:IsA("Model") and item.PrimaryPart then
                    local dist = (item.PrimaryPart.Position - cameraPos).Magnitude
                    if dist <= droppedESPRange then
                        local text = getDrawing(Drawings.DroppedTexts, item, "Text")
                        local screenPos, onScreen = WorldToScreenPoint(item.PrimaryPart.Position + Vector3.new(0, 3, 0))
                        if onScreen then
                            drawNameText(text, screenPos, item.Name, dist, Colors.DroppedText)
                        else
                            text.Visible = false
                        end
                    else
                        if Drawings.DroppedTexts[item] then
                            Drawings.DroppedTexts[item]:Remove()
                            Drawings.DroppedTexts[item] = nil
                        end
                    end
                end
            end
        end
    else
        clearDrawings(Drawings.DroppedTexts)
    end

    -- Exit Name ESP (text only)
    if exitTextEnabled then
        if Workspace:FindFirstChild("NoCollision") and Workspace.NoCollision:FindFirstChild("ExitLocations") then
            for _, exitPart in pairs(Workspace.NoCollision.ExitLocations:GetChildren()) do
                if exitPart:IsA("BasePart") then
                    local dist = (exitPart.Position - cameraPos).Magnitude
                    if dist <= exitESPRange then
                        local text = getDrawing(Drawings.ExitTexts, exitPart, "Text")
                        local screenPos, onScreen = WorldToScreenPoint(exitPart.Position + Vector3.new(0, 3, 0))
                        if onScreen then
                            drawNameText(text, screenPos, exitPart.Name, dist, Colors.ExitText)
                        else
                            text.Visible = false
                        end
                    else
                        if Drawings.ExitTexts[exitPart] then
                            Drawings.ExitTexts[exitPart]:Remove()
                            Drawings.ExitTexts[exitPart] = nil
                        end
                    end
                end
            end
        end
    else
        clearDrawings(Drawings.ExitTexts)
    end

    -- Cleanup drawings for deleted/destroyed instances
    for _, tbl in pairs(Drawings) do
        for key, drawingObj in pairs(tbl) do
            if typeof(key) == "Instance" and (not key.Parent or not drawingObj) then
                if drawingObj then
                    if type(drawingObj) == "table" then
                        for _, line in ipairs(drawingObj) do
                            if line then line:Remove() end
                        end
                    else
                        drawingObj:Remove()
                    end
                end
                tbl[key] = nil
            end
        end
    end
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1, 0, 0)
fovCircle.Thickness = 1
fovCircle.Transparency = 1
fovCircle.NumSides = 100
fovCircle.Filled = false

-- Update FOV circle on RenderStepped
RunService.RenderStepped:Connect(function()
    fovCircle.Visible = fovEnabled
    if fovEnabled then
        local center = Camera.ViewportSize / 2
        fovCircle.Position = Vector2.new(center.X, center.Y)
        fovCircle.Radius = fovSize
    end
end)

-- Cache ignore list for local player once
local cachedIgnoreList = {}
local function updateIgnoreList(targetChar)
    cachedIgnoreList = {}
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(cachedIgnoreList, part)
            end
        end
    end
    if targetChar then
        for _, part in ipairs(targetChar:GetDescendants()) do
            if part:IsA("BasePart") then
                table.insert(cachedIgnoreList, part)
            end
        end
    end
end

-- Check visibility once per target, cache result for short period
local visibilityCache = {}
local VISIBILITY_CACHE_TIME = 0.15

local function isVisible(targetChar)
    local now = tick()
    if visibilityCache[targetChar] and now - visibilityCache[targetChar].time < VISIBILITY_CACHE_TIME then
        return visibilityCache[targetChar].visible
    end

    local head = targetChar:FindFirstChild("Head")
    if not head then return false end

    updateIgnoreList(targetChar)
    local parts = Camera:GetPartsObscuringTarget({head.Position}, cachedIgnoreList)
    local visible = #parts == 0

    visibilityCache[targetChar] = { visible = visible, time = now }
    return visible
end

-- Get distance from screen center for FOV check
local function getScreenDist(pos2D)
    local center = Camera.ViewportSize / 2
    return (pos2D - center).Magnitude
end

-- Cached target list to avoid repeated table creation
local function getTargets()
    local targets = {}

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            table.insert(targets, plr.Character)
        end
    end

    if targetNpcsToo and Workspace:FindFirstChild("AiZones") then
        for _, npc in ipairs(Workspace.AiZones:GetDescendants()) do
            if npc:IsA("Model") and npc:FindFirstChild("Head") and not Players:GetPlayerFromCharacter(npc) then
                table.insert(targets, npc)
            end
        end
    end

    return targets
end

-- Find closest target within FOV and visibility
local function getClosestTarget()
    local bestTarget = nil
    local minDist = fovSize

    local targets = getTargets()
    for _, char in ipairs(targets) do
        local head = char:FindFirstChild("Head")
        if head then
            local distFromCam = (Camera.CFrame.Position - head.Position).Magnitude
            if distFromCam <= aimlockMaxRange then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = getScreenDist(Vector2.new(screenPos.X, screenPos.Y))
                    if dist <= fovSize then
                        if not useVisibilityCheck or isVisible(char) then
                            if dist < minDist then
                                minDist = dist
                                bestTarget = head
                            end
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

-- Use a timer to limit how often we search targets (reduce lag)
local targetUpdateInterval = 0.1
local lastTargetUpdate = 0

RunService.RenderStepped:Connect(function(dt)
    if aimlockEnabled and holdingRightClick then
        local now = tick()
        if not lockedTarget or (now - lastTargetUpdate) > targetUpdateInterval then
            lockedTarget = getClosestTarget()
            lastTargetUpdate = now
        end

        if lockedTarget then
            local screenPos, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
            if not onScreen or (useVisibilityCheck and not isVisible(lockedTarget.Parent)) then
                lockedTarget = nil
                return
            end

            -- Smoothly rotate camera toward target
            local origin = Camera.CFrame.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(origin, lockedTarget.Position), smoothness)
        end
    else
        lockedTarget = nil
    end
end)

-- Input handlers for right mouse button
UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessed then
        holdingRightClick = true
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        holdingRightClick = false
        lockedTarget = nil
    end
end)

-- Fullbright
local function setFullbright(state)
    if state then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 10
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        Lighting.ClockTime = 12
    else
        for k, v in pairs(originalLighting) do Lighting[k] = v end
    end
end

-- Build list of player folder names for the dropdown
local playerNames = {}
for _, folder in ipairs(playersFolder:GetChildren()) do
    if folder:IsA("Folder") then
        table.insert(playerNames, folder.Name)
    end
end

-- Create the Player selection dropdown
itemTab:CreateParagraph({ Title = "The Callback Errors Are Normal", Content = "Thanks to @TheMentol for the idea" })

local playerDropdown = itemTab:CreateDropdown({
    Name = "Select Player",
    Options = playerNames,
    CurrentOption = {playerNames[1] or "No Players"},
    MultipleOptions = false,
    Flag = "SelectedPlayer"
})

-- Initialize inventory category dropdowns with default "No Items Found"
local gunsDropdown = itemTab:CreateDropdown({
    Name = "Guns",
    Options = {"No Items Found"},
    CurrentOption = {"No Items Found"},
    MultipleOptions = false
})
local equipmentDropdown = itemTab:CreateDropdown({
    Name = "Equipment",
    Options = {"No Items Found"},
    CurrentOption = {"No Items Found"},
    MultipleOptions = false
})
local clothingDropdown = itemTab:CreateDropdown({
    Name = "Clothing",
    Options = {"No Items Found"},
    CurrentOption = {"No Items Found"},
    MultipleOptions = false
})
local clothingInventoryDropdown = itemTab:CreateDropdown({
    Name = "Inventory",
    Options = {"No Items Found"},
    CurrentOption = {"No Items Found"},
    MultipleOptions = false
})

-- Helper function to collect string values from a given folder
local function collectStrings(folder)
    local items = {}
    if folder then
        for _, val in ipairs(folder:GetChildren()) do
            if val:IsA("StringValue") then
                table.insert(items, val.Name)
            end
        end
    end
    if #items == 0 then
        items = {"No Items Found"}
    end
    return items
end

-- Create the "Get Inv" button
itemTab:CreateButton({
    Name = "Get Players Inventory",
    Callback = function()
        -- Get selected player name
        local selectedPlayer = playerDropdown.CurrentOption[1]
        if not selectedPlayer or selectedPlayer == "" then
            Rayfield:Notify({Title = "Error", Content = "No player selected", Duration = 3})
            return
        end

        -- Find the player folder in ReplicatedStorage
        local playerFolder = playersFolder:FindFirstChild(selectedPlayer)
        if not playerFolder then
            Rayfield:Notify({Title = "Error", Content = "Player data not found", Duration = 3})
            return
        end

        -- Collect items from each category
        local gunsList = collectStrings(playerFolder:FindFirstChild("Inventory"))
        local equipmentList = collectStrings(playerFolder:FindFirstChild("Equipment"))

        local clothingList = {}
        local clothingInvList = {}
        local clothingFolder = playerFolder:FindFirstChild("Clothing")
        if clothingFolder then
            for _, cloth in ipairs(clothingFolder:GetChildren()) do
                if cloth:IsA("StringValue") then
                    table.insert(clothingList, cloth.Name)
                    -- Check for nested Inventory folder under this clothing item
                    local invFolder = cloth:FindFirstChild("Inventory")
                    if invFolder then
                        for _, innerVal in ipairs(invFolder:GetChildren()) do
                            if innerVal:IsA("StringValue") then
                                table.insert(clothingInvList, innerVal.Name)
                            end
                        end
                    end
                end
            end
        end
        if #clothingList == 0 then
            clothingList = {"No Items Found"}
        end
        if #clothingInvList == 0 then
            clothingInvList = {"No Items Found"}
        end

        -- Update the dropdowns with the new lists
        gunsDropdown:Refresh(gunsList)
        gunsDropdown:Set({gunsList[1]})

        equipmentDropdown:Refresh(equipmentList)
        equipmentDropdown:Set({equipmentList[1]})

        clothingDropdown:Refresh(clothingList)
        clothingDropdown:Set({clothingList[1]})

        clothingInventoryDropdown:Refresh(clothingInvList)
        clothingInventoryDropdown:Set({clothingInvList[1]})
    end
})

-- // Auto Pickup Loop
task.spawn(function()
    while task.wait(0.1) do
        if autoPickupEnabled then
            local closestItem
            local closestDist = math.huge
            local root = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if root then
                for _, item in ipairs(workspace:WaitForChild("DroppedItems"):GetChildren()) do
                    if item:IsA("Model") and item.PrimaryPart then
                        local dist = (item.PrimaryPart.Position - root.Position).Magnitude
                        if dist <= 14.5 and dist < closestDist then
                            closestItem = item
                            closestDist = dist
                        end
                    end
                end

                if closestItem then
                    local args = {
                        closestItem,
                        Vector3.new(closestItem.PrimaryPart.Position.X, closestItem.PrimaryPart.Position.Y, closestItem.PrimaryPart.Position.Z)
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Take"):FireServer(unpack(args))
                end
            end

            task.wait(autoPickupSpeed)
        end
    end
end)

-- UI Toggles
combatTab:CreateToggle({Name = "Enable Aimlock", CurrentValue = false, Callback = function(v) aimlockEnabled = v fovEnabled = v end})
combatTab:CreateToggle({Name = "Target NPCs Too", CurrentValue = false, Callback = function(v) targetNpcsToo = v end})
combatTab:CreateToggle({Name = "Visibility Check (Buggy With Some Guns/Scopes)", CurrentValue = false, Callback = function(v) useVisibilityCheck = v end})
combatTab:CreateSlider({Name = "FOV Size", Range = {30, 500}, Increment = 1, CurrentValue = 100, Suffix = "px", Callback = function(v) fovSize = v end})
combatTab:CreateSlider({Name = "Strength", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.1, Callback = function(v) smoothness = v end})
combatTab:CreateSlider({Name = "Aimlock Max Range", Range = {50, 8000}, Increment = 50, CurrentValue = aimlockMaxRange, Callback = function(v) aimlockMaxRange = v end})

visualsTab:CreateToggle({Name = "Player Box ESP", CurrentValue = false, Callback = function(v) playerBoxEnabled = v if not v then clearAdornments("PlayersBox") end end})
visualsTab:CreateToggle({Name = "Player Name ESP", CurrentValue = false, Callback = function(v) playerNameEnabled = v if not v then clearAdornments("PlayersName") end end})
visualsTab:CreateToggle({Name = "NPC ESP", CurrentValue = false, Callback = function(v) npcBoxEnabled = v if not v then clearAdornments("NPCsBox") clearAdornments("NPCsName") end end})
visualsTab:CreateToggle({Name = "Container Box ESP", CurrentValue = false, Callback = function(v) containerBoxEnabled = v if not v then clearAdornments("ContainersBox") end end})
visualsTab:CreateToggle({Name = "Container Name ESP", CurrentValue = false, Callback = function(v) containerTextEnabled = v if not v then clearAdornments("ContainersName") end end})
visualsTab:CreateToggle({Name = "Dropped Item Box ESP", CurrentValue = false, Callback = function(v) droppedBoxEnabled = v if not v then clearAdornments("DroppedItemsBox") end end})
visualsTab:CreateToggle({Name = "Dropped Item Name ESP", CurrentValue = false, Callback = function(v) droppedTextEnabled = v if not v then clearAdornments("DroppedItemsName") end end})
visualsTab:CreateToggle({Name = "Exit Name ESP", CurrentValue = false, Callback = function(v) exitTextEnabled = v if not v then clearAdornments("ExitsName") end end})
local espDistanceSection = visualsTab:CreateSection("ESP Distance Sliders")
visualsTab:CreateSlider({
    Name = "Player ESP Range",
    Range = {50, 8000},
    Increment = 50,
    CurrentValue = playerESPRange,
    Suffix = " studs",
    Callback = function(value)
        playerESPRange = value
    end
})

visualsTab:CreateSlider({
    Name = "NPC ESP Range",
    Range = {50, 8000},
    Increment = 50,
    CurrentValue = npcESPRange,
    Suffix = " studs",
    Callback = function(value)
        npcESPRange = value
    end
})

visualsTab:CreateSlider({
    Name = "Container Max Range",
    Range = {50, 8000},
    Increment = 50,
    CurrentValue = containerESPRange,
    Suffix = " studs",
    Callback = function(value)
        containerESPRange = value
    end
})

visualsTab:CreateSlider({
    Name = "Dropped Item Max Range",
    Range = {50, 8000},
    Increment = 50,
    CurrentValue = droppedESPRange,
    Suffix = " studs",
    Callback = function(value)
        droppedESPRange = value
    end
})

visualsTab:CreateSlider({
    Name = "Exit Max Range",
    Range = {50, 8000},
    Increment = 50,
    CurrentValue = exitESPRange,
    Suffix = " studs",
    Callback = function(value)
        exitESPRange = value
    end
})

miscTab:CreateSlider({
	Name = "FOV Value",
	Range = {70, 120},
	Increment = 1,
	Suffix = "°",
	CurrentValue = selectedFOV,
	Callback = function(value)
		selectedFOV = value
	end
})

miscTab:CreateButton({
	Name = "Apply FOV (Takes A Few Seconds)",
	Callback = function()
		local args = {
			{
				GameplaySettings = {
					DefaultFOV = selectedFOV
				}
			}
		}
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("UpdateSettings"):FireServer(unpack(args))
	end
})

miscTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) fullbrightEnabled = v setFullbright(v) end})

miscTab:CreateButton({
    Name = "No Fog",
    Callback = function()
        Lighting.FogEnd = 1e10
        Lighting.FogStart = 0
        Lighting.FogColor = Color3.new(1, 1, 1)
    end
})

miscTab:CreateButton({
    Name = "Remove Trees/Plants (May Rubberband If You Walk Through Where A Tree Was)",
    Callback = function()
        local player = game:GetService("Players").LocalPlayer
        local workspace = game:GetService("Workspace")

        -- Remove from SpawnerZones.Foliage
        local spawnerFoliage = workspace:FindFirstChild("SpawnerZones")
        if spawnerFoliage and spawnerFoliage:FindFirstChild("Foliage") then
            for _, folder in ipairs(spawnerFoliage.Foliage:GetChildren()) do
                if folder:IsA("Folder") then
                    folder:Destroy()
                end
            end
        end

        -- Remove parts from NoCollision.FoliageZones
        local noCollisionFoliage = workspace:FindFirstChild("NoCollision")
        if noCollisionFoliage and noCollisionFoliage:FindFirstChild("FoliageZones") then
            for _, obj in ipairs(noCollisionFoliage.FoliageZones:GetChildren()) do
                if obj:IsA("BasePart") then
                    obj:Destroy()
                end
            end
        end
    end
})

riskyTab:CreateToggle({
    Name = "Auto Pickup Items",
    CurrentValue = false,
    Flag = "AutoPickup",
    Callback = function(Value)
        autoPickupEnabled = Value
    end
})

riskyTab:CreateSlider({
    Name = "Pickup Speed (Seconds)",
    Range = {0.1, 3.5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = autoPickupSpeed,
    Flag = "PickupSpeed",
    Callback = function(Value)
        autoPickupSpeed = Value
    end
})


creditsTab:CreateParagraph({ Title = "Scripted by breakneckv09", Content = "Thanks for using my script!" })
creditsTab:CreateButton({ Name = "Official Server Invite", Callback = function() setclipboard("discord.gg/faV3GCjebC") Rayfield:Notify({Title = "Copied Link!", Content = "Discord invite copied to clipboard.", Duration = 4}) end })