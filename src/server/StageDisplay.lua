-- SERVICES
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local stageStore = DataStoreService:GetDataStore("CheckpointStage")
local checkpointsFolder = workspace:WaitForChild("Checkpoints")

-- Add leaderstats
Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = 1
	stage.Parent = leaderstats

	-- Load saved stage
	local success, savedStage = pcall(function()
		return stageStore:GetAsync(player.UserId)
	end)
	if success and type(savedStage) == "number" and savedStage >= 1 then
		stage.Value = savedStage
	end

	-- Move player to their stage checkpoint
	player.CharacterAdded:Connect(function(char)
		task.wait()
		local cp = checkpointsFolder:FindFirstChild(tostring(stage.Value))
		if cp then
			local tpPart = cp:IsA("BasePart") and cp or cp:FindFirstChildWhichIsA("BasePart") or cp.PrimaryPart
			if tpPart and char:FindFirstChild("HumanoidRootPart") then
				char:MoveTo(tpPart.Position + Vector3.new(0,5,0))
			end
		end
	end)
end)

-- Save stage when player leaves or stage changes
local function saveStage(player)
	local stage = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Stage")
	if stage then
		pcall(function()
			stageStore:SetAsync(player.UserId, stage.Value)
		end)
	end
end

Players.PlayerRemoving:Connect(saveStage)
















