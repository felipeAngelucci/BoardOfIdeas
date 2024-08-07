-- LocalScript for Sticky Note GUI

local player = game.Players.LocalPlayer
local screenGui = script.Parent
local noteFrame = screenGui:WaitForChild("NoteFrame")
local textBox = noteFrame:WaitForChild("TextBox")
local confirmButton = noteFrame:WaitForChild("ConfirmButton")
local cancelButton = noteFrame:WaitForChild("CancelButton")

local tool = player.Backpack:WaitForChild("StickyNote")

local tempStickyNote -- Variable to hold reference to the temporary sticky note being created
local ghostNote -- Reference to the ghost sticky note
local clickPosition -- Variable to hold the position where the note will be placed

local function hideGhostNote()
	if ghostNote then
		ghostNote:Destroy() -- Removes the ghost note
		ghostNote = nil
	end
end

local function createStickyNote(position, noteText)
	local stickyNoteModel = game.ReplicatedStorage:WaitForChild("StickyNoteModel"):Clone()
	stickyNoteModel.Position = position
	stickyNoteModel.Parent = workspace

	local surfaceGui = stickyNoteModel:FindFirstChild("SurfaceGui")
	if surfaceGui then
		local textLabel = surfaceGui:FindFirstChild("TextLabel") 
		if textLabel then
			textLabel.Text = noteText -- Sets the text of the sticky note
		end
	end

	return stickyNoteModel
end

local function onConfirmButtonClicked()
	local noteText = textBox.Text
	if noteText and noteText ~= "" and clickPosition then
		-- Create and place the sticky note
		local placedStickyNote = createStickyNote(clickPosition, noteText)
		noteFrame.Visible = false -- Close the note frame after confirming
		textBox.Text = "" -- Clear the text box
		hideGhostNote() -- Hide the ghost note when done
		tempStickyNote = nil -- Reset the temporary sticky note reference
	end
end

local function onCancelButtonClicked()
	if tempStickyNote then
		tempStickyNote:Destroy() -- Remove only the temporary sticky note if it exists
	end
	noteFrame.Visible = false -- Hides the note frame
	textBox.Text = "" -- Clears the text box
	hideGhostNote() -- Hides the ghost note when canceled
end

local function showNoteFrame(position)
	noteFrame.Visible = true -- Shows the note frame
	textBox.Visible = true -- Shows the TextBox
	confirmButton.Visible = true -- Shows the ConfirmButton
	cancelButton.Visible = true -- Shows the CancelButton
	clickPosition = position -- Stores the position where the sticky note will be placed
	tempStickyNote = createStickyNote(position, "") -- Creates a temporary sticky note with no text
	hideGhostNote() -- Hides the ghost note when editing
end

tool.Activated:Connect(function()
	if not noteFrame.Visible then -- Checks if the note frame is already visible
		local mouse = player:GetMouse()
		local target = mouse.Target

		if target then
			local targetPosition = mouse.Hit.Position + Vector3.new(0, 1, 0) -- Adjusts Y to position above the surface
			showNoteFrame(targetPosition) -- Shows the note frame with the position
		end
	end
end)

confirmButton.MouseButton1Click:Connect(onConfirmButtonClicked) -- Connects the confirm button click
cancelButton.MouseButton1Click:Connect(onCancelButtonClicked) -- Connects the cancel button click
