local CheckIn = workspace.Misc.CheckIn

local Camera = CheckIn.Camera
local Computer = CheckIn.Computer
local Printer = CheckIn.Printer



local NPCs = workspace.NPCs
--local LouisKimura = NPCs["Louis Kimura"]

local function FireProximityPrompt(proximityPrompt)
    fireproximityprompt(proximityPrompt)
end

local function FireWhenEnabled(proximityPrompt)
    local function EnabledChanged()
        if proximityPrompt.Enabled then
            FireProximityPrompt(proximityPrompt)
        end
    end
    
    proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(EnabledChanged)
    EnabledChanged()
end

FireWhenEnabled(Camera.PP)
FireWhenEnabled(Computer.PP)
FireWhenEnabled(Printer.PP)

local function CheckInChildAdded(child)
    if child.Name == "Form" or child.Name == "PrintedBadge" then
        FireProximityPrompt(child.PP)
    end
end

CheckIn.ChildAdded:Connect(CheckInChildAdded)
for _, child in CheckIn:GetChildren() do
    task.spawn(CheckInChildAdded, child)
end
