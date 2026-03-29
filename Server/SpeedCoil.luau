local Players = game:GetService("Players")
local Tool = script.Parent

local TweenService = game:GetService("TweenService")

local tool = script.Parent
local coil = tool.SpeedCoil

local animationsFolder = tool.Animations
local animationController = tool.AnimationController
local coilEquipAnimation = animationsFolder.CoilEquip

local particle
local hum

function GetCharacter(Descendant)
	local Charater = Descendant
	local Player   = Players:GetPlayerFromCharacter(Charater)

	while not Player do
		if Charater.Parent then
			Charater = Charater.Parent
			Player   = Players:GetPlayerFromCharacter(Charater)
		else
			return nil
		end
	end

	-- Found the player, character must be true.
	return Charater, Player
end

tool.Equipped:Connect(function(mouse)
	local trail = coil:FindFirstChild("Trail", true)
	local coilEquip = animationController:LoadAnimation(coilEquipAnimation)

	coilEquip:Play()

	TweenService:Create(coil, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency = 0}):Play()
	
	task.spawn(function()
		task.wait(0.125)

		trail.Enabled = true

		task.wait(0.375)

		trail.Enabled = false
	end)
	
	local Character, Player = GetCharacter(Tool)

	if Character then

		hum = Character:FindFirstChildOfClass("Humanoid")

		if hum then
			hum.WalkSpeed = 25
		end
	else
		warn("[SpeedCoil] - Somehow inexplicity failed to retrieve character")
	end
end)

tool.Unequipped:Connect(function()
	coil.Transparency = 1
	
	if hum then
		hum.WalkSpeed = 16
	end
end)
