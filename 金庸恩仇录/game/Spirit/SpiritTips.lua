local SpiritTips = class("SpiritTips", function ()
	local tipLabelSprite = display.newScale9Sprite("ui_common/tip_bg2.png", 0, 0, CCSizeMake(0, 0))
	tipLabelSprite:setPosition(display.cx, display.cy)
	tipLabelSprite:setColor(cc.c3b(255, 255, 255))
	return tipLabelSprite
end)

function SpiritTips:ctor(num)
	local tipLabel = ui.newTTFLabel({
	text = common:getLanguageString("@tipEXPtoIten1", num),
	align = ui.TEXT_ALIGN_CENTER,
	size = 22,
	x = self:getContentSize().width / 2,
	y = self:getContentSize().height / 2
	})
	tipLabel:setColor(cc.c3b(138, 43, 226))
	tipLabel:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(tipLabel)
	local tipLabel2 = ui.newTTFLabel({
	text = common:getLanguageString("@tipEXPtoIten2"),
	align = ui.TEXT_ALIGN_CENTER,
	size = 22,
	x = self:getContentSize().width / 2,
	y = self:getContentSize().height / 2
	})
	self:addChild(tipLabel2)
	local lblSize = tipLabel:getContentSize()
	local lblSize2 = tipLabel2:getContentSize()
	self:setPreferredSize(cc.size(lblSize.width + lblSize2.width + 100, tipLabel:getContentSize().height + 40))
	tipLabel:setPosition(cc.p(50, self:getContentSize().height / 2))
	tipLabel2:setPosition(cc.p(0, self:getContentSize().height / 2))
	alignNodesOneByOne(tipLabel, tipLabel2, 0)
	local delayTime = delayTime or 2
	local action = transition.sequence({
	CCMoveBy:create(0.5, CCPointMake(0, CONFIG_SCREEN_HEIGHT / 6)),
	CCDelayTime:create(delayTime),
	CCFadeOut:create(2),
	CCRemoveSelf:create(true)
	})
	self:runAction(action)
end

return SpiritTips