-- ==============================================================================
-- TYO HUB V3 | SPEED HUB STYLE (NO-KEY & MULTI-DEVICE / MULTI-ACCOUNT SAFE)
-- MAP: MOUNT SOREYA UPDATE (ULTRA POTATO & MAX PERFORMANCE BOOST)
-- ==============================================================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------
-- STAT TRACKER GLOBAL VARIABLES
------------------------------------------------------------------
getgenv().TotalFishCaught = 0
getgenv().SessionStartTime = os.time()

------------------------------------------------------------------
-- CONFIGURATION & FILE SAVE SYSTEM (SAFE FOR MULTI-ACCOUNT)
------------------------------------------------------------------
local SAFE_NAME = tostring(LocalPlayer.UserId or LocalPlayer.Name)
local CONFIG_FILE = "TyoHubV3_Config_" .. SAFE_NAME .. ".json"

getgenv().TyoConfig = {
	BiteDelay = "0.5",
	TapDelay = "0.12",
	MinigameMode = "Legit",
	SelectedSpot = "Spot Mancing Jembatan",
	AutoSellTimer = "5",
	AntiAdminEnabled = false,
	TargetGroupId = 7019573,
	WebhookEnabled = false,
	WebhookUrl = "",
	SelectedTradeTarget = ""
}

local function SaveConfig()
	pcall(function()
		if writefile then
			local data = HttpService:JSONEncode(getgenv().TyoConfig)
			writefile(CONFIG_FILE, data)
		end
	end)
end

local function LoadConfig()
	pcall(function()
		if readfile and isfile and isfile(CONFIG_FILE) then
			local content = readfile(CONFIG_FILE)
			local success, data = pcall(function() return HttpService:JSONDecode(content) end)
			if success and type(data) == "table" then
				if data.BiteDelay then getgenv().TyoConfig.BiteDelay = data.BiteDelay end
				if data.TapDelay then getgenv().TyoConfig.TapDelay = data.TapDelay end
				if data.MinigameMode then getgenv().TyoConfig.MinigameMode = data.MinigameMode end
				if data.SelectedSpot then getgenv().TyoConfig.SelectedSpot = data.SelectedSpot end
				if data.AutoSellTimer then getgenv().TyoConfig.AutoSellTimer = data.AutoSellTimer end
				if data.AntiAdminEnabled ~= nil then getgenv().TyoConfig.AntiAdminEnabled = data.AntiAdminEnabled end
				if data.TargetGroupId then getgenv().TyoConfig.TargetGroupId = data.TargetGroupId end
				if data.WebhookEnabled ~= nil then getgenv().TyoConfig.WebhookEnabled = data.WebhookEnabled end
				if data.WebhookUrl then getgenv().TyoConfig.WebhookUrl = data.WebhookUrl end
				if data.SelectedTradeTarget then getgenv().TyoConfig.SelectedTradeTarget = data.SelectedTradeTarget end
			end
		end
	end)
end

local function ResetConfig()
	pcall(function()
		getgenv().TyoConfig = {
			BiteDelay = "0.5",
			TapDelay = "0.12",
			MinigameMode = "Legit",
			SelectedSpot = "Spot Mancing Jembatan",
			AutoSellTimer = "5",
			AntiAdminEnabled = false,
			TargetGroupId = 7019573,
			WebhookEnabled = false,
			WebhookUrl = "",
			SelectedTradeTarget = ""
		}
		if delfile and isfile then
			if isfile(CONFIG_FILE) then delfile(CONFIG_FILE) end
		end
	end)
end
LoadConfig()

------------------------------------------------------------------
-- DISCORD WEBHOOK SYSTEM (SERVER-WIDE CUTSCENE BROADCAST)
------------------------------------------------------------------
local function SendServerWideWebhook(playerName, catchType, position)
	pcall(function()
		if not getgenv().TyoConfig.WebhookEnabled then return end
		local url = getgenv().TyoConfig.WebhookUrl
		if not url or url == "" or not string.find(url, "api/webhooks") then return end
		
		local typeLower = string.lower(tostring(catchType))
		local targetPlayer = tostring(playerName or "Unknown Player")
		
		if string.find(typeLower, "secret") or string.find(typeLower, "forgotten") or string.find(typeLower, "core") or string.find(typeLower, "catch") or string.find(typeLower, "aether") then
			local requestFunc = (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request)
			if not requestFunc then return end
			
			local embedTitle = "👑 Tyo Hub V3 - Mount Soreya Rare Catch Tracker!"
			local alertContent = string.format("@everyone 🚨 **%s Berhasil Mendapatkan Tangkapan Langka!**", targetPlayer)
			local embedColor = 16711935
			
			if string.find(typeLower, "core") or string.find(typeLower, "aether") then
				alertContent = string.format("@everyone ⚡ **%s Mendapatkan Item Spesial / Aether Material!**", targetPlayer)
				embedTitle = "💎 Tyo Hub V3 - Mount Soreya Event Tracker!"
				embedColor = 16776960
			end
			
			local posStr = position and string.format("%.1f, %.1f, %.1f", position.X, position.Y, position.Z) or "N/A"
			
			local data = {
				["content"] = alertContent,
				["embeds"] = {
					{
						["title"] = embedTitle,
						["description"] = string.format("Pemain **%s** di dalam server Mount Soreya baru saja mendapatkan item spesial!", targetPlayer),
						["color"] = embedColor,
						["fields"] = {
							{ ["name"] = "👤 Nama Player", ["value"] = targetPlayer, ["inline"] = true },
							{ ["name"] = "🎯 Tipe Tangkapan", ["value"] = tostring(catchType), ["inline"] = true },
							{ ["name"] = "📍 Koordinat", ["value"] = posStr, ["inline"] = true }
						},
						["footer"] = { ["text"] = "Tyo Hub V3 • Mount Soreya Monitor" },
						["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
					}
				}
			}
			
			requestFunc({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode(data)
			})
		end
	end)
end

task.spawn(function()
	pcall(function()
		local CutsceneBroadcastRemote = ReplicatedStorage:FindFirstChild("CutsceneBroadcast")
		if CutsceneBroadcastRemote and CutsceneBroadcastRemote:IsA("RemoteEvent") then
			CutsceneBroadcastRemote.OnClientEvent:Connect(function(catchType, position, targetPlayer)
				local playerName = targetPlayer and targetPlayer.Name or "Unknown Player"
				SendServerWideWebhook(playerName, catchType, position)
			end)
		end
	end)
end)

------------------------------------------------------------------
-- REAL-TIME CATCH MONITOR & STATS COUNTER (LOCAL PLAYER)
------------------------------------------------------------------
local hookedRemotes = {}
local function ProcessNotifyClient(actionType, fishDataArg)
	if actionType == "GotFish" then
		pcall(function()
			getgenv().TotalFishCaught = getgenv().TotalFishCaught + 1
		end)
	end
end

local function AttachNotifyHook(remote)
	if remote and remote:IsA("RemoteEvent") and not hookedRemotes[remote] then
		hookedRemotes[remote] = true
		remote.OnClientEvent:Connect(ProcessNotifyClient)
	end
end

local function ScanContainerForNotify(container)
	if not container then return end
	for _, v in ipairs(container:GetDescendants()) do
		if v:IsA("RemoteEvent") and v.Name == "NotifyClient" then
			AttachNotifyHook(v)
		end
	end
end

local function ListenToFishCatch()
	pcall(function()
		ScanContainerForNotify(ReplicatedStorage)
		ReplicatedStorage.DescendantAdded:Connect(function(v)
			if v:IsA("RemoteEvent") and v.Name == "NotifyClient" then
				AttachNotifyHook(v)
			end
		end)
		local function ScanCharacter(char)
			if not char then return end
			ScanContainerForNotify(char)
			char.DescendantAdded:Connect(function(v)
				if v:IsA("RemoteEvent") and v.Name == "NotifyClient" then
					AttachNotifyHook(v)
				end
			end)
		end
		if LocalPlayer.Character then ScanCharacter(LocalPlayer.Character) end
		LocalPlayer.CharacterAdded:Connect(ScanCharacter)
	end)
end

task.spawn(function()
	task.wait(1)
	ListenToFishCatch()
end)

----------------------------------------------------
-- AUTO EQUIP ROD SYSTEM (UNIVERSAL)
----------------------------------------------------
local function AutoEquipRod()
	pcall(function()
		local character = LocalPlayer.Character
		if not character then return end
		
		for _, child in ipairs(character:GetChildren()) do
			if child:IsA("Tool") and (string.find(string.lower(child.Name), "rod") or string.find(string.lower(child.Name), "pancing")) then
				return
			end
		end
		
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if backpack and humanoid then
			for _, item in ipairs(backpack:GetChildren()) do
				if item:IsA("Tool") then
					local itemName = string.lower(item.Name)
					if string.find(itemName, "rod") or string.find(itemName, "pancing") then
						humanoid:EquipTool(item)
						break
					end
				end
			end
		end
	end)
end

------------------------------------------------------------------
-- HELPER: AUTO FISHING BAWAAN GAME & AUTO TAP CLICKER
------------------------------------------------------------------
local function EnableGameAutoFishing(state)
	if state == nil then state = true end
	local fired = false
	pcall(function()
		local mancing = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Mancing")
		local r = mancing and (mancing:FindFirstChild("Auto") or mancing:FindFirstChild("AutoFishing"))
		if r and r:IsA("RemoteEvent") then
			r:FireServer(state)
			fired = true
		end
	end)
	return fired
end

local function ClickGameAutoButton()
	pcall(function()
		local hub = PlayerGui:FindFirstChild("TyoHub")
		for _, v in ipairs(PlayerGui:GetDescendants()) do
			if (v:IsA("TextButton") or v:IsA("ImageButton")) and not (hub and v:IsDescendantOf(hub)) then
				local n = string.lower(v.Name)
				local t = v:IsA("TextButton") and string.lower(v.Text) or ""
				if string.find(n, "auto") or string.find(t, "auto") then
					if firesignal then
						firesignal(v.MouseButton1Click)
						firesignal(v.Activated)
					elseif getconnections then
						for _, c in ipairs(getconnections(v.MouseButton1Click)) do c:Fire() end
					end
					return
				end
			end
		end
	end)
end

local function PerformTapClicker()
	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	if isMobile then
		pcall(function()
			local char = LocalPlayer.Character
			local tool = char and char:FindFirstChildOfClass("Tool")
			if tool then tool:Activate() end
		end)
		return
	end
	
	local cam = Workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
	local mousePos = UIS:GetMouseLocation()
	local pos = (mousePos.X > 0 and mousePos.Y > 0) and mousePos or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
	
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
		task.wait(0.02)
		VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
	end)
end

------------------------------------------------------------------
-- AUTO RECONNECT
------------------------------------------------------------------
task.spawn(function()
	pcall(function()
		CoreGui.ChildAdded:Connect(function(child)
			if child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt" then
				task.wait(1)
				pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
			end
		end)
	end)
end)

-- GLOBAL STATES
getgenv().AutoFishingEventRunning = false
getgenv().BiteDelayInput = getgenv().TyoConfig.BiteDelay
getgenv().SelectedFishingSpot = getgenv().TyoConfig.SelectedSpot
getgenv().AutoSellRunning = false
getgenv().AutoSellTimerInput = getgenv().TyoConfig.AutoSellTimer
getgenv().AutoGalatamaRunning = false
getgenv().AutoSummitRunning = false
getgenv().AntiAFKRunning = false
getgenv().HideNameRunning = false
getgenv().FakeNameInput = "TYO HUB"
getgenv().CurrentSelectedHalo = nil
getgenv().AutoDetectCoreEvent = false
getgenv().LoopSpotEnabled = false
getgenv().SpotLoopConfig = {
	["Spot Mancing Jembatan"] = { Enabled = false, Timer = "10" },
	["Spot Mancing Core"] = { Enabled = false, Timer = "10" },
	["Spot Mancing Ikan Anomali"] = { Enabled = false, Timer = "10" }
}
getgenv().AutoFavoriteRunning = false
getgenv().AutoAcceptTradeRunning = false
getgenv().FavRarities = {
	["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false,
	["Legendary"] = true, ["Mythical"] = true, ["Secret"] = true, ["Forgotten"] = true, ["Aether"] = true
}
getgenv().FavMutations = {
	["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false,
	["Lightning"] = false, ["Fairy Dust"] = true, ["Gold"] = false, ["Midnight"] = false,
	["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false,
	["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false,
	["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false,
	["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false
}
getgenv().UnfavRarities = {
	["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false,
	["Legendary"] = false, ["Mythical"] = false, ["Secret"] = false, ["Forgotten"] = false
}
getgenv().UnfavMutations = {
	["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false,
	["Lightning"] = false, ["Fairy Dust"] = false, ["Gold"] = false, ["Midnight"] = false,
	["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false,
	["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false,
	["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false,
	["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false
}

local FishingSpots = {
	["Spot Mancing Jembatan"] = CFrame.new(-6783.74756, 1322.81006, -9757.34473, 0.0899723172, -9.34088291e-08, 0.995944262, 1.76120434e-08, 1, 9.21981638e-08, -0.995944262, 9.24533072e-09, 0.0899723172),
	["Spot Mancing Core"] = CFrame.new(-9069.33887, 1250.32092, -6510.3374, 0.99812746, -7.96398965e-08, -0.0611686334, 8.05492206e-08, 1, 1.24000188e-08, 0.0611686334, -1.73038845e-08, 0.99812746),
	["Spot Mancing Ikan Anomali"] = CFrame.new(-8199.52832, 1238.83752, -6278.13135, -0.999144316, 1.1644854e-08, -0.0413601957, 1.63464247e-08, 1, -1.13335595e-07, 0.0413601957, -1.13914709e-07, -0.999144316)
}
local NpcSellCFrame = CFrame.new(-6668.01416, 1312.69983, -9965.2998, 0.999977231, 1.08366018e-08, -0.00675115408, -1.09201403e-08, 1, -1.2337189e-08, 0.00675115408, 1.24106316e-08, 0.999977231)

local function GetEquippedRod()
	local char = LocalPlayer.Character
	if not char then return nil end
	local rod = char:FindFirstChild("Withering Rod")
	if rod then return rod end
	for _, c in ipairs(char:GetChildren()) do
		if c:IsA("Tool") and c:FindFirstChild("Mechanics") then return c end
	end
	return nil
end

------------------------------------------------------------------
-- ROD SETTINGS
------------------------------------------------------------------
local OriginalRodValues = {}
local function OptimizeRodSettings()
	pcall(function()
		local rod = GetEquippedRod()
		local s = rod and rod:FindFirstChild("Mechanics") and rod.Mechanics:FindFirstChild("Settings")
		if not s then return end
		local t = s:FindFirstChild("Time_before_getfish")
		if t then
			if OriginalRodValues[t] == nil then OriginalRodValues[t] = t.Value end
			t.Value = 0.05
		end
		local m = s:FindFirstChild("EnableMiniGame")
		if m then
			if OriginalRodValues[m] == nil then OriginalRodValues[m] = m.Value end
			m.Value = false
		end
	end)
end

local function RestoreRodSettings()
	pcall(function()
		for inst, val in pairs(OriginalRodValues) do
			if inst and inst.Parent then inst.Value = val end
			OriginalRodValues[inst] = nil
		end
		local rod = GetEquippedRod()
		local s = rod and rod:FindFirstChild("Mechanics") and rod.Mechanics:FindFirstChild("Settings")
		local m = s and s:FindFirstChild("EnableMiniGame")
		if m then m.Value = true end
	end)
end

------------------------------------------------------------------
-- AUTO FISHING (INSTANT / LEGIT)
------------------------------------------------------------------
local function RunAutoFishCycle(remoteFolder)
	pcall(function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		
		OptimizeRodSettings()
		
		remoteFolder.CastEvent:FireServer(true)
		task.wait(0.05)
		remoteFolder.CastEvent:FireServer(false, 100, hrp.CFrame.LookVector)
		
		local hooked = false
		local conn = remoteFolder.NotifyClient.OnClientEvent:Connect(function(actionType)
			if actionType == "Bite" or actionType == "Hook" then hooked = true end
		end)
		
		local start = tick()
		while not hooked and getgenv().AutoFishingEventRunning
			and getgenv().TyoConfig.MinigameMode == "Instant" do
			if tick() - start > 8 then break end
			task.wait(0.05)
		end
		if conn then conn:Disconnect() end
		
		if hooked and getgenv().AutoFishingEventRunning
			and getgenv().TyoConfig.MinigameMode == "Instant" then
			task.wait(tonumber(getgenv().BiteDelayInput) or 0.5)
			
			if getgenv().TyoConfig.MinigameMode ~= "Instant" then return end
			
			local tandaSeruRemote = remoteFolder:FindFirstChild("TandaSeruBersama")
			if tandaSeruRemote then
				local color1 = Color3.fromRGB(23, 255, 151)
				local color2 = Color3.fromRGB(20, 20, 20)
				local seq = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color1),
					ColorSequenceKeypoint.new(1, color1)
				})
				tandaSeruRemote:FireServer(color1, color2, seq, 1.5)
			end
			
			task.wait(0.1)
			if getgenv().TyoConfig.MinigameMode ~= "Instant" then return end
			remoteFolder.MiniGame:FireServer(true)
			task.wait(0.3)
		end
	end)
end

getgenv().FishLoopId = 0
local function StartFishingLoop()
	getgenv().FishLoopId = getgenv().FishLoopId + 1
	local myId = getgenv().FishLoopId
	task.spawn(function()
		local lastAuto, clickedGui, restored = 0, false, false
		while getgenv().AutoFishingEventRunning and getgenv().FishLoopId == myId do
			local mode = getgenv().TyoConfig.MinigameMode or "Legit"
			AutoEquipRod()
			if mode == "Legit" then
				if not restored then
					restored = true
					RestoreRodSettings()
					lastAuto = 0
				end
				if tick() - lastAuto > 10 then
					lastAuto = tick()
					local viaRemote = EnableGameAutoFishing(true)
					if not viaRemote and not clickedGui then
						clickedGui = true
						ClickGameAutoButton()
					end
				end
				PerformTapClicker()
				task.wait(tonumber(getgenv().TyoConfig.TapDelay) or 0.12)
			else
				restored = false
				pcall(function()
					local rod = GetEquippedRod()
					local rf = rod and rod:FindFirstChild("Mechanics") and rod.Mechanics:FindFirstChild("Remotes")
					if rf then RunAutoFishCycle(rf) else task.wait(1) end
				end)
				task.wait(0.1)
			end
		end
		if getgenv().FishLoopId == myId and (getgenv().TyoConfig.MinigameMode or "Legit") == "Legit" then
			EnableGameAutoFishing(false)
		end
	end)
end

local function TriggerSellToNpc()
	pcall(function()
		local character = LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local currentSpotCFrame = hrp.CFrame
		hrp.CFrame = NpcSellCFrame + Vector3.new(0, 5, 0)
		task.wait(0.8)
		local mancing = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Mancing")
		local jualSemua = mancing and mancing:FindFirstChild("JualSemua")
		if jualSemua then jualSemua:InvokeServer() end
		task.wait(0.8)
		if getgenv().AutoFishingEventRunning then
			hrp.CFrame = currentSpotCFrame
		end
	end)
end

local function GetInventoryRemote()
	local repStorage = game:GetService("ReplicatedStorage")
	return repStorage:FindFirstChild("Remote")
		and repStorage.Remote:FindFirstChild("Mancing")
		and repStorage.Remote.Mancing:FindFirstChild("TandaiFavorit")
end

local function GetServerFishData()
	local fishDataList = {}
	pcall(function()
		local repStorage = game:GetService("ReplicatedStorage")
		local ambilSemuaRemote = repStorage:FindFirstChild("Remote")
			and repStorage.Remote:FindFirstChild("Inventaris")
			and repStorage.Remote.Inventaris:FindFirstChild("AmbilSemua")
		
		if ambilSemuaRemote then
			local result = {ambilSemuaRemote:InvokeServer()}
			local data = result[1]
			if type(data) == "table" then
				for _, fish in ipairs(data) do
					if type(fish) == "table" and (fish.uid or fish.UUID) then
						table.insert(fishDataList, {
							UUID = tostring(fish.uid or fish.UUID),
							Name = tostring(fish.nama or fish.Name or ""),
							Rarity = tostring(fish.rarity or fish.Rarity or ""),
							Mutation = tostring(fish.mutasi or fish.Mutation or ""),
							IsFavorited = fish.favorit or fish.IsFavorit or fish.IsFavorite or false
						})
					end
				end
			end
		end
	end)
	return fishDataList
end

local function ProcessAutoFavorite()
	pcall(function()
		local tandaiRemote = GetInventoryRemote()
		if not tandaiRemote then return end
		local serverData = GetServerFishData()
		for _, fish in ipairs(serverData) do
			if not getgenv().AutoFavoriteRunning then break end
			local shouldFav = false
			local fishRarityLower = string.lower(fish.Rarity)
			local fishMutationLower = string.lower(fish.Mutation)
			
			for rName, active in pairs(getgenv().FavRarities) do
				if active and string.lower(rName) == fishRarityLower then shouldFav = true end
			end
			for mName, active in pairs(getgenv().FavMutations) do
				if active and string.find(fishMutationLower, string.lower(mName)) then shouldFav = true end
			end
			
			if shouldFav and not fish.IsFavorited then
				tandaiRemote:FireServer(fish.UUID, true)
				task.wait(0.12)
			end
		end
	end)
end

task.spawn(function()
	while true do
		if getgenv().AutoFavoriteRunning then ProcessAutoFavorite() end
		task.wait(2.5)
	end
end)

local function UnfavoriteAllFish()
	task.spawn(function()
		pcall(function()
			local tandaiRemote = GetInventoryRemote()
			if not tandaiRemote then return end
			local serverData = GetServerFishData()
			for _, fish in ipairs(serverData) do
				tandaiRemote:FireServer(fish.UUID, false)
				task.wait(0.08)
			end
		end)
	end)
end

local function UnfavoriteByFilter()
	task.spawn(function()
		pcall(function()
			local tandaiRemote = GetInventoryRemote()
			if not tandaiRemote then return end
			local serverData = GetServerFishData()
			for _, fish in ipairs(serverData) do
				local shouldUnfav = false
				local fishRarityLower = string.lower(fish.Rarity)
				local fishMutationLower = string.lower(fish.Mutation)
				for rName, active in pairs(getgenv().UnfavRarities) do
					if active and string.lower(rName) == fishRarityLower then shouldUnfav = true end
				end
				for mName, active in pairs(getgenv().UnfavMutations) do
					if active and string.find(fishMutationLower, string.lower(mName)) then shouldUnfav = true end
				end
				if shouldUnfav and fish.IsFavorited then
					tandaiRemote:FireServer(fish.UUID, false)
					task.wait(0.08)
				end
			end
		end)
	end)
end

------------------------------------------------------------------
-- TRADE UTILITIES (AUTO ADD, REQUEST, ACCEPT)
------------------------------------------------------------------
local function GetTradeRemote(actionName)
	pcall(function()
		local tradeFolder = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Trade")
		if tradeFolder and tradeFolder:FindFirstChild(actionName) then
			return tradeFolder[actionName]
		end
	end)
	return nil
end

local function AutoAddAllFishToTrade()
	pcall(function()
		local serverData = GetServerFishData()
		local tradeRemote = GetTradeRemote("AddItem") or GetTradeRemote("AddFish") or ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Trade") and ReplicatedStorage.Remote.Trade:FindFirstChild("TambahItem")
		for _, fish in ipairs(serverData) do
			if tradeRemote then
				if tradeRemote:IsA("RemoteEvent") then
					tradeRemote:FireServer(fish.UUID)
				elseif tradeRemote:IsA("RemoteFunction") then
					tradeRemote:InvokeServer(fish.UUID)
				end
				task.wait(0.05)
			end
		end
	end)
end

local function SendTradeRequestToTarget()
	pcall(function()
		local targetName = getgenv().TyoConfig.SelectedTradeTarget
		if not targetName or targetName == "" then return end
		local targetPlayer = Players:FindFirstChild(targetName)
		if targetPlayer then
			local reqRemote = GetTradeRemote("Request") or GetTradeRemote("SendRequest") or ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Trade") and ReplicatedStorage.Remote.Trade:FindFirstChild("KirimRequest")
			if reqRemote then
				if reqRemote:IsA("RemoteEvent") then
					reqRemote:FireServer(targetPlayer)
				elseif reqRemote:IsA("RemoteFunction") then
					reqRemote:InvokeServer(targetPlayer)
				end
			end
		end
	end)
end

-- Auto Accept Trade listener
task.spawn(function()
	while true do
		if getgenv().AutoAcceptTradeRunning then
			pcall(function()
				local acceptRemote = GetTradeRemote("Accept") or GetTradeRemote("TerimaTrade")
				if acceptRemote then
					if acceptRemote:IsA("RemoteEvent") then
						acceptRemote:FireServer()
					elseif acceptRemote:IsA("RemoteFunction") then
						acceptRemote:InvokeServer()
					end
				end
			end)
		end
		task.wait(1)
	end
end)

pcall(function()
	local oldGui = PlayerGui:FindFirstChild("TyoHub")
	if oldGui then oldGui:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "TyoHub"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false

local function MakeDraggable(guiObject, handleObject)
	handleObject = handleObject or guiObject
	local dragging, dragInput, dragStart, startPos
	local function update(input)
		local delta = input.Position - dragStart
		guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	handleObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	handleObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then update(input) end
	end)
end

----------------------------------------------------
-- MAIN HUB UI (SPEED HUB STYLE: DARK RED/GRAY ACCENT)
----------------------------------------------------
local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Visible = true
Main.Size = UDim2.new(0,550,0,320)
Main.Position = UDim2.new(0.5,-275,0.5,-160)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 22) -- Gaya Speed Hub Dark
Main.ClipsDescendants = true
MakeDraggable(Main)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(200, 45, 45) -- Aksen Merah Speed Hub
MainStroke.Thickness = 1.5

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Parent = Main
ControlsFrame.Size = UDim2.new(0, 65, 0, 30)
ControlsFrame.Position = UDim2.new(1, -70, 0, 5)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.ZIndex = 10

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.Parent = ControlsFrame
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlLayout.Padding = UDim.new(0, 5)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = ControlsFrame
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.ZIndex = 11

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 4)
minCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = ControlsFrame
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.ZIndex = 11

local clsCorner = Instance.new("UICorner")
clsCorner.CornerRadius = UDim.new(0, 4)
clsCorner.Parent = CloseBtn

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = Main
PingLabel.Size = UDim2.new(0,150,0,25)
PingLabel.Position = UDim2.new(1,-225,0,7)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "Ping: Menghitung..."
PingLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextSize = 12
PingLabel.TextXAlignment = Enum.TextXAlignment.Right

task.spawn(function()
	while true do
		pcall(function()
			local pingVal = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			PingLabel.Text = "📡 Ping: " .. pingVal .. " ms"
		end)
		task.wait(1)
	end
end)

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = Main
Sidebar.Size = UDim2.new(0,140,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
Sidebar.CanvasSize = UDim2.new(0,0,2.8,0)
Sidebar.ScrollBarThickness = 2
Sidebar.BorderSizePixel = 0

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = Sidebar

local HubTitle = Instance.new("TextLabel")
HubTitle.Parent = Sidebar
HubTitle.BackgroundTransparency = 1
HubTitle.Position = UDim2.new(0, 10, 0, 8)
HubTitle.Size = UDim2.new(1, -10, 0, 22)
HubTitle.Text = "Speed Hub X" -- Nuansa Speed Hub
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(220, 50, 50)
HubTitle.TextSize = 15

local HubSubTitle = Instance.new("TextLabel")
HubSubTitle.Parent = Sidebar
HubSubTitle.BackgroundTransparency = 1
HubSubTitle.Position = UDim2.new(0, 10, 0, 28)
HubSubTitle.Size = UDim2.new(1, -10, 0, 18)
HubSubTitle.Text = "🏔️ Mount Soreya"
HubSubTitle.Font = Enum.Font.GothamBold
HubSubTitle.TextColor3 = Color3.fromRGB(150, 150, 160)
HubSubTitle.TextSize = 11

local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.new(0,145,0,35)
Content.Size = UDim2.new(1,-150,1,-40)
Content.BackgroundTransparency = 1

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	MinimizeBtn.Text = isMinimized and "+" or "-"
	Main:TweenSize(isMinimized and UDim2.new(0,550,0,38) or UDim2.new(0,550,0,320), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
	Sidebar.Visible = not isMinimized
	Content.Visible = not isMinimized
	PingLabel.Visible = not isMinimized
end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local function CreateNavButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Parent = Sidebar
	btn.Position = UDim2.new(0, 8, 0, yPos)
	btn.Size = UDim2.new(1, -16, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	btn.Text = "  " .. text
	btn.TextColor3 = Color3.fromRGB(200, 200, 210)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = btn
	return btn
end

local HomeBtn = CreateNavButton("Fishing & Sell", 55)
local FavoriteBtn = CreateNavButton("⭐ Favorite", 90)
local TradeBtn = CreateNavButton("🤝 Auto Trade", 125)
local GalatamaBtn = CreateNavButton("Galatama", 160)
local TeleportShopBtn = CreateNavButton("Teleport Shop", 195)
local SummitBtn = CreateNavButton("Summit", 230)
local PlayerMenuBtn = CreateNavButton("Player", 265)
local HaloMenuBtn = CreateNavButton("Halo Kepala", 300)
local PlayerTpBtn = CreateNavButton("Teleport Player", 335)
local PrivacyBtn = CreateNavButton("Privacy", 370)
local SettingsBtn = CreateNavButton("Settings", 405)
local CreditsBtn = CreateNavButton("Credits", 440)

local function MakePage()
	local f = Instance.new("ScrollingFrame")
	f.Parent = Content
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.CanvasSize = UDim2.new(0,0,6,0)
	f.ScrollBarThickness = 3
	local pad = Instance.new("UIPadding")
	pad.Parent = f
	pad.PaddingTop = UDim.new(0, 5)
	pad.PaddingRight = UDim.new(0, 8)
	local l = Instance.new("UIListLayout")
	l.Parent = f
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 6)
	return f
end

local FishingPage = MakePage()
FishingPage.Visible = true
local FavoritePage = MakePage()
local TradePage = MakePage()
local GalatamaPage = MakePage()
local TeleportShopPage = MakePage()
local SummitPage = MakePage()
local PlayerPage = MakePage()
local HaloPage = MakePage()
local PlayerTpPage = MakePage()
local PrivacyPage = MakePage()
local SettingsPage = MakePage()
local CreditsPage = MakePage()

local function HideAll()
	FishingPage.Visible = false
	FavoritePage.Visible = false
	TradePage.Visible = false
	GalatamaPage.Visible = false
	TeleportShopPage.Visible = false
	SummitPage.Visible = false
	PlayerPage.Visible = false
	HaloPage.Visible = false
	PlayerTpPage.Visible = false
	PrivacyPage.Visible = false
	SettingsPage.Visible = false
	CreditsPage.Visible = false
end

HomeBtn.MouseButton1Click:Connect(function() HideAll(); FishingPage.Visible = true end)
FavoriteBtn.MouseButton1Click:Connect(function() HideAll(); FavoritePage.Visible = true end)
TradeBtn.MouseButton1Click:Connect(function() HideAll(); TradePage.Visible = true end)
GalatamaBtn.MouseButton1Click:Connect(function() HideAll(); GalatamaPage.Visible = true end)
TeleportShopBtn.MouseButton1Click:Connect(function() HideAll(); TeleportShopPage.Visible = true end)
SummitBtn.MouseButton1Click:Connect(function() HideAll(); SummitPage.Visible = true end)
PlayerMenuBtn.MouseButton1Click:Connect(function() HideAll(); PlayerPage.Visible = true end)
HaloMenuBtn.MouseButton1Click:Connect(function() HideAll(); HaloPage.Visible = true end)
PlayerTpBtn.MouseButton1Click:Connect(function() HideAll(); PlayerTpPage.Visible = true end)
PrivacyBtn.MouseButton1Click:Connect(function() HideAll(); PrivacyPage.Visible = true end)
SettingsBtn.MouseButton1Click:Connect(function() HideAll(); SettingsPage.Visible = true end)
CreditsBtn.MouseButton1Click:Connect(function() HideAll(); CreditsPage.Visible = true end)

local function AddToggle(parent, text, callback)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1,0,0,32)
	b.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	b.Text = "  " .. text .. " [OFF]"
	b.TextColor3 = Color3.fromRGB(210, 210, 220)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.TextXAlignment = Enum.TextXAlignment.Left
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = b
	local state = false
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = "  " .. text .. (state and " [ON]" : " [OFF]")
		b.BackgroundColor3 = state and Color3.fromRGB(180, 45, 45) or Color3.fromRGB(24, 24, 32)
		callback(state)
	end)
end

----------------------------------------------------
-- 1. FISHING PAGE
----------------------------------------------------
local TitleFish = Instance.new("TextLabel")
TitleFish.Parent = FishingPage
TitleFish.Size = UDim2.new(1,0,0,25)
TitleFish.BackgroundTransparency = 1
TitleFish.Text = "🔥 AUTO FISHING & SELL (MOUNT SOREYA)"
TitleFish.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleFish.Font = Enum.Font.GothamBold
TitleFish.TextSize = 12

local SpotDropdownFrame = Instance.new("Frame")
SpotDropdownFrame.Parent = FishingPage
SpotDropdownFrame.Size = UDim2.new(1,0,0,32)
SpotDropdownFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
SpotDropdownFrame.ClipsDescendants = true
local sdc = Instance.new("UICorner")
sdc.CornerRadius = UDim.new(0, 5)
sdc.Parent = SpotDropdownFrame

local DropHeader = Instance.new("TextButton")
DropHeader.Parent = SpotDropdownFrame
DropHeader.Size = UDim2.new(1,0,0,32)
DropHeader.BackgroundTransparency = 1
DropHeader.Text = "  📍 Spot: " .. (getgenv().SelectedFishingSpot or "Spot Mancing Jembatan") .. " 🔽"
DropHeader.TextColor3 = Color3.fromRGB(220, 60, 60)
DropHeader.Font = Enum.Font.GothamBold
DropHeader.TextSize = 11
DropHeader.TextXAlignment = Enum.TextXAlignment.Left

local function SetSpotDisplay(text)
	DropHeader.Text = "  📍 Spot: " .. tostring(text) .. " 🔽"
end

local DropContainer = Instance.new("Frame")
DropContainer.Parent = SpotDropdownFrame
DropContainer.Position = UDim2.new(0, 5, 0, 32)
DropContainer.Size = UDim2.new(1, -10, 0, 95)
DropContainer.BackgroundTransparency = 1

local DropLayout = Instance.new("UIListLayout")
DropLayout.Parent = DropContainer
DropLayout.Padding = UDim.new(0, 4)

local isDropOpen = false
DropHeader.MouseButton1Click:Connect(function()
	isDropOpen = not isDropOpen
	SpotDropdownFrame:TweenSize(isDropOpen and UDim2.new(1,0,0,130) or UDim2.new(1,0,0,32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
end)

for _, spotName in ipairs({"Spot Mancing Jembatan", "Spot Mancing Core", "Spot Mancing Ikan Anomali"}) do
	local optBtn = Instance.new("TextButton")
	optBtn.Parent = DropContainer
	optBtn.Size = UDim2.new(1,0,0,26)
	optBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
	optBtn.Text = "  " .. spotName
	optBtn.TextColor3 = Color3.new(1,1,1)
	optBtn.Font = Enum.Font.Gotham
	optBtn.TextSize = 11
	optBtn.TextXAlignment = Enum.TextXAlignment.Left
	local obc = Instance.new("UICorner")
	obc.CornerRadius = UDim.new(0, 4)
	obc.Parent = optBtn
	
	optBtn.MouseButton1Click:Connect(function()
		getgenv().SelectedFishingSpot = spotName
		getgenv().TyoConfig.SelectedSpot = spotName
		SetSpotDisplay(spotName)
		isDropOpen = false
		SpotDropdownFrame:TweenSize(UDim2.new(1,0,0,32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
		SaveConfig()
	end)
end

local ModeDropdownFrame = Instance.new("Frame")
ModeDropdownFrame.Parent = FishingPage
ModeDropdownFrame.Size = UDim2.new(1,0,0,32)
ModeDropdownFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
ModeDropdownFrame.ClipsDescendants = true
local mdc = Instance.new("UICorner")
mdc.CornerRadius = UDim.new(0, 5)
mdc.Parent = ModeDropdownFrame

local ModeDropHeader = Instance.new("TextButton")
ModeDropHeader.Parent = ModeDropdownFrame
ModeDropHeader.Size = UDim2.new(1,0,0,32)
ModeDropHeader.BackgroundTransparency = 1
ModeDropHeader.Text = "  🎮 Mode Fishing: " .. (getgenv().TyoConfig.MinigameMode or "Legit") .. " 🔽"
ModeDropHeader.TextColor3 = Color3.fromRGB(255, 180, 0)
ModeDropHeader.Font = Enum.Font.GothamBold
ModeDropHeader.TextSize = 11
ModeDropHeader.TextXAlignment = Enum.TextXAlignment.Left

local ModeDropContainer = Instance.new("Frame")
ModeDropContainer.Parent = ModeDropdownFrame
ModeDropContainer.Position = UDim2.new(0, 5, 0, 32)
ModeDropContainer.Size = UDim2.new(1, -10, 0, 60)
ModeDropContainer.BackgroundTransparency = 1

local ModeDropLayout = Instance.new("UIListLayout")
ModeDropLayout.Parent = ModeDropContainer
ModeDropLayout.Padding = UDim.new(0, 4)

local isModeDropOpen = false
ModeDropHeader.MouseButton1Click:Connect(function()
	isModeDropOpen = not isModeDropOpen
	ModeDropdownFrame:TweenSize(isModeDropOpen and UDim2.new(1,0,0,95) or UDim2.new(1,0,0,32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
end)

local fishingModes = {
	{ Name = "Legit Fishing (Auto Bawaan + Tap-Tap)", Value = "Legit" },
	{ Name = "Instant Fishing (Bypass Cepat)", Value = "Instant" }
}

for _, modeData in ipairs(fishingModes) do
	local mOptBtn = Instance.new("TextButton")
	mOptBtn.Parent = ModeDropContainer
	mOptBtn.Size = UDim2.new(1,0,0,26)
	mOptBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
	mOptBtn.Text = "  " .. modeData.Name
	mOptBtn.TextColor3 = Color3.new(1,1,1)
	mOptBtn.Font = Enum.Font.Gotham
	mOptBtn.TextSize = 11
	mOptBtn.TextXAlignment = Enum.TextXAlignment.Left
	local mobc = Instance.new("UICorner")
	mobc.CornerRadius = UDim.new(0, 4)
	mobc.Parent = mOptBtn
	
	mOptBtn.MouseButton1Click:Connect(function()
		local oldMode = getgenv().TyoConfig.MinigameMode
		getgenv().TyoConfig.MinigameMode = modeData.Value
		ModeDropHeader.Text = "  🎮 Mode Fishing: " .. modeData.Value .. " 🔽"
		isModeDropOpen = false
		ModeDropdownFrame:TweenSize(UDim2.new(1,0,0,32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
		SaveConfig()
		if oldMode ~= modeData.Value then
			task.spawn(function()
				local wasRunning = getgenv().AutoFishingEventRunning
				getgenv().FishLoopId = getgenv().FishLoopId + 1
				EnableGameAutoFishing(false)
				task.wait(0.6)
				RestoreRodSettings()
				pcall(function()
					local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum:UnequipTools() end
				end)
				task.wait(0.4)
				AutoEquipRod()
				if wasRunning and getgenv().AutoFishingEventRunning then StartFishingLoop() end
			end)
		end
	end)
end

AddToggle(FishingPage, "Smart Auto Fishing + Teleport", function(v)
	getgenv().AutoFishingEventRunning = v
	if v then
		pcall(function()
			local hrp = LocalPlayer.Character and LocalPlayer.Character:WaitForChild("HumanoidRootPart", 5)
			if hrp then hrp.CFrame = FishingSpots[getgenv().SelectedFishingSpot] + Vector3.new(0, 5, 0) end
		end)
		StartFishingLoop()
	end
end)

AddToggle(FishingPage, "Smart Auto Fishing (Di Tempat Saja)", function(v)
	getgenv().AutoFishingEventRunning = v
	if v then StartFishingLoop() end
end)

local BiteDelayBox = Instance.new("TextBox")
BiteDelayBox.Parent = FishingPage
BiteDelayBox.Size = UDim2.new(1,0,0,32)
BiteDelayBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
BiteDelayBox.PlaceholderText = "Bite Delay (Detik, Cth: 0.5) - Mode Instant"
BiteDelayBox.Text = tostring(getgenv().TyoConfig.BiteDelay)
BiteDelayBox.TextColor3 = Color3.new(1,1,1)
BiteDelayBox.Font = Enum.Font.Gotham
BiteDelayBox.TextSize = 12
local bdCorner = Instance.new("UICorner")
bdCorner.CornerRadius = UDim.new(0, 5)
bdCorner.Parent = BiteDelayBox
BiteDelayBox.FocusLost:Connect(function()
	getgenv().BiteDelayInput = BiteDelayBox.Text
	getgenv().TyoConfig.BiteDelay = BiteDelayBox.Text
	SaveConfig()
end)

local TapDelayBox = Instance.new("TextBox")
TapDelayBox.Parent = FishingPage
TapDelayBox.Size = UDim2.new(1,0,0,32)
TapDelayBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
TapDelayBox.PlaceholderText = "Jeda Tap (Detik, Cth: 0.12) - Mode Legit"
TapDelayBox.Text = tostring(getgenv().TyoConfig.TapDelay or "0.12")
TapDelayBox.TextColor3 = Color3.new(1,1,1)
TapDelayBox.Font = Enum.Font.Gotham
TapDelayBox.TextSize = 12
local tdCorner = Instance.new("UICorner")
tdCorner.CornerRadius = UDim.new(0, 5)
tdCorner.Parent = TapDelayBox
TapDelayBox.FocusLost:Connect(function()
	getgenv().TyoConfig.TapDelay = TapDelayBox.Text
	SaveConfig()
end)

AddToggle(FishingPage, "Auto Sell Timer ke NPC", function(v)
	getgenv().AutoSellRunning = v
	if v then
		task.spawn(function()
			local lastSellTime = tick()
			while getgenv().AutoSellRunning do
				task.wait(1)
				if ((tick() - lastSellTime) / 60) >= (tonumber(getgenv().AutoSellTimerInput) or 5) then
					TriggerSellToNpc()
					lastSellTime = tick()
				end
			end
		end)
	end
end)

local SellTimerBox = Instance.new("TextBox")
SellTimerBox.Parent = FishingPage
SellTimerBox.Size = UDim2.new(1,0,0,32)
SellTimerBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
SellTimerBox.PlaceholderText = "Jeda Waktu Jual (Menit, Cth: 5)"
SellTimerBox.Text = tostring(getgenv().TyoConfig.AutoSellTimer)
SellTimerBox.TextColor3 = Color3.new(1,1,1)
SellTimerBox.Font = Enum.Font.Gotham
SellTimerBox.TextSize = 12
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 5)
stCorner.Parent = SellTimerBox
SellTimerBox.FocusLost:Connect(function()
	getgenv().AutoSellTimerInput = SellTimerBox.Text
	getgenv().TyoConfig.AutoSellTimer = SellTimerBox.Text
	SaveConfig()
end)

----------------------------------------------------
-- SYSTEM ROTASI / LOOP SPOT MANCING
----------------------------------------------------
local TitleLoop = Instance.new("TextLabel")
TitleLoop.Parent = FishingPage
TitleLoop.Size = UDim2.new(1,0,0,25)
TitleLoop.BackgroundTransparency = 1
TitleLoop.Text = "⏳ ROTASI AUTO SPOT MANCING (TIMER)"
TitleLoop.TextColor3 = Color3.fromRGB(0, 200, 140)
TitleLoop.Font = Enum.Font.GothamBold
TitleLoop.TextSize = 12

AddToggle(FishingPage, "Aktifkan Loop Spot Mancing (Timer)", function(v) getgenv().LoopSpotEnabled = v end)

local function CreateSpotTimerSetting(parent, spotName)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1,0,0,32)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 5)
	fc.Parent = frame
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Parent = frame
	toggleBtn.Size = UDim2.new(0.65,0,1,0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = "  " .. spotName .. " [OFF]"
	toggleBtn.TextColor3 = Color3.new(1,1,1)
	toggleBtn.Font = Enum.Font.Gotham
	toggleBtn.TextSize = 11
	toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
	local timeBox = Instance.new("TextBox")
	timeBox.Parent = frame
	timeBox.Size = UDim2.new(0.3, -5, 0, 24)
	timeBox.Position = UDim2.new(0.7, 0, 0, 4)
	timeBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	timeBox.Text = getgenv().SpotLoopConfig[spotName].Timer
	timeBox.PlaceholderText = "Menit"
	timeBox.TextColor3 = Color3.fromRGB(220, 60, 60)
	timeBox.Font = Enum.Font.GothamBold
	timeBox.TextSize = 11
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 4)
	tc.Parent = timeBox
	toggleBtn.MouseButton1Click:Connect(function()
		local cur = not getgenv().SpotLoopConfig[spotName].Enabled
		getgenv().SpotLoopConfig[spotName].Enabled = cur
		toggleBtn.Text = "  " .. spotName .. (cur and " [ON]" or " [OFF]")
		toggleBtn.TextColor3 = cur and Color3.fromRGB(0, 255, 150) or Color3.new(1,1,1)
	end)
	timeBox.FocusLost:Connect(function() getgenv().SpotLoopConfig[spotName].Timer = timeBox.Text end)
end

CreateSpotTimerSetting(FishingPage, "Spot Mancing Jembatan")
CreateSpotTimerSetting(FishingPage, "Spot Mancing Core")
CreateSpotTimerSetting(FishingPage, "Spot Mancing Ikan Anomali")

task.spawn(function()
	local spotOrder = {"Spot Mancing Jembatan", "Spot Mancing Core", "Spot Mancing Ikan Anomali"}
	while true do
		if getgenv().LoopSpotEnabled and not getgenv().AutoDetectCoreEvent then
			for _, name in ipairs(spotOrder) do
				local cfg = getgenv().SpotLoopConfig[name]
				if getgenv().LoopSpotEnabled and cfg and cfg.Enabled then
					getgenv().SelectedFishingSpot = name
					SetSpotDisplay(name)
					pcall(function()
						local character = LocalPlayer.Character
						local hrp = character and character:FindFirstChild("HumanoidRootPart")
						local targetCFrame = FishingSpots[name]
						if hrp and targetCFrame then hrp.CFrame = targetCFrame + Vector3.new(0, 5, 0) end
					end)
					local duration = (tonumber(cfg.Timer) or 10) * 60
					local timerStart = tick()
					while getgenv().LoopSpotEnabled and cfg.Enabled and (tick() - timerStart < duration) do
						task.wait(1)
					end
				end
			end
		end
		task.wait(1)
	end
end)

----------------------------------------------------
-- DROPDOWN BUILDER (UNIVERSAL MULTI-SELECT)
----------------------------------------------------
local function CreateMultiSelectDropdown(parent, titleText, optionsTable, targetStateTable)
	local container = Instance.new("Frame")
	container.Parent = parent
	container.Size = UDim2.new(1,0,0,35)
	container.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	container.ClipsDescendants = true
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 5)
	cc.Parent = container
	local header = Instance.new("TextButton")
	header.Parent = container
	header.Size = UDim2.new(1,0,0,35)
	header.BackgroundTransparency = 1
	header.Text = "  " .. titleText
	header.TextColor3 = Color3.new(1,1,1)
	header.Font = Enum.Font.GothamMedium
	header.TextSize = 12
	header.TextXAlignment = Enum.TextXAlignment.Left
	local countLabel = Instance.new("TextLabel")
	countLabel.Parent = header
	countLabel.Size = UDim2.new(0,120,1,0)
	countLabel.Position = UDim2.new(1,-130,0,0)
	countLabel.BackgroundTransparency = 1
	countLabel.TextColor3 = Color3.fromRGB(220, 60, 60)
	countLabel.Font = Enum.Font.GothamBold
	countLabel.TextSize = 11
	countLabel.TextXAlignment = Enum.TextXAlignment.Right
	local optionsHolder = Instance.new("Frame")
	optionsHolder.Parent = container
	optionsHolder.Position = UDim2.new(0,5,0,35)
	optionsHolder.Size = UDim2.new(1,-10,0,0)
	optionsHolder.BackgroundTransparency = 1
	local listLayout = Instance.new("UIListLayout")
	listLayout.Parent = optionsHolder
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	local itemButtons = {}
	local function UpdateSummary()
		local selectedCount = 0
		for _, active in pairs(targetStateTable) do if active then selectedCount = selectedCount + 1 end end
		if selectedCount == 0 then countLabel.Text = "None 🔽"
		elseif selectedCount == #optionsTable then countLabel.Text = "All (" .. selectedCount .. ") 🔽"
		else countLabel.Text = selectedCount .. " Selected 🔽" end
	end
	local selectAllBtn = Instance.new("TextButton")
	selectAllBtn.Parent = optionsHolder
	selectAllBtn.Size = UDim2.new(1,0,0,26)
	selectAllBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
	selectAllBtn.Text = "  ⚡ SELECT ALL / UNSELECT ALL"
	selectAllBtn.TextColor3 = Color3.new(1,1,1)
	selectAllBtn.Font = Enum.Font.GothamBold
	selectAllBtn.TextSize = 11
	selectAllBtn.TextXAlignment = Enum.TextXAlignment.Left
	local saCorner = Instance.new("UICorner")
	saCorner.CornerRadius = UDim.new(0, 4)
	saCorner.Parent = selectAllBtn
	local allState = false
	selectAllBtn.MouseButton1Click:Connect(function()
		allState = not allState
		for _, optName in ipairs(optionsTable) do targetStateTable[optName] = allState end
		for optName, btn in pairs(itemButtons) do
			btn.BackgroundColor3 = allState and Color3.fromRGB(180, 45, 45) or Color3.fromRGB(32, 32, 42)
			btn.Text = "  " .. optName .. (allState and " [✓]" or " [ ]")
		end
		UpdateSummary()
		SaveConfig()
	end)
	for _, optName in ipairs(optionsTable) do
		local optBtn = Instance.new("TextButton")
		optBtn.Parent = optionsHolder
		optBtn.Size = UDim2.new(1,0,0,26)
		optBtn.BackgroundColor3 = targetStateTable[optName] and Color3.fromRGB(180, 45, 45) or Color3.fromRGB(32, 32, 42)
		optBtn.Text = "  " .. optName .. (targetStateTable[optName] and " [✓]" or " [ ]")
		optBtn.TextColor3 = Color3.new(1,1,1)
		optBtn.Font = Enum.Font.Gotham
		optBtn.TextSize = 11
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		local obc = Instance.new("UICorner")
		obc.CornerRadius = UDim.new(0, 4)
		obc.Parent = optBtn
		itemButtons[optName] = optBtn
		optBtn.MouseButton1Click:Connect(function()
			targetStateTable[optName] = not targetStateTable[optName]
			optBtn.BackgroundColor3 = targetStateTable[optName] and Color3.fromRGB(180, 45, 45) or Color3.fromRGB(32, 32, 42)
			optBtn.Text = "  " .. optName .. (targetStateTable[optName] and " [✓]" or " [ ]")
			UpdateSummary()
			SaveConfig()
		end)
	end
	UpdateSummary()
	local isOpen = false
	header.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		container:TweenSize(isOpen and UDim2.new(1,0,0, 40 + ((#optionsTable + 1) * 30)) or UDim2.new(1,0,0,35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
	end)
end

----------------------------------------------------
-- 2. FAVORITE PAGE
----------------------------------------------------
local TitleFav = Instance.new("TextLabel")
TitleFav.Parent = FavoritePage
TitleFav.Size = UDim2.new(1,0,0,25)
TitleFav.BackgroundTransparency = 1
TitleFav.Text = "⭐ AUTO FAVORITE FILTER (BUAT PET AETHER)"
TitleFav.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleFav.Font = Enum.Font.GothamBold
TitleFav.TextSize = 12

AddToggle(FavoritePage, "AUTO FAVORITE (SECRET & AETHER)", function(v) getgenv().AutoFavoriteRunning = v end)

local rarityList = {"Common", "UnCommon", "Rare", "Epic", "Legendary", "Mythical", "Secret", "Forgotten", "Aether"}
local mutationList = {
	"Galaxy", "Corrupt", "Gemstone", "Ghost", "Lightning", "Fairy Dust", 
	"Gold", "Midnight", "Radioactive", "Stone", "Holographic", "Albino", "Sandy", "Cosmic", 
	"Elemental", "Festive", "8-Bit", "Bloodmoon", "Abyssal", "Strawberry", "Void", "Cupid"
}

CreateMultiSelectDropdown(FavoritePage, "Fav Filter Rarity", rarityList, getgenv().FavRarities)
CreateMultiSelectDropdown(FavoritePage, "Fav Filter Mutasi", mutationList, getgenv().FavMutations)

local TitleUnfav = Instance.new("TextLabel")
TitleUnfav.Parent = FavoritePage
TitleUnfav.Size = UDim2.new(1,0,0,25)
TitleUnfav.BackgroundTransparency = 1
TitleUnfav.Text = "🗑️ UNFAVORITE FILTER SETTINGS"
TitleUnfav.TextColor3 = Color3.fromRGB(255, 100, 100)
TitleUnfav.Font = Enum.Font.GothamBold
TitleUnfav.TextSize = 12

CreateMultiSelectDropdown(FavoritePage, "Unfav Filter Rarity", rarityList, getgenv().UnfavRarities)
CreateMultiSelectDropdown(FavoritePage, "Unfav Filter Mutasi", mutationList, getgenv().UnfavMutations)

local UnfavFilterBtn = Instance.new("TextButton")
UnfavFilterBtn.Parent = FavoritePage
UnfavFilterBtn.Size = UDim2.new(1,0,0,35)
UnfavFilterBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 30)
UnfavFilterBtn.Text = "🎯 UNFAVORITE BY FILTER"
UnfavFilterBtn.TextColor3 = Color3.new(1,1,1)
UnfavFilterBtn.Font = Enum.Font.GothamBold
UnfavFilterBtn.TextSize = 12
local ufc = Instance.new("UICorner")
ufc.CornerRadius = UDim.new(0, 5)
ufc.Parent = UnfavFilterBtn
UnfavFilterBtn.MouseButton1Click:Connect(function() UnfavoriteByFilter() end)

local UnfavBtn = Instance.new("TextButton")
UnfavBtn.Parent = FavoritePage
UnfavBtn.Size = UDim2.new(1,0,0,35)
UnfavBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
UnfavBtn.Text = "🚨 UNFAVORITE ALL FISH"
UnfavBtn.TextColor3 = Color3.new(1,1,1)
UnfavBtn.Font = Enum.Font.GothamBold
UnfavBtn.TextSize = 12
local uac = Instance.new("UICorner")
uac.CornerRadius = UDim.new(0, 5)
uac.Parent = UnfavBtn
UnfavBtn.MouseButton1Click:Connect(function() UnfavoriteAllFish() end)

----------------------------------------------------
-- 3. AUTO TRADE PAGE
----------------------------------------------------
local TitleTrade = Instance.new("TextLabel")
TitleTrade.Parent = TradePage
TitleTrade.Size = UDim2.new(1,0,0,25)
TitleTrade.BackgroundTransparency = 1
TitleTrade.Text = "🤝 AUTO TRADE & MULTI-ACCOUNT UTILITIES"
TitleTrade.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleTrade.Font = Enum.Font.GothamBold
TitleTrade.TextSize = 12

local RefreshTradePlayersBtn = Instance.new("TextButton")
RefreshTradePlayersBtn.Parent = TradePage
RefreshTradePlayersBtn.Size = UDim2.new(1,0,0,32)
RefreshTradePlayersBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
RefreshTradePlayersBtn.Text = "🔄 Refresh Player di Trade"
RefreshTradePlayersBtn.TextColor3 = Color3.new(1,1,1)
RefreshTradePlayersBtn.Font = Enum.Font.GothamBold
RefreshTradePlayersBtn.TextSize = 12
local rtpb = Instance.new("UICorner")
rtpb.CornerRadius = UDim.new(0, 5)
rtpb.Parent = RefreshTradePlayersBtn

local TradeTargetDropFrame = Instance.new("Frame")
TradeTargetDropFrame.Parent = TradePage
TradeTargetDropFrame.Size = UDim2.new(1,0,0,32)
TradeTargetDropFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
TradeTargetDropFrame.ClipsDescendants = true
local ttdc = Instance.new("UICorner")
ttdc.CornerRadius = UDim.new(0, 5)
ttdc.Parent = TradeTargetDropFrame

local TradeTargetHeader = Instance.new("TextButton")
TradeTargetHeader.Parent = TradeTargetDropFrame
TradeTargetHeader.Size = UDim2.new(1,0,0,32)
TradeTargetHeader.BackgroundTransparency = 1
TradeTargetHeader.Text = "  🎯 Target Trade: " .. (getgenv().TyoConfig.SelectedTradeTarget ~= "" and getgenv().TyoConfig.SelectedTradeTarget or "Pilih Player") .. " 🔽"
TradeTargetHeader.TextColor3 = Color3.fromRGB(255, 180, 0)
TradeTargetHeader.Font = Enum.Font.GothamBold
TradeTargetHeader.TextSize = 11
TradeTargetHeader.TextXAlignment = Enum.TextXAlignment.Left

local TradeTargetContainer = Instance.new("ScrollingFrame")
TradeTargetContainer.Parent = TradeTargetDropFrame
TradeTargetContainer.Position = UDim2.new(0, 5, 0, 32)
TradeTargetContainer.Size = UDim2.new(1, -10, 0, 130)
TradeTargetContainer.BackgroundTransparency = 1
TradeTargetContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TradeTargetContainer.ScrollBarThickness = 4

local TradeListLayout = Instance.new("UIListLayout")
TradeListLayout.Parent = TradeTargetContainer
TradeListLayout.Padding = UDim.new(0, 4)
TradeListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Otomatis atur CanvasSize untuk bisa scroll sampai ke paling bawah
TradeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	TradeTargetContainer.CanvasSize = UDim2.new(0, 0, 0, TradeListLayout.AbsoluteContentSize.Y + 10)
end)

local isTradeDropOpen = false
TradeTargetHeader.MouseButton1Click:Connect(function()
	isTradeDropOpen = not isTradeDropOpen
	TradeTargetDropFrame:TweenSize(isTradeDropOpen and UDim2.new(1,0,0,170) or UDim2.new(1,0,0,32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
end)

local function RefreshTradeTargets()
	for _, child in ipairs(TradeTargetContainer:GetChildren()) do 
		if child:IsA("TextButton") then child:Destroy() end 
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Parent = TradeTargetContainer
			btn.Size = UDim2.new(1, -5, 0, 28)
			btn.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
			btn.Text = "  👤 " .. plr.Name
			btn.TextColor3 = Color3.new(1,1,1)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 11
			btn.TextXAlignment = Enum.TextXAlignment.Left
			local bc = Instance.new("UICorner")
			bc.CornerRadius = UDim.new(0, 4)
			bc.Parent = btn
			btn.MouseButton1Click:Connect(function()
				getgenv().TyoConfig.SelectedTradeTarget = plr.Name
				TradeTargetHeader.Text = "  🎯 Target Trade: " .. plr.Name .. " 🔽"
				isTradeDropOpen = false
				TradeTargetDropFrame:TweenSize(UDim2.new(1,0,0,32), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
				SaveConfig()
			end)
		end
	end
end

RefreshTradeTargets()
RefreshTradePlayersBtn.MouseButton1Click:Connect(function()
	RefreshTradeTargets()
	RefreshTradePlayersBtn.Text = "✅ Daftar Player Diperbarui!"
	task.wait(1)
	RefreshTradePlayersBtn.Text = "🔄 Refresh Player di Trade"
end)

Players.PlayerAdded:Connect(RefreshTradeTargets)
Players.PlayerRemoving:Connect(RefreshTradeTargets)

local AddAllTradeBtn = Instance.new("TextButton")
AddAllTradeBtn.Parent = TradePage
AddAllTradeBtn.Size = UDim2.new(1,0,0,35)
AddAllTradeBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
AddAllTradeBtn.Text = "📦 Auto Add All Ikan ke Trade"
AddAllTradeBtn.TextColor3 = Color3.new(1,1,1)
AddAllTradeBtn.Font = Enum.Font.GothamBold
AddAllTradeBtn.TextSize = 12
local aatc = Instance.new("UICorner")
aatc.CornerRadius = UDim.new(0, 5)
aatc.Parent = AddAllTradeBtn
AddAllTradeBtn.MouseButton1Click:Connect(function() AutoAddAllFishToTrade() end)

local SendTradeReqBtn = Instance.new("TextButton")
SendTradeReqBtn.Parent = TradePage
SendTradeReqBtn.Size = UDim2.new(1,0,0,35)
SendTradeReqBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
SendTradeReqBtn.Text = "🚀 Kirim Request Trade ke Target"
SendTradeReqBtn.TextColor3 = Color3.new(1,1,1)
SendTradeReqBtn.Font = Enum.Font.GothamBold
SendTradeReqBtn.TextSize = 12
local strc = Instance.new("UICorner")
strc.CornerRadius = UDim.new(0, 5)
strc.Parent = SendTradeReqBtn
SendTradeReqBtn.MouseButton1Click:Connect(function() SendTradeRequestToTarget() end)

AddToggle(TradePage, "Auto Accept Trade (Terima Otomatis)", function(v) getgenv().AutoAcceptTradeRunning = v end)

----------------------------------------------------
-- 4. GALATAMA PAGE
----------------------------------------------------
local TitleGal = Instance.new("TextLabel")
TitleGal.Parent = GalatamaPage
TitleGal.Size = UDim2.new(1,0,0,25)
TitleGal.BackgroundTransparency = 1
TitleGal.Text = "🏆 GALATAMA & CORE EVENT UTILITIES"
TitleGal.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleGal.Font = Enum.Font.GothamBold
TitleGal.TextSize = 12

local TeleportGalatamaBtn = Instance.new("TextButton")
TeleportGalatamaBtn.Parent = GalatamaPage
TeleportGalatamaBtn.Size = UDim2.new(1,0,0,32)
TeleportGalatamaBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
TeleportGalatamaBtn.Text = "📍 Teleport ke Galatama"
TeleportGalatamaBtn.TextColor3 = Color3.new(1,1,1)
TeleportGalatamaBtn.Font = Enum.Font.GothamBold
TeleportGalatamaBtn.TextSize = 12
local tgc = Instance.new("UICorner")
tgc.CornerRadius = UDim.new(0, 5)
tgc.Parent = TeleportGalatamaBtn
TeleportGalatamaBtn.MouseButton1Click:Connect(function()
	pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8008.12744, 1227.96838, -6091.92627) + Vector3.new(0, 5, 0) end)
end)

AddToggle(GalatamaPage, "Aktifkan Auto Join Galatama", function(v)
	getgenv().AutoGalatamaRunning = v
	if v then
		task.spawn(function()
			while getgenv().AutoGalatamaRunning do
				pcall(function()
					local galatamaRemote = ReplicatedStorage:FindFirstChild("Remote")
						and ReplicatedStorage.Remote:FindFirstChild("Glatama")
						and ReplicatedStorage.Remote.Glatama:FindFirstChild("Ikut")
					if galatamaRemote then
						galatamaRemote:InvokeServer()
					end
				end)
				task.wait(10)
			end
		end)
	end
end)

local TitleCoreEvent = Instance.new("TextLabel")
TitleCoreEvent.Parent = GalatamaPage
TitleCoreEvent.Size = UDim2.new(1,0,0,25)
TitleCoreEvent.BackgroundTransparency = 1
TitleCoreEvent.Text = "💎 AUTO DETECT WITHERING CORE EVENT"
TitleCoreEvent.TextColor3 = Color3.fromRGB(255, 180, 0)
TitleCoreEvent.Font = Enum.Font.GothamBold
TitleCoreEvent.TextSize = 12

AddToggle(GalatamaPage, "Auto Teleport Saat Event Core Berlangsung", function(v) getgenv().AutoDetectCoreEvent = v end)

local SavedPreviousSpot = nil
local IsAtCoreEvent = false
task.spawn(function()
	while true do
		if getgenv().AutoDetectCoreEvent then
			pcall(function()
				local currentMinute = tonumber(os.date("%M"))
				local isEventTime = (currentMinute >= 0 and currentMinute <= 10)
				
				if isEventTime then
					if not IsAtCoreEvent then
						SavedPreviousSpot = getgenv().SelectedFishingSpot
						IsAtCoreEvent = true
					end
					getgenv().SelectedFishingSpot = "Spot Mancing Core"
					SetSpotDisplay("Spot Mancing Core (⚡ Event Core)")
					
					local character = LocalPlayer.Character
					local hrp = character and character:FindFirstChild("HumanoidRootPart")
					local targetCFrame = FishingSpots["Spot Mancing Core"]
					if hrp and targetCFrame then
						if (hrp.Position - targetCFrame.Position).Magnitude > 20 then
							hrp.CFrame = targetCFrame + Vector3.new(0, 5, 0)
						end
					end
				else
					if IsAtCoreEvent then
						IsAtCoreEvent = false
						if SavedPreviousSpot and FishingSpots[SavedPreviousSpot] then
							getgenv().SelectedFishingSpot = SavedPreviousSpot
							SetSpotDisplay(SavedPreviousSpot)
							
							local character = LocalPlayer.Character
							local hrp = character and character:FindFirstChild("HumanoidRootPart")
							local prevCFrame = FishingSpots[SavedPreviousSpot]
							if hrp and prevCFrame then
								hrp.CFrame = prevCFrame + Vector3.new(0, 5, 0)
							end
						end
					end
				end
			end)
		end
		task.wait(5)
	end
end)

----------------------------------------------------
-- 5. TELEPORT SHOP PAGE
----------------------------------------------------
local TitleShop = Instance.new("TextLabel")
TitleShop.Parent = TeleportShopPage
TitleShop.Size = UDim2.new(1,0,0,25)
TitleShop.BackgroundTransparency = 1
TitleShop.Text = "🛒 TELEPORT TO SHOPS & NPCS"
TitleShop.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleShop.Font = Enum.Font.GothamBold
TitleShop.TextSize = 12

local function AddShopTeleportBtn(parent, name, cf)
	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(1,0,0,32)
	btn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	btn.Text = "  📍 Teleport ke " .. name
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = btn
	btn.MouseButton1Click:Connect(function() pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = cf + Vector3.new(0, 5, 0) end) end)
end

AddShopTeleportBtn(TeleportShopPage, "Tempat Jual Ikan", CFrame.new(-6668.79785, 1312.69983, -9964.06152))
AddShopTeleportBtn(TeleportShopPage, "Skin Shop", CFrame.new(-6639.45947, 1312.69983, -9947.36133))
AddShopTeleportBtn(TeleportShopPage, "Pet Shop", CFrame.new(-6640.44092, 1312.69983, -9917.93652))
AddShopTeleportBtn(TeleportShopPage, "Upgrade Pet", CFrame.new(-6637.85156, 1312.69983, -9886.52441))
AddShopTeleportBtn(TeleportShopPage, "Rod Shop", CFrame.new(-6638.09521, 1312.69983, -9857.41797))
AddShopTeleportBtn(TeleportShopPage, "Title Shop", CFrame.new(-6667.0249, 1312.69983, -9843.66113))

----------------------------------------------------
-- 6. SUMMIT PAGE
----------------------------------------------------
local TitleSum = Instance.new("TextLabel")
TitleSum.Parent = SummitPage
TitleSum.Size = UDim2.new(1,0,0,25)
TitleSum.BackgroundTransparency = 1
TitleSum.Text = "⛰️ AUTO SUMMIT FARM (INSTANT TP)"
TitleSum.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleSum.Font = Enum.Font.GothamBold
TitleSum.TextSize = 12

getgenv().SummitDelay = 1
getgenv().SummitCpHeight = 1.5
getgenv().SummitUseRemote = false
getgenv().SummitHeight = 6

local SummitPoints = {
	{"Cp1", CFrame.new(464.845001, 452.719116, -8948.57227, 0.997986674, 0.00330765732, -0.063337639, 5.851164e-10, 0.998639166, 0.0521515608, 0.0634239465, -0.0520465635, 0.996628582)},
	{"Tengah 1", CFrame.new(474.590057, 447.956573, -9159.24023, 0.999968529, -0.000852574885, -0.00788716134, -1.21188393e-10, 0.994208276, -0.107470497, 0.0079331072, 0.107467115, 0.994176984)},
	{"Cp2", CFrame.new(451.694855, 499.646576, -9572.44434, 0.99949652, 0.000553500664, 0.0317238159, 1.04904453e-10, 0.999847829, -0.0174448304, -0.0317286439, 0.0174360462, 0.999344409)},
	{"Tengah 2", CFrame.new(445.483307, 621.606934, -9778.32324, 0.997986615, -0.0062114615, 0.0631198436, 2.39959358e-10, 0.995192885, 0.0979343653, -0.0634247363, -0.0977371857, 0.993189156)},
	{"Cp3", CFrame.new(397.967834, 639.463623, -10116.7002, 0.999716818, -0.000510056969, -0.02379141, 4.97792363e-11, 0.999770284, -0.0214337762, 0.0237968769, 0.0214277059, 0.999487162)},
	{"Tengah 3", CFrame.new(395.853546, 635.549683, -10386.791, 0.999716818, 0.00315287593, -0.0235871132, 5.91942884e-10, 0.991184175, 0.132491052, 0.0237969011, -0.132453531, 0.990903497)},
	{"Cp4", CFrame.new(489.159821, 642.277039, -10681.7002, -0.0475802682, 0.0602015518, -0.997051597, 1.55177843e-10, 0.998182118, 0.060269814, 0.998867393, 0.00286765373, -0.0474937744)},
	{"Tengah 4", CFrame.new(956.084595, 697.091187, -10802.7363, 0.795761228, -0.0310973153, -0.604811549, -1.72196937e-10, 0.99868077, -0.0513487086, 0.60561049, 0.0408613123, 0.794711471)},
	{"Cp5", CFrame.new(1086.91284, 731.401855, -11160.585, 0.998458445, 0.000272808335, 0.0555039383, 3.18766229e-11, 0.9999879, -0.00491505768, -0.0555046089, 0.00490748091, 0.998446345)},
	{"Tengah 5", CFrame.new(1057.28174, 733.071716, -11465.1123, 0.986154497, 0.0050284788, -0.165753007, 1.63842329e-09, 0.99954015, 0.030323239, 0.165829256, -0.0299033988, 0.985700965)},
	{"Cp6", CFrame.new(971.530334, 740.581787, -11810.3145, 0.126592144, -0.0387375578, 0.991198182, 2.35382769e-10, 0.99923718, 0.0390517339, -0.991954863, -0.00494364277, 0.126495585)},
	{"Tengah 6", CFrame.new(691.74884, 797.521545, -11823.7451, 0.0396752357, -0.102132671, 0.993979275, -7.48076157e-10, 0.99476254, 0.102213152, -0.999212623, -0.00405533146, 0.0394674353)},
	{"Cp7", CFrame.new(388.335876, 895.511658, -11840.2939, 0.0238173455, -0.0717899501, 0.997135341, -6.08690737e-11, 0.997418284, 0.07181032, -0.999716341, -0.0017103313, 0.0237558559)},
	{"Tengah 7", CFrame.new(49.462944, 888.104858, -11861.6387, -0.34944579, -0.19423911, 0.916601777, -3.19386761e-09, 0.978275597, 0.207308546, -0.936956584, 0.0724430978, -0.341854304)},
	{"Cp8", CFrame.new(-328.146729, 853.138916, -11739.3906, 0.00795334298, -0.0638618842, 0.99792707, -8.82961412e-11, 0.997958601, 0.0638639033, -0.99996835, -0.000507931632, 0.00793710724)},
	{"Tengah 8", CFrame.new(-586.720459, 854.341248, -11757.834, -0.0317074656, -0.143703595, 0.989112675, -3.78500481e-10, 0.989610255, 0.14377588, -0.999497175, 0.00455876859, -0.0313780345)},
	{"Cp9", CFrame.new(-873.571655, 857.913574, -11736.6006, -0.0475608706, -0.0613531955, 0.996982336, -8.74402217e-11, 0.998111844, 0.0614227057, -0.998868346, 0.00292131724, -0.0474710688)},
	{"Tengah 9", CFrame.new(-1278.78198, 862.183228, -11790.2275, 0.987442195, -0.0267404672, 0.155701235, 5.12804066e-09, 0.985570729, 0.169264019, -0.157980785, -0.167138427, 0.973194122)},
	{"Cp10", CFrame.new(-1282.57056, 863.854065, -12096.4014, 0.999212563, 5.95095444e-05, -0.0396771468, -1.05802248e-12, 0.999998868, 0.00149984262, 0.0396771915, -0.00149866159, 0.999211431)},
	{"Tengah 10", CFrame.new(-1163.88379, 880.556641, -12491.4229, 0.999716282, 0.00329811801, -0.0235888157, 4.36980556e-11, 0.990366638, 0.138470113, 0.0238182656, -0.138430834, 0.990085661)},
	{"Cp11", CFrame.new(-1314.84912, 896.930481, -12835.1504, -0.0317075849, -0.0382487178, 0.998765051, -2.9176847e-10, 0.999267519, 0.0382679589, -0.999497175, 0.00121338433, -0.0316843614)},
	{"Tengah 11", CFrame.new(-1935.85815, 918.891724, -12822.8037, 0.0555249788, -0.118038259, 0.991455495, 5.07237197e-10, 0.992987335, 0.118220635, -0.998457313, -0.0065641976, 0.0551356003)},
	{"Cp12", CFrame.new(-2322.29541, 919.173645, -12668.2285, -0.99745357, 0.00879278593, -0.0707743391, -2.61384775e-10, 0.992370784, 0.123289101, 0.0713184401, 0.122975156, -0.989843845)},
	{"Tengah 12", CFrame.new(-2335.94287, 919.825073, -12331.4092, -0.999212563, 0.000273454934, 0.0396762192, 4.04826658e-11, 0.999976277, -0.00689199753, -0.0396771617, -0.00688657025, -0.99918884)},
	{"Cp13", CFrame.new(-2311.24023, 923.90979, -11851.917, -0.99745059, -0.00294975913, 0.0712991208, -1.04126284e-10, 0.999145269, 0.0413362421, -0.0713601112, 0.0412308611, -0.996598065)},
	{"Tengah 13", CFrame.new(-2340.36206, 951.430298, -11351.1699, -0.999497175, 0.00360921631, -0.03150158, -6.74113487e-10, 0.993500471, 0.113827907, 0.0317076631, 0.113770671, -0.993000925)},
	{"Cp14", CFrame.new(-2448.27344, 964.254089, -11057.0312, 0.0476028472, -0.0647127628, 0.996767879, 3.43433559e-10, 0.997899175, 0.0647862107, -0.99886632, -0.00308400765, 0.0475028418)},
	{"Tengah 14", CFrame.new(-3044.74292, 981.493469, -11030.8037, 0.0238184482, -0.0852627605, 0.996073782, -5.87034976e-10, 0.996356428, 0.08528696, -0.999716282, -0.00203140359, 0.0237316638)},
	{"Cp15", CFrame.new(-3483.43945, 988.503296, -11013.0811, 0.0396763459, -0.0475526191, 0.998080432, -1.16498686e-10, 0.998866975, 0.0475900918, -0.999212563, -0.00188820099, 0.0396313891)},
	{"Tengah 15", CFrame.new(-3854.48242, 985.936829, -11009.2061, -0.0950342268, -0.142578945, 0.985210478, -2.72903367e-09, 0.989689827, 0.14322719, -0.995473981, 0.0136114825, -0.0940544084)},
	{"Cp16", CFrame.new(-4231.1875, 1006.55963, -11017.707, 0.0950784385, -0.0579245724, 0.993783116, -6.25444918e-10, 0.998305619, 0.0581881776, -0.995469809, -0.00553244166, 0.0949173421)},
	{"Tengah 16", CFrame.new(-4490.48242, 1038.65771, -11328.7051, 0.990922332, -0.00802882854, 0.134195656, -4.68678207e-10, 0.99821502, 0.0597224832, -0.134435624, -0.0591803417, 0.989153564)},
	{"Cp17", CFrame.new(-4655.4458, 1085.97107, -11667.3447, -0.110815927, 0.02199829, 0.993597448, 2.2579081e-11, 0.999755025, -0.0221346188, -0.993840933, -0.00245286827, -0.110788777)},
	{"Tengah 17", CFrame.new(-5027.59277, 1094.36035, -11674.2949, 0.0238194466, -0.060855411, 0.997862339, -6.60101834e-11, 0.998145521, 0.0608726814, -0.999716282, -0.00144995365, 0.0237752739)},
	{"Cp18", CFrame.new(-5545.39404, 1107.8219, -11650.6357, -0.00791138876, -0.0912490711, 0.99579668, -1.18666341e-10, 0.995827854, 0.0912519246, -0.999968708, 0.000721929304, -0.00787838083)},
	{"Tengah 18", CFrame.new(-6414.31885, 1107.92029, -11711.4941, 0.39367038, -0.111929558, 0.912411869, 1.31374795e-08, 0.992559373, 0.121761598, -0.91925168, -0.0479339212, 0.390741229)},
	{"Cp19", CFrame.new(-6766.26074, 1105.58411, -11503.3955, -0.999874473, 0.000155506685, -0.015843736, -2.90724042e-12, 0.999951839, 0.00981455389, 0.0158444997, 0.00981332175, -0.999826312)},
	{"Tengah 19", CFrame.new(-6762.13184, 1099.67126, -11186.042, -0.998868346, 0.00112270634, -0.0475471318, -5.17564568e-11, 0.999721348, 0.0236059148, 0.0475603864, 0.0235792007, -0.998589993)},
	{"Cp20", CFrame.new(-6746.04248, 1108.37537, -10794.8271, -0.993840754, 0.0067165764, -0.11061395, -6.0127392e-10, 0.998161554, 0.060609255, 0.110817678, 0.0602359474, -0.992013633)}
}

local function SetPlatformStand(state)
	pcall(function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.PlatformStand = state end
	end)
end

AddToggle(SummitPage, "Auto Summit Loop (Instant TP)", function(v)
	getgenv().AutoSummitRunning = v
	if not v then
		SetPlatformStand(false)
		pcall(function()
			local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.AssemblyLinearVelocity = Vector3.zero
				hrp.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	end
end)

local function AddSummitBox(placeholder, default, onChange)
	local box = Instance.new("TextBox")
	box.Parent = SummitPage
	box.Size = UDim2.new(1,0,0,32)
	box.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
	box.PlaceholderText = placeholder
	box.Text = tostring(default)
	box.TextColor3 = Color3.new(1,1,1)
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 5)
	bc.Parent = box
	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then onChange(n) end
	end)
end

AddSummitBox("Tinggi di titik Tengah (Cth: 6)", 6, function(n) getgenv().SummitHeight = n end)
AddSummitBox("Tinggi di titik Cp (Cth: 1.5)", 1.5, function(n) getgenv().SummitCpHeight = n end)
AddToggle(SummitPage, "Pakai Remote Checkpoint (opsional)", function(v) getgenv().SummitUseRemote = v end)
AddSummitBox("Jeda di tiap Cp (detik, Cth: 1)", 1, function(n) getgenv().SummitDelay = math.max(n, 0) end)

local function TouchCheckpoint(cpNumber, approxCF)
	local part 
	local waited = 0 
	
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(approxCF.Position, 5)
	end)
	while getgenv().AutoSummitRunning and waited < 2 do
		local folder = workspace:FindFirstChild("Checkpoint")
		part = folder and folder:FindFirstChild("Checkpoint " .. tostring(cpNumber))
		if part and part:IsA("BasePart") then break end
		part = nil
		task.wait(0.2)
		waited = waited + 0.2
	end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not getgenv().AutoSummitRunning then return end
	if not part then
		hrp.CFrame = approxCF
		task.wait(0.1)
		return
	end
	local standPos = part.Position + Vector3.new(0, (part.Size.Y / 2) + 2, 0)
	hrp.CFrame = CFrame.new(standPos)
	hrp.AssemblyLinearVelocity = Vector3.zero
	if firetouchinterest then
		pcall(function()
			firetouchinterest(hrp, part, 0)
			task.wait(0.05)
			firetouchinterest(hrp, part, 1)
		end)
	end
end

task.spawn(function()
	while true do
		if getgenv().AutoSummitRunning then
			pcall(function()
				local midHeight = tonumber(getgenv().SummitHeight) or 6
				local cpHeight = tonumber(getgenv().SummitCpHeight) or 1.5
				
				for _, point in ipairs(SummitPoints) do
					if not getgenv().AutoSummitRunning then break end
					
					local character = LocalPlayer.Character
					local hrp = character and character:FindFirstChild("HumanoidRootPart")
					local humanoid = character and character:FindFirstChildOfClass("Humanoid")
					if not hrp or not humanoid then break end
					local name = point[1]
					local cpIndex = string.match(name, "^Cp(%d+)$")
					local height = cpIndex and cpHeight or midHeight
					pcall(function() LocalPlayer:RequestStreamAroundAsync(point[2].Position, 3) end)
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
					
					hrp.CFrame = point[2] + Vector3.new(0, height, 0)
					if not getgenv().AutoSummitRunning then break end
					if cpIndex then
						TouchCheckpoint(tonumber(cpIndex), point[2])
						
						local delayTime = tonumber(getgenv().SummitDelay) or 1
						task.wait(delayTime)
						
						if getgenv().SummitUseRemote then
							pcall(function()
								local cpRemote = ReplicatedStorage:FindFirstChild("Remote")
									and ReplicatedStorage.Remote:FindFirstChild("Checkpoint")
									and ReplicatedStorage.Remote.Checkpoint:FindFirstChild("TpToCheckpoint")
								if cpRemote then
									cpRemote:FireServer(tonumber(cpIndex))
								end
							end)
						end
						task.wait(0.1)
					else
						task.wait(0.15)
					end
				end
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrp and getgenv().AutoSummitRunning then
					hrp.CFrame = CFrame.new(-6766.44629, 1320.69983, -10083.8037) + Vector3.new(0, 5, 0)
					task.wait(0.8)
					hrp.CFrame = CFrame.new(-6834.84912, 1313.24744, -9902.42285) + Vector3.new(0, 5, 0)
				end
			end)
			task.wait(0.3)
		else
			task.wait(0.5)
		end
	end
end)

----------------------------------------------------
-- 7. PLAYER PAGE
----------------------------------------------------
local TitlePly = Instance.new("TextLabel")
TitlePly.Parent = PlayerPage
TitlePly.Size = UDim2.new(1,0,0,25)
TitlePly.BackgroundTransparency = 1
TitlePly.Text = "⚡ PLAYER SETTINGS & VISUALS"
TitlePly.TextColor3 = Color3.fromRGB(220, 60, 60)
TitlePly.Font = Enum.Font.GothamBold
TitlePly.TextSize = 12

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = PlayerPage
SpeedBox.Size = UDim2.new(1,0,0,32)
SpeedBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
SpeedBox.PlaceholderText = "Ketik WalkSpeed (Cth: 50)"
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.new(1,1,1)
local spc = Instance.new("UICorner")
spc.CornerRadius = UDim.new(0, 5)
spc.Parent = SpeedBox
SpeedBox.FocusLost:Connect(function()
	local num = tonumber(SpeedBox.Text)
	if num then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = num end) end
end)

AddToggle(PlayerPage, "Anti-AFK", function(v) getgenv().AntiAFKRunning = v end)
LocalPlayer.Idled:Connect(function()
	if getgenv().AntiAFKRunning then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end
end)

local HeadlessBtn = Instance.new("TextButton")
HeadlessBtn.Parent = PlayerPage
HeadlessBtn.Size = UDim2.new(1,0,0,32)
HeadlessBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
HeadlessBtn.Text = "👻 Enable Headless"
HeadlessBtn.TextColor3 = Color3.new(1,1,1)
HeadlessBtn.Font = Enum.Font.GothamBold
HeadlessBtn.TextSize = 12
local hlc = Instance.new("UICorner")
hlc.CornerRadius = UDim.new(0, 5)
hlc.Parent = HeadlessBtn
HeadlessBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
		if head then
			head.Transparency = 1
			for _, child in ipairs(head:GetChildren()) do if child:IsA("Decal") then child.Transparency = 1 end end
		end
	end)
end)

local FireRgbBtn = Instance.new("TextButton")
FireRgbBtn.Parent = PlayerPage
FireRgbBtn.Size = UDim2.new(1,0,0,32)
FireRgbBtn.BackgroundColor3 = Color3.fromRGB(120, 30, 160)
FireRgbBtn.Text = "🔥🌈 Auto RGB Fire: [OFF]"
FireRgbBtn.TextColor3 = Color3.new(1,1,1)
FireRgbBtn.Font = Enum.Font.GothamBold
FireRgbBtn.TextSize = 12
local frc = Instance.new("UICorner")
frc.CornerRadius = UDim.new(0, 5)
frc.Parent = FireRgbBtn
local autoRgbActive = false
FireRgbBtn.MouseButton1Click:Connect(function()
	autoRgbActive = not autoRgbActive
	FireRgbBtn.Text = "🔥🌈 Auto RGB Fire: " .. (autoRgbActive and "[ON]" or "[OFF]")
	FireRgbBtn.BackgroundColor3 = autoRgbActive and Color3.fromRGB(0, 140, 60) or Color3.fromRGB(120, 30, 160)
	pcall(function()
		local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
		if head then
			local fire = head:FindFirstChild("TyoHeadFire")
			if autoRgbActive and not fire then
				fire = Instance.new("Fire")
				fire.Name = "TyoHeadFire"
				fire.Size = 5
				fire.Heat = 15
				fire.Parent = head
			elseif not autoRgbActive and fire then
				fire:Destroy()
			end
		end
	end)
end)

task.spawn(function()
	local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 100, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 0), Color3.fromRGB(0, 255, 255)}
	local index = 1
	while true do
		if autoRgbActive then
			pcall(function()
				local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
				local fire = head and head:FindFirstChild("TyoHeadFire")
				if fire then
					index = index % #colors + 1
					fire.Color = colors[index]
					fire.SecondaryColor = colors[(index % #colors) + 1]
				end
			end)
		end
		task.wait(1)
	end
end)

----------------------------------------------------
-- 8. HALO PAGE
----------------------------------------------------
local TitleHalo = Instance.new("TextLabel")
TitleHalo.Parent = HaloPage
TitleHalo.Size = UDim2.new(1,0,0,25)
TitleHalo.BackgroundTransparency = 1
TitleHalo.Text = "👑 HALO & AKSESORIS KEPALA"
TitleHalo.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleHalo.Font = Enum.Font.GothamBold
TitleHalo.TextSize = 12

local function ApplyHaloToCharacter(haloName)
	getgenv().CurrentSelectedHalo = haloName
	pcall(function()
		local character = LocalPlayer.Character
		local head = character and character:FindFirstChild("Head")
		if not head then return end
		for _, v in ipairs(head:GetChildren()) do if v.Name == "CustomPlayerHalo" then v:Destroy() end end
		local haloSourceFolder = ReplicatedStorage:FindFirstChild("HaloKenyal")
		if haloSourceFolder then
			local targetHaloModel = haloSourceFolder:FindFirstChild(haloName)
			if targetHaloModel then
				local cloneModel = targetHaloModel:Clone()
				cloneModel.Name = "CustomPlayerHalo"
				local primaryPart = cloneModel:FindFirstChild("Handle") or cloneModel:FindFirstChild("Antenna") or cloneModel:FindFirstChildWhichIsA("BasePart")
				cloneModel.Parent = head
				for _, desc in ipairs(cloneModel:GetDescendants()) do
					if desc:IsA("BasePart") then desc.Anchored = false desc.CanCollide = false desc.Massless = true
					elseif desc:IsA("Script") or desc:IsA("LocalScript") then desc:Destroy() end
				end
				if primaryPart then
					primaryPart.CFrame = head.CFrame * CFrame.new(0, 1.3, 0)
					local weld = Instance.new("WeldConstraint")
					weld.Part0 = head
					weld.Part1 = primaryPart
					weld.Parent = primaryPart
				end
			end
		end
	end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(1)
	if getgenv().CurrentSelectedHalo then ApplyHaloToCharacter(getgenv().CurrentSelectedHalo) end
end)

pcall(function()
	local haloSourceFolder = ReplicatedStorage:FindFirstChild("HaloKenyal")
	if haloSourceFolder then
		local clearHaloBtn = Instance.new("TextButton")
		clearHaloBtn.Parent = HaloPage
		clearHaloBtn.Size = UDim2.new(1,0,0,32)
		clearHaloBtn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
		clearHaloBtn.Text = "❌ Lepas Aksesoris Kepala"
		clearHaloBtn.TextColor3 = Color3.new(1,1,1)
		clearHaloBtn.Font = Enum.Font.GothamBold
		clearHaloBtn.TextSize = 12
		local chc = Instance.new("UICorner")
		chc.CornerRadius = UDim.new(0, 5)
		chc.Parent = clearHaloBtn
		
		clearHaloBtn.MouseButton1Click:Connect(function()
			getgenv().CurrentSelectedHalo = nil
			pcall(function()
				local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
				if head then for _, v in ipairs(head:GetChildren()) do if v.Name == "CustomPlayerHalo" then v:Destroy() end end end
			end)
		end)
		for _, haloItem in ipairs(haloSourceFolder:GetChildren()) do
			local name = haloItem.Name
			local haloBtn = Instance.new("TextButton")
			haloBtn.Parent = HaloPage
			haloBtn.Size = UDim2.new(1,0,0,32)
			haloBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			haloBtn.Text = "👑 " .. name
			haloBtn.TextColor3 = Color3.new(1,1,1)
			haloBtn.Font = Enum.Font.GothamMedium
			haloBtn.TextSize = 12
			local hbc = Instance.new("UICorner")
			hbc.CornerRadius = UDim.new(0, 5)
			hbc.Parent = haloBtn
			haloBtn.MouseButton1Click:Connect(function() ApplyHaloToCharacter(name) end)
		end
	end
end)

----------------------------------------------------
-- 9. TELEPORT PLAYER PAGE (DENGAN SCROLL KE BAWAH)
----------------------------------------------------
local TitleTpPly = Instance.new("TextLabel")
TitleTpPly.Parent = PlayerTpPage
TitleTpPly.Size = UDim2.new(1,0,0,25)
TitleTpPly.BackgroundTransparency = 1
TitleTpPly.Text = "👥 TELEPORT TO OTHER PLAYERS"
TitleTpPly.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleTpPly.Font = Enum.Font.GothamBold
TitleTpPly.TextSize = 12

local RefreshPlayerBtn = Instance.new("TextButton")
RefreshPlayerBtn.Parent = PlayerTpPage
RefreshPlayerBtn.Size = UDim2.new(1,0,0,32)
RefreshPlayerBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
RefreshPlayerBtn.Text = "🔄 Refresh / Scan Pemain"
RefreshPlayerBtn.TextColor3 = Color3.new(1,1,1)
RefreshPlayerBtn.Font = Enum.Font.GothamBold
RefreshPlayerBtn.TextSize = 12
local rpc = Instance.new("UICorner")
rpc.CornerRadius = UDim.new(0, 5)
rpc.Parent = RefreshPlayerBtn

local PlayerListContainer = Instance.new("ScrollingFrame")
PlayerListContainer.Parent = PlayerTpPage
PlayerListContainer.Size = UDim2.new(1,0,0,210)
PlayerListContainer.BackgroundTransparency = 1
PlayerListContainer.CanvasSize = UDim2.new(0,0,0,0) -- Akan otomatis diatur sesuai jumlah player
PlayerListContainer.ScrollBarThickness = 4

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = PlayerListContainer
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)

-- Otomatis atur CanvasSize agar player bisa di-scroll sampai ke paling bawah
ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

local function ScanAndDisplayPlayers()
	for _, child in ipairs(PlayerListContainer:GetChildren()) do 
		if child:IsA("TextButton") then child:Destroy() end 
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local pBtn = Instance.new("TextButton")
			pBtn.Parent = PlayerListContainer
			pBtn.Size = UDim2.new(1, -5, 0, 32)
			pBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
			pBtn.Text = "  👤 " .. plr.Name .. " (" .. plr.DisplayName .. ")"
			pBtn.TextColor3 = Color3.new(1,1,1)
			pBtn.Font = Enum.Font.GothamMedium
			pBtn.TextSize = 11
			pBtn.TextXAlignment = Enum.TextXAlignment.Left
			local pbc = Instance.new("UICorner")
			pbc.CornerRadius = UDim.new(0, 4)
			pbc.Parent = pBtn
			pBtn.MouseButton1Click:Connect(function()
				pcall(function()
					local hrpTarget = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
					local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrpTarget and myHrp then myHrp.CFrame = hrpTarget.CFrame + Vector3.new(0, 5, 0) end
				end)
			end)
		end
	end
end

RefreshPlayerBtn.MouseButton1Click:Connect(ScanAndDisplayPlayers)
task.spawn(function() task.wait(2); ScanAndDisplayPlayers() end)

----------------------------------------------------
-- 10. PRIVACY & ANTI-ADMIN PAGE
----------------------------------------------------
local TitlePrv = Instance.new("TextLabel")
TitlePrv.Parent = PrivacyPage
TitlePrv.Size = UDim2.new(1,0,0,25)
TitlePrv.BackgroundTransparency = 1
TitlePrv.Text = "🛡️ PRIVACY & ANTI-ADMIN"
TitlePrv.TextColor3 = Color3.fromRGB(220, 60, 60)
TitlePrv.Font = Enum.Font.GothamBold
TitlePrv.TextSize = 12

local FakeNameBox = Instance.new("TextBox")
FakeNameBox.Parent = PrivacyPage
FakeNameBox.Size = UDim2.new(1,0,0,32)
FakeNameBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
FakeNameBox.PlaceholderText = "Nama Samaran (Cth: TYO HUB)"
FakeNameBox.Text = "TYO HUB"
FakeNameBox.TextColor3 = Color3.new(1,1,1)
local fnc = Instance.new("UICorner")
fnc.CornerRadius = UDim.new(0, 5)
fnc.Parent = FakeNameBox
FakeNameBox.FocusLost:Connect(function() getgenv().FakeNameInput = FakeNameBox.Text end)

AddToggle(PrivacyPage, "Privacy Mode (Hide Name)", function(v)
	getgenv().HideNameRunning = v
	if v then
		task.spawn(function()
			while getgenv().HideNameRunning do
				pcall(function()
					local fakeName = getgenv().FakeNameInput or "TYO HUB"
					local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
					if head then
						for _, child in ipairs(head:GetDescendants()) do
							if child:IsA("TextLabel") or child:IsA("TextMesh") then
								local txt = child.Text
								if string.find(txt, LocalPlayer.Name) or string.find(txt, LocalPlayer.DisplayName) then child.Text = fakeName end
							end
						end
					end
				end)
				task.wait(1)
			end
		end)
	end
end)

local AntiAdminToggleBtn = Instance.new("TextButton")
AntiAdminToggleBtn.Parent = PrivacyPage
AntiAdminToggleBtn.Size = UDim2.new(1,0,0,32)
AntiAdminToggleBtn.BackgroundColor3 = getgenv().TyoConfig.AntiAdminEnabled and Color3.fromRGB(180, 45, 45) or Color3.fromRGB(24, 24, 32)
AntiAdminToggleBtn.Text = " Anti-Admin Protect (MPG Group): " .. (getgenv().TyoConfig.AntiAdminEnabled and "[ON]" or "[OFF]")
AntiAdminToggleBtn.TextColor3 = Color3.new(1,1,1)
AntiAdminToggleBtn.Font = Enum.Font.Gotham
AntiAdminToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
local aac = Instance.new("UICorner")
aac.CornerRadius = UDim.new(0, 5)
aac.Parent = AntiAdminToggleBtn
AntiAdminToggleBtn.MouseButton1Click:Connect(function()
	getgenv().TyoConfig.AntiAdminEnabled = not getgenv().TyoConfig.AntiAdminEnabled
	local active = getgenv().TyoConfig.AntiAdminEnabled
	AntiAdminToggleBtn.Text = " Anti-Admin Protect (MPG Group): " .. (active and "[ON]" or "[OFF]")
	AntiAdminToggleBtn.BackgroundColor3 = active and Color3.fromRGB(180, 45, 45) or Color3.fromRGB(24, 24, 32)
	SaveConfig()
end)

local function CheckPlayerIsAdmin(player)
	local success, rank = pcall(function() return player:GetRankInGroup(getgenv().TyoConfig.TargetGroupId or 7019573) end)
	return success and rank and rank > 1
end

Players.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		task.spawn(function()
			task.wait(1.5)
			if getgenv().TyoConfig.AntiAdminEnabled and CheckPlayerIsAdmin(player) then
				TeleportService:Teleport(game.PlaceId, LocalPlayer)
			end
		end)
	end
end)

----------------------------------------------------
-- 11. SETTINGS & PERFORMANCE BOOST (ULTRA NO-RENDER / POTATO)
----------------------------------------------------
local TitleSet = Instance.new("TextLabel")
TitleSet.Parent = SettingsPage
TitleSet.Size = UDim2.new(1,0,0,25)
TitleSet.BackgroundTransparency = 1
TitleSet.Text = "⚙️ SETTINGS & PERFORMANCE BOOST"
TitleSet.TextColor3 = Color3.fromRGB(220, 60, 60)
TitleSet.Font = Enum.Font.GothamBold
TitleSet.TextSize = 12

local AntiLagBtn = Instance.new("TextButton")
AntiLagBtn.Parent = SettingsPage
AntiLagBtn.Size = UDim2.new(1,0,0,32)
AntiLagBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
AntiLagBtn.Text = "⚡ Ultra Potato Graphics (Max No-Render)"
AntiLagBtn.TextColor3 = Color3.new(1,1,1)
AntiLagBtn.Font = Enum.Font.GothamBold
local alc = Instance.new("UICorner")
alc.CornerRadius = UDim.new(0, 5)
alc.Parent = AntiLagBtn

local function ApplyUltraNoRender()
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 999999
		Lighting.Brightness = 1
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
				v:Destroy()
			end
		end
		
		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Explosion") or v:IsA("Highlight") then
				v:Destroy()
			elseif v:IsA("BasePart") then
				v.Material = Enum.Material.SmoothPlastic
				v.Reflectance = 0
				v.CastShadow = false
			elseif v:IsA("Decal") or v:IsA("Texture") then
				v:Destroy()
			elseif v:IsA("Model") and not v:IsDescendantOf(LocalPlayer.Character) then
				pcall(function()
					for _, d in ipairs(v:GetDescendants()) do
						if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") then
							d:Destroy()
						end
					end
				end)
			end
		end
		
		if workspace:FindFirstChildOfClass("Terrain") then
			local terrain = workspace:FindFirstChildOfClass("Terrain")
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterTransparency = 1
			terrain.WaterReflectance = 0
			pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
		end
	end)
end

AntiLagBtn.MouseButton1Click:Connect(function()
	ApplyUltraNoRender()
	AntiLagBtn.Text = "⚡ Ultra Potato Graphics Aktif!"
	AntiLagBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
end)

task.spawn(function()
	while true do
		pcall(function()
			local isPhotoOrPortraitActive = false
			for _, gui in ipairs(PlayerGui:GetDescendants()) do
				if gui:IsA("TextLabel") or gui:IsA("TextButton") then
					local text = string.lower(gui.Text or "")
					if string.find(text, "mode foto") or string.find(text, "mode potret") or string.find(text, "sembunyikan ui") then
						if gui.Parent and (gui.Parent.BackgroundColor3 == Color3.fromRGB(0, 170, 0) or gui.Parent.BackgroundColor3 == Color3.fromRGB(0, 255, 0)) then
							isPhotoOrPortraitActive = true
						end
					end
				end
			end
			if not isPhotoOrPortraitActive then
				ApplyUltraNoRender()
			end
		end)
		task.wait(10)
	end
end)

local BlackScreenGui = nil
local BlackScreenToggleBtn = Instance.new("TextButton")
BlackScreenToggleBtn.Parent = SettingsPage
BlackScreenToggleBtn.Size = UDim2.new(1,0,0,32)
BlackScreenToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
BlackScreenToggleBtn.Text = " 📱 Black Screen (Battery Saver): [OFF]"
BlackScreenToggleBtn.TextColor3 = Color3.new(1,1,1)
BlackScreenToggleBtn.Font = Enum.Font.Gotham
BlackScreenToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
local bsc = Instance.new("UICorner")
bsc.CornerRadius = UDim.new(0, 5)
bsc.Parent = BlackScreenToggleBtn
local isBlackScreen = false

BlackScreenToggleBtn.MouseButton1Click:Connect(function()
	isBlackScreen = not isBlackScreen
	BlackScreenToggleBtn.Text = " 📱 Black Screen (Battery Saver): " .. (isBlackScreen and "[ON]" or "[OFF]")
	BlackScreenToggleBtn.BackgroundColor3 = isBlackScreen and Color3.fromRGB(0, 140, 100) or Color3.fromRGB(24, 24, 32)
	
	if isBlackScreen then
		if not BlackScreenGui then
			BlackScreenGui = Instance.new("ScreenGui")
			BlackScreenGui.Name = "TyoBlackScreen"
			BlackScreenGui.Parent = PlayerGui
			BlackScreenGui.DisplayOrder = 999999
			BlackScreenGui.IgnoreGuiInset = true
			
			local frame = Instance.new("Frame")
			frame.Parent = BlackScreenGui
			frame.Size = UDim2.new(1,0,1,0)
			frame.BackgroundColor3 = Color3.fromRGB(2, 2, 5)
			
			local txt = Instance.new("TextLabel")
			txt.Parent = frame
			txt.Size = UDim2.new(1,0,0,60)
			txt.Position = UDim2.new(0,0,0.45,0)
			txt.BackgroundTransparency = 1
			txt.Text = "🌙 SPEED HUB STYLE - BATTERY SAVER ACTIVE\n(Sentuh Layar Untuk Kembali)"
			txt.TextColor3 = Color3.fromRGB(220, 60, 60)
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 13
			
			frame.InputBegan:Connect(function()
				isBlackScreen = false
				BlackScreenToggleBtn.Text = " 📱 Black Screen (Battery Saver): [OFF]"
				BlackScreenToggleBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
				BlackScreenGui.Enabled = false
			end)
		else
			BlackScreenGui.Enabled = true
		end
	else
		if BlackScreenGui then BlackScreenGui.Enabled = false end
	end
end)

local WebhookToggleBtn = Instance.new("TextButton")
WebhookToggleBtn.Parent = SettingsPage
WebhookToggleBtn.Size = UDim2.new(1,0,0,32)
WebhookToggleBtn.BackgroundColor3 = getgenv().TyoConfig.WebhookEnabled and Color3.fromRGB(0, 140, 100) or Color3.fromRGB(24, 24, 32)
WebhookToggleBtn.Text = " Webhook Server-Wide (Rare & Core): " .. (getgenv().TyoConfig.WebhookEnabled and "[ON]" or "[OFF]")
WebhookToggleBtn.TextColor3 = Color3.new(1,1,1)
WebhookToggleBtn.Font = Enum.Font.Gotham
WebhookToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
local wtc = Instance.new("UICorner")
wtc.CornerRadius = UDim.new(0, 5)
wtc.Parent = WebhookToggleBtn
WebhookToggleBtn.MouseButton1Click:Connect(function()
	getgenv().TyoConfig.WebhookEnabled = not getgenv().TyoConfig.WebhookEnabled
	WebhookToggleBtn.Text = " Webhook Server-Wide (Rare & Core): " .. (getgenv().TyoConfig.WebhookEnabled and "[ON]" or "[OFF]")
	WebhookToggleBtn.BackgroundColor3 = getgenv().TyoConfig.WebhookEnabled and Color3.fromRGB(0, 140, 100) or Color3.fromRGB(24, 24, 32)
	SaveConfig()
end)

local WebhookBox = Instance.new("TextBox")
WebhookBox.Parent = SettingsPage
WebhookBox.Size = UDim2.new(1,0,0,32)
WebhookBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
WebhookBox.PlaceholderText = "Paste Discord Webhook URL di sini..."
WebhookBox.Text = tostring(getgenv().TyoConfig.WebhookUrl or "")
WebhookBox.TextColor3 = Color3.new(1,1,1)
local wbc = Instance.new("UICorner")
wbc.CornerRadius = UDim.new(0, 5)
wbc.Parent = WebhookBox
WebhookBox.FocusLost:Connect(function()
	getgenv().TyoConfig.WebhookUrl = WebhookBox.Text
	SaveConfig()
end)

local TestWebhookBtn = Instance.new("TextButton")
TestWebhookBtn.Parent = SettingsPage
TestWebhookBtn.Size = UDim2.new(1,0,0,32)
TestWebhookBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
TestWebhookBtn.Text = "🧪 Test Kirim Webhook ke Discord"
TestWebhookBtn.TextColor3 = Color3.new(1,1,1)
TestWebhookBtn.Font = Enum.Font.GothamBold
TestWebhookBtn.TextSize = 12
local twc = Instance.new("UICorner")
twc.CornerRadius = UDim.new(0, 5)
twc.Parent = TestWebhookBtn
TestWebhookBtn.MouseButton1Click:Connect(function()
	pcall(function()
		local url = getgenv().TyoConfig.WebhookUrl
		if not url or url == "" or not string.find(url, "api/webhooks") then
			TestWebhookBtn.Text = "❌ URL Webhook Salah / Belum Diisi!"
			task.wait(2)
			TestWebhookBtn.Text = "🧪 Test Kirim Webhook ke Discord"
			return
		end
		local requestFunc = (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request)
		if requestFunc then
			requestFunc({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
					["content"] = "✅ **Speed Hub Style Webhook Test Berhasil!**"
				})
			})
			TestWebhookBtn.Text = "✅ Pesan Test Berhasil Dikirim!"
		else
			TestWebhookBtn.Text = "❌ Executor Tidak Mendukung Request!"
		end
		task.wait(2)
		TestWebhookBtn.Text = "🧪 Test Kirim Webhook ke Discord"
	end)
end)

local SaveConfigBtn = Instance.new("TextButton")
SaveConfigBtn.Parent = SettingsPage
SaveConfigBtn.Size = UDim2.new(1,0,0,32)
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
SaveConfigBtn.Text = "💾 Simpan Konfigurasi"
SaveConfigBtn.TextColor3 = Color3.new(1,1,1)
SaveConfigBtn.Font = Enum.Font.GothamBold
local scc = Instance.new("UICorner")
scc.CornerRadius = UDim.new(0, 5)
scc.Parent = SaveConfigBtn
SaveConfigBtn.MouseButton1Click:Connect(function()
	SaveConfig()
	SaveConfigBtn.Text = "✅ Config Berhasil Disimpan!"
	task.wait(1.5)
	SaveConfigBtn.Text = "💾 Simpan Konfigurasi"
end)

local ResetConfigBtn = Instance.new("TextButton")
ResetConfigBtn.Parent = SettingsPage
ResetConfigBtn.Size = UDim2.new(1,0,0,32)
ResetConfigBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
ResetConfigBtn.Text = "🔄 Reset Konfigurasi"
ResetConfigBtn.TextColor3 = Color3.new(1,1,1)
ResetConfigBtn.Font = Enum.Font.GothamBold
local rcc = Instance.new("UICorner")
rcc.CornerRadius = UDim.new(0, 5)
rcc.Parent = ResetConfigBtn
ResetConfigBtn.MouseButton1Click:Connect(function()
	ResetConfig()
	ResetConfigBtn.Text = "🔄 Config Direset!"
	task.wait(1.5)
	ResetConfigBtn.Text = "🔄 Reset Konfigurasi"
end)

local CredLbl = Instance.new("TextLabel")
CredLbl.Parent = CreditsPage
CredLbl.Size = UDim2.new(1,0,1,0)
CredLbl.BackgroundTransparency = 1
CredLbl.Text = "Created By TYO\nStyle: Speed Hub X\nMap: Mount Soreya"
CredLbl.TextColor3 = Color3.new(1,1,1)
CredLbl.Font = Enum.Font.GothamBold
CredLbl.TextSize = 18

----------------------------------------------------
-- 12. BOTTOM PANEL: SESSION STAT TRACKER (LIVE)
----------------------------------------------------
local StatPanel = Instance.new("Frame")
StatPanel.Parent = Main
StatPanel.Size = UDim2.new(1, -150, 0, 24)
StatPanel.Position = UDim2.new(0, 145, 1, -26)
StatPanel.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
StatPanel.BorderSizePixel = 0
local stpCorner = Instance.new("UICorner")
stpCorner.CornerRadius = UDim.new(0, 5)
stpCorner.Parent = StatPanel

local StatLabel = Instance.new("TextLabel")
StatLabel.Parent = StatPanel
StatLabel.Size = UDim2.new(1, -10, 1, 0)
StatLabel.Position = UDim2.new(0, 5, 0, 0)
StatLabel.BackgroundTransparency = 1
StatLabel.Text = "📊 Total Ikan: 0 | ⏱️ Play Time: 00s"
StatLabel.TextColor3 = Color3.fromRGB(220, 60, 60)
StatLabel.Font = Enum.Font.GothamBold
StatLabel.TextSize = 11
StatLabel.TextXAlignment = Enum.TextXAlignment.Left

task.spawn(function()
	while true do
		pcall(function()
			local elapsed = os.time() - getgenv().SessionStartTime
			local hours = math.floor(elapsed / 3600)
			local mins = math.floor((elapsed % 3600) / 60)
			local secs = elapsed % 60
			
			local timeStr = ""
			if hours > 0 then
				timeStr = string.format("%02dh %02dm %02ds", hours, mins, secs)
			elseif mins > 0 then
				timeStr = string.format("%02dm %02ds", mins, secs)
			else
				timeStr = string.format("%02ds", secs)
			end
			
			StatLabel.Text = string.format("📊 Total Ikan: %d | ⏱️ Play: %s", getgenv().TotalFishCaught, timeStr)
		end)
		task.wait(1)
	end
end)

----------------------------------------------------
-- FLOATING BUTTON (IMAGE BUTTON)
----------------------------------------------------
local Float = Instance.new("ImageButton")
Float.Parent = Gui
Float.Size = UDim2.new(0, 50, 0, 50)
Float.Position = UDim2.new(0, 20, 0, 120)
Float.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Float.Image = "rbxassetid://1000301096"
Float.ScaleType = Enum.ScaleType.Crop

local flCorner = Instance.new("UICorner")
flCorner.CornerRadius = UDim.new(1, 0)
flCorner.Parent = Float

local flStroke = Instance.new("UIStroke")
flStroke.Parent = Float
flStroke.Color = Color3.fromRGB(200, 45, 45)
flStroke.Thickness = 2

MakeDraggable(Float)

Float.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)
