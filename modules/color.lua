-- $Id: color.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local function update_text(self)
	self.lbl:SetText(string.format("%.2f  %.2f  %.2f", self.bg.r, self.bg.g, self.bg.b))
end

local color_frame = CreateFrame("Button")
color_frame:SetWidth(50)
color_frame:SetHeight(50)
color_frame.bg = color_frame:CreateTexture(nil, "BACKGROUND")
color_frame.bg.r = 1
color_frame.bg.g = 1
color_frame.bg.b = 1
color_frame.bg.a = 1
color_frame.bg:SetTexture(1, 1, 1, 1)
color_frame.bg:SetAllPoints()
color_frame.lbl = color_frame:CreateFontString(nil, "BACKGROUND")
color_frame.lbl:SetPoint("BOTTOM", color_frame, "TOP", 0, 5)
color_frame.lbl:SetFont(recMedia.fontFace.NORMAL, recMedia.fontSize.NORMAL, recMedia.fontFlag.OUTLINE)
color_frame:SetPoint("CENTER")
color_frame:SetScript("OnClick", function(self, button)
	ColorPickerFrame:EnableKeyboard(false)
	ColorPickerFrame:RegisterForDrag("LeftButton")
	ColorPickerFrame:SetScript("OnDragStart", function(self) if not IsShiftKeyDown() then return end self:StartMoving() end)
	ColorPickerFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
	ColorPickerFrame.hasOpacity = self.bg.a
	ColorPickerFrame.previousValues = self.bg.r, self.bg.g, self.bg.b
	ColorPickerFrame.opacity = 1 - self.bg.a
	ColorPickerFrame:SetColorRGB(self.bg.r, self.bg.g, self.bg.b)
	ColorPickerFrame.func = function()
		color_frame.bg:SetTexture(ColorPickerFrame:GetColorRGB())
		color_frame.bg.r, color_frame.bg.g, color_frame.bg.b = ColorPickerFrame:GetColorRGB()
		update_text(color_frame)
	end
	ColorPickerFrame.cancelFunc = function(values)
	end
	ColorPickerFrame.opacityFunc = function()
	end
	color_frame.bg:SetTexture(color_frame.bg.r, color_frame.bg.g, color_frame.bg.b, color_frame.bg.a)
	ColorPickerFrame:Show()
end)
color_frame:Hide()
SLASH_REC_TOOL_COLORS1 = "/rtc"
SlashCmdList["REC_TOOL_COLORS"] = function()
	if color_frame:IsShown() then
		color_frame:Hide()
	else
		color_frame:Show()
	end
end