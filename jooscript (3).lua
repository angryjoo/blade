local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Joo's Script",
    Icon = 0,
    LoadingTitle = "Loading Joo's Script",
    LoadingSubtitle = "by Joo",
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Big Hub"
    },
    KeySystem = true,
    KeySettings = {
        Title = "Enter Key",
        Subtitle = "made by Joo",
        Note = "Please contact Joo for a key",
        FileName = "Key",
        SaveKey = false,
        GrabKeyFromSite = true,
        Key = {"wasup123", "alani9", "liani9"}
    }
})

-- === Player Tab ===
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- WalkSpeed
local function updateWalkSpeed(speed)
    local player = game:GetService("Players").LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
        end
    end
end

local WalkSpeedSlider = PlayerTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(value)
        updateWalkSpeed(value)
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            updateWalkSpeed(value)
        end)
    end,
})

-- JumpPower
local function updateJumpPower(power)
    local player = game:GetService("Players").LocalPlayer
    if player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.JumpPower = power
            humanoid.JumpHeight = power / 1.5
        end
    end
end

local JumpPowerSlider = PlayerTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 10,
    Suffix = "Height",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(value)
        updateJumpPower(value)
        game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
            updateJumpPower(value)
        end)
    end,
})

-- FOV
local function updateFOV(value)
    local camera = game:GetService("Workspace").CurrentCamera
    if camera then
        camera.FieldOfView = value
    end
end

local FOVSlider = PlayerTab:CreateSlider({
    Name = "Camera FOV",
    Range = {70, 120},
    Increment = 5,
    Suffix = "FOV",
    CurrentValue = 70,
    Flag = "CameraFOV",
    Callback = function(value)
        updateFOV(value)
        game:GetService("RunService").RenderStepped:Connect(function()
            updateFOV(value)
        end)
    end,
})

-- === Parry Tab ===
local ParryTab = Window:CreateTab("Parry", 4483362458)

-- === Auto Clicker Einstellungen ===
local autoClickEnabled = false
local clickDelay = 0.1
local selectedKey = Enum.KeyCode.One

local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Hotkey Auswahl (setzt die Taste)
ParryTab:CreateKeybind({
    Name = "Auto Clicker Hotkey",
    CurrentKeybind = "One",
    HoldToInteract = false,
    Flag = "AutoClickerKey",
    Callback = function(Key)
        print("Hotkey gesetzt auf:", Key.Name)
        selectedKey = Key
    end,
})

-- Klickgeschwindigkeit einstellen
ParryTab:CreateSlider({
    Name = "Click Speed (sec)",
    Range = {0.01, 1},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = 0.1,
    Flag = "ClickDelay",
    Callback = function(value)
        clickDelay = value
    end,
})

-- Hotkey Listener zum Umschalten
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == selectedKey then
        autoClickEnabled = not autoClickEnabled
        print("AutoClicker Status:", autoClickEnabled)

        if autoClickEnabled then
            Rayfield:Notify({
                Title = "Auto Clicker",
                Content = "✅ Auto Clicker **aktiviert** per Hotkey",
                Duration = 3,
                Image = 4483362458
            })
        else
            Rayfield:Notify({
                Title = "Auto Clicker",
                Content = "❌ Auto Clicker **deaktiviert** per Hotkey",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
end)

-- Auto Clicker Loop
task.spawn(function()
    while true do
        task.wait(clickDelay)
        if autoClickEnabled then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.01)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end)

-- === Auto Parry ===
ParryTab:CreateToggle({
    Name = "Auto Parry",
    CurrentValue = false,
    Flag = "AutoParry",
    Callback = function(Value)
        if Value then
            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local Player = Players.LocalPlayer
            local Cooldown = tick()
            local Parried = false
            local Connection = nil

            local function GetBall()
                for _, Ball in ipairs(workspace.Balls:GetChildren()) do
                    if Ball:GetAttribute("realBall") then
                        return Ball
                    end
                end
            end

            local function ResetConnection()
                if Connection then
                    Connection:Disconnect()
                    Connection = nil
                end
            end

            workspace.Balls.ChildAdded:Connect(function()
                local Ball = GetBall()
                if not Ball then return end
                ResetConnection()
                Connection = Ball:GetAttributeChangedSignal("target"):Connect(function()
                    Parried = false
                end)
            end)

            RunService.PreSimulation:Connect(function()
                if not Player.Character then return end
                local Ball, HRP = GetBall(), Player.Character:FindFirstChild("HumanoidRootPart")
                if not Ball or not HRP then return end

                local Speed = Ball.zoomies.VectorVelocity.Magnitude
                local Distance = (HRP.Position - Ball.Position).Magnitude

                if Ball:GetAttribute("target") == Player.Name and not Parried and Distance / Speed <= 0.55 then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    Parried = true
                    Cooldown = tick()

                    if (tick() - Cooldown) >= 1 then
                        Parried = false
                    end
                end
            end)
        end
    end,
})

-- === Reset bei Respawn ===
updateWalkSpeed(WalkSpeedSlider.CurrentValue)
updateJumpPower(JumpPowerSlider.CurrentValue)
updateFOV(FOVSlider.CurrentValue)

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    updateWalkSpeed(WalkSpeedSlider.CurrentValue)
    updateJumpPower(JumpPowerSlider.CurrentValue)
    task.wait(0.5)
    updateFOV(FOVSlider.CurrentValue)
end)
