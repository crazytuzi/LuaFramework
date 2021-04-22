--
-- Author: xurui
-- Date: 2015-04-27 16:17:57
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMallVipPreviewBox = class("QUIWidgetMallVipPreviewBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetMallVipPreviewBox:ctor(options)
	local ccbFile = "ccb/Widget_GiftPreview.ccbi"
	local callBack = {}
	QUIWidgetMallVipPreviewBox.super.ctor(self, ccbFile, callBack, options)

	-- self._ccbOwner.item_name = setShadow5(self._ccbOwner.item_name)
end

function QUIWidgetMallVipPreviewBox:setItemBoxInfo(itemInfo)
	local itemConfig = {}
	local itemBox = QUIWidgetItemsBox.new()
	itemBox:setPromptIsOpen(true)

	local name = ""
	local itemType = ITEM_TYPE.ITEM
	if tonumber(itemInfo[1]) == nil then
		itemConfig = remote.items:getWalletByType(itemInfo[1])
		name = itemConfig.nativeName
		itemType = itemInfo[1]
	else
		itemConfig = QStaticDatabase:sharedDatabase():getItemByID(tonumber(itemInfo[1]))
		name = itemConfig.name
	end
	itemBox:setGoodsInfo(tonumber(itemInfo[1]), itemType, tonumber(itemInfo[2]))
	self._ccbOwner.node_icon:addChild(itemBox)

	if itemConfig ~= nil then
		self._ccbOwner.item_name:setString(name)
		self._ccbOwner.item_dec:setString(itemConfig.description)
		if itemConfig.colour ~= nil and remote.stores.itemQualityIndex[tonumber(itemConfig.colour)] ~= nil then
			local fontColor = BREAKTHROUGH_COLOR_LIGHT[remote.stores.itemQualityIndex[tonumber(itemConfig.colour)]]
			self._ccbOwner.item_name:setColor(fontColor)
			self._ccbOwner.item_name = setShadowByFontColor(self._ccbOwner.item_name, fontColor)
		end
	end
end	

function QUIWidgetMallVipPreviewBox:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end	

return QUIWidgetMallVipPreviewBox 