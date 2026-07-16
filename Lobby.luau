if not game:IsLoaded() then 
	game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Rooms = workspace.Rooms
local Quickstart = ReplicatedStorage.Util.Net["RE/Quickstart"]

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local function JoinEmptyRoom()
	for _, room in Rooms:GetChildren() do
		local Text = room.Sign.PlayerCount.UI.Label.Text
    	if tonumber(string.sub(Text, 1, 1)) == 0 then
        	firetouchinterest(Character.PrimaryPart, room.Touch, 0)
        	return true
        end
    end

    return false
end

while not LocalPlayer:HasTag("InRoom") do
    JoinEmptyRoom()
    task.wait(0.5)
end

if LocalPlayer:HasTag("Leader") then
    Quickstart:FireServer()
end
