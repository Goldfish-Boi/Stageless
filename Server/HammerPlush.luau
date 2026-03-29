local tool = script.Parent

local animationsFolder = tool.Animations
local soundsFolder = tool.Sounds

local db = false

tool.Activated:Connect(function()
	local humanoid:Humanoid = tool.Parent:FindFirstChild("Humanoid")
	
	if db or not humanoid then return end
	
	db = true

	local anim = humanoid:LoadAnimation(animationsFolder:FindFirstChild("Swing"))
	
	anim:Play()
	
	task.wait(35 / 60)

	soundsFolder.Squeak:Play()
	
	tool.Handle.Attachment.WorldOrientation = Vector3.new(0, 0, 0)
	
	tool.Handle.Attachment.Impact:Emit(1)
	tool.Handle.Attachment.StarSharp:Emit(10)
	tool.Handle.Attachment.StarThin:Emit(10)

	anim.Ended:Connect(function()
		tool.Handle.Orientation = Vector3.new(0, 0, 0)
		
		db = false
	end)
end)
