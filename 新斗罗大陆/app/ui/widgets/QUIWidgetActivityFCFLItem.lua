--
-- Author: Your Name
-- Date: 2015-07-16 10:26:55
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityFCFLItem = class("QUIWidgetActivityFCFLItem", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetActivityFCFLItem:ctor(options)
	local ccbFile = "ccb/Widget_Activity_client2.ccbi"
  
	QUIWidgetActivityFCFLItem.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityFCFLItem:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetActivityFCFLItem:setInfo(info)
	self._ccbOwner.node_btn2:setVisible(false)
	self._ccbOwner.node_btn_go:setVisible(false)
	self._ccbOwner.node_btn:setVisible(true)

	self._itemBoxs = {}
	self._info = info
	self._ccbOwner.tf_name:setString("累计登录"..info.need_day.."天")
	self._ccbOwner.tf_num:setString("进度："..info.loginDaysCount.."/"..info.need_day)
	self._ccbOwner.node_item:removeAllChildren()
	
	if not info.isComplete then
		if info.loginDaysCount >= info.need_day then
			-- 待领取
			self._state = 1
			makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
		else
			-- 未达成
			self._state = 0
			makeNodeFromNormalToGray(self._ccbOwner.node_btn)
		end
	else
		self._state = 3
		self._ccbOwner.node_btn:setVisible(false)
	end
	self._ccbOwner.sp_ishave:setVisible(info.isComplete)

	local yuan = info.rechargeAmount

    local token = yuan * info.token_feed_back
    local itembox1 = QUIWidgetItemsBox.new()
    itembox1:setScale(0.8)
    itembox1:setGoodsInfo(nil, ITEM_TYPE.TOKEN_MONEY, token)
    self._ccbOwner.node_item:addChild(itembox1)
    table.insert(self._itemBoxs, itembox1)

    local vipExp = yuan * info.vip_exp_feed_back
    local itembox2 = QUIWidgetItemsBox.new()
    itembox2:setScale(0.8)
    itembox2:setGoodsInfo(nil, ITEM_TYPE.VIP, vipExp)
    self._ccbOwner.node_item:addChild(itembox2)
    itembox2:setPositionX(100)
    table.insert(self._itemBoxs, itembox2)
end

function QUIWidgetActivityFCFLItem:getState()
	return self._state
end

function QUIWidgetActivityFCFLItem:getId()
	return self._info.id
end

function QUIWidgetActivityFCFLItem:getInfo()
	return self._info
end

function QUIWidgetActivityFCFLItem:registerItemBoxPrompt( index, list )
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v,nil, "showItemInfo")
	end
end

function QUIWidgetActivityFCFLItem:onEnter()
	self._isExit = true
end

function QUIWidgetActivityFCFLItem:onExit()
	self._isExit = nil
end

function QUIWidgetActivityFCFLItem:showItemInfo(x, y, itemBox, listView)
	app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
end

return QUIWidgetActivityFCFLItem