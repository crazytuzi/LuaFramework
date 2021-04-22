--
-- Author: wkwang
-- Date: 2014-08-06 18:58:49
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetChestSilver = class("QUIWidgetChestSilver", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QUIViewController = import("..QUIViewController")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIDialogTavernAchieve = import("..dialogs.QUIDialogTavernAchieve")
local QQuickWay = import("...utils.QQuickWay")

QUIWidgetChestSilver.EVENT_VIEW = "EVENT_VIEW"
QUIWidgetChestSilver.EVENT_CLICK = "QUIWidgetChestSilver_EVENT_CLICK"

function QUIWidgetChestSilver:ctor(options)
	local ccbFile = "ccb/Widget_TreasureChestDtraw_Silver1.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetChestSilver.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetChestSilver:onEnter()
    self._remoteProxy = cc.EventProxy.new(remote.user)
    self._remoteProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self.onEvent))

    self._activityProxy = cc.EventProxy.new(remote.activity)
    self._activityProxy:addEventListener(remote.activity.EVENT_UPDATE, handler(self, self.onEvent))

    self:init()
end

function QUIWidgetChestSilver:onExit()
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

function QUIWidgetChestSilver:_resetAll()
	-- front
	self._ccbOwner.tf_silver_free_label:setString("")
	self._ccbOwner.tf_silver_free:setString("")
	self._ccbOwner.silver_count:setString("")
	self._ccbOwner.tf_sliver_content:setString("")
	
	self._ccbOwner.silver_free_tip:setVisible(false)
	self._ccbOwner.tf_countdown:setString("")
end


function QUIWidgetChestSilver:init()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
    self:_resetAll()

	local config = QStaticDatabase:sharedDatabase():getConfiguration()
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

	if self._actorView == nil then
		self._actorView = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("jiuguan_liuerlong", nil, false)
		-- self._actorView:setScale(0.54)
		self._actorView:setPosition(ccp(5, -190))
		self._actorView:playAnimation("stand", true)
		self._ccbOwner.node_avatar:addChild(self._actorView)

		self._actorViewgang = QSkeletonViewController:sharedSkeletonViewController():createSkeletonActorWithFile("jiuguan_yuxiaogang", nil, false)
		self._actorViewgang:setPosition(ccp(-46, -135))
		self._actorViewgang:playAnimation("stand", true)
		self._ccbOwner.node_avatar:addChild(self._actorViewgang)

	    -- local layerColor = CCLayerColor:create(ccc4(0,0,0,255), 278, 400)
	    -- local ccclippingNode = CCClippingNode:create()
	    -- layerColor:setPosition(-136, -91)
	    -- ccclippingNode:setAlphaThreshold(1)
	    -- ccclippingNode:setStencil(layerColor)
	    -- ccclippingNode:addChild(self._actorView)
	    -- self._ccbOwner.node_avatar:addChild(ccclippingNode)
	end
end

function QUIWidgetChestSilver:setCallCardNum()	
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

function QUIWidgetChestSilver:showFree()
	--front
	self._ccbOwner.silver_free_tip:setVisible(true)

	self._ccbOwner.tf_silver_free_label:setString("免费次数：")
	self._ccbOwner.tf_silver_free:setString(self._freeSilverCount.."/"..self._silverCount)
end

function QUIWidgetChestSilver:neddNum()
	-- 显示还有几次获得魂师碎片
	local count = 10 - (remote.user.totalLuckyDrawNormalCount or 0)%10
	--local isBuyFirstDraw = remote.user.totalLuckyDrawNormalCount == 0
	self._ccbOwner.tf_sliver_content:setString("本次必送")
	self._ccbOwner.silver_count:setString("")
	self._ccbOwner.node_state:setVisible(true)
	self._ccbOwner.node_state2:setVisible(false)
	if app.tutorial:isTutorialFinished() == false and app.tutorial:getStage().forced == 1 then
		self._ccbOwner.node_state2:setVisible(true)
		self._ccbOwner.node_state:setVisible(false)
	elseif count > 1 then
		self._ccbOwner.silver_count:setString(count)
		self._ccbOwner.tf_sliver_content:setString("次后必送")
	end
end

function QUIWidgetChestSilver:onEvent(event)
	self:init()
end

function QUIWidgetChestSilver:_onTriggerClick(event)
	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetChestSilver.EVENT_CLICK})
	-- app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHero", 
	-- 	options = {tavernType = TAVERN_SHOW_HERO_CARD.SILVER_TAVERN_TYPE}})
end

function QUIWidgetChestSilver:_onTriggerPreview(e)
    if e ~= nil then app.sound:playSound("common_small") end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPreview", 
		options = {tavernType = QUIDialogPreview.GENERAL_TAVERN, noSuperAndAPlusHero = true}},{isPopCurrentDialog = false})
end

function QUIWidgetChestSilver:_onTriggerHelp()
    app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVritualBuyCountHelp", 
		options = {helpType = "jiuguan_1"}})
end

return QUIWidgetChestSilver