local marketPlaceService = game:GetService("MarketplaceService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

local webhook = "https://webhook.lewisakura.moe/api/webhooks/[YOUR DISCORD WEBHOOK HERE]/[YOUR WEBHOOK KEY HERE]"

local donations = {
	[3518136186] = "5",
	[3518136706] = "10",
	[3518137212] = "25",
	[3518137569] = "50",
	[3518137986] = "100",
	[3518138391] = "250",
	[3518138950] = "500",
	[3518139384] = "1000",
	[3518140586] = "2500",
	[3518141119] = "5000",
	[3518141732] = "10000",
}


replicatedStorage.Communicators.Remotes.Events.PromptPurchase.OnServerEvent:Connect(function(plr, purchaseType, id)
	print(purchaseType, id)
	
	if purchaseType == "Gamepass" then
		marketPlaceService:PromptGamePassPurchase(plr, id)
	elseif purchaseType == "Product" then
		marketPlaceService:PromptProductPurchase(plr, id)
	end
end)

marketPlaceService.PromptGamePassPurchaseFinished:Connect(function(plr, id, purchased)
	if purchased then
		replicatedStorage.Communicators.Bindables.Events.UpdatePlayerData:Fire(plr, nil, "Robux", marketPlaceService:GetProductInfoAsync(id, Enum.InfoType.GamePass).PriceInRobux)
		replicatedStorage.Communicators.Bindables.Events.UpdatePlayerData:Fire(plr, nil, "AddString", "OwnsPass [" .. id .. "]")
		replicatedStorage.Communicators.Remotes.Events.Notification:FireClient(plr, "Message", "You have purchased " .. marketPlaceService:GetProductInfoAsync(id, Enum.InfoType.GamePass).Name .. ". Thank you so much!")
	end
end)

marketPlaceService.PromptProductPurchaseFinished:Connect(function(userId, id, purchased)
	if purchased then
		local plr = players:GetPlayerByUserId(userId)
		
		replicatedStorage.Communicators.Bindables.Events.UpdatePlayerData:Fire(plr, nil, "Robux", tonumber(donations[id]))
		replicatedStorage.Communicators.Remotes.Events.Notification:FireClient(plr, "Message", "Thank you so much for donating " .. tonumber(donations[id]) .. " robux!")
		
		local discordData = {
			content = "**" .. players:GetNameFromUserIdAsync(userId) .. "** just donated **<:Robux:1463235462432030997> " .. donations[id] .. "**!"
		}

		local success, response = pcall(function()
			httpService:PostAsync(webhook, httpService:JSONEncode(discordData), Enum.HttpContentType.ApplicationJson)
		end)

		if not success then
			warn(response)
		end
	end
end)

replicatedStorage.Communicators.Remotes.Functions.RequestMarketplaceStatus.OnServerInvoke = function(plr, Id, Type)
	if Type == "Gamepass" then
		return marketPlaceService:GetProductInfoAsync(Id, Enum.InfoType.GamePass), marketPlaceService:UserOwnsGamePassAsync(plr.UserId, Id)
	end
end
