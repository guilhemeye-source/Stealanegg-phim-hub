--// aphim-hub | TELEPORTE DIRETO
--// Não precisa equipar nenhum item
--// Clique no botão para executar
--// 0.1s antes do teleporte
--// 0.90s na Base

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURAÇÃO
--==================================================

local Ativado = false
local Processando = false

local TEMPO_ANTES = 0.1
local TEMPO_NA_BASE = 0.90

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "aphimHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

--==================================================
-- PAINEL
--==================================================

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

    local Base = Workspace:FindFirstChild("Base", true)

    if not Base then
        warn("aphim-hub: Base não encontrada.")
        return nil
    end

    if Base:IsA("BasePart") then
        return Base
    end

    if Base:IsA("Model") then

        if Base.PrimaryPart then
            return Base.PrimaryPart
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
-- TELEPORTE
--==================================================

local function IrParaBase()

    if not Ativado then
        return
    end

    if Processando then
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

    --==================================================
    -- ESPERA 0.1 SEGUNDO
    --==================================================

    task.wait(TEMPO_ANTES)

    if not Root or not Root.Parent then
        Processando = false
        return
    end

    --==================================================
    -- TELEPORTA PARA A BASE
    --==================================================

    Root.CFrame =
        Base.CFrame + Vector3.new(0, 4, 0)

    print("aphim-hub: teleportado para a Base")

    --==================================================
    -- FICA 0.90 SEGUNDO NA BASE
    --==================================================

    task.wait(TEMPO_NA_BASE)

    --==================================================
    -- VOLTA
    --==================================================

    if Root and Root.Parent then
        Root.CFrame = PosicaoOriginal
    end

    print("aphim-hub: voltou para a posição original")

    Processando = false
end

--==================================================
-- BOTÃO TELEPORTE
--==================================================

local BotButton = Instance.new("TextButton")

BotButton.Size = UDim2.new(1, -20, 0, 45)
BotButton.Position = UDim2.fromOffset(10, 55)

BotButton.BackgroundColor3 =
    Color3.fromRGB(0, 0, 0)

BotButton.BorderSizePixel = 0

BotButton.Text = "📶 TELEPORTE BASE"
BotButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

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
Status.TextColor3 =
    Color3.fromRGB(255, 70, 70)

Status.TextSize = 14
Status.Font = Enum.Font.GothamBold

Status.Parent = Main

--==================================================
-- CLIQUE NO TELEPORTE
--==================================================

BotButton.MouseButton1Click:Connect(function()

    Ativado = not Ativado

    if Ativado then

        BotButton.BackgroundColor3 =
            Color3.fromRGB(0, 70, 140)

        Status.Text = "STATUS: ATIVADO"
        Status.TextColor3 =
            Color3.fromRGB(0, 255, 120)

        print("aphim-hub: TELEPORTE ATIVADO")

        -- Não precisa de Tool.
        -- O clique inicia diretamente.
        task.spawn(IrParaBase)

    else

        BotButton.BackgroundColor3 =
            Color3.fromRGB(0, 0, 0)

        Status.Text = "STATUS: DESATIVADO"
        Status.TextColor3 =
            Color3.fromRGB(255, 70, 70)

        print("aphim-hub: TELEPORTE DESATIVADO")

    end
end)

--==================================================
-- BOTÃO REABRIR
--==================================================

local OpenButton = Instance.new("TextButton")

OpenButton.Name = "Reabrir"

OpenButton.Size =
    UDim2.fromOffset(60, 60)

OpenButton.Position =
    UDim2.fromOffset(18, 200)

OpenButton.BackgroundColor3 =
    Color3.fromRGB(10, 10, 18)

OpenButton.Text = "SH"
OpenButton.TextColor3 =
    Color3.fromRGB(255, 255, 255)

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
-- ARRASTAR JANELA
--==================================================

local Dragging = false
local DragStart
local StartPos

Top.InputBegan:Connect(function(Input)

    if Input.UserInputType ==
        Enum.UserInputType.MouseButton1

    or Input.UserInputType ==
        Enum.UserInputType.Touch then

        Dragging = true
        DragStart = Input.Position
        StartPos = Main.Position

        Input.Changed:Connect(function()

            if Input.UserInputState ==
                Enum.UserInputState.End then

                Dragging = false

            end

        end)

    end
end)

UserInputService.InputChanged:Connect(function(Input)

    if not Dragging then
        return
    end

    if Input.UserInputType ==
        Enum.UserInputType.MouseMovement

    or Input.UserInputType ==
        Enum.UserInputType.Touch then

        local Delta =
            Input.Position - DragStart

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
print("Sem Tool necessária.")
print("Tempo antes: 0.1s")
print("Tempo na Base: 0.90s")



