local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("CoinDashRemotes")
local stateEvent = remotes:WaitForChild("StateChanged")
local feedbackEvent = remotes:WaitForChild("Feedback")

local gui = Instance.new("ScreenGui")
gui.Name = "CoinDashGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(360, 116)
panel.Position = UDim2.fromOffset(24, 24)
panel.BackgroundColor3 = Color3.fromRGB(20, 25, 34)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 30)
title.Position = UDim2.fromOffset(12, 10)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Coin Dash"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 22
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -24, 0, 34)
info.Position = UDim2.fromOffset(12, 44)
info.BackgroundTransparency = 1
info.Font = Enum.Font.Gotham
info.TextColor3 = Color3.fromRGB(220, 230, 240)
info.TextSize = 18
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = panel

local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -24, 0, 26)
message.Position = UDim2.fromOffset(12, 80)
message.BackgroundTransparency = 1
message.Font = Enum.Font.GothamMedium
message.TextColor3 = Color3.fromRGB(95, 220, 255)
message.TextSize = 16
message.TextXAlignment = Enum.TextXAlignment.Left
message.Parent = panel

local function makeSound(name, soundId, volume)
	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Parent = SoundService
	return sound
end

local coinSound = makeSound("CoinDashCoin", "rbxassetid://12221967", 0.35)
local winSound = makeSound("CoinDashWin", "rbxassetid://12222253", 0.5)

stateEvent.OnClientEvent:Connect(function(state)
	info.Text = string.format("Coins: %d/%d     Time: %ds", state.coins, state.target, state.timeLeft)
	if state.message and state.message ~= "" then
		message.Text = state.message
	end

	if state.won then
		panel.BackgroundColor3 = Color3.fromRGB(20, 92, 55)
	end
end)

feedbackEvent.OnClientEvent:Connect(function(kind)
	if kind == "coin" then
		coinSound:Play()
		TweenService:Create(panel, TweenInfo.new(0.08), { Size = UDim2.fromOffset(372, 124) }):Play()
		task.wait(0.08)
		TweenService:Create(panel, TweenInfo.new(0.15), { Size = UDim2.fromOffset(360, 116) }):Play()
	elseif kind == "win" then
		winSound:Play()
		message.Text = "通关成功！"
	end
end)
