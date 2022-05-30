local HeroSellDebrisCell = class("HeroSellDebrisCell", function()
	display.addSpriteFramesWithFile("ui/ui_submap.plist", "ui/ui_submap.png")
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	return CCTableViewCell:new()
end)

function HeroSellDebrisCell:getContentSize()
	local sprite = display.newSprite("#herolist_board.png")
	return sprite:getContentSize()
end

function HeroSellDebrisCell:refresh(id)
end

function HeroSellDebrisCell:create(param)
	local _id = param.id
	local _viewSize = param.viewSize
	self.cellIndex = _id
	local itemId = param.itemId
	self.curNum = param.curNum
	self.bg = display.newSprite("#herolist_board.png")
	self:addChild(self.bg)
	self.bg:setPosition(_viewSize.width / 2, self.bg:getContentSize().height / 2)
	local _height = self.bg:getContentSize().height
	local _width = self.bg:getContentSize().width
	local createDiaoLuoLayer = param.createDiaoLuoLayer
	local hechengFunc = param.hechengFunc
	local itemId = param.itemId
	self.cellIndex = cellIndex
	local data_item_item = require("data.data_item_item")
	local headName = "equip/icon/" .. data_item_item[itemId].icon .. ".png"
	local nameStr = data_item_item[itemId].name
	self.limitNum = data_item_item[itemId].para1
	local headIcon = display.newSprite(headName)
	headIcon:setPosition(headIcon:getContentSize().width / 2, self:getContentSize().height * 0.6)
	self.bg:addChild(headIcon)
	local debrisName = ui.newTTFLabel({
	x = headIcon:getContentSize().width * 0.5,
	y = self:getContentSize().height * 0.8,
	align = ui.TEXT_ALIGN_LEFT,
	text = nameStr,
	font = "Baoli",
	color = FONT_COLOR.PURPLE,
	size = 32
	})
	debrisName:setAnchorPoint(cc.p(0, 0.5))
	self.bg:addChild(debrisName)
	local jinduNode = display.newNode()
	self.bg:addChild(jinduNode)
	local jinduBg = display.newSprite("#submap_text_bg.png", x, y)
	jinduBg:setPosition(_width * 0.4, _height * 0.4)
	jinduBg:setScaleX(0.7)
	jinduNode:addChild(jinduBg)
	local jinduLable = ui.newTTFLabel({
	text = common:getLanguageString("@Quantity"),
	size = 24
	})
	jinduLable:setPosition(jinduBg:getPositionX() - _width * 0.15, jinduBg:getPositionY())
	jinduNode:addChild(jinduLable)
	local jinduNum = ui.newTTFLabel({
	text = self.curNum,
	size = 22,
	color = FONT_COLOR.YELLOW
	})
	jinduNum:setPosition(jinduLable:getPositionX() + jinduLable:getContentSize().width * 0.7, jinduLable:getPositionY())
	jinduNode:addChild(jinduNum)
	local jinduTotal = ui.newTTFLabel({
	text = "/" .. self.limitNum,
	size = 22,
	color = FONT_COLOR.ORANGE
	})
	jinduTotal:setPosition(jinduNum:getPositionX() + jinduNum:getContentSize().width * 1.1, jinduLable:getPositionY())
	jinduTotal:setAnchorPoint(cc.p(0, 0.5))
	jinduNode:addChild(jinduTotal)
	return self
end

function HeroSellDebrisCell:beTouched()
end

function HeroSellDebrisCell:onExit()
end

function HeroSellDebrisCell:runEnterAnim()
end

return HeroSellDebrisCell