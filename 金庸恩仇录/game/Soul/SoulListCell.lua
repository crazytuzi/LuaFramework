local SoulListCell = class("SoulListCell", function(data)
	return display.newSprite("#herolist_board.png")
end)

function SoulListCell:ctor(cellIndex, data)
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	local bgWidth = self:getContentSize().width
	local bgHeight = self:getContentSize().height
	local createCollectLayer = data.createCollectLayer
	self.cellIndex = cellIndex
	self:setPosition(display.right + 227, 0)
	local headIcon = display.newSprite("#submap_icon.png")
	headIcon:setPosition(headIcon:getContentSize().width / 2, self:getContentSize().height * 0.6)
	headIcon:setScale(0.8)
	self:addChild(headIcon)
	local soulName = ui.newTTFLabel({
	x = headIcon:getContentSize().width * 0.1,
	y = self:getContentSize().height * 0.8,
	align = ui.TEXT_ALIGN_LEFT,
	text = data.name,
	font = "Baoli",
	color = FONT_COLOR.PURPLE,
	size = 32
	})
	soulName:setAnchorPoint(ccp(0, 0.5))
	self:addChild(soulName)
	local heroLv = ui.newTTFLabel({
	x = headIcon:getPositionX() - headIcon:getContentSize().width * 0.4,
	y = headIcon:getPositionY() - headIcon:getContentSize().height / 2,
	align = ui.TEXT_ALIGN_LEFT,
	text = "Lv:" .. data.lv,
	font = "Baoli",
	color = ccc3(255, 255, 0),
	size = 26
	})
	self:addChild(heroLv)
	local jinduNode = display.newNode()
	self:addChild(jinduNode)
	local jinduBg = display.newSprite("#submap_text_bg.png", x, y)
	jinduBg:setPosition(bgWidth * 0.4, bgHeight * 0.4)
	jinduBg:setScaleX(0.7)
	jinduNode:addChild(jinduBg)
	local jinduLable = ui.newTTFLabel({
	text = common:getLanguageString("@Quantity"),
	size = 24
	})
	jinduLable:setPosition(jinduBg:getPositionX() - bgWidth * 0.15, jinduBg:getPositionY())
	jinduNode:addChild(jinduLable)
	local jinduNum = ui.newTTFLabel({
	text = 18,
	size = 22,
	color = FONT_COLOR.YELLOW
	})
	jinduNum:setPosition(jinduLable:getPositionX() + jinduLable:getContentSize().width * 0.7, jinduLable:getPositionY())
	jinduNode:addChild(jinduNum)
	local jinduTotal = ui.newTTFLabel({
	text = "/" .. 30,
	size = 22,
	color = FONT_COLOR.ORANGE
	})
	jinduTotal:setPosition(jinduNum:getPositionX() + jinduNum:getContentSize().width * 1.1, jinduNum:getPositionY())
	jinduNode:addChild(jinduTotal)
	local jiqi = ui.newTTFLabel({
	text = common:getLanguageString("@weijiqi"),
	font = "Baoli",
	color = FONT_COLOR.LIGHT_ORANGE
	})
	jiqi:setAnchorPoint(ccp(0, 0.5))
	jiqi:setPosition(jinduTotal:getPositionX() + jinduTotal:getContentSize().width * 1, jinduTotal:getPositionY())
	jinduNode:addChild(jiqi)
	local chaKanTTF = ui.newTTFLabel({
	text = common:getLanguageString("@chakandl"),
	size = 26
	})
	local chaKanDiaoLuoBtn = require("utility.CommonButton").new({
	img = "#com_btn_large_red.png",
	font = chaKanTTF,
	listener = function(...)
		createCollectLayer()
	end
	})
	chaKanDiaoLuoBtn:setPosition(self:getContentSize().width * 0.65, bgHeight * 0.1)
	self:addChild(chaKanDiaoLuoBtn)
	for i = 1, data.star do
		local stars = display.newSprite("#f_win_star.png")
		stars:setPosition(self:getContentSize().width * 0.6 + 0.8 * (i - 1) * stars:getContentSize().width, self:getContentSize().height * 0.8)
		stars:setScale(0.8)
		self:addChild(stars)
	end
	self:runEnterAnim()
end

function SoulListCell:beTouched()
	dump(self.cellIndex)
end

function SoulListCell:onExit()
end

function SoulListCell:runEnterAnim()
	local delayTime = self.cellIndex * 0.15
	local sequence = transition.sequence({
	CCCallFuncN:create(function()
		self:setPosition(cc.p(self:getContentSize().width / 2 + display.width / 2, self:getPositionY()))
	end),
	CCDelayTime:create(delayTime),
	CCMoveBy:create(0.3, cc.p(-(self:getContentSize().width / 2 + display.width / 2), 0))
	})
	self:runAction(sequence)
end

return SoulListCell