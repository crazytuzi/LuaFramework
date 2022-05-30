local COMMON_VIEW = 1
local SALE_VIEW = 2
local COLOR_GREEN = display.COLOR_GREEN

local JinJieCell = class("JinJieCell", function(param)
	return CCTableViewCell:new()
end)

function JinJieCell:getContentSize()
	return cc.size(95, 95)
end

function JinJieCell:create(param)
	self.itemIcon = display.newSprite()
	self:addChild(self.itemIcon)
	self.hasNum = ui.newTTFLabelWithOutline({
	text = "/99",
	size = 20,
	color = COLOR_GREEN,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	})
	self:addChild(self.hasNum, 10)
	
	self.need = ui.newTTFLabelWithOutline({
	text = "88",
	size = 20,
	color = COLOR_GREEN,
	outlineColor = display.COLOR_BLACK,
	font = FONTS_NAME.font_fzcy,
	})
	self:addChild(self.need, 10)
	
	self.data = param.listData
	self.viewSize = param.viewSize
	self:refresh(param.id + 1)
	return self
end

function JinJieCell:refresh(id)
	if self.data ~= nil then
		self.resId = self.data[id].id
		self.resType = self.data[id].t
		local itemType = ResMgr.ITEM
		if self.resType == 8 then
			itemType = ResMgr.HERO
		elseif self.resType == 4 then
			itemType = ResMgr.EQUIP
		elseif self.resType == 14 then
			itemType = ResMgr.PET
		elseif self.resType == ITEM_TYPE.cheats then
			itemType = ResMgr.CHEATS
		end
		ResMgr.refreshIcon({
		id = self.resId,
		itemBg = self.itemIcon,
		resType = itemType
		})
		self.itemIcon:setPosition(self.itemIcon:getContentSize().width / 2, self.viewSize.height / 2)
		local needStr = self.data[id].n1
		local hasNumStr = self.data[id].n2
		self.hasNum:setString(hasNumStr)
		self.need:setString("/" .. needStr)
		if needStr <= hasNumStr then
			self.hasNum:setColor(COLOR_GREEN)
		else
			self.hasNum:setColor(FONT_COLOR.RED)
		end
		self.need:setPosition(self:getContentSize().width - 15 - self.need:getContentSize().width / 2, self.need:getContentSize().height / 2 + 7)
		self.hasNum:setPosition(self.need:getPositionX() - self.need:getContentSize().width / 2 - self.hasNum:getContentSize().width / 2 - 5, self.need:getPositionY())
	end
end

function JinJieCell:tableCellTouched(x, y)
	local icon = self.itemIcon
	local size = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		local itemInfo = require("game.Huodong.ItemInformation").new({
		id = self.resId,
		type = self.resType
		})
		display.getRunningScene():addChild(itemInfo, 100000)
	end
end

function JinJieCell:runEnterAnim()
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

return JinJieCell