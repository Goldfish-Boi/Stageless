local module = {}

local dataStoreService = game:GetService("DataStoreService")
local players = game:GetService("Players")
local replicatedStorage = game.ReplicatedStorage

local playerDatastore = dataStoreService:GetDataStore("PlayerData")
local towerDatastore = dataStoreService:GetDataStore("TowerData")
local robuxLeaderboard = dataStoreService:GetOrderedDataStore("RobuxLeaderboard")

local towerInfo = require(script.Parent.TowerInfo)

local events = replicatedStorage.Communicators
local winEvent = events.Remotes.Events.OnTowerWin

PlayerDataTable = {}
TowerData = nil

events.Remotes.Functions.RequestData.OnServerInvoke = function(plr, Type)
	if PlayerDataTable[plr.UserId] == nil or PlayerDataTable[plr.UserId]["Settings"] == nil or PlayerDataTable[plr.UserId]["MiscCompletions"] == nil or PlayerDataTable[plr.UserId]["TowerCompletions"] == nil or TowerData == nil then
		repeat
			task.wait()
		until PlayerDataTable[plr.UserId] ~= nil and PlayerDataTable[plr.UserId]["Settings"] ~= nil and PlayerDataTable[plr.UserId]["MiscCompletions"] ~= nil and PlayerDataTable[plr.UserId]["TowerCompletions"] ~= nil and TowerData ~= nil
	end
	
	if Type == "All" then
		return PlayerDataTable[plr.UserId]
	elseif Type == "TowerData"then
		return TowerData
	elseif Type == "Towers" then
		return PlayerDataTable[plr.UserId]["TowerCompletions"]
	elseif Type == "CompletedTowers" then
		local completedTowers = {}
		
		for i, item in pairs(PlayerDataTable[plr.UserId]["TowerCompletions"]) do
			if item["Wins"] > 0 and towerInfo[i] ~= nil then
				table.insert(completedTowers, i)
			end
		end
		
		return completedTowers
	elseif Type == "Settings" then
		return PlayerDataTable[plr.UserId]["Settings"]
	elseif Type == "MiscCompletions" then
		return PlayerDataTable[plr.UserId]["MiscCompletions"]
	elseif Type == "RobuxLeaderboard" then
		return robuxLeaderboard:GetSortedAsync(false, 100, 5):GetCurrentPage()
	end
end

function module.LoadTowerData()
	local success, Tcompletions = pcall(function()
		return towerDatastore:GetAsync("Towers")
	end)
	
	TowerData = Tcompletions
	
	if TowerData == nil then TowerData = {} end
	
	for i, v in pairs(towerInfo) do
		if TowerData[tostring(i)] == nil then TowerData[tostring(i)] = {} end
		
		if TowerData[tostring(i)]["GlobalAttempts"] == nil then TowerData[tostring(i)]["GlobalAttempts"] = 0 end
		if TowerData[tostring(i)]["GlobalWins"] == nil then TowerData[tostring(i)]["GlobalWins"] = 0 end
		if TowerData[tostring(i)]["GlobalTimeSpent"] == nil then TowerData[tostring(i)]["GlobalTimeSpent"] = 0 end
		if TowerData[tostring(i)]["GlobalNoHitWins"] == nil then TowerData[tostring(i)]["GlobalNoHitWins"] = 0 end
	end
	
	events.Bindables.Events.IncrementGlobalData.Event:Connect(function(Tower, Type, Time, NoHit:boolean?)
		if TowerData[tostring(Tower)] then
			if Type == "Attempt" then
				TowerData[tostring(Tower)]["GlobalAttempts"] += 1
			elseif Type == "Win" then
				if NoHit == true then
					TowerData[tostring(Tower)]["GlobalNoHitWins"] += 1
				else
					TowerData[tostring(Tower)]["GlobalWins"] += 1
				end
			end
			
			if Time then
				TowerData[tostring(Tower)]["GlobalTimeSpent"] += Time
			end
			
			print(TowerData)
			
			local success, err = pcall(function()
				towerDatastore:UpdateAsync("Towers", function() return TowerData end)
			end)
			
			if err then
				warn(err)
			end
		end
	end)
	
	--towerDatastore:SetAsync("Towers", TowerData)
end

function module.LoadPlayerData(plr:Player)
	local success, Tcompletions = pcall(function()
		return playerDatastore:GetAsync(plr.UserId)
	end)
	
	if not success then
		plr:Kick("Failed to load data. Kicking as to not cause issues")
	end
	
	local PlayerData = Tcompletions
	
	if PlayerData == nil then PlayerData = {} end
	
	if PlayerData["TowerCompletions"] == nil then PlayerData["TowerCompletions"] = {} end
	
	for i, v in pairs(towerInfo) do
		if PlayerData["TowerCompletions"][tostring(i)] == nil then PlayerData["TowerCompletions"][tostring(i)] = {} end

		if PlayerData["TowerCompletions"][tostring(i)]["Attempts"] == nil then PlayerData["TowerCompletions"][tostring(i)]["Attempts"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["Wins"] == nil then PlayerData["TowerCompletions"][tostring(i)]["Wins"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["TimeSpent"] == nil then PlayerData["TowerCompletions"][tostring(i)]["TimeSpent"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["BestTime"] == nil then PlayerData["TowerCompletions"][tostring(i)]["BestTime"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["BestBoostTime"] == nil then PlayerData["TowerCompletions"][tostring(i)]["BestBoostTime"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["BestVMTime"] == nil then PlayerData["TowerCompletions"][tostring(i)]["BestVMTime"] = 0 end
		if PlayerData["TowerCompletions"][tostring(i)]["NoHitWins"] == nil then PlayerData["TowerCompletions"][tostring(i)]["NoHitWins"] = 0 end
	end
	
	if PlayerData["MiscCompletions"] == nil then PlayerData["MiscCompletions"] = {} end
	if PlayerData["Settings"] == nil then PlayerData["Settings"] = {} end
	if PlayerData["RobuxSpent"] == nil then PlayerData["RobuxSpent"] = 0 end
	--if PlayerData["Kredits"] == nil then PlayerData["Kredits"] = 0 end
	if PlayerData["TotalTime"] == nil then PlayerData["TotalTime"] = 0 end
	if PlayerData["DataVersion"] == nil then PlayerData["DataVersion"] = "v1.0.0" end
	
	PlayerDataTable[plr.UserId] = PlayerData
	
	print(PlayerDataTable)
	
	events.Remotes.Events.AddDataKey.OnServerEvent:Connect(function(player, stringToAdd, remove:boolean?)
		if player ~= plr then return end
		
		if remove == true then
			local stringDetected = table.find(PlayerData["MiscCompletions"], stringToAdd)
			
			if stringDetected then
				table.remove(PlayerData["MiscCompletions"], stringDetected)
			end
			
			return
		end
		
		if table.find(PlayerData["MiscCompletions"], stringToAdd) then return end
		
		table.insert(PlayerData["MiscCompletions"], stringToAdd)
		
		PlayerDataTable[plr.UserId] = PlayerData
		
		events.Remotes.Events.PlayerDataUpdated:FireClient(player, "MiscCompletions")
	end)
	
	events.Bindables.Events.UpdatePlayerData.Event:Connect(function(player, Tower, Type, Time, Data1)
		if player ~= plr then return end
		
		if Tower then
			if PlayerData["TowerCompletions"][tostring(Tower)] then
				if Type == "Attempt" then
					PlayerData["TowerCompletions"][tostring(Tower)]["Attempts"] += 1
				elseif Type == "Win" then
					if PlayerDataTable[plr.UserId]["Settings"]["NoHitMode"] == false then
						PlayerData["TowerCompletions"][tostring(Tower)]["Wins"] += 1
					else
						PlayerData["TowerCompletions"][tostring(Tower)]["NoHitWins"] += 1
					end	
				end

				if Time then
					PlayerData["TowerCompletions"][tostring(Tower)]["TimeSpent"] += Time
					
					if Data1 == "" then
						if Time > PlayerData["TowerCompletions"][tostring(Tower)]["BestTime"] then
							PlayerData["TowerCompletions"][tostring(Tower)]["BestTime"] = Time
						end
					elseif Data1 == "Boost" then
						if Time > PlayerData["TowerCompletions"][tostring(Tower)]["BestBoostTime"] then
							PlayerData["TowerCompletions"][tostring(Tower)]["BestBoostTime"] = Time
						end
					elseif Data1 == "VM" then
						if Time > PlayerData["TowerCompletions"][tostring(Tower)]["BestVMTime"] then
							PlayerData["TowerCompletions"][tostring(Tower)]["BestVMTime"] = Time
						end
					end
				end
			end
		else
			if Type == "Robux" then
				PlayerData["RobuxSpent"] += Time
				robuxLeaderboard:IncrementAsync(plr.UserId, Time)
			elseif Type == "AddString" then
				if not table.find(PlayerData["MiscCompletions"], Time) then
					table.insert(PlayerData["MiscCompletions"], Time)
				end
			end
		end
		
		PlayerDataTable[plr.UserId] = PlayerData
		
		if Tower then
			events.Remotes.Events.PlayerDataUpdated:FireClient(player, "Tower")
		end
		
		if Type == "AddString" then
			events.Remotes.Events.PlayerDataUpdated:FireClient(player, "MiscCompletions")
		end
	end)
	
	events.Remotes.Events.UpdatePlayerDataClient.OnServerEvent:Connect(function(player, dataType, data1, data2)
		if player ~= plr then return end
		
		if dataType == "Settings" then
			PlayerData[dataType] = data1
			events.Remotes.Events.PlayerDataUpdated:FireClient(player, "Settings")
		elseif dataType == "Towers" then
			if data2["Wins"] then
				PlayerData["TowerCompletions"][data1]["Wins"] += 1
			end
			if data2["Attempts"] then
				PlayerData["TowerCompletions"][data1]["Attempts"] += 1
			end
		elseif dataType == "Robux" then
			PlayerData["RobuxSpent"] += data1
			robuxLeaderboard:IncrementAsync(plr.UserId, data1)
		end
	end)
	
	--[[winEvent.OnServerEvent:Connect(function(winingPlr, towerName, towerDif)
		if towerDif == "TowerRush" then
			if table.find(PlayerData["MiscCompletions"], towerName) == nil then
				table.insert(PlayerData["MiscCompletions"], towerName)
			end
		else
			if table.find(PlayerData["TowerCompletions"], towerName) == nil then
				table.insert(PlayerData["TowerCompletions"], towerName)
			end
		end
	end)]]--

	--towerCompletions:SetAsync(plr.UserId, {})

	--[[for i, item in ipairs(PlayerData) do
		print(item)
	end]]--

	players.PlayerRemoving:Connect(function(p)
		if p ~= plr then return end
		
		if plr.leaderstats then
			PlayerData["TotalTime"] = PlayerData["TotalTime"] + plr.leaderstats["Time"].Value
		end
		
		local success2, error = pcall(function()
			playerDatastore:SetAsync(plr.UserId, PlayerData)
			
			PlayerData = nil
			PlayerDataTable[plr.UserId] = nil
		end)
	end)
end

game:BindToClose(function()
	local success, error = pcall(function()
		for i, playerData in pairs(PlayerDataTable) do
			playerDatastore:SetAsync(i, PlayerData)

			PlayerData = nil
		end
	end)
end)

function module.CheckCompletion(towerName)
	if table.find(PlayerData["TowerCompletions"], towerName) ~= nil then
		return true
	else
		return false
	end
end

function module.ReturnDataLength(plr, DataType)
	local count = 0
	
	if DataType == "Towers" then
		for i, item in pairs(PlayerDataTable[plr.UserId]["TowerCompletions"]) do
			if item["Wins"] > 0 then
				count += 1
			end
		end
	end
	
	if count == nil then
		count = 0
	end

	return count
end

return module
