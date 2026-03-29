local teleportService = game:GetService("TeleportService")
local replicatedStorage = game:GetService("ReplicatedStorage")

replicatedStorage.Communicators.Remotes.Events.Teleport.OnServerEvent:Connect(function(plr, location)
	teleportService:TeleportAsync(location, {plr})
end)
