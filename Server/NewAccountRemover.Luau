local Players = game:GetService("Players")

local minimumAge = 14 

Players.PlayerAdded:Connect(function(plr)
	if plr.AccountAge >= minimumAge then return end

	local daysLeft = minimumAge - plr.AccountAge
	
	local banConfig = {
		UserIds = {plr.UserId},
		Duration = daysLeft * 86400,
		DisplayReason = if daysLeft == 1 then "Your account is way too young, come back tomorrow!" else "Your account is way too young, come back in " .. daysLeft .. " days!",
		PrivateReason = "Auto-banned for low account age [" .. plr.AccountAge .. " days]",
		ExcludeAltAccounts = false,
		ApplyToUniverse = true
	}

	local success, errorMessage = pcall(function()
		Players:BanAsync(banConfig)
	end)

	if not success then
		warn("Failed to ban " .. plr.Name .. ": " .. errorMessage)
		plr:Kick("Your account is too new to play this game.")
	end
end)
