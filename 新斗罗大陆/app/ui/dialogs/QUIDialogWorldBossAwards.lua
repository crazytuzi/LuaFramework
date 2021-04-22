-- @Author: xurui
-- @Date:   2016-10-24 10:13:06
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-06 20:56:55
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBossAwards = class("QUIDialogWorldBossAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetWolrdBossAwardsClient = import("..widgets.QUIWidgetWolrdBossAwardsClient")
local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")

QUIDialogWorldBossAwards.GLOTY_TAB = "GLOTY_TAB"
QUIDialogWorldBossAwards.UNION_TAB = "UNION_TAB"
QUIDialogWorldBossAwards.KILL_TAB = "KILL_TAB"

function QUIDialogWorldBossAwards:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_Boss_jiangli.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGloryAwards", callback = handler(self, self._onTriggerGloryAwards)},
		{ccbCallbackName = "onTriggerUnionAwards", callback = handler(self, self._onTriggerUnionAwards)},
		{ccbCallbackName = "onTriggerKillAwards", callback = handler(self, self._onTriggerKillAwards)},
		{ccbCallbackName = "onTriggerGetAll", callback = handler(self, self._onTriggerGetAll)},
	}
	QUIDialogWorldBossAwards.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	if options then
		self._tab = options.tab or QUIDialogWorldBossAwards.GLOTY_TAB
	end

	self._awrdsItem = {}
	self._data = {}
	self._condition = 0
	self._index = 1
	self._awardsAlert = {}

	self:resetRedTips()
end

function QUIDialogWorldBossAwards:viewDidAppear()
	QUIDialogWorldBossAwards.super.viewDidAppear(self)
end

function QUIDialogWorldBossAwards:viewAnimationInHandler()
	QUIDialogWorldBossAwards.super.viewAnimationInHandler(self)
	self:initScrollView()
	self:selectTab()
	self:checkRedTips()
end

function QUIDialogWorldBossAwards:viewWillDisappear()
	QUIDialogWorldBossAwards.super.viewWillDisappear(self)

    app.tutorialNode:removeAllChildren()
end

function QUIDialogWorldBossAwards:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)
	self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogWorldBossAwards:selectTab()
	self:getOptions().tab = self._tab

	self._scrollView:clear()
	self:_setButtonState()

	local titleFormat = ""
	local worldBossInfo = remote.worldBoss:getWorldBossInfo()

	if self._tab == QUIDialogWorldBossAwards.GLOTY_TAB then
		self._condition = math.floor((worldBossInfo.allHurt or 0)/1000)
		self._data = remote.worldBoss:getAwardsData(1)
		titleFormat = "累计荣誉达到%s可领取"
	elseif self._tab == QUIDialogWorldBossAwards.UNION_TAB then
		self._condition = math.floor((worldBossInfo.consortiaTotalHurt or 0)/1000)
		self._data = remote.worldBoss:getAwardsData(3)
		titleFormat = "累计荣誉达到%s可领取"
	elseif self._tab == QUIDialogWorldBossAwards.KILL_TAB then
		self._condition = (worldBossInfo.bossLevel or 1)-1 
		self._data = remote.worldBoss:getAwardsData(2)
		titleFormat = "击杀%s级BOSS后可领取"
	end

	self:setClientInfo(titleFormat)
end

function QUIDialogWorldBossAwards:setClientInfo(titleFormat)
	local itemContentSize, buffer = self._scrollView:setCacheNumber(4, "widgets.QUIWidgetWolrdBossAwardsClient")
	for _, value in pairs(buffer) do
		value:addEventListener(QUIWidgetWolrdBossAwardsClient.EVENT_CLICK, handler(self, self._clickAwardsClient))
		table.insert(self._awrdsItem, value)
	end

	local row = 0
	local line = 0
	local lineDistance = 0
	local offsetX = -2
	local offsetY = 0
	for i = 1, #self._data do
		local positionX = offsetX
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY

		local num1, str1 = q.convertLargerNumber(self._data[i].meritorious_service)
		local num2, str2 = q.convertLargerNumber(self._condition)
		local num3, str3 = q.convertLargerNumber(self._data[i].meritorious_service)
		local titleString = string.format(titleFormat, num1..(str1 or ""))
		local rankString = string.format("进度：%s/%s", num2..(str2 or ""), num3..(str3 or ""))

		self._scrollView:addItemBox(positionX, positionY, {awardInfo = self._data[i], condition = self._condition, index = i, titleString = titleString, rankString = rankString})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogWorldBossAwards:_setButtonState()
	self._ccbOwner.btn_glory:setHighlighted(false)
	self._ccbOwner.btn_glory:setEnabled(true)
	self._ccbOwner.btn_union:setHighlighted(false)
	self._ccbOwner.btn_union:setEnabled(true)
	self._ccbOwner.btn_kill:setHighlighted(false)
	self._ccbOwner.btn_kill:setEnabled(true)

	if self._tab == QUIDialogWorldBossAwards.GLOTY_TAB then
		self._ccbOwner.btn_glory:setHighlighted(true)
		self._ccbOwner.btn_glory:setEnabled(false)
	elseif self._tab == QUIDialogWorldBossAwards.UNION_TAB then
		self._ccbOwner.btn_union:setHighlighted(true)
		self._ccbOwner.btn_union:setEnabled(false)
	elseif self._tab == QUIDialogWorldBossAwards.KILL_TAB then
		self._ccbOwner.btn_kill:setHighlighted(true)
		self._ccbOwner.btn_kill:setEnabled(false)
	end
end

function QUIDialogWorldBossAwards:resetRedTips()
	self._ccbOwner.honor_award_tips:setVisible(false)
	self._ccbOwner.union_award_tips:setVisible(false)
	self._ccbOwner.kill_award_tips:setVisible(false)
end

function QUIDialogWorldBossAwards:checkRedTips()
	self._ccbOwner.honor_award_tips:setVisible(remote.worldBoss:checkAwardsState(1))
	self._ccbOwner.union_award_tips:setVisible(remote.worldBoss:checkAwardsState(3))
	self._ccbOwner.kill_award_tips:setVisible(remote.worldBoss:checkAwardsState(2))
end

function QUIDialogWorldBossAwards:_clickAwardsClient(event)
	if self._isMoveing then return end
	if event.awardInfo and event.awardInfo.state == remote.worldBoss.AWARDS_IS_READY then
		self:requestAwards({event.awardInfo.id}, true)
	end
end

function QUIDialogWorldBossAwards:requestAwards(ids, isClick)
	local isClick = isClick
	if self._tab == QUIDialogWorldBossAwards.GLOTY_TAB then
		remote.worldBoss:requestWorldBossGloryAwards(ids, function(data)
				app.taskEvent:updateTaskEventProgress(app.taskEvent.WORLD_BOSS_AWARD_COUNT_EVENT, #ids)
				if self:safeCheck() then
					self:receiveAwardSuccess(data, isClick)
				end
			end)
	elseif self._tab == QUIDialogWorldBossAwards.UNION_TAB then
		remote.worldBoss:requestWorldBossUnionGloryAwards(ids, function(data)
				app.taskEvent:updateTaskEventProgress(app.taskEvent.WORLD_BOSS_AWARD_COUNT_EVENT, #ids)
				if self:safeCheck() then
					self:receiveAwardSuccess(data, isClick)
				end
			end)
	else
		remote.worldBoss:requestWorldBossKillAwards(ids, function(data)
				app.taskEvent:updateTaskEventProgress(app.taskEvent.WORLD_BOSS_AWARD_COUNT_EVENT, #ids)
				if self:safeCheck() then
					self:receiveAwardSuccess(data, isClick)
				end
			end)
	end
end

function QUIDialogWorldBossAwards:receiveAwardSuccess(data, isClick)
    local awards = {}
    for _,value in ipairs(data.prizes) do
        table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
    end
	if isClick then
		self._awardsAlert[self._index] = QUIWidgetSmallAwardsAlert.new({awards = awards, index = self._index, callBack = function(index)
			if self._awardsAlert[index] ~= nil then
				self._awardsAlert[index]:removeFromParentAndCleanup(true)
				self._awardsAlert[index] = nil
			end
		end})
		app.tutorialNode:addChild(self._awardsAlert[self._index])
		self._awardsAlert[self._index]:setPosition(ccp(display.width/2, display.height/2))
		self._index = self._index + 1
	else
	    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
	        options = {awards = awards, callBack = function ()
	            remote.user:checkTeamUp()
	        end}}, {isPopCurrentDialog = false} )
	end

	self:selectTab()
	self:checkRedTips()
end

function QUIDialogWorldBossAwards:_onTriggerGloryAwards()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogWorldBossAwards.GLOTY_TAB then return end
	self._tab = QUIDialogWorldBossAwards.GLOTY_TAB

	self:selectTab()
end

function QUIDialogWorldBossAwards:_onTriggerUnionAwards()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogWorldBossAwards.UNION_TAB then return end
	self._tab = QUIDialogWorldBossAwards.UNION_TAB

	self:selectTab()
end

function QUIDialogWorldBossAwards:_onTriggerKillAwards()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogWorldBossAwards.KILL_TAB then return end
	self._tab = QUIDialogWorldBossAwards.KILL_TAB
	
	self:selectTab()
end

function QUIDialogWorldBossAwards:_onTriggerGetAll(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_get_all) == false then return end
    app.sound:playSound("common_small")
    local awardType = 1
    if self._tab == QUIDialogWorldBossAwards.KILL_TAB then
    	awardType = 2
    elseif self._tab == QUIDialogWorldBossAwards.UNION_TAB then
    	awardType = 3
    end

    local awards = remote.worldBoss:getAwardsData(awardType)
    local ids = {}
    for i = 1, #awards do
    	if awards[i].state == remote.worldBoss.AWARDS_IS_READY then
    		ids[#ids+1] = awards[i].id
    	end
    end
    if next(ids) ~= nil then
    	self:requestAwards(ids)
    else
    	app.tip:floatTip("没有可领取的奖励")
	end
end

function QUIDialogWorldBossAwards:_onScrollViewBegan()
	self._isMoveing = false
end

function QUIDialogWorldBossAwards:_onScrollViewMoving()
	self._isMoveing = true
end

function QUIDialogWorldBossAwards:_backClickHandler()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogWorldBossAwards:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogWorldBossAwards:viewAninmationOutHandler()
	self:popSelf()
end

return QUIDialogWorldBossAwards