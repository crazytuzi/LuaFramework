--
-- Author: wkwang
-- Date: 2014-08-06 18:58:49
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetChestGold = class("QUIWidgetChestGold", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QUIViewController = import("..QUIViewController")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QQuickWay = import("...utils.QQuickWay")
local QUIDialogTavernAchieve = import("..dialogs.QUIDialogTavernAchieve")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")

QUIWidgetChestGold.EVENT_VIEW = "EVENT_VIEW"
QUIWidgetChestGold.EVENT_CLICK = "QUIWidgetChestGold_EVENT_CLICK"

function QUIWidgetChestGold:ctor(options)
	local ccbFile = "ccb/Widget_TreasureChestDtraw_Gold1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
	}
	QUIWidgetChestGold.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetChestGold:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote.user)
    self._remoteProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))
    
    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(remote.activity.EVENT_UPDATE, handler(self, self.onEvent))

    self:init()
end

function QUIWidgetChestGold:onExit()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
    if self.animationScheduler ~= nil then
        scheduler.unscheduleGlobal(self.animationScheduler)
        self.animationScheduler = nil
    end
    self._remoteProxy:removeAllEventListeners()
    self._activityProxy:removeAllEventListeners()
end

function QUIWidgetChestGold:_resetAll()
	-- front
	self._ccbOwner.tf_gold_free_label:setString("")
	self._ccbOwner.tf_gold_free:setString("")
	self._ccbOwner.tf_gold_count:setString("")
	self._ccbOwner.tf_gold_content:setString("")

	self._ccbOwner.gold_free_tip:setVisible(false)

	-- self._ccbOwner.node_definit_hero:setVisible(false)
	-- self._ccbOwner.node_frist:setVisible(false)
	-- self._ccbOwner.node_no_frist:setVisible(false)

	self._ccbOwner.tf_countdown:setString("")
end

function QUIWidgetChestGold:init()
    self:_resetAll()
	local config = QStaticDatabase:sharedDatabase():getConfiguration()

	self._goldCount = 1 -- 黄金宝箱的次数
	self._goldCost = config.ADVANCE_LUCKY_DRAW_TOKEN_COST.value or 0 -- 黄金宝箱购买所需代币数量
	self._goldTenCost = config.ADVANCE_LUCKY_DRAW_10_TIMES_TOKEN_COST.value or 0 -- 黄金宝箱购买所需代币数量
    self._callCardNum = remote.items:getItemsNumByID(24)
	local lastTime = (remote.user.luckyDrawAdvanceRefreshedAt or 0)/1000
	local halfTime = (remote.user.luckyAdvanceHalfPriceRefreshAt or 0)/1000

    self._lastRefreshTime = q.date("*t", q.serverTime())
   	if self._lastRefreshTime.hour < 5 then
   		lastTime = lastTime + DAY
   		halfTime = halfTime + DAY
   	end
	self._lastRefreshTime.hour = 5
    self._lastRefreshTime.min = 0
    self._lastRefreshTime.sec = 0
    self._lastRefreshTime = q.OSTime(self._lastRefreshTime)

    self._isGoldHalf = false
	if lastTime <= self._lastRefreshTime then
		self:showFree()
	elseif halfTime <= self._lastRefreshTime then
    	self._isGoldHalf = true
		self:showHalf()
	else
		self:setCallCardNum()
	end	
    if self._callCardNum >= 10 or (self._callCardNum >= 1 and remote.user.level <= 20) then
		self._ccbOwner.gold_free_tip:setVisible(true)
	end
	if self:checkTavernAward() then
		self._ccbOwner.gold_free_tip:setVisible(true)
	end	

	if self._actorView == nil then
		self._actorView = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("jiuguan_xiaowu", nil, false)
		self._actorView:setPosition(ccp(-60, -210))
		self._actorView:playAnimation(ANIMATION.STAND, true)
		self._ccbOwner.node_avatar:addChild(self._actorView)

		self._actorViewgang = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("jiuguan_tangsan", nil, false)
		self._actorViewgang:setPosition(ccp(15, -210))
		self._actorViewgang:playAnimation("stand", true)
		self._ccbOwner.node_avatar:addChild(self._actorViewgang)

		-- local vertices = {{3, 78}, {3, -14}, {278, -14}, {278, 78}, {380, 78}, {380, 400}, {-130, 400}, {-130, 78}, {3, 78}}
	 --    local drawNode = CCDrawNode:create()
	 --    drawNode:drawPolygon(vertices, {})
	 --    local ccclippingNode = CCClippingNode:create()
	 --    drawNode:setPosition(-136, -91)
	 --    ccclippingNode:setAlphaThreshold(1)
	 --    ccclippingNode:setStencil(drawNode)
	 --    ccclippingNode:addChild(self._actorView)
	 --    self._ccbOwner.node_avatar:addChild(ccclippingNode)
	end
end

function QUIWidgetChestGold:checkTavernAward()
	local scoreConfig = db:getConfigurationValue("WUHUNDIAN_JIFEN_DANGWEI")
	local scores = string.split(scoreConfig, ";")
	local curScore = remote.user.luckydrawAdvanceTotalScore or 0
	local curTurn = remote.user.luckydrawAdvanceRewardRow or 0
	local getBoxStr = remote.user.luckydrawAdvanceRewardGotBoxs or ""
	local getBoxList = string.split(getBoxStr, ";") or {}

	local maxScore = 0
	-- 三档位信息
	for i = 1, #scores do
		if maxScore < tonumber(scores[i]) then
			maxScore = tonumber(scores[i])
		end
	end

	-- 当前轮次积分
	curScore = curScore - curTurn*maxScore
	if curScore > maxScore then
		curScore = maxScore
	end

    -- 是否没被领取
    local hasNotAwardGot = function(luckyId)
		for i, v in pairs(getBoxList) do
			if luckyId == v then
				return false
			end
		end
		return true
	end
	for i = 1, #scores do
		local luckyId = "wuhundianjifen_"..i
		if curScore >= tonumber(scores[i]) and hasNotAwardGot(luckyId) then
			return true
		end
	end
	return false
end

function QUIWidgetChestGold:setCallCardNum()	
	-- front
	self._ccbOwner.tf_gold_free_label:setString("")
    self._ccbOwner.tf_gold_free:setString("")

	self._ccbOwner.tf_countdown:setString("每日5点重置免费次数")
end

function QUIWidgetChestGold:showFree()
	-- front
	self._ccbOwner.gold_free_tip:setVisible(true)
	self._ccbOwner.tf_gold_free_label:setString("免费次数：")
	self._ccbOwner.tf_gold_free:setString("1/1")
end

function QUIWidgetChestGold:showHalf()
	local isShowTips = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.GOLE_CHEST_HALF, 5)
	if isShowTips then
		self._ccbOwner.gold_free_tip:setVisible(true)
	end
	self._ccbOwner.tf_gold_free_label:setString("每日半价：")
	self._ccbOwner.tf_gold_free:setString("1/1")
end

function QUIWidgetChestGold:showBuy()
	-- front
	self._ccbOwner.tf_gold_money:setString(self._goldCost)
	self._ccbOwner.tf_gold_time0:setString("每日5点重置免费次数")

	-- timeHandler
	local refreshTime = self._lastRefreshTime
	local currentTime = q.serverTime()
	refreshTime = refreshTime < currentTime and refreshTime+(24*3600) or refreshTime
	if refreshTime > 0 then
		self._timeHandler = scheduler.performWithDelayGlobal(function()
				self:init()
			end, refreshTime-currentTime)
	end
end

function QUIWidgetChestGold:setNeedNum()
	self._ccbOwner.node_frist:setVisible(true)

	local isBuyFirstDraw = remote.user.totalLuckyDrawAdvanceCount == 0
	if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
		self._ccbOwner.state3:setVisible(true)

	else
		self._ccbOwner.state3:setVisible(false)
		local countAHero = 10 - (remote.user.totalLuckyDrawAdvanceCount or 0)%10
		local countSHero = math.ceil((40 - (remote.user.totalLuckyDrawAdvanceCount or 0)%40)/10)

		if countSHero == 1 then
			-- A 级魂师次数
			if countAHero == 1 then
				self._ccbOwner.state6:setVisible(true)
			else
				self._ccbOwner.state4:setVisible(true)
				self._ccbOwner.tf_count_4:setString(countAHero or 0)
			end
			-- S 级魂师次数
			self._ccbOwner.state7:setVisible(true)
		else
			-- A 级魂师次数
			if isBuyFirstDraw then
				self._ccbOwner.state2:setVisible(true)
			elseif countAHero == 1 and isBuyFirstDraw == false then
				self._ccbOwner.state2:setVisible(true)
			else
				self._ccbOwner.state1:setVisible(true)
				self._ccbOwner.tf_count:setString(countAHero)
			end
			-- S 级魂师次数
			self._ccbOwner.state5:setVisible(true)
			self._ccbOwner.tf_count_5:setString(countSHero or 0)
		end
	end
end

function QUIWidgetChestGold:onEvent(event)
	self:init() 
end

function QUIWidgetChestGold:_onTriggerClick(event)
	app.sound:playSound("common_small")
	-- 去掉半价红点
	if self._isGoldHalf then
		app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.GOLE_CHEST_HALF)
		remote.user.goldIsFree = false
	end
	self:dispatchEvent({name = QUIWidgetChestGold.EVENT_CLICK})
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHero", 
	-- 	options = {tavernType = TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE}})
end

function QUIWidgetChestGold:_onTriggerPreview()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
		options = {tavernType = QUIDialogPreview.HIGH_TAVERN, noSuperAndAPlusHero = false}},{isPopCurrentDialog = false})
end

function QUIWidgetChestGold:_onTriggerHelp()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestHelp"})
end

return QUIWidgetChestGold