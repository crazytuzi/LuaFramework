-- @Author: xurui
-- @Date:   2016-12-16 15:26:31
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-29 14:33:01
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderAwards = class("QUIDialogPlunderAwards", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetPlunderAwardClient = import("..widgets.QUIWidgetPlunderAwardClient")
local QUIWidgetSmallAwardsAlert = import("..widgets.QUIWidgetSmallAwardsAlert")

QUIDialogPlunderAwards.PERSONAL_AWARD = "PERSONAL_AWARD"
QUIDialogPlunderAwards.UNION_AWARD = "UNION_AWARD"

function QUIDialogPlunderAwards:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_mubiao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerPersonalAward", callback = handler(self, self._onTriggerPersonalAward)},
		{ccbCallbackName = "onTriggerUnionAward", callback = handler(self, self._onTriggerUnionAward)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGetAll", callback = handler(self, self._onTriggerGetAll)},
	}
	QUIDialogPlunderAwards.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	if options then
		self._tab = options.tab or QUIDialogPlunderAwards.PERSONAL_AWARD
	end
	self._awrdsItem = {}
	self._awardsAlert = {}
	self._index = 1

	self:initScrollView()
end

function QUIDialogPlunderAwards:viewDidAppear()
	QUIDialogPlunderAwards.super.viewDidAppear(self)

	self:selectTab()
	self:checkRedTips()
end

function QUIDialogPlunderAwards:viewWillDisappear()
	QUIDialogPlunderAwards.super.viewWillDisappear(self)
end

function QUIDialogPlunderAwards:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(false)
	-- self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end


function QUIDialogPlunderAwards:selectTab()
	self:getOptions().tab = self._tab

	self._scrollView:clear()
	self:_setButtonState()

	local titleFormat = ""

	if self._tab == QUIDialogPlunderAwards.PERSONAL_AWARD then
		self._condition = remote.plunder:getMyMaxScore()
		self._data = QStaticDatabase:sharedDatabase():getPlunderTargetReward(1)
		self._buyAwards = remote.plunder:getMyScoreAwards()
		titleFormat = "累计冰髓达到%s可领取"
	elseif self._tab == QUIDialogPlunderAwards.UNION_AWARD then
		self._condition = remote.plunder:getConsortiaMaxScore()
		self._data = QStaticDatabase:sharedDatabase():getPlunderTargetReward(2)
		self._buyAwards = remote.plunder:getConsortiaScoreAwards()
		titleFormat = "宗门冰髓达到%s可领取"
	end

	local isDone = function(id)
		for _, value in pairs(self._buyAwards) do
			if value == id then
				return true
			end
		end
		return false
	end

	table.sort( self._data, function(a, b) 
		local isDoneA = isDone(a.id)
		local isDoneB = isDone(b.id)

		if isDoneA ~= isDoneB then
			return isDoneA == false
		else
			return a.id < b.id 
		end
	end)
	self:setClientInfo(titleFormat)
end

function QUIDialogPlunderAwards:setClientInfo(titleFormat)
	local itemContentSize, buffer = self._scrollView:setCacheNumber(4, "widgets.QUIWidgetPlunderAwardClient")
	for _, value in pairs(buffer) do
		value:addEventListener(QUIWidgetPlunderAwardClient.EVENT_CLICK, handler(self, self._clickAwardsClient))
		table.insert(self._awrdsItem, value)
	end

	local row = 0
	local line = 0
	local lineDistance = 0
	local offsetX = 0
	local offsetY = 0
	for i = 1, #self._data do
		local positionX = offsetX
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY

		local num1, str1 = q.convertLargerNumber(self._data[i].target_score)
		local num2, str2 = q.convertLargerNumber(self._condition)
		local titleString = string.format(titleFormat, num1..(str1 or ""))
		local rankString = string.format("进度：%s/%s", num2..(str2 or ""), num1..(str1 or ""))

		self._scrollView:addItemBox(positionX, positionY, {awardInfo = self._data[i], condition = self._condition, index = i, titleString = titleString, rankString = rankString, buyAwards = self._buyAwards})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogPlunderAwards:_clickAwardsClient(event)
	if self._isMoveing then return end
	if event.awardInfo then
		self:requestAwards({event.awardInfo.id}, true, {event.awardInfo})
	end
end

function QUIDialogPlunderAwards:requestAwards(ids, isClick, awards)
	local isClick = isClick
	if self._tab == QUIDialogPlunderAwards.PERSONAL_AWARD then
		remote.plunder:plunderGetPersonalAwardRequest(ids, function(data)
				if self:safeCheck() then
					self:receiveAwardSuccess(data, isClick, awards)
				end
			end)
	else
		remote.plunder:plunderGetUnionAwardRequest(ids, function(data)
				if self:safeCheck() then
					self:receiveAwardSuccess(data, isClick, awards)
				end
			end)
	end
end

function QUIDialogPlunderAwards:receiveAwardSuccess(data, isClick, awards)
    local award = {}
    for _,value in ipairs(awards) do
    	local items = string.split(value.reward, ";")
    	for i = 1, #items do
    		items[i] = string.split(items[i], "^")
	    	local itemType = ITEM_TYPE.ITEM
			if tonumber(items[i][1]) == nil then
				itemType = items[i][1]
			end
	        table.insert(award, {id = tonumber(items[i][1]), typeName = itemType, count = tonumber(items[i][2])})
    	end
    end
	if isClick then
		self._awardsAlert[self._index] = QUIWidgetSmallAwardsAlert.new({awards = award, index = self._index, callBack = function(index)
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
	        options = {awards = award, callBack = function ()
	            remote.user:checkTeamUp()
	        end}}, {isPopCurrentDialog = false} )
	end
	self:selectTab()
	self:checkRedTips()
end

function QUIDialogPlunderAwards:_setButtonState()
	self._ccbOwner.btn_personal_award:setHighlighted(false)
	self._ccbOwner.btn_personal_award:setEnabled(true)
    
	self._ccbOwner.btn_union_award:setHighlighted(false)
	self._ccbOwner.btn_union_award:setEnabled(true)

	if self._tab == QUIDialogPlunderAwards.PERSONAL_AWARD then
		self._ccbOwner.btn_personal_award:setHighlighted(true)
		self._ccbOwner.btn_personal_award:setEnabled(false)
	elseif self._tab == QUIDialogPlunderAwards.UNION_AWARD then
		self._ccbOwner.btn_union_award:setHighlighted(true)
		self._ccbOwner.btn_union_award:setEnabled(false)
	end
end

function QUIDialogPlunderAwards:checkRedTips()
	self._ccbOwner.personal_award_tips:setVisible(remote.plunder:checkPersonalAwardTips())

	self._ccbOwner.union_award_tips:setVisible(remote.plunder:checkUnionAwardTips())
end

function QUIDialogPlunderAwards:_onTriggerPersonalAward()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderAwards.PERSONAL_AWARD then return end
	self._tab = QUIDialogPlunderAwards.PERSONAL_AWARD
	
	self:selectTab()
end

function QUIDialogPlunderAwards:_onTriggerUnionAward()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderAwards.UNION_AWARD then return end
	self._tab = QUIDialogPlunderAwards.UNION_AWARD
	
	self:selectTab()
end

function QUIDialogPlunderAwards:_onTriggerGetAll(e)
	if q.buttonEventShadow(e, self._ccbOwner.style_btn_get) == false then return end
	app.sound:playSound("common_small")
    local awardType = 1
    if self._tab == QUIDialogPlunderAwards.UNION_AWARD then
    	awardType = 2
    end

    local isDone = function (id)
		for _, value in pairs(self._buyAwards) do
			if value == id then
				return true
			end
		end
		return false
    end

    local awards = QStaticDatabase:sharedDatabase():getPlunderTargetReward(awardType)
    local ids = {}
    local award = {}
    for i = 1, #awards do
    	if awards[i].target_score <= self._condition and isDone(awards[i].id) == false then
    		ids[#ids+1] = awards[i].id
    		award[#award+1] = awards[i]
    	end
    end
    if next(ids) ~= nil then
    	self:requestAwards(ids, false, award)
    else
    	app.tip:floatTip("没有可领取的奖励")
	end
end

function QUIDialogPlunderAwards:_onScrollViewBegan()
	self._isMoveing = false
end

function QUIDialogPlunderAwards:_onScrollViewMoving()
	self._isMoveing = true
end

function QUIDialogPlunderAwards:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPlunderAwards:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPlunderAwards:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogPlunderAwards