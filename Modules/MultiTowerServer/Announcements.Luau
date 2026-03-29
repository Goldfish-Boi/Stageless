---!strict
-- Written by fanofpixels

-- Get types
local Types = require(script.Parent.Types)

type List<T> = Types.List<T>
type Dictionary<T> = Types.Dictionary<T>
type PlayerInfo = Types.PlayerInfo
type TowerRush = Types.TowerRush
type TowerInfo = Types.TowerInfo
type EndingInfo = Types.EndingInfo
type Difficulty = Types.DifficultyInfo

type WinMessageInfo = {
	MessageID:string,
	
	PlayerName:string,
	EndingName:string,
	DifficultyName:string,
	
	Time:number,
	BoostsUsed:Dictionary<string>
}
type ClientWinMessageInfo = {
	PlayerName:string,
	EndingName:string,
	Time:number,
	BoostsUsed:Dictionary<string>,
	
	Color:Color3,
	FancyFont:boolean,
}
type Message = {
	Data:any,
	Sent:number
}
local m = {}

local RemoteEvents:Dictionary<RemoteEvent> = {}
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HTTPService = game:GetService("HttpService")
local Messaging = game:GetService("MessagingService")
local Util = require(script.Parent.Util)

local Config:Dictionary<any> = {}
local Difficulties:Dictionary<Difficulty> = {}
local KickMessages:List<string> = {}

local LatestGlobalMessageID:string = ""

function m:WinAnnouncement(Player:PlayerInfo,EndingName:string,DifficultyName:string,NoHit:boolean)
	
	local regularWebhookURL = "[Example Webhook]"
	local scWebhookURL = "[Example Webhook]"

	local EndingDifficulty:Difficulty = Util:GetDifficulty(DifficultyName)
	
	local Info:WinMessageInfo = {
		-- Unique message ID
		MessageID = HTTPService:GenerateGUID(false),
		
		PlayerName = Config.UseDisplayName and Player.Player.DisplayName or Player.Player.Name,
		EndingName = EndingName,
		DifficultyName = DifficultyName,
		
		Time = Player.TowerTimer,
		BoostsUsed = Player.BoostItemNames
	}
	
	-- If this difficulty should be globally announced, message the universe
	if EndingDifficulty.GlobalAnnouncement then
		
		-- Set the latest global message ID, we do this so we can check later
		-- If we receive a message and it's the same one as this one, don't broadcast it
		-- This is to prevent a server from broadcasting the same win message twice
		LatestGlobalMessageID = Info.MessageID
		
		Messaging:PublishAsync("GlobalWin",Info)
	end

	local StandardDiffs = {"Effortless", "Easy", "Medium", "Hard", "Difficult", "Challenging", "Intense", "Remorseless"}
	local SCDiffs = {"Insane", "Extreme", "Terrifying", "Catastrophic", "Horrific", "Unreal", "Nil", "TowerRush"}

	local webhookURL = regularWebhookURL
	if table.find(SCDiffs, DifficultyName) then
		webhookURL = scWebhookURL
	end

	if table.find(StandardDiffs, DifficultyName) then
		webhookURL = regularWebhookURL
	end

	local boostsList = ""

	if Player.BoostItemUsed then
		local boostsTable = {}
		for _, v in pairs(Player.BoostItemNames) do
			table.insert(boostsTable, v)
		end
		boostsList = table.concat(boostsTable, ", ")
	else
		boostsList = "None"
	end

	local minutes = math.floor(Info.Time / 60)
	local seconds = math.floor(Info.Time % 60)
	local milliseconds = math.floor((Info.Time - math.floor(Info.Time)) * 1000)

	-- make the emote strings the emoji ids for your difficulty emojis in your server
	-- (and make ur towerrush difficulty towerrush or something so u can get a different emoji for it)
	-- remember to make ur tower rush emoji have an 'a' in front of the emoji kind of like this <a:thing:1234567890>
	-- if i figure out how to make the in-game tower rush announcement rainbow i might share that as well but otherwise dont ask me
	local Difficulties = {
		['Effortless'] = {emote = "<:Effortless:1426033094128959508>", dcolor = Color3.fromRGB(0, 150, 0)};
		['Easy'] = {emote = "<:Easy:1426033267311775816>", dcolor = Color3.fromRGB(100,225,75)};
		['Medium'] = {emote = "<:Medium:1426033305391988887>", dcolor = Color3.fromRGB(255,255,0)};
		['Hard'] = {emote = "<:Hard:1426033364292472893> ", dcolor = Color3.fromRGB(225, 115, 0)};
		['Difficult'] = {emote = "<:Difficult:1426033403865731132>", dcolor = Color3.fromRGB(255,0,0)};
		['Challenging'] = {emote = "<:Challenging:1426033461243809816>", dcolor = Color3.fromRGB(170,0,0)};
		['Intense'] = {emote = "<:Intense:1426033516612685875>", dcolor = Color3.fromRGB(50,85,110)};
		['Remorseless'] = {emote = "<:Remorseless:1426033563421380698>", dcolor = Color3.fromRGB(255,0,225)};
		['Insane'] = {emote = "<:Insane:1426033625983615026>", dcolor = Color3.fromRGB(0,70,255)};
		['Extreme'] = {emote = "<:Extreme:1426033676210147450>", dcolor = Color3.fromRGB(55,155,255)};
		['Terrifying'] = {emote = "<:Terrifying:1426033731667230811>", dcolor = Color3.fromRGB(0,255,255)};
		['Catastrophic'] = {emote = "<:Catastrophic:1426033773966921830>", dcolor = Color3.fromRGB(225,225,225)};
		['Horrific'] = {emote = "<:Horrific:1426033811694682163>", dcolor = Color3.fromRGB(150, 150, 255)};
		['Unreal'] = {emote = "<:Unreal:1426033846666924166>", dcolor = Color3.fromRGB(75, 0, 255)};
		["TowerRush"] = {emote = "<a:TowerRush:1427805484836192286>", dcolor = Color3.fromRGB(255,255,255)};
	}

	--print(Difficulties[DifficultyName].emote)

	local difficultyTag = "[" .. Difficulties[DifficultyName].emote .. "]"
	local timeString = string.format("%02d:%02d.%03d", minutes, seconds, milliseconds)
	
	local discordMessage = string.format(
		if NoHit == true then "**%s** has *no hit* **%s** %s in %s" else "**%s** has beaten **%s** %s in %s",
		Info.PlayerName,
		Info.EndingName,
		difficultyTag,
		"`"..timeString:sub(1, timeString:len() - 1).."`"
	)

	print(Player.BoostItemUsed)
	if Player.BoostItemUsed == true then
		discordMessage = string.format(
			"%s\n**Boosts Used:** %s",
			discordMessage,
			boostsList
		)
	end

	local discordData = {
		content = discordMessage
	}
	
	task.spawn(function()
		local success, response = pcall(function()
			HTTPService:PostAsync(webhookURL, HTTPService:JSONEncode(discordData), Enum.HttpContentType.ApplicationJson)
		end)
		
		if not success then
			warn("Failed to send message to Discord webhook:", response) -- keep this here just in case your webhook fails so you know whether you're dumb or if discord is
		end
	end)

	BroadcastWinAnnouncement(Info)
end

--[[ removed this function but kept it in for future reference if needed
the reason for removal is because the client is now responsible for constructing a win message out of 
the relevant info (useful for localization support in the future!)

-- Encapsulate this so that i cant accidentally create a loop with MessagingService
function BroadcastWinAnnouncement(Info:WinMessageInfo)
	local EndingDifficulty:Difficulty = Util:GetDifficulty(Info.DifficultyName)
	local BoostsUsed:List<string> = {}
	for k:string,v:string in Info.BoostsUsed do
		table.insert(BoostsUsed,v)
	end
	
	-- Construct the win message
	-- The {Time:???} will be substituted by the client
	local WinMessage:string = "{Player} beat {EndingName} in {Time} lol thats great"
	WinMessage = WinMessage:gsub("{Player}", Info.PlayerName)
	WinMessage = WinMessage:gsub("{EndingName}", Info.EndingName)
	WinMessage = WinMessage:gsub("{Time}","{Time:"..tostring(Info.Time).."}")
	
	-- If boosts were used, concatenate the list
	if #BoostsUsed > 0 then
		local BoostList:string = ""
		for k:number, v:string in BoostsUsed do
			BoostList ..= v
			if k < #BoostsUsed then
				BoostList ..= ", "
			end
		end
		WinMessage ..= " "..Config.WinBoostsUsed
		WinMessage = WinMessage:gsub("{BoostList}", BoostList)
	end
	
	-- Send the win message out
	m:GameAnnouncement(
		WinMessage,
		EndingDifficulty.Color,
		EndingDifficulty.FancyFont
	)
end
--]]

function BroadcastWinAnnouncement(Info:WinMessageInfo)
	local EndingDifficulty:Difficulty = Util:GetDifficulty(Info.DifficultyName)
	
	-- Construct an information table the client can recieve
	local ClientMsgInfo:ClientWinMessageInfo = {
		PlayerName = Info.PlayerName,
		EndingName = Info.EndingName,
		Time = Info.Time,
		BoostsUsed = Info.BoostsUsed,
		
		Color = EndingDifficulty.Color,
		FancyFont = EndingDifficulty.FancyFont
	}
	--print(EndingDifficulty)
	RemoteEvents.GameWinAnnouncement:FireAllClients(ClientMsgInfo)
end

function m:GameAnnouncement(Message:string, Color:Color3, FancyText:boolean?)
	RemoteEvents.GameAnnouncement:FireAllClients(Message,Color,FancyText)
end

function m:AntiCheatKick(Plr:Player, Reason:string)
	local Message:string = KickMessages[math.random(1,#KickMessages)]
	Message = Message:gsub("{Player}",(Config.UseDisplayNames) and Plr.DisplayName or Plr.Name)

	m:GameAnnouncement(Message,Color3.new(1,0,0))
	Plr:Kick(Reason)
end

function GlobalWinMessage(Msg:Message)
	local Info:WinMessageInfo = Msg.Data::WinMessageInfo
	
	-- Prevent double message
	if Info.MessageID == LatestGlobalMessageID then
		return
	end
	BroadcastWinAnnouncement(Info)
end

function m:Init(EventsTable:{[string]:RemoteEvent},GameData:Folder)
	RemoteEvents = EventsTable

	-- Using ::any to make Luau shut up about "unsupported require path"
	Config = require(GameData:WaitForChild("Config"))::any
	Difficulties = require(GameData:WaitForChild("Difficulties"))::any
	KickMessages = require(GameData:WaitForChild("KickMessages"))::any
	
	Messaging:SubscribeAsync("GlobalWin", GlobalWinMessage)
end

return m
