local marketplaceService = game:GetService("MarketplaceService")

local UserIds = {
	["1781558323"] = { -- Cheaty123457
		"HammerPlush",
	},
	["2564630611"] = { -- ICee_NOThing8
		"HammerPlush",
	},
	["635703648"] = { -- Pouwtjes
		"HammerPlush",
	},
	["1151597952"] = { -- liamisbasic
		"HammerPlush",
	},
	["3710892181"] = { -- Nevernormie
		"HammerPlush",
	},
	["649613928"] = { -- AboveAllSentinels
		"HammerPlush",
	},
	["4617108735"] = { -- XD_RobloxWasTaken
		"HammerPlush",
	},
	["1726601147"] = { -- Chloriini
		"HammerPlush",
	},
	["905876201"] = { -- ImTheMVP21v
		"HammerPlush",
	},
	["1726579200"] = { -- gammacxy
		"HammerPlush",
	},
	["140522081"] = { -- Detective_Memee
		"HammerPlush",
	},
	["3047026571"] = { -- Felixfame2000
		"HammerPlush",
	},
	["1151021248"] = { -- guilhermeGAMER38o
		"HammerPlush",
	},
}

local GamepassIds = {
	["Gravity Coil"] = 1031433733,
	["Speed Coil"] = 1677928100,
	["Healing Coil"] = 1676208753,
	["Vertical Mobility"] = 1032895955,
}

local active = false

script.Parent.MultiTowerServer.Initiated.Event:Connect(function()
	active = true
end)

local function CharacterAdded(char)
	local plr = game.Players:GetPlayerFromCharacter(char)
	
	for item, id in pairs(GamepassIds) do
		if marketplaceService:UserOwnsGamePassAsync(plr.UserId, id) == true then
			print(item .. " " .. id)
			local clonedItem = script:FindFirstChild(item):Clone()
			clonedItem.Parent = plr.Backpack
		end
	end
	
	for i, id in pairs(UserIds) do
		if plr.UserId == tonumber(i) then
			for i, item in pairs(id) do
				local clonedItem = script:FindFirstChild(item):Clone()
				clonedItem.Parent = plr.Backpack
			end
		end
	end
	
	if plr:IsInGroupAsync(15256687) == true then
		local clonedItem = script:FindFirstChild("Crystal"):Clone()
		clonedItem.Parent = plr.Backpack
	end
end

local function PlayerAdded(player)
	--Connect the event
	player.CharacterAdded:Connect(CharacterAdded)

	--Take care of when it already exists
	local char = player.Character
	if char then
		CharacterAdded(char)
	end
end

--Connect the event
game.Players.PlayerAdded:Connect(PlayerAdded)

--Take care of when it already exists
for i,v in pairs(game.Players:GetPlayers()) do
	PlayerAdded(v)
end
