local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local stageStore = DataStoreService:GetDataStore("StageData")

Players.PlayerAdded:Connect(function(player)
	-- leaderstats folder
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	-- Stage value
	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = 1
	stage.Parent = leaderstats

	-- Load saved stage from DataStore
	local savedStage
	pcall(function()
		savedStage = stageStore:GetAsync(player.UserId)
	end)

	if typeof(savedStage) == "number" and savedStage >= 1 then
		stage.Value = savedStage
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local stage = player:FindFirstChild("leaderstats") and player.leaderstats:FindFirstChild("Stage")
	if stage then
		pcall(function()
			stageStore:SetAsync(player.UserId, stage.Value)
		end)
	end
end)
