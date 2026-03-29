local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")

local tool = script.Parent
local main = tool.Main
local pulse = tool.Pulse
local light = main.PointLight
local particleEmitter = main.ParticleEmitter
local billboardGui = main.BillboardGui
local recharge = main.Recharge
local flash = main.Flash

local db = false

task.spawn(function()
	game.ContentProvider:PreloadAsync({billboardGui, billboardGui.ImageLabel})
end)

function createPulse(largePulse:boolean?)
	local newPulse = pulse:Clone()
	newPulse.Parent = tool
	newPulse.Transparency = 0

	debris:AddItem(newPulse, 1)

	if largePulse then particleEmitter.Speed = NumberRange.new(10, 20); flash:Play() else particleEmitter.Speed = NumberRange.new(3, 7); recharge:Play() end
	particleEmitter:Emit(if largePulse then 100 else 33)

	tweenService:Create(newPulse, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Size = if largePulse then Vector3.new(3, 6, 2.25) else Vector3.new(1.5, 3, 1.125), Transparency = 1}):Play()

	if not largePulse then return end

	billboardGui.Brightness = 15
	billboardGui.Size = UDim2.fromScale(15, 15)
	billboardGui.ImageLabel.ImageTransparency = 0

	tweenService:Create(billboardGui, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Brightness = 1, Size = UDim2.fromScale(14, 14)}):Play()
	tweenService:Create(billboardGui.ImageLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
end

tool.Activated:Connect(function()
	if db then return end

	db = true
	task.delay(5, function()
		db = false
		createPulse()
		main.Color = Color3.fromRGB(248, 248, 248)
	end)

	light.Brightness = 15
	light.Range = 45

	createPulse(true)

	main.Color = Color3.fromRGB(150, 150, 150)

	tweenService:Create(light, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {Brightness = 0}):Play()
end)
