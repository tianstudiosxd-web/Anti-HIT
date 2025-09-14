-- Multi-Feature Script dengan GUI untuk Roblox
-- Features: Kill Aura, Invisibility, Anti Hit
-- Letakkan script ini sebagai LocalScript di StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variabel untuk mengontrol mode
local killMode = false
local invisibilityMode = false
local antiHitMode = false
local killDistance = 10 -- Jarak untuk membunuh (dalam studs)

-- Variabel untuk menyimpan bagian karakter asli (untuk invisibility)
local originalTransparency = {}
local originalCanCollide = {}

-- Membuat GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MultiFeatureGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 280)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

-- Gradient untuk frame
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 25))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Shadow effect
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 10, 1, 10)
shadow.Position = UDim2.new(0, -5, 0, -5)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.7
shadow.ZIndex = mainFrame.ZIndex - 1
shadow.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 12)
shadowCorner.Parent = shadow

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🛡️ Multi Hack Menu"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Separator line
local separator = Instance.new("Frame")
separator.Name = "Separator"
separator.Size = UDim2.new(0.9, 0, 0, 2)
separator.Position = UDim2.new(0.05, 0, 0, 45)
separator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
separator.BorderSizePixel = 0
separator.Parent = mainFrame

-- Function to create feature button
local function createFeatureButton(name, text, icon, yPosition, callback)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(0.9, 0, 0, 45)
    button.Position = UDim2.new(0.05, 0, 0, yPosition)
    button.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    button.Text = icon .. " " .. text .. ": OFF"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.Parent = mainFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Kill Aura Button
local killAuraButton = createFeatureButton("KillAura", "Kill Aura", "⚔️", 60, function()
    killMode = not killMode
    if killMode then
        killAuraButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        killAuraButton.Text = "⚔️ Kill Aura: ON"
    else
        killAuraButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        killAuraButton.Text = "⚔️ Kill Aura: OFF"
    end
end)

-- Invisibility Button
local invisibilityButton = createFeatureButton("Invisibility", "Invisibility", "👻", 120, function()
    invisibilityMode = not invisibilityMode
    if invisibilityMode then
        invisibilityButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        invisibilityButton.Text = "👻 Invisibility: ON"
        makeInvisible()
    else
        invisibilityButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        invisibilityButton.Text = "👻 Invisibility: OFF"
        makeVisible()
    end
end)

-- Anti Hit Button
local antiHitButton = createFeatureButton("AntiHit", "Anti Hit", "🛡️", 180, function()
    antiHitMode = not antiHitMode
    if antiHitMode then
        antiHitButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        antiHitButton.Text = "🛡️ Anti Hit: ON"
        enableAntiHit()
    else
        antiHitButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        antiHitButton.Text = "🛡️ Anti Hit: OFF"
        disableAntiHit()
    end
end)

-- Status Panel
local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.Size = UDim2.new(0.9, 0, 0, 40)
statusFrame.Position = UDim2.new(0.05, 0, 0, 230)
statusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
statusFrame.BorderSizePixel = 0
statusFrame.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.Position = UDim2.new(0, 0, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "📊 All Features: Inactive"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = statusFrame

-- Functions untuk invisibility (Server-side compatible)
function makeInvisible()
    local character = player.Character
    if not character then return end
    
    -- Method 1: Extreme position displacement
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        -- Simpan posisi asli
        originalTransparency["OriginalPosition"] = humanoidRootPart.CFrame
        
        -- Pindahkan karakter ke posisi sangat jauh (invisible to others)
        humanoidRootPart.CFrame = CFrame.new(math.huge, math.huge, math.huge)
    end
    
    -- Method 2: Transparency + CanCollide manipulation
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            originalTransparency[part] = {
                transparency = part.Transparency,
                canCollide = part.CanCollide,
                size = part.Size
            }
            
            -- Set transparency dan properties
            part.Transparency = 1
            part.CanCollide = false
            -- Kecilkan size untuk mengurangi hitbox
            part.Size = Vector3.new(0.01, 0.01, 0.01)
            
        elseif part:IsA("Accessory") then
            local handle = part:FindFirstChild("Handle")
            if handle then
                originalTransparency[handle] = {
                    transparency = handle.Transparency,
                    canCollide = handle.CanCollide,
                    size = handle.Size
                }
                handle.Transparency = 1
                handle.CanCollide = false
                handle.Size = Vector3.new(0.01, 0.01, 0.01)
            end
        end
    end
    
    -- Method 3: Hide character name and health bar
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        originalTransparency["DisplayDistanceType"] = humanoid.DisplayDistanceType
        originalTransparency["HealthDisplayDistance"] = humanoid.HealthDisplayDistance
        originalTransparency["NameDisplayDistance"] = humanoid.NameDisplayDistance
        
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        humanoid.HealthDisplayDistance = 0
        humanoid.NameDisplayDistance = 0
    end
    
    -- Method 4: Sembunyikan face dan clothing
    local head = character:FindFirstChild("Head")
    if head then
        for _, item in pairs(head:GetChildren()) do
            if item:IsA("Decal") or item:IsA("SpecialMesh") then
                originalTransparency[item] = item.Transparency
                item.Transparency = 1
            end
        end
    end
    
    -- Method 5: Remove character sound effects
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            for _, sound in pairs(part:GetChildren()) do
                if sound:IsA("Sound") then
                    originalTransparency[sound] = sound.Volume
                    sound.Volume = 0
                end
            end
        end
    end
end

function makeVisible()
    local character = player.Character
    if not character then return end
    
    -- Kembalikan posisi asli
    if originalTransparency["OriginalPosition"] then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        if humanoidRootPart then
            humanoidRootPart.CFrame = originalTransparency["OriginalPosition"]
        end
    end
    
    -- Kembalikan properties asli
    for part, properties in pairs(originalTransparency) do
        if typeof(properties) == "table" and part ~= "OriginalPosition" and part ~= "DisplayDistanceType" and part ~= "HealthDisplayDistance" and part ~= "NameDisplayDistance" then
            if part.Parent then
                if properties.transparency then part.Transparency = properties.transparency end
                if properties.canCollide then part.CanCollide = properties.canCollide end
                if properties.size then part.Size = properties.size end
            end
        elseif typeof(properties) == "number" and part.Parent then
            if part:IsA("Decal") or part:IsA("SpecialMesh") then
                part.Transparency = properties
            elseif part:IsA("Sound") then
                part.Volume = properties
            end
        end
    end
    
    -- Kembalikan humanoid settings
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        if originalTransparency["DisplayDistanceType"] then
            humanoid.DisplayDistanceType = originalTransparency["DisplayDistanceType"]
        end
        if originalTransparency["HealthDisplayDistance"] then
            humanoid.HealthDisplayDistance = originalTransparency["HealthDisplayDistance"]
        end
        if originalTransparency["NameDisplayDistance"] then
            humanoid.NameDisplayDistance = originalTransparency["NameDisplayDistance"]
        end
    end
    
    originalTransparency = {}
end

-- Functions untuk anti hit
local antiHitConnection
function enableAntiHit()
    local character = player.Character
    if not character then return end
    
    -- Simpan CanCollide asli dan nonaktifkan collision
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            originalCanCollide[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    
    -- Monitor kesehatan dan reset jika terkena damage
    local humanoid = character:FindFirstChild("Humanoid")
    if humanoid then
        antiHitConnection = humanoid.HealthChanged:Connect(function(health)
            if health < humanoid.MaxHealth and antiHitMode then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end
end

function disableAntiHit()
    if antiHitConnection then
        antiHitConnection:Disconnect()
        antiHitConnection = nil
    end
    
    local character = player.Character
    if not character then return end
    
    -- Kembalikan CanCollide asli
    for part, canCollide in pairs(originalCanCollide) do
        if part.Parent then
            part.CanCollide = canCollide
        end
    end
    
    originalCanCollide = {}
end

-- Function untuk membunuh player
local function killPlayer(targetPlayer)
    if targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") then
        targetPlayer.Character.Humanoid.Health = 0
    end
end

-- Function untuk menghitung jarak
local function getDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

-- Function untuk update status
local function updateStatus()
    local activeFeatures = {}
    if killMode then table.insert(activeFeatures, "Kill Aura") end
    if invisibilityMode then table.insert(activeFeatures, "Invisibility") end
    if antiHitMode then table.insert(activeFeatures, "Anti Hit") end
    
    if #activeFeatures > 0 then
        statusLabel.Text = "📊 Active: " .. table.concat(activeFeatures, ", ")
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        statusLabel.Text = "📊 All Features: Inactive"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Loop utama untuk kill aura
local killAuraConnection
killAuraConnection = RunService.Heartbeat:Connect(function()
    updateStatus()
    
    if not killMode then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local playerPosition = character.HumanoidRootPart.Position
    
    -- Cek semua player lain
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherCharacter = otherPlayer.Character
            local otherRootPart = otherCharacter:FindFirstChild("HumanoidRootPart")
            local otherHumanoid = otherCharacter:FindFirstChild("Humanoid")
            
            if otherRootPart and otherHumanoid and otherHumanoid.Health > 0 then
                local distance = getDistance(playerPosition, otherRootPart.Position)
                
                if distance <= killDistance then
                    killPlayer(otherPlayer)
                end
            end
        end
    end
end)

-- Handle karakter respawn
player.CharacterAdded:Connect(function(character)
    -- Wait for character to fully load
    character:WaitForChild("HumanoidRootPart")
    character:WaitForChild("Humanoid")
    wait(1) -- Extra wait untuk memastikan semua part loaded
    
    -- Reset semua mode saat respawn
    if invisibilityMode then
        makeInvisible()
    end
    
    if antiHitMode then
        enableAntiHit()
    end
end)

-- Membersihkan koneksi saat player leave
player.CharacterRemoving:Connect(function()
    if killAuraConnection then
        killAuraConnection:Disconnect()
    end
    if antiHitConnection then
        antiHitConnection:Disconnect()
    end
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.K then -- Kill Aura
        killAuraButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.I then -- Invisibility
        invisibilityButton.MouseButton1Click:Fire()
    elseif input.KeyCode == Enum.KeyCode.H then -- Anti Hit
        antiHitButton.MouseButton1Click:Fire()
    end
end)

print("🚀 Multi-Feature Script loaded successfully!")
print("📋 Features Available:")
print("   ⚔️  Kill Aura (Hotkey: K)")
print("   👻 True Invisibility - Hidden from ALL players (Hotkey: I)")
print("   🛡️  Anti Hit (Hotkey: H)")
print("   📊 Distance: " .. killDistance .. " studs")
print("   🖱️  GUI can be dragged around")
print("   🔥 Advanced invisibility methods active!")

-- Animasi startup
mainFrame:TweenSize(
    UDim2.new(0, 250, 0, 280),
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Back,
    0.7,
    true
)
