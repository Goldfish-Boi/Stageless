local services = {
	["run_service"] = game:GetService("RunService"),
}

local gui = script.Parent
local fps_label = gui:WaitForChild("fps_label")
local update_rate = gui:WaitForChild("update_rate").Value
update_rate = (update_rate < 0.25 or update_rate > 2) and 1 or update_rate

local frames_rendered = 0
local last_update = tick() - update_rate
local multiplier = 1 / update_rate
services["run_service"].RenderStepped:Connect(
	function()
		if tick() - last_update >= update_rate then
			fps_label.Text = tostring(math.round(frames_rendered * multiplier)).. " FPS"
			frames_rendered = 0; last_update = tick()
		else
			frames_rendered += 1
		end
	end
)
