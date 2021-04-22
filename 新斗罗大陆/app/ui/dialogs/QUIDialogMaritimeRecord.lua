-- @Author: vicentboo
-- @Date:   2019-04-26 15:28:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-04 16:29:22
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeRecord = class("QUIDialogMaritimeRecord", QUIDialog)


local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMaritimeReplayClient = import("..widgets.QUIWidgetMaritimeReplayClient")
local QUIWidgetMaritimeAllReplayClient = import("..widgets.QUIWidgetMaritimeAllReplayClient")
local QListView = import("...views.QListView")
local QReplayUtil = import("...utils.QReplayUtil")
local QScrollView = import("...views.QScrollView")
local QUIWidgetHands = import("..widgets.QUIWidgetHands")

-- QUIDialogMaritimeRecord.TAB_AWARDS = "TAB_AWARDS"
QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY = "TAB_PERSONAL_REPLAY"
QUIDialogMaritimeRecord.TAB_PROTECT_REPLAY = "TAB_PROTECT_REPLAY"
QUIDialogMaritimeRecord.TAB_ALL_REPLAY = "TAB_ALL_REPLAY"

local REPLAY_CD_LIMIT = "%d分钟内只允许发送%d条战报，%s后可以发送"
local REPLAY_CD = 5 -- 5m
local REPLAY_COUNT = 5

function QUIDialogMaritimeRecord:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang_jiangli.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		-- {ccbCallbackName = "onTriggerAward", callback = handler(self, self._onTriggerAward)},
		{ccbCallbackName = "onTriggerPersonalRecord", callback = handler(self, self._onTriggerPersonalRecord)},
		{ccbCallbackName = "onTriggerProtectRecord", callback = handler(self, self._onTriggerProtectRecord)},
		{ccbCallbackName = "onTriggerAllRecord", callback = handler(self, self._onTriggerAllRecord)},
	}
    QUIDialogMaritimeRecord.super.ctor(self, ccbFile, callBack, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._tab = options.tab or QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY
		self._callBack = options.callBack
	end
	self._replayClient = {}

	self._ccbOwner.sp_personal_record_tips:setVisible(false)
	self._ccbOwner.sp_protect_record_tips:setVisible(false)
	self._ccbOwner.sp_all_record_tips:setVisible(false)

	-- self:initScrollView()
end

function QUIDialogMaritimeRecord:viewDidAppear()
	QUIDialogMaritimeRecord.super.viewDidAppear(self)

	self:selectTab()
end

function QUIDialogMaritimeRecord:viewWillDisappear()
  	QUIDialogMaritimeRecord.super.viewWillDisappear(self)

	if self._hands then
		self._hands:removeFromParent()
		self._hands = nil
	end
end

function QUIDialogMaritimeRecord:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMaritimeRecord:initScrollView(scrollViewtype)
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

    if self._scrollView then
        self._scrollView:clear()
    end

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = scrollViewtype, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end


function QUIDialogMaritimeRecord:checkRedTips()
	self._ccbOwner.sp_personal_record_tips:setVisible(remote.maritime:checkReplayTips())
	self._ccbOwner.sp_protect_record_tips:setVisible(remote.maritime:checkProjectReplayTips())
	local flag = remote.maritime:checkReplayTips() or remote.maritime:checkProjectReplayTips()
	self._ccbOwner.sp_all_record_tips:setVisible(flag)
end

function QUIDialogMaritimeRecord:selectTab()
	self:getOptions().tab = self._tab
	if self._tab == QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY or self._tab == QUIDialogMaritimeRecord.TAB_PROTECT_REPLAY then
		self:initScrollView(2)
	else
		self:initScrollView(1)
	end
	self:_setButtonState()

	if self._contentListView ~= nil then
		self._contentListView:clear(true)
	end
	self._scrollView:clear()
	self._replayClient = {}
	self:_checkTutorialHands(false)

	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.sp_long_bg:setVisible(true)
	local seltctType = 1
	if self._tab == QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY then
		seltctType = 1
		remote.maritime:updateReplayTip(false)
	elseif self._tab == QUIDialogMaritimeRecord.TAB_PROTECT_REPLAY then
		seltctType = 2
		remote.maritime:updateProjectReplayTip(false)
	else		
		seltctType = 3
	end
	remote.maritime:requestGetMaritimeReplayList(seltctType, function(data)
		if self:safeCheck() == false then return end

		self:checkRedTips()
		self._data = data.maritimeGetFightReportListResponse.fightInfos
		if self._data == nil or next(self._data) == nil then
			self._ccbOwner.node_no:setVisible(true)
			self._ccbOwner.tf_no_content:setString("魂师大人，当前还没有您的战报信息~")
			return
		end
		if seltctType == 3 then
			self:setAllRecordInfo()
		else
			self:setRecordInfo()
		end
	end)
end

function QUIDialogMaritimeRecord:setRecordInfo()
	
	local itemContentSize, buffer = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetMaritimeReplayClient")
	for _, value in pairs(buffer) do
	    value:addEventListener(QUIWidgetMaritimeReplayClient.EVENT_SHARE, handler(self, self._clickShare))
	    value:addEventListener(QUIWidgetMaritimeReplayClient.EVENT_REPLAY, handler(self, self._clickReplay))
	    value:addEventListener(QUIWidgetMaritimeReplayClient.EVENT_SCORE, handler(self, self._clickScore))
	    self._replayClient[#self._replayClient+1] = value
	end
	local row = 0
	local line = 0
	local lineDistance = 0
	local offsetX = 3
	local offsetY = 0
	local selectPositionY = nil

	for i = 1, #self._data do
		local positionX = offsetX
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY
		self._scrollView:addItemBox(positionX, positionY, {info = self._data[i], index = i})

		if self._infoReplay ~= nil and self._infoReplay.shipInfoId == self._data[i].shipInfoId then
			selectPositionY = positionY
		end

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)

	if self._infoReplay ~= nil and selectPositionY then
		self._scrollView:moveTo(0, -selectPositionY)
		self:_checkTutorialHands(true)
	end
	self._infoReplay = nil 
end

function QUIDialogMaritimeRecord:setAllRecordInfo()
    local index = 0
    local positionY = 0
    self._totalHeightRegional = 0
    for _, v in pairs(self._data) do
        local widgetMaritimeAllReplayClient = QUIWidgetMaritimeAllReplayClient.new({info = v, index = index}) 
    	widgetMaritimeAllReplayClient:setPosition(ccp(0, -positionY))
        positionY =  positionY + widgetMaritimeAllReplayClient:getContentSize().height 
    	print(positionY)

        self._scrollView:addItemBox(widgetMaritimeAllReplayClient)
        self._totalHeightRegional = self._totalHeightRegional + widgetMaritimeAllReplayClient:getContentSize().height
        index = index + 1
        self._scrollView:setRect(0, -self._totalHeightRegional, 0, widgetMaritimeAllReplayClient:getContentSize().width)
        -- self._regionalRecordScrollView:setRect(0, -self._totalHeightRegional, 0, self._ccbOwner.sheet_content:getContentSize().width)
    end

end

function QUIDialogMaritimeRecord:_checkTutorialHands(isCreat)
	if isCreat == false then
		if self._hands then
			self._hands:removeFromParent()
			self._hands = nil
		end
		return
	end
	local position = nil
	if self._replayClient and next(self._replayClient) then
		for i = 1, #self._replayClient do
			local data = self._replayClient[i]:getReplayInfo()
			if data.shipInfoId == self._infoReplay.shipInfoId then
				position = self._replayClient[i]._ccbOwner.ly_bg:convertToWorldSpaceAR(ccp(0,0))
				break
			end
		end

		if position then
			self._hands = QUIWidgetHands.new()
			self._hands:setPosition(position.x+295, position.y)
			app.tutorialNode:addChild(self._hands)
		end
	end
end

function QUIDialogMaritimeRecord:_clickInfo(event)
	if event.info then
		self._infoReplay = event.info
		self:_onTriggerPersonalRecord()
	end
end

function QUIDialogMaritimeRecord:_clickShare(event)
    app.sound:playSound("common_small")
	if event and event.info and event.info.fightReportId then
		local replayId = event.info.fightReportId
		local earliestTime, replayCount = app:getServerChatData():getEarliestReplaySentTime()
		if replayCount >= REPLAY_COUNT and q.serverTime() - earliestTime < REPLAY_CD * 60 then
			app.tip:floatTip(string.format(REPLAY_CD_LIMIT, REPLAY_CD, REPLAY_COUNT, q.timeToHourMinuteSecond(REPLAY_CD * 60 - (q.serverTime() - earliestTime), true)))
			return
		end

		local nickName = event.info.fighterName
		if event.info.fighterId == remote.user.userId then
			nickName = event.info.defenseName
		end
		QReplayUtil:getReplayInfo(replayId, function (data)
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogReplayShare", 
				options = {rivalName = nickName, myNickName = remote.user.nickname, replayId = replayId, replayType = REPORT_TYPE.MARITIME}}, {isPopCurrentDialog = false})
		end, nil, REPORT_TYPE.MARITIME)
	end
end

function QUIDialogMaritimeRecord:_clickReplay(event)
    app.sound:playSound("common_small")
	if event and event.info and event.info.fightReportId then
		local replayId = event.info.fightReportId
		QReplayUtil:getReplayInfo(replayId, function (data)
			QReplayUtil:downloadReplay(replayId, function (replay)
				QReplayUtil:play(replay)
			end, nil, REPORT_TYPE.MARITIME)
		end, nil, REPORT_TYPE.MARITIME)
	end
end

function QUIDialogMaritimeRecord:_clickScore(event)
	app.sound:playSound("common_small")
	if event and event.info and event.info.fightReportId then
		local info = event.info
		local replayId = info.fightReportId
		local userId = info.fighterId
		local isInitiative = false
		if userId == remote.user.userId then
			userId = info.defenseId
			isInitiative = true
		end
		remote.maritime:requestQueryMaritimeShipInfo(userId, function(data)
			local fighter = (data.maritimeQueryFighterResponse.fighter or {})
			local scoreList = info.scoreList
			QReplayUtil:getReplayInfo(replayId, function (data)
				local detailInfo = {}
				detailInfo.isInitiative = isInitiative
				detailInfo.scoreList = scoreList
				detailInfo.fighter = fighter
				detailInfo.replayInfo = data
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAgainstRecordDetail",
		    		options = {info = detailInfo}}, {isPopCurrentDialog = false})
			end, nil, REPORT_TYPE.MARITIME)
		end)
	end
end

function QUIDialogMaritimeRecord:getContentListView()
    return self._contentListView
end

function QUIDialogMaritimeRecord:_setButtonState()

	local personalTab = self._tab == QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY
	self._ccbOwner.btn_personal_record:setHighlighted(personalTab)
	self._ccbOwner.btn_personal_record:setEnabled(not personalTab)

	local protectTab = self._tab == QUIDialogMaritimeRecord.TAB_PROTECT_REPLAY
	self._ccbOwner.btn_protect_record:setHighlighted(protectTab)
	self._ccbOwner.btn_protect_record:setEnabled(not protectTab)

	local allTab = self._tab == QUIDialogMaritimeRecord.TAB_ALL_REPLAY
	self._ccbOwner.btn_all_record:setHighlighted(allTab)
	self._ccbOwner.btn_all_record:setEnabled(not allTab)
end

function QUIDialogMaritimeRecord:_onScrollViewMoving()
	self._isMove = true
end

function QUIDialogMaritimeRecord:_onScrollViewBegan()
	self._isMove = false
	self:_checkTutorialHands(false)
end

function QUIDialogMaritimeRecord:_onTriggerPersonalRecord()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY then return end
	self._tab = QUIDialogMaritimeRecord.TAB_PERSONAL_REPLAY
	self:selectTab()
end

function QUIDialogMaritimeRecord:_onTriggerProtectRecord()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogMaritimeRecord.TAB_PROTECT_REPLAY then return end
	self._tab = QUIDialogMaritimeRecord.TAB_PROTECT_REPLAY
	self:selectTab()
end

function QUIDialogMaritimeRecord:_onTriggerAllRecord()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogMaritimeRecord.TAB_ALL_REPLAY then return end
	self._tab = QUIDialogMaritimeRecord.TAB_ALL_REPLAY
	
	self:selectTab()
end


function QUIDialogMaritimeRecord:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end	
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMaritimeRecord:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMaritimeRecord
