local player = game.Players.LocalPlayer
local stage = player:WaitForChild("leaderstats"):WaitForChild("Stage")
local checkpointsFolder = workspace:WaitForChild("Checkpoints")
local UserInputService = game:GetService("UserInputService")

-- Get all BaseParts in a checkpoint
local function getParts(cp)
	local parts = {}
	if cp:IsA("BasePart") then
		table.insert(parts, cp)
	else
		for _, p in ipairs(cp:GetDescendants()) do
			if p:IsA("BasePart") then
				table.insert(parts, p)
			end
		end
	end
	return parts
end

-- Update colors
local function updateColors()
	for _, cp in ipairs(checkpointsFolder:GetChildren()) do
		local num = tonumber(cp.Name)
		if num then
			local reached = num <= stage.Value
			for _, p in ipairs(getParts(cp)) do
				p.Color = reached and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,255)
			end
		end
	end
end

stage:GetPropertyChangedSignal("Value"):Connect(updateColors)
updateColors()

-- Teleport to last checkpoint when pressing R
UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.R then
		local cp = checkpointsFolder:FindFirstChild(tostring(stage.Value))
		local tpPart
		if cp then
			tpPart = cp:IsA("BasePart") and cp or cp:FindFirstChildWhichIsA("BasePart") or cp.PrimaryPart
		end
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if tpPart and hrp then
			char:MoveTo(tpPart.Position + Vector3.new(0,5,0))
		end
	end
end)
