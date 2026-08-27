-- Zeta by Vhyse | v1.6

local Zeta = {
    Settings = {
        Enabled = true,
        MaxDistance = 300,
        TargetTeams = {},
        Filter = function(player) return true end, 
        Chams = { Enabled = false, Color = Color3.fromRGB(255, 0, 0), Chroma = false },
        Box = {
            Enabled = true, Color = Color3.fromRGB(255, 255, 255), Chroma = false,
            HeadCircle = { Enabled = true, Color = Color3.fromRGB(255, 255, 255), Chroma = false }
        },
        Text = { Enabled = true, UseDisplayName = true, Color = Color3.fromRGB(255, 255, 255), Chroma = false },
        Tracers = { Enabled = false, Origin = "Bottom", Color = Color3.fromRGB(255, 255, 255), Chroma = false },
        HealthBar = { Enabled = true }
    },
    Cache = {},
    Connections = {},
    Loaded = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

if not Drawing then return nil end

local HEAD_OFFSET = Vector3.new(0, 0.5, 0)
local ROOT_OFFSET = Vector3.new(0, 3, 0)
local CIRCLE_OFFSET = Vector3.new(0, 0.2, 0)

local function CreateESPObject(target, objType, customName, customColor)
    local espObj = {
        Target = target,
        Type = objType or "Player",
        CustomName = customName,
        CustomColor = customColor,
        Highlight = nil,
        Character = nil,
        Parts = {},
        DrawingsVisible = false,
        Drawings = {
            Box = Drawing.new("Square"),
            HeadCircle = Drawing.new("Circle"),
            NameText = Drawing.new("Text"),
            Tracer = Drawing.new("Line"),
            HealthBg = Drawing.new("Square"),
            HealthBar = Drawing.new("Square")
        }
    }

    espObj.Drawings.Box.Thickness = 1
    espObj.Drawings.Box.Filled = false
    espObj.Drawings.Box.ZIndex = 2
    
    espObj.Drawings.HeadCircle.Thickness = 1
    espObj.Drawings.HeadCircle.Filled = false
    espObj.Drawings.HeadCircle.ZIndex = 2
    
    espObj.Drawings.NameText.Size = 14
    espObj.Drawings.NameText.Center = true
    espObj.Drawings.NameText.Outline = true
    espObj.Drawings.NameText.Font = 2
    espObj.Drawings.NameText.ZIndex = 3
    
    espObj.Drawings.Tracer.Thickness = 1 
    espObj.Drawings.Tracer.Transparency = 1 
    espObj.Drawings.Tracer.ZIndex = 2
    
    espObj.Drawings.HealthBg.Filled = true
    espObj.Drawings.HealthBg.Color = Color3.new(0, 0, 0)
    espObj.Drawings.HealthBg.ZIndex = 1
    
    espObj.Drawings.HealthBar.Filled = true
    espObj.Drawings.HealthBar.ZIndex = 2
    
    local hl = Instance.new("Highlight")
    hl.Name = "Zeta_Chams"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    espObj.Highlight = hl

    function espObj:HideAll()
        if self.DrawingsVisible then
            self.DrawingsVisible = false
            for _, drawing in pairs(self.Drawings) do
                drawing.Visible = false
            end
        end
        if self.Highlight and self.Highlight.Enabled then
            self.Highlight.Enabled = false
        end
    end

    function espObj:Destroy()
        self:HideAll()
        for _, drawing in pairs(self.Drawings) do
            drawing:Remove()
        end
        if self.Highlight then
            self.Highlight:Destroy()
        end
        table.clear(self.Parts)
    end

    function espObj:GetPart(partName)
        local char = self.Target.Character
        if not char then return nil end
        if self.Character ~= char then
            self.Character = char
            table.clear(self.Parts)
        end
        local cached = self.Parts[partName]
        if cached then return cached end
        local found = char:FindFirstChild(partName)
        if found then self.Parts[partName] = found end
        return found
    end

    return espObj
end

local function AddPlayer(player)
    if player == LocalPlayer then return end
    if not Zeta.Cache[player] then
        Zeta.Cache[player] = CreateESPObject(player, "Player")
    end
end

local function RemovePlayer(player)
    if Zeta.Cache[player] then
        Zeta.Cache[player]:Destroy()
        Zeta.Cache[player] = nil
    end
end

function Zeta:AddObject(instance, name, color)
    if not self.Cache[instance] then
        self.Cache[instance] = CreateESPObject(instance, "Object", name, color)
    end
end

function Zeta:RemoveObject(instance)
    if self.Cache[instance] then
        self.Cache[instance]:Destroy()
        self.Cache[instance] = nil
    end
end

function Zeta:AddTargetTeam(team)
    self.Settings.TargetTeams[team] = true
end

function Zeta:RemoveTargetTeam(team)
    self.Settings.TargetTeams[team] = nil
end

function Zeta:ClearTargetTeams()
    table.clear(self.Settings.TargetTeams)
end

local function UpdateESP()
    local CurrentCamera = Workspace.CurrentCamera
    if not CurrentCamera then return end

    local viewportSize = CurrentCamera.ViewportSize
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    local currentChromaColor = Color3.fromHSV(os.clock() % 5 / 5, 1, 1)
    local masterEnabled = Zeta.Settings.Enabled
    local hasTargetTeams = next(Zeta.Settings.TargetTeams) ~= nil

    for target, espObj in pairs(Zeta.Cache) do
        if not masterEnabled then
            espObj:HideAll()
            continue
        end

        local rootPart, head, displayName, maxHealth, currentHealth
        local hlTarget = nil

        if espObj.Type == "Player" then
            local player = target
            local character = player.Character
            
            if not character or not Zeta.Settings.Filter(player) then
                espObj:HideAll()
                continue
            end
            
            if hasTargetTeams and not Zeta.Settings.TargetTeams[player.Team] then
                espObj:HideAll()
                continue
            end

            local humanoid = espObj:GetPart("Humanoid")
            rootPart = espObj:GetPart("HumanoidRootPart")
            head = espObj:GetPart("Head")

            if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
                espObj:HideAll()
                continue
            end

            displayName = Zeta.Settings.Text.UseDisplayName and player.DisplayName or player.Name
            maxHealth = humanoid.MaxHealth
            currentHealth = humanoid.Health
            hlTarget = character
        elseif espObj.Type == "Object" then
            if not target or not target.Parent then
                espObj:Destroy()
                Zeta.Cache[target] = nil
                continue
            end
            
            rootPart = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")) or target
            head = rootPart
            
            if not rootPart then
                espObj:HideAll()
                continue
            end
            
            displayName = espObj.CustomName or target.Name
            maxHealth = 0
            currentHealth = 0
            hlTarget = target
        end

        local distance = myRoot and (rootPart.Position - myRoot.Position).Magnitude or 0
        if distance > Zeta.Settings.MaxDistance then
            espObj:HideAll()
            continue
        end

        local rootPos, onScreen = CurrentCamera:WorldToViewportPoint(rootPart.Position)
        if not onScreen then
            espObj:HideAll()
            continue
        end

        local topPos, bottomPos
        if espObj.Type == "Player" then
            topPos = CurrentCamera:WorldToViewportPoint(head.Position + HEAD_OFFSET)
            bottomPos = CurrentCamera:WorldToViewportPoint(rootPart.Position - ROOT_OFFSET)
        else
            local size = rootPart:IsA("BasePart") and rootPart.Size or Vector3.new(2, 2, 2)
            topPos = CurrentCamera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, size.Y / 2, 0))
            bottomPos = CurrentCamera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, size.Y / 2, 0))
        end
        
        local height = math.abs(topPos.Y - bottomPos.Y)
        local width = height / 2
        local boxPos = Vector2.new(topPos.X - width / 2, topPos.Y)

        local d = espObj.Drawings
        espObj.DrawingsVisible = true

        if Zeta.Settings.Chams.Enabled then
            local hl = espObj.Highlight
            if hl.Parent ~= hlTarget then hl.Parent = hlTarget end
            if not hl.Enabled then hl.Enabled = true end
            local chamColor = espObj.CustomColor or (Zeta.Settings.Chams.Chroma and currentChromaColor or Zeta.Settings.Chams.Color)
            if hl.FillColor ~= chamColor then
                hl.FillColor = chamColor
                hl.OutlineColor = chamColor
            end
        else
            if espObj.Highlight.Enabled then espObj.Highlight.Enabled = false end
        end

        if Zeta.Settings.Box.Enabled then
            d.Box.Visible = true
            d.Box.Size = Vector2.new(width, height)
            d.Box.Position = boxPos
            d.Box.Color = espObj.CustomColor or (Zeta.Settings.Box.Chroma and currentChromaColor or Zeta.Settings.Box.Color)
        else
            d.Box.Visible = false
        end

        if Zeta.Settings.Box.HeadCircle.Enabled and espObj.Type == "Player" then
            local circleRadius = height / 6 
            local headScreenPos = CurrentCamera:WorldToViewportPoint(head.Position - CIRCLE_OFFSET)
            
            d.HeadCircle.Visible = true
            d.HeadCircle.Position = Vector2.new(headScreenPos.X, headScreenPos.Y)
            d.HeadCircle.Radius = circleRadius
            d.HeadCircle.Color = Zeta.Settings.Box.HeadCircle.Chroma and currentChromaColor or Zeta.Settings.Box.HeadCircle.Color
        else
            d.HeadCircle.Visible = false
        end

        if Zeta.Settings.Text.Enabled then
            d.NameText.Visible = true
            d.NameText.Text = displayName
            d.NameText.Position = Vector2.new(topPos.X, topPos.Y - d.NameText.TextBounds.Y - 5)
            d.NameText.Color = espObj.CustomColor or (Zeta.Settings.Text.Chroma and currentChromaColor or Zeta.Settings.Text.Color)
        else
            d.NameText.Visible = false
        end

        if Zeta.Settings.Tracers.Enabled then
            d.Tracer.Visible = true
            
            local origin = Vector2.new(viewportSize.X / 2, viewportSize.Y)
            local currentOriginSetting = Zeta.Settings.Tracers.Origin
            if currentOriginSetting == "Top" then
                origin = Vector2.new(viewportSize.X / 2, 0)
            elseif currentOriginSetting == "Center" then
                origin = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)
            end

            d.Tracer.From = origin
            d.Tracer.To = Vector2.new(topPos.X, topPos.Y) 
            d.Tracer.Color = espObj.CustomColor or (Zeta.Settings.Tracers.Chroma and currentChromaColor or Zeta.Settings.Tracers.Color)
        else
            d.Tracer.Visible = false
        end

        if Zeta.Settings.HealthBar.Enabled and espObj.Type == "Player" then
            local healthPercent = 0
            if maxHealth > 0 then
                healthPercent = math.clamp(currentHealth / maxHealth, 0, 1)
            end
            
            local healthColor = Color3.new(1 - healthPercent, healthPercent, 0)

            local barX = boxPos.X - 8 
            local barY = boxPos.Y
            local barHeight = height * healthPercent

            d.HealthBg.Visible = true
            d.HealthBg.Size = Vector2.new(4, height + 2)
            d.HealthBg.Position = Vector2.new(barX - 1, barY - 1)

            d.HealthBar.Visible = true
            d.HealthBar.Size = Vector2.new(2, barHeight)
            d.HealthBar.Position = Vector2.new(barX, barY + (height - barHeight))
            d.HealthBar.Color = healthColor
        else
            d.HealthBg.Visible = false
            d.HealthBar.Visible = false
        end
    end
end

function Zeta:Load()
    if self.Loaded then return end
    self.Loaded = true

    for _, player in ipairs(Players:GetPlayers()) do
        AddPlayer(player)
    end

    table.insert(self.Connections, Players.PlayerAdded:Connect(AddPlayer))
    table.insert(self.Connections, Players.PlayerRemoving:Connect(RemovePlayer))
    table.insert(self.Connections, RunService.RenderStepped:Connect(UpdateESP))
end

function Zeta:Unload()
    if not self.Loaded then return end
    self.Loaded = false

    for _, conn in ipairs(self.Connections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    self.Connections = {}

    for target, espObj in pairs(self.Cache) do
        espObj:Destroy()
    end
    self.Cache = {}
end

return Zeta
