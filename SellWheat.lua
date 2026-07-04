loadstring(game:HttpGet("https://raw.githubusercontent.com/lchMagDichNicht/Pastel.wtf-Script/refs/heads/main/Theme.lua"))()
wait(0.25)
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/placeholder14331/dependencies/refs/heads/main/ThemeManager")
)()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- =========================
-- Service
-- =========================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local cam = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local Camera = workspace.CurrentCamera
local Options = Library.Options
local Toggles = Library.Toggles
local player = Players.LocalPlayer
local Player = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Gui = Player:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")

local startTime = os.time()

local executorName = (identifyexecutor and identifyexecutor())
	or (getexecutorname and getexecutorname())
	or "Unknown Executor"

local userRegion = LocalizationService:GetCountryRegionForPlayerAsync(LocalPlayer) or "Global"

local rawHwid
if crypt and crypt.hash then
	rawHwid = string.sub(crypt.hash(tostring(LocalPlayer.UserId) .. "PASTEL_SALT", "sha256"), 1, 18):upper()
else
	local seed = LocalPlayer.UserId + 1337
	math.randomseed(seed)
	local chars = "ABCDEF0123456789"
	local tempHwid = {}
	for i = 1, 18 do
		local r = math.random(1, #chars)
		table.insert(tempHwid, string.sub(chars, r, r))
	end
	rawHwid = table.concat(tempHwid)
end

-- =================================
-- UI Window Configuration
-- =================================
local Window = Library:CreateWindow({
	Title = "Pastel.wtf",
	Icon = 118706235232208,
	ShowCustomCursor = false,
	DisableSearch = true,
	Size = UDim2.fromOffset(650, 480),
	IconSize = UDim2.fromOffset(40, 40),
	Footer = "♡ made with love by IchMagDichNicht",
	NotifySide = "Right",
	Resizable = false,
	ToggleKeybind = Enum.KeyCode.RightControl,
})

-- ================================
-- Tabs
-- ================================
local Tabs = {
	Home = Window:AddTab("Home", "house"),
    Main = Window:AddTab("Main", "globe"),
    Settings = Window:AddTab("UI Settings", "settings"),
}

-- =================================
-- Settings Tab Layout
-- =================================
local SettingsGroupLeft = Tabs.Settings:AddLeftGroupbox("Menu Customization", "app-window")

SettingsGroupLeft:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Show Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})

local MyToggle = SettingsGroupLeft:AddToggle("MyToggle", {
	Text = "Custom Cursor",
	Default = false,
})

Toggles.MyToggle:OnChanged(function(state)
	Library.ShowCustomCursor = state
end)

SettingsGroupLeft:AddDivider()

SettingsGroupLeft:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "Interface Scale (DPI)",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})

SettingsGroupLeft:AddDivider()

SettingsGroupLeft:AddLabel("Menu Bind"):AddKeyPicker("MenuKeybind", {
	Default = "RightControl",
	NoUI = true,
	Text = "Menu keybind",
})

SettingsGroupLeft:AddButton("Unload Script", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

-- =================================
-- SaveManager & ThemeManager
-- =================================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("Pastel.wtf")
SaveManager:SetFolder("Pastel.wtf/Sell Wheat")
SaveManager:SetSubFolder("Pastel.wtf")
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig("")

-- =================================
-- Dashboard / Home (MODERN & PASTEL)
-- =================================
do
	local request = (syn and syn.request) or (http and http.request) or http_request or request

	local ProfileBox = Tabs.Home:AddLeftGroupbox("Profile", "user")
	local SystemBox = Tabs.Home:AddLeftGroupbox("Environment", "activity")
	local CommunityBox = Tabs.Home:AddRightGroupbox("System Credentials", "shield")

	-- 1. PROFILE
	local Thumbnail =
		Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	ProfileBox:AddImage("UserAvatar", {
		Image = Thumbnail,
		Transparency = 0.05,
		Color = Color3.fromRGB(255, 218, 224),
		ScaleType = Enum.ScaleType.Fit,
		Height = 130,
	})

	ProfileBox:AddDivider()
	ProfileBox:AddLabel({
		Text = "Welcome back, <font color='#ffb6c1'><b>" .. LocalPlayer.DisplayName .. "</b></font> ♡",
	})
	ProfileBox:AddLabel({ Text = "@" .. LocalPlayer.Name })

	local accountCreationTimestamp = os.time() - (LocalPlayer.AccountAge * 86400)
	local creationDate = os.date("%d.%m.%Y", accountCreationTimestamp)
	ProfileBox:AddLabel({ Text = "Created: <font color='#bfe3b4'>" .. creationDate .. "</font>" })

	-- 2. ENVIRONMENT
	local success, productInfo = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	local gameName = success and productInfo.Name or "Unknown Universe"

	SystemBox:AddLabel({ Text = "<b>Game:</b> " .. gameName, DoesWrap = true })
	SystemBox:AddDivider()

	SystemBox:AddLabel({ Text = "Connection: <font color='#bfe3b4'>Stable</font>" })
	SystemBox:AddLabel({ Text = "Executor: <font color='#aec6cf'>" .. executorName .. "</font>" })

	-- 3. SYSTEM CREDENTIALS
	CommunityBox:AddLabel({ Text = "<b>✨ PASTEL.WTF</b>", DoesWrap = true })

	local uptimeLabel = CommunityBox:AddLabel({ Text = "Uptime: 00:00:00" })
	local serverTimeLabel = CommunityBox:AddLabel({ Text = "Time: " .. os.date("%X") })
	local livePingLabel = CommunityBox:AddLabel({ Text = "Latency: Fetching..." })

	CommunityBox:AddDivider()

	CommunityBox:AddLabel({ Text = "HWID: <font color='#ffb6c1' face='Code'>" .. rawHwid .. "</font>" })
	CommunityBox:AddLabel({ Text = "Account Age: <font color='#aec6cf'>" .. LocalPlayer.AccountAge .. " Days</font>" })
	CommunityBox:AddLabel({ Text = "Region: <font color='#ffdfba'>" .. userRegion .. "</font>" })

	CommunityBox:AddDivider()

	-- Live-Loop für Uptime, Uhrzeit und echten Live-Ping
	task.spawn(function()
		while task.wait(1) do
			if not Library then
				break
			end

			local diff = os.time() - startTime
			local hours = math.floor(diff / 3600)
			local minutes = math.floor((diff % 3600) / 60)
			local seconds = diff % 60

			local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())

			uptimeLabel:SetText(
				string.format("Uptime: <font color='#bfe3b4'>%02d:%02d:%02d</font>", hours, minutes, seconds)
			)
			serverTimeLabel:SetText("Server Time: <font color='#ffdfba'>" .. os.date("%X") .. "</font>")
			livePingLabel:SetText("Latency: <font color='#aec6cf'>" .. ping .. "ms</font>")
		end
	end)

	local inviteCode = "ZtRSZY8qaD"
	CommunityBox:AddButton({
		Text = "Join Community Discord",
		Func = function()
			setclipboard("https://discord.gg/" .. inviteCode)

			if request then
				request({
					Url = "http://127.0.0.1:6463/rpc?v=1",
					Method = "POST",
					Headers = {
						["Content-Type"] = "application/json",
						["Origin"] = "https://discord.com",
					},
					Body = HttpService:JSONEncode({
						cmd = "INVITE_BROWSER",
						nonce = HttpService:GenerateGUID(false),
						args = { code = inviteCode },
					}),
				})

				Library:Notify({
					Title = "Pastel.wtf",
					Description = "Opening Discord App...",
					Time = 4,
				})
			else
				Library:Notify({
					Title = "Pastel.wtf",
					Description = "Invite copied to clipboard!",
					Time = 4,
				})
			end
		end,
		DoubleClick = false,
	})
end

local MainLeft = Tabs.Main:AddLeftGroupbox("Main", "globe")
local MainRight = Tabs.Main:AddRightGroupbox("Stats", "globe")

MainLeft:AddButton("Sell", function()
    game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("Sell", 9e9):FireServer()
end)

MainLeft:AddButton("Rebirth", function()
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes", 9e9):WaitForChild("Rebirth", 9e9):FireServer()
end)

MainLeft:AddButton("Collect All", function()
	local player = game.Players.LocalPlayer
	local collect = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Collect")
	local placedObjects = workspace:WaitForChild("PlacedObjects"):WaitForChild(player.Name)

	for _, object in ipairs(placedObjects:GetChildren()) do
    	collect:FireServer(object)
	end
end)

local Price = game.Players.LocalPlayer.PlayerGui.UI.Pages.Sell.Main.Sell.Price

local Label = MainRight:AddLabel("Wheat Worth: " .. Price.Text:gsub("Sell%s*%$", ""), false)

Price:GetPropertyChangedSignal("Text"):Connect(function()
    Label:SetText("Wheat Worth: " .. Price.Text:gsub("Sell%s*%$", ""))
end)

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local folder = workspace.PlacedObjects:WaitForChild(player.Name)

local Label = MainRight:AddLabel("", false)

local function formatNumber(num)
	local function round(value)
		return math.floor(value + 0.5)
	end

	if num >= 1e12 then
		return round(num / 1e12) .. "T"
	elseif num >= 1e9 then
		return round(num / 1e9) .. "B"
	elseif num >= 1e6 then
		return round(num / 1e6) .. "M"
	elseif num >= 1e3 then
		return round(num / 1e3) .. "K"
	else
		return tostring(round(num))
	end
end

RunService.RenderStepped:Connect(function()
	local currentTotal = 0
	local maxTotal = 0

	for _, model in ipairs(folder:GetChildren()) do
		local current = model:GetAttribute("CurrentCapacity")
		local max = model:GetAttribute("MaxCapacity")

		if current and max then
			currentTotal += current
			maxTotal += max
		end
	end

	Label:SetText("Capacity: " .. formatNumber(currentTotal) .. "/" .. formatNumber(maxTotal))
end)

local player = game:GetService("Players").LocalPlayer
local RunService = game:GetService("RunService")
local folder = workspace.PlacedObjects:WaitForChild(player.Name)

local Label = MainRight:AddLabel("", false)

local function formatNumber(num)
	if num >= 1e12 then
		return string.format("%.2fT", num / 1e12)
	elseif num >= 1e9 then
		return string.format("%.2fB", num / 1e9)
	elseif num >= 1e6 then
		return string.format("%.2fM", num / 1e6)
	elseif num >= 1e3 then
		return string.format("%.2fK", num / 1e3)
	else
		return tostring(math.floor(num))
	end
end

RunService.RenderStepped:Connect(function()
	local totalCPS = 0

	for _, model in ipairs(folder:GetChildren()) do
		local cps = model:GetAttribute("CPS")

		if cps then
			totalCPS += cps
		end
	end

	Label:SetText("Wheat/sec: " .. formatNumber(totalCPS))
end)

local Label = MainRight:AddLabel("Next Collect: --", false)

local MyToggle = MainRight:AddToggle("MyToggle", {
    Text = "Auto Collect When Full",
    Default = false,
})

local player = game:GetService("Players").LocalPlayer
local collect = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Collect")
local placedObjects = workspace:WaitForChild("PlacedObjects"):WaitForChild(player.Name)

local collected = false

local function UpdateCollectTimer()
    local totalCurrent = 0
    local totalMax = 0
    local totalCPS = 0

    for _, obj in ipairs(placedObjects:GetDescendants()) do
        if obj:IsA("Model") then
            local current = obj:GetAttribute("CurrentCapacity")
            local max = obj:GetAttribute("MaxCapacity")
            local cps = obj:GetAttribute("CPS")

            if typeof(current) == "number" then
                totalCurrent += current
            end

            if typeof(max) == "number" then
                totalMax += max
            end

            if typeof(cps) == "number" then
                totalCPS += cps
            end
        end
    end

    if totalMax <= 0 or totalCPS <= 0 then
        Label:SetText("Next Collect: --")
        return
    end

    local remaining = math.max(0, (totalMax - totalCurrent) / totalCPS)
    local totalTime = totalMax / totalCPS

    local remMin = math.floor(remaining / 60)
    local remSec = math.floor(remaining % 60)

    local totalMin = math.floor(totalTime / 60)
    local totalSec = math.floor(totalTime % 60)

    Label:SetText(string.format(
        "Next Collect: %02d:%02d (%02d:%02d)",
        remMin,
        remSec,
        totalMin,
        totalSec
    ))
end

local function CheckAllFull()
    local found = false

    for _, obj in ipairs(placedObjects:GetDescendants()) do
        if obj:IsA("Model") then
            local current = obj:GetAttribute("CurrentCapacity")
            local max = obj:GetAttribute("MaxCapacity")

            if current ~= nil and max ~= nil then
                found = true

                if current < max then
                    collected = false
                    return false
                end
            end
        end
    end

    return found
end

Toggles.MyToggle:OnChanged(function(state)
    if state then
        task.spawn(function()
            while Toggles.MyToggle.Value do
                UpdateCollectTimer()

                if CheckAllFull() and not collected then
                    collected = true

                    for _, object in ipairs(placedObjects:GetChildren()) do
                        collect:FireServer(object)
                    end
                end

                task.wait(0.2)
            end

            Label:SetText("Next Collect: --")
        end)
    else
        Label:SetText("Next Collect: --")
    end
end)