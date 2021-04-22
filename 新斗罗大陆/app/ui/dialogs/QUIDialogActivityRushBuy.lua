--[[	
	文件名称：QUIDialogActivityRushBuy
	创建时间：2017-02-09 17:25:33
	作者：nieming
	描述：QUIDialogActivityRushBuy 6元夺宝
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogActivityRushBuy = class("QUIDialogActivityRushBuy", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QUIWidgetRushBuyItem = import("..widgets.QUIWidgetRushBuyItem")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
--初始化
function QUIDialogActivityRushBuy:ctor(options)
	local ccbFile = "Dialog_SixYuan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggleScoreExchange", callback = handler(self, QUIDialogActivityRushBuy._onTriggleScoreExchange)},
		{ccbCallbackName = "onTriggerIntroduce", callback = handler(self, QUIDialogActivityRushBuy._onTriggerIntroduce)},
		{ccbCallbackName = "onTriggleLuckyPerson", callback = handler(self, QUIDialogActivityRushBuy._onTriggleLuckyPerson)},
		{ccbCallbackName = "onTriggleCurLuckyPerson", callback = handler(self, QUIDialogActivityRushBuy._onTriggleCurLuckyPerson)},
		{ccbCallbackName = "onTriggleBuyRecords", callback = handler(self, QUIDialogActivityRushBuy._onTriggleBuyRecords)},
		{ccbCallbackName = "onTriggleBuy", callback = handler(self, QUIDialogActivityRushBuy._onTriggleBuy)},
	}
	QUIDialogActivityRushBuy.super.ctor(self,ccbFile,callBacks,options)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page:setAllUIVisible()
    page.topBar:showWithRushBuy()
	--代码

	self._scoresBarMask = self:_addScoresBarMaskLayer(self._ccbOwner.progressSprite, self._ccbOwner.progressBarParent)

	if not options then
		options = {}
	end
	-- self._goodsInfo = options.goodsInfo or {}
	-- self._buyInfo = options.buyInfo or {}
	self._time = 0
	self._curSelectIndex = options.selectIndex or 1
	self:render()
	self._ccbOwner.time:setString(q.timeToHourMinuteSecond(self._time))
	self._lastItemNum = #self._data

	self._root:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, QUIDialogActivityRushBuy.onFrame))
    self._root:scheduleUpdate()

	self._schedulerID = scheduler.scheduleGlobal(handler(self, self._timeUpdate), 1)

    local imp = remote.activityRounds:getRushBuy()
	if imp then
		imp:clickedActivity(true)
	end
	
	self._ccbOwner.tf_buy_count:setVisible(false) 
end

function QUIDialogActivityRushBuy:render(  )
	-- body
	self:getData()
	self:initListView()
	self:refreshContent()
end

function QUIDialogActivityRushBuy:onFrame(  )
	-- body
	if self._dataDirty then
		self._dataDirty = nil
		self:render()
	end
end

function QUIDialogActivityRushBuy:getData( goodInfo, buyInfo)
	-- body
	local imp = remote.activityRounds:getRushBuy()
	if not imp then
		return
	end

	local goodInfo = imp:getGoodInfo()
	local buyInfo = imp:getBuyInfo()

	local oldData = self._data or {}
	self._data = {}
	local temp = {}
	for k, v in pairs(goodInfo) do
		temp[v.roundId] = v
	end

	local isAllItemClicked = true
	for k, v in pairs(buyInfo) do
		local data = temp[v.roundId]
		local t = {}
		if data then
			t.levelLimit = data.levelLimit
			t.item = data.item
			t.num = data.num
			t.price = data.price
			t.times = data.times
			t.numLimit = data.numLimit
			t.buyMax = data.buyMax

			t.roundId = v.roundId
			t.issue = v.issue
			t.allBuyCount = v.allBuyCount
			t.myBuyCount = v.myBuyCount
			t.isRedTips = app:getUserOperateRecord():getRushBuyRedTips(imp.activityId ,v.roundId)
			if isAllItemClicked and t.isRedTips and  t.allBuyCount ~=  t.price and t.myBuyCount and t.myBuyCount == 0 and imp.isActivityNotEnd then
				isAllItemClicked = false
			end
			self._data[v.roundId] = t
		end
	end
	imp:setAllItemClicked(isAllItemClicked)
end


function QUIDialogActivityRushBuy:_timeUpdate(  )
	-- body
	self._time = self._time - 1
	if self._time < 0 then
		self._time  = 0
	end
	self._ccbOwner.time:setString(q.timeToHourMinuteSecond(self._time))
end

function QUIDialogActivityRushBuy:_addScoresBarMaskLayer(ccb, mask)

    local width = ccb:getContentSize().width * ccb:getScaleX()
    self._barWidth = width
    local height = ccb:getContentSize().height * ccb:getScaleY()
    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0))
    maskLayer:setPosition(ccp(0, 0))

    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccb:setPosition(ccp(0, 0))
    ccclippingNode:addChild(ccb)
    ccb:release()

    mask:addChild(ccclippingNode)
    return maskLayer
end

function QUIDialogActivityRushBuy:selectItem( x, y, touchNode, listView )
	-- body
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()

    if self._curSelectIndex and self._curSelectIndex ~= touchIndex then
        local oldItem = listView:getItemByIndex(self._curSelectIndex)
        if oldItem then
            oldItem:setSelected(false)
        end
    end

    local item = listView:getItemByIndex(touchIndex)
    if item then
        item:setSelected(true)
    end

    if self._curSelectIndex ~= touchIndex then
        self._curSelectIndex = touchIndex
        self:refreshContent()
    end
end



function QUIDialogActivityRushBuy:initListView( )
	-- body
	if not self._listViewWidget then
		local cfg = {
			renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	          	local data = self._data[index]
	          	

	            local item = list:getItemFromCache()
	            if not item then
	            	item = QUIWidgetRushBuyItem.new()
	                isCacheNode = false
	            end
	            local isSelected = false
	            if self._curSelectIndex == index then
	            	isSelected = true
	            end
	            item:setInfo(data, isSelected, self._data)
	           
	            info.item = item
	            info.size = item:getContentSize()
	            --注册事件
                -- list:registerClickHandler(index,"self", function ( )
                -- 	return true
                -- end, nil, handler(self, self.selectItem))
                list:registerBtnHandler(index, "itemBtn",handler(self, self.selectItem))

                -- list:registerItemBoxPrompt(index, 1, item._itembox, nil, nil, true)
                
	            return isCacheNode
	        end,
	     	-- curOffset = 15,
	      	-- spaceY = 5,
	        -- enableShadow = false,
	        headIndex = self._curSelectIndex,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listViewWidget = QListView.new(self._ccbOwner.listViewLayer,cfg)
	else
		if self._lastItemNum == #self._data then
			self._listViewWidget:refreshData() 
		else
			self._listViewWidget:reload({totalNumber = #self._data, headIndex = self._curSelectIndex}) 
			self._lastItemNum = #self._data
		end
	end
end

function QUIDialogActivityRushBuy:refreshContent( )
	local curTime = q.serverTime()
	local imp = remote.activityRounds:getRushBuy()
	local curData = self._data[self._curSelectIndex]
	self._curData = curData
	if imp then
		if imp.isOpen then
			if not curData then
				return
			end
			if imp.isActivityNotEnd then
				self._time = imp.endAt - curTime
				self._ccbOwner.timeLabel:setString("夺宝结束时间：")
			else
				self._time = imp.showEndAt - curTime
				self._ccbOwner.timeLabel:setString("兑换结束时间：")
			end
			-- self._ccbOwner.time:setString(q.timeToHourMinuteSecond(self._time))

			local itemConfig
			local itemType = remote.items:getItemType(curData.item)
			if itemType ~= nil and  itemType ~= ITEM_TYPE.ITEM then
				itemConfig = remote.items:getWalletByType(itemType)
				self._ccbOwner.itemName:setString("奖品："..itemConfig.nativeName)
			else
				itemConfig = QStaticDatabase:sharedDatabase():getItemByID(curData.item)
				self._ccbOwner.itemName:setString("奖品："..itemConfig.name)
			end
			
			
			if not self._itembox then
				self._itembox = QUIWidgetItemsBox.new()
				self._ccbOwner.itemNode:addChild(self._itembox)
			end
			self._itembox:setGoodsInfoByID(curData.item, curData.num)
			self._itembox:setPromptIsOpen(true)

			self._ccbOwner.progressLabel:setString(string.format("%s/%s", curData.allBuyCount, curData.price))
			self._ccbOwner.curNo:setString(curData.issue)

			if not imp.isActivityNotEnd then
				self._ccbOwner.emptyStatus:setVisible(true)
				self._ccbOwner.notEmptyStatus:setVisible(false)
				self._ccbOwner.alreadyEmpty:setVisible(false)
				self._ccbOwner.tipLabel:setVisible(true)
				self._ccbOwner.tipLabel:setString(string.format("夺宝活动已结束"))
			else
				self._ccbOwner.alreadyEmpty:setVisible(true)
				if curData.allBuyCount == curData.price then
					self._ccbOwner.emptyStatus:setVisible(true)
					self._ccbOwner.tipLabel:setVisible(false)
					self._ccbOwner.notEmptyStatus:setVisible(false)
				else
					self._ccbOwner.emptyStatus:setVisible(false)
					self._ccbOwner.notEmptyStatus:setVisible(true)
					self._ccbOwner.tipLabel:setVisible(true)
					self._ccbOwner.tipLabel:setString(string.format("还需%s次，即抽取1人获得该商品。1次=1夺宝币", curData.price-curData.allBuyCount))
					self._ccbOwner.alreadyTimes:setString(string.format("%s次", curData.myBuyCount))
					local num = QStaticDatabase.sharedDatabase():getConfigurationValue("duobao_weizhongjiang")
					self._ccbOwner.tf_returnValue:setString(string.format("x%s", curData.myBuyCount * num))
				end
			end
			self._ccbOwner.luckyPersonRedTips:setVisible(remote.redTips:getTipsStateByName("QUIDialogActivityRushBuy_LuckyTips"))
			self._ccbOwner.recordRedTips:setVisible(imp:getRecordRedTips(self._curData.issue))

			if curData.levelLimit > remote.user.level then
				self._ccbOwner.levelLimit:setString(curData.levelLimit)
				self._ccbOwner.alreadyTimesLabel:setVisible(false)
				self._ccbOwner.alreadyTimes:setVisible(false)
				self._ccbOwner.levelLimitLabel:setVisible(true)
				self._ccbOwner.levelLimit:setVisible(true)
				makeNodeFromNormalToGray(self._ccbOwner.buyBtn)
			else
				self._ccbOwner.alreadyTimesLabel:setVisible(true)
				self._ccbOwner.alreadyTimes:setVisible(true)
				self._ccbOwner.levelLimitLabel:setVisible(false)
				self._ccbOwner.levelLimit:setVisible(false)
				makeNodeFromGrayToNormal(self._ccbOwner.buyBtn)
			end
			self._scoresBarMask:setScaleX(curData.allBuyCount/curData.price)
		else
			app:alert({content = "该活动下线了", title = "系统提示", callback = function (  )
                -- body
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end},false,true)
		end
	end
end

--describe：
function QUIDialogActivityRushBuy:_onTriggleScoreExchange()
	--代码
	app.sound:playSound("common_small")
	remote.stores:openShopDialog(SHOP_ID.rushBuyShop)
end

function QUIDialogActivityRushBuy:_onTriggerIntroduce()
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityRushBuyHelp", 
        options = {}})
end

function QUIDialogActivityRushBuy:_onTriggleLuckyPerson()
	app.sound:playSound("common_small")
	local imp = remote.activityRounds:getRushBuy()
	if imp then
		imp:requestLuckyPerson(function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRushBuyLuckyPerson", 
        		options = {data = data, title = "中奖名单"}})
		end)
	end

end

function QUIDialogActivityRushBuy:_onTriggleCurLuckyPerson()
	app.sound:playSound("common_small")
	local imp = remote.activityRounds:getRushBuy()
	if imp then
		imp:requestLuckyPersonIssue(self._curData.issue,function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRushBuyLuckyPerson", 
        		options = {data = data, title = "往期中奖"}})
		end)
	end
end

function QUIDialogActivityRushBuy:_onTriggleBuyRecords()
	app.sound:playSound("common_small")
	local imp = remote.activityRounds:getRushBuy()
	if imp and imp.isOpen and self._curData then
		imp:requestMyNum(self._curData.issue,function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityRushBuyRecord", 
        		options = {myNums = data, totalNums = self._curData.price, issue = self._curData.issue}})
		end)
	end
end

function QUIDialogActivityRushBuy:_onTriggleBuy(event)
	if q.buttonEventShadow(event, self._ccbOwner.buyBtn) == false then return end
	app.sound:playSound("common_small")
	local imp = remote.activityRounds:getRushBuy()
	if imp and imp.isOpen then
		if imp.isActivityNotEnd then
			if remote.user.level <  self._curData.levelLimit then
				app.tip:floatTip(string.format("%s级可购买",self._curData.levelLimit))
				return 
			end

			if remote.user.rushBuyMoney < 1 then
				app:vipAlert({title = "6元夺宝", textType = VIPALERT_TYPE.NO_RUSH_BUY_MONEY}, false)
				return
			end

			local maxNum = self._curData.buyMax - self._curData.myBuyCount
			local maxBuyNum = maxNum
			if remote.user.rushBuyMoney < maxNum then
				maxNum = remote.user.rushBuyMoney
			end
			if self._curData.price - self._curData.allBuyCount < maxNum then
				maxNum = self._curData.price - self._curData.allBuyCount
			end

			if maxNum < 1 then
				app.tip:floatTip("该期已达到最大购买次数！")
				return
			end

			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRushBuyMultiple", 
       			options = {maxNum = maxNum, maxBuyNum = maxBuyNum, issue = self._curData.issue}})
		else
			app.tip:floatTip("当前活动已结束，下次请早！")
		end

	else
		app.tip:floatTip("当前活动已结束，下次请早！")
	end
end

function QUIDialogActivityRushBuy:close( )
	self:playEffectOut()
end

function QUIDialogActivityRushBuy:_redTipsChange()
	self._ccbOwner.luckyPersonRedTips:setVisible(remote.redTips:getTipsStateByName("QUIDialogActivityRushBuy_LuckyTips"))
end

function QUIDialogActivityRushBuy:_handlerNotify(  )
	local imp = remote.activityRounds:getRushBuy()
    if imp and imp.isOpen then
        imp:openAward(true)
		local time = app.random(1, 5)
		scheduler.performWithDelayGlobal(function ( ... )
		local imp = remote.activityRounds:getRushBuy()
		if imp and imp.isOpen then
			imp:requestBuyInfos(function ( ... )
				remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
			end)
		end
		end,time)
    end
end

function QUIDialogActivityRushBuy:viewDidAppear()
	QUIDialogActivityRushBuy.super.viewDidAppear(self)
	self:addBackEvent(false)
	self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RUSHBUY_UPDATE, function ( event)
		self._dataDirty = true
	end)
	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RUSHBUY_RECORD_CHANGE, self:safeHandler(function() 
			local imp = remote.activityRounds:getRushBuy()
	   		if imp and imp.isOpen then
				self._ccbOwner.recordRedTips:setVisible(imp:getRecordRedTips(self._curData.issue))
			end
		end))

	self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RUSHBUY_CHANGE, function (  )
		local time = app.random(1, 5)
		scheduler.performWithDelayGlobal(function ( ... )
		local imp = remote.activityRounds:getRushBuy()
		if imp and imp.isOpen then
			imp:requestGoodsInfo(function ( )
				imp:requestBuyInfos(function ( ... )
					remote.activityRounds:dispatchEvent({name = remote.activityRounds.RUSHBUY_UPDATE})
				end)
			end)
		end
		end,time)
	end)


	remote:registerPushMessage("RUSH_BUY_ISSUE_END", self, self._handlerNotify)
	
	self._redTipsEventProxy = cc.EventProxy.new(remote.redTips)
    self._redTipsEventProxy:addEventListener(remote.redTips.TIPS_STATE_CHANGE, handler(self, self._redTipsChange))
end

function QUIDialogActivityRushBuy:viewWillDisappear()
	QUIDialogActivityRushBuy.super.viewWillDisappear(self)
	self:removeBackEvent()
	if self._activityRoundsEventProxy then
		self._activityRoundsEventProxy:removeAllEventListeners()
		self._activityRoundsEventProxy = nil
	end

	if self._redTipsEventProxy then
		self._redTipsEventProxy:removeAllEventListeners()
		self._redTipsEventProxy = nil
	end

	remote:removePushMessage("RUSH_BUY_ISSUE_END", self, self._handlerNotify)


	if self._schedulerID then
		scheduler.unscheduleGlobal(self._schedulerID)
		self._schedulerID = nil 
	end
end

function QUIDialogActivityRushBuy:onTriggerBackHandler()

	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogActivityRushBuy:onTriggerHomeHandler()
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogActivityRushBuy
