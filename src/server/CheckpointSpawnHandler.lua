local Players = game:GetService("Players")
local checkpointsFolder = workspace:WaitForChild("Checkpoints")

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local stage = player:WaitForChild("leaderstats"):WaitForChild("Stage")
		local cp = checkpointsFolder:FindFirstChild(tostring(stage.Value))
		if cp and char:FindFirstChild("HumanoidRootPart") then
			local tpPart
			if cp:IsA("BasePart") then
				tpPart = cp
			elseif cp.PrimaryPart then
				tpPart = cp.PrimaryPart
			else
				tpPart = cp:FindFirstChildWhichIsA("BasePart")
			end

			if tpPart then
				char.HumanoidRootPart.CFrame = tpPart.CFrame + Vector3.new(0,5,0)
			end
		end
	end)
end)
