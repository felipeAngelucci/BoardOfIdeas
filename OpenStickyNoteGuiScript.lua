-- LocalScript for Opening the Sticky Note GUI

local openNoteFrame = script.Parent -- Reference to the GUI
local closeButton = openNoteFrame:WaitForChild("CloseButton") -- Reference to the close button
local noteTextLabel = openNoteFrame:WaitForChild("TextLabel") -- Reference to the TextLabel that will show the note's contents

-- Function to open the GUI and set the note text
local function openNoteGUI(noteText)
	openNoteFrame.Visible = true -- Show the note frame
	noteTextLabel.Text = noteText -- Set the note text in the GUI
end

-- Function to connect the ClickDetector to the openNoteGUI function
local function setupClickDetector(stickyNote)
	local clickDetector = stickyNote:FindFirstChild("ClickDetector")
	if clickDetector then
		clickDetector.MouseClick:Connect(function(player)
			local surfaceGui = stickyNote:FindFirstChild("SurfaceGui") -- Find the SurfaceGui in the sticky note
			if surfaceGui then
				local textLabel = surfaceGui:FindFirstChild("TextLabel") -- Find the TextLabel in the SurfaceGui
				if textLabel then
					openNoteGUI(textLabel.Text) -- Open the GUI with the text from the sticky note
				end
			end
		end)
	end
end

-- Set up the click detectors for existing StickyNoteModels in workspace
local function setupClickDetectors()
	for _, child in ipairs(workspace:GetChildren()) do
		if child:IsA("Part") and child.Name == "StickyNoteModel" then -- Check if it's a sticky note
			setupClickDetector(child)
		end
	end
end

-- Set up the click detectors initially
setupClickDetectors()

-- Hide the GUI when the close button is clicked
closeButton.MouseButton1Click:Connect(function()
	openNoteFrame.Visible = false
end)

-- Update the setupClickDetectors function to work with new notes
workspace.ChildAdded:Connect(function(child)
	if child:IsA("Part") and child.Name == "StickyNoteModel" then -- Ensure it's the correct model
		setupClickDetector(child)
	end
end)
