-- StickyNote Tool Script
-- Important: Ensure that the sticky note tool has "RequiresHandle" unchecked

local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local replicatedStorage = game:GetService("ReplicatedStorage")

local stickyNoteModel = replicatedStorage:WaitForChild("StickyNoteModel")
local ghostStickyNoteModel = replicatedStorage:WaitForChild("GhostStickyNoteModel")

local ghostNote
local lastPlacedTime = 0
local cooldownTime = 10 -- 10 second cooldown
local toolEquipped = false

local function isBoardSurface(target)
	return target and target:IsA("Part") and target.Name == "BoardSurface"
end

local function isTouchingEdge(targetPosition, targetSize)
	local touchingParts = workspace:FindPartsInRegion3(
		Region3.new(
			targetPosition - (targetSize / 2),
			targetPosition + (targetSize / 2)
		),
		nil,
		math.huge
	)
	for _, part in ipairs(touchingParts) do
		if part.Name == "Edge" then
			return true
		end
	end
	return false
end

local function isOverlapping(targetPosition, targetSize)
	local touchingParts = workspace:FindPartsInRegion3(
		Region3.new(
			targetPosition - (targetSize / 2),
			targetPosition + (targetSize / 2)
		),
		nil,
		math.huge
	)
	for _, part in ipairs(touchingParts) do
		if part.Name == "StickyNote" then
			return true
		end
	end
	return false
end

local function updateGhostNote(target, mouseHit)
	if not ghostNote then
		ghostNote = ghostStickyNoteModel:Clone()
		ghostNote.Parent = workspace
	end
	local ghostPosition = mouseHit.Position + Vector3.new(0, 0, 0.1)
	ghostNote.CFrame = CFrame.new(ghostPosition)
	local isOverlappingNote = isOverlapping(ghostPosition, ghostNote.Size)
	local isTouchingEdgeNote = isTouchingEdge(ghostPosition, ghostNote.Size)
	if isOverlappingNote or isTouchingEdgeNote then
		ghostNote.BrickColor = BrickColor.new("Bright red")
	else
		ghostNote.BrickColor = BrickColor.new("Bright green")
	end
	ghostNote.Transparency = 0.5
end

local function removeGhostNote()
	if ghostNote then
		ghostNote:Destroy()
		ghostNote = nil
	end
end

local function placeStickyNote(target, mouseHit)
	if not toolEquipped then
		return
	end

	local currentTime = tick()
	if currentTime - lastPlacedTime < cooldownTime then
		return
	end

	local stickyNotePosition = mouseHit.Position + Vector3.new(0, 0, 0.1)

	if isBoardSurface(target) and not isOverlapping(stickyNotePosition, stickyNoteModel.Size) and not isTouchingEdge(stickyNotePosition, stickyNoteModel.Size) then
		local newStickyNote = stickyNoteModel:Clone()
		newStickyNote.CFrame = CFrame.new(stickyNotePosition)
		newStickyNote.Parent = workspace
		newStickyNote.Name = "StickyNote"
		removeGhostNote()
		lastPlacedTime = currentTime
	end
end

tool.Equipped:Connect(function()
	toolEquipped = true
	mouse.Move:Connect(function()
		if toolEquipped then
			local target = mouse.Target
			if target and isBoardSurface(target) then
				updateGhostNote(target, mouse.Hit)
			else
				removeGhostNote()
			end
		end
	end)

	mouse.Button1Down:Connect(function()
		if toolEquipped then
			local target = mouse.Target
			if target then
				placeStickyNote(target, mouse.Hit)
			end
		end
	end)
end)

tool.Unequipped:Connect(function()
	removeGhostNote()
	toolEquipped = false
end)
