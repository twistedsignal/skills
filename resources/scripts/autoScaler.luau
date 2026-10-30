--!strict
-- Constant variables
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local PHONE_HEIGHT = 393
local PC_HEIGHT = 1080
local TAG = "UIScale"

-- Private variables
local camera = workspace.CurrentCamera
local scales: {[UIScale]: Vector2} = {}
local currentAlpha = 1

-- Private functions
local function getAlpha(viewportSize: number): number
	return math.clamp((viewportSize - PHONE_HEIGHT) / (PC_HEIGHT - PHONE_HEIGHT), 0, 1)
end

local function scaleAdded(scale: UIScale)
	local minSize = (scale:GetAttribute("MinScale") :: number) or .75 -- phone size
	local maxSize = (scale:GetAttribute("MaxScale") :: number) or 1 -- pc size
	
	scales[scale] = Vector2.new(minSize, maxSize)
	
	-- initial update
	scale.Scale = math.map(currentAlpha, 0, 1, minSize, maxSize)
	
	return function()
		scales[scale] = nil
	end
end

local function update()
	local viewportSize = camera.ViewportSize.Y
	currentAlpha = getAlpha(viewportSize)
	
	for scale, sizes in scales do
		local minSize, maxSize = sizes.X, sizes.Y
		scale.Scale = math.map(currentAlpha, 0, 1, minSize, maxSize)
	end
end

if RunService:IsClient() then
	local cleanup: {[Instance]: () -> ()} = {}

	local function added(instance: UIScale)
		if not instance:IsA("UIScale") then return end
		if not instance:IsDescendantOf(game) then return end
		cleanup[instance] = scaleAdded(instance)
	end

	local function clean(instance: Instance)
		local cleanupFunction = cleanup[instance]
		cleanup[instance] = nil

		if cleanupFunction then
			cleanupFunction()
		end
	end

	CollectionService:GetInstanceRemovedSignal(TAG):Connect(clean)
	CollectionService:GetInstanceAddedSignal(TAG):Connect(added :: any)
	for _, v in CollectionService:GetTagged(TAG) do
		task.spawn(added, v)
	end
	
	camera:GetPropertyChangedSignal("ViewportSize"):Connect(update)
	update()
end

return nil
