--
-- Author: nzhang
-- Date: 2016-01-06 14:37:09
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLuckyDrawPreviewBox = class("QUIWidgetLuckyDrawPreviewBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetLuckyDrawPreviewBox:ctor(options)
	local ccbFile = "ccb/Widget_GiftPreview.ccbi"
	local callBack = {}
	QUIWidgetLuckyDrawPreviewBox.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetLuckyDrawPreviewBox:setItemBoxInfo(itemInfo)
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setPromptIsOpen(true)
	itemBox:setGoodsInfo(itemInfo.id, itemInfo.type, itemInfo.num)
	self._ccbOwner.node_icon:addChild(itemBox)

	if itemConfig ~= nil then
		self._ccbOwner.item_name:setString(itemConfig.name)
		self._ccbOwner.item_dec:setString(itemConfig.description)
	end

	local value = remote.items:getWalletByType(itemInfo.type)
	if value then
		self._ccbOwner.item_name:setString(value.nativeName)
		self._ccbOwner.item_dec:setString(value.description)
	elseif itemInfo.type == ITEM_TYPE.ITEM then
		local config = QStaticDatabase:sharedDatabase():getItemByID(itemInfo.id)
		self._ccbOwner.item_name:setString(config.name)
		self._ccbOwner.item_dec:setString(config.description)
	end
end	

function QUIWidgetLuckyDrawPreviewBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end	

return QUIWidgetLuckyDrawPreviewBox 