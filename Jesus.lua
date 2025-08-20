        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild('HumanoidRootPart')

        local platform
        local platformSize = Vector3.new(6, 1, 6)
        local WATER_OFFSET = 0.01

        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = { char }
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist

        RunService.RenderStepped:Connect(function()
            local ray = Workspace:Raycast(
                hrp.Position,
                Vector3.new(0, -50, 0),
                rayParams
            )

            if ray and ray.Material == Enum.Material.Water then
                if not platform then
                    platform = Instance.new('Part')
                    platform.Size = platformSize
                    platform.Anchored = true
                    platform.CanCollide = true
                    platform.Transparency = 1
                    platform.Parent = Workspace
                end
                platform.Position = Vector3.new(
                    hrp.Position.X,
                    ray.Position.Y + WATER_OFFSET,
                    hrp.Position.Z
                )
            elseif platform then
                platform:Destroy()
                platform = nil
            end
        end)
