local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LOCAL_PLAYER = Players.LocalPlayer
local MAX_DISTANCE = 3000 -- Distância máxima em studs

-- Função para criar o marcador (ESP)
local function createESP(player)
    local function onCharacterAdded(character)
        local head = character:WaitForChild("Head")

        -- BillboardGui para exibir o ESP
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(2, 0, 2, 0) -- Tamanho ajustado para 2x2 studs
        billboard.StudsOffset = Vector3.new(0, 2, 0) -- Elevação do marcador acima da cabeça
        billboard.AlwaysOnTop = true

        -- Frame principal para o ESP
        local frame = Instance.new("Frame", billboard)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.3
        frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Cor do ESP (verde)
        frame.BorderSizePixel = 0

        -- Tornar o frame redondo
        local corner = Instance.new("UICorner", frame)
        corner.CornerRadius = UDim.new(0.5, 0) -- Deixa o frame redondo

        -- Texto para exibir a distância
        local distanceLabel = Instance.new("TextLabel", billboard)
        distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
        distanceLabel.Position = UDim2.new(0, 0, -0.5, 0) -- Posicionado acima do círculo
        distanceLabel.BackgroundTransparency = 1
        distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Cor do texto (branco)
        distanceLabel.TextScaled = true
        distanceLabel.Font = Enum.Font.SourceSansBold

        billboard.Parent = head

        -- Atualizar distância no texto
        RunService.Heartbeat:Connect(function()
            local localCharacter = LOCAL_PLAYER.Character
            if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
                local distance = (localCharacter.HumanoidRootPart.Position - head.Position).Magnitude
                distanceLabel.Text = string.format("%.0f studs", distance) -- Exibe a distância arredondada
            else
                distanceLabel.Text = ""
            end
        end)
    end

    -- Conecta ao evento de "CharacterAdded" para garantir o ESP
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Atualização contínua do ESP para todos os jogadores
local function updateAllESPs()
    RunService.Heartbeat:Connect(function()
        local localCharacter = LOCAL_PLAYER.Character
        if localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") then
            local localPosition = localCharacter.HumanoidRootPart.Position

            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LOCAL_PLAYER and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local billboard = head:FindFirstChildOfClass("BillboardGui")
                        if billboard then
                            local distance = (localPosition - head.Position).Magnitude
                            billboard.Enabled = distance <= MAX_DISTANCE
                        end
                    end
                end
            end
        end
    end)
end

-- Adiciona ESP para todos os jogadores existentes
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LOCAL_PLAYER then
        createESP(player)
    end
end

-- Adiciona ESP para novos jogadores
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Inicia a atualização do ESP
updateAllESPs()
