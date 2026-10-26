-- ==============================================================================
-- TYO HUB V3 (AEMEATH WUTHERING WAVES EDITION) | NO-KEY & MULTI-DEVICE
-- MAP: MOUNT SOREYA UPDATE (EXTREME POTATO & MINIMAL RENDER DISTANCE)
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
-- CONFIGURATION & FILE SAVE SYSTEM (AUTO SAVE & AUTO LOAD)
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
	AutoLoadEnabled = true
}

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
			AutoLoadEnabled = true
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
						["footer"] = { ["text"] = "Aemeath Wuthering Waves Edition • Monitor" },
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
getgenv().BiteDelayInput = getgenv().TyoConfig.BiteDelay
getgenv().SelectedFishingSpot = getgenv().TyoConfig.SelectedSpot
getgenv().AutoSellRunning = false
getgenv().AutoSellTimerInput = getgenv().TyoConfig.AutoSellTimer
getgenv().AutoGalatamaRunning = false
getgenv().AutoSummitRunning = false
getgenv().AntiAFKRunning = false
getgenv().HideNameRunning = false
getgenv().FakeNameInput = "AEMEATH HUB"
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
getgenv().InvisibleRunning = false
getgenv().NetworkBoostRunning = false

-- FLY & LONG JUMP STATES
getgenv().FlyRunning = false
getgenv().FlySpeed = 50
getgenv().LongJumpRunning = false
getgenv().JumpPowerMultiplier = 3

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
-- FLY SYSTEM
------------------------------------------------------------------
local flyConn = nil
local function StartFly()
	if flyConn then flyConn:Disconnect() end
	local cam = Workspace.CurrentCamera
	flyConn = RunService.RenderStepped:Connect(function()
		if not getgenv().FlyRunning then return end
		pcall(function()
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hrp and hum then
				hum.PlatformStand = true
				local moveDir = hum.MoveDirection
				local camCF = cam.CFrame
				local velocity = Vector3.zero
				
				if moveDir.Magnitude > 0 then
					local moveV = (camCF.RightVector * moveDir.X + camCF.LookVector * moveDir.Z)
					velocity = Vector3.new(moveV.X, 0, moveV.Z).Unit * getgenv().FlySpeed
				end
				
				if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.ButtonR2) then
					velocity = velocity + Vector3.new(0, getgenv().FlySpeed, 0)
				elseif UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.ButtonL2) then
					velocity = velocity - Vector3.new(0, getgenv().FlySpeed, 0)
				end
				
				hrp.AssemblyLinearVelocity = velocity
			end
		end)
	end)
end

local function StopFly()
	if flyConn then flyConn:Disconnect(); flyConn = nil end
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hum then hum.PlatformStand = false end
		if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
	end)
end

------------------------------------------------------------------
-- LONG JUMP / SUPER JUMP SYSTEM
------------------------------------------------------------------
UIS.JumpRequest:Connect(function()
	if not getgenv().LongJumpRunning then return end
	pcall(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and hum and hum.FloorMaterial ~= Enum.Material.Air then
			local jumpPower = (hum.JumpPower > 0 and hum.JumpPower) or (hum.JumpHeight * 50) or 50
			hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, jumpPower * (getgenv().JumpPowerMultiplier or 3), hrp.AssemblyLinearVelocity.Z)
		end
	end)
end)

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
-- TRADE UTILITIES
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

local function AutoAddAllFishToTrade()
	pcall(function()
		local serverData = GetServerFishData()
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
Gui.DisplayOrder = 2147483647

----------------------------------------------------
-- IMPROVED UNIVERSAL DRAGGABLE FUNCTION
----------------------------------------------------
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
		if delta.Magnitude > 6 then
			isClick = false
		end
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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handleObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	return function()
		return isClick and (tick() - clickTimeStart < 0.35)
	end
end

----------------------------------------------------
-- MAIN HUB UI (WUTHERING WAVES / AEMEATH AURA THEME)
----------------------------------------------------
local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Visible = true
Main.Size = UDim2.new(0, 560, 0, 330)
Main.Position = UDim2.new(0.5, -280, 0.5, -165)
Main.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
Main.ClipsDescendants = true
Main.ZIndex = 10

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(80, 150, 255)
MainStroke.Thickness = 1.5

-- Top Bar Header
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
HubTitle.Size = UDim2.new(0, 300, 1, 0)
HubTitle.BackgroundTransparency = 1
HubTitle.Text = "AEMEATH HUB <font color='#50A0FF'>V3</font>"
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

-- Sidebar Tabs
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = Main
Sidebar.Position = UDim2.new(0, 8, 0, 42)
Sidebar.Size = UDim2.new(0, 135, 1, -50)
Sidebar.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
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

----------------------------------------------------
-- SPEED HUB STYLE TOGGLE BUILDER
----------------------------------------------------
local function AddToggle(parent, text, callback, initialValue)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1, -5, 0, 36)
	frame.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
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

local function SetSpotDisplay(text)
	DropHeader.Text = " 📍 Spot: " .. tostring(text) .. " 🔽"
end

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

local ModeDropdownFrame = Instance.new("Frame")
ModeDropdownFrame.Parent = FishingPage
ModeDropdownFrame.Size = UDim2.new(1, -5, 0, 36)
ModeDropdownFrame.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
ModeDropdownFrame.ClipsDescendants = true
ModeDropdownFrame.ZIndex = 13
local mdc = Instance.new("UICorner")
mdc.CornerRadius = UDim.new(0, 6)
mdc.Parent = ModeDropdownFrame

local ModeDropHeader = Instance.new("TextButton")
ModeDropHeader.Parent = ModeDropdownFrame
ModeDropHeader.Size = UDim2.new(1, 0, 0, 36)
ModeDropHeader.BackgroundTransparency = 1
ModeDropHeader.Text = " 🎮 Mode Fishing: " .. (getgenv().TyoConfig.MinigameMode or "Legit") .. " 🔽"
ModeDropHeader.TextColor3 = Color3.fromRGB(210, 225, 240)
ModeDropHeader.Font = Enum.Font.GothamMedium
ModeDropHeader.TextSize = 11
ModeDropHeader.TextXAlignment = Enum.TextXAlignment.Left
ModeDropHeader.ZIndex = 14

local ModeDropContainer = Instance.new("Frame")
ModeDropContainer.Parent = ModeDropdownFrame
ModeDropContainer.Position = UDim2.new(0, 5, 0, 36)
ModeDropContainer.Size = UDim2.new(1, -10, 0, 65)
ModeDropContainer.BackgroundTransparency = 1
ModeDropContainer.ZIndex = 14

local ModeDropLayout = Instance.new("UIListLayout")
ModeDropLayout.Parent = ModeDropContainer
ModeDropLayout.Padding = UDim.new(0, 4)

local isModeDropOpen = false
ModeDropHeader.MouseButton1Click:Connect(function()
	isModeDropOpen = not isModeDropOpen
	ModeDropdownFrame:TweenSize(isModeDropOpen and UDim2.new(1, -5, 0, 105) or UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
end)

local fishingModes = {
	{ Name = "Legit Fishing (Auto Bawaan + Tap-Tap)", Value = "Legit" },
	{ Name = "Instant Fishing (Bypass Cepat)", Value = "Instant" }
}

for _, modeData in ipairs(fishingModes) do
	local mOptBtn = Instance.new("TextButton")
	mOptBtn.Parent = ModeDropContainer
	mOptBtn.Size = UDim2.new(1, 0, 0, 28)
	mOptBtn.BackgroundColor3 = Color3.fromRGB(22, 29, 48)
	mOptBtn.Text = " " .. modeData.Name
	mOptBtn.TextColor3 = Color3.fromRGB(160, 180, 210)
	mOptBtn.Font = Enum.Font.Gotham
	mOptBtn.TextSize = 11
	mOptBtn.TextXAlignment = Enum.TextXAlignment.Left
	mOptBtn.ZIndex = 15
	local mobc = Instance.new("UICorner")
	mobc.CornerRadius = UDim.new(0, 4)
	mobc.Parent = mOptBtn
	
	mOptBtn.MouseButton1Click:Connect(function()
		local oldMode = getgenv().TyoConfig.MinigameMode
		getgenv().TyoConfig.MinigameMode = modeData.Value
		ModeDropHeader.Text = " 🎮 Mode Fishing: " .. modeData.Value .. " 🔽"
		isModeDropOpen = false
		ModeDropdownFrame:TweenSize(UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
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
BiteDelayBox.Size = UDim2.new(1, -5, 0, 36)
BiteDelayBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
BiteDelayBox.PlaceholderText = "Bite Delay (Detik, Cth: 0.5) - Mode Instant"
BiteDelayBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
BiteDelayBox.Text = tostring(getgenv().TyoConfig.BiteDelay)
BiteDelayBox.TextColor3 = Color3.fromRGB(210, 225, 240)
BiteDelayBox.Font = Enum.Font.GothamMedium
BiteDelayBox.TextSize = 11
BiteDelayBox.ZIndex = 13
local bdCorner = Instance.new("UICorner")
bdCorner.CornerRadius = UDim.new(0, 6)
bdCorner.Parent = BiteDelayBox
BiteDelayBox.FocusLost:Connect(function()
	getgenv().TyoConfig.BiteDelay = BiteDelayBox.Text
	SaveConfig()
end)

local TapDelayBox = Instance.new("TextBox")
TapDelayBox.Parent = FishingPage
TapDelayBox.Size = UDim2.new(1, -5, 0, 36)
TapDelayBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
TapDelayBox.PlaceholderText = "Jeda Tap (Detik, Cth: 0.12) - Mode Legit"
TapDelayBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
TapDelayBox.Text = tostring(getgenv().TyoConfig.TapDelay or "0.12")
TapDelayBox.TextColor3 = Color3.fromRGB(210, 225, 240)
TapDelayBox.Font = Enum.Font.GothamMedium
TapDelayBox.TextSize = 11
TapDelayBox.ZIndex = 13
local tdCorner = Instance.new("UICorner")
tdCorner.CornerRadius = UDim.new(0, 6)
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
				if ((tick() - lastSellTime) / 60) >= (tonumber(getgenv().TyoConfig.AutoSellTimer) or 5) then
					TriggerSellToNpc()
					lastSellTime = tick()
				end
			end
		end)
	end
end)

local SellTimerBox = Instance.new("TextBox")
SellTimerBox.Parent = FishingPage
SellTimerBox.Size = UDim2.new(1, -5, 0, 36)
SellTimerBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
SellTimerBox.PlaceholderText = "Jeda Waktu Jual (Menit, Cth: 5)"
SellTimerBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
SellTimerBox.Text = tostring(getgenv().TyoConfig.AutoSellTimer)
SellTimerBox.TextColor3 = Color3.fromRGB(210, 225, 240)
SellTimerBox.Font = Enum.Font.GothamMedium
SellTimerBox.TextSize = 11
SellTimerBox.ZIndex = 13
local stCorner = Instance.new("UICorner")
stCorner.CornerRadius = UDim.new(0, 6)
stCorner.Parent = SellTimerBox
SellTimerBox.FocusLost:Connect(function()
	getgenv().TyoConfig.AutoSellTimer = SellTimerBox.Text
	SaveConfig()
end)

local TitleLoop = Instance.new("TextLabel")
TitleLoop.Parent = FishingPage
TitleLoop.Size = UDim2.new(1, -5, 0, 25)
TitleLoop.BackgroundTransparency = 1
TitleLoop.Text = "⏳ ROTASI AUTO SPOT MANCING (TIMER)"
TitleLoop.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleLoop.Font = Enum.Font.GothamBold
TitleLoop.TextSize = 12
TitleLoop.ZIndex = 13

AddToggle(FishingPage, "Aktifkan Loop Spot Mancing (Timer)", function(v) getgenv().LoopSpotEnabled = v end)

local function CreateSpotTimerSetting(parent, spotName)
	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1, -5, 0, 36)
	frame.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
	frame.ZIndex = 13
	local fc = Instance.new("UICorner")
	fc.CornerRadius = UDim.new(0, 6)
	fc.Parent = frame
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Parent = frame
	toggleBtn.Size = UDim2.new(0.65, 0, 1, 0)
	toggleBtn.BackgroundTransparency = 1
	toggleBtn.Text = " " .. spotName .. " [OFF]"
	toggleBtn.TextColor3 = Color3.fromRGB(210, 225, 240)
	toggleBtn.Font = Enum.Font.GothamMedium
	toggleBtn.TextSize = 11
	toggleBtn.TextXAlignment = Enum.TextXAlignment.Left
	toggleBtn.ZIndex = 14
	local timeBox = Instance.new("TextBox")
	timeBox.Parent = frame
	timeBox.Size = UDim2.new(0.3, -5, 0, 26)
	timeBox.Position = UDim2.new(0.7, 0, 0.5, -13)
	timeBox.BackgroundColor3 = Color3.fromRGB(24, 32, 52)
	timeBox.Text = getgenv().SpotLoopConfig[spotName].Timer
	timeBox.PlaceholderText = "Menit"
	timeBox.TextColor3 = Color3.fromRGB(80, 150, 255)
	timeBox.Font = Enum.Font.GothamBold
	timeBox.TextSize = 11
	timeBox.ZIndex = 14
	local tc = Instance.new("UICorner")
	tc.CornerRadius = UDim.new(0, 4)
	tc.Parent = timeBox
	toggleBtn.MouseButton1Click:Connect(function()
		local cur = not getgenv().SpotLoopConfig[spotName].Enabled
		getgenv().SpotLoopConfig[spotName].Enabled = cur
		toggleBtn.Text = " " .. spotName .. (cur and " [ON]" or " [OFF]")
		toggleBtn.TextColor3 = cur and Color3.fromRGB(80, 255, 200) or Color3.fromRGB(210, 225, 240)
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
-- DROPDOWN BUILDER
----------------------------------------------------
local function CreateMultiSelectDropdown(parent, titleText, optionsTable, targetStateTable)
	local container = Instance.new("Frame")
	container.Parent = parent
	container.Size = UDim2.new(1, -5, 0, 36)
	container.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
	container.ClipsDescendants = true
	container.ZIndex = 13
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 6)
	cc.Parent = container
	local header = Instance.new("TextButton")
	header.Parent = container
	header.Size = UDim2.new(1, 0, 0, 36)
	header.BackgroundTransparency = 1
	header.Text = " " .. titleText
	header.TextColor3 = Color3.fromRGB(210, 225, 240)
	header.Font = Enum.Font.GothamMedium
	header.TextSize = 11
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.ZIndex = 14
	local countLabel = Instance.new("TextLabel")
	countLabel.Parent = header
	countLabel.Size = UDim2.new(0, 120, 1, 0)
	countLabel.Position = UDim2.new(1, -130, 0, 0)
	countLabel.BackgroundTransparency = 1
	countLabel.TextColor3 = Color3.fromRGB(80, 150, 255)
	countLabel.Font = Enum.Font.GothamBold
	countLabel.TextSize = 11
	countLabel.TextXAlignment = Enum.TextXAlignment.Right
	countLabel.ZIndex = 15
	local optionsHolder = Instance.new("Frame")
	optionsHolder.Parent = container
	optionsHolder.Position = UDim2.new(0, 5, 0, 36)
	optionsHolder.Size = UDim2.new(1, -10, 0, 0)
	optionsHolder.BackgroundTransparency = 1
	optionsHolder.ZIndex = 14
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
	selectAllBtn.Size = UDim2.new(1, 0, 0, 28)
	selectAllBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
	selectAllBtn.Text = " ⚡ SELECT ALL / UNSELECT ALL"
	selectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	selectAllBtn.Font = Enum.Font.GothamBold
	selectAllBtn.TextSize = 10
	selectAllBtn.TextXAlignment = Enum.TextXAlignment.Left
	selectAllBtn.ZIndex = 15
	local saCorner = Instance.new("UICorner")
	saCorner.CornerRadius = UDim.new(0, 4)
	saCorner.Parent = selectAllBtn
	local allState = false
	selectAllBtn.MouseButton1Click:Connect(function()
		allState = not allState
		for _, optName in ipairs(optionsTable) do targetStateTable[optName] = allState end
		for optName, btn in pairs(itemButtons) do
			btn.BackgroundColor3 = allState and Color3.fromRGB(35, 48, 78) or Color3.fromRGB(22, 29, 48)
			btn.Text = " " .. optName .. (allState and " [✓]" or " [ ]")
		end
		UpdateSummary()
		SaveConfig()
	end)
	for _, optName in ipairs(optionsTable) do
		local optBtn = Instance.new("TextButton")
		optBtn.Parent = optionsHolder
		optBtn.Size = UDim2.new(1, 0, 0, 28)
		optBtn.BackgroundColor3 = targetStateTable[optName] and Color3.fromRGB(35, 48, 78) or Color3.fromRGB(22, 29, 48)
		optBtn.Text = " " .. optName .. (targetStateTable[optName] and " [✓]" or " [ ]")
		optBtn.TextColor3 = Color3.fromRGB(160, 180, 210)
		optBtn.Font = Enum.Font.Gotham
		optBtn.TextSize = 11
		optBtn.TextXAlignment = Enum.TextXAlignment.Left
		optBtn.ZIndex = 15
		local obc = Instance.new("UICorner")
		obc.CornerRadius = UDim.new(0, 4)
		obc.Parent = optBtn
		itemButtons[optName] = optBtn
		optBtn.MouseButton1Click:Connect(function()
			targetStateTable[optName] = not targetStateTable[optName]
			optBtn.BackgroundColor3 = targetStateTable[optName] and Color3.fromRGB(35, 48, 78) or Color3.fromRGB(22, 29, 48)
			optBtn.Text = " " .. optName .. (targetStateTable[optName] and " [✓]" or " [ ]")
			UpdateSummary()
			SaveConfig()
		end)
	end
	UpdateSummary()
	local isOpen = false
	header.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		container:TweenSize(isOpen and UDim2.new(1, -5, 0, 42 + ((#optionsTable + 1) * 32)) or UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
	end)
end

----------------------------------------------------
-- 2. FAVORITE PAGE
----------------------------------------------------
local FavoritePage = pages["⭐ Favorite"]

local TitleFav = Instance.new("TextLabel")
TitleFav.Parent = FavoritePage
TitleFav.Size = UDim2.new(1, -5, 0, 25)
TitleFav.BackgroundTransparency = 1
TitleFav.Text = "⭐ AUTO FAVORITE FILTER (BUAT PET AETHER)"
TitleFav.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleFav.Font = Enum.Font.GothamBold
TitleFav.TextSize = 12
TitleFav.ZIndex = 13

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
TitleUnfav.Size = UDim2.new(1, -5, 0, 25)
TitleUnfav.BackgroundTransparency = 1
TitleUnfav.Text = "🗑️ UNFAVORITE FILTER SETTINGS"
TitleUnfav.TextColor3 = Color3.fromRGB(255, 100, 100)
TitleUnfav.Font = Enum.Font.GothamBold
TitleUnfav.TextSize = 12
TitleUnfav.ZIndex = 13

CreateMultiSelectDropdown(FavoritePage, "Unfav Filter Rarity", rarityList, getgenv().UnfavRarities)
CreateMultiSelectDropdown(FavoritePage, "Unfav Filter Mutasi", mutationList, getgenv().UnfavMutations)

local UnfavFilterBtn = Instance.new("TextButton")
UnfavFilterBtn.Parent = FavoritePage
UnfavFilterBtn.Size = UDim2.new(1, -5, 0, 34)
UnfavFilterBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 30)
UnfavFilterBtn.Text = "🎯 UNFAVORITE BY FILTER"
UnfavFilterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnfavFilterBtn.Font = Enum.Font.GothamBold
UnfavFilterBtn.TextSize = 11
UnfavFilterBtn.ZIndex = 13
local ufc = Instance.new("UICorner")
ufc.CornerRadius = UDim.new(0, 6)
ufc.Parent = UnfavFilterBtn
UnfavFilterBtn.MouseButton1Click:Connect(function() UnfavoriteByFilter() end)

local UnfavBtn = Instance.new("TextButton")
UnfavBtn.Parent = FavoritePage
UnfavBtn.Size = UDim2.new(1, -5, 0, 34)
UnfavBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
UnfavBtn.Text = "🚨 UNFAVORITE ALL FISH"
UnfavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnfavBtn.Font = Enum.Font.GothamBold
UnfavBtn.TextSize = 11
UnfavBtn.ZIndex = 13
local uac = Instance.new("UICorner")
uac.CornerRadius = UDim.new(0, 6)
uac.Parent = UnfavBtn
UnfavBtn.MouseButton1Click:Connect(function() UnfavoriteAllFish() end)

----------------------------------------------------
-- 3. AUTO TRADE PAGE
----------------------------------------------------
local TradePage = pages["🤝 Auto Trade"]

local TitleTrade = Instance.new("TextLabel")
TitleTrade.Parent = TradePage
TitleTrade.Size = UDim2.new(1, -5, 0, 25)
TitleTrade.BackgroundTransparency = 1
TitleTrade.Text = "🤝 AUTO TRADE & MULTI-ACCOUNT"
TitleTrade.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleTrade.Font = Enum.Font.GothamBold
TitleTrade.TextSize = 12
TitleTrade.ZIndex = 13

local RefreshTradePlayersBtn = Instance.new("TextButton")
RefreshTradePlayersBtn.Parent = TradePage
RefreshTradePlayersBtn.Size = UDim2.new(1, -5, 0, 34)
RefreshTradePlayersBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
RefreshTradePlayersBtn.Text = "🔄 Refresh Player di Trade"
RefreshTradePlayersBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshTradePlayersBtn.Font = Enum.Font.GothamBold
RefreshTradePlayersBtn.TextSize = 11
RefreshTradePlayersBtn.ZIndex = 13
local rtpb = Instance.new("UICorner")
rtpb.CornerRadius = UDim.new(0, 6)
rtpb.Parent = RefreshTradePlayersBtn

local TradeTargetDropFrame = Instance.new("Frame")
TradeTargetDropFrame.Parent = TradePage
TradeTargetDropFrame.Size = UDim2.new(1, -5, 0, 36)
TradeTargetDropFrame.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
TradeTargetDropFrame.ClipsDescendants = true
TradeTargetDropFrame.ZIndex = 13
local ttdc = Instance.new("UICorner")
ttdc.CornerRadius = UDim.new(0, 6)
ttdc.Parent = TradeTargetDropFrame

local TradeTargetHeader = Instance.new("TextButton")
TradeTargetHeader.Parent = TradeTargetDropFrame
TradeTargetHeader.Size = UDim2.new(1, 0, 0, 36)
TradeTargetHeader.BackgroundTransparency = 1
TradeTargetHeader.Text = " 🎯 Target Trade: " .. (getgenv().TyoConfig.SelectedTradeTarget ~= "" and getgenv().TyoConfig.SelectedTradeTarget or "Pilih Player") .. " 🔽"
TradeTargetHeader.TextColor3 = Color3.fromRGB(210, 225, 240)
TradeTargetHeader.Font = Enum.Font.GothamMedium
TradeTargetHeader.TextSize = 11
TradeTargetHeader.TextXAlignment = Enum.TextXAlignment.Left
TradeTargetHeader.ZIndex = 14

local TradeTargetContainer = Instance.new("ScrollingFrame")
TradeTargetContainer.Parent = TradeTargetDropFrame
TradeTargetContainer.Position = UDim2.new(0, 5, 0, 36)
TradeTargetContainer.Size = UDim2.new(1, -10, 0, 110)
TradeTargetContainer.BackgroundTransparency = 1
TradeTargetContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TradeTargetContainer.ScrollBarThickness = 3
TradeTargetContainer.ZIndex = 14

local TradeListLayout = Instance.new("UIListLayout")
TradeListLayout.Parent = TradeTargetContainer
TradeListLayout.Padding = UDim.new(0, 4)
TradeListLayout.SortOrder = Enum.SortOrder.LayoutOrder

TradeListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	TradeTargetContainer.CanvasSize = UDim2.new(0, 0, 0, TradeListLayout.AbsoluteContentSize.Y + 10)
end)

local isTradeDropOpen = false
TradeTargetHeader.MouseButton1Click:Connect(function()
	isTradeDropOpen = not isTradeDropOpen
	TradeTargetDropFrame:TweenSize(isTradeDropOpen and UDim2.new(1, -5, 0, 150) or UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
end)

local function RefreshTradeTargets()
	for _, child in ipairs(TradeTargetContainer:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Parent = TradeTargetContainer
			btn.Size = UDim2.new(1, -5, 0, 28)
			btn.BackgroundColor3 = Color3.fromRGB(22, 29, 48)
			btn.Text = " 👤 " .. plr.Name
			btn.TextColor3 = Color3.fromRGB(160, 180, 210)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 11
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.ZIndex = 15
			local bc = Instance.new("UICorner")
			bc.CornerRadius = UDim.new(0, 4)
			bc.Parent = btn
			btn.MouseButton1Click:Connect(function()
				getgenv().TyoConfig.SelectedTradeTarget = plr.Name
				TradeTargetHeader.Text = " 🎯 Target Trade: " .. plr.Name .. " 🔽"
				isTradeDropOpen = false
				TradeTargetDropFrame:TweenSize(UDim2.new(1, -5, 0, 36), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
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
AddAllTradeBtn.Size = UDim2.new(1, -5, 0, 34)
AddAllTradeBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
AddAllTradeBtn.Text = "📦 Auto Add All Ikan ke Trade"
AddAllTradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddAllTradeBtn.Font = Enum.Font.GothamBold
AddAllTradeBtn.TextSize = 11
AddAllTradeBtn.ZIndex = 13
local aatc = Instance.new("UICorner")
aatc.CornerRadius = UDim.new(0, 6)
aatc.Parent = AddAllTradeBtn
AddAllTradeBtn.MouseButton1Click:Connect(function() AutoAddAllFishToTrade() end)

local SendTradeReqBtn = Instance.new("TextButton")
SendTradeReqBtn.Parent = TradePage
SendTradeReqBtn.Size = UDim2.new(1, -5, 0, 34)
SendTradeReqBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
SendTradeReqBtn.Text = "🚀 Kirim Request Trade ke Target"
SendTradeReqBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SendTradeReqBtn.Font = Enum.Font.GothamBold
SendTradeReqBtn.TextSize = 11
SendTradeReqBtn.ZIndex = 13
local strc = Instance.new("UICorner")
strc.CornerRadius = UDim.new(0, 6)
strc.Parent = SendTradeReqBtn
SendTradeReqBtn.MouseButton1Click:Connect(function() SendTradeRequestToTarget() end)

AddToggle(TradePage, "Auto Accept Trade (Terima Otomatis)", function(v) getgenv().AutoAcceptTradeRunning = v end)

----------------------------------------------------
-- 4. GALATAMA PAGE
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
TitleCoreEvent.Size = UDim2.new(1, -5, 0, 25)
TitleCoreEvent.BackgroundTransparency = 1
TitleCoreEvent.Text = "💎 AUTO DETECT WITHERING CORE EVENT"
TitleCoreEvent.TextColor3 = Color3.fromRGB(255, 200, 0)
TitleCoreEvent.Font = Enum.Font.GothamBold
TitleCoreEvent.TextSize = 12
TitleCoreEvent.ZIndex = 13

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
local TeleportShopPage = pages["Teleport Shop"]

local TitleShop = Instance.new("TextLabel")
TitleShop.Parent = TeleportShopPage
TitleShop.Size = UDim2.new(1, -5, 0, 25)
TitleShop.BackgroundTransparency = 1
TitleShop.Text = "🛒 TELEPORT TO SHOPS & NPCS"
TitleShop.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleShop.Font = Enum.Font.GothamBold
TitleShop.TextSize = 12
TitleShop.ZIndex = 13

local function AddShopTeleportBtn(parent, name, cf)
	local btn = Instance.new("TextButton")
	btn.Parent = parent
	btn.Size = UDim2.new(1, -5, 0, 34)
	btn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
	btn.Text = "📍 Teleport ke " .. name
	btn.TextColor3 = Color3.fromRGB(210, 225, 240)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 11
	btn.ZIndex = 13
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
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
-- 6. SUMMIT PAGE (FAST TP)
----------------------------------------------------
local SummitPage = pages["Summit"]

local TitleSum = Instance.new("TextLabel")
TitleSum.Parent = SummitPage
TitleSum.Size = UDim2.new(1, -5, 0, 25)
TitleSum.BackgroundTransparency = 1
TitleSum.Text = "⛰️ AUTO SUMMIT FARM (INSTANT FAST TP)"
TitleSum.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleSum.Font = Enum.Font.GothamBold
TitleSum.TextSize = 12
TitleSum.ZIndex = 13

getgenv().SummitDelay = 0.2
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

AddToggle(SummitPage, "Auto Summit Loop (Fast TP)", function(v)
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
	box.Size = UDim2.new(1, -5, 0, 36)
	box.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
	box.Text = tostring(default)
	box.TextColor3 = Color3.fromRGB(210, 225, 240)
	box.Font = Enum.Font.GothamMedium
	box.TextSize = 11
	box.ZIndex = 13
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 6)
	bc.Parent = box
	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then onChange(n) end
	end)
end

AddSummitBox("Tinggi di titik Tengah (Cth: 6)", 6, function(n) getgenv().SummitHeight = n end)
AddSummitBox("Tinggi di titik Cp (Cth: 1.5)", 1.5, function(n) getgenv().SummitCpHeight = n end)
AddToggle(SummitPage, "Pakai Remote Checkpoint (opsional)", function(v) getgenv().SummitUseRemote = v end)
AddSummitBox("Jeda Cepat di tiap Cp (detik, Cth: 0.2)", 0.2, function(n) getgenv().SummitDelay = math.max(n, 0) end)

local function TouchCheckpointFast(cpNumber, approxCF)
	local part 
	local waited = 0 
	
	pcall(function()
		LocalPlayer:RequestStreamAroundAsync(approxCF.Position, 5)
	end)
	while getgenv().AutoSummitRunning and waited < 1 do
		local folder = workspace:FindFirstChild("Checkpoint")
		part = folder and folder:FindFirstChild("Checkpoint " .. tostring(cpNumber))
		if part and part:IsA("BasePart") then break end
		part = nil
		task.wait(0.05)
		waited = waited + 0.05
	end
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not getgenv().AutoSummitRunning then return end
	if not part then
		hrp.CFrame = approxCF
		return
	end
	local standPos = part.Position + Vector3.new(0, (part.Size.Y / 2) + 2, 0)
	hrp.CFrame = CFrame.new(standPos)
	hrp.AssemblyLinearVelocity = Vector3.zero
	if firetouchinterest then
		pcall(function()
			firetouchinterest(hrp, part, 0)
			firetouchinterest(hrp, part, 1)
		end)
	end
end

task.spawn(function()
	while true do
		if getgenv().AutoSummitRunning then
			pcall(function()
				SetPlatformStand(true)
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
					
					hrp.AssemblyLinearVelocity = Vector3.zero
					hrp.AssemblyAngularVelocity = Vector3.zero
					
					hrp.CFrame = point[2] + Vector3.new(0, height, 0)
					
					if not getgenv().AutoSummitRunning then break end
					
					if cpIndex then
						TouchCheckpointFast(tonumber(cpIndex), point[2])
						
						local delayTime = tonumber(getgenv().SummitDelay) or 0.2
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
					else
						task.wait(0.05)
					end
				end
				
				local hrpFinal = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if hrpFinal and getgenv().AutoSummitRunning then
					hrpFinal.CFrame = CFrame.new(-6766.44629, 1320.69983, -10083.8037) + Vector3.new(0, 5, 0)
					task.wait(0.2)
					hrpFinal.CFrame = CFrame.new(-6834.84912, 1313.24744, -9902.42285) + Vector3.new(0, 5, 0)
				end
			end)
			task.wait(0.1)
		else
			SetPlatformStand(false)
			task.wait(0.3)
		end
	end
end)

----------------------------------------------------
-- 7. PLAYER PAGE (DENGAN TERBANG & LOMPAT JAUH)
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

AddToggle(PlayerPage, "🛫 Fitur Terbang (Fly)", function(v)
	getgenv().FlyRunning = v
	if v then StartFly() else StopFly() end
end)

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Parent = PlayerPage
FlySpeedBox.Size = UDim2.new(1, -5, 0, 36)
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
FlySpeedBox.PlaceholderText = "Kecepatan Terbang (Cth: 50)"
FlySpeedBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
FlySpeedBox.Text = "50"
FlySpeedBox.TextColor3 = Color3.fromRGB(210, 225, 240)
FlySpeedBox.Font = Enum.Font.GothamMedium
FlySpeedBox.TextSize = 11
FlySpeedBox.ZIndex = 13
local fsbc = Instance.new("UICorner")
fsbc.CornerRadius = UDim.new(0, 6)
fsbc.Parent = FlySpeedBox
FlySpeedBox.FocusLost:Connect(function()
	local n = tonumber(FlySpeedBox.Text)
	if n then getgenv().FlySpeed = n end
end)

AddToggle(PlayerPage, "🦘 Fitur Lompat Jauh (Long Jump)", function(v)
	getgenv().LongJumpRunning = v
end)

local JumpMultiplierBox = Instance.new("TextBox")
JumpMultiplierBox.Parent = PlayerPage
JumpMultiplierBox.Size = UDim2.new(1, -5, 0, 36)
JumpMultiplierBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
JumpMultiplierBox.PlaceholderText = "Kelipatan Lompat Jauh (Cth: 3)"
JumpMultiplierBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
JumpMultiplierBox.Text = "3"
JumpMultiplierBox.TextColor3 = Color3.fromRGB(210, 225, 240)
JumpMultiplierBox.Font = Enum.Font.GothamMedium
JumpMultiplierBox.TextSize = 11
JumpMultiplierBox.ZIndex = 13
local jmbc = Instance.new("UICorner")
jmbc.CornerRadius = UDim.new(0, 6)
jmbc.Parent = JumpMultiplierBox
JumpMultiplierBox.FocusLost:Connect(function()
	local n = tonumber(JumpMultiplierBox.Text)
	if n then getgenv().JumpPowerMultiplier = n end
end)

AddToggle(PlayerPage, "👻 Invisible Mode (Tak Terlihat Player Lain & Rod Hilang)", function(v)
	getgenv().InvisibleRunning = v
	pcall(function()
		local char = LocalPlayer.Character
		if not char then return end
		
		if v then
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(0, -9999, 0)
			end
			
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = 1
					part.CanCollide = false
				elseif part:IsA("Decal") then
					part.Transparency = 1
				end
			end
			
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			end
		else
			local hrp = char:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = FishingSpots["Spot Mancing Jembatan"] + Vector3.new(0, 5, 0)
			end
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					part.Transparency = 0
					part.CanCollide = true
				elseif part:IsA("Decal") then
					part.Transparency = 0
				end
			end
		end
	end)
end)

task.spawn(function()
	while true do
		if getgenv().InvisibleRunning then
			pcall(function()
				local char = LocalPlayer.Character
				if char then
					for _, tool in ipairs(char:GetChildren()) do
						if tool:IsA("Tool") then
							for _, p in ipairs(tool:GetDescendants()) do
								if p:IsA("BasePart") then
									p.Transparency = 1
									p.CanCollide = false
								end
							end
						end
					end
				end
			end)
		end
		task.wait(0.3)
	end
end)

AddToggle(PlayerPage, "🚀 Peningkatan Jaringan (Network Booster)", function(v)
	getgenv().NetworkBoostRunning = v
	task.spawn(function()
		while getgenv().NetworkBoostRunning do
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
			task.wait(2)
		end
	end)
end)

AddToggle(PlayerPage, "Anti-AFK", function(v) getgenv().AntiAFKRunning = v end)
LocalPlayer.Idled:Connect(function()
	if getgenv().AntiAFKRunning then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end
end)

local HeadlessBtn = Instance.new("TextButton")
HeadlessBtn.Parent = PlayerPage
HeadlessBtn.Size = UDim2.new(1, -5, 0, 34)
HeadlessBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
HeadlessBtn.Text = "👻 Enable Headless"
HeadlessBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
HeadlessBtn.Font = Enum.Font.GothamBold
HeadlessBtn.TextSize = 11
HeadlessBtn.ZIndex = 13
local hlc = Instance.new("UICorner")
hlc.CornerRadius = UDim.new(0, 6)
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
FireRgbBtn.Size = UDim2.new(1, -5, 0, 34)
FireRgbBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 220)
FireRgbBtn.Text = "🔥🌈 Auto RGB Fire: [OFF]"
FireRgbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FireRgbBtn.Font = Enum.Font.GothamBold
FireRgbBtn.TextSize = 11
FireRgbBtn.ZIndex = 13
local frc = Instance.new("UICorner")
frc.CornerRadius = UDim.new(0, 6)
frc.Parent = FireRgbBtn
local autoRgbActive = false
FireRgbBtn.MouseButton1Click:Connect(function()
	autoRgbActive = not autoRgbActive
	FireRgbBtn.Text = "🔥🌈 Auto RGB Fire: " .. (autoRgbActive and "[ON]" or "[OFF]")
	FireRgbBtn.BackgroundColor3 = autoRgbActive and Color3.fromRGB(80, 255, 200) or Color3.fromRGB(60, 120, 220)
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
	local colors = {Color3.fromRGB(80, 150, 255), Color3.fromRGB(80, 255, 200), Color3.fromRGB(150, 100, 255), Color3.fromRGB(255, 255, 255)}
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
local HaloPage = pages["Halo Kepala"]

local TitleHalo = Instance.new("TextLabel")
TitleHalo.Parent = HaloPage
TitleHalo.Size = UDim2.new(1, -5, 0, 25)
TitleHalo.BackgroundTransparency = 1
TitleHalo.Text = "👑 HALO & AKSESORIS KEPALA"
TitleHalo.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleHalo.Font = Enum.Font.GothamBold
TitleHalo.TextSize = 12
TitleHalo.ZIndex = 13

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
		clearHaloBtn.Size = UDim2.new(1, -5, 0, 34)
		clearHaloBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
		clearHaloBtn.Text = "❌ Lepas Aksesoris Kepala"
		clearHaloBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		clearHaloBtn.Font = Enum.Font.GothamBold
		clearHaloBtn.TextSize = 11
		clearHaloBtn.ZIndex = 13
		local chc = Instance.new("UICorner")
		chc.CornerRadius = UDim.new(0, 6)
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
			haloBtn.Size = UDim2.new(1, -5, 0, 34)
			haloBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
			haloBtn.Text = "👑 " .. name
			haloBtn.TextColor3 = Color3.fromRGB(210, 225, 240)
			haloBtn.Font = Enum.Font.GothamMedium
			haloBtn.TextSize = 11
			haloBtn.ZIndex = 13
			local hbc = Instance.new("UICorner")
			hbc.CornerRadius = UDim.new(0, 6)
			hbc.Parent = haloBtn
			haloBtn.MouseButton1Click:Connect(function() ApplyHaloToCharacter(name) end)
		end
	end
end)

----------------------------------------------------
-- 9. TELEPORT PLAYER PAGE
----------------------------------------------------
local PlayerTpPage = pages["Teleport Player"]

local TitleTpPly = Instance.new("TextLabel")
TitleTpPly.Parent = PlayerTpPage
TitleTpPly.Size = UDim2.new(1, -5, 0, 25)
TitleTpPly.BackgroundTransparency = 1
TitleTpPly.Text = "👥 TELEPORT TO OTHER PLAYERS"
TitleTpPly.TextColor3 = Color3.fromRGB(80, 150, 255)
TitleTpPly.Font = Enum.Font.GothamBold
TitleTpPly.TextSize = 12
TitleTpPly.ZIndex = 13

local RefreshPlayerBtn = Instance.new("TextButton")
RefreshPlayerBtn.Parent = PlayerTpPage
RefreshPlayerBtn.Size = UDim2.new(1, -5, 0, 34)
RefreshPlayerBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
RefreshPlayerBtn.Text = "🔄 Refresh / Scan Pemain"
RefreshPlayerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshPlayerBtn.Font = Enum.Font.GothamBold
RefreshPlayerBtn.TextSize = 11
RefreshPlayerBtn.ZIndex = 13
local rpc = Instance.new("UICorner")
rpc.CornerRadius = UDim.new(0, 6)
rpc.Parent = RefreshPlayerBtn

local PlayerListContainer = Instance.new("ScrollingFrame")
PlayerListContainer.Parent = PlayerTpPage
PlayerListContainer.Size = UDim2.new(1, -5, 0, 210)
PlayerListContainer.BackgroundTransparency = 1
PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListContainer.ScrollBarThickness = 3
PlayerListContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 150, 255)
PlayerListContainer.ZIndex = 13

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = PlayerListContainer
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 4)

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	PlayerListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
end)

local function GetCharacterRootPart(char)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") 
		or char:FindFirstChild("Torso") 
		or char:FindFirstChild("UpperTorso") 
		or char:FindFirstChild("Head")
end

local function ScanAndDisplayPlayers()
	for _, child in ipairs(PlayerListContainer:GetChildren()) do if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			local card = Instance.new("Frame")
			card.Parent = PlayerListContainer
			card.Size = UDim2.new(1, -5, 0, 34)
			card.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
			card.ZIndex = 14
			
			local cc = Instance.new("UICorner")
			cc.CornerRadius = UDim.new(0, 6)
			cc.Parent = card
			
			local pName = Instance.new("TextLabel")
			pName.Parent = card
			pName.Position = UDim2.new(0, 10, 0, 0)
			pName.Size = UDim2.new(0.65, 0, 1, 0)
			pName.BackgroundTransparency = 1
			pName.Text = "👤 " .. plr.Name
			pName.TextColor3 = Color3.fromRGB(210, 225, 240)
			pName.Font = Enum.Font.GothamMedium
			pName.TextSize = 11
			pName.TextXAlignment = Enum.TextXAlignment.Left
			pName.ZIndex = 15
			
			local tpBtn = Instance.new("TextButton")
			tpBtn.Parent = card
			tpBtn.Position = UDim2.new(1, -70, 0.5, -11)
			tpBtn.Size = UDim2.new(0, 60, 0, 22)
			tpBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
			tpBtn.Text = "Teleport"
			tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			tpBtn.Font = Enum.Font.GothamBold
			tpBtn.TextSize = 10
			tpBtn.ZIndex = 15
			
			local tpc = Instance.new("UICorner")
			tpc.CornerRadius = UDim.new(0, 4)
			tpc.Parent = tpBtn
			
			tpBtn.MouseButton1Click:Connect(function()
				task.spawn(function()
					pcall(function()
						local targetChar = plr.Character
						local targetPart = GetCharacterRootPart(targetChar)
						local myChar = LocalPlayer.Character
						local myPart = GetCharacterRootPart(myChar)
						
						if targetPart and myPart then
							pcall(function()
								LocalPlayer:RequestStreamAroundAsync(targetPart.Position, 10)
							end)
							task.wait(0.2)
							
							if myPart:IsA("BasePart") then
								myPart.Anchored = false
								myPart.AssemblyLinearVelocity = Vector3.zero
								myPart.AssemblyAngularVelocity = Vector3.zero
							end
							
							local targetCFrame = targetPart.CFrame * CFrame.new(0, 3, 2)
							for i = 1, 5 do
								if myChar and myPart and targetPart.Parent then
									myPart.CFrame = targetCFrame
								end
								task.wait(0.05)
							end
							
							tpBtn.Text = "Berhasil!"
							task.wait(1)
							tpBtn.Text = "Teleport"
						else
							tpBtn.Text = "Gagal!"
							task.wait(1)
							tpBtn.Text = "Teleport"
						end
					end)
				end)
			end)
		end
	end
end

RefreshPlayerBtn.MouseButton1Click:Connect(ScanAndDisplayPlayers)
task.spawn(function() task.wait(2); ScanAndDisplayPlayers() end)

Players.PlayerAdded:Connect(ScanAndDisplayPlayers)
Players.PlayerRemoving:Connect(ScanAndDisplayPlayers)

----------------------------------------------------
-- 10. PRIVACY PAGE
----------------------------------------------------
local PrivacyPage = pages["Privacy"]

local TitlePrv = Instance.new("TextLabel")
TitlePrv.Parent = PrivacyPage
TitlePrv.Size = UDim2.new(1, -5, 0, 25)
TitlePrv.BackgroundTransparency = 1
TitlePrv.Text = "🛡️ PRIVACY & ANTI-ADMIN"
TitlePrv.TextColor3 = Color3.fromRGB(80, 150, 255)
TitlePrv.Font = Enum.Font.GothamBold
TitlePrv.TextSize = 12
TitlePrv.ZIndex = 13

local FakeNameBox = Instance.new("TextBox")
FakeNameBox.Parent = PrivacyPage
FakeNameBox.Size = UDim2.new(1, -5, 0, 36)
FakeNameBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
FakeNameBox.PlaceholderText = "Nama Samaran (Cth: AEMEATH HUB)"
FakeNameBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
FakeNameBox.Text = "AEMEATH HUB"
FakeNameBox.TextColor3 = Color3.fromRGB(210, 225, 240)
FakeNameBox.Font = Enum.Font.GothamMedium
FakeNameBox.TextSize = 11
FakeNameBox.ZIndex = 13
local fnc = Instance.new("UICorner")
fnc.CornerRadius = UDim.new(0, 6)
fnc.Parent = FakeNameBox
FakeNameBox.FocusLost:Connect(function() getgenv().FakeNameInput = FakeNameBox.Text end)

AddToggle(PrivacyPage, "Privacy Mode (Hide Name)", function(v)
	getgenv().HideNameRunning = v
	if v then
		task.spawn(function()
			while getgenv().HideNameRunning do
				pcall(function()
					local fakeName = getgenv().FakeNameInput or "AEMEATH HUB"
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
AntiAdminToggleBtn.Size = UDim2.new(1, -5, 0, 36)
AntiAdminToggleBtn.BackgroundColor3 = getgenv().TyoConfig.AntiAdminEnabled and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(18, 24, 38)
AntiAdminToggleBtn.Text = " Anti-Admin Protect (MPG Group): " .. (getgenv().TyoConfig.AntiAdminEnabled and "[ON]" or "[OFF]")
AntiAdminToggleBtn.TextColor3 = Color3.fromRGB(210, 225, 240)
AntiAdminToggleBtn.Font = Enum.Font.GothamMedium
AntiAdminToggleBtn.TextSize = 11
AntiAdminToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
AntiAdminToggleBtn.ZIndex = 13
local aac = Instance.new("UICorner")
aac.CornerRadius = UDim.new(0, 6)
aac.Parent = AntiAdminToggleBtn
AntiAdminToggleBtn.MouseButton1Click:Connect(function()
	getgenv().TyoConfig.AntiAdminEnabled = not getgenv().TyoConfig.AntiAdminEnabled
	local active = getgenv().TyoConfig.AntiAdminEnabled
	AntiAdminToggleBtn.Text = " Anti-Admin Protect (MPG Group): " .. (active and "[ON]" or "[OFF]")
	AntiAdminToggleBtn.BackgroundColor3 = active and Color3.fromRGB(180, 50, 50) or Color3.fromRGB(18, 24, 38)
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
-- 11. SETTINGS & PERFORMANCE PAGE
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

AddToggle(SettingsPage, "Auto Save Config", function(v)
	getgenv().TyoConfig.AutoSaveEnabled = v
	if v then SaveConfig() end
end, getgenv().TyoConfig.AutoSaveEnabled)

AddToggle(SettingsPage, "Auto Load Config saat Start", function(v)
	getgenv().TyoConfig.AutoLoadEnabled = v
	SaveConfig()
end, getgenv().TyoConfig.AutoLoadEnabled)

local AntiLagBtn = Instance.new("TextButton")
AntiLagBtn.Parent = SettingsPage
AntiLagBtn.Size = UDim2.new(1, -5, 0, 34)
AntiLagBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 200)
AntiLagBtn.Text = "⚡ EXTREME POTATO: Hapus Tembok & Min Render"
AntiLagBtn.TextColor3 = Color3.fromRGB(12, 16, 26)
AntiLagBtn.Font = Enum.Font.GothamBold
AntiLagBtn.TextSize = 11
AntiLagBtn.ZIndex = 13
local alc = Instance.new("UICorner")
alc.CornerRadius = UDim.new(0, 6)
alc.Parent = AntiLagBtn

local function ApplyExtremePotatoAndNoWalls()
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
end

AntiLagBtn.MouseButton1Click:Connect(function()
	ApplyExtremePotatoAndNoWalls()
	AntiLagBtn.Text = "⚡ Tembok Dihapus & Render Diminimalkan!"
	AntiLagBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
	AntiLagBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end)

local BlackScreenGui = nil
local BlackScreenToggleBtn = Instance.new("TextButton")
BlackScreenToggleBtn.Parent = SettingsPage
BlackScreenToggleBtn.Size = UDim2.new(1, -5, 0, 36)
BlackScreenToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
BlackScreenToggleBtn.Text = " 📱 Black Screen (Battery Saver): [OFF]"
BlackScreenToggleBtn.TextColor3 = Color3.fromRGB(210, 225, 240)
BlackScreenToggleBtn.Font = Enum.Font.GothamMedium
BlackScreenToggleBtn.TextSize = 11
BlackScreenToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
BlackScreenToggleBtn.ZIndex = 13
local bsc = Instance.new("UICorner")
bsc.CornerRadius = UDim.new(0, 6)
bsc.Parent = BlackScreenToggleBtn
local isBlackScreen = false

BlackScreenToggleBtn.MouseButton1Click:Connect(function()
	isBlackScreen = not isBlackScreen
	BlackScreenToggleBtn.Text = " 📱 Black Screen (Battery Saver): " .. (isBlackScreen and "[ON]" or "[OFF]")
	BlackScreenToggleBtn.BackgroundColor3 = isBlackScreen and Color3.fromRGB(80, 150, 255) or Color3.fromRGB(18, 24, 38)
	
	if isBlackScreen then
		if not BlackScreenGui then
			BlackScreenGui = Instance.new("ScreenGui")
			BlackScreenGui.Name = "AemeathBlackScreen"
			BlackScreenGui.Parent = PlayerGui
			BlackScreenGui.DisplayOrder = 2147483647
			BlackScreenGui.IgnoreGuiInset = true
			
			local frame = Instance.new("Frame")
			frame.Parent = BlackScreenGui
			frame.Size = UDim2.new(1, 0, 1, 0)
			frame.BackgroundColor3 = Color3.fromRGB(6, 9, 15)
			
			local txt = Instance.new("TextLabel")
			txt.Parent = frame
			txt.Size = UDim2.new(1, 0, 0, 60)
			txt.Position = UDim2.new(0, 0, 0.45, 0)
			txt.BackgroundTransparency = 1
			txt.Text = "🌙 AEMEATH WUTHERING WAVES HUB V3 - BATTERY SAVER ACTIVE\n(Sentuh Layar Untuk Kembali)"
			txt.TextColor3 = Color3.fromRGB(80, 150, 255)
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 12
			
			frame.InputBegan:Connect(function()
				isBlackScreen = false
				BlackScreenToggleBtn.Text = " 📱 Black Screen (Battery Saver): [OFF]"
				BlackScreenToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
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
WebhookToggleBtn.Size = UDim2.new(1, -5, 0, 36)
WebhookToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
WebhookToggleBtn.Text = " Webhook Server-Wide (Rare & Core): " .. (getgenv().TyoConfig.WebhookEnabled and "[ON]" or "[OFF]")
WebhookToggleBtn.TextColor3 = Color3.fromRGB(210, 225, 240)
WebhookToggleBtn.Font = Enum.Font.GothamMedium
WebhookToggleBtn.TextSize = 11
WebhookToggleBtn.TextXAlignment = Enum.TextXAlignment.Left
WebhookToggleBtn.ZIndex = 13
local wtc = Instance.new("UICorner")
wtc.CornerRadius = UDim.new(0, 6)
wtc.Parent = WebhookToggleBtn
WebhookToggleBtn.MouseButton1Click:Connect(function()
	getgenv().TyoConfig.WebhookEnabled = not getgenv().TyoConfig.WebhookEnabled
	WebhookToggleBtn.Text = " Webhook Server-Wide (Rare & Core): " .. (getgenv().TyoConfig.WebhookEnabled and "[ON]" or "[OFF]")
	WebhookToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
	SaveConfig()
end)

local WebhookBox = Instance.new("TextBox")
WebhookBox.Parent = SettingsPage
WebhookBox.Size = UDim2.new(1, -5, 0, 36)
WebhookBox.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
WebhookBox.PlaceholderText = "Paste Discord Webhook URL di sini..."
WebhookBox.PlaceholderColor3 = Color3.fromRGB(90, 110, 140)
WebhookBox.Text = tostring(getgenv().TyoConfig.WebhookUrl or "")
WebhookBox.TextColor3 = Color3.fromRGB(210, 225, 240)
WebhookBox.Font = Enum.Font.GothamMedium
WebhookBox.TextSize = 11
WebhookBox.ZIndex = 13
local wbc = Instance.new("UICorner")
wbc.CornerRadius = UDim.new(0, 6)
wbc.Parent = WebhookBox
WebhookBox.FocusLost:Connect(function()
	getgenv().TyoConfig.WebhookUrl = WebhookBox.Text
	SaveConfig()
end)

local TestWebhookBtn = Instance.new("TextButton")
TestWebhookBtn.Parent = SettingsPage
TestWebhookBtn.Size = UDim2.new(1, -5, 0, 34)
TestWebhookBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
TestWebhookBtn.Text = "🧪 Test Kirim Webhook ke Discord"
TestWebhookBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestWebhookBtn.Font = Enum.Font.GothamBold
TestWebhookBtn.TextSize = 11
TestWebhookBtn.ZIndex = 13
local twc = Instance.new("UICorner")
twc.CornerRadius = UDim.new(0, 6)
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
					["content"] = "✅ **Aemeath Wuthering Waves Hub V3 Mount Soreya Webhook Test Berhasil!**"
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
SaveConfigBtn.Size = UDim2.new(1, -5, 0, 34)
SaveConfigBtn.BackgroundColor3 = Color3.fromRGB(80, 255, 200)
SaveConfigBtn.Text = "💾 Simpan Konfigurasi (Manual Save)"
SaveConfigBtn.TextColor3 = Color3.fromRGB(12, 16, 26)
SaveConfigBtn.Font = Enum.Font.GothamBold
SaveConfigBtn.TextSize = 11
SaveConfigBtn.ZIndex = 13
local scc = Instance.new("UICorner")
scc.CornerRadius = UDim.new(0, 6)
scc.Parent = SaveConfigBtn
SaveConfigBtn.MouseButton1Click:Connect(function()
	SaveConfig()
	SaveConfigBtn.Text = "✅ Config Berhasil Disimpan!"
	task.wait(1.5)
	SaveConfigBtn.Text = "💾 Simpan Konfigurasi (Manual Save)"
end)

local LoadConfigBtn = Instance.new("TextButton")
LoadConfigBtn.Parent = SettingsPage
LoadConfigBtn.Size = UDim2.new(1, -5, 0, 34)
LoadConfigBtn.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
LoadConfigBtn.Text = "📂 Muat Konfigurasi (Manual Load)"
LoadConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadConfigBtn.Font = Enum.Font.GothamBold
LoadConfigBtn.TextSize = 11
LoadConfigBtn.ZIndex = 13
local lcc = Instance.new("UICorner")
lcc.CornerRadius = UDim.new(0, 6)
lcc.Parent = LoadConfigBtn
LoadConfigBtn.MouseButton1Click:Connect(function()
	LoadConfig()
	LoadConfigBtn.Text = "✅ Config Berhasil Dimuat!"
	task.wait(1.5)
	LoadConfigBtn.Text = "📂 Muat Konfigurasi (Manual Load)"
end)

local ResetConfigBtn = Instance.new("TextButton")
ResetConfigBtn.Parent = SettingsPage
ResetConfigBtn.Size = UDim2.new(1, -5, 0, 34)
ResetConfigBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70)
ResetConfigBtn.Text = "🔄 Reset Konfigurasi"
ResetConfigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetConfigBtn.Font = Enum.Font.GothamBold
ResetConfigBtn.TextSize = 11
ResetConfigBtn.ZIndex = 13
local rcc = Instance.new("UICorner")
rcc.CornerRadius = UDim.new(0, 6)
rcc.Parent = ResetConfigBtn
ResetConfigBtn.MouseButton1Click:Connect(function()
	ResetConfig()
	ResetConfigBtn.Text = "🔄 Config Direset!"
	task.wait(1.5)
	ResetConfigBtn.Text = "🔄 Reset Konfigurasi"
end)

----------------------------------------------------
-- 12. CREDITS PAGE
----------------------------------------------------
local CreditsPage = pages["Credits"]
local CredLbl = Instance.new("TextLabel")
CredLbl.Parent = CreditsPage
CredLbl.Size = UDim2.new(1, -5, 1, 0)
CredLbl.BackgroundTransparency = 1
CredLbl.Text = "Aemeath Wuthering Waves Edition\nMap: Mount Soreya\nModern UI Redesign"
CredLbl.TextColor3 = Color3.fromRGB(210, 225, 240)
CredLbl.Font = Enum.Font.GothamBold
CredLbl.TextSize = 14
CredLbl.ZIndex = 13

----------------------------------------------------
-- BOTTOM PANEL: SESSION STAT TRACKER (LIVE)
----------------------------------------------------
local StatPanel = Instance.new("Frame")
StatPanel.Parent = Main
StatPanel.Size = UDim2.new(1, -158, 0, 24)
StatPanel.Position = UDim2.new(0, 150, 1, -26)
StatPanel.BackgroundColor3 = Color3.fromRGB(16, 21, 35)
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

----------------------------------------------------
-- FLOATING BUTTON
----------------------------------------------------
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
	if isFloatClick() then
		Main.Visible = not Main.Visible
	end
end)

print("Aemeath Wuthering Waves Hub V3 Loaded Successfully with Fly, Long Jump, Fast Summit & Auto Save/Load!")
