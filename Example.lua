local Fever = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Fever/refs/heads/main/Library.lua"))()
local Zeta = loadstring(game:HttpGet("https://raw.githubusercontent.com/d1versity/Zeta/refs/heads/main/Library.lua"))()

Zeta:Load()

local Window = Fever:CreateWindow("Zeta ESP Controller", true)

local MainTab = Window:CreateTab("Main Settings")

MainTab:CreateParagraph("Zeta ESP", "Master controls for player visuals.")

MainTab:CreateToggle("Master ESP Enabled", Zeta.Settings.Enabled, function(state)
    Zeta.Settings.Enabled = state
end)

MainTab:CreateSlider("Max Render Distance", 50, 2000, Zeta.Settings.MaxDistance, function(value)
    Zeta.Settings.MaxDistance = value
end)

MainTab:CreateToggle("Show Boxes", Zeta.Settings.Box.Enabled, function(state)
    Zeta.Settings.Box.Enabled = state
end)

MainTab:CreateToggle("Show Head Circles", Zeta.Settings.Box.HeadCircle.Enabled, function(state)
    Zeta.Settings.Box.HeadCircle.Enabled = state
end)

MainTab:CreateToggle("Show Names", Zeta.Settings.Text.Enabled, function(state)
    Zeta.Settings.Text.Enabled = state
end)

MainTab:CreateToggle("Show Health Bars", Zeta.Settings.HealthBar.Enabled, function(state)
    Zeta.Settings.HealthBar.Enabled = state
end)

local ExtraTab = Window:CreateTab("Tracers & Chams")

ExtraTab:CreateToggle("Enable Tracers", Zeta.Settings.Tracers.Enabled, function(state)
    Zeta.Settings.Tracers.Enabled = state
end)

ExtraTab:CreateDropdown("Tracer Origin", {"Bottom", "Center", "Top"}, Zeta.Settings.Tracers.Origin, function(selected)
    Zeta.Settings.Tracers.Origin = selected
end)

ExtraTab:CreateToggle("Enable Chams (Highlights)", Zeta.Settings.Chams.Enabled, function(state)
    Zeta.Settings.Chams.Enabled = state
end)

local ColorTab = Window:CreateTab("Colors & Chroma")

ColorTab:CreateParagraph("Chroma Mode", "Overrides static colors with an RGB rainbow effect.")

ColorTab:CreateToggle("Rainbow Box & Text", false, function(state)
    Zeta.Settings.Box.Chroma = state
    Zeta.Settings.Text.Chroma = state
    Zeta.Settings.Box.HeadCircle.Chroma = state
end)

ColorTab:CreateToggle("Rainbow Tracers & Chams", false, function(state)
    Zeta.Settings.Tracers.Chroma = state
    Zeta.Settings.Chams.Chroma = state
end)

ColorTab:CreateLabel("Static Colors:")

ColorTab:CreateColorPicker("Box Color", Zeta.Settings.Box.Color, function(color)
    Zeta.Settings.Box.Color = color
    Zeta.Settings.Box.HeadCircle.Color = color
end)

ColorTab:CreateColorPicker("Text Color", Zeta.Settings.Text.Color, function(color)
    Zeta.Settings.Text.Color = color
end)

ColorTab:CreateColorPicker("Tracer Color", Zeta.Settings.Tracers.Color, function(color)
    Zeta.Settings.Tracers.Color = color
end)

ColorTab:CreateColorPicker("Cham Color", Zeta.Settings.Chams.Color, function(color)
    Zeta.Settings.Chams.Color = color
end)

local AdvTab = Window:CreateTab("Advanced")

AdvTab:CreateParagraph("Custom Objects", "Zeta can track non-player objects like dropped items.")

AdvTab:CreateButton("Track Random Spawn Part", function()
    local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation")
    if spawnLocation then
        Zeta:AddObject(spawnLocation, "Spawn Point", Color3.fromRGB(0, 255, 0))
    end
end)

AdvTab:CreateButton("Clear Custom Objects", function()
    local spawnLocation = workspace:FindFirstChildWhichIsA("SpawnLocation")
    if spawnLocation then
        Zeta:RemoveObject(spawnLocation)
    end
end)

AdvTab:CreateLabel("Script Management")

AdvTab:CreateButton("Unload Everything", function()
    Zeta:Unload()
    Fever:Unload()
end)

Window:CreateSettingsTab()
