-- $Id: mouse_frames.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
local tool_frame_list_button = CreateFrame("Button", "tool_frame_list_button", UIParent)
tool_frame_list_button:SetScript("OnClick", function()
	local frame = EnumerateFrames()
	while frame do
		if frame:IsVisible() and MouseIsOver(frame) then
			print(frame:GetName())
		end
		frame = EnumerateFrames(frame)
	end
end)
tool_frame_list_button:SetScript("OnEvent", function()
	SetBindingClick("RIGHT", "tool_frame_list_button", "LeftButton")
end)
tool_frame_list_button:RegisterEvent("PLAYER_ENTERING_WORLD")