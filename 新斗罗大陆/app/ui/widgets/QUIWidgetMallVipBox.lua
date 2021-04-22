-- @Author: xurui
-- @Date:   2018-07-05 21:18:26
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-10-29 22:06:33
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetMallVipBox = class("QUIWidgetMallVipBox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QListView = import("...views.QListView")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QVIPUtil = import("...utils.QVIPUtil")

QUIWidgetMallVipBox.MALL_VIP_BOX_ICON_CLICK = "MALL_VIP_BOX_ICON_CLICK"

function QUIWidgetMallVipBox:ctor(options)
	local ccbFile = "ccb/Widget_shopVIP3.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerRcive", callback = handler(self, self._onTriggerRcive)},
		-- {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
    }
    QUIWidgetMallVipBox.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetMallVipBox:onEnter()
end

function QUIWidgetMallVipBox:onExit()
end

function QUIWidgetMallVipBox:setInfo(data, shopId, parentNode)
	self._info = data
	self._shopId = shopId
	self._awardsPanel = parentNode
	self._position = self._info.position
	self.maxCount = 1

	self._ccbOwner.tf_num:setString(string.format("VIP%s可购买", self._info.vipLevel))
	self._ccbOwner.tf_name:setString(string.format("VIP%s特权礼包", self._info.vipLevel))

	local itemMoney = (self._info.sale or 1) * self._info.cost
	self._ccbOwner.tf_token:setString(math.floor(itemMoney))

	self._ccbOwner.node_btn:setVisible(false)
	self._ccbOwner.node_btn2:setVisible(false)
	self._ccbOwner.alreadyTouch:setVisible(false)
	local currVipLevel = QVIPUtil:VIPLevel()
	if self._info.count == 0 then
		self._ccbOwner.alreadyTouch:setVisible(self._info.count == 0)
		self._ccbOwner.node_token:setVisible(false)
		self._ccbOwner.tf_num:setVisible(false)
	else
		local isCanBuy = self._info.count > 0 and currVipLevel >= self._info.vipLevel
		self._ccbOwner.node_btn:setVisible(isCanBuy)
		self._ccbOwner.node_btn2:setVisible(not isCanBuy)
		self._ccbOwner.tf_num:setVisible(not isCanBuy)
		self._ccbOwner.node_token:setVisible(isCanBuy)
	end

	local goodInfo = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(self._info.good_group_id)
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(goodInfo.id_1)
	self._items = string.split(itemInfo.content, ";")

	self:initListView()
end

function QUIWidgetMallVipBox:initListView( ... )
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._items[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item, data, index)

	            info.item = item
	            info.tag = data.oType
	            info.size = item._ccbOwner.parentNode:getContentSize()

	            --注册事件
                list:registerItemBoxPrompt(index, 1, item._itemBox)

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        multiItems = 2,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._items,

	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView,cfg)
	else
		self._listView:reload({totalNumber = #self._items})
	end 
end

function QUIWidgetMallVipBox:setItemInfo(item, data, index)
	if not item._itemBox then
		item._itemBox = QUIWidgetItemsBox.new()
		item._itemBox:setScale(0.8)
		item._itemBox:setPosition(ccp(75,40))
		item._ccbOwner.parentNode:addChild(item._itemBox)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(95,90))

	end
	local items = string.split(data, "^")
	local id = items[1]
	local count = tonumber(items[2])
	local itemType = remote.items:getItemType(id)
    if itemType == nil then
        itemType = ITEM_TYPE.ITEM
    end

	if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
		item._itemBox:setGoodsInfo(id, itemType, count)
	else
		item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)	
	end
end

function QUIWidgetMallVipBox:onTouchListView( event )	
	if not event then
		return
	end
	if event.name == "moved" then
		local contentListView = self._awardsPanel:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_H then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_V then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._awardsPanel:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end

function QUIWidgetMallVipBox:_onTriggerRcive( ... )
	self:dispatchEvent({name = QUIWidgetMallVipBox.MALL_VIP_BOX_ICON_CLICK, shopId = self._shopId, itemInfo = self._info, maxNum = self.maxCount, pos = self._position})
end

function QUIWidgetMallVipBox:_onTriggerGoto( ... )
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVIPRecharge"})
end

function QUIWidgetMallVipBox:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetMallVipBox
