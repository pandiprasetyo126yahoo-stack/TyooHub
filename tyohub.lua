‎-- ==============================================================================
‎-- TYO HUB V3 (AEMEATH WUTHERING WAVES EDITION) | NO-KEY & MULTI-DEVICE
‎-- MAP: MOUNT SOREYA UPDATE (EXTREME POTATO & MINIMAL RENDER DISTANCE)
‎-- ==============================================================================
‎local HttpService = game:GetService("HttpService")
‎local Players = game:GetService("Players")
‎local ReplicatedStorage = game:GetService("ReplicatedStorage")
‎local VirtualUser = game:GetService("VirtualUser")
‎local VirtualInputManager = game:GetService("VirtualInputManager")
‎local CoreGui = game:GetService("CoreGui")
‎local UIS = game:GetService("UserInputService")
‎local TeleportService = game:GetService("TeleportService")
‎local Stats = game:GetService("Stats")
‎local Lighting = game:GetService("Lighting")
‎local Workspace = game:GetService("Workspace")
‎local LocalPlayer = Players.LocalPlayer
‎local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
‎
‎------------------------------------------------------------------
‎-- STAT TRACKER GLOBAL VARIABLES
‎------------------------------------------------------------------
‎getgenv().TotalFishCaught = 0
‎getgenv().SessionStartTime = os.time()
‎
‎------------------------------------------------------------------
‎-- CONFIGURATION & FILE SAVE SYSTEM (AUTO SAVE & AUTO LOAD FIXED)
‎------------------------------------------------------------------
‎local SAFE_NAME = tostring(LocalPlayer.UserId or LocalPlayer.Name)
‎local CONFIG_FILE = "AemeathHubV3_Config_" .. SAFE_NAME .. ".json"
‎
‎getgenv().TyoConfig = {
‎BiteDelay = "0.5",
‎TapDelay = "0.12",
‎MinigameMode = "Legit",
‎SelectedSpot = "Spot Mancing Jembatan",
‎AutoSellTimer = "5",
‎AntiAdminEnabled = false,
‎TargetGroupId = 7019573,
‎WebhookEnabled = false,
‎WebhookUrl = "",
‎SelectedTradeTarget = "",
‎AutoSaveEnabled = true,
‎AutoLoadEnabled = true
‎}
‎
‎local function SaveConfig()
‎pcall(function()
‎if writefile and getgenv().TyoConfig.AutoSaveEnabled then
‎getgenv().TyoConfig.SelectedSpot = getgenv().SelectedFishingSpot or getgenv().TyoConfig.SelectedSpot
‎local data = HttpService:JSONEncode(getgenv().TyoConfig)
‎writefile(CONFIG_FILE, data)
‎end
‎end)
‎end
‎
‎local function LoadConfig()
‎pcall(function()
‎if readfile and isfile and isfile(CONFIG_FILE) then
‎local content = readfile(CONFIG_FILE)
‎local success, data = pcall(function() return HttpService:JSONDecode(content) end)
‎if success and type(data) == "table" then
‎for k, v in pairs(data) do
‎if getgenv().TyoConfig[k] ~= nil then
‎getgenv().TyoConfig[k] = v
‎end
‎end
‎if getgenv().TyoConfig.SelectedSpot then
‎getgenv().SelectedFishingSpot = getgenv().TyoConfig.SelectedSpot
‎end
‎end
‎end
‎end)
‎end
‎
‎-- Jalankan Auto Load saat script pertama kali dieksekusi jika diaktifkan
‎if getgenv().TyoConfig.AutoLoadEnabled then
‎LoadConfig()
‎end
‎
‎-- Sistem Auto Save Berkala (Setiap 30 detik jika ada perubahan)
‎task.spawn(function()
‎while true do
‎task.wait(30)
‎if getgenv().TyoConfig.AutoSaveEnabled then
‎SaveConfig()
‎end
‎end
‎end)
‎
‎local function ResetConfig()
‎pcall(function()
‎getgenv().TyoConfig = {
‎BiteDelay = "0.5",
‎TapDelay = "0.12",
‎MinigameMode = "Legit",
‎SelectedSpot = "Spot Mancing Jembatan",
‎AutoSellTimer = "5",
‎AntiAdminEnabled = false,
‎TargetGroupId = 7019573,
‎WebhookEnabled = false,
‎WebhookUrl = "",
‎SelectedTradeTarget = "",
‎AutoSaveEnabled = true,
‎AutoLoadEnabled = true
‎}
‎getgenv().SelectedFishingSpot = "Spot Mancing Jembatan"
‎if delfile and isfile and isfile(CONFIG_FILE) then
‎delfile(CONFIG_FILE)
‎end
‎end)
‎end
‎
‎------------------------------------------------------------------
‎-- DISCORD WEBHOOK SYSTEM (SERVER-WIDE CUTSCENE BROADCAST)
‎------------------------------------------------------------------
‎local function SendServerWideWebhook(playerName, catchType, position)
‎pcall(function()
‎if not getgenv().TyoConfig.WebhookEnabled then return end
‎local url = getgenv().TyoConfig.WebhookUrl
‎if not url or url == "" or not string.find(url, "api/webhooks") then return end
‎
‎local typeLower = string.lower(tostring(catchType))
‎local targetPlayer = tostring(playerName or "Unknown Player")
‎
‎if string.find(typeLower, "secret") or string.find(typeLower, "forgotten") or string.find(typeLower, "core") or string.find(typeLower, "catch") or string.find(typeLower, "aether") then
‎local requestFunc = (syn and syn.request) or (http and http.request) or request or (fluxus and fluxus.request)
‎if not requestFunc then return end
‎
‎local embedTitle = "👑 Aemeath Wuthering Waves Hub V3 - Mount Soreya Rare Catch Tracker!"
‎local alertContent = string.format("@everyone 🚨 **%s Berhasil Mendapatkan Tangkapan Langka!**", targetPlayer)
‎local embedColor = 10040319
‎
‎if string.find(typeLower, "core") or string.find(typeLower, "aether") then
‎alertContent = string.format("@everyone ⚡ **%s Mendapatkan Item Spesial / Aether Material!**", targetPlayer)
‎embedTitle = "💎 Aemeath Wuthering Waves Hub V3 - Mount Soreya Event Tracker!"
‎embedColor = 16776960
‎end
‎
‎local posStr = position and string.format("%.1f, %.1f, %.1f", position.X, position.Y, position.Z) or "N/A"
‎
‎local data = {
‎["content"] = alertContent,
‎["embeds"] = {
‎{
‎["title"] = embedTitle,
‎["description"] = string.format("Pemain **%s** di dalam server Mount Soreya baru saja mendapatkan item spesial!", targetPlayer),
‎["color"] = embedColor,
‎["fields"] = {
‎{ ["name"] = "👤 Nama Player", ["value"] = targetPlayer, ["inline"] = true },
‎{ ["name"] = "🎯 Tipe Tangkapan", ["value"] = tostring(catchType), ["inline"] = true },
‎{ ["name"] = "📍 Koordinat", ["value"] = posStr, ["inline"] = true }
‎},
‎["footer"] = { ["text"] = "Aemeath Wuthering Waves Edition • Monitor" },
‎["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
‎}
‎}
‎}
‎
‎requestFunc({
‎Url = url,
‎Method = "POST",
‎Headers = { ["Content-Type"] = "application/json" },
‎Body = HttpService:JSONEncode(data)
‎})
‎end
‎end)
‎end
‎
‎task.spawn(function()
‎pcall(function()
‎local CutsceneBroadcastRemote = ReplicatedStorage:FindFirstChild("CutsceneBroadcast")
‎if CutsceneBroadcastRemote and CutsceneBroadcastRemote:IsA("RemoteEvent") then
‎CutsceneBroadcastRemote.OnClientEvent:Connect(function(catchType, position, targetPlayer)
‎local playerName = targetPlayer and targetPlayer.Name or "Unknown Player"
‎SendServerWideWebhook(playerName, catchType, position)
‎end)
‎end
‎end)
‎end)
‎
‎------------------------------------------------------------------
‎-- REAL-TIME CATCH MONITOR & STATS COUNTER
‎------------------------------------------------------------------
‎local hookedRemotes = {}
‎local function ProcessNotifyClient(actionType, fishDataArg)
‎if actionType == "GotFish" then
‎pcall(function()
‎getgenv().TotalFishCaught = getgenv().TotalFishCaught + 1
‎end)
‎end
‎end
‎
‎local function AttachNotifyHook(remote)
‎if remote and remote:IsA("RemoteEvent") and not hookedRemotes[remote] then
‎hookedRemotes[remote] = true
‎remote.OnClientEvent:Connect(ProcessNotifyClient)
‎end
‎end
‎
‎local function ScanContainerForNotify(container)
‎if not container then return end
‎for _, v in ipairs(container:GetDescendants()) do
‎if v:IsA("RemoteEvent") and v.Name == "NotifyClient" then
‎AttachNotifyHook(v)
‎end
‎end
‎end
‎
‎local function ListenToFishCatch()
‎pcall(function()
‎ScanContainerForNotify(ReplicatedStorage)
‎ReplicatedStorage.DescendantAdded:Connect(function(v)
‎if v:IsA("RemoteEvent") and v.Name == "NotifyClient" then
‎AttachNotifyHook(v)
‎end
‎end)
‎local function ScanCharacter(char)
‎if not char then return end
‎ScanContainerForNotify(char)
‎char.DescendantAdded:Connect(function(v)
‎if v:IsA("RemoteEvent") and v.Name == "NotifyClient" then
‎AttachNotifyHook(v)
‎end
‎end)
‎end
‎if LocalPlayer.Character then ScanCharacter(LocalPlayer.Character) end
‎LocalPlayer.CharacterAdded:Connect(ScanCharacter)
‎end)
‎end
‎
‎task.spawn(function()
‎task.wait(1)
‎ListenToFishCatch()
‎end)
‎
‎----------------------------------------------------
‎-- AUTO EQUIP ROD SYSTEM
‎----------------------------------------------------
‎local function AutoEquipRod()
‎pcall(function()
‎local character = LocalPlayer.Character
‎if not character then return end
‎
‎for _, child in ipairs(character:GetChildren()) do
‎if child:IsA("Tool") and (string.find(string.lower(child.Name), "rod") or string.find(string.lower(child.Name), "pancing")) then
‎return
‎end
‎end
‎
‎local backpack = LocalPlayer:FindFirstChild("Backpack")
‎local humanoid = character:FindFirstChildOfClass("Humanoid")
‎if backpack and humanoid then
‎for _, item in ipairs(backpack:GetChildren()) do
‎if item:IsA("Tool") then
‎local itemName = string.lower(item.Name)
‎if string.find(itemName, "rod") or string.find(itemName, "pancing") then
‎humanoid:EquipTool(item)
‎break
‎end
‎end
‎end
‎end
‎end)
‎end
‎
‎------------------------------------------------------------------
‎-- HELPER: AUTO FISHING & TAP CLICKER
‎------------------------------------------------------------------
‎local function EnableGameAutoFishing(state)
‎if state == nil then state = true end
‎local fired = false
‎pcall(function()
‎local mancing = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Mancing")
‎local r = mancing and (mancing:FindFirstChild("Auto") or mancing:FindFirstChild("AutoFishing"))
‎if r and r:IsA("RemoteEvent") then
‎r:FireServer(state)
‎fired = true
‎end
‎end)
‎return fired
‎end
‎
‎local function ClickGameAutoButton()
‎pcall(function()
‎local hub = PlayerGui:FindFirstChild("TyoHub")
‎for _, v in ipairs(PlayerGui:GetDescendants()) do
‎if (v:IsA("TextButton") or v:IsA("ImageButton")) and not (hub and v:IsDescendantOf(hub)) then
‎local n = string.lower(v.Name)
‎local t = v:IsA("TextButton") and string.lower(v.Text) or ""
‎if string.find(n, "auto") or string.find(t, "auto") then
‎if firesignal then
‎firesignal(v.MouseButton1Click)
‎firesignal(v.Activated)
‎elseif getconnections then
‎for _, c in ipairs(getconnections(v.MouseButton1Click)) do c:Fire() end
‎end
‎return
‎end
‎end
‎end
‎end)
‎end
‎
‎local function PerformTapClicker()
‎local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
‎if isMobile then
‎pcall(function()
‎local char = LocalPlayer.Character
‎local tool = char and char:FindFirstChildOfClass("Tool")
‎if tool then tool:Activate() end
‎end)
‎return
‎end
‎
‎local cam = Workspace.CurrentCamera
‎local vp = cam and cam.ViewportSize or Vector2.new(800, 600)
‎local mousePos = UIS:GetMouseLocation()
‎local pos = (mousePos.X > 0 and mousePos.Y > 0) and mousePos or Vector2.new(vp.X * 0.5, vp.Y * 0.5)
‎
‎pcall(function()
‎VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
‎task.wait(0.02)
‎VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
‎end)
‎end
‎
‎------------------------------------------------------------------
‎-- AUTO RECONNECT
‎------------------------------------------------------------------
‎task.spawn(function()
‎pcall(function()
‎CoreGui.ChildAdded:Connect(function(child)
‎if child.Name == "ErrorPrompt" or child.Name == "DisconnectPrompt" then
‎task.wait(1)
‎pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
‎end
‎end)
‎end)
‎end)
‎
‎-- GLOBAL STATES
‎getgenv().AutoFishingEventRunning = false
‎getgenv().BiteDelayInput = getgenv().TyoConfig.BiteDelay
‎getgenv().SelectedFishingSpot = getgenv().TyoConfig.SelectedSpot
‎getgenv().AutoSellRunning = false
‎getgenv().AutoSellTimerInput = getgenv().TyoConfig.AutoSellTimer
‎getgenv().AutoGalatamaRunning = false
‎getgenv().AutoSummitRunning = false
‎getgenv().AntiAFKRunning = false
‎getgenv().HideNameRunning = false
‎getgenv().FakeNameInput = "AEMEATH HUB"
‎getgenv().CurrentSelectedHalo = nil
‎getgenv().AutoDetectCoreEvent = false
‎getgenv().LoopSpotEnabled = false
‎getgenv().SpotLoopConfig = {
‎["Spot Mancing Jembatan"] = { Enabled = false, Timer = "10" },
‎["Spot Mancing Core"] = { Enabled = false, Timer = "10" },
‎["Spot Mancing Ikan Anomali"] = { Enabled = false, Timer = "10" }
‎}
‎getgenv().AutoFavoriteRunning = false
‎getgenv().AutoAcceptTradeRunning = false
‎getgenv().InvisibleRunning = false
‎getgenv().NetworkBoostRunning = false
‎
‎getgenv().FavRarities = {
‎["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false,
‎["Legendary"] = true, ["Mythical"] = true, ["Secret"] = true, ["Forgotten"] = true, ["Aether"] = true
‎}
‎getgenv().FavMutations = {
‎["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false,
‎["Lightning"] = false, ["Fairy Dust"] = true, ["Gold"] = false, ["Midnight"] = false,
‎["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false,
‎["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false,
‎["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false,
‎["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false
‎}
‎getgenv().UnfavRarities = {
‎["Common"] = false, ["UnCommon"] = false, ["Rare"] = false, ["Epic"] = false,
‎["Legendary"] = false, ["Mythical"] = false, ["Secret"] = false, ["Forgotten"] = false
‎}
‎getgenv().UnfavMutations = {
‎["Galaxy"] = false, ["Corrupt"] = false, ["Gemstone"] = false, ["Ghost"] = false,
‎["Lightning"] = false, ["Fairy Dust"] = false, ["Gold"] = false, ["Midnight"] = false,
‎["Radioactive"] = false, ["Stone"] = false, ["Holographic"] = false, ["Albino"] = false,
‎["Sandy"] = false, ["Cosmic"] = false, ["Normal"] = false, ["Elemental"] = false,
‎["Festive"] = false, ["8-Bit"] = false, ["Bloodmoon"] = false, ["Abyssal"] = false,
‎["Strawberry"] = false, ["Void"] = false, ["Cupid"] = false
‎}
‎
‎local FishingSpots = {
‎["Spot Mancing Jembatan"] = CFrame.new(-6783.74756, 1322.81006, -9757.34473, 0.0899723172, -9.34088291e-08, 0.995944262, 1.76120434e-08, 1, 9.21981638e-08, -0.995944262, 9.24533072e-09, 0.0899723172),
‎["Spot Mancing Core"] = CFrame.new(-9069.33887, 1250.32092, -6510.3374, 0.99812746, -7.96398965e-08, -0.0611686334, 8.05492206e-08, 1, 1.24000188e-08, 0.0611686334, -1.73038845e-08, 0.99812746),
‎["Spot Mancing Ikan Anomali"] = CFrame.new(-8199.52832, 1238.83752, -6278.13135, -0.999144316, 1.1644854e-08, -0.0413601957, 1.63464247e-08, 1, -1.13335595e-07, 0.0413601957, -1.13914709e-07, -0.999144316)
‎}
‎local NpcSellCFrame = CFrame.new(-6668.01416, 1312.69983, -9965.2998, 0.999977231, 1.08366018e-08, -0.00675115408, -1.09201403e-08, 1, -1.2337189e-08, 0.00675115408, 1.24106316e-08, 0.999977231)
‎
‎local function GetEquippedRod()
‎local char = LocalPlayer.Character
‎if not char then return nil end
‎local rod = char:FindFirstChild("Withering Rod")
‎if rod then return rod end
‎for _, c in ipairs(char:GetChildren()) do
‎if c:IsA("Tool") and c:FindFirstChild("Mechanics") then return c end
‎end
‎return nil
‎end
‎
‎------------------------------------------------------------------
‎-- ROD SETTINGS
‎------------------------------------------------------------------
‎local OriginalRodValues = {}
‎local function OptimizeRodSettings()
‎pcall(function()
‎local rod = GetEquippedRod()
‎local s = rod and rod:FindFirstChild("Mechanics") and rod.Mechanics:FindFirstChild("Settings")
‎if not s then return end
‎local t = s:FindFirstChild("Time_before_getfish")
‎if t then
‎if OriginalRodValues[t] == nil then OriginalRodValues[t] = t.Value end
‎t.Value = 0.05
‎end
‎local m = s:FindFirstChild("EnableMiniGame")
‎if m then
‎if OriginalRodValues[m] == nil then OriginalRodValues[m] = m.Value end
‎m.Value = false
‎end
‎end)
‎end
‎
‎local function RestoreRodSettings()
‎pcall(function()
‎for inst, val in pairs(OriginalRodValues) do
‎if inst and inst.Parent then inst.Value = val end
‎OriginalRodValues[inst] = nil
‎end
‎local rod = GetEquippedRod()
‎local s = rod and rod:FindFirstChild("Mechanics") and rod.Mechanics:FindFirstChild("Settings")
‎local m = s and s:FindFirstChild("EnableMiniGame")
‎if m then m.Value = true end
‎end)
‎end
‎
‎------------------------------------------------------------------
‎-- AUTO FISHING
‎------------------------------------------------------------------
‎local function RunAutoFishCycle(remoteFolder)
‎pcall(function()
‎local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
‎if not hrp then return end
‎
‎OptimizeRodSettings()
‎
‎remoteFolder.CastEvent:FireServer(true)
‎task.wait(0.05)
‎remoteFolder.CastEvent:FireServer(false, 100, hrp.CFrame.LookVector)
‎
‎local hooked = false
‎local conn = remoteFolder.NotifyClient.OnClientEvent:Connect(function(actionType)
‎if actionType == "Bite" or actionType == "Hook" then hooked = true end
‎end)
‎
‎local start = tick()
‎while not hooked and getgenv().AutoFishingEventRunning
‎and getgenv().TyoConfig.MinigameMode == "Instant" do
‎if tick() - start > 8 then break end
‎task.wait(0.05)
‎end
‎if conn then conn:Disconnect() end
‎
‎if hooked and getgenv().AutoFishingEventRunning
‎and getgenv().TyoConfig.MinigameMode == "Instant" then
‎task.wait(tonumber(getgenv().TyoConfig.BiteDelay) or 0.5)
‎
‎if getgenv().TyoConfig.MinigameMode ~= "Instant" then return end
‎
‎local tandaSeruRemote = remoteFolder:FindFirstChild("TandaSeruBersama")
‎if tandaSeruRemote then
‎local color1 = Color3.fromRGB(23, 255, 151)
‎local color2 = Color3.fromRGB(20, 20, 20)
‎local seq = ColorSequence.new({
‎ColorSequenceKeypoint.new(0, color1),
‎ColorSequenceKeypoint.new(1, color1)
‎})
‎tandaSeruRemote:FireServer(color1, color2, seq, 1.5)
‎end
‎
‎task.wait(0.1)
‎if getgenv().TyoConfig.MinigameMode ~= "Instant" then return end
‎remoteFolder.MiniGame:FireServer(true)
‎task.wait(0.3)
‎end
‎end)
‎end
‎
‎getgenv().FishLoopId = 0
‎local function StartFishingLoop()
‎getgenv().FishLoopId = getgenv().FishLoopId + 1
‎local myId = getgenv().FishLoopId
‎task.spawn(function()
‎local lastAuto, clickedGui, restored = 0, false, false
‎while getgenv().AutoFishingEventRunning and getgenv().FishLoopId == myId do
‎local mode = getgenv().TyoConfig.MinigameMode or "Legit"
‎AutoEquipRod()
‎if mode == "Legit" then
‎if not restored then
‎restored = true
‎RestoreRodSettings()
‎lastAuto = 0
‎end
‎if tick() - lastAuto > 10 then
‎lastAuto = tick()
‎local viaRemote = EnableGameAutoFishing(true)
‎if not viaRemote and not clickedGui then
‎clickedGui = true
‎ClickGameAutoButton()
‎end
‎end
‎PerformTapClicker()
‎task.wait(tonumber(getgenv().TyoConfig.TapDelay) or 0.12)
‎else
‎restored = false
‎pcall(function()
‎local rod = GetEquippedRod()
‎local rf = rod and rod:FindFirstChild("Mechanics") and rod.Mechanics:FindFirstChild("Remotes")
‎if rf then RunAutoFishCycle(rf) else task.wait(1) end
‎end)
‎task.wait(0.1)
‎end
‎end
‎if getgenv().FishLoopId == myId and (getgenv().TyoConfig.MinigameMode or "Legit") == "Legit" then
‎EnableGameAutoFishing(false)
‎end
‎end)
‎end
‎
‎local function TriggerSellToNpc()
‎pcall(function()
‎local character = LocalPlayer.Character
‎local hrp = character and character:FindFirstChild("HumanoidRootPart")
‎if not hrp then return end
‎local currentSpotCFrame = hrp.CFrame
‎hrp.CFrame = NpcSellCFrame + Vector3.new(0, 5, 0)
‎task.wait(0.8)
‎local mancing = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Mancing")
‎local jualSemua = mancing and mancing:FindFirstChild("JualSemua")
‎if jualSemua then jualSemua:InvokeServer() end
‎task.wait(0.8)
‎if getgenv().AutoFishingEventRunning then
‎hrp.CFrame = currentSpotCFrame
‎end
‎end)
‎end
‎
‎local function GetInventoryRemote()
‎local repStorage = game:GetService("ReplicatedStorage")
‎return repStorage:FindFirstChild("Remote")
‎and repStorage.Remote:FindFirstChild("Mancing")
‎and repStorage.Remote.Mancing:FindFirstChild("TandaiFavorit")
‎end
‎
‎local function GetServerFishData()
‎local fishDataList = {}
‎pcall(function()
‎local repStorage = game:GetService("ReplicatedStorage")
‎local ambilSemuaRemote = repStorage:FindFirstChild("Remote")
‎and repStorage.Remote:FindFirstChild("Inventaris")
‎and repStorage.Remote.Inventaris:FindFirstChild("AmbilSemua")
‎
‎if ambilSemuaRemote then
‎local result = {ambilSemuaRemote:InvokeServer()}
‎local data = result[1]
‎if type(data) == "table" then
‎for _, fish in ipairs(data) do
‎if type(fish) == "table" and (fish.uid or fish.UUID) then
‎table.insert(fishDataList, {
‎UUID = tostring(fish.uid or fish.UUID),
‎Name = tostring(fish.nama or fish.Name or ""),
‎Rarity = tostring(fish.rarity or fish.Rarity or ""),
‎Mutation = tostring(fish.mutasi or fish.Mutation or ""),
‎IsFavorited = fish.favorit or fish.IsFavorit or fish.IsFavorite or false
‎})
‎end
‎end
‎end
‎end
‎end)
‎return fishDataList
‎end
‎
‎local function ProcessAutoFavorite()
‎pcall(function()
‎local tandaiRemote = GetInventoryRemote()
‎if not tandaiRemote then return end
‎local serverData = GetServerFishData()
‎for _, fish in ipairs(serverData) do
‎if not getgenv().AutoFavoriteRunning then break end
‎local shouldFav = false
‎local fishRarityLower = string.lower(fish.Rarity)
‎local fishMutationLower = string.lower(fish.Mutation)
‎
‎for rName, active in pairs(getgenv().FavRarities) do
‎if active and string.lower(rName) == fishRarityLower then shouldFav = true end
‎end
‎for mName, active in pairs(getgenv().FavMutations) do
‎if active and string.find(fishMutationLower, string.lower(mName)) then shouldFav = true end
‎end
‎
‎if shouldFav and not fish.IsFavorited then
‎tandaiRemote:FireServer(fish.UUID, true)
‎task.wait(0.12)
‎end
‎end
‎end)
‎end
‎
‎task.spawn(function()
‎while true do
‎if getgenv().AutoFavoriteRunning then ProcessAutoFavorite() end
‎task.wait(2.5)
‎end
‎end)
‎
‎local function UnfavoriteAllFish()
‎task.spawn(function()
‎pcall(function()
‎local tandaiRemote = GetInventoryRemote()
‎if not tandaiRemote then return end
‎local serverData = GetServerFishData()
‎for _, fish in ipairs(serverData) do
‎tandaiRemote:FireServer(fish.UUID, false)
‎task.wait(0.08)
‎end
‎end)
‎end)
‎end
‎
‎local function UnfavoriteByFilter()
‎task.spawn(function()
‎pcall(function()
‎local tandaiRemote = GetInventoryRemote()
‎if not tandaiRemote then return end
‎local serverData = GetServerFishData()
‎for _, fish in ipairs(serverData) do
‎local shouldUnfav = false
‎local fishRarityLower = string.lower(fish.Rarity)
‎local fishMutationLower = string.lower(fish.Mutation)
‎for rName, active in pairs(getgenv().UnfavRarities) do
‎if active and string.lower(rName) == fishRarityLower then shouldUnfav = true end
‎end
‎for mName, active in pairs(getgenv().UnfavMutations) do
‎if active and string.find(fishMutationLower, string.lower(mName)) then shouldUnfav = true end
‎end
‎if shouldUnfav and fish.IsFavorited then
‎tandaiRemote:FireServer(fish.UUID, false)
‎task.wait(0.08)
‎end
‎end
‎end)
‎end)
‎end
‎
‎------------------------------------------------------------------
‎-- TRADE UTILITIES
‎------------------------------------------------------------------
‎local function GetTradeRemote(actionName)
‎local res = nil
‎pcall(function()
‎local tradeFolder = ReplicatedStorage:FindFirstChild("Remote") and ReplicatedStorage.Remote:FindFirstChild("Trade")
‎if tradeFolder then
‎res = tradeFolder:FindFirstChild(actionName)
‎end
‎end)
‎return res
‎end
‎
‎local function AutoAddAllFishToTrade()
‎pcall(function()
‎local serverData = GetServerFishData()
‎local tradeRemote = GetTradeRemote("AddItem") or GetTradeRemote("AddFish") or GetTradeRemote("TambahItem")
‎for _, fish in ipairs(serverData) do
‎if tradeRemote then
‎if tradeRemote:IsA("RemoteEvent") then
‎tradeRemote:FireServer(fish.UUID)
‎elseif tradeRemote:IsA("RemoteFunction") then
‎tradeRemote:InvokeServer(fish.UUID)
‎end
‎task.wait(0.05)
‎end
‎end
‎end)
‎end
‎
‎local function SendTradeRequestToTarget()
‎pcall(function()
‎local targetName = getgenv().TyoConfig.SelectedTradeTarget
‎if not targetName or targetName == "" then return end
‎local targetPlayer = Players:FindFirstChild(targetName)
‎if targetPlayer then
‎local reqRemote = GetTradeRemote("Request") or GetTradeRemote("SendRequest") or GetTradeRemote("KirimRequest")
‎if reqRemote then
‎if reqRemote:IsA("RemoteEvent") then
‎reqRemote:FireServer(targetPlayer)
‎elseif reqRemote:IsA("RemoteFunction") then
‎reqRemote:InvokeServer(targetPlayer)
‎end
‎end
‎end
‎end)
‎end
‎
‎task.spawn(function()
‎while true do
‎if getgenv().AutoAcceptTradeRunning then
‎pcall(function()
‎local acceptRemote = GetTradeRemote("Accept") or GetTradeRemote("TerimaTrade")
‎if acceptRemote then
‎if acceptRemote:IsA("RemoteEvent") then
‎acceptRemote:FireServer()
‎elseif acceptRemote:IsA("RemoteFunction") then
‎acceptRemote:InvokeServer()
‎end
‎end
‎end)
‎end
‎task.wait(1)
‎end
‎end)
‎
‎pcall(function()
‎local oldGui = PlayerGui:FindFirstChild("TyoHub")
‎if oldGui then oldGui:Destroy() end
‎end)
‎
‎local Gui = Instance.new("ScreenGui")
‎Gui.Name = "TyoHub"
‎Gui.Parent = PlayerGui
‎Gui.ResetOnSpawn = false
‎Gui.DisplayOrder = 2147483647
‎
‎----------------------------------------------------
‎-- IMPROVED UNIVERSAL DRAGGABLE FUNCTION
‎----------------------------------------------------
‎local function MakeDraggable(guiObject, handleObject)
‎handleObject = handleObject or guiObject
‎local dragging = false
‎local dragInput = nil
‎local dragStart = Vector3.zero
‎local startPos = UDim2.new()
‎local isClick = true
‎local clickTimeStart = 0
‎
‎local function update(input)
‎local delta = input.Position - dragStart
‎if delta.Magnitude > 6 then
‎isClick = false
‎end
‎guiObject.Position = UDim2.new(
‎startPos.X.Scale, startPos.X.Offset + delta.X,
‎startPos.Y.Scale, startPos.Y.Offset + delta.Y
‎)
‎end
‎
‎handleObject.InputBegan:Connect(function(input)
‎if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
‎dragging = true
‎isClick = true
‎clickTimeStart = tick()
‎dragStart = input.Position
‎startPos = guiObject.Position
‎
‎input.Changed:Connect(function()
‎if input.UserInputState == Enum.UserInputState.End then
‎dragging = false
‎end
‎end)
‎end
‎end)
‎
‎handleObject.InputChanged:Connect(function(input)
‎if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
‎dragInput = input
‎end
‎end)
‎
‎UIS.InputChanged:Connect(function(input)
‎if input == dragInput and dragging then
‎update(input)
‎end
‎end)
‎
‎return function()
‎return isClick and (tick() - clickTimeStart < 0.35)
‎end
‎end
‎
‎----------------------------------------------------
‎-- MAIN HUB UI (WUTHERING WAVES / AEMEATH AURA THEME)
‎----------------------------------------------------
‎local Main = Instance.new("Frame")
‎Main.Parent = Gui
‎Main.Visible = true
‎Main.Size = UDim2.new(0, 560, 0, 330)
‎Main.Position = UDim2.new(0.5, -280, 0.5, -165)
‎Main.BackgroundColor3 = Color3.fromRGB(12, 16, 26)
‎Main.ClipsDescendants = true
‎Main.ZIndex = 10
‎
‎local mainCorner = Instance.new("UICorner")
‎mainCorner.CornerRadius = UDim.new(0, 10)
‎mainCorner.Parent = Main
‎
‎local MainStroke = Instance.new("UIStroke")
‎MainStroke.Parent = Main
‎MainStroke.Color = Color3.fromRGB(80, 150, 255)
‎MainStroke.Thickness = 1.5
‎
‎-- Top Bar Header
‎local TopBar = Instance.new("Frame")
‎TopBar.Parent = Main
‎TopBar.Size = UDim2.new(1, 0, 0, 35)
‎TopBar.BackgroundColor3 = Color3.fromRGB(18, 24, 38)
‎TopBar.ZIndex = 11
‎
‎local TopCorner = Instance.new("UICorner")
‎TopCorner.CornerRadius = UDim.new(0, 10)
‎TopCorner.Parent = TopBar
‎
‎MakeDraggable(Main, TopBar)
‎
‎local HubTitle = Instance.new("TextLabel")
‎HubTitle.Parent = TopBar
‎HubTitle.Position = UDim2.new(0, 15, 0, 0)
‎HubTitle.Size = UDim2.new(0, 300, 1, 0)
‎HubTitle.BackgroundTransparency = 1
‎HubTitle.Text = "AEMEATH HUB <font color='#50A0FF'>V3</font>"
‎HubTitle.RichText = true
‎HubTitle.Font = Enum.Font.GothamBold
‎HubTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
‎HubTitle.TextSize = 14
‎HubTitle.TextXAlignment = Enum.TextXAlignment.Left
‎HubTitle.ZIndex = 12
‎
‎local ControlsFrame = Instance.new("Frame")
‎ControlsFrame.Parent = TopBar
‎ControlsFrame.Size = UDim2.new(0, 65, 1, 0)
‎ControlsFrame.Position = UDim2.new(1, -70, 0, 0)
‎ControlsFrame.BackgroundTransparency = 1
‎ControlsFrame.ZIndex = 12
‎
‎local ControlLayout = Instance.new("UIListLayout")
‎ControlLayout.Parent = ControlsFrame
‎ControlLayout.FillDirection = Enum.FillDirection.Horizontal
‎ControlLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
‎ControlLayout.VerticalAlignment = Enum.VerticalAlignment.Center
‎ControlLayout.Padding = UDim.new(0, 5)
‎
‎local MinimizeBtn = Instance.new("TextButton")
‎MinimizeBtn.Parent = ControlsFrame
‎MinimizeBtn.Size = UDim2.new(0, 24, 0, 24)
‎MinimizeBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 56)
‎MinimizeBtn.Text = "-"
‎MinimizeB
‎
