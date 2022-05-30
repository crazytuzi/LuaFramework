local TipLabel = class("TipLabel", function ()
	local tipLabelSprite = display.newScale9Sprite("ui_common/tip_bg2.png", 0, 0, CCSizeMake(0, 0))
	tipLabelSprite:setPosition(display.cx, display.cy)
	tipLabelSprite:setColor(cc.c3b(255, 255, 255))
	return tipLabelSprite
end)
function TipLabel:ctor(text, delayTime)
	local tipLabel = ui.newTTFLabel({
	text = text,
	align = ui.TEXT_ALIGN_CENTER,
	size = 22,
	x = self:getContentSize().width / 2,
	y = self:getContentSize().height / 2
	})
	self:addChild(tipLabel)
	local w = tipLabel:getContentSize().width * 1.3
	if w < display.width / 3 then
		w = display.width * 0.4
	end
	if w > display.width then
		w = display.width
	end
	self:setPreferredSize(CCSizeMake(w, tipLabel:getContentSize().height + 40))
	tipLabel:setPosition(self:getContentSize().width / 2, self:getContentSize().height / 2)
	local delayTime = delayTime or 2
	local action = transition.sequence({
	CCMoveBy:create(0.5, CCPointMake(0, CONFIG_SCREEN_HEIGHT / 6)),
	CCDelayTime:create(delayTime),
	CCFadeOut:create(2),
	CCRemoveSelf:create(true)
	})
	self:runAction(action)
end

return TipLabel