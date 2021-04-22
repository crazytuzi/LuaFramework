-- @Author: xurui
-- @Date:   2019-01-21 15:36:55
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-04 12:27:10
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityCarnival = class("QUIDialogActivityCarnival", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetCarnivalDayButton = import("..widgets.QUIWidgetCarnivalDayButton")
local QUIWidgetCarnivalActivityButton = import("..widgets.QUIWidgetCarnivalActivityButton")
local QListView = import("...views.QListView")
local QUIWidgetCarnivalActivityItem = import("..widgets.QUIWidgetCarnivalActivityItem")
local QUIWidgetCarnivalActivityExchange = import("..widgets.QUIWidgetCarnivalActivityExchange")
local QUIWidgetActivityCarnivalDiscountItem = import("..widgets.QUIWidgetActivityCarnivalDiscountItem")
local QUIWidgetCarnivalActivityChest = import("..widgets.QUIWidgetCarnivalActivityChest")

local OFFLINE_TIP = "当前活动已下线"

function QUIDialogActivityCarnival:ctor(options)
	local ccbFile = "ccb/Dialog_Carnival.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogActivityCarnival.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    local defaultDayIndex = remote.activityCarnival:getCurrentDayNum()
    self._activityChestClient = {}          --活动宝箱组件
    self._activityBtnClient = {}          	--活动按钮组件
    self._dayBtnClient = {}          		--天数按钮组件
    self._selectDayBtnIndex = defaultDayIndex    			--当前选中的天数按钮
    self._selectActivityBtnIndex = 1   		--当前选中的活动按钮
    self._curDayActivityInfoList = {}       --当天的活动列表
    self._curActivityInfo = {}       		--当天选中的活动
    self._exchangeActivityDict = {}         --兑换活动信息
    self._curDay = 0						--当前天数
	self._isAwardTime = false
    if options then
    	self._callBack = options.callBack
    	self._selectDayBtnIndex = options.selectDay or defaultDayIndex
    	self._selectActivityBtnIndex = options.selectActivity or 1
    end

	self:initActivityListView()

    self._totalBarWidth = self._ccbOwner.sp_bar_progress:getContentSize().width * self._ccbOwner.sp_bar_progress:getScaleX()
    self._totalBarPosX = self._ccbOwner.sp_bar_progress:getPositionX()

    self._percentBarClippingNode = q.newPercentBarClippingNode(self._ccbOwner.sp_bar_progress)
end

function QUIDialogActivityCarnival:viewDidAppear()
	QUIDialogActivityCarnival.super.viewDidAppear(self)

    self._activityProxy = cc.EventProxy.new(remote.activityCarnival)
    self._activityProxy:addEventListener(remote.activityCarnival.UPDATE_CARNIVAL_ACTIVITY, handler(self, self.updateActivityPanel))

	self:updateActivityPanel()
end

function QUIDialogActivityCarnival:viewWillDisappear()
  	QUIDialogActivityCarnival.super.viewWillDisappear(self)
	
	self._activityProxy:removeAllEventListeners()
	self._activityProxy = nil

	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
end

function QUIDialogActivityCarnival:updateActivityPanel()
	local isPopSelf = self:updateActivityInfo()
	if isPopSelf then
		return
	end

	self:initActivityListView()
	
	self:updateExchangeActivity()

	self:setActivityTimeScheduler()

	self:setDayButtonStatus()

	self:setActivityButtonStatus()
end

function QUIDialogActivityCarnival:updateActivityInfo()
	local activitDayList = remote.activityCarnival:getCarnivalActivityDayList()
	self._exchangeActivityDict = remote.activityCarnival:getActivityInfo()
	if q.isEmpty(activitDayList) or q.isEmpty(self._exchangeActivityDict) then
		app.tip:floatTip(OFFLINE_TIP)
		self:popSelfAtNextFrame()
		return true
	end
	self._dayNum = #activitDayList
	self._curDayActivityInfoList = activitDayList[self._selectDayBtnIndex] or {}
	self._curActivityInfo = self._curDayActivityInfoList[self._selectActivityBtnIndex] or {}

	self._curDay = remote.activityCarnival:getCurrentDayNum()
	remote.activity:setActivityTipEveryDay(self._curActivityInfo)
end

function QUIDialogActivityCarnival:setDayButtonStatus()
	for i = 1, 6 do
		self._ccbOwner["node_day"..i]:setVisible(false)
	end

	for i = 1, self._dayNum do
		if self._ccbOwner["node_day"..i] then
			self._ccbOwner["node_day"..i]:setVisible(true)
			if self._dayBtnClient[i] == nil then
				self._dayBtnClient[i] = QUIWidgetCarnivalDayButton.new()
				self._ccbOwner["node_day"..i]:addChild(self._dayBtnClient[i])
				self._dayBtnClient[i]:addEventListener(QUIWidgetCarnivalDayButton.EVENT_CLICK_DAY_BUTTON, handler(self, self._onClickEvent))
			end
			self._dayBtnClient[i]:setInfo(i)
			self._dayBtnClient[i]:setSelectStatus(self._selectDayBtnIndex == i)
		end
	end
end

function QUIDialogActivityCarnival:setActivityButtonStatus()
	for i, value in ipairs(self._curDayActivityInfoList) do
		if self._ccbOwner["node_activity_btn_"..i] then
			if self._activityBtnClient[i] == nil then
				self._activityBtnClient[i] = QUIWidgetCarnivalActivityButton.new()
				self._ccbOwner["node_activity_btn_"..i]:addChild(self._activityBtnClient[i])
				self._activityBtnClient[i]:addEventListener(QUIWidgetCarnivalActivityButton.EVENT_CLICK_ACTIVITY_BUTTON, handler(self, self._onClickEvent))
			end
			self._activityBtnClient[i]:setInfo(value, i)
			self._activityBtnClient[i]:setSelectStatus(self._selectActivityBtnIndex == i)
		end
	end
end

function QUIDialogActivityCarnival:initActivityListView()
    local activitInfo = self._curActivityInfo or {}

    if self._selectActivityBtnIndex ~= 3 then
		if self._discountItem then
			self._discountItem:setVisible(false)
		end
	    local totalNumber = #(activitInfo.targets or {})
	    if not self._activityListView then
		    local cfg = {
		        renderItemCallBack = handler(self, self._renderItemFunc),
		        spaceY = 0,
		        enableShadow = true,
		        topShadow = self._ccbOwner.top_shadow,
		        bottomShadow = self._ccbOwner.down_shadow,
		        ignoreCanDrag = true,
		        totalNumber = totalNumber,
		        curOffset = 10,
		    }  
		    self._activityListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
		else
	        self._activityListView:reload({totalNumber = totalNumber})
		end
		self._activityListView:setVisible(true)
	elseif next(activitInfo) then
		if self._activityListView then
			self._activityListView:setVisible(false)
		end

		if self._discountItem == nil then
			self._discountItem = QUIWidgetActivityCarnivalDiscountItem.new()
			self._ccbOwner.node_sheet:addChild(self._discountItem)
		end
		self._discountItem:setVisible(true)
   		self._discountItem:setInfo(activitInfo.activityId, activitInfo.targets[1], 0, activitInfo, self._curDay)
	end
end

function QUIDialogActivityCarnival:_renderItemFunc(list, index, info )
    -- body
    local isCacheNode = true
    local data = self._curActivityInfo.targets[index]
    if not data then
    	return
    end
    local tag
    if remote.activity:isExchangeActivity(data.type) then
        tag = "exchange"
    end
    local item = list:getItemFromCache(tag)

    if not item then
        if tag then
            if tag == "exchange" then
                item = QUIWidgetCarnivalActivityExchange.new()
            end
        else
            item = QUIWidgetCarnivalActivityItem.new()
        end
        isCacheNode = false
    end

    item:setInfo(data.activityId, data, self, self._curActivityInfo, self._curDay)
    info.item = item
    info.tag = tag
    info.size = item:getContentSize()

    if tag then
        if tag == "exchange" then
            item:registerItemBoxPrompt(index, list)
            list:registerTouchHandler(index,"onTouchListView")
            list:registerBtnHandler(index, "btnExchange", "onTriggerExchange", nil, true)
        end
    else
        list:registerTouchHandler(index,"onTouchListView")
        if data.completeNum == 1 and remote.activity:isRechargeActivity(data.type) then
            list:registerBtnHandler(index,"btn_ok2", "gotoRecharge", nil, true)
        else
            list:registerBtnHandler(index,"btn_ok", "_onTriggerConfirm", nil, true)
            list:registerBtnHandler(index,"btn_go", "_onTriggerGo", nil, true)
        end
    end
    return isCacheNode
end

function QUIDialogActivityCarnival:getContentListView(  )
    return self._activityListView
end

function QUIDialogActivityCarnival:updateExchangeActivity()
	local targets = self._exchangeActivityDict.targets or {}
	table.sort(targets, function(a, b)
			return a.value < b.value
		end)

	local totalNum = targets[#targets].value or 0
	local allTargetsNum = 0
	local curTargetNum = 0
	local totalWidth = self._ccbOwner.sp_bar_progress:getContentSize().width

	for i, value in ipairs(targets) do
		if self._activityChestClient[i] == nil then
			self._activityChestClient[i] = QUIWidgetCarnivalActivityChest.new()
			self._ccbOwner["node_reward"]:addChild(self._activityChestClient[i])
			self._activityChestClient[i]:addEventListener(QUIWidgetCarnivalActivityChest.EVENT_CLICK_CHEST, handler(self, self._onClickEvent))
			self._activityChestClient[i]:setPositionX(totalWidth/totalNum*(value.value or 0) - self._activityChestClient[i]:getContentSize().width/2)
		end
		self._activityChestClient[i]:setInfo(value)
		
		curTargetNum = value.haveNum or value.value
		if allTargetsNum < value.value then
			allTargetsNum = value.value or 0
		end
	end

	if curTargetNum > allTargetsNum then
		curTargetNum = allTargetsNum
	end

	local stencil = self._percentBarClippingNode:getStencil()
	local posX = -self._totalBarWidth + curTargetNum/allTargetsNum*self._totalBarWidth
	stencil:setPositionX(posX)
end

function QUIDialogActivityCarnival:setActivityTimeScheduler()
	local scheduleFunc
	scheduleFunc = function()
		local curTime = q.serverTime()
		local endTime = (self._exchangeActivityDict.end_at or 0) / 1000

		local isAwardTime, awardTime = remote.activityCarnival:checkActivityIsAwardTime()
		local lastTime = endTime - curTime
		if isAwardTime then
			if self._isAwardTime == false then
				self._isAwardTime = true
				self:updateActivityPanel()
			end
			self._ccbOwner.tf_time_time:setString("领奖时间：")
			lastTime = awardTime - curTime
		else
			self._isAwardTime = false
			self._ccbOwner.tf_time_time:setString("活动时间：")
		end
		if lastTime > 0 then
			self._ccbOwner.tf_time:setString(q.timeToDayHourMinute(lastTime) or "")
		else
			if self._timeScheduler then
				scheduler.unscheduleGlobal(self._timeScheduler)
				self._timeScheduler = nil
			end

			app.tip:floatTip(OFFLINE_TIP)
			self:popSelfAtNextFrame()
		end
	end
	scheduleFunc()
	if self._timeScheduler then
		scheduler.unscheduleGlobal(self._timeScheduler)
		self._timeScheduler = nil
	end
	self._timeScheduler = scheduler.scheduleGlobal(scheduleFunc, 1)
end

function QUIDialogActivityCarnival:_clickChestHandler(info)
	if q.isEmpty(info) then return end

    local awards = {}
    local data = string.split(info.awards, "^")
    table.insert(awards, {id = tonumber(data[1]), typeName = ITEM_TYPE.ITEM, count = tonumber(data[2])})
	if info.completeNum == 2 then
		app:getClient():activityCompleteRequest(info.activityId, info.activityTargetId, nil, nil, function ()
	  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	    		options = {awards = awards}},{isPopCurrentDialog = false} )
			dialog:setTitle("恭喜您获得活动奖励")
			remote.activity:setCompleteDataById(info.activityId, info.activityTargetId)
		end)
	else
		app:luckyDrawAlert("", nil, awards)
	end
end

function QUIDialogActivityCarnival:_onClickEvent(event)
	if event == nil then return end

	local index = event.index
	if event.name == QUIWidgetCarnivalDayButton.EVENT_CLICK_DAY_BUTTON then
		if self._curDay + 1 < index then
			app.tip:floatTip(string.format("第%s天开启", index))
		else
			self:getOptions().selectDay = index
			self._selectDayBtnIndex = index
			self:updateActivityPanel()
		end
	elseif event.name == QUIWidgetCarnivalActivityButton.EVENT_CLICK_ACTIVITY_BUTTON then
		self:getOptions().selectActivity = index
		self._selectActivityBtnIndex = index
		self:updateActivityPanel()
	elseif event.name == QUIWidgetCarnivalActivityChest.EVENT_CLICK_CHEST then
		self:_clickChestHandler(event.info)
	end
end

function QUIDialogActivityCarnival:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivityCarnival:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivityCarnival:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogActivityCarnival