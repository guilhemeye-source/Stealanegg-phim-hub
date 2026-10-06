--// aphim-hub | PARA BOTS
--// Clica para Teleportar
--// 0.2s antes | 0.70s na Base

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURAÇÃO
--==================================================

local TEMPO_ANTES = 0.2
local TEMPO_NA_BASE = 0.70

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "aphimHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(260, 135)
Main.Position = UDim2.new(0.5, -130, 0.5, -67)
Main.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 120, 255)
Stroke.Thickness = 1
Stroke.Parent = Main

--==================================================
-- TOPO
--==================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 34)
Top.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.fromOffset(9, 0)
Title.BackgroundTransparency = 1
Title.Text = "aphim-hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

--==================================================
-- FECHAR
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(25, 25)
CloseButton.Position = UDim2.new(1, -30, 0, 4)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 11
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Top

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseButton

--==================================================
-- ENCONTRAR BASE
--==================================================

local function FindBaseSpawn()

    local Base = workspace:FindFirstChild("Base", true)

    if Base then

        if Base:IsA("SpawnLocation") then
            return Base
        end

        if Base:IsA("Model") then
            local Spawn = Base:FindFirstChildWhichIsA(
                "SpawnLocation",
                true
            )

            if Spawn then
                return Spawn
            end
        end

        if Base:IsA("BasePart") then
            return Base
        end
    end

    local Spawns = {}

    for _, Obj in ipairs(workspace:GetDescendants()) do
        if Obj:IsA("SpawnLocation") then
            table.insert(Spawns, Obj)
        end
    end

    if #Spawns == 1 then
        return Spawns[1]
    end

    for _, Spawn in ipairs(Spawns) do

        local Nome = string.lower(Spawn.Name)

        if Nome:find("base")
        or Nome:find("spawn")
        or Nome:find("home") then
            return Spawn
        end
    end

    warn("aphim-hub: Ponto da Base não encontrado!")

    return nil
end

--==================================================
-- TELEPORTAR PARA BASE
--==================================================

local function TeleportToBase()

    local Point = FindBaseSpawn()

    if not Point then
        return
    end

    local Character = Player.Character

    if not Character then
        return
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChild("Humanoid")

    if not Root or not Humanoid then
        return
    end

    local PosicaoOriginal = Root.CFrame

    -- 0.2 segundo antes do teleporte
    task.wait(TEMPO_ANTES)

    if not Root or not Root.Parent then
        return
    end

    Humanoid:SetStateEnabled(
        Enum.HumanoidStateType.Running,
        false
    )

    Humanoid:SetStateEnabled(
        Enum.HumanoidStateType.FallingDown,
        false
    )

    Humanoid.PlatformStand = true

    -- Teleporta para a Base
    local NovaPosicao =
        Point.CFrame + Vector3.new(0, 4, 0)

    Root.CFrame = NovaPosicao

    task.wait()

    if Root and Root.Parent then
        Root.CFrame = NovaPosicao
    end

    print("aphim-hub: chegou na Base")

    -- 0.70 segundo na Base
    task.wait(TEMPO_NA_BASE)

    -- Volta para a posição original
    if Root and Root.Parent then
        Root.CFrame = PosicaoOriginal
    end

    if Humanoid and Humanoid.Parent then

        Humanoid:SetStateEnabled(
            Enum.HumanoidStateType.Running,
            true
        )

        Humanoid.PlatformStand = false

    end

    print("aphim-hub: voltou para posição original")
end

--==================================================
-- BOTÃO PARA BOTS
--==================================================

local BostButton = Instance.new("TextButton")

BostButton.Size = UDim2.new(1, -16, 0, 38)
BostButton.Position = UDim2.fromOffset(8, 47)
BostButton.BackgroundColor3 = Color3.fromRGB(0, 100, 210)
BostButton.BorderSizePixel = 0
BostButton.Text = "☑️ PARA BOTS"
BostButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BostButton.TextSize = 13
BostButton.Font = Enum.Font.GothamBold
BostButton.Parent = Main

local BostCorner = Instance.new("UICorner")
BostCorner.CornerRadius = UDim.new(0, 8)
BostCorner.Parent = BostButton

BostButton.MouseButton1Click:Connect(function()
    task.spawn(function()
        TeleportToBase()
    end)
end)

--==================================================
-- BOTÃO REABRIR COM IMAGEM
--==================================================

local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "Reabrir"
OpenButton.Size = UDim2.fromOffset(52, 52)
OpenButton.Position = UDim2.fromOffset(15, 180)
OpenButton.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
OpenButton.BorderSizePixel = 0

OpenButton.Image = "https://i.ibb.co/MxrNJQyk/75b4d340-c108-11f1-aed2-815e7ff87a19.png"

OpenButton.ScaleType = Enum.ScaleType.Crop
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

--==================================================
-- FECHAR / REABRIR
--==================================================

CloseButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
end)

--==================================================
-- ARRASTAR JANELA
--==================================================

local Dragging = false
local DragStart
local StartPos

Top.InputBegan:Connect(function(Input)

    if Input.UserInputType == Enum.UserInputType.MouseButton1
    or Input.UserInputType == Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPos = Main.Position

        Input.Changed:Connect(function()

            if Input.UserInputState == Enum.UserInputState.End then
                Dragging = false
            end

        end)
    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseMovement
    or Input.UserInputType == Enum.UserInputType.Touch then

        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPos.X.Scale,
            StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale,
            StartPos.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- INÍCIO
--==================================================

print("aphim-hub carregado!")
print("☑️ PARA BOTS: pronto")
print("Tempo antes: 0.2s")
print("Tempo na Base: 0.70s")
