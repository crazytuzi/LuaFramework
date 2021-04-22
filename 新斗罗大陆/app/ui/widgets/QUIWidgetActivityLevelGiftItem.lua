--
-- Author: Your Name
-- Date: 2015-07-16 10:26:55
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityLevelGiftItem = class("QUIWidgetActivityLevelGiftItem", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetActivityLevelGiftItem:ctor(options)
	local ccbFile = "ccb/Widget_Activity_client2.ccbi"
  
	QUIWidgetActivityLevelGiftItem.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityLevelGiftItem:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetActivityLevelGiftItem:setInfo(info)
	self._ccbOwner.node_btn2:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.node_btn:setVisible(true)

	local level = remote.user.level
	self._itemBoxs = {}
	self._info = info
	self._ccbOwner.tf_name:setString("战队等级达到"..(info.value or 0).."级")
	self._ccbOwner.tf_num:setString("我的等级"..level.."/"..(info.value or 0))
	self._ccbOwner.sp_ishave:setVisible(false)
	self._ccbOwner.notTouch:setVisible(false)
	self._ccbOwner.sp_time_out:setVisible(false)
	self._ccbOwner.alreadyTouch:setVisible(false)
	if info.completeNum == 2 then
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	elseif info.completeNum == 1 then
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	else
		self._ccbOwner.node_btn:setVisible(false)
		self._ccbOwner.sp_ishave:setVisible(true)
	end

	self._ccbOwner.node_item:removeAllChildren()
	local awards = remote.items:analysisServerItem(info.awards)
	for index, award in ipairs(awards) do
		local itemBox = QUIWidgetItemsBox.new()
		itemBox:setScale(0.8)
		itemBox:setGoodsInfo(award.id, award.typeName, award.count)
		itemBox:setPositionX((index-1) * 80)
		self._ccbOwner.node_item:addChild(itemBox)
		table.insert(self._itemBoxs, itemBox)
	end

	self._awards = awards
end

function QUIWidgetActivityLevelGiftItem:getAwards()
	return self._awards
end

function QUIWidgetActivityLevelGiftItem:getInfo()
	return self._info
end

function QUIWidgetActivityLevelGiftItem:registerItemBoxPrompt( index, list )
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v,nil, "showItemInfo")
	end
end

function QUIWidgetActivityLevelGiftItem:onEnter()
	self._isExit = true
end

function QUIWidgetActivityLevelGiftItem:onExit()
	self._isExit = nil
end

function QUIWidgetActivityLevelGiftItem:showItemInfo(x, y, itemBox, listView)
	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
end

return QUIWidgetActivityLevelGiftItem