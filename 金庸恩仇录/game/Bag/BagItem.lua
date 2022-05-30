local data_item_item = require("data.data_item_item")

local BagItem = class("BagItem", function()
	return CCTableViewCell:new()
end)

function BagItem:getContentSize()
	return cc.size(display.width * 0.98, 158)
end

local ITEM_TYPE_USE = 1
local ITEM_TYPE_SALE = 2

function BagItem:setItemType(t)
	self._itemType = t
end

function BagItem:create(param)
	local _viewSize = param.viewSize
	self._useListener = param.useListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("bag/bag_object_item.ccbi", proxy, self._rootnode)
	node:setPosition(_viewSize.width / 2, self._rootnode.itemBg:getContentSize().height / 2)
	self:addChild(node, 0)
	self.typeNode = display.newNode()
	node:addChild(self.typeNode)
	
	--สนำร
	self._rootnode.useBtn:addHandleOfControlEvent(function()
		if self._useListener then
			self._useListener(self, 1)
		end
	end,
	CCControlEventTouchUpInside)
	
	self._itemData = param.itemData
	self.itemName = ui.newTTFLabelWithShadow({
	text = "",
	font = FONTS_NAME.font_fzcy,
	size = 24,
	color = NAME_COLOR[data_item_item[self._itemData.itemId].quality],
	shadowColor = display.COLOR_BLACK,
	})
	self._rootnode.itemNameLabel:addChild(self.itemName)
	self:refresh(param)
	return self
end

function BagItem:touch(bChoose)
	if bChoose then
		self._rootnode.itemSelectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_selected.png"))
	else
		self._rootnode.itemSelectedSprite:setDisplayFrame(display.newSpriteFrame("item_board_unselected.png"))
	end
end

function BagItem:tableCellTouched(x, y)
	local icon = self._rootnode["iconSprite"]
	local size = icon:getContentSize()
	if cc.rectContainsPoint(cc.rect(0, 0, size.width, size.height), icon:convertToNodeSpace(cc.p(x, y))) then
		if  self._useListener then
			self._useListener(self, 2)
		end
	end
end

function BagItem:refresh(param)
	local _itemType = param.itemType
	self._itemData = param.itemData
	if data_item_item[param.itemData.itemId].type ~= 7 and data_item_item[param.itemData.itemId].type ~= 11 then
		self._rootnode.useBtn:setVisible(false)
	else
		self._rootnode.useBtn:setVisible(true)
	end
	if _itemType == ITEM_TYPE_SALE then
		self._rootnode.useView:setVisible(false)
		self._rootnode.saleView:setVisible(true)
		self._rootnode.silverLabel:setString(tostring(data_item_item[self._itemData.itemId].price))
		self:touch(param.bChoose)
	else
		self._rootnode.useView:setVisible(true)
		self._rootnode.saleView:setVisible(false)
	end
	
	ResMgr.refreshIcon({
	itemBg = self._rootnode.iconSprite,
	id = self._itemData.itemId,
	resType = ResMgr.ITEM
	})
	
	self._rootnode.countLabel:setString(common:getLanguageString("@Count", tostring(self._itemData.itemCnt)))
	self.itemName:setString(data_item_item[self._itemData.itemId].name)
	self._rootnode.descLabel:setString(data_item_item[self._itemData.itemId].describe)
	
	self.itemName:setPosition(self.itemName:getContentSize().width / 2, 0)
	self.itemName:setColor(NAME_COLOR[data_item_item[self._itemData.itemId].quality])
end

return BagItem