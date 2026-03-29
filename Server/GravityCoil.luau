local Players                     = game:GetService("Players")
local Tool                        = script.Parent

local GravityAccelerationConstant = 196.2 -- For every 20 studs is one meter on ROBLOX. 9.81 is the common accepted acceleration of gravity per a kg on earth, and is used on ROBLOX
local PercentGravity              = 0.5      -- Percentage of countered acceleration due to gravity by the coil. 

-- @author Quenty
-- A rewritten gravity coil script designed for understanding and reliability

local TweenService = game:GetService("TweenService")

local tool = script.Parent
local coil = tool.GravityCoil

local animationsFolder = tool.Animations
local animationController = tool.AnimationController
local coilEquipAnimation = animationsFolder.CoilEquip

local particle

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

local function WaitForChild(Parent, Name, TimeLimit)
	-- Waits for a child to appear. Not efficient, but it shoudln't have to be. It helps with debugging. 
	-- Useful when ROBLOX lags out, and doesn't replicate quickly.
	-- @param TimeLimit If TimeLimit is given, then it will return after the timelimit, even if it hasn't found the child.

	assert(Parent ~= nil, "Parent is nil")
	assert(type(Name) == "string", "Name is not a string.")

	local Child     = Parent:FindFirstChild(Name)
	local StartTime = tick()
	local Warned    = false

	while not Child and Parent do
		wait(0)
		Child = Parent:FindFirstChild(Name)
		if not Warned and StartTime + (TimeLimit or 5) <= tick() then
			Warned = true
			warn("Infinite yield possible for WaitForChild(" .. Parent:GetFullName() .. ", " .. Name .. ")")
			if TimeLimit then
				return Parent:FindFirstChild(Name)
			end
		end
	end

	if not Parent then
		warn("Parent became nil.")
	end

	return Child
end


local function CallOnChildren(Instance, FunctionToCall)
	-- Calls a function on each of the children of a certain object, using recursion.  

	FunctionToCall(Instance)

	for _, Child in next, Instance:GetChildren() do
		CallOnChildren(Child, FunctionToCall)
	end
end

local function GetBricks(StartInstance)
	-- Returns a list of bricks (will include StartInstance)

	local List = {}

	CallOnChildren(StartInstance, function(Item)
		if Item:IsA("BasePart") then
			List[#List+1] = Item;
		end
	end)

	return List
end

--[[Maid
Manages the cleaning of events and other things.
 
API:
	HireMaid()                        Returns a new Maid object.
 
	Maid[key] = (function)            Adds a task to perform when cleaning up.
	Maid[key] = (event connection)    Manages an event connection. Anything that isn't a function is assumed to be this.
	Maid[key] = nil                   Removes a named task. If the task is an event, it is disconnected.
 
	Maid:GiveTask(task)               Same as above, but uses an incremented number as a key.
	Maid:DoCleaning()                 Disconnects all managed events and performs all clean-up tasks.
]]
local MakeMaid do
	local index = {
		GiveTask = function(self, task)
			local n = #self.Tasks+1
			self.Tasks[n] = task
			return n
		end;
		DoCleaning = function(self)
			local tasks = self.Tasks
			for name,task in pairs(tasks) do
				if type(task) == 'function' then
					task()
				else
					task:disconnect()
				end
				tasks[name] = nil
			end
			-- self.Tasks = {}
		end;
	};

	local mt = {
		__index = function(self, k)
			if index[k] then
				return index[k]
			else
				return self.Tasks[k]
			end
		end;
		__newindex = function(self, k, v)
			local tasks = self.Tasks
			if v == nil then
				-- disconnect if the task is an event
				if type(tasks[k]) ~= 'function' and tasks[k] then
					tasks[k]:disconnect()
				end
			elseif tasks[k] then
				-- clear previous task
				self[k] = nil
			end
			tasks[k] = v
		end;
	}

	function MakeMaid()
		return setmetatable({Tasks={},Instances={}},mt)
	end
end

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

--- Load and create constants
local AntiGravityForce      = Instance.new("BodyForce")
AntiGravityForce.Name       = "GravityCoilEffect"
AntiGravityForce.Archivable = false

local Handle           = WaitForChild(Tool, "Handle")
local CoilSound        = WaitForChild(Handle, "CoilSound")
local GravityMaid      = MakeMaid() -- Will contain and maintain events

local function UpdateGravityEffect(Character)
	-- Updates the AntiGravityForce to match the force of gravity on the character

	local Bricks
	if Character:IsDescendantOf(game) and Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart:IsA("BasePart") then
		local BasePart = Character.HumanoidRootPart
		Bricks         = BasePart:GetConnectedParts(true) -- Recursive
	else
		warn("[UpdateGravityEffect] - Character failed to have a HumanoidRootPart or something")
		Bricks = GetBricks(Character)
	end

	local TotalMass = 0

	-- Calculate total mass of player
	for _, Part in pairs(Bricks) do
		TotalMass = TotalMass + Part:GetMass()
	end

	-- Force = Mass * Acceleration
	local ForceOnCharacter         = GravityAccelerationConstant * TotalMass
	local CounteringForceMagnitude = PercentGravity * ForceOnCharacter

	-- Set the actual value...
	AntiGravityForce.force = Vector3.new(0, CounteringForceMagnitude, 0)
end


-- Connect events for player interaction
Tool.Equipped:connect(function()
	local Character, Player = GetCharacter(Tool)

	if Character then
		-- Connect events to recalculate gravity when hats are added or removed. Of course, this is not a perfect solution,
		-- as connected parts are not necessarily part of the character, but ROBLOX has no API to handle the changing of joints, and
		-- scanning the whole game for potential joints is really not worth the efficiency cost. 
		GravityMaid.DescendantAddedConnection = Character.DescendantAdded:connect(function()
			UpdateGravityEffect(Character)
		end)

		GravityMaid.DecendantRemovingConnection = Character.DescendantRemoving:connect(function()
			UpdateGravityEffect(Character)
		end)

		UpdateGravityEffect(Character)
		-- Add in the force
		AntiGravityForce.Parent = Handle
	else
		warn("[GravityCoil] - Somehow inexplicity failed to retrieve character")
	end
end)

Tool.Unequipped:connect(function()
	-- Remove force and clean up events
	AntiGravityForce.Parent = nil
	GravityMaid:DoCleaning()
end)
