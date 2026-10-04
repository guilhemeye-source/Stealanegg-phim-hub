--// aphim-hub | PARA BOTS
--// Sistema para seu próprio jogo
--// Detecta Tools no Backpack/Character
--// Detecta ovos e ProximityPrompts recursivamente
--// 8s antes do teleporte
--// 0.90s permanecendo na Base

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Backpack = Player:WaitForChild("Backpack")

--==================================================
-- CONFIGURAÇÃO
--==================================================

local Ativado = false
local Conexoes = {}

local TEMPO_ANTES = 8
local TEMPO_NA_BASE = 0.90

local Processando = false
local UltimoObjeto = nil

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

    for _, Obj in ipairs(workspace:GetDescendants()) do

        if Obj:IsA("SpawnLocation") then

            local Nome = string.lower(Obj.Name)

            if Nome:find("base")
            or Nome:find("spawn")
            or Nome:find("home") then

                return Obj
            end
        end
    end

    warn("aphim-hub: Base não encontrada!")

    return nil
end

--==================================================
-- TELEPORTE
--==================================================

local function TeleportWithFailure()

    if not Ativado then
        return
    end

    if Processando then
        return
    end

    Processando = true

    local Point = FindBaseSpawn()

    if not Point then
        Processando = false
        return
    end

    local Character = Player.Character

    if not Character then
        Processando = false
        return
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Root then
        Processando = false
        return
    end

    local PosicaoOriginal = Root.CFrame

    -- Espera 8 segundos antes do teleporte
    task.wait(TEMPO_ANTES)

    if not Root or not Root.Parent then
        Processando = false
        return
    end

    -- Vai para a Base
    Root.CFrame = Point.CFrame + Vector3.new(0, 4, 0)

    print("aphim-hub: foi para a Base")

    -- Permanece 0.90 segundos na Base
    task.wait(TEMPO_NA_BASE)

    -- Volta para a posição original
    if Root and Root.Parent then
        Root.CFrame = PosicaoOriginal
    end

    print("aphim-hub: voltou para posição original")

    Processando = false
end

--==================================================
-- ENCONTRAR PROXIMITYPROMPT
--==================================================

local function EncontrarPrompt(Ovo)

    if Ovo:IsA("ProximityPrompt") then
        return Ovo
    end

    for _, Objeto in ipairs(Ovo:GetDescendants()) do

        if Objeto:IsA("ProximityPrompt") then
            return Objeto
        end
    end

    return nil
end

--==================================================
-- ENCONTRAR PASTA DE OVOS
--==================================================

local function EncontrarPastaOvos()

    local Eggs = workspace:FindFirstChild("Eggs")

    if Eggs then
        return Eggs
    end

    local Spawns = workspace:FindFirstChild("Spawns")

    if Spawns then
        return Spawns
    end

    return nil
end

--==================================================
-- ANALISAR OVO
--==================================================

local function AnalisarOvo(Ovo)

    if not Ativado then
        return
    end

    if not Ovo or not Ovo.Parent then
        return
    end

    local Prompt = EncontrarPrompt(Ovo)

    if not Prompt then
        return
    end

    print("--------------------------------")
    print("aphim-hub: OVO ENCONTRADO")
    print("Nome:", Ovo.Name)
    print("Caminho:", Ovo:GetFullName())
    print("Prompt:", Prompt:GetFullName())
    print("--------------------------------")

    task.spawn(function()

        -- Espera 8 segundos antes do processo
        task.wait(TEMPO_ANTES)

        if not Ativado then
            return
        end

        if not Ovo or not Ovo.Parent then
            return
        end

        print("aphim-hub: ovo pronto")

        -- Espera 0.90 segundos
        task.wait(TEMPO_NA_BASE)

        TeleportWithFailure()

    end)
end

--==================================================
-- MONITORAR OVOS
--==================================================

local function MonitorarOvos()

    local Pasta = EncontrarPastaOvos()

    if not Pasta then

        warn(
            "aphim-hub: workspace.Eggs/Spawns não encontrado!"
        )

        return
    end

    print(
        "aphim-hub: pasta de ovos:",
        Pasta:GetFullName()
    )

    for _, Ovo in ipairs(Pasta:GetChildren()) do
        AnalisarOvo(Ovo)
    end

    Pasta.ChildAdded:Connect(function(Ovo)

        print(
            "aphim-hub: novo objeto:",
            Ovo.Name
        )

        task.wait()

        AnalisarOvo(Ovo)

    end)
end

--==================================================
-- BOTÃO PARA BOTS
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

        print("aphim-hub: PARA BOTS ATIVADO")

        MonitorarOvos()

    else

        Status.Text = "STATUS: DESATIVADO"
        Status.TextColor3 = Color3.fromRGB(255, 70, 70)

        print("aphim-hub: PARA BOTS DESATIVADO")

    end
end)

--==================================================
-- PROCESSAR TOOL
--==================================================

local function VerificarTool(Obj)

    if not Obj:IsA("Tool") then
        return
    end

    if not Ativado then
        return
    end

    if UltimoObjeto == Obj and Processando then
        return
    end

    UltimoObjeto = Obj

    print(
        "aphim-hub: objeto equipado:",
        Obj.Name
    )

    task.spawn(function()
        TeleportWithFailure()
    end)
end

--==================================================
-- MONITORAR CHARACTER
--==================================================

local function MonitorarCharacter(Character)

    for _, Connection in ipairs(Conexoes) do

        if Connection then
            Connection:Disconnect()
        end

    end

    table.clear(Conexoes)

    table.insert(
        Conexoes,
        Character.ChildAdded:Connect(function(Obj)

            if Obj:IsA("Tool") then
                VerificarTool(Obj)
            end

        end)
    )

    for _, Obj in ipairs(Character:GetChildren()) do

        if Obj:IsA("Tool") then
            VerificarTool(Obj)
        end

    end
end

--==================================================
-- MONITORAR BACKPACK
--==================================================

Backpack.ChildAdded:Connect(function(Obj)

    if not Obj:IsA("Tool") then
        return
    end

    print(
        "aphim-hub: novo item:",
        Obj.Name
    )

    task.wait()

    if Ativado then
        VerificarTool(Obj)
    end
end)

--==================================================
-- CHARACTER ATUAL
--==================================================

if Player.Character then
    MonitorarCharacter(Player.Character)
end

--==================================================
-- RENASCIMENTO
--==================================================

Player.CharacterAdded:Connect(function(Character)

    task.wait(0.5)

    UltimoObjeto = nil
    Processando = false

    MonitorarCharacter(Character)

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
print("Tempo antes da Base: 8s")
print("Tempo na Base: 0.90s")
