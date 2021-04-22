-- @Author: zhouxiaoshu
-- @Date:   2019-08-13 12:20:51
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-04-23 15:16:11
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityPrizeWheel = class("QUIDialogActivityPrizeWheel", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetActivityRewardBox = import("..widgets.QUIWidgetActivityRewardBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QRichText = import("...utils.QRichText")

QUIDialogActivityPrizeWheel.COST_DESC = "每消耗%d体力获赠1张抽奖券"


function QUIDialogActivityPrizeWheel:ctor(options)
	local ccbFile = "ccb/Dialog_prize_wheel.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
        {ccbCallbackName = "onTriggerBox", callback = handler(self, self._onTriggerBox)},
        {ccbCallbackName = "onTriggerRule", callback = handler(self, self._onTriggerRule)},
    }
    QUIDialogActivityPrizeWheel.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page:setScalingVisible(false)
    page.topBar:showWithPrizeWheel()

    self._callback = options.callback
    self._rowNum = 1
	self._itemBox = {}
	self._rewardBox = {}
	self._prizeWheelConfig = {}
	self._prizeAwardConfig = {}
	self._isDrawing = false

	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
	if prizeWheelRound then
    	self._rowNum = prizeWheelRound.rowNum or 1
	end
	
	self:initData()
end

function QUIDialogActivityPrizeWheel:viewDidAppear()
    QUIDialogActivityPrizeWheel.super.viewDidAppear(self)
    self:addBackEvent(false)

    self._userEventProxy = cc.EventProxy.new(remote.user)
   	self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.updateInfo))

    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.PRIZA_WHEEL_UPDATE, handler(self, self.updateInfo))

	self:updateInfo()
end

function QUIDialogActivityPrizeWheel:viewWillDisappear()
    QUIDialogActivityPrizeWheel.super.viewWillDisappear(self)
    self:removeBackEvent()

    self._userEventProxy:removeAllEventListeners()
    self._activityRoundsEventProxy:removeAllEventListeners()

    if self._timeScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end
end

function QUIDialogActivityPrizeWheel:initData()
	local wheelGiftConfig = db:getStaticByName("activity_prize_wheel_gift")
	local prizeWheelConfig = db:getStaticByName("activity_prize_wheel")
	local curPrizeWheelConfig = prizeWheelConfig[tostring(self._rowNum)] or {}
	self._wheelGiftConfig = wheelGiftConfig[tostring(self._rowNum)] or {}
	for i, v in pairs(curPrizeWheelConfig) do
		if v.type == 1 then
			table.insert(self._prizeWheelConfig, v)
		else
			table.insert(self._prizeAwardConfig, v)
		end
	end
	table.sort( self._prizeWheelConfig, function(a, b)
		return a.id < b.id
	end )
	table.sort( self._prizeAwardConfig, function(a, b)
		return a.number < b.number
	end )

	for i, v in pairs(self._prizeWheelConfig) do
		local rewardBox = QUIWidgetActivityRewardBox.new()
		self._ccbOwner["node_icon_"..i]:removeAllChildren()
		self._ccbOwner["node_icon_"..i]:addChild(rewardBox)
		self._itemBox[i] = rewardBox
	end

	local totalWidth = self._ccbOwner.sp_bar_bg:getContentSize().width
	local rewardCount = #self._prizeAwardConfig
	self._maxNumber = self._prizeAwardConfig[rewardCount].number
	for i, v in pairs(self._prizeAwardConfig) do
		local posX = v.number/self._maxNumber*totalWidth
		local rewardBox = QUIWidgetActivityRewardBox.new()
		rewardBox:addEventListener(QUIWidgetActivityRewardBox.EVENT_CLICK, handler(self, self._onGetReward))
		rewardBox:setScale(0.6)
		rewardBox:setPosition(ccp(posX, 10))
		self._ccbOwner.node_reward:addChild(rewardBox)
		self._rewardBox[i] = rewardBox
	end

	if not self._avatar then
		local heroInfo = {skinId = 4}
		self._avatar = QUIWidgetHeroInformation.new()
		self._avatar:setBackgroundVisible(false)
		self._avatar:setNameVisible(false)
		self._avatar:setStarVisible(false)
		self._avatar:setAvatarByHeroInfo(heroInfo, 1025, 1.3)
		self._avatar:setRandomActions("common_victory:50;common_walk:50")
        self._avatar:startAutoPlay(10)
		self._avatar:resetAutoPlay()
		self._ccbOwner.node_avatar:addChild(self._avatar)
	end

	local icon = remote.items:getURLForItem(ITEM_TYPE.PRIZE_WHEEL_MONEY, "alphaIcon")
	self._ccbOwner.sp_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(icon))

	self._richText = QRichText.new({}, 370)
	self._richText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_ticket:addChild(self._richText)
    self._ccbOwner.tf_ticket:setVisible(false)



    
end

function QUIDialogActivityPrizeWheel:setTimeCountdown()
    if self._timeScheduler ~= nil then 
        scheduler.unscheduleGlobal(self._timeScheduler)
        self._timeScheduler = nil
    end
	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    local tipStr = " 后转盘奖励重置"
    if prizeWheelRound.showEndAt - q.serverTime() <= DAY then
    	tipStr = " 后活动结束"
    end
    local leftTime = q.getLeftTimeOfDay()
    local timeDownFunction = function()
    	if leftTime >= 0 then
    		local timeDesc = q.timeToHourMinuteSecond(leftTime)
        	self._ccbOwner.tf_time_down:setString(timeDesc..tipStr)
        	leftTime = leftTime - 1
        else
			prizeWheelRound:requestPrizeWheelInfo(function()
				if self:safeCheck() then
        			self:updateInfo()
        		end
        	end)
        end
    end
    timeDownFunction()
    self._timeScheduler = scheduler.scheduleGlobal(timeDownFunction, 1)
end

function QUIDialogActivityPrizeWheel:updateInfo()
	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
   	local prizeWheelInfo = prizeWheelRound:getPrizeWheelInfo() or {}

   	-- 活动时间已过
	if q.serverTime() > prizeWheelRound.showEndAt then
    	app.tip:floatTip("活动已结束，敬请期待下次活动")
    	self:popSelf()
    	return
	end

	local totalDrawCount = prizeWheelInfo.totalDrawCount or 0
	local wheelPrizeGot = prizeWheelInfo.wheelPrizeGot or {}
	local boxPrizeGot = prizeWheelInfo.boxPrizeGot or {}

	local checkFunc = function(getList, id)
		for _, v in pairs(getList) do
			if tonumber(v) == id then
				return true
			end
		end
		return false
	end

	for i, v in pairs(self._prizeWheelConfig) do
		local info = {}
		local isGet = checkFunc(wheelPrizeGot, v.id)
		local awards = remote.items:analysisServerItem(v.reward)
		info.isGet = isGet
		info.effect = v.effect
		info.awards = awards[1]
		self._itemBox[i]:setInfo(info)
		self._itemBox[i]:setHideGet()
	end

	for i, v in pairs(self._prizeAwardConfig) do
		local info = {}
		local isGet = checkFunc(boxPrizeGot, v.id)
		local isComplete = totalDrawCount >= v.number
		local awards = remote.items:analysisServerItem(v.reward)
		info.id = v.id
		info.isGet = isGet
		info.effect = v.effect
		info.isComplete = isComplete
		info.awards = awards[1]
		self._rewardBox[i]:setInfo(info)
		self._rewardBox[i]:setDesc("累计"..v.number.."次")
	end

	local scaleX = totalDrawCount/self._maxNumber
	if scaleX > 1 then
		scaleX = 1
	end
	self._ccbOwner.sp_progress:setScaleX(scaleX)
	self._ccbOwner.tf_draw_count:setString(totalDrawCount)
	local costValue = prizeWheelRound:getCurDropCostNum()
    self._ccbOwner.tf_cost_desc:setString(string.format("每消耗%d体力获赠1张抽奖券", costValue))
	local curLottery = prizeWheelInfo.prizeWheelLottery or 0
	local curConsume = prizeWheelRound:getCurConsumeTicket()
	self._ccbOwner.tf_ticket:setString(curLottery.."/"..curConsume)
	self._richText:setString({
	        {oType = "font", content = "x", size = 24, color = GAME_COLOR_SHADOW.normal, strokeColor = COLORS.Y},
	        {oType = "font", content = tostring(curLottery), size = 24, color = GAME_COLOR_SHADOW.property, strokeColor = COLORS.Y},
	    	{oType = "font", content = "/"..curConsume, size = 24, color = GAME_COLOR_SHADOW.normal, strokeColor = COLORS.Y},
	    })
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.topBar then
    	page.topBar:updateNumByTopBarType(TOP_BAR_TYPE.PRIZE_WHEEL_MONEY, curLottery)
    end

	local startTime = q.timeToYearMonthDayHourMin(prizeWheelRound.startAt or 0)
	local endTime = q.timeToYearMonthDayHourMin(prizeWheelRound.endAt or 0)
	self._ccbOwner.tf_time_desc:setString(startTime.."~\n"..endTime)
	
	local helpRed = prizeWheelRound:checkHelpBoxRedTips()
	self._ccbOwner.sp_red_tips:setVisible(helpRed)
	
	self._ccbOwner.sp_light:stopAllActions()
	self._ccbOwner.sp_light:setVisible(false)
	self._ccbOwner.node_go_effect:stopAnimation()
	self._ccbOwner.node_go_effect:setVisible(false)

	self:setTimeCountdown()
end

function QUIDialogActivityPrizeWheel:showDrawAnimation(positionId, curConsume, callback)
    self._avatar:avatarPlayAnimation("common_long_atk14")

	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
   	local prizeWheelInfo = prizeWheelRound:getPrizeWheelInfo() or {}
	local curLottery = prizeWheelInfo.prizeWheelLottery or 0
	local curConsume = prizeWheelRound:getCurConsumeTicket()
	self._ccbOwner.tf_ticket:setString(curLottery.."/"..curConsume)
	self._richText:setString({
	        {oType = "font", content = "x", size = 24, color = GAME_COLOR_SHADOW.normal, strokeColor = COLORS.Y},
	        {oType = "font", content = tostring(curLottery), size = 24, color = GAME_COLOR_SHADOW.property, strokeColor = COLORS.Y},
	    	{oType = "font", content = "/"..curConsume, size = 24, color = GAME_COLOR_SHADOW.normal, strokeColor = COLORS.Y},
	    })
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.topBar then
    	page.topBar:updateNumByTopBarType(TOP_BAR_TYPE.PRIZE_WHEEL_MONEY, curLottery)
    end

    local totalAngle = 360*8-45*(positionId-1)
	local rotation = CCRotateTo:create(5, totalAngle)
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.5))
    array:addObject(CCEaseSineOut:create(rotation))
    array:addObject(CCCallFunc:create(callback))
    local action = CCSequence:create(array)
	self._ccbOwner.node_draw:runAction(action)
end

function QUIDialogActivityPrizeWheel:showEndAnimation()
	self._isDrawing = false

    local array = CCArray:create()
    array:addObject(CCFadeTo:create(0.5, 100))
    array:addObject(CCFadeTo:create(0.5, 255))
	self._ccbOwner.sp_light:setVisible(true)
	self._ccbOwner.sp_light:runAction(CCRepeatForever:create(CCSequence:create(array)))
	self._ccbOwner.node_go_effect:setVisible(true)
	self._ccbOwner.node_go_effect:playAnimation("animation", false)
    self._avatar:avatarPlayAnimation("common_victory")

	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
	local positionId, awards = prizeWheelRound:getDrawReward()
    local totalAngle = 360*8-45*(positionId-1)
   	self._ccbOwner.node_draw:stopAllActions()
	self._ccbOwner.node_draw:setRotation(totalAngle)
	
	app.tip:awardsTip(awards, "恭喜您获得奖励", function()
		if self:safeCheck() then
			self:updateInfo()
		end
	end)
end

function QUIDialogActivityPrizeWheel:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
	app.sound:playSound("common_small")
	
	if self._isDrawing then
		self:showEndAnimation()
		return
	end
	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
   	local prizeWheelInfo = prizeWheelRound:getPrizeWheelInfo() or {}
	local wheelPrizeGot = prizeWheelInfo.wheelPrizeGot or {}
	if #wheelPrizeGot >= 8 then
		app.tip:floatTip("今日转盘奖励已领完")
		return
	end
	local curLottery = prizeWheelInfo.prizeWheelLottery or 0
	local curConsume = prizeWheelRound:getCurConsumeTicket()
	if curLottery < curConsume then
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.PRIZE_WHEEL_MONEY)
		return
	end
    prizeWheelRound:requestPrizeWheelDraw(function()
	  	local positionId, awards = prizeWheelRound:getDrawReward()
    	if self:safeCheck() and positionId > 0 then
			self._isDrawing = true
			self:showDrawAnimation(positionId, curConsume, function()
				self:showEndAnimation()
        	end)
	    end
  	end)
end

function QUIDialogActivityPrizeWheel:_onGetReward(event)
	if self._isDrawing then
		return
	end
	local info = event.info
	if not info then
		return
	end
	local prizeWheelRound = remote.activityRounds:getPrizaWheel()
    prizeWheelRound:requestPrizeWheelGetPrizeTotal(info.id, function(data)
  		if self:safeCheck() then
    		app:alertAwards({awards = {info.awards}, callback = function()
    			if self:safeCheck() then
    				self:updateInfo()
    			end
    		end})
	    end
	end)
end

function QUIDialogActivityPrizeWheel:_onTriggerBox(event)
	if self._isDrawing then
		return
	end
	if q.buttonEventShadow(event, self._ccbOwner.btn_box) == false then return end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPrizeWheelHelpBox"})
end

function QUIDialogActivityPrizeWheel:_onTriggerRule(event)
	if self._isDrawing then
		return
	end
	app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPrizeWheelRule"})
end

return QUIDialogActivityPrizeWheel
