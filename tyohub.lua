-- ==============================================================================
-- TYO HUB V3 (AEMEATH WUTHERING WAVES EDITION) | NO-KEY & MULTI-DEVICE
-- MAP: MOUNT SOREYA UPDATE (EXTREME POTATO & MINIMAL RENDER DISTANCE)
-- AUTO-ACTIVATED: ANTI-LAG, ANTI-AFK, NETWORK BOOSTER & AUTO GALATAMA
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
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------
-- STAT TRACKER GLOBAL VARIABLES
------------------------------------------------------------------
getgenv().TotalFishCaught = 0
getgenv().SessionStartTime = os.time()

------------------------------------------------------------------
-- CONFIGURATION & FILE SAVE SYSTEM (AUTO SAVE & AUTO LOAD FIXED)
------------------------------------------------------------------
local SAFE_NAME = tostring(LocalPlayer.UserId or LocalPlayer.Name)
local CONFIG_FILE = "AemeathHubV3_Config_" .. SAFE_NAME .. ".json"

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
	SelectedTradeTarget = "",
	AutoSaveEnabled = true,
	AutoLoadEnabled = true,
	AutoReadyTrade = true,
	AutoConfirmTrade = true,
	AutoAcceptTrade = true,
	AutoAddAllFishTrade = true,
	FlySpeed = 50,
	JumpPowerValue = 100,
	
	FavRarities = {
		["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false,
		["Legendary"] = true, ["Mythical"] = true, ["Secret"] = true, ["Forgotten"] = true, ["Aether"] = true
	},
	FavMutations = {
		["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false,
		["Lightning"] = false, ["Fairy Dust"] = true, ["Gold"] = false, ["Midnight"] = false,
		["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false,
		["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false,
		["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false,
		["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false
	},
	UnfavRarities = {
		["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false,
		["Legendary"] = false, ["Mythical"] = false, ["Secret"] = false, ["Forgotten"] = false
	},
	UnfavMutations = {
		["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false,
		["Lightning"] = false, ["Fairy Dust"] = false, ["Gold"] = false, ["Midnight"] = false,
		["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false,
		["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false,
		["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false,
		["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false
	},
	SpotLoopConfig = {
		["Spot Mancing Jembatan"] = { Enabled = false, Timer = "10" },
		["Spot Mancing Core"] = { Enabled = false, Timer = "10" },
		["Spot Mancing Ikan Anomali"] = { Enabled = false, Timer = "10" }
	}
}

-- Sinkronisasi Global Variable
getgenv().FavRarities = getgenv().TyoConfig.FavRarities
getgenv().FavMutations = getgenv().TyoConfig.FavMutations
getgenv().UnfavRarities = getgenv().TyoConfig.UnfavRarities
getgenv().UnfavMutations = getgenv().TyoConfig.UnfavMutations
getgenv().SpotLoopConfig = getgenv().TyoConfig.SpotLoopConfig

local function SaveConfig()
	pcall(function()
		if writefile and getgenv().TyoConfig.AutoSaveEnabled then
			getgenv().TyoConfig.SelectedSpot = getgenv().SelectedFishingSpot or getgenv().TyoConfig.SelectedSpot
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
				for k, v in pairs(data) do
					if getgenv().TyoConfig[k] ~= nil then
						getgenv().TyoConfig[k] = v
					end
				end
				getgenv().FavRarities = getgenv().TyoConfig.FavRarities
				getgenv().FavMutations = getgenv().TyoConfig.FavMutations
				getgenv().UnfavRarities = getgenv().TyoConfig.UnfavRarities
				getgenv().UnfavMutations = getgenv().TyoConfig.UnfavMutations
				getgenv().SpotLoopConfig = getgenv().TyoConfig.SpotLoopConfig

				if getgenv().TyoConfig.SelectedSpot then
					getgenv().SelectedFishingSpot = getgenv().TyoConfig.SelectedSpot
				end
			end
		end
	end)
end

if getgenv().TyoConfig.AutoLoadEnabled then
	LoadConfig()
end

task.spawn(function()
	while true do
		task.wait(30)
		if getgenv().TyoConfig.AutoSaveEnabled then
			SaveConfig()
		end
	end
end)

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
			SelectedTradeTarget = "",
			AutoSaveEnabled = true,
			AutoLoadEnabled = true,
			AutoReadyTrade = true,
			AutoConfirmTrade = true,
			AutoAcceptTrade = true,
			AutoAddAllFishTrade = true,
			FlySpeed = 50,
			JumpPowerValue = 100,
			FavRarities = { ["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false, ["Legendary"] = true, ["Mythical"] = true, ["Secret"] = true, ["Forgotten"] = true, ["Aether"] = true },
			FavMutations = { ["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false, ["Lightning"] = false, ["Fairy Dust"] = true, ["Gold"] = false, ["Midnight"] = false, ["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false, ["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false, ["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false, ["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false },
			UnfavRarities = { ["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false, ["Legendary"] = false, ["Mythical"] = false, ["Secret"] = false, ["Forgotten"] = false },
			UnfavMutations = { ["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false, ["Lightning"] = false, ["Fairy Dust"] = false, ["Gold"] = false, ["Midnight"] = false, ["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false, ["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false, ["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false, ["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false },
			SpotLoopConfig = {
				["Spot Mancing Jembatan"] = { Enabled = false, Timer = "10" },
				["Spot Mancing Core"] = { Enabled = false, Timer = "10" },
				["Spot Mancing Ikan Anomali"] = { Enabled = false, Timer = "10" }
			}
		}
		getgenv().SelectedFishingSpot = "Spot Mancing Jembatan"
		if delfile and isfile and isfile(CONFIG_FILE) then
			delfile(CONFIG_FILE)
		end
	end)
end

------------------------------------------------------------------
-- DISCORD WEBHOOK SYSTEM
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
			
			local embedTitle = "👑 Aemeath Wuthering Waves Hub V3 - Mount Soreya Rare Catch Tracker!"
			local alertContent = string.format("@everyone 🚨 **%s Berhasil Mendapatkan Tangkapan Langka!**", targetPlayer)
			local embedColor = 10040319
			
			if string.find(typeLower, "core") or string.find(typeLower, "aether") then
				alertContent = string.format("@everyone ⚡ **%s Mendapatkan Item Spesial / Aether Material!**", targetPlayer)
				embedTitle = "💎 Aemeath Wuthering Waves Hub V3 - Mount Soreya Event Tracker!"
				embedColor = 16776960
			end
			
			local posStr = position and string.format("%.1f, %.1f, %.1f", position.X, position.Y, position.Z) or "N/A"
			
			requestFunc({
				Url = url,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({
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
							["footer"] = { ["text"] = "Aemeath Wuthering Waves Edition • Monitor" },
							["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
						}
					}
				})
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
-- REAL-TIME CATCH MONITOR & STATS COUNTER
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
-- AUTO EQUIP ROD SYSTEM
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
-- HELPER: AUTO FISHING & TAP CLICKER
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
getgenv().SelectedFishingSpot = getgenv().TyoConfig.SelectedSpot
getgenv().AutoSellRunning = false
getgenv().AutoGalatamaRunning = true -- AUTO GALATAMA DIAKTIFKAN OTOMATIS
getgenv().AutoSummitRunning = false
getgenv().AntiAFKRunning = true -- ANTI-AFK DIAKTIFKAN OTOMATIS
getgenv().HideNameRunning = false
getgenv().FakeNameInput = "AEMEATH HUB"
getgenv().CurrentSelectedHalo = nil
getgenv().AutoDetectCoreEvent = false
getgenv().LoopSpotEnabled = false
getgenv().AutoFavoriteRunning = false
getgenv().InvisibleRunning = false
getgenv().NetworkBoostRunning = true -- NETWORK BOOSTER DIAKTIFKAN OTOMATIS

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
-- AUTO FISHING
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
			task.wait(tonumber(getgenv().TyoConfig.BiteDelay) or 0.5)
			
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
			local success, result = pcall(function() return {ambilSemuaRemote:InvokeServer()} end)
			if success and result and result[1] then
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
-- IMPROVED TRADE UTILITIES (AUTO SIAP, KONFIRMASI, ACCEPT & ADD ALL)
------------------------------------------------------------------
local function GetTradeRemote(actionName)
	local res = nil
	pcall(function()
		local tradeFolder = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Trade")
		if tradeFolder then
			res = tradeFolder:FindFirstChild(actionName)
		end
	end)
	return res
end

local RarityPriority = {
	["aether"] = 9,
	["forgotten"] = 8,
	["secret"] = 7,
	["mythical"] = 6,
	["legendary"] = 5,
	["epic"] = 4,
	["rare"] = 3,
	["uncommon"] = 2,
	["common"] = 1
}

local function AutoAddAllFishToTrade()
	pcall(function()
		local serverData = GetServerFishData()
		
		table.sort(serverData, function(a, b)
			local rankA = RarityPriority[string.lower(a.Rarity)] or 0
			local rankB = RarityPriority[string.lower(b.Rarity)] or 0
			return rankA > rankB
		end)
		
		local tradeRemote = GetTradeRemote("AddItem") or GetTradeRemote("AddFish") or GetTradeRemote("TambahItem")
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
			local reqRemote = GetTradeRemote("Request") or GetTradeRemote("SendRequest") or GetTradeRemote("KirimRequest")
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

local function ClickGuiButtonByName(targetNames)
	pcall(function()
		for _, guiObj in ipairs(PlayerGui:GetDescendants()) do
			if (guiObj:IsA("TextButton") or guiObj:IsA("ImageButton")) and guiObj.Visible then
				local textVal = guiObj:IsA("TextButton") and string.lower(guiObj.Text) or ""
				local nameVal = string.lower(guiObj.Name)
				
				for _, tName in ipairs(targetNames) do
					local targetLower = string.lower(tName)
					if string.find(textVal, targetLower) or string.find(nameVal, targetLower) then
						if firesignal then
							firesignal(guiObj.MouseButton1Click)
							firesignal(guiObj.Activated)
						elseif getconnections then
							for _, c in ipairs(getconnections(guiObj.MouseButton1Click)) do c:Fire() end
						end
					end
				end
			end
		end
	end)
end

task.spawn(function()
	while true do
		pcall(function()
			if getgenv().TyoConfig.AutoAddAllFishTrade then
				AutoAddAllFishToTrade()
			end

			if getgenv().TyoConfig.AutoReadyTrade then
				ClickGuiButtonByName({"siap", "ready"})
				local readyRemote = GetTradeRemote("Ready") or GetTradeRemote("Siap") or GetTradeRemote("SetReady")
				if readyRemote then
					if readyRemote:IsA("RemoteEvent") then readyRemote:FireServer(true)
					elseif readyRemote:IsA("RemoteFunction") then readyRemote:InvokeServer(true) end
				end
			end

			if getgenv().TyoConfig.AutoConfirmTrade then
				ClickGuiButtonByName({"konfirmasi", "confirm", "ok", "yes"})
				local confirmRemote = GetTradeRemote("Confirm") or GetTradeRemote("Konfirmasi") or GetTradeRemote("SetConfirm")
				if confirmRemote then
					if confirmRemote:IsA("RemoteEvent") then confirmRemote:FireServer()
					elseif confirmRemote:IsA("RemoteFunction") then confirmRemote:InvokeServer() end
				end
			end

			if getgenv().TyoConfig.AutoAcceptTrade then
				ClickGuiButtonByName({"terima", "accept", "yes"})
				local acceptRemote = GetTradeRemote("Accept") or GetTradeRemote("TerimaTrade")
				if acceptRemote then
					if acceptRemote:IsA("RemoteEvent") then acceptRemote:FireServer()
					elseif acceptRemote:IsA("RemoteFunction") then acceptRemote:InvokeServer() end
				end
			end
		end)
		task.wait(0.2)
	end
end)

----------------------------------------------------
-- EXECUTOR OTOMATIS: AUTO GALATAMA, ANTI-AFK, NETWORK BOOSTER & ANTI-LAG
----------------------------------------------------
-- 1. Auto Galatama Background Task
task.spawn(function()
	while true do
		if getgenv().AutoGalatamaRunning then
			pcall(function()
				local galatamaRemote = ReplicatedStorage:FindFirstChild("Remote")
					and ReplicatedStorage.Remote:FindFirstChild("Glatama")
					and ReplicatedStorage.Remote.Glatama:FindFirstChild("Ikut")
				if galatamaRemote then
					galatamaRemote:InvokeServer()
				end
			end)
		end
		task.wait(10)
	end
end)

-- 2. Anti-AFK Background Task
LocalPlayer.Idled:Connect(function()
	if getgenv().AntiAFKRunning then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(0, 0))
		end)
	end
end)

task.spawn(function()
	while true do
		task.wait(60)
		if getgenv().AntiAFKRunning then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:Button1Down(Vector2.new(0, 0))
				task.wait(0.1)
				VirtualUser:Button1Up(Vector2.new(0, 0))
			end)
		end
	end
end)

-- 3. Network Booster Background Task
task.spawn(function()
	while true do
		if getgenv().NetworkBoostRunning then
			pcall(function()
				settings():GetService("NetworkSettings").IncomingReplicationLag = 0
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character then
						for _, part in ipairs(p.Character:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CastShadow = false
							end
						end
					end
				end
			end)
		end
		task.wait(2)
	end
end)

-- 4. Langsung Terapkan Anti-Lag / Extreme Potato & Hapus Tembok saat Skrip Dijalankan
task.spawn(function()
	pcall(function()
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 100
		Lighting.FogStart = 0
		Lighting.Brightness = 2
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
		
		pcall(function()
			Workspace.CurrentCamera.CFrame = Workspace.CurrentCamera.CFrame
			LocalPlayer.CameraMaxZoomDistance = 30
			LocalPlayer.CameraMinZoomDistance = 5
		end)
		
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
				v:Destroy()
			end
		end
		
		for _, v in ipairs(workspace:GetDescendants()) do
			pcall(function()
				local nameLower = string.lower(v.Name)
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Explosion") or v:IsA("Highlight") or v:IsA("Decal") or v:IsA("Texture") then
					v:Destroy()
				elseif v:IsA("BasePart") then
					if string.find(nameLower, "wall") or string.find(nameLower, "tembok") or string.find(nameLower, "dinding") or string.find(nameLower, "building") or string.find(nameLower, "house") or string.find(nameLower, "prop") or string.find(nameLower, "rock") or string.find(nameLower, "tree") then
						v:Destroy()
					else
						v.Material = Enum.Material.SmoothPlastic
						v.Reflectance = 0
						v.CastShadow = false
					end
				end
			end)
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
end)

----------------------------------------------------
-- UI SETUP & INTERFACE (DENGAN TAB LENGKAP & DRAGGABLE)
----------------------------------------------------
pcall(function()
	local oldGui = PlayerGui:FindFirstChild("TyoHub")
	if oldGui then oldGui:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "TyoHub"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 2147483647

local function MakeDraggable(guiObject, handleObject)
	handleObject = handleObject or guiObject
	local dragging = false
	local dragInput = nil
	local dragStart = Vector3.zero
	local startPos = UDim2.new()
	local isClick = true
	local clickTimeStart = 0

	local function update(input)
		local delta = input.Position - dragStart
		if delta.Magnitude > 6 then isClick = false end
		guiObject.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end

	handleObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			isClick = true
			clickTimeStart = tick()
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

	return function() return isClick and (tick() - clickTimeStart < 0.35) end
end

local Main = Instance.new("ImageLabel")
Main.Parent = Gui
Main.Visible = true
Main.Size = UDim2.new(0, 560, 0, 330)
Main.Position = UDim2.new(0.5, -280, 0.5, -165)
Main.Image = "rbxassetid://106191671617535"
Main.ImageTransparency = 0.35
Main.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
Main.ScaleType = Enum.ScaleType.Crop
Main.ClipsDescendants = true
Main.ZIndex = 10

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(80, 150, 255)
MainStroke.Thickness = 1.5

local TopBar = Instance.new("Frame")
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
TopBar.ZIndex = 11

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

MakeDraggable(Main, TopBar)

local HubTitle = Instance.new("TextLabel")
HubTitle.Parent = TopBar
HubTitle.Position = UDim2.new(0, 15, 0, 0)
HubTitle.Size = UDim2.new(0, 320, 1, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "AEMEATH HUB <font color='#50A0FF'>V3</font> (AUTO ACTIVE)"
HubTitle.RichText = true
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
HubTitle.TextSize = 14
HubTitle.TextXAlignment = Enum.TextXAlignment.Left
HubTitle.ZIndex = 12

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Parent = TopBar
ControlsFrame.Size = UDim2.new(0, 65, 1, 0)
ControlsFrame.Position = UDim2.new(1, -70, 0, 0)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.ZIndex = 12

local ControlLayout = Instance.new("UIListLayout")
ControlLayout.Parent = ControlsFrame
ControlLayout.FillDirection = Enum.FillDirection.Horizontal
ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
ControlLayout.Padding = UDim.new(0, 5)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = ControlsFrame
MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 56)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(210, 225, 240)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.ZIndex = 13
local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = MinimizeBtn

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = ControlsFrame
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 80)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.ZIndex = 13
local clsCorner = Instance.new("UICorner")
clsCorner.CornerRadius = UDim.new(0, 6)
clsCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local PingLabel = Instance.new("TextLabel")
PingLabel.Parent = TopBar
PingLabel.Size = UDim2.new(0, 120, 1, 0)
PingLabel.Position = UDim2.new(1, -200, 0, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Text = "Ping: ... ms"
PingLabel.TextColor3 = Color3.fromRGB(80, 255, 200)
PingLabel.Font = Enum.Font.GothamBold
PingLabel.TextSize = 11
PingLabel.TextXAlignment = Enum.TextXAlignment.Right
PingLabel.ZIndex = 12

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
Sidebar.Position = UDim2.new(0, 8, 0, 42)
Sidebar.Size = UDim2.new(0, 135, 1, -50)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
Sidebar.BackgroundTransparency = 0.2
Sidebar.CanvasSize = UDim2.new(0, 0, 3.2, 0)
Sidebar.ScrollBarThickness = 0
Sidebar.ZIndex = 11

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 8)
sbCorner.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.Padding = UDim.new(0, 4)
SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.new(0, 150, 0, 42)
Content.Size = UDim2.new(1, -158, 1, -50)
Content.BackgroundTransparency = 1
Content.ZIndex = 11

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	MinimizeBtn.Text = isMinimized and "+" or "-"
	Main:TweenSize(isMinimized and UDim2.new(0,560,0,35) or UDim2.new(0,560,0,330), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
	Sidebar.Visible = not isMinimized
	Content.Visible = not isMinimized
end)

local navButtons = {}
local pages = {}

local function CreateNavButton(text)
	local btn = Instance.new("TextButton")
	btn.Parent = Sidebar
	btn.Size = UDim2.new(0, 125, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(22, 29, 48)
	btn.BackgroundTransparency = 0.2
	btn.Text = "  " .. text
	btn.TextColor3 = Color3.fromRGB(160, 180, 210)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.ZIndex = 12
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Parent = btn
	indicator.Size = UDim2.new(0, 3, 0, 18)
	indicator.Position = UDim2.new(0, 3, 0.5, -9)
	indicator.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
	indicator.Visible = false
	indicator.ZIndex = 13
	local indCorner = Instance.new("UICorner")
	indCorner.CornerRadius = UDim.new(0, 2)
	indCorner.Parent = indicator
	return btn
end

local function MakePage()
	local f = Instance.new("ScrollingFrame")
	f.Parent = Content
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.CanvasSize = UDim2.new(0, 0, 6, 0)
	f.ScrollBarThickness = 3
	f.ScrollBarImageColor3 = Color3.fromRGB(80, 150, 255)
	f.ZIndex = 12
	local pad = Instance.new("UIPadding")
	pad.Parent = f
	pad.PaddingTop = UDim.new(0, 5)
	local l = Instance.new("UIListLayout")
	l.Parent = f
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 6)
	return f
end

local tabList = {"Fishing & Sell", "⭐ Favorite", "🤝 Auto Trade", "Galatama", "Teleport Shop", "Summit", "Player", "Halo Kepala", "Teleport Player", "Privacy", "Settings", "Credits"}

for _, name in ipairs(tabList) do
	local btn = CreateNavButton(name)
	local page = MakePage()
	navButtons[name] = btn
	pages[name] = page
	
	btn.MouseButton1Click:Connect(function()
		for _, p in pairs(pages) do p.Visible = false end
		for _, b in pairs(navButtons) do
			b.BackgroundColor3 = Color3.fromRGB(22, 29, 48)
			b.TextColor3 = Color3.fromRGB(160, 180, 210)
			if b:FindFirstChild("Indicator") then b.Indicator.Visible = false end
		end
		page.Visible = true
		btn.BackgroundColor3 = Color3.fromRGB(35, 48, 78)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		if btn:FindFirstChild("Indicator") then btn.Indicator.Visible = true end
	end)
end

pages["Fishing & Sell"].Visible = true
navButtons["Fishing & Sell"].BackgroundColor3 = Color3.fromRGB(35, 48, 78)
navButtons["Fishing & Sell"].TextColor3 = Color3.fromRGB(255, 255, 255)
navButtons["Fishing & Sell"].Indicator.Visible = true

local function AddToggle(parent, text, callback, initialValue)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1, -5, 0, 36)
	frame.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
	frame.BackgroundTransparency = 0.2
	frame.ZIndex = 13
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 6)
	fc.Parent = frame
	local label = Instance.new("TextLabel")
	label.Parent = frame
	label.Position = UDim2.new(0, 12, 0, 0)
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(210, 225, 240)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 14
	local switchBg = Instance.new("TextButton")
	switchBg.Parent = frame
	switchBg.Position = UDim2.new(1, -45, 0.5, -10)
	switchBg.Size = UDim2.new(0, 36, 0, 20)
	switchBg.BackgroundColor3 = Color3.fromRGB(30, 40, 64)
	switchBg.Text = ""
	switchBg.ZIndex = 14
	local sbc = Instance.new("UICorner")
	sbc.CornerRadius = UDim.new(1, 0)
	sbc.Parent = switchBg
	local knob = Instance.new("Frame")
	knob.Parent = switchBg
	knob.Position = UDim2.new(0, 2, 0.5, -7)
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.BackgroundColor3 = Color3.fromRGB(130, 150, 180)
	knob.ZIndex = 15
	local kc = Instance.new("UICorner")
	kc.CornerRadius = UDim.new(1, 0)
	kc.Parent = knob
	
	local state = initialValue or false
	if state then
		knob.Position = UDim2.new(1, -16, 0.5, -7)
		switchBg.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
	
	switchBg.MouseButton1Click:Connect(function()
		state = not state
		if state then
			knob:TweenPosition(UDim2.new(1, -16, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.15, true)
			switchBg.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		else
			knob:TweenPosition(UDim2.new(0, 2, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.15, true)
			switchBg.BackgroundColor3 = Color3.fromRGB(30, 40, 64)
			knob.BackgroundColor3 = Color3.fromRGB(130, 150, 180)
		end
		callback(state)
	end)
end

----------------------------------------------------
-- 1. FISHING PAGE
----------------------------------------------------
local FishingPage = pages["Fishing & Sell"]
local TitleFish = Instance.new("TextLabel")
TitleFish.Parent = FishingPage
TitleFish.Size = UDim2.new(1, 0, 0, 25)
TitleFish.BackgroundTransparency = 1
TitleFish.Text = "🔥 AUTO FISHING & SELL (MOUNT SOREYA)"
TitleFish.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleFish.Font = Enum.Font.GothamBold
TitleFish.TextSize = 12
TitleFish.ZIndex = 13

local SpotDropdownFrame = Instance.new("Frame")
SpotDropdownFrame.Parent = FishingPage
SpotDropdownFrame.Size = UDim2.new(1, -5, 0, 36)
SpotDropdownFrame.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
SpotDropdownFrame.BackgroundTransparency = 0.2
SpotDropdownFrame.ClipsDescendants = true
SpotDropdownFrame.ZIndex = 13
local sdc = Instance.new("UICorner")
sdc.CornerRadius = UDim.new(0, 6)
sdc.Parent = SpotDropdownFrame

local DropHeader = Instance.new("TextButton")
DropHeader.Parent = SpotDropdownFrame
DropHeader.Size = UDim2.new(1, 0, 0, 36)
DropHeader.BackgroundTransparency = 1
DropHeader.Text = " 📍 Spot: " .. (getgenv().SelectedFishingSpot or "Spot Mancing Jembatan") .. " 🔽"
DropHeader.TextColor3 = Color3.fromRGB(210, 225, 240)
DropHeader.Font = Enum.Font.GothamMedium
DropHeader.TextSize = 11
DropHeader.TextXAlignment = Enum.TextXAlignment.Left
DropHeader.ZIndex = 14

local function SetSpotDisplay(text) DropHeader.Text = " 📍 Spot: " .. tostring(text) .. " 🔽" end

local DropContainer = Instance.new("Frame")
DropContainer.Parent = SpotDropdownFrame
DropContainer.Position = UDim2.new(0, 5, 0, 36)
DropContainer.Size = UDim2.new(1, -10, 0, 95)
DropContainer.BackgroundTransparency = 1
DropContainer.ZIndex = 14

local DropLayout = Instance.new("UIListLayout")
DropLayout.Parent = DropContainer
DropLayout.Padding = UDim.new(0, 4)

local isDropOpen = false
DropHeader.MouseButton1Click:Connect(function()
	isDropOpen = not isDropOpen
	SpotDropdownFrame:TweenSize(isDropOpen and UDim2.new(1, -5, 0, 135) or UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
end)

for _, spotName in ipairs({"Spot Mancing Jembatan", "Spot Mancing Core", "Spot Mancing Ikan Anomali"}) do
	local optBtn = Instance.new("TextButton")
	optBtn.Parent = DropContainer
	optBtn.Size = UDim2.new(1, 0, 0, 28)
	optBtn.BackgroundColor3 = Color3.fromRGB(22, 29, 48)
	optBtn.BackgroundTransparency = 0.2
	optBtn.Text = " " .. spotName
	optBtn.TextColor3 = Color3.fromRGB(160, 180, 210)
	optBtn.Font = Enum.Font.Gotham
	optBtn.TextSize = 11
	optBtn.TextXAlignment = Enum.TextXAlignment.Left
	optBtn.ZIndex = 15
	local obc = Instance.new("UICorner")
	obc.CornerRadius = UDim.new(0, 4)
	obc.Parent = optBtn
	optBtn.MouseButton1Click:Connect(function()
		getgenv().SelectedFishingSpot = spotName
		getgenv().TyoConfig.SelectedSpot = spotName
		SetSpotDisplay(spotName)
		isDropOpen = false
		SpotDropdownFrame:TweenSize(UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
		SaveConfig()
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

----------------------------------------------------
-- 4. GALATAMA PAGE (AUTO GALATAMA DEFAULT ON)
----------------------------------------------------
local GalatamaPage = pages["Galatama"]
local TitleGal = Instance.new("TextLabel")
TitleGal.Parent = GalatamaPage
TitleGal.Size = UDim2.new(1, -5, 0, 25)
TitleGal.BackgroundTransparency = 1
TitleGal.Text = "🏆 GALATAMA & CORE EVENT UTILITIES"
TitleGal.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleGal.Font = Enum.Font.GothamBold
TitleGal.TextSize = 12
TitleGal.ZIndex = 13

local TeleportGalatamaBtn = Instance.new("TextButton")
TeleportGalatamaBtn.Parent = GalatamaPage
TeleportGalatamaBtn.Size = UDim2.new(1, -5, 0, 34)
TeleportGalatamaBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
TeleportGalatamaBtn.Text = "📍 Teleport ke Galatama"
TeleportGalatamaBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportGalatamaBtn.Font = Enum.Font.GothamBold
TeleportGalatamaBtn.TextSize = 11
TeleportGalatamaBtn.ZIndex = 13
local tgc = Instance.new("UICorner")
tgc.CornerRadius = UDim.new(0, 6)
tgc.Parent = TeleportGalatamaBtn
TeleportGalatamaBtn.MouseButton1Click:Connect(function()
	pcall(function() LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-8008.12744, 1227.96838, -6091.92627) + Vector3.new(0, 5, 0) end)
end)

AddToggle(GalatamaPage, "Aktifkan Auto Join Galatama", function(v)
	getgenv().AutoGalatamaRunning = v
end, true) -- Default ON

----------------------------------------------------
-- 7. PLAYER PAGE (FLY, HIGH JUMP, NETWORK BOOSTER, ANTI-AFK)
----------------------------------------------------
local PlayerPage = pages["Player"]
local TitlePly = Instance.new("TextLabel")
TitlePly.Parent = PlayerPage
TitlePly.Size = UDim2.new(1, -5, 0, 25)
TitlePly.BackgroundTransparency = 1
TitlePly.Text = "⚡ PLAYER SETTINGS & MOVEMENT"
TitlePly.TextColor3 = Color3.fromRGB(80, 150, 255)
TitlePly.Font = Enum.Font.GothamBold
TitlePly.TextSize = 12
TitlePly.ZIndex = 13

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = PlayerPage
SpeedBox.Size = UDim2.new(1, -5, 0, 36)
SpeedBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
SpeedBox.BackgroundTransparency = 0.2
SpeedBox.PlaceholderText = "Ketik WalkSpeed (Cth: 50)"
SpeedBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
SpeedBox.Text = ""
SpeedBox.TextColor3 = Color3.fromRGB(210, 225, 240)
SpeedBox.Font = Enum.Font.GothamMedium
SpeedBox.TextSize = 11
SpeedBox.ZIndex = 13
local spc = Instance.new("UICorner")
spc.CornerRadius = UDim.new(0, 6)
spc.Parent = SpeedBox
SpeedBox.FocusLost:Connect(function()
	local num = tonumber(SpeedBox.Text)
	if num then pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = num end) end
end)

local JumpBox = Instance.new("TextBox")
JumpBox.Parent = PlayerPage
JumpBox.Size = UDim2.new(1, -5, 0, 36)
JumpBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
JumpBox.BackgroundTransparency = 0.2
JumpBox.PlaceholderText = "Ketik JumpPower (Cth: 100)"
JumpBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
JumpBox.Text = tostring(getgenv().TyoConfig.JumpPowerValue or 100)
JumpBox.TextColor3 = Color3.fromRGB(210, 225, 240)
JumpBox.Font = Enum.Font.GothamMedium
JumpBox.TextSize = 11
JumpBox.ZIndex = 13
local jpc = Instance.new("UICorner")
jpc.CornerRadius = UDim.new(0, 6)
jpc.Parent = JumpBox

JumpBox.FocusLost:Connect(function()
	local num = tonumber(JumpBox.Text)
	if num then
		getgenv().TyoConfig.JumpPowerValue = num
		SaveConfig()
		pcall(function()
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.UseJumpPower = true hum.JumpPower = num end
		end)
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	task.wait(1)
	pcall(function()
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.UseJumpPower = true
			hum.JumpPower = getgenv().TyoConfig.JumpPowerValue or 100
		end
	end)
end)

local flyActive = false
local flyConnection = nil
local bv, bg

AddToggle(PlayerPage, "🛸 Aktifkan Fly (Terbang)", function(v)
	flyActive = v
	pcall(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		
		if flyActive then
			if hrp and hum then
				hum.PlatformStand = true
				bv = Instance.new("BodyVelocity")
				bv.Name = "TyoFlyVelocity"
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.zero
				bv.Parent = hrp
				
				bg = Instance.new("BodyGyro")
				bg.Name = "TyoFlyGyro"
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.CFrame = hrp.CFrame
				bg.Parent = hrp
				
				flyConnection = RunService.RenderStepped:Connect(function()
					if not flyActive or not hrp or not hum or hum.Health <= 0 then return end
					local cam = Workspace.CurrentCamera
					local speed = tonumber(getgenv().TyoConfig.FlySpeed) or 50
					local moveDir = Vector3.zero
					
					if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then moveDir = moveDir + cam.CFrame.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then moveDir = moveDir - cam.CFrame.LookVector end
					if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then moveDir = moveDir - cam.CFrame.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then moveDir = moveDir + cam.CFrame.RightVector end
					if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
					if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
					
					bv.Velocity = moveDir * speed
					bg.CFrame = cam.CFrame
				end)
			end
		else
			if flyConnection then flyConnection:Disconnect() flyConnection = nil end
			if bv then bv:Destroy() bv = nil end
			if bg then bg:Destroy() bg = nil end
			if hum then hum.PlatformStand = false end
		end
	end)
end)

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Parent = PlayerPage
FlySpeedBox.Size = UDim2.new(1, -5, 0, 36)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
FlySpeedBox.BackgroundTransparency = 0.2
FlySpeedBox.PlaceholderText = "Kecepatan Fly (Cth: 50)"
FlySpeedBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
FlySpeedBox.Text = tostring(getgenv().TyoConfig.FlySpeed or 50)
FlySpeedBox.TextColor3 = Color3.fromRGB(210, 225, 240)
FlySpeedBox.Font = Enum.Font.GothamMedium
FlySpeedBox.TextSize = 11
FlySpeedBox.ZIndex = 13
local fsc = Instance.new("UICorner")
fsc.CornerRadius = UDim.new(0, 6)
fsc.Parent = FlySpeedBox

FlySpeedBox.FocusLost:Connect(function()
	local num = tonumber(FlySpeedBox.Text)
	if num then
		getgenv().TyoConfig.FlySpeed = num
		SaveConfig()
	end
end)

AddToggle(PlayerPage, "🚀 Peningkatan Jaringan (Network Booster)", function(v)
	getgenv().NetworkBoostRunning = v
end, true) -- Default ON

AddToggle(PlayerPage, "Anti-AFK", function(v)
	getgenv().AntiAFKRunning = v
end, true) -- Default ON

----------------------------------------------------
-- 11. SETTINGS & PERFORMANCE PAGE (ANTI-LAG DEFAULT ON)
----------------------------------------------------
local SettingsPage = pages["Settings"]
local TitleSet = Instance.new("TextLabel")
TitleSet.Parent = SettingsPage
TitleSet.Size = UDim2.new(1, -5, 0, 25)
TitleSet.BackgroundTransparency = 1
TitleSet.Text = "⚙️ SETTINGS & PERFORMANCE BOOST"
TitleSet.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleSet.Font = Enum.Font.GothamBold
TitleSet.TextSize = 12
TitleSet.ZIndex = 13

local AntiLagStatusBtn = Instance.new("TextButton")
AntiLagStatusBtn.Parent = SettingsPage
AntiLagStatusBtn.Size = UDim2.new(1, -5, 0, 34)
AntiLagStatusBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
AntiLagStatusBtn.Text = "⚡ EXTREME POTATO & HAPUS TEMBOK: [AKTIF OTOMATIS]"
AntiLagStatusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiLagStatusBtn.Font = Enum.Font.GothamBold
AntiLagStatusBtn.TextSize = 11
AntiLagStatusBtn.ZIndex = 13
local alc = Instance.new("UICorner")
alc.CornerRadius = UDim.new(0, 6)
alc.Parent = AntiLagStatusBtn

----------------------------------------------------
-- CREDITS & STATS TRACKER
----------------------------------------------------
local CreditsPage = pages["Credits"]
local CredLbl = Instance.new("TextLabel")
CredLbl.Parent = CreditsPage
CredLbl.Size = UDim2.new(1, -5, 1, 0)
CredLbl.BackgroundTransparency = 1
CredLbl.Text = "Aemeath Wuthering Waves Edition\nMap: Mount Soreya\nAll Auto-Boosters Active!"
CredLbl.TextColor3 = Color3.fromRGB(210, 225, 240)
CredLbl.Font = Enum.Font.GothamBold
CredLbl.TextSize = 14
CredLbl.ZIndex = 13

local StatPanel = Instance.new("Frame")
StatPanel.Parent = Main
StatPanel.Size = UDim2.new(1, -158, 0, 24)
StatPanel.Position = UDim2.new(0, 150, 1, -26)
StatPanel.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
StatPanel.BackgroundTransparency = 0.2
StatPanel.BorderSizePixel = 0
StatPanel.ZIndex = 11
local stpCorner = Instance.new("UICorner")
stpCorner.CornerRadius = UDim.new(0, 6)
stpCorner.Parent = StatPanel

local StatLabel = Instance.new("TextLabel")
StatLabel.Parent = StatPanel
StatLabel.Size = UDim2.new(1, -10, 1, 0)
StatLabel.Position = UDim2.new(0, 5, 0, 0)
StatLabel.BackgroundTransparency = 1
StatLabel.Text = "📊 Total Ikan: 0 | ⏱️ Play Time: 00s"
StatLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
StatLabel.Font = Enum.Font.GothamBold
StatLabel.TextSize = 10
StatLabel.TextXAlignment = Enum.TextXAlignment.Left
StatLabel.ZIndex = 12

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

local Float = Instance.new("ImageButton")
Float.Parent = Gui
Float.Size = UDim2.new(0, 48, 0, 48)
Float.Position = UDim2.new(0, 20, 0, 120)
Float.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
Float.Image = "rbxassetid://137785805499299"
Float.ScaleType = Enum.ScaleType.Crop
Float.Active = true
Float.Selectable = true
Float.ZIndex = 2147483647

local flCorner = Instance.new("UICorner")
flCorner.CornerRadius = UDim.new(1, 0)
flCorner.Parent = Float

local flStroke = Instance.new("UIStroke")
flStroke.Parent = Float
flStroke.Color = Color3.fromRGB(80, 150, 255)
flStroke.Thickness = 2

local isFloatClick = MakeDraggable(Float, Float)
Float.MouseButton1Click:Connect(function()
	if isFloatClick() then Main.Visible = not Main.Visible end
end)

print("Aemeath Wuthering Waves Hub V3 Loaded Successfully - All Features & Auto-Boosters Fully Active!")
