--
-- Author: xurui
-- Date: 2016-08-09 15:27:53
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGemstonePiecePrompt = class("QUIWidgetGemstonePiecePrompt", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetGemstonePiecePrompt:ctor(options)
  	local ccbFile = "ccb/Dialog_SilverMine_Shopmessage.ccbi"
  	local callBacks = {}
  	QUIWidgetGemstonePiecePrompt.super.ctor(self, ccbFile, callBacks, options)

  	self._itemId = options.itemId
  	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(self._itemId)
	local info = remote.gemstone:getStoneCraftInfoByPieceId(tonumber(self._itemId))
	local gemstoneInfo = QStaticDatabase:sharedDatabase():getItemByID(info.item_id)

	local icon = QUIWidgetItemsBox.new()
	self._ccbOwner.node_icon:addChild(icon)
	icon:setGoodsInfo(self._itemId, ITEM_TYPE.ITEM, 0)

	for i=2,4 do
		self._ccbOwner["tf_suit_prop"..i]:setString("")
        self._ccbOwner["tf_name"..i]:setString("")
	end

	self._ccbOwner.tf_name:setString(itemConfig.name)
	self._ccbOwner.tf_dec:setString(itemConfig.description or "")
  	local needNum = info.component_num_1 or 0
	self._ccbOwner.tf_num:setString(remote.items:getItemsNumByID(self._itemId).."/"..needNum)

	local suits = remote.gemstone:getSuitByItemId(info.item_id)
	for index,suitInfo in ipairs(suits) do
		local icon = QUIWidgetGemstonesBox.new()
		self._ccbOwner["node_suit"..index]:addChild(icon)
        icon:setState(remote.gemstone.GEMSTONE_ICON)
        icon:setItemId(suitInfo.id)
        self._ccbOwner["tf_name"..index]:setString(suitInfo.name)
        icon:setNameVisible(false)
        icon:setIconScale(0.6)
	end

	local suitInfos = QStaticDatabase:sharedDatabase():getGemstoneSuitEffectBySuitId(gemstoneInfo.gemstone_set_index)
	self._ccbOwner.tf_suit_name:setString(suitInfos[1].name)
	local index = 1
	for i = 2, 4 do
		self._ccbOwner["tf_suit_prop"..i]:setString("【"..i.." 件效果】"..suitInfos[index].set_desc)
		index = index + 1
	end 
end

return QUIWidgetGemstonePiecePrompt