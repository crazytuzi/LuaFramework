-- @Author: liaoxianbo
-- @Date:   2019-06-03 15:42:51
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-01 15:36:32
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityMzlbCell = class("QUIWidgetActivityMzlbCell", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetActivityMzlbCell.UPDATE_BUYSTATE = "UPDATE_BUYSTATE"

function QUIWidgetActivityMzlbCell:ctor(options)
	local ccbFile = "ccb/Widget_Activity_mzlb_client.ccbi"
    local callBacks = {
		-- {ccbCallbackName = "onTriggerBuy", callback = handler(self, self._onTriggerBuy)},
    }
    QUIWidgetActivityMzlbCell.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

--describe：setInfo 
function QUIWidgetActivityMzlbCell:setInfo(info,widgetActivityMzlb)

	self._widgetActivityMzlb = widgetActivityMzlb
	self._info = info

	self._ccbOwner.tf_name:setString(self._info.description or "")
	local buyTimeStr = string.format("可购买：%s次",self._info.exchange_number)
	self._ccbOwner.tf_num:setString(buyTimeStr)
	self._data = {}					-- 所有道具
	self._exchangeItems = {}		-- 购买
	self.awards = {}				-- 奖励
	-- table.insert(self._data, {oType = "item", id = self._info.resource_1, count = self._info.resource_number_1,isNotAwawd = true})
	table.insert(self._exchangeItems, {oType = "item", id = self._info.resource_1, count = self._info.resource_number_1})
	-- 等号分隔
	table.insert(self._exchangeItems, {oType = "separate", id = "ui/Activity_game/yellow_denghao.png"})

	local items = string.split(self._info.awards, ";") 
	local count = #items
	for i=1,count,1 do
		local obj = string.split(items[i], "^")
	    if #obj == 2 then
	    	table.insert(self._data, {oType = "item", id = obj[1], count = obj[2]})
	    	local typeName = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
	    	table.insert(self.awards, {id = obj[1], typeName = typeName, count = tonumber(obj[2])})
	    end
	end

	self._ccbOwner.node_dazhe:removeAllChildren()
	if self._info.discount_view then
		local ccbProxy = CCBProxy:create()
        local ccbOwner = {}
        local dazheWidget = CCBuilderReaderLoad("Widget_dazhe.ccbi", ccbProxy, ccbOwner)
        ccbOwner.chengDisCountBg:setVisible(false)
        ccbOwner.lanDisCountBg:setVisible(false)
        ccbOwner.ziDisCountBg:setVisible(false)
        ccbOwner.hongDisCountBg:setVisible(true)
        if self._info.discount_view >= 1 and self._info.discount_view < 10 then
        	ccbOwner.discountStr:setString(self._info.discount_view.."折")
    	elseif self._info.discount_view == 11 then
        	ccbOwner.discountStr:setString("限时")
        elseif self._info.discount_view == 12 then
        	ccbOwner.discountStr:setString("火热")
        elseif self._info.discount_view == 13 then
        	ccbOwner.discountStr:setString("推荐")
        end
        self._ccbOwner.node_dazhe:addChild(dazheWidget)
	end

	self._ccbOwner.node_item:removeAllChildren()
	self._itemBox = nil

	self:initShortListView()

	self:checkCanBeBuy()

end
function QUIWidgetActivityMzlbCell:checkCanBeBuy()
	self._weekRecord = remote.activityVipGift:getWeekRecord()
	local notBuy = false
	for _,value in pairs(self._weekRecord) do
		if tonumber(self._info.id) == tonumber(value.id) then
			local lastBuyTime = tonumber(self._info.exchange_number) - tonumber(value.count) 
			local buyTimeStr = string.format("可购买：%s次",lastBuyTime)
			self._ccbOwner.tf_num:setString(buyTimeStr)
			if lastBuyTime <= 0 then
				notBuy = true
			end
			break
		end
	end
	self:updateBuyState(notBuy)
end

function QUIWidgetActivityMzlbCell:updateBuyState(notBuy)
	self._ccbOwner.node_btn:setVisible(not notBuy)
	self._ccbOwner.sp_yigoumai:setVisible(notBuy)
end

function QUIWidgetActivityMzlbCell:initShortListView()
	-- 拥有材料滑动
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, false)
		end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._data[index]

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end
	            self:setItemInfo(item,data,index)

	            info.item = item
	            info.tag = data.oType
	            info.size = item._ccbOwner.parentNode:getContentSize()
	            --注册事件
	            if data.oType == "item" then
                	list:registerItemBoxPrompt(index, 1, item._itemBox, nil, showItemInfo)
	           	end

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._data,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end

	local nodeAward = self._ccbOwner.node_item

	-- 奖励固定
	local posX = 0
	for i, data in pairs(self._exchangeItems) do
		if data.oType == "separate" then
			local sprite = CCSprite:create(data.id)
			sprite:setPosition(ccp(posX+25, 0))
			nodeAward:addChild(sprite)
			break
		else
			local itemBox = QUIWidgetItemsBox.new()
			itemBox:setScale(0.8)
			nodeAward:addChild(itemBox)
			self._itemBox = itemBox

			local id = data.id 
			local count = tonumber(data.count)
			local itemType = remote.items:getItemType(id)
			if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
				itemBox:setGoodsInfo(id, itemType, count)
			else
				itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
			end			
			local isNeed = remote.stores:checkMaterialIsNeed(tonumber(id), count)
	        itemBox:showGreenTips(isNeed)
			itemBox:setPosition(ccp(posX, 0))
			posX = posX + 50
		end
	end
end

function QUIWidgetActivityMzlbCell:setItemInfo( item, data ,index)
	-- item._ccbOwner.parentNode:removeAllChildren()
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setScale(0.8)
			item._itemBox:setPosition(ccp(45, 45))
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(80, 80))

		end
		local id = data.id 
		local count = tonumber(data.count)
		local itemType = remote.items:getItemType(id)

		if itemType ~= nil and itemType ~= ITEM_TYPE.ITEM then
			item._itemBox:setGoodsInfo(id, itemType, count)
		else
			item._itemBox:setGoodsInfo(id, ITEM_TYPE.ITEM, count)
			if data.isNeedShowItemCount then
				local num = remote.items:getItemsNumByID(id) or 0
				item._itemBox:setItemCount(string.format("%d/%d",num, count))
			end
		end
		local isNeed = remote.stores:checkMaterialIsNeed(tonumber(id), count)
        item._itemBox:showGreenTips(isNeed) 
	
	elseif data.oType == "separate" then
		if not item._separate then
			local sprite = CCSprite:create(data.id)
			item._separate = sprite
			item._ccbOwner.parentNode:addChild(sprite)
		else
			local frame  = QSpriteFrameByPath(data.id)
			if frame then
				item._separate:setDisplayFrame(frame)
			end
		end
		local width = 50
		if data.width then
			width = data.width
		end 
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(width, 80))
		item._separate:setPosition(width/2, 55)
	end
end

function QUIWidgetActivityMzlbCell:onTriggerBuy()
	local curentVipLevel = app.vipUtil:VIPLevel()
	if curentVipLevel < tonumber(self._info.vip_id) then
		local text = "VIP达到"..tonumber(self._info.vip_id).."级可购买，是否前往充值提升VIP等级？"
		app:vipAlert({content=text}, false)
		return
	end
 	self:dispatchEvent({name = QUIWidgetActivityMzlbCell.UPDATE_BUYSTATE, index = self._info.id, awards = self.awards})
end

function QUIWidgetActivityMzlbCell:registerItemBoxPrompt( index, list )
	if self._itemBox then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end
		list:registerItemBoxPrompt(index, 1, self._itemBox, nil, showItemInfo)
	end
end

function QUIWidgetActivityMzlbCell:onTouchListView(event)
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._widgetActivityMzlb:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_V then
					self._listView:setCanNotTouchMove(true)
				elseif curGesture == QListView.GESTURE_H then
					contentListView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		local contentListView = self._widgetActivityMzlb:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end
function QUIWidgetActivityMzlbCell:onEnter()
end

function QUIWidgetActivityMzlbCell:onExit()
end

function QUIWidgetActivityMzlbCell:getContentSize()
	return self._ccbOwner.cellSize:getContentSize()
end

return QUIWidgetActivityMzlbCell
