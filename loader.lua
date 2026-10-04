--// aphim-hub | SISTEMA COMPLETO + AUTO FARM OVOS
--// ProximityPrompt + coleta + Base + Auto Ovos Steal an Egg
--// 0.1s antes do teleporte | 0.90s na Base

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURAÇÃO
--==================================================

local Ativado = false
local AutoOvosAtivado = false

local TEMPO_ANTES = 0.1
local TEMPO_NA_BASE = 0.90
local INTERVALO_FARM = 1

local Processando = false
local PromptsMonitorados = {}

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "aphimHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(300, 240)
Main.Position = UDim2.new(0.5, -150, 0.5, -120)
Main.BackgroundColor3 = Color3.fromRGB(15, 18, 25)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 10)
Corner.Parent = Main

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 120, 255)
Stroke.Thickness = 2
Stroke.Parent = Main

--==================================================
-- TOPO
--==================================================

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 38)
Top.BackgroundColor3 = Color3.fromRGB(10, 13, 20)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -55, 1, 0)
Title.Position = UDim2.fromOffset(10, 0)
Title.BackgroundTransparency = 1
Title.Text = "aphim-hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

--==================================================
-- FECHAR
--==================================================

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(28, 28)
CloseButton.Position = UDim2.new(1, -33, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(35, 40, 52)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 13
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = Top

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 7)
CloseCorner.Parent = CloseButton

--==================================================
-- ENCONTRAR BASE
--==================================================

local function FindBase()
    local Base = Workspace:FindFirstChild("Base", true)
    if not Base then
        warn("aphim-hub: Base não encontrada.")
        return nil
    end
    if Base:IsA("BasePart") then return Base end
    if Base:IsA("Model") then
        local Part = Base.PrimaryPart
        if Part then return Part end
        return Base:FindFirstChildWhichIsA("BasePart", true)
    end
    return Base:FindFirstChildWhichIsA("BasePart", true)
end

--==================================================
-- TELEPORTE PARA BASE
--==================================================

local function IrParaBase()
    if not Ativado or Processando then return end
    Processando = true

    local Character = Player.Character
    if not Character then Processando = false; return end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then Processando = false; return end

    local Base = FindBase()
    if not Base then Processando = false; return end

    local PosicaoOriginal = Root.CFrame

    task.wait(TEMPO_ANTES)
    if not Root.Parent then Processando = false; return end

    Root.CFrame = Base.CFrame + Vector3.new(0, 4, 0)
    print("aphim-hub: foi para a Base")

    task.wait(TEMPO_NA_BASE)
    if Root and Root.Parent then
        Root.CFrame = PosicaoOriginal
    end

    print("aphim-hub: voltou")
    Processando = false
end

--==================================================
-- AUTO FARM OVOS
--==================================================

local function autoFarmOvos()
    if not AutoOvosAtivado then return end

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Parent and obj.Parent.Name:match("Ovo") then
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = obj.Parent.CFrame
                task.wait(0.2)
                fireproximityprompt(obj)
                task.spawn(IrParaBase)
            end
        end
    end
end

--==================================================
-- ENCONTRAR PROXIMITYPROMPT
--==================================================

local function ProcurarPrompts()
    local Encontrados = {}
    for _, Obj in ipairs(Workspace:GetDescendants()) do
        if Obj:IsA("ProximityPrompt") then
            table.insert(Encontrados, Obj)
        end
    end
    return Encontrados
end

--==================================================
-- PROCESSAR PROMPT
--==================================================

local function MonitorarPrompt(Prompt)
    if PromptsMonitorados[Prompt] then return end
    PromptsMonitorados[Prompt] = true

    Prompt.Triggered:Connect(function(Jogador)
        if Jogador ~= Player then return end
        if not Ativado then return end

        print("aphim-hub: interação detectada:", Prompt:GetFullName())
        task.spawn(IrParaBase)
    end)
end

--==================================================
-- MONITORAR TODOS OS PROMPTS
--==================================================

local function MonitorarPrompts()
    for _, Prompt in ipairs(ProcurarPrompts()) do
        MonitorarPrompt(Prompt)
    end
end

--==================================================
-- NOVOS PROMPTS
--==================================================

Workspace.DescendantAdded:Connect(function(Obj)
    if Obj:IsA("ProximityPrompt") then
        task.wait()
        MonitorarPrompt(Obj)
    end
end)

--==================================================
-- BOTÕES
--==================================================

-- Botão Principal (Teleporte Base)
local BotButton = Instance.new("TextButton")
BotButton.Size = UDim2.new(1, -20, 0, 40)
BotButton.Position = UDim2.fromOffset(10, 55)
BotButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotButton.BorderSizePixel = 0
BotButton.Text = "📶 TELEPORTE BASE"
BotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BotButton.TextSize = 15
BotButton.Font = Enum.Font.GothamBold
BotButton.Parent = Main

local BotCorner = Instance.new("UICorner")
BotCorner.CornerRadius = UDim.new(0, 8)
BotCorner.Parent = BotButton

-- Botão Auto Ovos
local OvoButton = Instance.new("TextButton")
OvoButton.Size = UDim2.new(1, -20, 0, 40)
OvoButton.Position = UDim2.fromOffset(10, 105)
OvoButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OvoButton.BorderSizePixel = 0
OvoButton.Text = "🥚 AUTO FARM OVOS"
OvoButton.TextColor3 = Color3.fromRGB(255, 70, 70)
OvoButton.TextSize = 15
OvoButton.Font = Enum.Font.GothamBold
OvoButton.Parent = Main

local OvoCorner = Instance.new("UICorner")
OvoCorner.CornerRadius = UDim.new(0, 8)
OvoCorner.Parent = OvoButton

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.fromOffset(10, 160)
Status.BackgroundTransparency = 1
Status.Text = "BASE: DESATIVADO | OVOS: DESATIVADO"
Status.TextColor3 = Color3.fromRGB(255, 70, 70)
Status.TextSize = 13
Status.Font = Enum.Font.GothamBold
Status.Parent = Main

--==================================================
-- ATIVAR / DESATIVAR BASE
--==================================================

BotButton.MouseButton1Click:Connect(function()
    Ativado = not Ativado
    if Ativado then
        BotButton.BackgroundColor3 = Color3.fromRGB(0, 70, 140)
        MonitorarPrompts()
        print("aphim-hub: BASE ATIVADA")
    else
        BotButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        print("aphim-hub: BASE DESATIVADA")
    end
    Status.Text = "BASE: " .. (Ativado and "ATIVADO" or "DESATIVADO") .. " | OVOS: " .. (AutoOvosAtivado and "ATIVADO" or "DESATIVADO")
    Status.TextColor3 = (Ativado or AutoOvosAtivado) and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 70, 70)
end)

--==================================================
-- ATIVAR / DESATIVAR AUTO OVOS
--==================================================

OvoButton.MouseButton1Click:Connect(function()
    AutoOvosAtivado = not AutoOvosAtivado
    if AutoOvosAtivado then
        OvoButton.BackgroundColor3 = Color3.fromRGB(0, 100, 60)
        OvoButton.TextColor3 = Color3.fromRGB(0, 255, 120)
        print("aphim-hub: AUTO OVOS ATIVADO")
    else
        OvoButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        OvoButton.TextColor3 = Color3.fromRGB(255, 70, 70)
        print("aphim-hub: AUTO OVOS DESATIVADO")
    end
    Status.Text = "BASE: " .. (Ativado and "ATIVADO" or "DESATIVADO") .. " | OVOS: " .. (AutoOvosAtivado and "ATIVADO" or "DESATIVADO")
    Status.TextColor3 = (Ativado or AutoOvosAtivado) and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 70, 70)
end)

--==================================================
-- LOOP AUTO FARM
--==================================================

task.spawn(function()
    while task.wait(INTERVALO_FARM) do
        if AutoOvosAtivado then
            pcall(autoFarmOvos)
        end
    end
end)

--==================================================
-- BOTÃO REABRIR
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "Reabrir"
OpenButton.Size = UDim2.fromOffset(60, 60)
OpenButton.Position = UDim2.fromOffset(18, 250)
OpenButton.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
OpenButton.Text = "SH"
OpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenButton.TextSize = 14
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

--==================================================
-- ABRIR / FECHAR
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
-- ARRASTAR
--==================================================

local Dragging = false
local DragStart, StartPos

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
    if not Dragging then return end
    if Input.UserInputType == Enum.UserInputType.MouseMovement
    or Input.UserInputType == Enum.UserInputType.Touch then
        local Delta = Input.Position - DragStart
        Main.Position = UDim2.new(
            StartPos.X.Scale, StartPos.X.Offset + Delta.X,
            StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
        )
    end
end)

--==================================================
-- INÍCIO
--==================================================

print("aphim-hub carregado!")
print("Base: 0.1s antes | 0.90s na Base")
print("Auto Ovos: a cada " .. INTERVALO_FARM .. "s")
