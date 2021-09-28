local MonsterBubble = class("MonsterBubble", function() return cc.Node:create() end)


function MonsterBubble:ctor(text, pos, fontSize)
    if fontSize == nil then
        fontSize = 14
    end

	local text_len = string.len(text)
	local imageFileBg = nil
	local textPosY = 0
	local showPos = pos
    local textPosX = 128
 --[[   if text_len <= 36 then
		imageFileBg = "res/chat/talkBubble_Min.png"
		textPosY = 91
		showPos.x = showPos.x + 54
		showPos.y = showPos.y + 56
        textPosX = 94
	else]]
    if text_len <= 144 then
		imageFileBg = "res/chat/talkBubble_Low.png"
		textPosY = 91
		showPos.x = showPos.x + 54
		showPos.y = showPos.y + 56
	else
		imageFileBg = "res/chat/talkBubble_High.png"
		textPosY = 112
		showPos.x = showPos.x - 54
		showPos.y = showPos.y + 56
	end

	self.bubbleBg = createSprite(self, imageFileBg, showPos, cc.p(0.5,0.0))
	self.bubbleBg:setOpacity(220)

	local richText = require("src/RichText").new(self.bubbleBg, cc.p(textPosX, textPosY-31), cc.size(230, 0), cc.p(0.5, 0.5), 20, fontSize, MColor.white)
	richText:setAutoWidth()
	richText:addText(text, cc.c3b(250, 250, 250), true)
	richText:format()


	log("[MonsterBubble:ctor] x = %d, y = %d.", showPos.x, showPos.y)
end


return MonsterBubble

