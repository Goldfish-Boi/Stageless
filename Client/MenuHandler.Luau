local Debris = game:GetService("Debris")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local collectionService = game:GetService("CollectionService")
local runService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local tweens = require(script.MenuTweens)

local plr = game.Players.LocalPlayer
local hum:Humanoid = plr.Character

local timer = plr.PlayerGui.TowerGUI.TimerPanel

local gui = script.Parent
local frames = gui.Frames
local settingsFrame = frames.Settings
local open = script.Parent.Open
local exit = script.Parent.Exit

local menuOpened = false
local playerData = nil
local inTower = false

local infoBubble = script.Parent.InfoBubble
local infoBubbleTextBox = infoBubble.Frame.TextLabel
local quickActions = script.Parent.Main.ScrollingFrame.QuickActions

local RemotesFolder:Folder = game.ReplicatedStorage.Communicators

local RemoteEvents:{[string]:RemoteEvent} = {}
local BindableEvents:{[string]:BindableEvent} = {}

local RemoteFunctions:{[string]:RemoteFunction} = {}

do 
	for k:number, v:Instance in RemotesFolder:GetDescendants() do
		if v:IsA("RemoteEvent") then
			RemoteEvents[v.Name] = v
		elseif v:IsA("BindableEvent") then
			BindableEvents[v.Name] = v
		elseif v:IsA("RemoteFunction") then
			RemoteFunctions[v.Name] = v
		end
	end
end

BindableEvents.DataUpdate.Event:Connect(function(Type, data)
	if Type == "SettingsClient" then
		playerData = data
	end
end)

local function CharacterAdded(char)
	hum = char:WaitForChild("Humanoid")
	hum.Died:Connect(function()
		playerDied()
	end)
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

function adjustTextSize()
	for i, object in ipairs(gui:GetDescendants()) do
		if object:IsA("TextLabel") and object ~= infoBubbleTextBox then
			object.TextSize = object.AbsoluteSize.Y / 2
		end
	end
end

workspace.Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
	adjustTextSize()
end)

adjustTextSize()

for i, button in ipairs(gui:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {AspectRatio = 1.75}):Play()

			button.MouseLeave:Connect(function()
				TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 2}):Play()
			end)
		end)
	end
end

open.MouseButton1Click:Connect(function()
	menuOpened = true
	
	if playerData then
		if playerData["PracticeMode"] == true and inTower == true then
			gui.Parent.PracticeGui.MainFrame.Visible = false
		end
	end
	
	script.Parent.Main.Position = UDim2.new(0.5, 0, 0.55, 0)
	exit.Position = UDim2.new(0.008, 0, 0.475, 0)
	
	--workspace.Camera.CameraType = Enum.CameraType.Scriptable
	--workspace.Camera.CFrame = workspace.Menu.Cam.CFrame
	
	open.Visible = false
	exit.Visible = true
	script.Parent.Main.Visible = true
	
	TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
	TweenService:Create(exit, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.008, 0, 0.5, 0)}):Play()
	TweenService:Create(script.Parent.Main, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
	
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
	
	--workspace.Camera.CameraType = Enum.CameraType.Scriptable
	local menu = game.ReplicatedStorage.Menu:Clone()
	local viewPort = script.Viewport:Clone()
	
	viewPort.Parent = gui.Parent
	
	--menu.AnimationController:LoadAnimation(menu.Animations.Entrances[math.random(1, #menu.Animations.Entrances:GetChildren())]):Play()
	
	menu.Parent = viewPort.ViewportFrame.WorldModel
	
	tweens.RandomStartTween(menu)
	--menu:SetPrimaryPartCFrame(viewPort.WorldModel.Camera.CFrame)
end)

function removeMenu()
	menuOpened = false
	
	if playerData then
		if playerData["PracticeMode"] == true and inTower == true then
			gui.Parent.PracticeGui.MainFrame.Visible = true
		end
	end

	open.Position = UDim2.new(0.008, 0, 0.475, 0)

	--workspace.Camera.CameraType = Enum.CameraType.Custom

	open.Visible = true
	exit.Visible = false
	script.Parent.Main.Visible = false

	for i, frame in ipairs(frames:GetChildren()) do
		if frame:IsA("Frame") then
			frame.Visible = false
		end
	end

	TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.015, 0)}):Play()
	TweenService:Create(open, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.008, 0, 0.5, 0)}):Play()

	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

	--workspace.Camera.CameraType = Enum.CameraType.Custom
	
	local viewport = gui.Parent:FindFirstChild("Viewport")
	
	if viewport then
		Debris:AddItem(viewport, 0)
	end
end

exit.MouseButton1Click:Connect(function()
	removeMenu()
end)

script.RemoveMenu.Event:Connect(function()
	removeMenu()
end)

function playerDied()
	if menuOpened == true then
		open.Position = UDim2.new(0.008, 0, 0.475, 0)

		workspace.Camera.CameraType = Enum.CameraType.Custom

		open.Visible = true
		exit.Visible = false
		script.Parent.Main.Visible = false

		for i, frame in ipairs(frames:GetChildren()) do
			if frame:IsA("Frame") then
				frame.Visible = false
			end
		end

		TweenService:Create(timer, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.015, 0)}):Play()
		TweenService:Create(open, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.008, 0, 0.5, 0)}):Play()

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)

		workspace.Camera.CameraType = Enum.CameraType.Custom

		Debris:AddItem(workspace.Camera:WaitForChild("Menu"), 0)
	end
	
	menuOpened = false
end

quickActions.RestartTower.MouseButton1Click:Connect(function()
	RemoteEvents.RestartRequested:FireServer()

	task.wait(1)

	removeMenu()
end)

quickActions.ExitTower.MouseButton1Click:Connect(function()
	RemoteEvents.ExitRequested:FireServer()
	
	task.wait(1)
	
	removeMenu()
end)

quickActions.RejoinServer.MouseButton1Click:Connect(function()
	RemoteEvents.Teleport:FireServer("Self")
end)

quickActions.ReturnToHub.MouseButton1Click:Connect(function()
	RemoteEvents.Teleport:FireServer("Hub")
end)

for i, button in ipairs(script.Parent.Main.ScrollingFrame.Buttons:GetDescendants()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1.125}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1}):Play()
		end)
		button.MouseButton1Click:Connect(function()
			local frame:Frame = frames:FindFirstChild(button.Name)
			
			script.ClickSound:Play()
			
			frame.Position = UDim2.new(0.5, 0, 0.55, 0)
			frame.Visible = true
			TweenService:Create(frame, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
			
			gui.Main.Visible = false
		end)
	end
end

for i, button in ipairs(quickActions:GetChildren()) do
	if button:IsA("TextButton") then
		button.MouseEnter:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 1.5}):Play()
		end)
		button.MouseLeave:Connect(function()
			TweenService:Create(button.UIAspectRatioConstraint, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {AspectRatio = 2}):Play()
		end)
		button.MouseButton1Click:Connect(function()
			script.ClickSound:Play()
		end)
	end
end

for i, button in ipairs(frames:GetDescendants()) do
	if button:IsA("TextButton") and button.Name == "Exit" then
		button.MouseButton1Click:Connect(function()
			button.Parent.Visible = false
			
			gui.Main.Position = UDim2.new(0.5, 0, 0.55, 0)
			gui.Main.Visible = true
			TweenService:Create(gui.Main, TweenInfo.new(0.125, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		end)
	end
end

local function updateInfoBubbleSize()
	TweenService:Create(infoBubble.Frame, TweenInfo.new(0.25), {Size = UDim2.new(0, gui.AbsoluteSize.X / (gui.AbsoluteSize.X / 250), 0, infoBubbleTextBox.TextBounds.Y + 20)}):Play()
end

for i, object:GuiObject in ipairs(collectionService:GetTagged("InfoObject")) do
	object.MouseEnter:Connect(function(x, y)
		if y / workspace.CurrentCamera.ViewportSize.Y < 0.45 then
			infoBubble.AnchorPoint = Vector2.new(0.5, 0)
			infoBubble.Frame.AnchorPoint = Vector2.new(0.5, 0)
			infoBubble.Frame.Position = UDim2.fromScale(0.5, 0.35)
			infoBubble.ImageLabel.Position = UDim2.fromScale(0.5, 0.3)
			infoBubble.ImageLabel.Rotation = 180
		else
			infoBubble.AnchorPoint = Vector2.new(0.5, 1)
			infoBubble.Frame.AnchorPoint = Vector2.new(0.5, 1)
			infoBubble.Frame.Position = UDim2.fromScale(0.5, 0.75)
			infoBubble.ImageLabel.Position = UDim2.fromScale(0.5, 0.8)
			infoBubble.ImageLabel.Rotation = 0
		end
		
		infoBubble.Position = UDim2.fromOffset(object.AbsolutePosition.X + (object.AbsoluteSize.X / 2), object.AbsolutePosition.Y)
		infoBubble.Frame.Size = UDim2.fromOffset(gui.AbsoluteSize.X / (gui.AbsoluteSize.X / 250), gui.AbsoluteSize.Y / (gui.AbsoluteSize.Y / 97))
		infoBubbleTextBox.TextSize = gui.AbsoluteSize.X / (gui.AbsoluteSize.X / 20)
		infoBubble.Visible = true
		infoBubbleTextBox.Text = object:GetAttribute("Info")
		infoBubbleTextBox.MaxVisibleGraphemes = 0
		
		TweenService:Create(infoBubbleTextBox, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {MaxVisibleGraphemes = utf8.len(infoBubbleTextBox.Text)}):Play()
		
		updateInfoBubbleSize()
	end)
	object.MouseLeave:Connect(function()
		infoBubble.Visible = false
		infoBubbleTextBox.Text = ""

		updateInfoBubbleSize()
	end)
end

function LoadTower()
	inTower = true
	quickActions.ExitTower.Visible = true
	quickActions.RestartTower.Visible = true
end

function UnloadTower()
	inTower = false
	quickActions.ExitTower.Visible = false
	quickActions.RestartTower.Visible = false
end

RemoteEvents.LoadTower.OnClientEvent:Connect(LoadTower)
RemoteEvents.UnloadTower.OnClientEvent:Connect(UnloadTower)
