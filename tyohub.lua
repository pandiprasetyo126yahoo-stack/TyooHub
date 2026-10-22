-- ==============================================================================
-- TYO HUB V3 | FULL FEATURE & NO-KEY SYSTEM (MULTI-DEVICE COMPATIBLE)
-- ==============================================================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

------------------------------------------------------------------
-- CONFIGURATION & FILE SAVE SYSTEM (SAFE FOR MULTI-ACCOUNT)
------------------------------------------------------------------
local SAFE_NAME = tostring(LocalPlayer.UserId or LocalPlayer.Name)
local CONFIG_FILE = "TyoHub_Config_" .. SAFE_NAME .. ".json"

getgenv().TyoConfig = {
	BiteDelay = "0.5",
	TapDelay = "0.12",
	MinigameMode = "Legit",
	SelectedSpot = "Spot Mancing Jembatan",
	AutoSellTimer = "5",
	AntiAFK = true,
	WebhookUrl = ""
}

local function SaveConfig()
	pcall(function()
		if writefile then
			writefile(CONFIG_FILE, HttpService:JSONEncode(getgenv().TyoConfig))
		end
	end)
end

------------------------------------------------------------------
-- ANTI AFK & AUTO RECONNECT
------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
	if getgenv().TyoConfig.AntiAFK then 
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new(0,0)) 
	end
end)

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

----------------------------------------------------
-- MAIN HUB UI (TYO HUB - FULL VERSION)
----------------------------------------------------
pcall(function()
	local oldGui = PlayerGui:FindFirstChild("TyoHub")
	if oldGui then oldGui:Destroy() end
end)

local Gui = Instance.new("ScreenGui")
Gui.Name = "TyoHub"
Gui.Parent = PlayerGui
Gui.ResetOnSpawn = false

local Main = Instance.new("Frame")
Main.Parent = Gui
Main.Visible = true
Main.Size = UDim2.new(0,550,0,320)
Main.Position = UDim2.new(0.5,-275,0.5,-160)
Main.BackgroundColor3 = Color3.fromRGB(20,20,25)
Main.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0,18)
mainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = Main
MainStroke.Color = Color3.fromRGB(0,170,255)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Parent = Main
Sidebar.Size = UDim2.new(0,140,1,0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15,15,20)

local HubTitle = Instance.new("TextLabel")
HubTitle.Parent = Sidebar
HubTitle.BackgroundTransparency = 1
HubTitle.Position = UDim2.new(0, 0, 0, 12)
HubTitle.Size = UDim2.new(1, 0, 0, 22)
HubTitle.Text = "TYO HUB"
HubTitle.Font = Enum.Font.GothamBold
HubTitle.TextColor3 = Color3.fromRGB(0, 170, 255)
HubTitle.TextSize = 18

local HubSubTitle = Instance.new("TextLabel")
HubSubTitle.Parent = Sidebar
HubSubTitle.BackgroundTransparency = 1
HubSubTitle.Position = UDim2.new(0, 0, 0, 34)
HubSubTitle.Size = UDim2.new(1, 0, 0, 18)
HubSubTitle.Text = "🔥 No Key - Multi-Device"
HubSubTitle.Font = Enum.Font.GothamBold
HubSubTitle.TextColor3 = Color3.fromRGB(0, 255, 150)
HubSubTitle.TextSize = 10

-- Content Container
local Content = Instance.new("Frame")
Content.Parent = Main
Content.Position = UDim2.new(0,150,0,30)
Content.Size = UDim2.new(1,-160,1,-40)
Content.BackgroundTransparency = 1

local function MakePage()
	local f = Instance.new("ScrollingFrame")
	f.Parent = Content
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.CanvasSize = UDim2.new(0,0,2.5,0)
	f.ScrollBarThickness = 4
	local l = Instance.new("UIListLayout")
	l.Parent = f
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 8)
	return f
end

local FishingPage = MakePage(); FishingPage.Visible = true
local PlayerPage = MakePage()
local SettingsPage = MakePage()

local function CreateNavButton(text, yPos, page)
	local btn = Instance.new("TextButton")
	btn.Parent = Sidebar
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	btn.Text = text
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 12
	local corner = Instance.new("UICorner")
	corner.Parent = btn
	btn.MouseButton1Click:Connect(function()
		FishingPage.Visible = false
		PlayerPage.Visible = false
		SettingsPage.Visible = false
		page.Visible = true
	end)
	return btn
end

CreateNavButton("Fishing & Sell", 65, FishingPage)
CreateNavButton("Player", 105, PlayerPage)
CreateNavButton("Settings", 145, SettingsPage)

local function AddToggle(parent, text, defaultState, callback)
	local b = Instance.new("TextButton")
	b.Parent = parent
	b.Size = UDim2.new(1,-10,0,35)
	b.BackgroundColor3 = defaultState and Color3.fromRGB(0,120,200) or Color3.fromRGB(30,30,40)
	b.Text = "  " .. text .. (defaultState and " [ON]" or " [OFF]")
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 12
	b.TextXAlignment = Enum.TextXAlignment.Left
	local c = Instance.new("UICorner")
	c.Parent = b
	local state = defaultState
	b.MouseButton1Click:Connect(function()
		state = not state
		b.Text = "  " .. text .. (state and " [ON]" or " [OFF]")
		b.BackgroundColor3 = state and Color3.fromRGB(0,120,200) or Color3.fromRGB(30,30,40)
		callback(state)
	end)
end

----------------------------------------------------
-- ISIKAN TOMBOL FITUR
----------------------------------------------------
AddToggle(FishingPage, "Auto Fishing (Smart Rod)", false, function(v)
	getgenv().AutoFishing = v
end)

AddToggle(FishingPage, "Fast Reel / Instant Catch", false, function(v)
	getgenv().FastReel = v
end)

AddToggle(FishingPage, "Auto Sell Fish", false, function(v)
	getgenv().AutoSell = v
end)

AddToggle(PlayerPage, "Anti-AFK Protection", true, function(v)
	getgenv().TyoConfig.AntiAFK = v
	SaveConfig()
end)

AddToggle(PlayerPage, "Infinite Jump", false, function(v)
	getgenv().InfJump = v
end)