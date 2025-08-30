-- CONFIGURATION
local Workspace = game:GetService("Workspace")

-- Find the two unique pressure plates
local pressurePlates = {}
for _, obj in Workspace:GetChildren() do
    if obj.Name == "PressurePlate" and obj:IsA("BasePart") then
        pressurePlates[#pressurePlates+1] = obj
    end
end

local plate1 = pressurePlates[1]
local plate2 = pressurePlates[2]

-- Reference the correct wall ("Transparent Wall")
local wall = Workspace:FindFirstChild("PressurePlateWall")

-- Store original and raised positions
local wallOriginalCFrame = wall and wall.CFrame
local wallRaisedCFrame = wallOriginalCFrame and (wallOriginalCFrame + Vector3.new(0, wall.Size.Y + 2, 0))

-- Track which players are on each plate
local plate1Players = {}
local plate2Players = {}

-- Track press times for simultaneous logic
local plate1PressTime = nil
local plate2PressTime = nil
local simultaneousWindow = 0.25 -- seconds

local wallUp = false
local lowerWallTimerActive = false

local function isPlatePressed(platePlayers)
    for _, v in platePlayers do
        if v then return true end
    end
    return false
end

local function bothPlatesPressed()
    return isPlatePressed(plate1Players) and isPlatePressed(plate2Players)
end

local function raiseWall()
    if wall and wallRaisedCFrame then
        wall.CFrame = wallRaisedCFrame
        wallUp = true
    end
end

local function lowerWall()
    if wall and wallOriginalCFrame then
        wall.CFrame = wallOriginalCFrame
        wallUp = false
    end
end

local function tryLowerWallWithDelay()
    if lowerWallTimerActive then return end
    lowerWallTimerActive = true
    task.wait(2)
    -- Only lower if both plates are NOT pressed after the delay
    if not bothPlatesPressed() then
        lowerWall()
    end
    lowerWallTimerActive = false
end

local function resetPressTimes()
    plate1PressTime = nil
    plate2PressTime = nil
end

local function tryActivateWallSimultaneous()
    if plate1PressTime and plate2PressTime then
        local diff = math.abs(plate1PressTime - plate2PressTime)
        if diff <= simultaneousWindow then
            if not wallUp then
                raiseWall()
            end
        else
            -- Not simultaneous, reset state
            resetPressTimes()
            -- Remove all players from both plates to force re-press
            for k in plate1Players do plate1Players[k] = nil end
            for k in plate2Players do plate2Players[k] = nil end
        end
    end
end

local function updateWallOnRelease()
    if wallUp then
        tryLowerWallWithDelay()
    end
end

local function onPlateTouched(platePlayers, setPressTime)
    return function(other)
        local character = other.Parent
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if not platePlayers[character] then
                platePlayers[character] = true
                setPressTime(os.clock())
                tryActivateWallSimultaneous()
            end
        end
    end
end

local function onPlateTouchEnded(platePlayers, clearPressTime)
    return function(other)
        local character = other.Parent
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if platePlayers[character] then
                platePlayers[character] = nil
                clearPressTime()
                updateWallOnRelease()
            end
        end
    end
end

if plate1 then
    plate1.Touched:Connect(onPlateTouched(plate1Players, function(t) plate1PressTime = t end))
    plate1.TouchEnded:Connect(onPlateTouchEnded(plate1Players, function() plate1PressTime = nil end))
end

if plate2 then
    plate2.Touched:Connect(onPlateTouched(plate2Players, function(t) plate2PressTime = t end))
    plate2.TouchEnded:Connect(onPlateTouchEnded(plate2Players, function() plate2PressTime = nil end))
end

