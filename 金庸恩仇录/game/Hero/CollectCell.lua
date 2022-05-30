local CollectCell = class("CollectCell", function(param)
	display.addSpriteFramesWithFile("ui/ui_herolist.plist", "ui/ui_herolist.png")
	return display.newSprite("#herolist_board_mini.png")
end)

function CollectCell:ctor(param)
	dump(param)
	self.cellIndex = param.cellIndex
	local bgWidth = self:getContentSize().width
	local bgHeight = self:getContentSize().height
	local goTTF = display.newScale9Sprite("#herolist_go.png", bgWidth * 0.7, bgHeight * 0.5, size)
	self:addChild(goTTF)
	local levelBg = display.newSprite("#submap_text_bg.png", bgWidth * 0.02, bgHeight * 0.6)
	levelBg:setScaleX(0.44)
	levelBg:setScaleY(1.25)
	levelBg:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(levelBg)
	local lvlName = ui.newTTFLabel({
	text = param.name,
	size = 22,
	color = FONT_COLOR.YELLOW
	})
	lvlName:setAnchorPoint(cc.p(0, 0.5))
	lvlName:setPosition(bgWidth * 0.04, bgHeight * 0.7)
	self:addChild(lvlName)
	local locaName = ui.newTTFLabel({
	text = common:getLanguageString("@CheckPoint") .. param.fieldName,
	size = 18,
	color = FONT_COLOR.LIGHT_ORANGE
	})
	locaName:setAnchorPoint(cc.p(0, 0.5))
	locaName:setPosition(bgWidth * 0.04, bgHeight * 0.4)
	self:addChild(locaName)
	self:runEnterAnim()
end

function CollectCell:beTouched()
	dump(self.cellIndex)
end

function CollectCell:runEnterAnim()
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
	CCCallFuncN:create(function()
		self:setPosition(CCPoint(self:getContentSize().width / 2 + display.width / 2, self:getPositionY()))
	end),
	CCDelayTime:create(delayTime),
	CCMoveBy:create(0.3, CCPoint(-(self:getContentSize().width / 2 + display.width / 2), 0))
	})
	self:runAction(sequence)
end

return CollectCell