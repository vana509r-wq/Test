-- Автоматическая загрузка внешнего скрипта при старте меню
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/platinww/CrustyMain/refs/heads/main/universal/DropKick.lua"))()
end)

-- Создание графического интерфейса (GUI) в CoreGui (чтобы не пропадал при смерти)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local SpeedBtn = Instance.new("TextButton")
local FlyBtn = Instance.new("TextButton")
local ESPBtn = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Настройка главного фрейма меню
MainFrame.Name = "DeltaCheatMenu"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 200, 0, 250)
MainFrame.Active = true
MainFrame.Draggable = true -- Меню можно двигать пальцем/мышкой

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 12)

-- Заголовок меню
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Title.Text = "Delta Menu"
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
local TitleCorner = Instance.new("UICorner", Title)
TitleCorner.CornerRadius = UDim.new(0, 12)

-- Функция для быстрого создания красивых кнопок
local function createButton(name, text, pos)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = MainFrame
    btn.Position = pos
    btn.Size = UDim2.new(0, 170, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Font = Enum.Font.SourceSansSemibold
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    return btn
end

SpeedBtn = createButton("SpeedBtn", "Спидхак: ВЫКЛ", UDim2.new(0, 15, 0, 60))
FlyBtn = createButton("FlyBtn", "Флай (Полет): ВЫКЛ", UDim2.new(0, 15, 0, 120))
ESPBtn = createButton("ESPBtn", "ВХ (Подсветка): ВЫКЛ", UDim2.new(0, 15, 0, 180))

-- Логика чит-функций
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local players = game:GetService("Players")

local speedActive = false
local flyActive = false
local espActive = false
local flyConnection

-- 1. Спидхак (Speedhack)
SpeedBtn.MouseButton1Click:Connect(function()
    speedActive = not speedActive
    if speedActive then
        SpeedBtn.Text = "Спидхак: ВКЛ"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 75)
    else
        SpeedBtn.Text = "Спидхак: ВЫКЛ"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

runService.RenderStepped:Connect(function()
    if speedActive and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 100 -- Твоя скорость (можно менять)
    end
end)

-- 2. Флай (Fly)
FlyBtn.MouseButton1Click:Connect(function()
    flyActive = not flyActive
    if flyActive then
        FlyBtn.Text = "Флай: ВКЛ"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 75)
        
        local character = player.Character
        if not character then return end
        local root = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        
        if root and humanoid then
            humanoid.PlatformStand = true
            flyConnection = runService.RenderStepped:Connect(function()
                if not flyActive or not root or not character.Parent then
                    if flyConnection then flyConnection:Disconnect() end
                    return
                end
                
                local camCFrame = workspace.CurrentCamera.CFrame
                if humanoid.MoveDirection.Magnitude > 0 then
                    root.Velocity = camCFrame.LookVector * 75 -- Скорость полета
                else
                    root.Velocity = Vector3.new(0, 0, 0)
                end
                root.CFrame = CFrame.new(root.Position, root.Position + camCFrame.LookVector)
            end)
        end
    else
        FlyBtn.Text = "Флай: ВЫКЛ"
        FlyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        if flyConnection then flyConnection:Disconnect() end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- 3. ВХ / Валлхак (ESP Highlight)
local function applyESP(targetPlayer)
    if targetPlayer == player then return end
    
    local function drawESP(character)
        character:WaitForChild("HumanoidRootPart")
        if espActive and not character:FindFirstChild("MenuHighlight") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "MenuHighlight"
            highlight.FillColor = Color3.fromRGB(255, 0, 50)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.4
            highlight.AlwaysOnTop = true
            highlight.Parent = character
        end
    end
    
    if targetPlayer.Character then drawESP(targetPlayer.Character) end
    targetPlayer.CharacterAdded:Connect(drawESP)
end

ESPBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        ESPBtn.Text = "ВХ: ВКЛ"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 75)
        for _, p in ipairs(players:GetPlayers()) do applyESP(p) end
    else
        ESPBtn.Text = "ВХ: ВЫКЛ"
        ESPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
        for _, p in ipairs(players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("MenuHighlight") then
                p.Character.MenuHighlight:Destroy()
            end
        end
    end
end)

players.PlayerAdded:Connect(applyESP)
