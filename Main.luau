if not game:IsLoaded() then 
    game.Loaded:Wait() 
end

local AnimalHospital = {}

local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local CheckIn = workspace.Misc.CheckIn
local MedicalRooms = workspace.Rooms.Medical
local Camera = CheckIn.Camera
local Computer = CheckIn.Computer
local Printer = CheckIn.Printer

local NPCsFolder = workspace.NPCs

local Tasks = {}

-- Helpers 
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

function AnimalHospital.FireProximityPrompt(proximityPrompt)
    local Adornee = proximityPrompt.Parent

    if Adornee:IsA("Model") then
        Adornee = Adornee.PrimaryPart or Adornee:FindFirstChildWhichIsA("BasePart")
    end

    Character:PivotTo(Adornee.Position)

    task.wait(0.1)

    fireproximityprompt(proximityPrompt)
end

function AnimalHospital.CheckInInstanceAdded(instance)
    if instance.Name == "Form" or instance.Name == "PrintedBadge" then
        AnimalHospital.FireProximityWhenEnabled(instance.PP)
    end
end

function AnimalHospital.NPCAdded(instance)
    AnimalHospital.FireProximityWhenEnabled(instance.PP)
end

function AnimalHospital.RoomAdded(room)
    local Minigame = room.Minigame
    
    local Analyzer = Minigame.Analyzer
    local Computer = Minigame.Computer

    AnimalHospital.FireProximityWhenEnabled(Analyzer.PP)
    AnimalHospital.FireProximityWhenEnabled(Computer.PP)
end

function AnimalHospital.AddTask(func, priority)
    local task = { func = func, priority = priority }
    table.insert(Tasks, task)

    return task
end

function AnimalHospital.RemoveTask(task)
    for i, t in ipairs(Tasks) do
        if t == task then
            table.remove(Tasks, i)
            break
        end
    end
end

function AnimalHospital.FireProximityWhenEnabled(proximityPrompt)
    local task
    local enableChangedConnection
    local parentChangedConnection

    local function EnabledChanged()
        if proximityPrompt.Enabled then
            task = AnimalHospital.AddTask(function()
                AnimalHospital.FireProximityPrompt(proximityPrompt)
            end, 1)
        else
            if task then
                AnimalHospital.RemoveTask(task)
                task = nil
            end
        end
    end

    local function Cleanup()
        if task then
            AnimalHospital.RemoveTask(task)
            task = nil
        end
        if enableChangedConnection then
            enableChangedConnection:Disconnect()
            enableChangedConnection = nil
        end
        if parentChangedConnection then
            parentChangedConnection:Disconnect()
            parentChangedConnection = nil
        end
    end

    enableChangedConnection = proximityPrompt:GetPropertyChangedSignal("Enabled"):Connect(EnabledChanged)
    parentChangedConnection = proximityPrompt:GetPropertyChangedSignal("Parent"):Connect(function()
        if not proximityPrompt.Parent then
            Cleanup()
        end
    end)

    return Cleanup
end

function AnimalHospital.ProcessTasks()
    while true do
        if #Tasks > 0 then
            table.sort(Tasks, function(a, b)
                return a.priority > b.priority
            end)

            local taskToRun = Tasks[1]
            taskToRun.func()
        end

        task.wait(0.1)
    end
end

function AnimalHospital.Init()
    AnimalHospital.FireProximityWhenEnabled(Camera.PP)
    AnimalHospital.FireProximityWhenEnabled(Computer.PP)
    AnimalHospital.FireProximityWhenEnabled(Printer.PP)
    SafeChildAdded(NPCsFolder, AnimalHospital.NPCAdded)
    SafeChildAdded(CheckIn, AnimalHospital.CheckInInstanceAdded)
    ForEachChild(MedicalRooms, AnimalHospital.RoomAdded)

    task.spawn(AnimalHospital.ProcessTasks)
end

AnimalHospital.Init()