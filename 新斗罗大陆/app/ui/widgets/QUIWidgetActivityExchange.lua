--[[	
	文件名称：QUIWidgetActivityExchange.lua
	创建时间：2016-03-10 18:28:19
	作者：nieming
	描述：QUIWidgetActivityExchange
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetActivityExchange = class("QUIWidgetActivityExchange", QUIWidget)
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import(".QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("...ui.QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIWidgetActivityExchange:ctor(options)
	local ccbFile = "Widget_Activity_Exchange.ccbi"
	if options and options.ccbFile then
		ccbFile = options.ccbFile
		print("ccbFile ====="..ccbFile)
	end
	local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIWidgetActivityExchange._onTriggerConfirm)},
	}
	QUIWidgetActivityExchange.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._buyCount = 0
end

--describe：
function QUIWidgetActivityExchange:_onTriggerConfirm()
	--代码
end

--describe：onEnter 
function QUIWidgetActivityExchange:onEnter()
	--代码
	self._isExit = true
end

--describe：onExit 
function QUIWidgetActivityExchange:onExit()
	--代码
	self._isExit = nil
end


--describe：setInfo 
function QUIWidgetActivityExchange:setInfo(activityId, info, activityPanel, isPreviewActivity, startAt)
	self._info = info

	self._activityPanel = activityPanel
	if info.awards == nil then
		return 
	end
	self._data = {}					-- 所有道具
	self._chooseData = {}			-- 兑换选择材料
	self.awards = {}
	self._price = 0
	self._moneyType = nil
	self._items = {}
	self._isAwardChooseOne = false	-- 奖励选择一个
	self._isItemChooseOne = false	-- 兑换选择一个
	self._awardStr = nil
	self._exchangeItems = {}
	self._buyCount = 0
	if info.type == 300 then
		table.insert(self._data, {oType = "item", id = ITEM_TYPE.TOKEN_MONEY, count = info.value2,isNotAwawd = true})
		self._price = tonumber(info.value2)
		self._moneyType = ITEM_TYPE.TOKEN_MONEY
	elseif info.type == 301 then
		table.insert(self._data, {oType = "item", id = ITEM_TYPE.MONEY, count = info.value2,isNotAwawd = true})
		self._price = tonumber(info.value2)
		self._moneyType = ITEM_TYPE.MONEY
	elseif info.type == 302 then
		if string.find(info.value3, "#") then
			local items = string.split(info.value3, "#") 
			self._isItemChooseOne = #items > 1
			for i = 1, #items do
				local obj = string.split(items[i], "^")
		        if #obj == 2 then
		        	table.insert(self._chooseData, {oType = "item", id = obj[1], count = obj[2], isNeedShowItemCount = true,isNotAwawd = true})
		        	table.insert(self._exchangeItems,{ oType = "item", id = obj[1], count = tonumber(obj[2])} )
		       		if i ~= #items then
			        	table.insert(self._chooseData, {oType = "separate", id = "ui/Activity_game/zi_huo.png", width = 30})
			        end
		        end
			end
		else
			local items = string.split(info.value3, ";") 
			for i = 1, #items do
				local obj = string.split(items[i], "^")
		        if #obj == 2 then
		        	table.insert(self._data, {oType = "item", id = obj[1], count = obj[2], isNeedShowItemCount = true,isNotAwawd = true})
		        	table.insert(self._exchangeItems,{ oType = "item", id = obj[1], count = tonumber(obj[2])} )
		        end
			end
		end
	end
	
	-- 等号分隔
	table.insert(self._data, {oType = "separate", id = "ui/Activity_game/yellow_denghao.png"})
	
	local items = string.split(info.awards, ";") 
	local count = #items
	for i=1,count,1 do
		local  temp = string.split(items[i], "#")
		if #temp > 1 then
			self._isAwardChooseOne = true
			self._awardStr = string.gsub(items[i], "#", ";")
			self._awardArr = temp

			for k,v in pairs(temp) do
				local obj = string.split(v, "^")
		        if #obj == 2 then
		        	local typeName = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
	        		table.insert(self.awards, {id = obj[1], typeName = typeName, count = tonumber(obj[2])})
		        	table.insert(self._data, {oType = "item", id = obj[1], count = obj[2]})
		        	if k ~= #temp then
		        		table.insert(self._data, {oType = "separate", id = "ui/Activity_game/zi_huo.png", width = 30})
		        	end
		        end
			end
		else
			local obj = string.split(items[i], "^")
	        if #obj == 2 then
	        	table.insert(self._data, {oType = "item", id = obj[1], count = obj[2]})
	        	local typeName = remote.items:getItemType(obj[1]) or ITEM_TYPE.ITEM
	        	table.insert(self.awards, {id = obj[1], typeName = typeName, count = tonumber(obj[2])})
	        	table.insert(self._items, {typeName = typeName, id = obj[1],count = tonumber(obj[2])})
	        end
		end 
	end

	self._ccbOwner.node_btn:setVisible(false)
	if self._ccbOwner.notTouch then
		self._ccbOwner.notTouch:setVisible(false)
	end
	local progressData = remote.activity:getActivityTargetProgressDataById(info.activityId, info.activityTargetId)
	if progressData then
		if isPreviewActivity and q.serverTime() * 1000 < (startAt or 0) then

			if self._ccbOwner.notTouch then
				self._ccbOwner.notTouch:setString("明日开启")
				self._ccbOwner.notTouch:setVisible(true)
			end
		elseif info.repeatCount > progressData.awardCount then
			self._ccbOwner.btnName:setString("兑换")
			self._ccbOwner.btnName:enableOutline()
			self._ccbOwner.node_btn:setVisible(true)
			makeNodeFromGrayToNormal(self._ccbOwner.btnExchange)
		else
			self._ccbOwner.btnName:setString("已兑换")
			self._ccbOwner.btnName:disableOutline()
			makeNodeFromNormalToGray(self._ccbOwner.btnExchange)
			self._ccbOwner.node_btn:setVisible(true)
		end
		self._ccbOwner.titleName:setString(info.description)

		self._ccbOwner.timesLabel:setString(string.format("剩余次数：%d/%d", info.repeatCount - progressData.awardCount,info.repeatCount))
		self._buyCount = info.repeatCount - progressData.awardCount
		
		local maxNum = 0
		self._selectNum = 0
		if self._info.type == 300 then
			maxNum = math.floor(remote.user.token/self._price)
		elseif self._info.type == 301 then
			maxNum = math.floor(remote.user.money/self._price)
		elseif self._info.type == 302 then
			for k, v in ipairs(self._exchangeItems) do
				local haveCount = remote.items:getItemsNumByID(v.id) or 0
				if tonumber(v.id) == nil then
					local itemType = remote.items:getItemType(v.id)
					haveCount = remote.user[itemType]
				end
				local tempMaxNum = math.floor(haveCount/v.count)
				if self._isItemChooseOne then
					if self._selectNum == 0 and haveCount > 0 then
						self._selectNum = k
						maxNum = tempMaxNum
					end
				else
					if maxNum == 0 then
						maxNum = tempMaxNum
					elseif maxNum > tempMaxNum then
						maxNum = tempMaxNum
					end
				end
			end
		end
		self._buyCount = self._buyCount > maxNum and maxNum or self._buyCount
	end

	if info.completeNum == 1 and info.type == 302 then
		self._ccbOwner.btnName:disableOutline()
		makeNodeFromNormalToGray(self._ccbOwner.btnExchange)
	end

	self._ccbOwner.node_dazhe:removeAllChildren()
	if self._info.discount then
		local ccbProxy = CCBProxy:create()
        local ccbOwner = {}
        local dazheWidget = CCBuilderReaderLoad("Widget_dazhe.ccbi", ccbProxy, ccbOwner)
        ccbOwner.chengDisCountBg:setVisible(false)
        ccbOwner.lanDisCountBg:setVisible(false)
        ccbOwner.ziDisCountBg:setVisible(false)
        ccbOwner.hongDisCountBg:setVisible(true)
        if self._info.discount >= 1 and self._info.discount < 10 then
        	ccbOwner.discountStr:setString(self._info.discount.."折")
    	elseif self._info.discount == 11 then
        	ccbOwner.discountStr:setString("限时")
        elseif self._info.discount == 12 then
        	ccbOwner.discountStr:setString("火热")
        elseif self._info.discount == 13 then
        	ccbOwner.discountStr:setString("推荐")
        end
        self._ccbOwner.node_dazhe:addChild(dazheWidget)
	end

	self._ccbOwner.node_award:removeAllChildren()
	self._itemBox = nil

	-- 只滑动左边材料item
	if self._listView then
		self._listView:clear(true)
		self._listView = nil
	end
	if self._isItemChooseOne then
		self:initShortListView()
	else
		self:initListView()
	end
end

function QUIWidgetActivityExchange:initShortListView()
	-- 拥有材料滑动
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end

		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	          	local data = self._chooseData[index]

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
	            else
	            	item:setZOrder(1)
	           	end

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._chooseData,
	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView_short,cfg)
	else
		self._listView:reload({totalNumber = #self._chooseData})
	end

	-- 位置校准
	local width = 0
	for i, data in pairs(self._chooseData) do
		if data.width then
			width = width + data.width
		else
			width = width + 100
		end
	end
	local listWidth = self._ccbOwner.itemsListView_short:getContentSize().width
	if width > listWidth then
		width = listWidth
	end
	local nodeAward = self._ccbOwner.node_award
	nodeAward:setPositionX(width+30)

	-- 奖励固定
	local posX = 0
	for i, data in pairs(self._data) do
		if data.oType == "separate" then
			local sprite = CCSprite:create(data.id)
			sprite:setPosition(ccp(posX+25, -3))
			nodeAward:addChild(sprite)
			posX = posX + 50
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
			itemBox:setPosition(ccp(posX+45, -11))
			posX = posX + 100
			break
		end
	end
end

function QUIWidgetActivityExchange:registerItemBoxPrompt( index, list )
	if self._itemBox then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
		end
		list:registerItemBoxPrompt(index, 1, self._itemBox, nil, showItemInfo)
	end
end

function QUIWidgetActivityExchange:initListView()
	if not self._listView then
		local function showItemInfo(x, y, itemBox, listView)
			app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
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
	            else
	            	item:setZOrder(1)
	           	end

	            return isCacheNode
	        end,
	        isChildOfListView = true,
	        isVertical = false,
	        enableShadow = false,
	        tailIndex = tailIndex,
	        -- ignoreCanDrag = true,
	    	-- leftShadow = self._ccbOwner.leftShadow,
	    	-- rightShadow = self._ccbOwner.rightShadow,
	        totalNumber = #self._data,

	    }  
    	self._listView = QListView.new(self._ccbOwner.itemsListView,cfg)
	else
		self._listView:reload({totalNumber = #self._data, tailIndex = tailIndex})
	end 
end


function QUIWidgetActivityExchange:setItemInfo( item, data ,index)
	-- item._ccbOwner.parentNode:removeAllChildren()
	if data.oType == "item" then
		if not item._itemBox then
			item._itemBox = QUIWidgetItemsBox.new()
			item._itemBox:setScale(0.75)
			item._itemBox:setPosition(ccp(45, 38))
			item._ccbOwner.parentNode:addChild(item._itemBox)
			item._ccbOwner.parentNode:setContentSize(CCSizeMake(75, 75))

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
		local width = 60
		if data.width then
			width = data.width
		end 
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(width, 80))
		item._separate:setPosition(width/2+3, 50)
	end
end

-- function QUIWidgetActivityExchange:registerItemBoxPrompt( index, list )
-- 	-- body
-- 	for k, v in pairs(self._itemBoxs) do
-- 		list:registerItemBoxPrompt(index,k,v)
-- 	end
-- end



--describe：getContentSize 
function QUIWidgetActivityExchange:getContentSize()
	--代码
	return self._ccbOwner.cellSize:getContentSize()
end

function QUIWidgetActivityExchange:getListView( )
	-- body
	return self._listView
end

function QUIWidgetActivityExchange:onTouchListView( event )
	-- body
	if not event then
		return
	end

	if event.name == "moved" then
		local contentListView = self._activityPanel:getContentListView()
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
		local contentListView = self._activityPanel:getContentListView()
		if contentListView then
			contentListView:setCanNotTouchMove(nil)
		end
		self._listView:setCanNotTouchMove(nil)
	end

	self._listView:onTouch(event)
end


function QUIWidgetActivityExchange.getRewards(activityId, activityTargetId, moneyType, price, awards, params, count)
	if count == nil then count = 1 end
	if moneyType == ITEM_TYPE.TOKEN_MONEY then
		if remote.user.token < (count * price) then
			QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			return
		end
	elseif moneyType == ITEM_TYPE.MONEY then
		if remote.user.money < (count * price) then
    		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
			return
		end
	end

	for _,value in ipairs(awards or {}) do
		value.count = value.count * count
	end
	-- bod

	app:getClient():activityCompleteRequest(activityId, activityTargetId, params, count, function ()
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
		dialog:setTitle("恭喜您获得活动奖励")
		remote.activity:setCompleteDataById(activityId, activityTargetId, count)
	end)
	return true
end

--请求完成
function QUIWidgetActivityExchange:onTriggerExchange(x , y, touchNodeNode, list)
    app.sound:playSound("common_small")
	

	if  self._info.completeNum == 3 then
		return
	end
	if  self._info.completeNum ~= 2 then
		if not remote.activity:checkIsActivity(self._info.activityId) then
			app.tip:floatTip("不在活动时间段内!")
			return
		else
			if self._info.type == 302 then
				local tipWord = "兑换道具不足！"
				local items = string.split(self._info.value3, ";") 
				for i=1, #items, 1 do
					local obj = string.split(items[i], "^")
			        if #obj == 2 then
			        	local num = remote.items:getItemsNumByID(tonumber(obj[1])) or 0
			        	if tonumber(obj[1]) == nil then
			        		local itemType, itemName = remote.items:getItemType(obj[1])
							num = remote.user[itemType]
							tipWord = "兑换"..(itemName or "道具").."不足！"
			        	end

			        	if num < (tonumber(obj[2]) or 0) then
			        		break;
			        	end
			        end
				end
				app.tip:floatTip(tipWord)
			else
				app.tip:floatTip("活动目标未达成！")
			end
			
		end
		return
	end

	if remote.activity:checkIsActivityAward(self._info.activityId) == false then
		app.tip:floatTip("活动领奖时间已过！下次请早！")
		return
	end

	if self._activityPanel then
		self._activityPanel:getOptions().curActivityTargetId  = self._info.activityTargetId
		self._activityPanel:getOptions().curActivityTargetOffset  = list:getItemPosToTopDistance(list:getCurTouchIndex())
	end


	local progressData = remote.activity:getActivityTargetProgressDataById(self._info.activityId, self._info.activityTargetId)
	local activityTargetId = self._info.activityTargetId
	local activityId = self._info.activityId
	local maxExchangeNum = (self._info.repeatCount or 0) - (progressData.awardCount)
	local exchangeItems = self._exchangeItems
	local awards = self.awards
	local moneyType = self._moneyType
	local price = tonumber(self._price) or 0

	if self._isItemChooseOne then	
		local isMul = true
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
            options = {awards = exchangeItems, confirmText = "兑 换", useLabel = "批量兑换：", maxOpenNum = self._buyCount, maxExchangeNum = maxExchangeNum, isMultiple = isMul, titleText="活动兑换", isItemChoose = true, explainStr = "请选择消耗物品",
            	tipText = "请选择%s个消耗物品", selectNum = self._selectNum,
                okCallback = function ( chooseIndexs , selectCount)
              		if not chooseIndexs then
						chooseIndexs = {}
					end

					local chooseIndex = chooseIndexs[1]
                	if not chooseIndex or chooseIndex <= 0 then
                		app.tip:floatTip("请选择")
                		return false
                	end

                	local chooseAward = exchangeItems[chooseIndex]
                	if type(chooseAward) == "table" then
                    	local chooseAwardStr = chooseAward.id.."^"..chooseAward.count
                    	local chooseAwards = awards
                    	return QUIWidgetActivityExchange.getRewards(activityId, activityTargetId, moneyType, price, chooseAwards, chooseAwardStr, selectCount)
                    end
                    return true
                end}}, {isPopCurrentDialog = false})
	elseif self._isAwardChooseOne then	
		local isMul = self._buyCount >= 2
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
            options = {awards = awards, confirmText = "兑 换", useLabel = "批量兑换：", maxOpenNum = self._buyCount, isMultiple = isMul,titleText="活动兑换",
                okCallback = function ( chooseIndexs , selectCount)
              		if not chooseIndexs then
						chooseIndexs = {}
					end

					local chooseIndex = chooseIndexs[1]
                	if not chooseIndex or chooseIndex <= 0 then
                		app.tip:floatTip("请选择")
                		return false
                	end

                	local chooseAward = awards[chooseIndex]
                	if type(chooseAward) == "table" then
                    	local chooseAwardStr = chooseAward.id.."^"..chooseAward.count
                    	local chooseAwards = {}
                    	table.insert(chooseAwards, chooseAward)
                    	return QUIWidgetActivityExchange.getRewards(activityId, activityTargetId, moneyType, price, chooseAwards, chooseAwardStr, selectCount)
                    end
                    return true
                end}}, {isPopCurrentDialog = false})
	elseif #self._items == 1 then
		local maxCount = self._buyCount
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityBuyMultiple",
			options = {items = self._items[1], maxCount = maxCount, price = self._price, moneyType = self._moneyType, isItemExchange = (self._info.type == 302), 
				callback = function (count)
					QUIWidgetActivityExchange.getRewards(activityId, activityTargetId, moneyType, price, awards, nil, count)
				end}}, {isPopCurrentDialog = false})
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogXuanzejiangli", 
            options = {awards = awards, confirmText = "兑 换", useLabel = "批量兑换：", maxOpenNum = self._buyCount, isMultiple = true,chooseType = 3,explainStr="请选择你要兑换的数量",titleText="活动兑换",
            	okCallback = function (selectCount)
                	QUIWidgetActivityExchange.getRewards(activityId, activityTargetId, moneyType, price, awards, nil , selectCount)
            	end}}, {isPopCurrentDialog = false})
	end
end

return QUIWidgetActivityExchange
