--// aphim-hub | SISTEMA DO SEU JOGO
--// ProximityPrompt + coleta + Base
--// 0.1s antes do teleporte
--// 0.90s na Base

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURAÇÃO
--==================================================

local Ativado = false

local TEMPO_ANTES = 0.1
local TEMPO_NA_BASE = 0.90

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
Main.Name = "Main"
Main.Size = UDim2.fromOffset(300, 190)
Main.Position = UDim2.new(0.5, -150, 0.5, -95)
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

    local Base = workspace:FindFirstChild("Base", true)

    if not Base then
        warn("aphim-hub: Base não encontrada.")
        return nil
    end

    if Base:IsA("BasePart") then
        return Base
    end

    if Base:IsA("Model") then

        local Part = Base.PrimaryPart

        if Part then
            return Part
        end

        return Base:FindFirstChildWhichIsA(
            "BasePart",
            true
        )
    end

    return Base:FindFirstChildWhichIsA(
        "BasePart",
        true
    )
end

--==================================================
-- TELEPORTE PARA BASE
--==================================================

local function IrParaBase()

    if not Ativado or Processando then
        return
    end

    Processando = true

    local Character = Player.Character

    if not Character then
        Processando = false
        return
    end

    local Root = Character:FindFirstChild(
        "HumanoidRootPart"
    )

    if not Root then
        Processando = false
        return
    end

    local Base = FindBase()

    if not Base then
        Processando = false
        return
    end

    local PosicaoOriginal = Root.CFrame

    -- 0.1 segundo antes
    task.wait(TEMPO_ANTES)

    if not Root.Parent then
        Processando = false
        return
    end

    -- Vai para a Base
    Root.CFrame =
        Base.CFrame + Vector3.new(0, 4, 0)

    print("aphim-hub: foi para a Base")

    -- Fica 0.90 segundo
    task.wait(TEMPO_NA_BASE)

    if Root and Root.Parent then
        Root.CFrame = PosicaoOriginal
    end

    print("aphim-hub: voltou")

    Processando = false
end

--==================================================
-- ENCONTRAR PROXIMITYPROMPT
--==================================================

local function ProcurarPrompts()

    local Encontrados = {}

    for _, Obj in ipairs(workspace:GetDescendants()) do

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

    if PromptsMonitorados[Prompt] then
        return
    end

    PromptsMonitorados[Prompt] = true

    Prompt.Triggered:Connect(function(Jogador)

        if Jogador ~= Player then
            return
        end

        if not Ativado then
            return
        end

        print(
            "aphim-hub: interação detectada:",
            Prompt:GetFullName()
        )

        -- A coleta já foi acionada pelo
        -- ProximityPrompt do próprio jogo.
        --
        -- Depois da interação, vai para a Base.
        task.spawn(function()
            IrParaBase()
        end)

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

workspace.DescendantAdded:Connect(function(Obj)

    if Obj:IsA("ProximityPrompt") then

        task.wait()

        MonitorarPrompt(Obj)

    end

end)

--==================================================
-- BOTÃO
--==================================================

local BotButton = Instance.new("TextButton")
BotButton.Size = UDim2.new(1, -20, 0, 45)
BotButton.Position = UDim2.fromOffset(10, 55)
BotButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
BotButton.BorderSizePixel = 0
BotButton.Text = "📶 PARA BOTS"
BotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BotButton.TextSize = 15
BotButton.Font = Enum.Font.GothamBold
BotButton.Parent = Main

local BotCorner = Instance.new("UICorner")
BotCorner.CornerRadius = UDim.new(0, 8)
BotCorner.Parent = BotButton

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Position = UDim2.fromOffset(10, 108)
Status.BackgroundTransparency = 1
Status.Text = "STATUS: DESATIVADO"
Status.TextColor3 = Color3.fromRGB(255, 70, 70)
Status.TextSize = 14
Status.Font = Enum.Font.GothamBold
Status.Parent = Main

--==================================================
-- ATIVAR / DESATIVAR
--==================================================

BotButton.MouseButton1Click:Connect(function()

    Ativado = not Ativado

    if Ativado then

        Status.Text = "STATUS: ATIVADO"
        Status.TextColor3 = Color3.fromRGB(0, 255, 120)

        print("aphim-hub: ATIVADO")

        MonitorarPrompts()

    else

        Status.Text = "STATUS: DESATIVADO"
        Status.TextColor3 = Color3.fromRGB(255, 70, 70)

        print("aphim-hub: DESATIVADO")

    end
end)

--==================================================
-- BOTÃO REABRIR
--==================================================

local OpenButton = Instance.new("TextButton")

OpenButton.Name = "Reabrir"
OpenButton.Size = UDim2.fromOffset(60, 60)
OpenButton.Position = UDim2.fromOffset(18, 200)
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
print("Tempo antes: 0.1s")
print("Tempo na Base: 0.90s")
