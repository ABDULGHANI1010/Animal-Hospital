if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local CheckIn = workspace.Misc.CheckIn
local MedicalRooms = workspace.Rooms.Medical

local Camera = CheckIn.Camera
local Computer = CheckIn.Computer
local Printer = CheckIn.Printer

local NPCsFolder = workspace.NPCs

local function FireWhenEnabled(proximityPrompt)
    proximityPrompt.RequiresLineOfSight = false
    
    local function EnabledChanged()
        if proximityPrompt.Enabled then
            fireproximityprompt(proximityPrompt)
        end
    end
    
    proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(EnabledChanged)
    EnabledChanged()
end

local function CheckInChildAdded(child)
    if child.Name == "Form" or child.Name == "PrintedBadge" then
        repeat 
            FireProximityPrompt(child:WaitForChild("PP"))
            task.wait()
        until child.Parent == nil
    end
end

local function NPCAdded(npc)
    FireWhenEnabled(npc:WaitForChild("PP"))
    npc.ChildAdded:Connect(function(child)
        print("child added to npc: ", child.Name)
    end)
end

local function Room(room)
    local Minigame = room.Minigame
    
    local Analyzer = Minigame.Analyzer
    local Computer = Minigame.Computer

    FireWhenEnabled(Analyzer.PP)
    FireWhenEnabled(Computer.PP)
end

local function ForEachChild(parent, callback)
    for _, child in parent:GetChildren() do
        task.spawn(callback, child)
    end
end

local function SafeChildAdded(parent, callback)
    local Connection = parent.ChildAdded:Connect(callback)
    ForEachChild(parent, callback)

    return function() Connection:Disconnect() end
end

FireWhenEnabled(Camera.PP)
FireWhenEnabled(Computer.PP)
FireWhenEnabled(Printer.PP)

SafeChildAdded(NPCsFolder, NPCAdded)
SafeChildAdded(CheckIn, CheckInChildAdded)
ForEachChild(MedicalRooms, Room)
