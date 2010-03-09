-- $Id: frame.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
-- These store the original values, so the frame can be 'reset'.
local original_frame = ""
local original_point = ""
local original_parent = ""
local original_parent_point = ""
local original_offset_x = 0
local original_offset_y = 0

-- These store the current values, used to re position the frame after changing settings.
local current_frame = ""
local current_point = "CENTER"
local current_parent = ""
local current_parent_point = "CENTER"
local current_offset_x = 0
local current_offset_y = 0

-- Dummy function, is "created" later, but is required to be a function at this point
-- :TODO:11:24 PM Saturday, January 23, 2010:Rc:  Perhaps do forward declaration of the objects instead of overwriting this function with the real one later?
local request_update = function() end

-- Create our GUI
local gui_frame = CreateFrame("Frame", "recToolFramePosition", UIParent)
gui_frame:RegisterEvent("PLAYER_ENTERING_WORLD")
gui_frame:SetScript("OnEvent", function(self, event)
gui_frame:SetWidth(280)
gui_frame:SetHeight(290)
gui_frame:SetPoint("CENTER")
gui_frame:SetFrameStrata("DIALOG")
gui_frame:EnableMouse(true)
gui_frame:SetMovable(true)
gui_frame:RegisterForDrag("LeftButton")
gui_frame:SetScript("OnDragStart", function(this) this:StartMoving() end)
gui_frame:SetScript("OnDragStop", function(this) this:StopMovingOrSizing() end)
table.insert(UISpecialFrames, gui_frame:GetName())

gui_frame.texture = gui_frame:CreateTexture(nil, "BACKGROUND")
gui_frame.texture:SetTexture(0,0,0,.5)
gui_frame.texture:SetAllPoints()

gui_frame.close_button = CreateFrame("Button", nil, gui_frame)
gui_frame.close_button:SetNormalTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Up.blp]])
gui_frame.close_button:SetPushedTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Down.blp]])
gui_frame.close_button:SetHighlightTexture([[Interface\Buttons\UI-Panel-MinimizeButton-Highlight.blp]])
gui_frame.close_button:SetWidth(30)
gui_frame.close_button:SetHeight(30)
gui_frame.close_button:SetPoint("TOPRIGHT")
gui_frame.close_button:SetScript("OnClick", function(this) this:GetParent():Hide() end)

-- Creates our sliders
local function make_slider(name, min_value, max_value, caption, value)
	local slider = CreateFrame("Slider", name, gui_frame, "OptionsSliderTemplate")
	slider:EnableMouseWheel(1)
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(min_value, max_value)
	slider:SetValueStep(0.5)
	slider:SetValue(value)
	slider:SetWidth(180)
	slider:SetHeight(16)
	getglobal(string.format("%sLow", name)):SetText(tostring(min_value))
	getglobal(string.format("%sHigh", name)):SetText(tostring(max_value))
	getglobal(string.format("%sText", name)):SetText(caption)
	slider:SetScript("OnValueChanged", function(this)
		if this:GetName() == "offset_x" then
			current_offset_x = this:GetValue()
			getglobal(string.format("%sText", name)):SetText(string.format("X Offset: %.1f", current_offset_x))
		else
			current_offset_y = this:GetValue()
			getglobal(string.format("%sText", name)):SetText(string.format("Y Offset: %.1f", current_offset_y))
		end
		request_update()
	end)
	slider:SetScript("OnMouseWheel", function(this, value)
		local min_value, max_value = this:GetMinMaxValues()
		-- Make sure min/max are within bounds
		if value > 0 then
			if ((this:GetName() == "offset_x") and ((current_offset_x + 0.5) <= max_value)) then
				current_offset_x = current_offset_x + 0.5
				this:SetValue(current_offset_x)
			elseif ((current_offset_y + 0.5) <= max_value) then
				current_offset_y = current_offset_y + 0.5
				this:SetValue(current_offset_y)
			else
				return	-- No update needed, value out of bounds.
			end
		elseif value < 0 then
			if ((this:GetName() == "offset_x") and ((current_offset_x - 0.5) >= min_value)) then
				current_offset_x = current_offset_x - 0.5
				this:SetValue(current_offset_x)
			elseif ((current_offset_y - 0.5) >= min_value) then
				current_offset_y = current_offset_y - 0.5
				this:SetValue(current_offset_y)
			else
				return	-- No update needed, value out of bounds.
			end
		end
	end)
	return slider
end

-- Generate width/height dynamically
local ui_scale = GetCVar("uiScale")
local screen_height = GetScreenHeight()
local screen_width = GetScreenWidth()
screen_height = math.ceil(screen_height / ui_scale)
screen_width = math.ceil(screen_width / ui_scale)

-- Add our offset sliders
gui_frame.offset_x = make_slider("offset_x", (screen_width * -1), screen_width, "X Offset", 0)
gui_frame.offset_x:SetPoint("BOTTOM", 0, 50)
gui_frame.offset_y = make_slider("offset_y", (screen_height * -1), screen_height, "Y Offset", 0)
gui_frame.offset_y:SetPoint("BOTTOM", 0, 10)

-- Possible attachment points
local points = {
	"TOPLEFT",
	"TOP",
	"TOPRIGHT",
	"LEFT",
	"CENTER",
	"RIGHT",
	"BOTTOMLEFT",
	"BOTTOM",
	"BOTTOMRIGHT"
}

-- Dropdown helper functions
local onclick = function(self)
	UIDropDownMenu_SetSelectedValue(self.owner, self.value)
	if self.owner:GetName() == "parent_point" then
		current_parent_point = self.value
	else
		current_point = self.value
	end
	request_update()
end
local initialize_dropdown = function(self)
	UIDropDownMenu_SetWidth(self, 200, 0)
	UIDropDownMenu_SetSelectedValue(self, nil)
	local info = UIDropDownMenu_CreateInfo()
	info.owner = self:GetParent()
	info.func = self.OnClick
	for _, point in pairs(points) do
		info.text = point
		info.value = point
		info.owner = self
		UIDropDownMenu_AddButton(info, 1)
	end
	UIDropDownMenu_SetText(self, "<Change Point>")
end

-- Dropdown for attach point
gui_frame.frame_point = CreateFrame("Frame", "frame_point", gui_frame, "UIDropDownMenuTemplate")
gui_frame.frame_point.OnClick = onclick
gui_frame.frame_point.Initialize = initialize_dropdown
UIDropDownMenu_Initialize(gui_frame.frame_point, gui_frame.frame_point.Initialize)
gui_frame.frame_point:SetPoint("BOTTOM", -20, 150)

-- Dropdown for parent attach point
gui_frame.parent_point = CreateFrame("Frame", "parent_point", gui_frame, "UIDropDownMenuTemplate")
gui_frame.parent_point.OnClick = onclick
gui_frame.parent_point.Initialize = initialize_dropdown
UIDropDownMenu_Initialize(gui_frame.parent_point, gui_frame.parent_point.Initialize)
gui_frame.parent_point:SetPoint("BOTTOM", -20, 100)

-- Creates an edit box.
local function make_editbox(name, caption, func)
	local editbox = CreateFrame("EditBox", name, gui_frame, "InputBoxTemplate")
	editbox:SetHeight(10)
	editbox:SetWidth(200)
	editbox:SetAutoFocus(false)
	editbox:SetText(caption)
	editbox:SetScript("OnEscapePressed", function(this) this:ClearFocus() end)
	editbox:SetScript("OnEnterPressed", function(this) func.onenter(this); this:ClearFocus() end)
	return editbox
end

-- Make an edit box for the frame to work with
gui_frame.frame_name = make_editbox("frame_name", "<Set working frame>", {
	onenter= function(this)
		local name = this:GetText()
		-- :TODO:1/23/2010 7:22:48 PM:Rc: Handle bad names better. Clear edit box.
		if name == "" then return end
		if not _G[name] then return end
		-- Make a current copy of the settings.
		current_frame = name
		current_point, current_parent, current_parent_point, current_offset_x, current_offset_y = _G[name]:GetPoint()
		-- Store original settings so that things can be restored later.
		original_point, original_parent, original_parent_point, original_offset_x, original_offset_y = _G[name]:GetPoint()
		gui_frame.offset_x:SetValue(current_offset_x)
		gui_frame.offset_y:SetValue(current_offset_y)
		request_update()
	end
})
gui_frame.frame_name:SetPoint("BOTTOM", 0, 225)

-- Make an edit box for the working frame's parent.
gui_frame.parent_frame_name = make_editbox("parent_frame_name", "<Set parent frame>", {
	onenter = function(this)
		local name = this:GetText()
		-- :TODO:1/23/2010 7:22:48 PM:Rc: Handle bad names better. Clear edit box.
		if name == "" then return end
		if not _G[name] then return end
		current_parent = name
		gui_frame.offset_x:SetValue(0)
		gui_frame.offset_y:SetValue(0)
		current_offset_x = 0
		current_offset_y = 0
		current_point = "CENTER"
		current_parent_point = "CENTER"
		request_update()
	end
})
gui_frame.parent_frame_name:SetPoint("BOTTOM", 0, 200)

-- Make an edit box for the code output
gui_frame.code_output = make_editbox("code_output", "<Code Output>", {onenter = function() end})
gui_frame.code_output:SetPoint("BOTTOM", 0, 250)

local function reset_frame()
	-- :TODO:2:35 AM Sunday, January 24, 2010:Rc:  Need to complete this function.  Will need a button to reset things.
	-- Reset the current frame using original_* data.
end

request_update = function()
	-- Make sure we have data
	if current_frame == "" or current_parent == "" or current_point == "" or current_parent_point == "" then return end
	
	-- Update parent edit box (needed if changing working frame)
	if type(current_parent) == "table" then
		current_parent = current_parent:GetName()
	end
	gui_frame.parent_frame_name:SetText(current_parent)
	
	-- Update point dropdowns
	UIDropDownMenu_SetSelectedValue(gui_frame.frame_point, current_point)
	UIDropDownMenu_SetSelectedValue(gui_frame.parent_point, current_parent_point)
	UIDropDownMenu_SetText(gui_frame.frame_point, current_point)
	UIDropDownMenu_SetText(gui_frame.parent_point, current_parent_point)
	
	-- Move frame to new settings
	_G[current_frame]:ClearAllPoints()
	_G[current_frame]:SetPoint(current_point, current_parent, current_parent_point, current_offset_x, current_offset_y)
	
	-- Debug text
	gui_frame.code_output:SetText(string.format("%s:SetPoint(\"%s\", %s, \"%s\", %.1f, %.1f)", current_frame, current_point, current_parent, current_parent_point, current_offset_x, current_offset_y))
end


SLASH_TOOLFRAMEPOSITIONING1 = '/tfp'
SlashCmdList.TOOLFRAMEPOSITIONING = function() gui_frame:Show() end
gui_frame:Hide()
end)