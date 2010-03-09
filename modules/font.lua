-- $Id: font.lua 550 2010-03-02 15:27:53Z john.d.mann@gmail.com $
--local font = "Interface\\AddOns\\recMedia\\fonts\\Oceania-Medium.ttf"

local fonts = {}

local font_frame = CreateFrame("Frame")
font_frame:SetFrameStrata("TOOLTIP")
font_frame:SetWidth(900)
font_frame:SetHeight(600)
font_frame.bbg = font_frame:CreateTexture(nil, "BACKGROUND")
font_frame.bbg:SetTexture(0,0,0,1)
font_frame.bbg:SetPoint("TOPLEFT")
font_frame.bbg:SetPoint("TOPRIGHT")
font_frame.bbg:SetHeight(300)
font_frame.wbg = font_frame:CreateTexture(nil, "BACKGROUND")
font_frame.wbg:SetTexture(1, 1, 1, 1)
font_frame.wbg:SetPoint("BOTTOMLEFT")
font_frame.wbg:SetPoint("BOTTOMRIGHT")
font_frame.wbg:SetHeight(300)
font_frame:SetPoint("CENTER")
font_frame:Hide()

-- Create and position fonts
for i = 1, 40 do
	fonts[i] = font_frame:CreateFontString(string.format("recToolsFont%d", i), "OVERLAY")
	
	if i <= 20 then
		fonts[i]:SetPoint("TOPLEFT", i == 1 and font_frame or fonts[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, 0)
	else
		fonts[i]:SetPoint("TOPLEFT", i == 21 and font_frame or fonts[i-1], i == 21 and "TOPLEFT" or "BOTTOMLEFT", 0, i == 21 and -300 or 0)
	end
end

-- Set font face
function set_font(font)
	for i = 1, 40 do
		if i <= 20 then
			fonts[i]:SetFont(font, i)
			fonts[i]:SetText(i.." The quick brown fox jumps over the lazy dog.")
		else
			fonts[i]:SetFont(font, i-20, "OUTLINE")
			fonts[i]:SetText((i-20).." The quick brown fox jumps over the lazy dog.")
		end
	end
end

SLASH_REC_TOOL_FONT1 = "/rtf"
SlashCmdList["REC_TOOL_FONT"] = function(cmd)
	if cmd and cmd ~= "" then
		set_font(cmd)
		font_frame:Show()
	else
		font_frame:Hide()
	end
end