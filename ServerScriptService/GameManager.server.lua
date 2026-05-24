local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local COIN_TARGET = 10
local ROUND_SECONDS = 90

local remotes = ReplicatedStorage:FindFirstChild("CoinDashRemotes") or Instance.new("Folder")
remotes.Name = "CoinDashRemotes"
remotes.Parent = ReplicatedStorage

local stateEvent = remotes:FindFirstChild("StateChanged") or Instance.new("RemoteEvent")
stateEvent.Name = "StateChanged"
stateEvent.Parent = remotes

local feedbackEvent = remotes:FindFirstChild("Feedback") or Instance.new("RemoteEvent")
feedbackEvent.Name = "Feedback"
feedbackEvent.Parent = remotes

local map = workspace:FindFirstChild("CoinDashMap") or Instance.new("Folder")
map.Name = "CoinDashMap"
map.Parent = workspace
map:ClearAllChildren()

local playerState = {}
local gatePart

local function makePart(name, size, position, color, anchored)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Anchored = anchored ~= false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = map
	return part
end

local function buildMap()
	makePart("StartPlatform", Vector3.new(18, 1, 18), Vector3.new(0, 0, 0), Color3.fromRGB(80, 170, 255))
	makePart("MainPlatform", Vector3.new(70, 1, 32), Vector3.new(0, 0, -35), Color3.fromRGB(70, 80, 95))
	makePart("FinishPlatform", Vector3.new(18, 1, 18), Vector3.new(0, 0, -78), Color3.fromRGB(100, 210, 120))

	for i = 1, 5 do
		makePart("Obstacle_" .. i, Vector3.new(8, 3, 2), Vector3.new(-24 + i * 8, 2, -22 - i * 8), Color3.fromRGB(255, 90, 90))
	end

	for i = 1, COIN_TARGET do
		local x = -28 + ((i - 1) % 5) * 14
		local z = -18 - math.floor((i - 1) / 5) * 22
		local coin = makePart("Coin_" .. i, Vector3.new(2, 2, 0.4), Vector3.new(x, 3, z), Color3.fromRGB(255, 214, 75))
		coin.Shape = Enum.PartType.Cylinder
		coin.Orientation = Vector3.new(0, 0, 90)
		coin:SetAttribute("Collected", false)
	end

	gatePart = makePart("LockedGate", Vector3.new(14, 14, 2), Vector3.new(0, 7, -68), Color3.fromRGB(40, 160, 255))
	gatePart.Transparency = 0.15

	local finish = makePart("FinishTrigger", Vector3.new(14, 2, 14), Vector3.new(0, 2, -79), Color3.fromRGB(80, 255, 130))
	finish.Transparency = 0.45
	finish.CanCollide = false
end

local function getState(player)
	playerState[player] = playerState[player] or {
		coins = 0,
		timeLeft = ROUND_SECONDS,
		won = false,
		roundStarted = os.clock(),
	}
	return playerState[player]
end

local function pushState(player, message)
	local state = getState(player)
	stateEvent:FireClient(player, {
		coins = state.coins,
		target = COIN_TARGET,
		timeLeft = math.max(0, state.timeLeft),
		won = state.won,
		message = message or "",
	})
end

local function openGate()
	if not gatePart or gatePart:GetAttribute("Opened") then
		return
	end

	gatePart:SetAttribute("Opened", true)
	gatePart.CanCollide = false
	TweenService:Create(gatePart, TweenInfo.new(0.8), {
		Position = gatePart.Position + Vector3.new(0, 14, 0),
		Transparency = 0.75,
	}):Play()
end

local function onCoinTouched(coin, hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player or coin:GetAttribute("Collected") then
		return
	end

	local state = getState(player)
	if state.won or state.timeLeft <= 0 then
		return
	end

	coin:SetAttribute("Collected", true)
	coin.Transparency = 1
	coin.CanTouch = false
	coin.CanCollide = false

	state.coins += 1
	feedbackEvent:FireClient(player, "coin")

	if state.coins >= COIN_TARGET then
		openGate()
		pushState(player, "金币已收集完，终点门已开启！")
	else
		pushState(player, "收集金币中")
	end
end

local function onFinishTouched(hit)
	local character = hit.Parent
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local state = getState(player)
	if state.won or state.coins < COIN_TARGET or state.timeLeft <= 0 then
		return
	end

	state.won = true
	feedbackEvent:FireClient(player, "win")
	pushState(player, "通关成功！")
end

local function connectMapEvents()
	for _, child in ipairs(map:GetChildren()) do
		if child.Name:match("^Coin_") then
			child.Touched:Connect(function(hit)
				onCoinTouched(child, hit)
			end)
		elseif child.Name == "FinishTrigger" then
			child.Touched:Connect(onFinishTouched)
		end
	end
end

local function setupPlayer(player)
	local state = getState(player)
	state.coins = 0
	state.timeLeft = ROUND_SECONDS
	state.won = false
	state.roundStarted = os.clock()

	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart")
		root.CFrame = CFrame.new(0, 5, 0)
		pushState(player, "收集所有金币并抵达终点")
	end)

	task.spawn(function()
		while player.Parent do
			local current = getState(player)
			if not current.won then
				current.timeLeft = ROUND_SECONDS - math.floor(os.clock() - current.roundStarted)
				if current.timeLeft <= 0 then
					current.timeLeft = 0
					pushState(player, "时间结束，重新运行游戏再试一次")
					break
				end
				pushState(player)
			end
			task.wait(1)
		end
	end)
end

buildMap()
connectMapEvents()

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	playerState[player] = nil
end)
