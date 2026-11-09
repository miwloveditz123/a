-- =========================================================
-- FPS BOOST v2
-- • No texture   : Texture/Decal/SurfaceAppearance/MeshPart texture dihapus
-- • No shadow    : GlobalShadows OFF + CastShadow part OFF
-- • No fog       : Fog dihilangkan + Atmosphere dihapus
-- • No reflect   : Reflectance 0 + EnvironmentSpecularScale 0 + water reflect 0
-- Otomatis apply ke part baru (streaming/respawn).
-- =========================================================

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local SETTINGS = {
    Texture = true,
    Shadow  = true,
    Fog     = true,
    Reflect = true,
}

local statusLbl

local function setStatus(text)
    if statusLbl then
        pcall(function() statusLbl.Text = tostring(text) end)
    end
end

-- ===================== LIGHTING =====================
local function applyLighting()
    if SETTINGS.Shadow then
        pcall(function() Lighting.GlobalShadows = false end)
        pcall(function() Lighting.ShadowSoftness = 0 end)
    end
    if SETTINGS.Fog then
        pcall(function()
            Lighting.FogStart = 0
            Lighting.FogEnd = 100000
        end)
        for _, obj in ipairs(Lighting:GetChildren()) do
            if obj:IsA("Atmosphere") then pcall(function() obj:Destroy() end) end
        end
    end
    if SETTINGS.Reflect then
        pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
    end
    pcall(function()
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterReflectance = 0
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
        end
    end)
end

-- ===================== PART =====================
local function stripPart(part)
    if not part or not part:IsA("BasePart") then return end
    if SETTINGS.Shadow then
        pcall(function() part.CastShadow = false end)
    end
    if SETTINGS.Reflect then
        pcall(function() part.Reflectance = 0 end)
    end
    if SETTINGS.Texture then
        if part:IsA("MeshPart") then
            pcall(function() part.TextureID = "" end)
        end
        pcall(function()
            if part.Material ~= Enum.Material.Neon then
                part.Material = Enum.Material.SmoothPlastic
            end
        end)
    end
end

local function stripObject(obj)
    if not obj or not obj.Parent then return end
    if obj:IsA("BasePart") then
        stripPart(obj)
    elseif SETTINGS.Texture then
        if obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance") then
            pcall(function() obj:Destroy() end)
        elseif obj:IsA("SpecialMesh") then
            pcall(function() obj.TextureId = "" end)
        end
    end
end

-- ===================== APPLY ALL =====================
local function applyAll()
    applyLighting()
    local list = Workspace:GetDescendants()
    local parts = 0
    for i, obj in ipairs(list) do
        if obj:IsA("BasePart") then
            stripPart(obj)
            parts = parts + 1
        elseif SETTINGS.Texture and (obj:IsA("Decal") or obj:IsA("Texture") or obj:IsA("SurfaceAppearance")) then
            pcall(function() obj:Destroy() end)
        elseif SETTINGS.Texture and obj:IsA("SpecialMesh") then
            pcall(function() obj.TextureId = "" end)
        end
        if i % 300 == 0 then task.wait() end
    end
    setStatus(("Applied: %d part"):format(parts))
end

-- ===================== WATCHER =====================
local queue, queued = {}, {}
local function enqueue(obj)
    if not obj or queued[obj] then return end
    queued[obj] = true
    queue[#queue + 1] = obj
end

Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")
        or obj:IsA("SurfaceAppearance") or obj:IsA("SpecialMesh") then
        enqueue(obj)
    end
end)

Lighting.DescendantAdded:Connect(function(obj)
    if obj:IsA("Atmosphere") and SETTINGS.Fog then
        pcall(function() obj:Destroy() end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if #queue > 0 then
            local items = queue
            queue, queued = {}, {}
            for _, obj in ipairs(items) do
                pcall(stripObject, obj)
            end
            setStatus(("Auto: %d objek baru"):format(#items))
        end
    end
end)

-- ===================== UI =====================
local function getSurface()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    return LP:FindFirstChildOfClass("PlayerGui") or game:GetService("CoreGui")
end

local surface = getSurface()
for _, old in ipairs(surface:GetChildren()) do
    if old:IsA("ScreenGui") and old.Name == "FPSBOOST_V2" then old:Destroy() end
end

local sg = Instance.new("ScreenGui")
sg.Name = "FPSBOOST_V2"
sg.ResetOnSpawn = false
sg.DisplayOrder = 99999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function() sg.Parent = surface end)

local Main = Instance.new("Frame")
Main.Parent = sg
Main.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 40, 0, 120)
Main.Size = UDim2.fromOffset(320, 250)
Main.Active = true
local mc = Instance.new("UICorner"); mc.CornerRadius = UDim.new(0, 8); mc.Parent = Main
local mst = Instance.new("UIStroke"); mst.Color = Color3.fromRGB(150, 80, 255); mst.Thickness = 1.6; mst.Transparency = 0.25; mst.Parent = Main

local TopBar = Instance.new("Frame"); TopBar.Parent = Main
TopBar.BackgroundColor3 = Color3.fromRGB(26, 23, 36); TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 28)
local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 8); tc.Parent = TopBar

local Title = Instance.new("TextLabel"); Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(12, 0)
Title.Size = UDim2.new(1, -44, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "FPS BOOST v2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local Close = Instance.new("TextButton"); Close.Parent = TopBar
Close.BackgroundTransparency = 1
Close.Position = UDim2.new(1, -26, 0, 2)
Close.Size = UDim2.fromOffset(22, 22)
Close.Font = Enum.Font.GothamBold
Close.Text = "X"
Close.TextColor3 = Color3.fromRGB(200, 190, 220)
Close.TextSize = 13
Close.MouseButton1Click:Connect(function() sg:Destroy() end)

statusLbl = Instance.new("TextLabel"); statusLbl.Parent = Main
statusLbl.BackgroundTransparency = 1
statusLbl.Position = UDim2.fromOffset(12, 34)
statusLbl.Size = UDim2.new(1, -24, 0, 16)
statusLbl.Font = Enum.Font.Code
statusLbl.Text = "Siap"
statusLbl.TextColor3 = Color3.fromRGB(180, 170, 210)
statusLbl.TextSize = 10
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.TextTruncate = Enum.TextTruncate.AtEnd

local function makeBtn(text, pos, size, color, cb)
    local b = Instance.new("TextButton")
    b.Parent = Main
    b.BackgroundColor3 = color or Color3.fromRGB(36, 31, 48)
    b.BorderSizePixel = 0
    b.Position = pos
    b.Size = size
    b.Font = Enum.Font.GothamSemibold
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 10
    b.AutoButtonColor = true
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 5); c.Parent = b
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

local function updBtn(btn, key, label)
    local on = SETTINGS[key]
    btn.Text = label .. ": " .. (on and "ON" or "OFF")
    btn.BackgroundColor3 = on and Color3.fromRGB(120, 60, 220) or Color3.fromRGB(48, 40, 64)
end

local texBtn = makeBtn("", UDim2.fromOffset(12, 58), UDim2.fromOffset(140, 26), nil, function()
    SETTINGS.Texture = not SETTINGS.Texture
    updBtn(texBtn, "Texture", "No Texture")
    if SETTINGS.Texture then task.spawn(applyAll) end
end)
local shBtn = makeBtn("", UDim2.fromOffset(164, 58), UDim2.fromOffset(140, 26), nil, function()
    SETTINGS.Shadow = not SETTINGS.Shadow
    updBtn(shBtn, "Shadow", "No Shadow")
    if SETTINGS.Shadow then task.spawn(applyAll) end
end)
local fogBtn = makeBtn("", UDim2.fromOffset(12, 90), UDim2.fromOffset(140, 26), nil, function()
    SETTINGS.Fog = not SETTINGS.Fog
    updBtn(fogBtn, "Fog", "No Fog")
    if SETTINGS.Fog then task.spawn(applyAll) end
end)
local refBtn = makeBtn("", UDim2.fromOffset(164, 90), UDim2.fromOffset(140, 26), nil, function()
    SETTINGS.Reflect = not SETTINGS.Reflect
    updBtn(refBtn, "Reflect", "No Reflect")
    if SETTINGS.Reflect then task.spawn(applyAll) end
end)

updBtn(texBtn, "Texture", "No Texture")
updBtn(shBtn, "Shadow", "No Shadow")
updBtn(fogBtn, "Fog", "No Fog")
updBtn(refBtn, "Reflect", "No Reflect")

makeBtn("APPLY ULANG", UDim2.fromOffset(12, 128), UDim2.fromOffset(292, 30), Color3.fromRGB(120, 60, 220), function()
    task.spawn(applyAll)
end)

local note = Instance.new("TextLabel"); note.Parent = Main
note.BackgroundTransparency = 1
note.Position = UDim2.fromOffset(12, 166)
note.Size = UDim2.new(1, -24, 0, 70)
note.Font = Enum.Font.Code
note.Text = "Texture/Decal/SurfaceAppearance dihapus.\nShadow part dimatikan.\nFog + Atmosphere dihapus.\nReflectance & specular = 0.\nPart baru otomatis diproses."
note.TextColor3 = Color3.fromRGB(130, 120, 150)
note.TextSize = 10
note.TextXAlignment = Enum.TextXAlignment.Left
note.TextYAlignment = Enum.TextYAlignment.Top
note.TextWrapped = true

-- drag
local dragging, dragStart, startPos = false, nil, nil
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ===================== START =====================
task.spawn(function()
    setStatus("Apply awal...")
    applyAll()
end)
