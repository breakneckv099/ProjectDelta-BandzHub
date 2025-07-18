-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

-- Create Window & Tabs
local Window = Rayfield:CreateWindow({
    Name = "Project Delta Script - breakneckv09",
    LoadingTitle = "Loading Project Delta Script...",
    LoadingSubtitle = "by - breakneckv09",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "BHRevampConfigs", -- folder name
        FileName = "ProjectDelta" -- file name
    },
    KeySystem = true,
    KeySettings = {
        Title = "Project Delta Script - Key System",
        Subtitle = "by breakneckv09",
        Note = "The Key Is In Our Discord .gg/faV3GCjebC",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"R9W6TJ3VXZ7LQ1B8K2NM"} -- replace or add more keys as needed
    }
})

local combatTab  = Window:CreateTab("Combat", 4483362458)
local visualsTab = Window:CreateTab("Visuals", 4483362458)
local miscTab    = Window:CreateTab("Misc", 4483362458)
local creditsTab = Window:CreateTab("Credits", 4483362458)

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
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
local exitEspEnabled, fullbrightEnabled = false, false
local aimlockEnabled, fovEnabled = false, false
local targetNpcsToo, useVisibilityCheck = false, false
local fovSize, smoothness = 100, 0.1
local holdingRightClick, lockedTarget = false, nil

-- Lighting Backup
local originalLighting = {
    Ambient = Lighting.Ambient,
    Brightness = Lighting.Brightness,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    ClockTime = Lighting.ClockTime,
}

-- Drawing Cache
local boxCache, textCache = {}, {}
local function clearBoxes(key)
    if boxCache[key] then
        for _, box in ipairs(boxCache[key]) do if box and box.Parent then box:Destroy() end end
    end
    boxCache[key] = {}
end
local function clearTexts()
    for _, gui in ipairs(textCache) do if gui and gui.Parent then gui:Destroy() end end
    textCache = {}
end

-- ESP Helpers
local function createBoxEsp(model, color, key)
    if not model:IsA("Model") or not model.PrimaryPart then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = model.PrimaryPart
    box.Size = model:GetExtentsSize() * 0.95
    box.Color3 = color
    box.Transparency = 0.5
    box.AlwaysOnTop = true
    box.ZIndex = 0
    box.Parent = model.PrimaryPart
    box.Name = "BoxESP_" .. key
    boxCache[key] = boxCache[key] or {}
    table.insert(boxCache[key], box)
end

local function createBillboardText(part, text, color)
    if not part then return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP_Text"
    gui.Adornee = part
    gui.Size = UDim2.new(0, 100, 0, 20)
    gui.StudsOffset = Vector3.new(0, 2.5, 0)
    gui.AlwaysOnTop = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.SourceSansBold
    label.TextScaled = true
    label.Text = text
    label.Parent = gui

    gui.Parent = part
    table.insert(textCache, gui)
end

-- ESP Loop
task.spawn(function()
    while true do
        clearBoxes("Players")
        clearBoxes("NPCs")
        clearBoxes("Containers")
        clearBoxes("DroppedItems")
        clearTexts()

        -- Player ESP
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
                if playerBoxEnabled then
                    createBoxEsp(plr.Character, Color3.new(1, 0, 0), "Players")
                end
                if playerNameEnabled then
                    local dist = (Camera.CFrame.Position - plr.Character.Head.Position).Magnitude
                    createBillboardText(plr.Character.Head, plr.Name .. " [" .. math.floor(dist) .. "m]", Color3.new(1, 1, 1))
                end
            end
        end

        -- NPC ESP
        if npcBoxEnabled and Workspace:FindFirstChild("AiZones") then
            for _, mdl in ipairs(Workspace.AiZones:GetDescendants()) do
                if mdl:IsA("Model") and mdl:FindFirstChild("Head") then
                    createBoxEsp(mdl, Color3.new(1, 1, 0), "NPCs")
                    local dist = (Camera.CFrame.Position - mdl.Head.Position).Magnitude
                    createBillboardText(mdl.Head, mdl.Name .. " [" .. math.floor(dist) .. "m]", Color3.new(1, 1, 0))
                end
            end
        end

        -- Container ESP
        if Workspace:FindFirstChild("Containers") then
            for _, mdl in ipairs(Workspace.Containers:GetDescendants()) do
                if mdl:IsA("Model") and mdl.PrimaryPart then
                    if containerBoxEnabled then
                        createBoxEsp(mdl, Color3.new(1, 0.5, 0), "Containers")
                    end
                    if containerTextEnabled then
                        local dist = (Camera.CFrame.Position - mdl.PrimaryPart.Position).Magnitude
                        createBillboardText(mdl.PrimaryPart, mdl.Name .. " [" .. math.floor(dist) .. "m]", Color3.new(1, 1, 0))
                    end
                end
            end
        end

        -- Dropped Item ESP
        if Workspace:FindFirstChild("DroppedItems") then
            for _, mdl in ipairs(Workspace.DroppedItems:GetChildren()) do
                if mdl:IsA("Model") and mdl.PrimaryPart then
                    if droppedBoxEnabled then
                        createBoxEsp(mdl, Color3.new(0, 1, 0), "DroppedItems")
                    end
                    if droppedTextEnabled then
                        local dist = (Camera.CFrame.Position - mdl.PrimaryPart.Position).Magnitude
                        createBillboardText(mdl.PrimaryPart, mdl.Name .. " [" .. math.floor(dist) .. "m]", Color3.new(0, 1, 0))
                    end
                end
            end
        end

        -- Exit ESP
        if exitEspEnabled and Workspace:FindFirstChild("NoCollision") and Workspace.NoCollision:FindFirstChild("ExitLocations") then
            for _, part in ipairs(Workspace.NoCollision.ExitLocations:GetChildren()) do
                if part:IsA("BasePart") then
                    local dist = (Camera.CFrame.Position - part.Position).Magnitude
                    createBillboardText(part, part.Name .. " [" .. math.floor(dist) .. "m]", Color3.new(0, 0.8, 1))
                end
            end
        end

        task.wait(0.15)
    end
end)

-- FOV Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.new(1, 0, 0)
fovCircle.Thickness = 1
fovCircle.Transparency = 1
fovCircle.NumSides = 100
fovCircle.Filled = false

RunService.RenderStepped:Connect(function()
    fovCircle.Visible = fovEnabled
    if fovEnabled then
        local center = Camera.ViewportSize / 2
        fovCircle.Position = Vector2.new(center.X, center.Y)
        fovCircle.Radius = fovSize
    end
end)

-- Get Closest Target
local function getClosestTarget()
    local best, minDist = nil, fovSize
    local function check(char)
        if not char or not char:FindFirstChild("Head") then return end
        local head = char.Head
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then return end
        if useVisibilityCheck then
            local ignore = {LocalPlayer.Character, char}
            local parts = Camera:GetPartsObscuringTarget({head.Position}, ignore)
            if #parts > 0 then return end
        end
        local dist = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize / 2).Magnitude
        if dist < minDist then minDist = dist best = head end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then check(plr.Character) end
    end
    if targetNpcsToo and Workspace:FindFirstChild("AiZones") then
        for _, npc in ipairs(Workspace.AiZones:GetDescendants()) do
            if npc:IsA("Model") then check(npc) end
        end
    end
    return best
end

-- Aimlock Logic
RunService.RenderStepped:Connect(function()
    if aimlockEnabled and holdingRightClick then
        if not lockedTarget then lockedTarget = getClosestTarget() end
        if lockedTarget then
            local screenPos, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
            local visible = true
            if useVisibilityCheck then
                local parts = Camera:GetPartsObscuringTarget({lockedTarget.Position}, {LocalPlayer.Character, lockedTarget.Parent})
                visible = #parts == 0
            end
            if not onScreen or not visible then
                lockedTarget = nil
            else
                local origin = Camera.CFrame.Position
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(origin, lockedTarget.Position), smoothness)
            end
        end
    end
end)

UIS.InputBegan:Connect(function(i, gpe)
    if i.UserInputType == Enum.UserInputType.MouseButton2 and not gpe then holdingRightClick = true end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
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

-- UI Toggles
combatTab:CreateToggle({Name = "Enable Aimlock", CurrentValue = false, Callback = function(v) aimlockEnabled = v end})
combatTab:CreateToggle({Name = "Target NPCs Too", CurrentValue = false, Callback = function(v) targetNpcsToo = v end})
combatTab:CreateToggle({Name = "Visibility Check (Buggy Without The FOV Circle)", CurrentValue = false, Callback = function(v) useVisibilityCheck = v end})
combatTab:CreateToggle({Name = "FOV Circle", CurrentValue = false, Callback = function(v) fovEnabled = v end})
combatTab:CreateSlider({Name = "FOV Size", Range = {30, 500}, Increment = 1, CurrentValue = 100, Suffix = "px", Callback = function(v) fovSize = v end})
combatTab:CreateSlider({Name = "Strength", Range = {0.01, 1}, Increment = 0.01, CurrentValue = 0.1, Callback = function(v) smoothness = v end})

visualsTab:CreateToggle({Name = "Player Box ESP", CurrentValue = false, Callback = function(v) playerBoxEnabled = v if not v then clearBoxes("Players") end end})
visualsTab:CreateToggle({Name = "Player Name ESP", CurrentValue = false, Callback = function(v) playerNameEnabled = v if not v then clearTexts() end end})
visualsTab:CreateToggle({Name = "NPC ESP", CurrentValue = false, Callback = function(v) npcBoxEnabled = v if not v then clearBoxes("NPCs") end end})
visualsTab:CreateToggle({Name = "Container Box ESP", CurrentValue = false, Callback = function(v) containerBoxEnabled = v if not v then clearBoxes("Containers") end end})
visualsTab:CreateToggle({Name = "Container Name ESP", CurrentValue = false, Callback = function(v) containerTextEnabled = v if not v then clearTexts() end end})
visualsTab:CreateToggle({Name = "Dropped Item Box ESP (A Little Buggy)", CurrentValue = false, Callback = function(v) droppedBoxEnabled = v if not v then clearBoxes("DroppedItems") end end})
visualsTab:CreateToggle({Name = "Dropped Item Name ESP", CurrentValue = false, Callback = function(v) droppedTextEnabled = v if not v then clearTexts() end end})
visualsTab:CreateToggle({Name = "Exit ESP (Some Might Be Behind Locked Doors!)", CurrentValue = false, Callback = function(v) exitEspEnabled = v if not v then clearTexts() end end})

miscTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) fullbrightEnabled = v setFullbright(v) end})
miscTab:CreateButton({Name = "FPS Booster", Callback = function()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic obj.Reflectance = 0 obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
            obj.Enabled = false
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogStart = 0 Lighting.FogEnd = 1e10
    Lighting.Brightness = 2 Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end})

creditsTab:CreateParagraph({ Title = "Scripted by breakneckv09", Content = "Thanks for using my script!" })
creditsTab:CreateButton({ Name = "Copy Discord Invite", Callback = function() setclipboard("discord.gg/faV3GCjebC") Rayfield:Notify({Title = "Copied Link!", Content = "Discord invite copied to clipboard.", Duration = 4}) end })