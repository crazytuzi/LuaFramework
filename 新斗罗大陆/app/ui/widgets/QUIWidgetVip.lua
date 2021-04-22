-- @Author: xurui
-- @Date:   2018-06-19 14:48:43
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-06-20 15:29:47
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetVip = class("QUIWidgetVip", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetVipClient = import("..widgets.QUIWidgetVipClient")
local QVIPUtil = import("...utils.QVIPUtil")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QRichText = import("...utils.QRichText")

QUIWidgetVip.UPDATE_VIP = "UPDATE_VIP"

function QUIWidgetVip:ctor(options)
	local ccbFile = "ccb/Widget_VIP_new.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBuy", callback = handler(self, QUIWidgetVip._onTriggerBuy)},
    }
    QUIWidgetVip.super.ctor(self, ccbFile, callBacks, options)
	q.setButtonEnableShadow(self._ccbOwner.canbuy)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._itemBoxs = {}
	self._itemData = {}
end

function QUIWidgetVip:onEnter()
end

function QUIWidgetVip:onExit()
end

function QUIWidgetVip:setInfo(currentLevel, activityPanel)
	self._vipLevel = currentLevel
	self._activityPanel = activityPanel

	self._ccbOwner.node_vip_content:setVisible(currentLevel > 0)
	self._ccbOwner.tf_vip:setString("VIP"..currentLevel)

	if self._richText == nil then
		self._richText = QRichText.new(nil, 1000, {autoCenter = true, stringType = 1})
		self._richText:setAnchorPoint(ccp(0.5, 0.5))
		self._ccbOwner.node_vip_content:addChild(self._richText)
	end
	local token = QVIPUtil:cash(self._vipLevel)
	local strTable = {
            {oType = "font", content = "累计购买", size = 22,color = ccc3(135, 87, 57)},
            {oType = "font", content = token, size = 22,color = ccc3(94, 50, 25)},
            {oType = "font", content = "钻，可享受", size = 22,color = ccc3(135, 87, 57)},
            {oType = "font", content = "VIP"..self._vipLevel, size = 22,color = ccc3(94, 50, 25)},
            {oType = "font", content = "特权", size = 22,color = ccc3(135, 87, 57)},
        }
	self._richText:setString(strTable)

	self:getVIPItemData()

	self:initListView()
end

function QUIWidgetVip:getVIPItemData()
	local shopItem = nil
	local shopItems = remote.stores:getStoresById(SHOP_ID.vipShop)
	local pos = 0
	if shopItems ~= nil then
		for i = 1, #shopItems, 1 do
			if self._vipLevel == QVIPUtil:getVIPLevelByShopId(shopItems[i].good_group_id) then
				shopItem = shopItems[i]
				break
			end
			pos = pos + 1
		end
	end

	local itemId = nil
	if shopItem then
		self._ccbOwner.bought:setVisible(shopItem.count == 0)
		self._ccbOwner.unbought:setVisible(shopItem.count ~= 0)
	else
		self._ccbOwner.bought:setVisible(true)
		self._ccbOwner.unbought:setVisible(false)
	end

	if shopItem then
		self._cost = math.floor(shopItem.cost * (shopItem.sale or 0))
		self._ccbOwner.originalPrice:setString(shopItem.cost)
		self._ccbOwner.discountPrice:setString(self._cost)
		itemId = shopItem.id

		if self._vipLevel <= QVIPUtil:VIPLevel() then
	  		makeNodeFromGrayToNormal(self._ccbOwner.canbuy:getParent())
	  		self._ccbOwner.recharge_tip:setVisible(true)
	  		self._ccbOwner.buyEffect:setVisible(true)
	  		self._ccbOwner.canbuy:setEnabled(true)
			self._onTriggerBuyImpl = function ( ... )
			    app:alert({content=string.format("是否花费%d钻石，购买V%d超值礼包？", self._cost, self._vipLevel), title="系统提示", 
			        callback = function(state)
			            if state == ALERT_TYPE.CONFIRM then
			            	-- VIP 商城点击礼包直接打开
							app:getClient():buyShopItem(SHOP_ID.vipShop, pos, itemId, 1, 1, function(data)
								app:getClient():openItemPackage(itemId, 1, function(data)
				                    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QVIPUtil.AWARD_PURCHASED, id = itemId})

									local luckyDrawAwards = data.luckyDrawItemReward
									if luckyDrawAwards ~= nil then
										local awards = {}
										for _,value in ipairs(luckyDrawAwards) do
											table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
										end
										local backFun = function()
				                    		self:dispatchEvent({name = QUIWidgetVip.UPDATE_VIP})
										end
										app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
											options = {awards = awards, callback = backFun}}, {isPopCurrentDialog = true} )
									end

									self:getVIPItemData()
								end)
							end)
			            end
			        end}, true, true)
	  		end
	  	else
	  		makeNodeFromNormalToGray(self._ccbOwner.canbuy:getParent())
	  		self._ccbOwner.recharge_tip:setVisible(false)
	  		self._ccbOwner.buyEffect:setVisible(false)
	  		self._ccbOwner.canbuy:setEnabled(false)
			self._onTriggerBuyImpl = function ( ... ) end
	  	end
	else
		itemId = QStaticDatabase:sharedDatabase():getGoodsGroupByGroupId(QVIPUtil:getShopIdByVIP(self._vipLevel)).id_1

		self._onTriggerBuyImpl = function ( ... ) end
	end

	if itemId then 
		local info = QStaticDatabase:sharedDatabase():getItemByID(itemId)
		local itemInfos = string.split(info.content, ";")
		local highlightInfo = string.split(info.highlight, ";")
		local totalWidth = 0
		for i = 1, #itemInfos, 1 do
			local items = string.split(itemInfos[i], "^")
			if items then 
				local id = items[1]
				local itemCount = tonumber(items[2])
        		local itemType = remote.items:getItemType(id)
		        if itemType == nil then
		            itemType = ITEM_TYPE.ITEM
		        end

		        if self._itemBoxs[i] == nil then
		        	self._itemBoxs[i] = QUIWidgetItemsBox.new()
	        		self._itemBoxs[i]:setPromptIsOpen(true)
	        		self._ccbOwner["node_item_"..i]:addChild(self._itemBoxs[i])
		    	end

				self._itemBoxs[i]:setGoodsInfo(tonumber(id), itemType, tonumber(itemCount))
				for j = 1, #highlightInfo do
					if tonumber(highlightInfo[j]) == i then
						self._itemBoxs[i]:showBoxEffect("effects/DailySignIn_saoguang2.ccbi", true)
						break
					end
				end
			end
		end
	end
end

function QUIWidgetVip:initListView( ... )
	local sheet = self._ccbOwner.sheet_layout
	-- if self._vipLevel == 0 then
	-- 	sheet = self._ccbOwner.sheet_layout1
	-- end

	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = {}

	            local item = list:getItemFromCache(data.oType)
	            if not item then
	                item = QUIWidgetVipClient.new()
	                isCacheNode = false
	            end
	            item:setVipContent(self._vipLevel)

	            info.item = item
	            info.tag = data.oType
	            info.size = item:getContentSize()

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = true,
	        enableShadow = false,
	        totalNumber = 1,
	        curOffset = 5,
	    }  
    	self._listView = QListView.new(sheet, cfg)
	else
		self._listView:reload({totalNumber = 1})
	end 
end

function QUIWidgetVip:onTouchListView( event , parentNode)
	-- body
	if not event then
		return
	end
	if event.name == "moved" then
		local contentListView = self._activityPanel:getContentListView()
		if contentListView then
			local curGesture = contentListView:getCurGesture() 
			if curGesture then
				if curGesture == QListView.GESTURE_H then
					self._listView:setCanNotTouchMove(true)
				end
			end
		end
	elseif  event.name == "ended" then
		self._listView:setCanNotTouchMove(nil)
	end

	if self._listView then
		self._listView:onTouch(event)
	end
end

function QUIWidgetVip:registerItemBoxPrompt( index, list )
	-- body
	for k, v in pairs(self._itemBoxs) do
		list:registerItemBoxPrompt(index,k,v)
	end
end

function QUIWidgetVip:_onTriggerBuy()
    app.sound:playSound("common_small")
	self._onTriggerBuyImpl()
end

function QUIWidgetVip:getContentSize()
	return CCSize(900, 430)
end

return QUIWidgetVip
