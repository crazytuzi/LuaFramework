-- @Author: liaoxianbo
-- @Date:   2020-01-17 17:17:30
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-17 18:32:46
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChestGoldOrSilver = class("QUIWidgetChestGoldOrSilver", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QUIDialogTavernAchieve = import("..dialogs.QUIDialogTavernAchieve")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetChestGoldOrSilver.EVENT_SLIVER_CLICK = "EVENT_SLIVER_CLICK"
QUIWidgetChestGoldOrSilver.EVENT_GOLD_CLICK = "EVENT_GOLD_CLICK"

function QUIWidgetChestGoldOrSilver:ctor(options)
	local ccbFile = "ccb/Widget_TreasureChestDtraw_new.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetChestGoldOrSilver.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._index = options.index or 1
end

function QUIWidgetChestGoldOrSilver:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote.user)
    self._remoteProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))

    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(remote.activity.EVENT_UPDATE, handler(self, self.onEvent))

    if self._index == 1 then
    	self:initSliver()
    else
    	self:initGold()
    end
end

function QUIWidgetChestGoldOrSilver:onExit()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
    if self.animationScheduler ~= nil then
        scheduler.unscheduleGlobal(self.animationScheduler)
        self.animationScheduler = nil
    end
	self._remoteProxy:removeAllEventListeners()
    self._activityProxy:removeAllEventListeners()

end

function QUIWidgetChestGoldOrSilver:_resetAll()
	-- front
	self._ccbOwner.node_gold_state:setVisible(false)
	self._ccbOwner.node_silver_state:setVisible(false)
	self._ccbOwner.tf_silver_free_label:setString("")
	self._ccbOwner.tf_silver_free:setString("")
	self._ccbOwner.silver_count:setString("")
	self._ccbOwner.tf_sliver_content:setString("")
		
	self._ccbOwner.silver_free_tip:setVisible(false)
	self._ccbOwner.tf_countdown:setString("")
end

function QUIWidgetChestGoldOrSilver:initSliver()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
    self:_resetAll()

	local config = db:getConfiguration()
	self._silverCount = config.LUCKY_DRAW_COUNT.value or 0 -- 白银宝箱的次数
	self._silverTime = config.LUCKY_DRAW_TIME.value or 0 -- 白银宝箱的CD时间
	self._silverCost = config.LUCKY_DRAW_MONEY_COST.value or 0 -- 白银宝箱购买所需银币数量
	self._silverCurrTime = 0
	self._callCardNum = 0
	self._itemId = 23
   	self._callCardNum = remote.items:getItemsNumByID(self._itemId)
	self._freeSilverCount = remote.user.todayLuckyDrawFreeCount or 0
	self._lastTime = (remote.user.luckyDrawRefreshedAt or 0)/1000

	self._CDTime = self._silverTime * 60
	local currTime = q.serverTime()

	if q.refreshTime(remote.user.c_systemRefreshTime) > self._lastTime then
		self._freeSilverCount = self._silverCount
	else
		self._freeSilverCount = self._silverCount - self._freeSilverCount
	end
	
	if self._freeSilverCount == self._silverCount or (self._freeSilverCount > 0 and (currTime - self._lastTime) >= self._CDTime) then
		self:showFree()
	else
		self:setCallCardNum()
	end

	self:neddNum()
end

function QUIWidgetChestGoldOrSilver:initGold()
    self:_resetAll()
	local config = db:getConfiguration()

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
		self._ccbOwner.silver_free_tip:setVisible(true)
	end
	if self:checkTavernAward() then
		self._ccbOwner.silver_free_tip:setVisible(true)
	end	
end

function QUIWidgetChestGoldOrSilver:setCallCardNum()	
	-- front
	self._ccbOwner.tf_silver_free_label:setString("")
    self._ccbOwner.tf_silver_free:setString("")

    if self._callCardNum >= 10 then
		self._ccbOwner.silver_free_tip:setVisible(true)
	end

	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end	
	if self._freeSilverCount > 0 then
		self._timeFun = function ()
			local offsetTime = q.serverTime() - self._lastTime
			if offsetTime < self._CDTime then
				local date = q.timeToHourMinuteSecond(self._CDTime - offsetTime)
				self._ccbOwner.tf_countdown:setString(date.." 后免费")
			else
				self:init()
			end
			self._timeHandler = scheduler.performWithDelayGlobal(self._timeFun, 1)
		end
		self._timeFun()
	else
		self._ccbOwner.tf_countdown:setString("今日免费次数已用完")
	end
end

function QUIWidgetChestGoldOrSilver:showFree()
	--front
	self._ccbOwner.silver_free_tip:setVisible(true)

	self._ccbOwner.tf_silver_free_label:setString("免费次数：")
	self._ccbOwner.tf_silver_free:setString(self._freeSilverCount.."/"..self._silverCount)
end

function QUIWidgetChestGoldOrSilver:neddNum()
	if self._index == 1 then
		-- 显示还有几次获得魂师碎片
		local count = 10 - (remote.user.totalLuckyDrawNormalCount or 0)%10
		--local isBuyFirstDraw = remote.user.totalLuckyDrawNormalCount == 0
		self._ccbOwner.tf_sliver_content:setString("本次必送")
		self._ccbOwner.silver_count:setString("")
		self._ccbOwner.node_silver_state:setVisible(true)
		self._ccbOwner.node_state2:setVisible(false)
		if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
			self._ccbOwner.node_state2:setVisible(true)
			self._ccbOwner.node_state:setVisible(false)
		elseif count > 1 then
			self._ccbOwner.silver_count:setString(count)
			self._ccbOwner.tf_sliver_content:setString("次后必送")
		end
	else
	end
end

function QUIWidgetChestGoldOrSilver:onEvent(event)
    if self._index == 1 then
    	self:initSliver()
    else
    	self:initGold()
    end
end

function QUIWidgetChestGoldOrSilver:_onTriggerClick(event)
	app.sound:playSound("common_small")
	if self._index == 1 then
		self:dispatchEvent({name = QUIWidgetChestGoldOrSilver.EVENT_SLIVER_CLICK})
	else
		self:dispatchEvent({name = QUIWidgetChestGoldOrSilver.EVENT_GOLD_CLICK})
	end
end

function QUIWidgetChestGoldOrSilver:_onTriggerPreview(e)
    if e ~= nil then app.sound:playSound("common_small") end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
		options = {tavernType = QUIDialogPreview.GENERAL_TAVERN, noSuperAndAPlusHero = true}},{isPopCurrentDialog = false})
end

function QUIWidgetChestGoldOrSilver:_onTriggerHelp()
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCountHelp", 
		options = {helpType = "jiuguan_1"}})
end

function QUIWidgetChestGoldOrSilver:getContentSize()
end

return QUIWidgetChestGoldOrSilver
