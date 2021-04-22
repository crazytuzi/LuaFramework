-- @Author: xurui
-- @Date:   2016-12-19 15:04:10
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-13 16:25:04
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderBattleReport = class("QUIDialogPlunderBattleReport", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetPlunderRegionalRecord = import("..widgets.QUIWidgetPlunderRegionalRecord")

QUIDialogPlunderBattleReport.PERSONAL_REPORT = "PERSONAL_REPORT"
QUIDialogPlunderBattleReport.UNION_REPORT = "UNION_REPORT"

function QUIDialogPlunderBattleReport:ctor(options)
	local ccbFile = "ccb/Dialog_plunder_zhanbao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerPersonalReport", callback = handler(self, self._onTriggerPersonalReport)},
		{ccbCallbackName = "onTriggerUnionReport", callback = handler(self, self._onTriggerUnionReport)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogPlunderBattleReport.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._tab = options.tab or QUIDialogPlunderBattleReport.PERSONAL_REPORT
	end

	remote.plunder.isRecordRedTip = false
	
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.award_tips:setVisible(false)
	self._ccbOwner.personalRecord_tips:setVisible(false)

	self:initScrollView()
end

function QUIDialogPlunderBattleReport:viewDidAppear()
	QUIDialogPlunderBattleReport.super.viewDidAppear(self)

	self:selectTab()
end

function QUIDialogPlunderBattleReport:viewWillDisappear()
	QUIDialogPlunderBattleReport.super.viewWillDisappear(self)
end

function QUIDialogPlunderBattleReport:initScrollView()
	local contentSize = self._ccbOwner.sheet_layout:getContentSize()

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, contentSize, {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(false)
	self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))

	self._scrollView1 = QScrollView.new(self._ccbOwner.sheet, contentSize, {bufferMode = 1, sensitiveDistance = 10})
	self._scrollView1:setVerticalBounce(true)
	self._scrollView1:setGradient(false)
	self._scrollView1:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)

    self._scrollView1:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView1:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end


function QUIDialogPlunderBattleReport:selectTab()
	self:getOptions().tab = self._tab

	self._scrollView:clear()
	self._scrollView1:clear()
	self:_setButtonState()

	if self._tab == QUIDialogPlunderBattleReport.PERSONAL_REPORT then
		remote.plunder:plunderGetFightReportListRequest(1, function(data)
				if self:safeCheck() then
					if data.kuafuMineGetFightReportListResponse then
						self:setPersonalReport(data.kuafuMineGetFightReportListResponse.reports)
					end
				end
			end)
	elseif self._tab == QUIDialogPlunderBattleReport.UNION_REPORT then
		remote.plunder:plunderGetMineFightReportListRequest(function(data)
				if self:safeCheck() then
					if data.kuafuMineGetMineFightReportListResponse then
						self:setUnionReport(data.kuafuMineGetMineFightReportListResponse.reports)
					end
				end
			end)
	end
end

function QUIDialogPlunderBattleReport:setPersonalReport(data)
	if data == nil or next(data) == nil then return end
	local itemContentSize, buffer = self._scrollView:setCacheNumber(10, "widgets.QUIWidgetPlunderReportClient")

	local row = 0
	local line = 0
	local lineDistance = 6
	local offsetX = 0
	local offsetY = 0
	for i = 1, #data do
		local positionX = offsetX
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY

        local me = data[i].fighter1
        local rival = data[i].fighter2
        local result = data[i].success
        local score = data[i].lootScore or 0
        local reportType = data[i].reportType or 0
        local attackState = 1

        -- need to know which fighter is myself
        if me.userId ~= remote.user.userId then
        	me, rival = rival, me
            attackState = 2
            result = not result
        end
		self._scrollView:addItemBox(positionX, positionY, {parent = self, userId = rival.userId, nickName = rival.name, level = rival.level, 
					result = result, rankChanged = 0, avatar = rival.avatar, time = data[i].fighter1.lastFightAt, replay = data[i].fightReportId, 
					vip = rival.vip, mineId = data[i].mineId, score = score, reportType = reportType, attackState = attackState, 
					gameAreaName = rival.game_area_name, lootScore = data[i].lootScore, bgVisible = math.fmod(i, 2) == 0})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogPlunderBattleReport:setUnionReport(data)
	if data == nil or next(data) == nil then return end
	local row = 0
	local line = 0
	local lineDistance = 6
	local offsetX = 0
	local offsetY = 0
	local itemContentSize
	for i = 1, #data do
        local result = data[i].success
        local score = data[i].lootScore
        local reportType = data[i].type

        local nickNameWin, forceWin, nickNameLose, forceLose, areaNameLose, areaNameWin
        if result == true then
            nickNameWin = data[i].fighter1Name
            forceWin = data[i].fighter1Force
            areaNameWin = data[i].fighter1GameAreaName
            nickNameLose = data[i].fighter2Name
            forceLose = data[i].fighter2Force
            areaNameLose = data[i].fighter2GameAreaName
        else
            nickNameWin = data[i].fighter2Name
            forceWin = data[i].fighter2Force
            areaNameWin = data[i].fighter2GameAreaName
            nickNameLose = data[i].fighter1Name
            forceLose = data[i].fighter1Force
            areaNameLose = data[i].fighter1GameAreaName
        end

		local reportClient = QUIWidgetPlunderRegionalRecord.new({time = data[i].fightAt, winnerIsAttacker = result, nickNameWin = nickNameWin,
				 mineId = data[i].mineId, forceWin = forceWin, nickNameLose = nickNameLose, forceLose = forceLose, bgVisible = math.fmod(i, 2) == 0, 
				 areaNameWin = areaNameWin, areaNameLose = areaNameLose, reportType = reportType, score = score})

		itemContentSize = reportClient:getContentSize()
		local positionX = offsetX
		local positionY = -(itemContentSize.height+lineDistance) * line + offsetY
		reportClient:setPosition(ccp(positionX, positionY))
		self._scrollView1:addItemBox(reportClient)

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = (itemContentSize.height+lineDistance) * line
	self._scrollView1:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogPlunderBattleReport:_setButtonState()
	self._ccbOwner.btn_personal_report:setHighlighted(false)
	self._ccbOwner.btn_personal_report:setEnabled(true)

	self._ccbOwner.btn_union_report:setHighlighted(false)
	self._ccbOwner.btn_union_report:setEnabled(true)

	if self._tab == QUIDialogPlunderBattleReport.PERSONAL_REPORT then
		self._ccbOwner.btn_personal_report:setHighlighted(true)
		self._ccbOwner.btn_personal_report:setEnabled(false)
	elseif self._tab == QUIDialogPlunderBattleReport.UNION_REPORT then
		self._ccbOwner.btn_union_report:setHighlighted(true)
		self._ccbOwner.btn_union_report:setEnabled(false)
	end
end

function QUIDialogPlunderBattleReport:_onScrollViewBegan()
	self._isMoveing = false
end

function QUIDialogPlunderBattleReport:_onScrollViewMoving()
	self._isMoveing = true
end

function QUIDialogPlunderBattleReport:_onTriggerPersonalReport()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderBattleReport.PERSONAL_REPORT then return end
	self._tab = QUIDialogPlunderBattleReport.PERSONAL_REPORT
	
	self:selectTab()
end

function QUIDialogPlunderBattleReport:_onTriggerUnionReport()
    app.sound:playSound("common_menu")
	if self._tab == QUIDialogPlunderBattleReport.UNION_REPORT then return end
	self._tab = QUIDialogPlunderBattleReport.UNION_REPORT
	
	self:selectTab()
end

function QUIDialogPlunderBattleReport:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPlunderBattleReport:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	self:playEffectOut()
end

function QUIDialogPlunderBattleReport:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogPlunderBattleReport