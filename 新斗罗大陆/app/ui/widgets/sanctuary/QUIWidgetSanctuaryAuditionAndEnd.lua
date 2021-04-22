--
-- zxs
-- 精英赛海选
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryAuditionAndEnd = class("QUIWidgetSanctuaryAuditionAndEnd", QUIWidget)
local QUIWidgetSanctuaryAvatar = import("...widgets.sanctuary.QUIWidgetSanctuaryAvatar")
local QSanctuaryArrangement = import("....arrangement.QSanctuaryArrangement")
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")

function QUIWidgetSanctuaryAuditionAndEnd:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_end.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerFight", callback = handler(self, self._onTriggerFight)},
        {ccbCallbackName = "onTriggerRank", callback = handler(self, self._onTriggerRank)},
        {ccbCallbackName = "onTriggerVisit1", callback = handler(self, self._onTriggerVisit1)},
        {ccbCallbackName = "onTriggerVisit2", callback = handler(self, self._onTriggerVisit2)},     
        {ccbCallbackName = "onTriggerVisit3", callback = handler(self, self._onTriggerVisit3)},     
	}
	QUIWidgetSanctuaryAuditionAndEnd.super.ctor(self,ccbFile,callBacks,options)

	self._gloryData = {}
	self._fighters = {}

	-- 预备显示多个
	for i = 1, 3 do
		local fighter = QUIWidgetSanctuaryAvatar.new()
		self._ccbOwner["node_avatar"..i]:addChild(fighter)
		table.insert(self._fighters, fighter)
		fighter:setVisible(false)
	end

	-- 积分位置
	self._myNodePosY = self._ccbOwner.node_tf_self:getPositionY()
	
	self:switchState()
end

function QUIWidgetSanctuaryAuditionAndEnd:onEnter()
	QUIWidgetSanctuaryAuditionAndEnd.super.onEnter(self)

	self._sanctuaryProxy = cc.EventProxy.new(remote.sanctuary)
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_RANK_UPDATE, handler(self, self.updateRankInfo))
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_GLORY_UPDATE, handler(self, self.updateGloryInfo))
	self._sanctuaryProxy:addEventListener(remote.sanctuary.EVENT_SANCTUARY_UPDATE_FORCE, handler(self, self.updateMyBattleForce))
end

function QUIWidgetSanctuaryAuditionAndEnd:onExit()
	QUIWidgetSanctuaryAuditionAndEnd.super.onExit(self)

	if self._sanctuaryProxy ~= nil then
		self._sanctuaryProxy:removeAllEventListeners()
		self._sanctuaryProxy = nil
	end
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QUIWidgetSanctuaryAuditionAndEnd:resetAll()
	self._ccbOwner.node_end:setVisible(false)
	self._ccbOwner.node_no_game:setVisible(false)
	self._ccbOwner.node_fight:setVisible(false)
	self._ccbOwner.node_boss:removeAllChildren()
	self._ccbOwner.node_boss:setScaleX(-1.8)
	self._ccbOwner.node_boss:setScaleY(1.8)
	
	for i = 1, 8 do
		self._ccbOwner["node_tf_"..i]:setVisible(false)
	end
	for i = 1, 3 do
		self._ccbOwner["tf_name"..i]:setString("")
		self._ccbOwner["tf_server"..i]:setString("")
	end
end

function QUIWidgetSanctuaryAuditionAndEnd:switchState()
	self:resetAll()

	local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_MATCH_OPPONENT then
		self:showAudition()
		self._ccbOwner.node_tips:setVisible(false)
	elseif state == remote.sanctuary.STATE_AUDITION_1 or state == remote.sanctuary.STATE_AUDITION_2 or
	 	state == remote.sanctuary.STATE_AUDITION_1_END or state == remote.sanctuary.STATE_AUDITION_2_END then
		self:showAudition()
	elseif state == remote.sanctuary.STATE_ALL_END or state == remote.sanctuary.STATE_NONE then
		self:showAllEnd()
	end

	local selfInfo = remote.sanctuary:getTeamInfo()
	self._ccbOwner.tf_name_self:setString(selfInfo.name or "")
	self._ccbOwner.tf_society_self:setString(selfInfo.game_area_name or "")
	
	remote.sanctuary:sanctuaryWarGetRankScoreRequest()
end

function QUIWidgetSanctuaryAuditionAndEnd:showAudition()
	local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	if not myInfo or not myInfo.seasonUser then
		return
	end

	local seasonScore = myInfo.seasonUser.seasonScore or 0
	local winCount = myInfo.seasonUser.seasonTotalWin or 0
	local loseCount = myInfo.seasonUser.seasonTotalLose or 0
	local currRound = myInfo.seasonUser.currRound or 1
	local currAuditionCount = myInfo.seasonUser.currAuditionCount
	local fighteCount = remote.sanctuary:getTotalFightCount() - currAuditionCount
	if fighteCount < 0 then
		fighteCount = 0
	end

	self._ccbOwner.tf_my_score:setString(string.format("积分：%d", seasonScore))
	self._ccbOwner.tf_my_win_count:setString(string.format("战绩：%d胜%d败", winCount, loseCount))
	self._ccbOwner.node_tf_self:setPositionY(self._myNodePosY)
	self._ccbOwner.tf_society_self:setVisible(false)

	-- 未报名
	if myInfo.signUp == false then
		self._ccbOwner.node_no_game:setVisible(true)
		self._ccbOwner.tf_desc:setString("魂师大人，您本赛季未报名，请在下赛季及时报名~")
		local avatar = QUIWidgetActorDisplay.new(1027)
		self._ccbOwner.node_boss:addChild(avatar)
		self._ccbOwner.node_tips:setVisible(false)
		return
	end

	self._ccbOwner.node_fight:setVisible(false)
	self._ccbOwner.node_tips:setVisible(false)
	local state = remote.sanctuary:getState()
	if state == remote.sanctuary.STATE_MATCH_OPPONENT then
		local title = string.format("海选赛第%d场", 1)
		self._ccbOwner.tf_audition:setString(title)
		self._ccbOwner.node_fight:setVisible(true)
		self._ccbOwner.node_tips:setVisible(true)
		self._ccbOwner.tf_time_desc:setString(string.format("剩余次数：%d", fighteCount))
		self:showFighters(false)
	elseif state == remote.sanctuary.STATE_AUDITION_1 then
		local title
		if fighteCount > 0 then
		 	title = string.format("海选赛第%d场", currAuditionCount+1)
		else
		 	title = string.format("海选赛第%d场(明日开启)", currAuditionCount+1)
		end
		self._ccbOwner.tf_audition:setString(title)
		self._ccbOwner.node_fight:setVisible(true)
		self._ccbOwner.node_tips:setVisible(true)
		self._ccbOwner.tf_time_desc:setString(string.format("剩余次数：%d", fighteCount))
		self:showFighters(fighteCount > 0)
	elseif state == remote.sanctuary.STATE_AUDITION_2 then
		if fighteCount > 0 then
			local title = string.format("海选赛第%d场", currAuditionCount+1+6)
			self._ccbOwner.tf_audition:setString(title)
			self._ccbOwner.node_fight:setVisible(true)
			self._ccbOwner.node_tips:setVisible(true)
			self._ccbOwner.tf_time_desc:setString(string.format("剩余次数：%d", fighteCount))
			self:showFighters(true)
		else
			self._ccbOwner.node_no_game:setVisible(true)
			self._ccbOwner.node_tips:setVisible(false)
			self._ccbOwner.tf_desc:setString("今日海选赛已经结束，晋级名单将在周四0点后生成，并且在周四19:30准时开始淘汰赛~")
			local avatar = QUIWidgetActorDisplay.new(1027)
			self._ccbOwner.node_boss:addChild(avatar)
		end
	elseif state == remote.sanctuary.STATE_AUDITION_1_END then
		self._ccbOwner.node_no_game:setVisible(true)
		self._ccbOwner.node_tips:setVisible(false)
		self._ccbOwner.tf_desc:setString("第一轮海选赛已结束，周三早上5:00准时开始第2轮海选")
		local avatar = QUIWidgetActorDisplay.new(1027)
		self._ccbOwner.node_boss:addChild(avatar)
	elseif state == remote.sanctuary.STATE_AUDITION_2_END then
		self._ccbOwner.node_no_game:setVisible(true)
		self._ccbOwner.node_tips:setVisible(false)
		self._ccbOwner.tf_desc:setString("第二轮海选赛已结束，周四19:30准时开始淘汰赛～")
		local avatar = QUIWidgetActorDisplay.new(1027)
		self._ccbOwner.node_boss:addChild(avatar)
	end
end

function QUIWidgetSanctuaryAuditionAndEnd:updateMyBattleForce()
	if self._fighter1 then
		local myInfo = remote.sanctuary:getSanctuaryMyInfo()
		local selfInfo = remote.sanctuary:getTeamInfo()
		selfInfo.sanctuaryWarScore = myInfo.seasonUser.seasonScore or 0
		self._fighter1:setInfo(selfInfo)
	end
end

--显示avatar（自己和对手的）
function QUIWidgetSanctuaryAuditionAndEnd:showFighters(isShow)
	--设置自己的avatar信息
	if self._fighter1 == nil then
		self._fighter1 = QUIWidgetSanctuaryAvatar.new()
		self._ccbOwner.node_self:addChild(self._fighter1)
	end
	
	local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	local selfInfo = remote.sanctuary:getTeamInfo()
	local defenseTeam = remote.sanctuary:getSanctuaryDefense()
	selfInfo.force = defenseTeam.armyForce or 0
	selfInfo.sanctuaryWarScore = myInfo.seasonUser.seasonScore or 0
	self._fighter1:setInfo(selfInfo)
	self._fighter1:setAvatarScaleX(-1)

	if self._fighter2 == nil then
		self._fighter2 = QUIWidgetSanctuaryAvatar.new()
		self._ccbOwner.node_enemy:addChild(self._fighter2)
	end

	local oldFighter, isWin = remote.sanctuary:getOldFighter()
	local rivalFighter = myInfo.seasonUser.rivalFighter
	local callback = function(isRefresh)
		if isShow and rivalFighter then
			self._fighter2:setShowInfo(true)
			self._fighter2:setInfo(rivalFighter, isRefresh)
		else
			self._fighter2:setInfo()
			self._fighter2:setShowInfo(false)
			self._fighter2:setShowNoFlag(true)
		end
	end

	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	local updateFighter = function()
		self._timeHandler = scheduler.performWithDelayGlobal( function()
				callback(true)
			end, 0)
	end

	if oldFighter and not rivalFighter then
		self._fighter2:setInfo(oldFighter)
		if isWin then
			self._fighter2:showDeadEffect(updateFighter)
		else
			updateFighter()
		end
	elseif oldFighter and rivalFighter and oldFighter.userId ~= rivalFighter.userId then
		self._fighter2:setInfo(oldFighter)
		if isWin then
			self._fighter2:showDeadEffect(updateFighter)
		else
			updateFighter()
		end
	else
		callback()
	end
end

function QUIWidgetSanctuaryAuditionAndEnd:showAllEnd()
	self._ccbOwner.node_end:setVisible(true)
	self._ccbOwner.node_tf_self:setPositionY(self._myNodePosY-10)
	self._ccbOwner.tf_my_score:setString("")
	self._ccbOwner.tf_my_win_count:setString("")
	self._ccbOwner.tf_society_self:setVisible(true)
	self._ccbOwner.node_tips:setVisible(false)

	remote.sanctuary:sanctuaryWarLastSeasonGloryRequest()
end

--显示荣耀墙
function QUIWidgetSanctuaryAuditionAndEnd:updateGloryInfo()
	self._gloryData = remote.sanctuary:getGloryData() or {}
	for index, fighter in ipairs(self._fighters) do
		local info = self._gloryData[index]
		if info then
			fighter:setInfo(info)
			fighter:setVisible(true)
			fighter:setShowInfo(false)
			fighter:setAvatarScaleX(-1)
			self._ccbOwner["tf_name"..index]:setString(info.name)
			self._ccbOwner["tf_server"..index]:setString(info.game_area_name)
		end
	end
end

function QUIWidgetSanctuaryAuditionAndEnd:updateRankInfo()
	for i = 1, 8 do
		self._ccbOwner["node_tf_"..i]:setVisible(false)
	end

	local state = remote.sanctuary:getState()
	local rankInfo = remote.sanctuary:getRankInfo() or {}
	local rankData = rankInfo.fighter or {}
	if #rankData > 0 then
		for index, fighter in ipairs(rankData) do
			self._ccbOwner["node_tf_"..index]:setVisible(true)
			self._ccbOwner["tf_name_"..index]:setString(index..". "..fighter.name)
			if state == remote.sanctuary.STATE_ALL_END or state == remote.sanctuary.STATE_NONE then
				self._ccbOwner["tf_society_"..index]:setString(fighter.game_area_name or "")
			else
				self._ccbOwner["tf_society_"..index]:setString((fighter.sanctuaryWarScore or 0).."积分")
			end
		end
	end
	
	local selfInfo = remote.sanctuary:getTeamInfo()
	self._ccbOwner.tf_name_self:setString((rankInfo.myRank or 0)..". "..(selfInfo.name or ""))
end

function QUIWidgetSanctuaryAuditionAndEnd:_onTriggerVisit1()
    app.sound:playSound("common_small")
	if not self._gloryData[1] then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._gloryData[1].userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIWidgetSanctuaryAuditionAndEnd:_onTriggerVisit2()
    app.sound:playSound("common_small")
	if not self._gloryData[2] then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._gloryData[2].userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

function QUIWidgetSanctuaryAuditionAndEnd:_onTriggerVisit3()
    app.sound:playSound("common_small")
	if not self._gloryData[3] then
		return
	end
	remote.sanctuary:sanctuaryWarQueryFighterRequest(self._gloryData[3].userId, function(data)
		if data.sanctuaryWarQueryFighterResponse ~= nil and data.sanctuaryWarQueryFighterResponse.fighter ~= nil then
			local fighterInfo = data.sanctuaryWarQueryFighterResponse.fighter
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogStromArenaPlayerInfo",
		    	options = {fighterInfo = fighterInfo, specialTitle1 = "当前积分：", specialValue1 = fighterInfo.sanctuaryWarScore or 0, isPVP = true}}, {isPopCurrentDialog = false})
		end
	end)
end

--开始战斗
function QUIWidgetSanctuaryAuditionAndEnd:_onTriggerFight(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_fight) == false then return end
    app.sound:playSound("common_small")

	local state = remote.sanctuary:getState()
	if state ~= remote.sanctuary.STATE_AUDITION_1 and state ~= remote.sanctuary.STATE_AUDITION_2 then
		app.tip:floatTip("海选赛还未开始！")
		return
	end

	local myInfo = remote.sanctuary:getSanctuaryMyInfo()
	if not myInfo or not myInfo.seasonUser or not myInfo.seasonUser.rivalFighter then
		app.tip:floatTip("缺少对手信息！")
		return
	end

	local currAuditionCount = myInfo.seasonUser.currAuditionCount
	local fighteCount = remote.sanctuary:getTotalFightCount() - currAuditionCount
	if fighteCount <= 0 then
		app.tip:floatTip("今日挑战次数不足！")
		return
	end

	local rivalInfo = myInfo.seasonUser.rivalFighter
	remote.sanctuary:sanctuaryWarQueryFighterRequest(rivalInfo.userId, function(data)
		local rivalsFight = data.sanctuaryWarQueryFighterResponse.fighter
		remote.teamManager:sortTeam(rivalsFight.heros, true)
		remote.teamManager:sortTeam(rivalsFight.subheros, true)
		remote.teamManager:sortTeam(rivalsFight.sub2heros, true)
		remote.teamManager:sortTeam(rivalsFight.main1Heros, true)
		remote.teamManager:sortTeam(rivalsFight.sub1heros, true)
		
		local myTeamInfo = remote.sanctuary:getTeamInfo()
		local sanctuaryArrangement1 = QSanctuaryArrangement.new({myInfo = myTeamInfo, rivalInfo = rivalsFight, teamKey = remote.teamManager.SANCTUARY_ATTACK_TEAM1})
		local sanctuaryArrangement2 = QSanctuaryArrangement.new({myInfo = myTeamInfo, rivalInfo = rivalsFight, teamKey = remote.teamManager.SANCTUARY_ATTACK_TEAM2})
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
			options = {arrangement1 = sanctuaryArrangement1, arrangement2 = sanctuaryArrangement2, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo", fighterInfo = rivalsFight}})
	end)
end

--跳转排行榜
function QUIWidgetSanctuaryAuditionAndEnd:_onTriggerRank()
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRank", 
		options = {initRank = "sanctuary"}}, {isPopCurrentDialog = false})
end

return QUIWidgetSanctuaryAuditionAndEnd