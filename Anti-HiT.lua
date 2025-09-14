-- Simple Anti-Hit Toggle Script untuk Roblox
-- Hanya tombol toggle ON/OFF dan tombol close X

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Variabel untuk anti-hit
local antiHitEnabled = false
local originalCanCollide = {}
local heartbeatConnection

-- Membuat ScreenGui utama
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleAntiHitGui"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false

-- Frame utama yang bisa di-drag
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 80, 0, 30)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

-- Corner untuk frame utama
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Toggle button (tombol utama ON/OFF)
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Parent = mainFrame
toggleBtn.Size = UDim2.new(0, 50, 1, 0)
toggleBtn.Position = UDim2.new(0, 0, 0, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- Close button (tombol X)
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Parent = mainFrame
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Position = UDim2.new(0, 50, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Fungsi untuk menyimpan CanCollide asli
local function saveOriginalCanCollide()
    if player.Character then
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") then
                originalCanCollide[part] = part.CanCollide
            end
        end
    end
end

-- Fungsi untuk mengaktifkan anti-hit
local function enableAntiHit()
    if player.Character then
        saveOriginalCanCollide()
        
        -- Set semua part menjadi non-collidable
        for _, part in pairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = false
            end
        end
        
        -- Monitor part baru yang ditambahkan
        heartbeatConnection = RunService.Heartbeat:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        if originalCanCollide[part] == nil then
                            originalCanCollide[part] = part.CanCollide
                        end
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

-- Fungsi untuk menonaktifkan anti-hit
local function disableAntiHit()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    
    if player.Character then
        -- Kembalikan CanCollide ke nilai asli
        for part, originalValue in pairs(originalCanCollide) do
            if part and part.Parent then
                part.CanCollide = originalValue
            end
        end
    end
    
    originalCanCollide = {}
end

-- Fungsi untuk update tampilan tombol
local function updateToggleButton()
    if antiHitEnabled then
        toggleBtn.Text = "ON"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    else
        toggleBtn.Text = "OFF"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    end
end

-- Event handler untuk toggle button
toggleBtn.MouseButton1Click:Connect(function()
    antiHitEnabled = not antiHitEnabled
    
    if antiHitEnabled then
        enableAntiHit()
    else
        disableAntiHit()
    end
    
    updateToggleButton()
    
    -- Efek visual saat diklik
    local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 45, 0.9, 0)
    })
    tween:Play()
    tween.Completed:Connect(function()
        local tween2 = TweenService:Create(toggleBtn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 50, 1, 0)
        })
        tween2:Play()
    end)
end)

-- Event handler untuk close button
closeBtn.MouseButton1Click:Connect(function()
    -- Nonaktifkan anti-hit sebelum menutup
    if antiHitEnabled then
        antiHitEnabled = false
        disableAntiHit()
    end
    
    -- Efek fade out sebelum menghapus GUI
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 65, 0, 65)
    })
    
    tween:Play()
    tween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

-- Event untuk menangani ketika character respawn
player.CharacterAdded:Connect(function()
    wait(1) -- Tunggu character fully loaded
    if antiHitEnabled then
        disableAntiHit()
        enableAntiHit()
    end
end)

-- Efek hover untuk tombol
toggleBtn.MouseEnter:Connect(function()
    if antiHitEnabled then
        local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(60, 187, 89)
        })
        tween:Play()
    else
        local tween = TweenService:Create(toggleBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = Color3.fromRGB(240, 73, 89)
        })
        tween:Play()
    end
end)

toggleBtn.MouseLeave:Connect(function()
    updateToggleButton()
end)

closeBtn.MouseEnter:Connect(function()
    local tween = TweenService:Create(closeBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    })
    tween:Play()
end)

closeBtn.MouseLeave:Connect(function()
    local tween = TweenService:Create(closeBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    })
    tween:Play()
end)

-- Update tampilan awal
updateToggleButton()

print("Simple Anti-Hit Toggle berhasil dimuat!")
print("- Klik tombol untuk toggle ON/OFF")
print("- Drag untuk memindahkan posisi")
print("- Klik X untuk menutup (otomatis nonaktifkan anti-hit)")
