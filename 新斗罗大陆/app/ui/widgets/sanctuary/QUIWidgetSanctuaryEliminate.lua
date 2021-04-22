--
-- zxs
-- 精英赛8强
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryEliminate = class("QUIWidgetSanctuaryEliminate", QUIWidget)
local QUIWidgetSanctuaryPageGroup = import("..sanctuary.QUIWidgetSanctuaryPageGroup")
local QUIWidgetSanctuaryWinloseFlag = import("..sanctuary.QUIWidgetSanctuaryWinloseFlag")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAvatar = import("..QUIWidgetAvatar")
local QUIViewController = import("....ui.QUIViewController")
local QReplayUtil = import("....utils.QReplayUtil")

function QUIWidgetSanctuaryEliminate:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_bet.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerVisit1", callback = handler(self, self._onTriggerVisit1)},
        {ccbCallbackName = "onTriggerVisit2", callback = handler(self, self._onTriggerVisit2)},
        {ccbCallbackName = "onTriggerBet", callback = handler(self, self._onTriggerBet)},
        {ccbCallbackName = "onTriggerReplay", callback = handler(self, self._onTriggerReplay)},
	}
	QUIWidgetSanctuaryEliminate.super.ctor(self,ccbFile,callBacks,options)
	self._options = options or {}

	q.setButtonEnableShadow(self._ccbOwner.btn_replay)
	
	self:switchState()
end

function QUIWidgetSanctuaryEliminate:onEnter()
	QUIWidgetSanctuaryEliminate.super.onEnter(self)
	
	self._sanctuaryProxy = cc.EventProxy.new(remote.sanctuary)
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_UPDATE_FORCE, handler(self, self.updateMyBattleForce))
end

function QUIWidgetSanctuaryEliminate:onExit()
	QUIWidgetSanctuaryEliminate.super.onExit(self)

	if self._sanctuaryProxy ~= nil then
		self._sanctuaryProxy:removeAllEventListeners()
		self._sanctuaryProxy = nil
	end
end

--刷新数据
function QUIWidgetSanctuaryEliminate:switchState()
	local myIndex = remote.sanctuary:getMyPageIndex()
	self._totalPage = remote.sanctuary:getTotalPage()
	self._currentIndex = myIndex

	if self._options.currentIndex then
		self._currentIndex = self._options.currentIndex
	end
	if self._currentIndex == 0 then
		self._currentIndex = 1
	end
	if self._currentIndex > self._totalPage then
		self._currentIndex = self._totalPage
	end

	-- 组
	self._groupBtn = {}
	self._ccbOwner.node_group:removeAllChildren()
	local width = 65
	local startPosX = -self._totalPage*width/2
	if self._totalPage % 2 == 0 then
		startPosX = startPosX - width/2
	end
	for index = 1, self._totalPage do
		self._groupBtn[index] = QUIWidgetSanctuaryPageGroup.new()
		self._groupBtn[index]:addEventListener(QUIWidgetSanctuaryPageGroup.EVENT_GROUP_CLICK, handler(self, self._groupClickHandler))
		self._groupBtn[index]:setPositionX(startPosX+index*width)
		self._groupBtn[index]:setIndex(index)
		self._groupBtn[index]:setIsSelf(myIndex == index)
		self._ccbOwner.node_group:addChild(self._groupBtn[index])
	end
	
	self:showInfo()
end

function QUIWidgetSanctuaryEliminate:resetAll()
	self._ccbOwner.node_left1:removeAllChildren()
	self._ccbOwner.node_left2:removeAllChildren()
	self._ccbOwner.node_right1:removeAllChildren()
	self._ccbOwner.node_right2:removeAllChildren()
	self._ccbOwner.node_head1:removeAllChildren()
	self._ccbOwner.node_head2:removeAllChildren()
	self._ccbOwner.node_result1:removeAllChildren()
	self._ccbOwner.node_result2:removeAllChildren()

	self._ccbOwner.tf_force1:setString(0)
	self._ccbOwner.tf_server1:setString("")
	self._ccbOwner.tf_name1:setString("")
	self._ccbOwner.tf_number1:setString("0人")
	self._ccbOwner.tf_force2:setString(0)
	self._ccbOwner.tf_server2:setString("")
	self._ccbOwner.tf_name2:setString("")
	self._ccbOwner.tf_number2:setString("0人")

	self._ccbOwner.node_btn_bet:setVisible(false)
	self._ccbOwner.node_btn_replay:setVisible(false)
	self._ccbOwner.node_award:setVisible(false)
	self._ccbOwner.node_bet:setVisible(false)
end

--显示界面的信息
function QUIWidgetSanctuaryEliminate:updateMyBattleForce()
	self:showInfo()
end

--显示界面的信息
function QUIWidgetSanctuaryEliminate:showInfo()
	self._options.currentIndex = self._currentIndex
	self:resetAll()
	local state = remote.sanctuary:getState()
	for index = 1, self._totalPage do
		self._groupBtn[index]:setIsSelected(index == self._currentIndex)
		if state == remote.sanctuary.STATE_BETS_2 or state == remote.sanctuary.STATE_FINAL then
			self._groupBtn[index]:setSpecialIndex(index)
		end
	end

	local players = remote.sanctuary:getInfoByPage(self._currentIndex)
	self._player1 = players[1]
	self._player2 = players[2]

	if not self._player1 or not self._player1.fighter or not self._player2 or not self._player2.fighter then
		return
	end

	local fighter1 = self._player1.fighter
	local showHeroInfo = fighter1.showHeroInfo or {}
	if showHeroInfo[1] then
		local avatar1 = QUIWidgetActorDisplay.new(showHeroInfo[1].actorId, {heroInfo = showHeroInfo[1]})
		self._ccbOwner.node_left1:addChild(avatar1)
		self._ccbOwner.node_left1:setScaleX(-1.3)
		self._ccbOwner.node_left1:setScaleY(1.3)
	end
	if showHeroInfo[2] then
		local avatar2 = QUIWidgetActorDisplay.new(showHeroInfo[2].actorId, {heroInfo = showHeroInfo[2]})
		self._ccbOwner.node_left2:addChild(avatar2)
		self._ccbOwner.node_left2:setScaleX(-1.3)
		self._ccbOwner.node_left2:setScaleY(1.3)
	end
	local avatar = QUIWidgetAvatar.new(fighter1.avatar)
	avatar:setSilvesArenaPeak(fighter1.championCount)
    self._ccbOwner.node_head1:addChild(avatar)
    self._ccbOwner.node_self1:setVisible(fighter1.userId == remote.user.userId)
    self._ccbOwner.node_normal1:setVisible(fighter1.userId ~= remote.user.userId)

	local force1 = fighter1.force or 0
	local num,unit = q.convertLargerNumber(force1)
	self._ccbOwner.tf_force1:setString(num..unit)
	self._ccbOwner.tf_server1:setString(fighter1.game_area_name or "")
	local nameStr = string.format("LV.%d %s", fighter1.level or 0, fighter1.name or "")
	self._ccbOwner.tf_name1:setString(nameStr)

	local fighter2 = self._player2.fighter
	local showHeroInfo = fighter2.showHeroInfo or {}
	if showHeroInfo[1] then
		local avatar1 = QUIWidgetActorDisplay.new(showHeroInfo[1].actorId, {heroInfo = showHeroInfo[1]})
		self._ccbOwner.node_right1:addChild(avatar1)
		self._ccbOwner.node_right1:setScale(1.3)
	end
	if showHeroInfo[2] then
		local avatar2 = QUIWidgetActorDisplay.new(showHeroInfo[2].actorId, {heroInfo = showHeroInfo[2]})
		self._ccbOwner.node_right2:addChild(avatar2)
		self._ccbOwner.node_right2:setScale(1.3)
	end
	local avatar = QUIWidgetAvatar.new(fighter2.avatar)
	avatar:setSilvesArenaPeak(fighter2.championCount)
	avatar:setScaleX(-1)
    self._ccbOwner.node_head2:addChild(avatar)
    self._ccbOwner.node_self2:setVisible(fighter2.userId == remote.user.userId)
    self._ccbOwner.node_normal2:setVisible(fighter2.userId ~= remote.user.userId)

	local force2 = fighter2.force or 0
	local num,unit = q.convertLargerNumber(force2)
	self._ccbOwner.tf_force2:setString(num..unit)
	self._ccbOwner.tf_server2:setString(fighter2.game_area_name or "")
	local nameStr = string.format("LV.%d %s", fighter2.level or 0, fighter2.name or "")
	self._ccbOwner.tf_name2:setString(nameStr)

	-- 押注信息状态，对决没押注过是没有信息的，需要显示默认
	self._betInfo = remote.sanctuary:getBetInfoById(self._player1.fighter.userId, self._player2.fighter.userId)
	if not self._betInfo then
		self:showDefaultInfo()
		return
	end
	local scoreList = self._betInfo.scoreList
	if scoreList and next(scoreList) then
		self:showFightResult()
	else
		self:showBetInfo()
	end

	self:showBetNum()
end

function QUIWidgetSanctuaryEliminate:showDefaultInfo()
	self._ccbOwner.node_bet:setVisible(true)
	local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_BETS_8 or state == remote.sanctuary.STATE_BETS_4 or state == remote.sanctuary.STATE_BETS_2 then
		self._ccbOwner.node_btn_bet:setVisible(true)
		self._ccbOwner.tf_bet_info:setVisible(false)
	elseif state == remote.sanctuary.STATE_KNOCKOUT_8_OUT or state == remote.sanctuary.STATE_KNOCKOUT_4_OUT or state == remote.sanctuary.STATE_KNOCKOUT_2_OUT then
		self._ccbOwner.node_btn_bet:setVisible(false)
		self._ccbOwner.tf_bet_info:setVisible(false)
	else
		self._ccbOwner.node_btn_bet:setVisible(false)
		self._ccbOwner.tf_bet_info:setVisible(true)
		self._ccbOwner.tf_bet_info:setString("未押注")
	end
end

function QUIWidgetSanctuaryEliminate:showBetNum()
	local scoreInfos = self._betInfo.scoreDetailInfos or {}
	local totalNum1 = 0
	local totalNum2 = 0
	for i, scoreInfo in pairs(scoreInfos) do
		if scoreInfo.scoreId <= 2 then
			totalNum1 = totalNum1 + scoreInfo.totalNum
		else
			totalNum2 = totalNum2 + scoreInfo.totalNum
		end
	end
	self._ccbOwner.tf_number1:setString(totalNum1.."人")
	self._ccbOwner.tf_number2:setString(totalNum2.."人")
end

function QUIWidgetSanctuaryEliminate:showBetInfo()
	self._ccbOwner.node_bet:setVisible(true)
	self._ccbOwner.node_btn_bet:setVisible(true)
	local myScoreId = self._betInfo.myScoreId or 0
	if myScoreId == 0 then
		self._ccbOwner.tf_bet_info:setVisible(false)
	else
		local score = remote.sanctuary.SCORE_MAP[myScoreId]
		local str = string.format("押注 %d : %d", score[1], score[2])
		self._ccbOwner.tf_bet_info:setString(str)
		self._ccbOwner.tf_bet_info:setVisible(true)
	end
end

function QUIWidgetSanctuaryEliminate:showFightResult()
	self._ccbOwner.node_btn_replay:setVisible(true)
	self._ccbOwner.node_award:setVisible(true)

	local scoreList = self._betInfo.scoreList or {}
	local winNum = 0
	local loseNum = 0
	local fighterNum = #scoreList
	local offsetX = -70
	if fighterNum == 2 then
		offsetX = -35
	end
	for i, win in ipairs(scoreList) do
		if win == true then
			winNum = winNum + 1
		else
			loseNum = loseNum + 1
		end
		local posX = offsetX+70*(i-1)
		local flag1 = QUIWidgetSanctuaryWinloseFlag.new()
		flag1:setIndex(i)
		flag1:setIsWin(win)
		flag1:setPositionX(posX)
		self._ccbOwner.node_result1:addChild(flag1)

		local flag2 = QUIWidgetSanctuaryWinloseFlag.new()
		flag2:setIndex(i)
		flag2:setIsWin(not win)
		flag2:setPositionX(posX)
		self._ccbOwner.node_result2:addChild(flag2)
	end

	local scoreId = 0
	for i, score in ipairs(remote.sanctuary.SCORE_MAP) do
		if score[1] == winNum and score[2] == loseNum then
			scoreId = i
			break
		end
	end
	local myScoreId = self._betInfo.myScoreId or 0
	if myScoreId == 0 then
		self._ccbOwner.tf_award_desc:setString("未押注")
	elseif scoreId == myScoreId then
		self._ccbOwner.tf_award_desc:setString("中奖")
	else
		self._ccbOwner.tf_award_desc:setString("未中奖")
	end

	self._ccbOwner.tf_score_1:setString(winNum)
	self._ccbOwner.tf_score_2:setString(loseNum)
end

function QUIWidgetSanctuaryEliminate:_onTriggerReplay(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_replay) == false then return end
    app.sound:playSound("common_small")
	if not self._player1 or not self._player1.fighter or not self._player2 or not self._player2.fighter then
		return
	end

	local battleInfo = nil
	if self._player1.currRound < self._player2.currRound then
		battleInfo = self._player1
	else
		battleInfo = self._player2
	end
	local isThirdRound = false
	local state = remote.sanctuary:getState()
	if (state == remote.sanctuary.STATE_BETS_2 or state == remote.sanctuary.STATE_FINAL) and self._currentIndex == 2 then
		isThirdRound = true
	end
	if battleInfo ~= nil then
		remote.sanctuary:sanctuaryWarGetReportRequest(battleInfo.currRound, battleInfo.fighter.userId, false, true, isThirdRound, function (data)
			local reports = data.sanctuaryWarGetReportResponse.reports or {}
			if #reports > 0 then
				local report = reports[1]
				QReplayUtil:getReplayInfo(report.reportId, function (data)
					QReplayUtil:downloadReplay(report.reportId, function (replay)
						QReplayUtil:play(replay, data.scoreList, data.fightReportStats, true)
					end, nil, REPORT_TYPE.SANCTUARY_WAR)
				end, nil, REPORT_TYPE.SANCTUARY_WAR)
			end
		end)
	else
		app.tip:floatTip("没有可用的战报~")
	end
end

function QUIWidgetSanctuaryEliminate:_onTriggerVisit1()
    app.sound:playSound("common_small")
	if not self._player1 or not self._player1.fighter then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._player1.fighter.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIWidgetSanctuaryEliminate:_onTriggerVisit2()
    app.sound:playSound("common_small")
	if not self._player2 or not self._player2.fighter then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._player2.fighter.userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIWidgetSanctuaryEliminate:_onTriggerBet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_bet) == false then return end
    app.sound:playSound("common_small")
    if not self._player1 or not self._player1.fighter or not self._player2 or not self._player2.fighter then
		return
	end
	local player1 = self._player1
	local player2 = self._player2
	remote.sanctuary:sanctuaryWarGetTargetBetInfoRequest(self._player1.fighter.userId, self._player2.fighter.userId, function(data)
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryBetInfo", 
			options = {player1 = player1, player2 = player2}}, {isPopCurrentDialog = false})
	end)
end

function QUIWidgetSanctuaryEliminate:_onTriggerLeft(e)
	self._currentIndex = self._currentIndex - 1
	if self._currentIndex < 1 then
		self._currentIndex = self._totalPage
	end
	self:showInfo()
end

function QUIWidgetSanctuaryEliminate:_onTriggerRight(e)
	self._currentIndex = self._currentIndex + 1
	if self._currentIndex > self._totalPage then
		self._currentIndex = 1
	end
	self:showInfo()
end

function QUIWidgetSanctuaryEliminate:_groupClickHandler(event)
	self._currentIndex = event.index
	self:showInfo()
end

return QUIWidgetSanctuaryEliminate