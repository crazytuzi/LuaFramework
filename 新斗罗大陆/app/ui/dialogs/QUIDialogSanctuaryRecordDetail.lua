--
-- zxs
-- 精英赛我的战斗简介
--

local QUIDialog = import(".QUIDialog")
local QUIDialogSanctuaryRecordDetail = class("QUIDialogSanctuaryRecordDetail", QUIDialog)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QUIWidgetSanctuaryWinloseFlag = import("..widgets.sanctuary.QUIWidgetSanctuaryWinloseFlag")
local QReplayUtil = import("...utils.QReplayUtil")
local QUIViewController = import("..QUIViewController")

--初始化
function QUIDialogSanctuaryRecordDetail:ctor(options)
	local ccbFile = "ccb/Dialog_Sanctuary_details.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerVisit1", callback = handler(self, self._onTriggerVisit1)},
        {ccbCallbackName = "onTriggerVisit2", callback = handler(self, self._onTriggerVisit2)},
	}
	QUIDialogSanctuaryRecordDetail.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._report = options.report
	self._fighter1 = options.report.fighter1
	self._fighter2 = options.report.fighter2

	self._ccbOwner.frame_tf_title:setString("战况详情")
	q.setButtonEnableShadow(self._ccbOwner.btn_replay)

    self:updatePlayer()
    self:showBetNum()
    self:showFightResult()
end

function QUIDialogSanctuaryRecordDetail:updatePlayer()
    self._ccbOwner.node_head_1:removeAllChildren()
    self._ccbOwner.node_head_2:removeAllChildren()
	
	local force1 = self._fighter1.force or 0
	local num,unit = q.convertLargerNumber(force1)
	self._ccbOwner.tf_force_1:setString(num..unit)
	local str = "LV."..self._fighter1.level.." "..self._fighter1.name
	self._ccbOwner.tf_name_1:setString(str)
	local avatar = QUIWidgetAvatar.new(self._fighter1.avatar)
	avatar:setSilvesArenaPeak(self._fighter1.championCount)
    self._ccbOwner.node_head_1:addChild(avatar)
    self._ccbOwner.tf_server_1:setString(self._fighter1.game_area_name)

	local force2 = self._fighter2.force or 0
	local num,unit = q.convertLargerNumber(force2)
	self._ccbOwner.tf_force_2:setString(num..unit)
	local str = "LV."..self._fighter2.level.." "..self._fighter2.name
	self._ccbOwner.tf_name_2:setString(str)
	local avatar = QUIWidgetAvatar.new(self._fighter2.avatar)
	avatar:setSilvesArenaPeak(self._fighter2.championCount)
	avatar:setScaleX(-1)
    self._ccbOwner.node_head_2:addChild(avatar)
    self._ccbOwner.tf_server_2:setString(self._fighter2.game_area_name)
end

function QUIDialogSanctuaryRecordDetail:showBetNum()
	self._ccbOwner.tf_bet_1:setVisible(false)
	self._ccbOwner.tf_bet_2:setVisible(false)
	self._ccbOwner.tf_bet_num_1:setString("")
	self._ccbOwner.tf_bet_num_2:setString("")

	-- 押注信息
	local betInfo = self._report.betInfo
	if betInfo and self._report.currRound >= remote.sanctuary.ROUND_8 then
		local betTbl = string.split(betInfo, ":")
		self._ccbOwner.tf_bet_1:setVisible(true)
		self._ccbOwner.tf_bet_2:setVisible(true)
		self._ccbOwner.tf_bet_num_1:setString(betTbl[1] or 0)
		self._ccbOwner.tf_bet_num_2:setString(betTbl[2] or 0)
	end
end

function QUIDialogSanctuaryRecordDetail:showFightResult()
	local scoreList = string.split(self._report.scoreInfo or "", ";")
	local winNum = 0
	local loseNum = 0
	local fighterNum = #scoreList

	for i, score in ipairs(scoreList) do
		local isWin = true
		if score == "1" then
			winNum = winNum + 1
			isWin = true
		else
			loseNum = loseNum + 1
			isWin = false
		end
		local posX = 95*(i-1)
		local flag1 = QUIWidgetSanctuaryWinloseFlag.new()
		flag1:setIndex(i)
		flag1:setIsWin(isWin)
		flag1:setPositionX(posX)
		self._ccbOwner.node_result1:addChild(flag1)

		local flag2 = QUIWidgetSanctuaryWinloseFlag.new()
		flag2:setIndex(i)
		flag2:setIsWin(not isWin)
		flag2:setPositionX(posX)
		self._ccbOwner.node_result2:addChild(flag2)
	end

	self._ccbOwner.sp_score_1:setString(winNum)
	self._ccbOwner.sp_score_2:setString(loseNum)
end

function QUIDialogSanctuaryRecordDetail:_onTriggerReplay(e)
    app.sound:playSound("common_small")
	local reportId = self._report.reportId
	QReplayUtil:getReplayInfo(reportId, function (data)
		QReplayUtil:downloadReplay(reportId, function (replay)
			QReplayUtil:play(replay,data.scoreList, data.fightReportStats, true)
		end, nil, REPORT_TYPE.SANCTUARY_WAR)
	end, nil, REPORT_TYPE.SANCTUARY_WAR)
end

function QUIDialogSanctuaryRecordDetail:_onTriggerVisit1()
    app.sound:playSound("common_small")
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._fighter1.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = true})
		end
	end)
end

function QUIDialogSanctuaryRecordDetail:_onTriggerVisit2()
    app.sound:playSound("common_small")
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._fighter2.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = true})
		end
	end)
end

function QUIDialogSanctuaryRecordDetail:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogSanctuaryRecordDetail:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogSanctuaryRecordDetail
