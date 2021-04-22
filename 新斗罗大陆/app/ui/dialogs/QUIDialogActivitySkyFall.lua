-- @Author: lxb
-- @Date:   2020-03-26 16:42:58
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-09 19:28:03
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivitySkyFall = class("QUIDialogActivitySkyFall", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetRedPackage = import("..widgets.QUIWidgetRedPackage")
local QUIWidget = import("..widgets.QUIWidget")
local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogActivitySkyFall:ctor(options)
	local ccbFile = "ccb/Dialog_Activity_SkyFall.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOpenGrabPackage", callback = handler(self,self._onTriggerOpenGrabPackage)},
		{ccbCallbackName = "onTriggerBox1", callback = handler(self, self._onTriggerBox1)},
		{ccbCallbackName = "onTriggerBox2", callback = handler(self, self._onTriggerBox2)},
		{ccbCallbackName = "onTriggerBox3", callback = handler(self, self._onTriggerBox3)},
		{ccbCallbackName = "onTriggerBox4", callback = handler(self, self._onTriggerBox4)},	
		{ccbCallbackName = "onTriggerBox5", callback = handler(self, self._onTriggerBox5)},
    }
    
    QUIDialogActivitySkyFall.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	CalculateUIBgSize(self._ccbOwner.ly_bg)
	-- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	-- page:setManyUIVisible()

	self._ccbOwner.node_effect:removeAllChildren()

    self._totalBarWidth = self._ccbOwner.node_bar:getContentSize().width * self._ccbOwner.node_bar:getScaleX()
    self._totalBarPosX = self._ccbOwner.node_bar:getPositionX()

    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.node_bar)

    self._size = CCSize(display.ui_width ,display.ui_height) 

    self._activitySkyFallProxy = remote.activityRounds:getSkyFall()
    
    self._tokenNumUpdate = QTextFiledScrollUtils.new()
    self._packageIdList = {}
    self._rankAwardsInfo = {}
    self._rankAwardsItemBoxs = {}
	for i=1,3 do
		local item = QUIWidgetItemsBox.new()
		self._ccbOwner["node_awrds_"..i]:addChild(item)
		table.insert(self._rankAwardsItemBoxs,item) 
	end
    self._redPackageDownIng = false
    self._openPackageAction = false
    self._skyfallInfo = self._activitySkyFallProxy:getActivitySkyFallInfo()

    self._lastOpenCount = self._activitySkyFallProxy:getLastSkyFallTimes()    
    print("剩余打开红包次数---",self._lastOpenCount)
    self._tokenNums = self._activitySkyFallProxy:getRandomRedpackage()
 
 	local rankAwards = db:getSkyFallActivityRewardByRowNum(self._activitySkyFallProxy.rowNum)
	if rankAwards then
		self._activitySkyFallProxy:switchLuckAwards(rankAwards.final_lucky_reward,self._rankAwardsInfo)
	end

	self:initRedPackage()
	self._todayGetToken = self._skyfallInfo and self._skyfallInfo.todayGetToken or 0

	self._allTokenNum = 0


end


function QUIDialogActivitySkyFall:viewDidAppear()
	QUIDialogActivitySkyFall.super.viewDidAppear(self)

    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.SKY_FALL_UPDATE, handler(self, self.updateInfo))

	self:_onTodayTokenUpdate(self._todayGetToken)
	self:updateInfo()
	self:updateRankInfo()
	self:setTimeCountdown()
	self:setActivityTime() 

	scheduler.performWithDelayGlobal(function( ... )
		if self:safeCheck() then
			if self._lastOpenCount > 0 and self._activitySkyFallProxy.showEndAt - q.serverTime() > DAY then
				self:setRedPackageAction()   
			end
		end
	end,1)
	
end

function QUIDialogActivitySkyFall:viewWillDisappear()
  	QUIDialogActivitySkyFall.super.viewWillDisappear(self)
  	-- print(debug.traceback())
  	self._activityRoundsEventProxy:removeAllEventListeners()

    if self._textureCacheScheduler then
	    scheduler.unscheduleGlobal(self._textureCacheScheduler)
	    self._textureCacheScheduler = nil	
    end
	if self._tokenNumUpdate then
		self._tokenNumUpdate:stopUpdate()
		self._tokenNumUpdate = nil
	end

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end

	if self._timeNextScheduler then
		scheduler.unscheduleGlobal(self._timeNextScheduler)
		self._timeNextScheduler = nil
	end
end

function QUIDialogActivitySkyFall:setRedPackageAction( )
	local arr = CCArray:create()
    arr:addObject(CCRotateTo:create(0.05, 5))
    arr:addObject(CCRotateTo:create(0.05, 0))
    arr:addObject(CCRotateTo:create(0.05, -5))
    arr:addObject(CCRotateTo:create(0.05, 0))
    local seq = CCSequence:create(arr)

    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCRepeat:create(seq, 2))
    actionArrayIn:addObject(CCDelayTime:create(3))
    local ccsequence = CCRepeatForever:create(CCSequence:create(actionArrayIn))
    self._ccbOwner.sp_redPackage:runAction(ccsequence)
end

function QUIDialogActivitySkyFall:initRedPackage()
	local packageSize = CCSize(90,110)
	self._containNum = math.floor((self._size.width - packageSize.width*2 )/packageSize.width)
	self._cellWidth = (self._size.width - packageSize.width*2 )/self._containNum
	self._redPackageDownWidget = {}
	for i=1,self._containNum do
		local packageCard = QUIWidgetRedPackage.new()
		packageCard:setOpacity(0)
		packageCard:addEventListener(QUIWidgetRedPackage.EVENT_TOUCH_CLICK, handler(self, self.openRedpackageEvent))
		packageCard:setPositionY(self._size.height/2+packageSize.height)
		self._ccbOwner.node_redpackage:addChild(packageCard)
		self._redPackageDownWidget[i] = packageCard
	end
end

function QUIDialogActivitySkyFall:_onTodayTokenUpdate(tokenNum)
	self._ccbOwner.node_today_token:removeAllChildren()
	self._totalForceNumWidth = 0
    local forceStr = tostring(math.ceil(tokenNum))
    local strLen = string.len(forceStr)
    for i = 1, strLen, 1 do
        local num = tonumber(string.sub(forceStr, i, i))
        if num == 0 then num = 10 end
        local paths = QResPath("activity_sky_fall_num")
        local spNum = CCSprite:create(paths[num])
        self._ccbOwner.node_today_token:addChild(spNum)
        local width = spNum:getContentSize().width
        spNum:setPosition(self._totalForceNumWidth + width/2, 0)
        self._totalForceNumWidth = self._totalForceNumWidth + width
    end	
    self._ccbOwner.node_today_token:setPositionX(-self._totalForceNumWidth/2)
end

function QUIDialogActivitySkyFall:_updateTodayLastTimes(times)
	self._ccbOwner.tf_today_lastTime:setString(string.format("（剩余次数：%d次）",times))
end

function QUIDialogActivitySkyFall:_updateRedPackageTips()
	if self._lastOpenCount > 0 then
		self._ccbOwner.not_open_effect:setVisible(true)
		self._ccbOwner.tf_dianji_tips:setVisible(true)
		self._ccbOwner.node_open:setVisible(false)
	else
		self._ccbOwner.not_open_effect:setVisible(false)
		self._ccbOwner.tf_dianji_tips:setVisible(false)
		self._ccbOwner.node_open:setVisible(true)
		self._ccbOwner.sp_redPackage:stopAllActions()
	end
    if self._activitySkyFallProxy.showEndAt - q.serverTime() <= DAY then
    	self._ccbOwner.tf_dianji_tips:setString("天降红包活动已结束")
		self._ccbOwner.not_open_effect:setVisible(false)
		self._ccbOwner.tf_dianji_tips:setVisible(true)
		self._ccbOwner.node_open:setVisible(false)   
		self._ccbOwner.sp_redPackage:stopAllActions() 	
    end	
end

function QUIDialogActivitySkyFall:checkCanShowRedPackageDown( )
	-- if not self._activitySkyFallProxy:checkCanOpen() then
	-- 	app.tip:floatTip("天降红包结算中，无法领取")
	-- 	self:popSelf()
	-- 	return true
	-- end

	if self._activitySkyFallProxy.showEndAt - q.serverTime() <= DAY then --活动结束不能显示红包掉落界面
		self._ccbOwner.node_packageDown:setVisible(false)
    	self._redPackageDownIng = false
    	self:updateAwardsTipsState(true)	
	    if self._textureCacheScheduler then
		    scheduler.unscheduleGlobal(self._textureCacheScheduler)
		    self._textureCacheScheduler = nil	
	    end	    	
	end

	return false
end

function QUIDialogActivitySkyFall:setActivityTime()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	local endTime = self._activitySkyFallProxy.endAt or 0

	local timeFunc
	timeFunc = function ( )
		local lastTime = endTime - q.serverTime()
		if self:safeCheck() then
			if lastTime > 0 then
				local timeStr = q.timeToDayHourMinute(lastTime)
				self._ccbOwner.tf_endTime:setString("活动"..timeStr.."后结束")
			else
				if self._timeScheduler then
					scheduler.unscheduleGlobal(self._timeScheduler)
					self._timeScheduler = nil
				end
				self._ccbOwner.tf_endTime:setString("活动已结束")
				self:checkCanShowRedPackageDown()
			end
		end
	end

	self._timeScheduler = scheduler.scheduleGlobal(timeFunc, 1)
	timeFunc()
end

function QUIDialogActivitySkyFall:setTimeCountdown()
    if self._timeNextScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeNextScheduler)
        self._timeNextScheduler = nil
    end

    local tipStr = " 揭晓今日锦鲤"
    if self._activitySkyFallProxy.showEndAt - q.serverTime() <= DAY then
    	tipStr = " 后奖励领取结束"
    end
    local leftTime = q.getLeftTimeOfDay()
    local timeDownFunction = function()
    	if self:safeCheck() then
	    	if leftTime >= 0 then
	    		local timeDesc = q.timeToHourMinuteSecond(leftTime)
	        	self._ccbOwner.tf_next_time:setString(timeDesc..tipStr)
	        	leftTime = leftTime - 1
	        else
				self._activitySkyFallProxy:requestMySkyFallInfo(function()
					if self:safeCheck() then
	        			self:updateInfo()
	        		end
	        	end)
	        end
	    end
    end
    timeDownFunction()
    self._timeNextScheduler = scheduler.scheduleGlobal(timeDownFunction, 1)
end

function QUIDialogActivitySkyFall:updateRankInfo( )
	local rankInfo = self._activitySkyFallProxy:getRankAwardsInfo()
	local showLabel = function(isFlag)
		for i=1,3 do
			if self._ccbOwner["tf_rank_"..i] then
				self._ccbOwner["tf_rank_"..i]:setVisible(not isFlag)
			end
			if self._ccbOwner["node_have_awards"..i] then
				self._ccbOwner["node_have_awards"..i]:setVisible(isFlag)
			end
		end
	end

	if q.isEmpty(rankInfo) then
		self._ccbOwner.sp_yesterday:setVisible(false)
		showLabel(false)
	else
		self._ccbOwner.sp_yesterday:setVisible(true)
		showLabel(true)
	end

	for i=1,3 do
		local item = self._rankAwardsItemBoxs[i]
		if item then
			local itemType = remote.items:getItemType(self._rankAwardsInfo[i].itemId)
			-- self._ccbOwner["node_awrds_"..i]:addChild(item)
			item:setGoodsInfo(self._rankAwardsInfo[i].itemId, itemType or ITEM_TYPE.ITEM, tonumber(self._rankAwardsInfo[i].count))
			item:setPromptIsOpen(true)
			item:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
		end
		if rankInfo[i] then
			self._ccbOwner["tf_token_num"..i]:setString(rankInfo[i].getToken)
			self._ccbOwner["tf_player_name"..i]:setString(rankInfo[i].nickname)
		else
			self._ccbOwner["tf_token_num"..i]:setString("")
			self._ccbOwner["tf_player_name"..i]:setString("")
		end
	end
end

function QUIDialogActivitySkyFall:updateAwardsTipsState(boo)
	for i=1,3 do
		local item = self._rankAwardsItemBoxs[i]
		if item then
			item:setPromptIsOpen(boo)
		end
	end
end
function QUIDialogActivitySkyFall:updateInfo()
	self:checkCanShowRedPackageDown()
	-- -- -- 活动时间已过
	-- if self._activitySkyFallProxy.showEndAt and q.serverTime() > self._activitySkyFallProxy.showEndAt then
 --    	app.tip:floatTip("活动已结束，敬请期待下次活动")
 --    	self:popSelf()
 --    	return
	-- end

	self._skyfallInfo = self._activitySkyFallProxy:getActivitySkyFallInfo()
	if q.isEmpty(self._skyfallInfo) then
		return
	end

	self._awardsData,self._totalScore = self._activitySkyFallProxy:getCurRoundAwards()

	local totalToken = self._skyfallInfo.totalGetToken or 0

	self._ccbOwner.tf_scroe:setString(totalToken)
	self._getDatas = {}
	local progress = 0
	for i,v in pairs(self._awardsData) do
		local isGet = false
		for _,index in pairs(self._skyfallInfo.getScoreIdList or {}) do
			if index == v.id then
				isGet = true
				break
			end
		end
		self._getDatas[i] = isGet
		if isGet then
			self._ccbOwner["node_light"..i]:setVisible(false)
			self._ccbOwner["node_close"..i]:setVisible(false)
			self._ccbOwner["node_open"..i]:setVisible(true)			
		else
			self._ccbOwner["node_close"..i]:setVisible(true)
			self._ccbOwner["node_open"..i]:setVisible(false)
			self._ccbOwner["node_light"..i]:setVisible(totalToken >= v.condition)
		end
		if totalToken >= v.condition then
			progress = i
		end
	end

	for i,v in pairs(self._awardsData) do
		self._ccbOwner["node_"..i]:setVisible(true)
		self._ccbOwner["tf_"..i]:setString(v.condition)
		self._ccbOwner["node_"..i]:setPositionX(v.condition/self._totalScore*self._totalBarWidth + self._totalBarPosX)
	end
	local posX = 0
	local stencil = self._percentBarClippingNode:getStencil()
	if progress == 5 then
		posX = 0
	else
		posX = -self._totalBarWidth + totalToken/self._totalScore*self._totalBarWidth
	end
	stencil:setPositionX(posX)

	self:_updateRedPackageTips()

end

function QUIDialogActivitySkyFall:_onTriggerOpenGrabPackage( )
	if self._redPackageDownIng then
		return
	end
	if self._openPackageAction then
		return
	end
	if self._lastOpenCount <= 0 then
		app.tip:floatTip("今日红包已领取~")
		return
	end
	
	if self._activitySkyFallProxy.showEndAt - q.serverTime() <= DAY then
		app.tip:floatTip("活动已结束~")
		return
	end

	self._openPackageAction = true
	self._ccbOwner.sp_redPackage:stopAllActions()

	local arr = CCArray:create()
    arr:addObject(CCRotateTo:create(0.05, 10))
    arr:addObject(CCRotateTo:create(0.05, 0))
    arr:addObject(CCRotateTo:create(0.05, -10))
    arr:addObject(CCRotateTo:create(0.05, 0))
    local seq = CCSequence:create(arr)

    local actionArrayIn = CCArray:create()
    actionArrayIn:addObject(CCRepeat:create(seq, 4))
    actionArrayIn:addObject(CCCallFunc:create(function ()
	    local fcaAnimation = QUIWidgetFcaAnimation.new("fca/tx_hongbaobg_effect", "res")
		fcaAnimation:playAnimation("animation", false)
		self._ccbOwner.node_effect:addChild(fcaAnimation)
		fcaAnimation:setEndCallback(function( )
			fcaAnimation:removeFromParent()
			self._redPackageDownIng = true
			self:updateAwardsTipsState(false)
			self._openPackageAction = false
			self:redPackageDown()
		end)
    end))
    local ccsequence = CCSequence:create(actionArrayIn)
    self._ccbOwner.sp_redPackage:runAction(ccsequence)	
end

function QUIDialogActivitySkyFall:redPackageDown()
	self._ccbOwner.node_packageDown:setVisible(true)
	self:_updateTodayLastTimes(self._lastOpenCount)
	self:beginRedPackageDown()
	self._textureCacheScheduler = scheduler.scheduleGlobal(handler(self, self.beginRedPackageDown), 0.4)
end

function QUIDialogActivitySkyFall:beginRedPackageDown()
	if self:safeCheck() then
		local randomNum = math.random(1,self._containNum)
		local searchNotDowning = function()
			for i=1,self._containNum do
				if not self._redPackageDownWidget[i]:getIsDowning() then
					return i
				end
			end
			return math.random(1,self._containNum)
		end

		if self._redPackageDownWidget[randomNum]:getIsDowning() then
			randomNum = searchNotDowning()
		end

		local isEven = randomNum%2 == 0 
		self._randomNum = randomNum
		local flagNum = isEven and 1 or -1
		local startX = self._cellWidth * (self._randomNum/2) * flagNum

		local startY = self._size.height/2 + 110
		self._redPackageDownWidget[self._randomNum]:setStartPosition(ccp(startX,startY))
		self._redPackageDownWidget[self._randomNum]:runDownAction()
	end
end

function QUIDialogActivitySkyFall:boxTriggerHandler(index)
	if self._redPackageDownIng then
		return
	end		
	local data = self._awardsData[index]
	if q.isEmpty(data) then return end 
	if self._getDatas[index] == false and self._skyfallInfo.totalGetToken >= data.condition then
		--请求获取
		self._activitySkyFallProxy:playerGetSocreAwardsRequest({data.id}, function (data)
			local awards = {}
			local prizes = data.prizes or {}
			for _,item in pairs(prizes) do
	            local typeName = remote.items:getItemType(item.type)
	            table.insert(awards, {typeName = typeName, id = item.id, count = item.count})
			end
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    			options = {awards = awards, callBack = function ()
 					if self:safeCheck() then
 						self:updateInfo()
 					end
	    		end}},{isPopCurrentDialog = false} )
	    	dialog:setTitle("恭喜您获得钻石累计奖励")
		end)
	else
		local tips = {
            {oType = "font", content = "领取条件：累计获得",size = 20,color = ccc3(114,82,63)},
            {oType = "font", content = data.condition,size = 20,color = ccc3(109,57,29)},
            {oType = "font", content = "钻石",size = 20,color = ccc3(114,82,63)},
        }
		app:luckyDrawAlert(data.reward_id, tips, nil, false)
	end
end

function QUIDialogActivitySkyFall:openRedpackageEvent(event)
	if event.name == QUIWidgetRedPackage.EVENT_TOUCH_CLICK then
		if self._lastOpenCount <= 0 then
			return
		end
		local maxTimes = #self._tokenNums
		self._lastOpenCount = self._lastOpenCount - 1
		local contentStr = string.format("X%d",self._tokenNums[maxTimes-self._lastOpenCount].num)
		self:_updateTodayLastTimes(self._lastOpenCount)

		print("红包tips位置显示----",event.posX,event.posY)
		app.tip:skyfloatAward(contentStr,event.posX,event.posY)
		self._allTokenNum = self._allTokenNum + self._tokenNums[maxTimes-self._lastOpenCount].num

		if self._lastOpenCount == 0 then
			scheduler.performWithDelayGlobal(function()
				if self:safeCheck() then
					self:showEndTokenTipsAction()
					self._ccbOwner.node_packageDown:setVisible(false)
				    if self._textureCacheScheduler then
					    scheduler.unscheduleGlobal(self._textureCacheScheduler)
					    self._textureCacheScheduler = nil	
				    end	
				end
			end,0.6)		
		end
		self._activitySkyFallProxy:playerOpenRedPackageRequest({self._tokenNums[maxTimes-self._lastOpenCount].id},function()
			if self:safeCheck() then
				self:updateInfo()
			end
		end)
	end
end

function QUIDialogActivitySkyFall:showEndTokenTipsAction( )
	self._ccbOwner.node_tips:setVisible(true)
	self._ccbOwner.node_tips:setScale(0)
	self._ccbOwner.tf_words1:setString("获得钻石总数:"..self._allTokenNum)
	local targetPosX = self._ccbOwner.node_open:getPositionX()
	local targetPosY = self._ccbOwner.node_open:getPositionY()
	local arr1 = CCArray:create()
	arr1:addObject(CCScaleTo:create(0.2,1))
	arr1:addObject(CCDelayTime:create(1))
	local arr2 = CCArray:create()
	arr2:addObject(CCMoveTo:create(0.5, ccp(targetPosX,targetPosY - 50)))
	arr2:addObject(CCScaleTo:create(0.3,0))
	arr1:addObject(CCSpawn:create(arr2))
    arr1:addObject(CCCallFunc:create(function()
		local ccbFile = "effects/tx_baoguang_effect.ccbi"
		local effect = QUIWidget.new(ccbFile)
		effect:setScale(0.1)
		self._ccbOwner.node_tips_effect:addChild(effect)
	    local dur2 = q.flashFrameTransferDur(6)
		local arr = CCArray:create()
	    arr:addObject(CCDelayTime:create(dur2))
	    arr:addObject(CCCallFunc:create(function()
	    	if self:safeCheck() then
		    	effect:stopAllActions()
		    	effect:removeFromParent()
		    	self._redPackageDownIng = false
		    	self:updateAwardsTipsState(true)
		    	self._tokenNumUpdate:addUpdate(self._todayGetToken, self._todayGetToken + self._allTokenNum, handler(self, self._onTodayTokenUpdate), 0.5)
	    	end
	    end))
		effect:runAction(CCSequence:create(arr))
    end))

    self._ccbOwner.node_tips:runAction(CCSequence:create(arr1))
end

function QUIDialogActivitySkyFall:_onTriggerBox1(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(1)
end

function QUIDialogActivitySkyFall:_onTriggerBox2(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(2)
end

function QUIDialogActivitySkyFall:_onTriggerBox3(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(3)
end

function QUIDialogActivitySkyFall:_onTriggerBox4(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(4)
end

function QUIDialogActivitySkyFall:_onTriggerBox5(event)
    app.sound:playSound("common_small")
	self:boxTriggerHandler(5)
end

function QUIDialogActivitySkyFall:_backClickHandler()
	if self._redPackageDownIng then
		return
	end
    self:_onTriggerClose()
end

function QUIDialogActivitySkyFall:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivitySkyFall:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivitySkyFall
