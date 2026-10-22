-- ==============================================================================
-- TYO HUB V3 | UNIVERSAL MULTI-DEVICE & NO-KEY SYSTEM
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
-- DETEKSI PERANGKAT (MULTI-DEVICE MONITOR)
------------------------------------------------------------------
local isTouch = UIS.TouchEnabled and not UIS.KeyboardEnabled
getgenv().TyoDeviceType = isTouch and "Mobile / Cloud Phone" or "PC"

------------------------------------------------------------------
-- STAT TRACKER GLOBAL VARIABLES
------------------------------------------------------------------
getgenv().TotalFishCaught = 0
getgenv().SessionStartTime = os.time()

------------------------------------------------------------------
-- CONFIGURATION & FILE SAVE SYSTEM (SAFE FOR MULTI-ACCOUNT)
------------------------------------------------------------------
-- Memisahkan file config per UserId agar tidak bentrok antar device/akun
local SAFE_NAME = tostring(LocalPlayer.UserId or LocalPlayer.Name)
local CONFIG_FILE = "TyoHub_Config_" .. SAFE_NAME .. ".json"

getgenv().TyoConfig = {
	BiteDelay = "0.5",
	TapDelay = "0.12",
	MinigameMode = "Legit", -- "Legit" / "Instant"
	SelectedSpot = "Spot Mancing Jembatan",
	AutoSellTimer = "5",
	AntiAdminEnabled = false,
	TargetGroupId = 7019573,
	WebhookEnabled = false,
	WebhookUrl = ""
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
			WebhookUrl = ""
		}
		if delfile and isfile then
			if isfile(CONFIG_FILE) then delfile(CONFIG_FILE) end
		end
	end)
end
LoadConfig()

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
		
		if string.find(typeLower, "secret") or string.find(typeLower, "forgotten") or string.find(typeLower, "core") or string.find(typeLower, "catch") then
			local requestFunc = (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request)
			if not requestFunc then return end
			
			local embedTitle = "👑 Tyo Hub - Server Rare Catch Tracker!"
			local alertContent = string.format("@everyone 🚨 **%s Berhasil Mendapatkan Tangkapan Langka!**", targetPlayer)
			local embedColor = 16711935
			
			if string.find(typeLower, "core") then
				alertContent = string.format("@everyone ⚡ **%s Mendapatkan Withering Core!**", targetPlayer)
				embedTitle = "💎 Tyo Hub - Core Event Tracker!"
				embedColor = 16776960
			end
			
			local posStr = position and string.format("%.1f, %.1f, %.1f", position.X, position.Y, position.Z) or "N/A"
			
			local data = {
				["content"] = alertContent,
				["embeds"] = {
					{
						["title"] = embedTitle,
						["description"] = string.format("Pemain **%s** di dalam server ini baru saja mendapatkan item spesial!", targetPlayer),
						["color"] = embedColor,
						["fields"] = {
							{ ["name"] = "👤 Nama Player", ["value"] = targetPlayer, ["inline"] = true },
							{ ["name"] = "🎯 Tipe Tangkapan", ["value"] = tostring(catchType), ["inline"] = true },
							{ ["name"] = "📍 Koordinat", ["value"] = posStr, ["inline"] = true }
						},
						["footer"] = { ["text"] = "Tyo Hub • Multi-Device Monitor" },
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
	if isTouch then
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
-- MAIN HUB UI (TYO HUB - NO KEY)
----------------------------------------------------
local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Visible = true -- Langsung Terbuka Tanpa Key
Main.Size = UDim2.new(0,550,0,320)
Main.Position = UDim2.new(0.5,-275,0.5,-160)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.ClipsDescendants = true
MakeDraggable(Main)

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,18)
mainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(0,170,255)

local ControlsFrame = Instance.new("Frame")
ControlsFrame.Parent = Main
ControlsFrame.Size = UDim2.new(0, 65, 0, 30)
ControlsFrame.Position = UDim2.new(1, -70, 0, 5)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.ZIndex = 10

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Parent = ControlsFrame
MinimizeBtn.Size = UDim2.new(0, 26, 0, 26)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = ControlsFrame
CloseBtn.Position = UDim2.new(0, 32, 0, 0)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Parent = Main
Sidebar.Size = UDim2.new(0,140,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,20)
Sidebar.CanvasSize = UDim2.new(0,0,2.6,0)
Sidebar.ScrollBarThickness = 2

local HubTitle = Instance.new("TextLabel")
HubTitle.Parent = Sidebar
HubTitle.BackgroundTransparency = 1
HubTitle.Position = UDim2.new(0, 0, 0, 8)
HubTitle.Size = UDim2.new(1, 0, 0, 22)
HubTitle.Text = "TYO HUB"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
HubTitle.TextSize = 17

local HubSubTitle = Instance.new("TextLabel")
HubSubTitle.Parent = Sidebar
HubSubTitle.BackgroundTransparency = 1
HubSubTitle.Position = UDim2.new(0, 0, 0, 32)
HubSubTitle.Size = UDim2.new(1, 0, 0, 18)
HubSubTitle.Text = "🔥 No Key • Multi-Device"
HubSubTitle.Font = Enum.Font.GothamBold
HubSubTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
HubSubTitle.TextSize = 10

local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.new(0,150,0,30)
Content.Size = UDim2.new(1,-160,1,-40)
Content.BackgroundTransparency = 1

local isMinimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	MinimizeBtn.Text = isMinimized and "+" or "-"
	Main:TweenSize(isMinimized and UDim2.new(0,550,0,38) or UDim2.new(0,550,0,320), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
	Sidebar.Visible = not isMinimized
	Content.Visible = not isMinimized
end)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

local function CreateNavButton(text, yPos)
	local btn = Instance.new("TextButton")
	btn.Parent = Sidebar
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.Size = UDim2.new(1, -20, 0, 28)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	local corner = Instance.new("UICorner")
	corner.Parent = btn
	return btn
end

local HomeBtn = CreateNavButton("Fishing & Sell", 60)
local PlayerMenuBtn = CreateNavButton("Player", 95)
local SettingsBtn = CreateNavButton("Settings", 130)

local function MakePage()
	local f = Instance.new("ScrollingFrame")
	f.Parent = Content
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.CanvasSize = UDim2.new(0,0,3,0)
	f.ScrollBarThickness = 4
	local pad = Instance.new("UIPadding")
	pad.Parent = f
	pad.PaddingTop = UDim.new(0, 10)
	local l = Instance.new("UIListLayout")
	l.Parent = f
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 8)
	return f
end

local FishingPage = MakePage(); FishingPage.Visible = true
local PlayerPage = MakePage()
local SettingsPage = MakePage()

HomeBtn.MouseButton1Click:Connect(function() FishingPage.Visible = true; PlayerPage.Visible = false; SettingsPage.Visible = false end)
PlayerMenuBtn.MouseButton1Click:Connect(function() FishingPage.Visible = false; PlayerPage.Visible = true; SettingsPage.Visible = false end)
SettingsBtn.MouseButton1Click:Connect(function() FishingPage.Visible = false; PlayerPage.Visible = false; SettingsPage.Visible = true end)

local function AddToggle(parent, text, callback)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1,0,0,35)
	b.BackgroundColor3 = Color3.fromRGB(30,30,40)
	b.Text = " " .. text .. " [OFF]"
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 13
	b.TextXAlignment = Enum.TextXAlignment.Left
	local c = Instance.new("UICorner")
	c.Parent = b
	local state = false
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = " " .. text .. (state and " [ON]" or " [OFF]")
		b.BackgroundColor3 = state and Color3.fromRGB(0,100,180) or Color3.fromRGB(30,30,40)
		callback(state)
	end)
end

----------------------------------------------------
-- PAGES CONTENT
----------------------------------------------------
AddToggle(FishingPage, "Smart Auto Fishing", function(v)
	getgenv().AutoFishingEventRunning = v
	if v then StartFishingLoop() end
end)

AddToggle(PlayerPage, "Anti-AFK Protect", function(v) getgenv().AntiAFKRunning = v end)
LocalPlayer.Idled:Connect(function()
	if getgenv().AntiAFKRunning then VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end
end)

----------------------------------------------------
-- FLOATING BUTTON TOGGLE
----------------------------------------------------
local Float = Instance.new("ImageButton")
Float.Parent = Gui
Float.Size = UDim2.new(0,55,0,55)
Float.Position = UDim2.new(0,20,0,120)
Float.Image = "rbxassetid://90770802417381"
Float.BackgroundColor3 = Color3.fromRGB(20,20,25)
local flCorner = Instance.new("UICorner") flCorner.CornerRadius = UDim.new(1,0) flCorner.Parent = Float
MakeDraggable(Float)

Float.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)
