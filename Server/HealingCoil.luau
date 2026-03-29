local Players = game:GetService("Players")
local Tool = script.Parent

local TweenService = game:GetService("TweenService")

local tool = script.Parent
local coil = tool.HealingCoil

local animationsFolder = tool.Animations
local animationController = tool.AnimationController
local coilEquipAnimation = animationsFolder.CoilEquip

local particle
local active = false

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
end)

tool.Unequipped:Connect(function()
	coil.Transparency = 1
end)

local function GetCharacter(Descendant)
	-- Returns the Player and Charater that a descendent is part of, if it is part of one.
	-- @param Descendant A child of the potential character. 

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

-- Connect events for player interaction
Tool.Equipped:connect(function()
	local Character, Player = GetCharacter(Tool)

	if Character then
		active = true
		
		while task.wait(1) do
			if active == false then break end
			
			local hum:Humanoid = Character:findFirstChildOfClass("Humanoid")
			
			if hum and hum.Health > 0 then
				hum:TakeDamage(-2.5)
				if hum.Health > 100 then
					hum.Health = 100
				end
			else
				break
			end
		end
		
	else
		warn("[HealingCoil] - Somehow inexplicity failed to retrieve character")
	end
end)

Tool.Unequipped:connect(function()
	active = false
end)

Tool.Destroying:Connect(function()
	active = false
end)
