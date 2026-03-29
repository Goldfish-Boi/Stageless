local success
repeat
	success = pcall(function()
		game.StarterGui:SetCore("BadgesNotificationsActive", false)
	end)
	task.wait()
until success

local BadgeService = game:GetService("BadgeService")
local TweenService = game:GetService("TweenService")

local NotificationEvent = game.ReplicatedStorage.Communicators.Remotes.Events.Notification

local gui = script.Parent
local holder = gui.Holder
local badgeTemplate = holder.BadgeTemplate
local messageTemplate = holder.MessageTemplate

local notificationsGiven = 0

NotificationEvent.OnClientEvent:Connect(function(messageType, info)
	print("Notification", messageType)
	
	script.HapticEffect:Play()
	
	if messageType == "Badge" then
		if BadgeService:UserHasBadgeAsync(game.Players.LocalPlayer.UserId, info) == false then
			notificationsGiven += 1
			
			local message = badgeTemplate:Clone()
			local badgeInfo = BadgeService:GetBadgeInfoAsync(info)
			
			print(message)
			
			message.LayoutOrder = -(notificationsGiven)
			message.BadgeName.Text = badgeInfo.Name
			message.BadgeName.MaxVisibleGraphemes = 0
			message.Glow.ImageTransparency = 1
			--game.ContentProvider:PreloadAsync({badgeInfo.IconImageId})
			message.BadgeImage.Image = "rbxassetid://" .. badgeInfo.IconImageId
			message.Size = UDim2.fromScale(0, 0)
			message.Visible = true
			message.Parent = holder
			
			print(message)
			
			script.NotificationSound:Play()
			
			task.spawn(function()
				TweenService:Create(message.Glow, TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = message.Glow.Rotation + 360}):Play()
				TweenService:Create(message.Glow, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {ImageTransparency = 0}):Play()
				TweenService:Create(message.BadgeName, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = string.len(badgeInfo.Name)}):Play()
			end)
			
			TweenService:Create(message, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.95, 0.175)}):Play()
			
			task.wait(5)
			
			TweenService:Create(message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(0.95, 0)}):Play()
			TweenService:Create(message.BadgeName, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = 0}):Play()
			
			task.wait(1)
			
			message:Destroy()
		end
	elseif messageType == "Message" then
		notificationsGiven += 1
		
		local message = messageTemplate:Clone()
		local manualDestroy = false
		local autoDestroy = false
		
		message.LayoutOrder = -(notificationsGiven)
		message.Message.Text = info
		message.Size = UDim2.fromScale(0, 0)
		message.Visible = true
		message.Parent = holder
		
		script.NotificationSound:Play()
		
		message.MouseButton1Click:Connect(function()
			if autoDestroy == true then return end
			
			manualDestroy = true
			
			TweenService:Create(message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(0.95, 0)}):Play()

			task.wait(0.5)

			TweenService:Create(message.Message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = 0}):Play()

			task.wait(1)

			message:Destroy()
		end)
		
		TweenService:Create(message, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromScale(0.95, 0.175)}):Play()
		TweenService:Create(message.Message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = string.len(info)}):Play()
		
		task.wait(math.max(5, string.len(info) * 0.075))
		
		if manualDestroy == true then return end
		
		autoDestroy = true

		TweenService:Create(message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = UDim2.fromScale(0.95, 0)}):Play()
		
		task.wait(0.5)
		
		TweenService:Create(message.Message, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {MaxVisibleGraphemes = 0}):Play()

		task.wait(1)

		message:Destroy()
	end
end)
