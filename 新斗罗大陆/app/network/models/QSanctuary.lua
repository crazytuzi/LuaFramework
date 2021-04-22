-- 
-- zxs
-- 全大陆精英赛
-- 
local QBaseModel = import("...models.QBaseModel")
local QSanctuary = class("QSanctuary", QBaseModel)

local QUIViewController = import("...ui.QUIViewController")
local QSanctuaryDefenseArrangement = import("...arrangement.QSanctuaryDefenseArrangement")

QSanctuary.EVENT_SANCTUARY_UPDATE = "EVENT_SANCTUARY_UPDATE"
QSanctuary.EVENT_SANCTUARY_MY_UPDATE = "EVENT_SANCTUARY_MY_UPDATE"
QSanctuary.EVENT_SANCTUARY_TIME_UPDATE = "EVENT_SANCTUARY_TIME_UPDATE"
QSanctuary.EVENT_SANCTUARY_RANK_UPDATE = "EVENT_SANCTUARY_RANK_UPDATE"
QSanctuary.EVENT_SANCTUARY_GLORY_UPDATE = "EVENT_SANCTUARY_GLORY_UPDATE"
QSanctuary.EVENT_SANCTUARY_AUTO_SIGNUP = "EVENT_SANCTUARY_AUTO_SIGNUP"
QSanctuary.EVENT_SANCTUARY_UPDATE_FORCE = "EVENT_SANCTUARY_UPDATE_FORCE"

QSanctuary.STATE_NONE = 0				--无状态阶段
QSanctuary.STATE_REGISTER = 1 			--报名阶段
QSanctuary.STATE_MATCH_OPPONENT = 2 	--匹配对手阶段
QSanctuary.STATE_AUDITION_1 = 3 		--海选赛第一阶段
QSanctuary.STATE_AUDITION_1_END = 4 	--海选赛第一阶段结束
QSanctuary.STATE_AUDITION_2 = 5 		--海选赛第二阶段
QSanctuary.STATE_AUDITION_2_END = 6 	--海选赛第二阶段结束
QSanctuary.STATE_KNOCKOUT_64 = 7 		--淘汰赛64进32
QSanctuary.STATE_KNOCKOUT_32 = 8 		--淘汰赛32进16
QSanctuary.STATE_KNOCKOUT_16 = 9 		--淘汰赛16进8
QSanctuary.STATE_KNOCKOUT_8_OUT = 10 	--淘汰赛8强出线
QSanctuary.STATE_BETS_8 = 11 			--下注8强
QSanctuary.STATE_KNOCKOUT_8 = 12 		--淘汰赛8进4
QSanctuary.STATE_KNOCKOUT_4_OUT = 13 	--淘汰赛4强出线
QSanctuary.STATE_BETS_4 = 14 			--下注4强
QSanctuary.STATE_KNOCKOUT_4 = 15 		--淘汰赛4进2
QSanctuary.STATE_KNOCKOUT_2_OUT = 16 	--淘汰赛2强出线
QSanctuary.STATE_BETS_2 = 17 			--下注冠军
QSanctuary.STATE_FINAL = 18 			--决赛阶段
QSanctuary.STATE_ALL_END = 19			--全部赛程结束阶段

--1:海选1,2:海选2,3:64进32,4:32进16,5:16进8,6:8进4,7:半决赛,8:决赛
QSanctuary.AUDITION_1 = 1
QSanctuary.AUDITION_2 = 2
QSanctuary.ROUND_64 = 3
QSanctuary.ROUND_32 = 4
QSanctuary.ROUND_16 = 5
QSanctuary.ROUND_8 = 6
QSanctuary.ROUND_4 = 7
QSanctuary.ROUND_2 = 8
QSanctuary.ROUND_1 = 9

QSanctuary.POS_1 = 1 --8进4位
QSanctuary.POS_2 = 2 --4进2位
QSanctuary.POS_3 = 3 --2进1位
QSanctuary.POS_4 = 4 --最终位

QSanctuary.SCORE_MAP = {{2, 0}, {2, 1}, {1, 2}, {0, 2}}

function QSanctuary:ctor(options)
	QSanctuary.super.ctor(self)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QSanctuary:didappear()
	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self,self._onUserPropHandler))

	self:resetData()
end

function QSanctuary:disappear()
	if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QSanctuary:loginEnd()
	if self:checkSanctuaryIsOpen() then
		self:sanctuaryWarMyInfoRequest()
		self:sanctuaryWarLastSeasonGloryRequest()
	end
end

function QSanctuary:_onUserPropHandler(event)
	if self:checkSanctuaryIsOpen() then
		self:resetTimeCount()
	end
end

function QSanctuary:getIsInSeasonTime()
	if not self:getIsServerOpen() then
		return false
	end
    local endTimeAt = self._seasonStartAt / 1000
	if endTimeAt + WEEK > q.serverTime() then
		return true
	else
		return false
	end
end

--判断是否能打开防守阵容布阵
-- return 1是否可以布阵 2 是否是报名
function QSanctuary:checkCanSaveFormation()
	local isSeason = self:getIsInSeasonTime()
	if not isSeason then
		return true,false
	end
	local myInfo = self:getSanctuaryMyInfo()
	if myInfo == nil then
		return false
	end
	local stateConfig = self:getCurrentConfig()
	if stateConfig.state == remote.sanctuary.STATE_REGISTER and not myInfo.signUp then
		return true ,true
	elseif stateConfig.changeTeam == false then
		return false
	elseif not myInfo.signUp then
		return false
	end
	return true,false
end



function QSanctuary:getIsInSeasonTimeForWeeklyTask()
	if self:checkSanctuaryIsOpen() and self._seasonStartAt ~= 0 then
	    local endTimeAt = self._seasonStartAt or 0
	    endTimeAt = endTimeAt / 1000
		if endTimeAt + WEEK + HOUR * 5 > q.serverTime() then --任务的刷新时间为 周一5点
			return true
		end
	end
	return false
end

function QSanctuary:getSeasonStartTime()
	return self._seasonStartAt
end

function QSanctuary:getIsGotSendMoney()
	return self._gotSendMoney
end

function QSanctuary:getIsServerOpen()
	local state = self:getState()
	if state == QSanctuary.STATE_REGISTER then
		return true
	end
	return self._zoneNo ~= 0
end

function QSanctuary:resetData()
	self._guideEnterSanctuary = false			-- 引导
	self._stateChangeTips = false				-- 状态变化拉取新信息
	self._zoneNo = 0 							-- 大区
	self._seasonStartAt = 0 					-- 精英赛季开启时间
	self._state = QSanctuary.STATE_NONE			-- 精英赛状态
	self._betInfo = {}							-- 下注信息
	self._teamInfo = {}							-- 阵容信息
	self._gloryData = {}						-- 荣耀信息
	self._rankInfo = {}							-- 排名信息
	self._positionInfo = {}						-- 位置信息
	self._timeConfigList = {}					-- 精英赛时间配置
	self._championFighter = nil					-- 历届冠军
	self._oldFighter = nil						-- 上个对手
	self._isFightWin = false					-- 上个对手胜利
	self._defenseInfo = nil						-- 防守阵容
	self._isTipsNewInfo = false					-- myInfo是否最新(用于检测是否弹脸提示)
	self._gotSendMoney = false					-- 是否领取过奖励
	self._dispatchList = {}

	local timeConfig = db:getStaticByName("sanctuary_time_config")
	local weekFirstTime = q.getFirstTimeOfWeek()
	for i, v in pairs(timeConfig) do
		v.startAt = self:getCurTimeWeekOffset(v.start_at, weekFirstTime)
		v.endAt = self:getCurTimeWeekOffset(v.end_at, weekFirstTime)
		v.changeTeam = v.change_team == 1
		v.canBet = v.can_bet == 1
		v.state = v.id
		table.insert(self._timeConfigList, v)
	end

	table.sort(self._timeConfigList, function(a, b)
		return a.startAt < b.startAt
	end)
end

function QSanctuary:getCurTimeWeekOffset(timeStr, weekFirstTime)
	local weekTimeTbl = string.split(timeStr, ",")
	local week = tonumber(weekTimeTbl[1]) - 1
	local timeTbl = string.split(weekTimeTbl[2], ":")
	local dateTime = q.date("*t", weekFirstTime)
	dateTime.hour = timeTbl[1] or 0
	dateTime.min = timeTbl[2] or 0
	dateTime.sec = timeTbl[3] or 0
	dateTime.day = dateTime.day + week

    return q.OSTime(dateTime)
end

-- 是否可以进入
function QSanctuary:checkGuideEnterSanctuary()
	return self._guideEnterSanctuary
end

-- 是否可以进入
function QSanctuary:setGuideEnterSanctuary(state)
	self._guideEnterSanctuary = state
end

-- 是否需要请求新数据
function QSanctuary:getStateChangeTips()
	return self._stateChangeTips
end

-- 是否需要请求新数据
function QSanctuary:setStateChangeTips(state)
	self._stateChangeTips = state
end

function QSanctuary:openDialog(callback)
	self._guideEnterSanctuary = false
	self._stateChangeTips = false
	self._oldFighter = nil
	if self:checkSanctuaryIsOpen(true) then
		self:sanctuaryWarInfoRequest(function ()
			self._guideEnterSanctuary = true
			self:resetTimeCount()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuary"})
			if callback then
				callback()
			end
		end, function ()
			if callback then
				callback()
			end
		end)
	else
		if callback then
			callback()
		end
	end
end

function QSanctuary:checkSanctuaryIsOpen(isTips)
	if not app.unlock:checkLock("UNLOCK_SANCTRUARY", isTips) then
		return false
	end

	return true
end

-- 主界面弹窗提示
function QSanctuary:checkGameShowTips()
	local state = self:getState()
	if state == QSanctuary.STATE_REGISTER then
		return 1, false
	elseif state == QSanctuary.STATE_AUDITION_2_END then
		if self._isTipsNewInfo and self._myInfo.signUp then
			return 2, false
		end
	elseif state >= QSanctuary.STATE_KNOCKOUT_8_OUT and state <= QSanctuary.STATE_BETS_8 and self._myInfo.seasonUser.currRound >= QSanctuary.ROUND_8 then
		if self._isTipsNewInfo then
			return 3, false
		end
	elseif state == QSanctuary.STATE_ALL_END then
		if next(self._gloryData) then
			return 4, true
		end
	elseif state == QSanctuary.STATE_NONE then
		local date = q.date("*t", q.serverTime())
		if next(self._gloryData) and date.wday >= 2 and date.wday <= 6 then
			return 4, true
		end
	elseif state == QSanctuary.STATE_AUDITION_1 then
		if self._myInfo.signUp then
			return 5, false
		end
	elseif state == QSanctuary.STATE_AUDITION_2 then
		-- 刘常华提的新需求，要求周二周三都弹脸
		if self._myInfo.signUp then
			return 5.1, false
		end
	elseif state == QSanctuary.STATE_BETS_8 then
		return 6, false
	elseif state == QSanctuary.STATE_BETS_4 then
		return 7, false
	elseif state == QSanctuary.STATE_BETS_2 then
		return 8, false
	end

	return 0, false
end

-- 玩法弹窗提示
function QSanctuary:checkSanctuaryShowTips()
	if not self:getIsServerOpen() then
		return 0
	end
	local state = self:getState()
	if state == QSanctuary.STATE_AUDITION_2_END then
		if next(self._positionInfo) then
			return 1
		end
	elseif state >= QSanctuary.STATE_KNOCKOUT_8_OUT and state <= QSanctuary.STATE_BETS_8 then
		return 2
	end
	return 0
end

--开始计时
function QSanctuary:resetTimeCount()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end

	self._curConfig = nil
	self._nexConfig = nil
	local currentTime = q.serverTime()
	for _, timeConfig in ipairs(self._timeConfigList) do
		if timeConfig.startAt > currentTime then
			self._nexConfig = timeConfig
			break
		end
		self._curConfig = timeConfig
	end

	if not self._curConfig then
		self._curConfig = self._timeConfigList[#self._timeConfigList]
	end
	if not self._nexConfig then
		self._nexConfig = self._timeConfigList[1]
		self._nexConfig.startAt = self._nexConfig.startAt + WEEK
	end
	self._state = self._curConfig.state
	if self:getIsInSeasonTime() then
		local delayTime = 1
		local schedulerTime = self._nexConfig.startAt - currentTime
		self._timeHandler = scheduler.performWithDelayGlobal(function()
				self._stateChangeTips = true
				self:dispatchEvent({name = QSanctuary.EVENT_SANCTUARY_TIME_UPDATE})
			end, schedulerTime+delayTime)
	else
		self._curConfig = {state = QSanctuary.STATE_NONE, canBet = false, changeTeam = false, name = "停赛期间", desc = "新赛季下周一开启，敬请期待~", desc_2 = "新赛季下周一开启，敬请期待~"}
		self._nexConfig = {}
		self._state = self._curConfig.state
	end

	--检查tips
	self:checkRedTips()
end

--检查防守阵容是否发生变化需要更新信息
function QSanctuary:checkDefenseUpdate(callBack)
	local stateConfig = self:getCurrentConfig()
	local myInfo = self:getSanctuaryMyInfo()
	if stateConfig.changeTeam ~= true or not myInfo.signUp then
		if callBack then
			callBack()
		end
		return 
	end
	local defenseInfo = self:getSanctuaryDefense()
	if defenseInfo then
		local battleFormation1 = {}
		local battleFormation2 = {}
		if defenseInfo.battleFormation ~= nil then
			battleFormation1 = defenseInfo.battleFormation
		end
		if defenseInfo.battleFormation2 ~= nil then
			battleFormation2 = defenseInfo.battleFormation2
		end
		local force = remote.teamManager:countBattleFormationForce(battleFormation1)
		force = force + remote.teamManager:countBattleFormationForce(battleFormation2)
		
		local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SANCTUARY_DEFEND_TEAM1, false)
		teamVO:setTeamDataWithBattleFormation(battleFormation1)
		local heroIdList1 = teamVO:getAllTeam()
		local battleFormation1 = remote.teamManager:encodeBattleFormation(heroIdList1)
		local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SANCTUARY_DEFEND_TEAM2, false)
	    teamVO:setTeamDataWithBattleFormation(battleFormation2)
		local heroIdList2 = teamVO:getAllTeam()
		local battleFormation2 = remote.teamManager:encodeBattleFormation(heroIdList2)

		if defenseInfo.armyForce and force ~= defenseInfo.armyForce then
			local sanctuaryDefenseArrangement1 = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM1, isSign = isSign})
			local sanctuaryDefenseArrangement2 = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM2, isSign = isSign})
			local fail = function()
				local dialog = app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMetalCityTeamArrangement",
					options = {arrangement1 = sanctuaryDefenseArrangement1, arrangement2 = sanctuaryDefenseArrangement2, defense = true, isStromArena = true, widgetClass = "QUIWidgetStormArenaTeamBossInfo"}})
			end
			if sanctuaryDefenseArrangement1:teamValidity(heroIdList1[1].actorIds, 1) and sanctuaryDefenseArrangement2:teamValidity(heroIdList2[1].actorIds, 2) then
				local arenaArrangement = QSanctuaryDefenseArrangement.new({teamKey = remote.teamManager.SANCTUARY_DEFEND_TEAM1})
				arenaArrangement:refreshTeam(battleFormation1, battleFormation2, callBack, fail)
			else
				fail()
			end
		else
			if callBack then
				callBack()
			end
		end
	end
end

function QSanctuary:checkTeamRedTips()
	local stateConfig = self:getCurrentConfig()
	local myInfo = self:getSanctuaryMyInfo()
	if stateConfig and stateConfig.changeTeam ~= true or not myInfo.signUp then
		return false
	end

    local team1Main = remote.teamManager:checkTeamIsFull(remote.teamManager.SANCTUARY_DEFEND_TEAM1, 1)
    local team1Help = remote.teamManager:checkTeamIsFull(remote.teamManager.SANCTUARY_DEFEND_TEAM1, 2)
    local team2Main = remote.teamManager:checkTeamIsFull(remote.teamManager.SANCTUARY_DEFEND_TEAM2, 1)
    local team2Help = remote.teamManager:checkTeamIsFull(remote.teamManager.SANCTUARY_DEFEND_TEAM2, 2)
    if team1Main and team1Help and team2Main and team2Help then
        return false
    end

    return true
end

-- 红点
function QSanctuary:checkRedTips()
	if not self:checkSanctuaryIsOpen() then
		return false
	end
	local myInfo = self:getSanctuaryMyInfo()
	if myInfo == nil then 
		return false
	end
	local stateConfig = self:getCurrentConfig()
	if not stateConfig then
		return false
	end
	
	if self:checkRegisterRedTips() then
		return true
	end
	if self:checkBetRedTips() then
		return true
	end
	if self:checkFightRedTips() then
		return true
	end
	if self:checkShopRedTips() then
		return true
	end
	if self:checkTeamRedTips() then
		return true
	end

	return false
end

-- 报名提示
function QSanctuary:checkRegisterRedTips()
	local curConfig = self:getCurrentConfig()
	local myInfo = self:getSanctuaryMyInfo()
	if curConfig and curConfig.state == QSanctuary.STATE_REGISTER and myInfo.signUp == false then
		return true
	end
	return false
end

-- 下注提示
function QSanctuary:checkBetRedTips()
	local curConfig = self:getCurrentConfig()
	local isCanBet = self:getIsCanBet()
	if curConfig and curConfig.canBet and isCanBet then
		return true
	end
	return false
end

-- 挑战提示
function QSanctuary:checkFightRedTips()
	local curConfig = self:getCurrentConfig()
	local myInfo = self:getSanctuaryMyInfo()
	if curConfig and (curConfig.state == QSanctuary.STATE_AUDITION_1 or curConfig.state == QSanctuary.STATE_AUDITION_2) then
		if myInfo.signUp and myInfo.seasonUser.currAuditionCount < self:getTotalFightCount() then
			return true
		end
	end
	return false
end

--商店红点
function QSanctuary:checkShopRedTips(  )
    if remote.stores:checkFuncShopRedTips(SHOP_ID.sanctuaryShop) then
        return true
    end
    return false
end

--设置防守阵容
function QSanctuary:setSanctuaryDefense(defenseInfo)
	self._defenseInfo = defenseInfo
	local battleFormation1 = {}
	local battleFormation2 = {}
	if defenseInfo.battleFormation then
		battleFormation1 = defenseInfo.battleFormation
	end
	if defenseInfo.battleFormation2 then
		battleFormation2 = defenseInfo.battleFormation2
	end

	local teamV1 = remote.teamManager:getTeamByKey(remote.teamManager.SANCTUARY_DEFEND_TEAM1, false)
	teamV1:setTeamDataWithBattleFormation(battleFormation1)
	local teamV2 = remote.teamManager:getTeamByKey(remote.teamManager.SANCTUARY_DEFEND_TEAM2, false)
    teamV2:setTeamDataWithBattleFormation(battleFormation2)

    -- 阵容信息
    local team1Main = teamV1:getTeamActorsByIndex(1)
    local team1Help = teamV1:getTeamActorsByIndex(2)
    local team1Skill = teamV1:getTeamSkillByIndex(2)
    local team2Main = teamV2:getTeamActorsByIndex(1)
    local team2Help = teamV2:getTeamActorsByIndex(2)
    local team2Skill = teamV2:getTeamSkillByIndex(2)
    
    self._teamInfo.heros = {}
    self._teamInfo.subheros = {}
    self._teamInfo.main1Heros = {}
    self._teamInfo.sub1heros = {}

    local insertFunc = function (srcHeros, destHeros)
        if srcHeros ~= nil then
            for _,actorId in pairs(srcHeros) do
                table.insert(destHeros, remote.herosUtil:getHeroByID(actorId))
            end
        end
    end
        
    insertFunc(team1Main, self._teamInfo.heros)
    insertFunc(team1Help, self._teamInfo.subheros)
    insertFunc(team2Main, self._teamInfo.main1Heros)
    insertFunc(team2Help, self._teamInfo.sub1heros)
    
    self._teamInfo.activeSubActorId = team1Skill[1]
    self._teamInfo.active1SubActorId = team1Skill[2]
    self._teamInfo.activeSub2ActorId = team2Skill[1]
    self._teamInfo.active1Sub2ActorId = team2Skill[2]

    local team1Force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SANCTUARY_DEFEND_TEAM1)
    local team2Force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SANCTUARY_DEFEND_TEAM2)
    self._teamInfo.force = team1Force + team2Force

    self._teamInfo.game_area_name = remote.user.myGameAreaName or ""
    self._teamInfo.userId = remote.user.userId
    self._teamInfo.title = remote.user.title
    self._teamInfo.soulTrial = remote.user.soulTrial
    self._teamInfo.name = remote.user.nickname

    -- 更新战力
    for _, info in pairs(self._positionInfo) do
    	if info.fighter.userId == self._teamInfo.userId then
    		info.fighter.force = self._teamInfo.force
    		break
    	end
    end
	self:dispatchEvent({name = QSanctuary.EVENT_SANCTUARY_UPDATE_FORCE})
end

--获取历史下注
function QSanctuary:getTotalBetMoney()
	if self._myInfo then
		return self._myInfo.totalBetMoney or 0
	else
		return 0
	end
end

--获取当前赛季
function QSanctuary:getTeamInfo()
	return self._teamInfo
end

--获取当前赛季
function QSanctuary:getCurrentSeasonNo()
	return self._currentSeasonNo or 1
end

--获取防守阵容
function QSanctuary:getSanctuaryDefense()
	return self._defenseInfo
end

--获取个人信息
function QSanctuary:getSanctuaryMyInfo()
	return self._myInfo
end

--获取当前时间配置
function QSanctuary:getCurrentConfig()
	return self._curConfig
end

--获取下一个时间配置
function QSanctuary:getNextConfig()
	return self._nexConfig
end

--获取当前状态
function QSanctuary:getState()
	return self._state
end

--获取押注信息
function QSanctuary:updateSanctuaryBetInfo(info)
	if not info then
		return
	end

	local isExist = false
	local betInfoList = self._myInfo.infos or {}
	for i, betInfo in ipairs(betInfoList) do
		if info.fighter1.userId == betInfo.fighter1.userId and info.fighter2.userId == betInfo.fighter2.userId then
			betInfoList[i] = info
			isExist = true
			break
		end
	end
	if not isExist then
		self._myInfo.infos = self._myInfo.infos or {}
		table.insert(self._myInfo.infos, info)
	end
end

--获取押注信息
function QSanctuary:getBetInfoById(userId1, userId2)
	local betInfoList = self._myInfo.infos or {}
	for i, betInfo in ipairs(betInfoList) do
		if userId1 == betInfo.fighter1.userId and userId2 == betInfo.fighter2.userId then
			return betInfo
		end
	end
	return nil
end

--获取是否可以押注
function QSanctuary:getIsCanBet()
	local betInfoList = self._myInfo.infos or {}
	for i, betInfo in ipairs(betInfoList) do
		local myScoreId = betInfo.myScoreId or 0
		if myScoreId == 0 then
			return true
		end
	end
	return false
end

--设置个人信息
function QSanctuary:setSanctuaryMyInfo(myInfo, isDispatch)
	self._myInfo = myInfo
	self:checkRedTips()

	-- 64强和8强会有弹脸，需要最新myInfo才弹
	if self._state == QSanctuary.STATE_AUDITION_2_END or self._state == QSanctuary.STATE_KNOCKOUT_8_OUT or self._state == QSanctuary.STATE_BETS_8 then
		self._isTipsNewInfo = true
	else
		self._isTipsNewInfo = false
	end

	if isDispatch then
		self:dispatchEvent({name = QSanctuary.EVENT_SANCTUARY_MY_UPDATE})
	end
end

--设置冠军
function QSanctuary:setChampionFighter(fighter)
	self._championFighter = fighter
end

--设置冠军
function QSanctuary:getChampionFighter()
	return self._championFighter
end

--设置上个对手
function QSanctuary:setOldFighter(fighter, isWin)
	self._oldFighter = fighter
	self._isFightWin = isWin
end

--拿到上个对手
function QSanctuary:getOldFighter()
	return self._oldFighter, self._isFightWin
end

--获取战区区服名称列表
function QSanctuary:setSanctuaryGameAreaNameList(areaList)
	self._areaList = areaList
end

function QSanctuary:getSanctuaryGameAreaNameList()
	return self._areaList
end

--设置排名信息
function QSanctuary:setRankInfo(rankInfo)
	self._rankInfo = rankInfo
end

--获取排名信息
function QSanctuary:getRankInfo()
	return self._rankInfo
end

--设置荣耀信息
function QSanctuary:setGloryData(gloryData)
	self._gloryData = gloryData
end

--获取荣耀信息
function QSanctuary:getGloryData()
	return self._gloryData
end

--是否8强赛
function QSanctuary:isEight()
	local stateConfig = self:getCurrentConfig()
	if stateConfig and stateConfig.state and stateConfig.state > QSanctuary.STATE_KNOCKOUT_8_OUT then
		return true
	end
	return false
end

--设置淘汰赛位置信息
function QSanctuary:getPositionList()
	return self._positionInfo
end

--设置淘汰赛位置信息
function QSanctuary:setPositionInfo(positionInfo)
	self._positionInfo = positionInfo
	local groupWith = self:getGroupWidth()
	if self:isEight() then
		for index, v in pairs(self._positionInfo) do
			if v.currRound <= QSanctuary.ROUND_8 then
				v.localRound = QSanctuary.POS_1
			elseif v.currRound == QSanctuary.ROUND_4 then
				v.localRound = QSanctuary.POS_2
			elseif v.currRound == QSanctuary.ROUND_2 then
				v.localRound = QSanctuary.POS_3
			elseif v.currRound == QSanctuary.ROUND_1 then
				v.localRound = QSanctuary.POS_4
			end
		end
	else
		for index, v in pairs(self._positionInfo) do
			if v.currRound == QSanctuary.ROUND_64 then
				v.localRound = QSanctuary.POS_1
			elseif v.currRound == QSanctuary.ROUND_32 then
				v.localRound = QSanctuary.POS_2
			elseif v.currRound == QSanctuary.ROUND_16 then
				v.localRound = QSanctuary.POS_3
			elseif v.currRound >= QSanctuary.ROUND_8 then
				v.localRound = QSanctuary.POS_4
			end
		end
	end
	table.sort( self._positionInfo, function(a, b)
		return a.position < b.position
	end )
end

--获取自己的海选赛位置
function QSanctuary:getMyPageIndex()
	local groupWith, isFinal, currRound = self:getGroupWidth()
	for _, v in pairs(self._positionInfo) do
		if v.fighter.userId == remote.user.userId and v.currRound >= currRound then
			if isFinal then
				if v.currRound >= QSanctuary.ROUND_2 then
					return 1
				else
					return 2
				end
			else
				local index = math.ceil(v.position/groupWith)
				return index
			end
		end
	end
	return 0
end

--获取总页签数目
function QSanctuary:getGroupWidth()
	local groupWith = 8
	local currRound = QSanctuary.ROUND_64
	local isFinal = false	-- 决赛
	local state = self:getState()
	if state == QSanctuary.STATE_KNOCKOUT_8_OUT or state == QSanctuary.STATE_BETS_8 or state == QSanctuary.STATE_KNOCKOUT_8 then
		groupWith = 16
		currRound = QSanctuary.ROUND_8
	elseif state == QSanctuary.STATE_KNOCKOUT_4_OUT or state == QSanctuary.STATE_BETS_4 or state == QSanctuary.STATE_KNOCKOUT_4 then
		groupWith = 32
		currRound = QSanctuary.ROUND_4
	elseif state == QSanctuary.STATE_KNOCKOUT_2_OUT or state == QSanctuary.STATE_BETS_2 or state == QSanctuary.STATE_FINAL then
		groupWith = 32
		currRound = QSanctuary.ROUND_4
		isFinal = true
	end

	return groupWith, isFinal, currRound
end

--获取总页签数目
function QSanctuary:getTotalPage()
	local maxPos = 0
	for _,v in pairs(self._positionInfo) do
		maxPos = math.max(v.position, maxPos)
	end
	if maxPos > 0 then
		local groupWith = self:getGroupWidth()
		return math.ceil(maxPos/groupWith)
	else
		return 1
	end
end

--根据页签获取数据
function QSanctuary:getInfoByPage(index)
	local players = {}
	local groupWith, isFinal, currRound = self:getGroupWidth()
	if isFinal then
		for _, v in pairs(self._positionInfo) do
			if v.currRound >= QSanctuary.ROUND_2 and index == 1 then
				table.insert(players, v)
			elseif v.currRound == QSanctuary.ROUND_4 and index == 2 then
				table.insert(players, v)
			end
		end
	else
		local startIndex = (index-1)*groupWith+1
		for _, v in pairs(self._positionInfo) do
			if v.currRound >= currRound and startIndex <= v.position and v.position < startIndex + groupWith then
				table.insert(players, v)
			end
		end
	end
	return players
end

--获取海选赛每日战斗总次数
function QSanctuary:getTotalFightCount()
	return db:getConfiguration()["sanctuary_auditions_times"].value
end

function QSanctuary:_dispatchAll()
    local tbl = {}
    for _, name in pairs(self._dispatchList) do
        if not tbl[name] then
            self:dispatchEvent({name = name})
            tbl[name] = true
        end
    end
    self._dispatchList = {}
end

--------------------------- 协议 ----------------------------

------------------------------------------------------

function QSanctuary:responseHandler(data, success, fail, succeeded)
	if data.api == "SANCTUARY_WAR_BET" and data.error == "NO_ERROR" then
		app.taskEvent:updateTaskEventProgress(app.taskEvent.SANCTUARY_BET_COUNT_EVENT, 1)
    end

	--进游戏拉取简单信息
	if data.sanctuaryWarMyInfoResponse ~= nil then
		self._zoneNo = data.sanctuaryWarMyInfoResponse.zoneNo or 1  -- 备注：特殊处理 默认值 1 用于弹脸特殊判断
		self._currentSeasonNo = data.sanctuaryWarMyInfoResponse.seasonNo or 1
		self._seasonStartAt = data.sanctuaryWarMyInfoResponse.seasonStartAt or 0

		self:resetTimeCount()
    	self:setSanctuaryMyInfo(data.sanctuaryWarMyInfoResponse.myInfo)
    	
    	if data.sanctuaryWarMyInfoResponse.battleArmy then
        	self:setSanctuaryDefense(data.sanctuaryWarMyInfoResponse.battleArmy)
        end
    end

    --拉取信息
    if data.sanctuaryWarInfoResponse ~= nil then
    	if data.sanctuaryWarInfoResponse.zoneNo ~= nil then
			self._zoneNo = data.sanctuaryWarInfoResponse.zoneNo
		end
		if data.sanctuaryWarInfoResponse.gotSendMoney ~= nil then
			self._gotSendMoney = data.sanctuaryWarInfoResponse.gotSendMoney or false
		end
		if data.sanctuaryWarInfoResponse.seasonStartAt ~= nil then
			self._seasonStartAt = data.sanctuaryWarInfoResponse.seasonStartAt
		end
        if data.sanctuaryWarInfoResponse.myInfo then
        	if data.api == "SANCTUARY_WAR_AUTO_SIGN_UP" then
        		self._myInfo.autoSignUp = data.sanctuaryWarInfoResponse.myInfo.autoSignUp
       		 	table.insert(self._dispatchList, QSanctuary.EVENT_SANCTUARY_AUTO_SIGNUP)
        	else
        		self:setSanctuaryMyInfo(data.sanctuaryWarInfoResponse.myInfo)
        	end
        end
        if data.sanctuaryWarInfoResponse.cmpionFighter then
        	self:setChampionFighter(data.sanctuaryWarInfoResponse.championFighter)
        end
    	if data.sanctuaryWarInfoResponse.battleArmy then
        	self:setSanctuaryDefense(data.sanctuaryWarInfoResponse.battleArmy)
        end
    	if data.sanctuaryWarInfoResponse.positions then
        	self:setPositionInfo(data.sanctuaryWarInfoResponse.positions)
        end
    end

	--跨服海选赛战斗结束
	if data.gfEndResponse ~= nil and data.gfEndResponse.sanctuaryWarAuditionFightEndResponse ~= nil then
		
		app.taskEvent:updateTaskEventProgress(app.taskEvent.SANCTUARY_TASK_EVENT, 1)

		local oldFighter = clone(self._myInfo.seasonUser.rivalFighter)
		self:setOldFighter(oldFighter, data.gfEndResponse.isWin)
    	self:setSanctuaryMyInfo(data.gfEndResponse.sanctuaryWarAuditionFightEndResponse.myInfo)
    end

    if data.sanctuaryWarLastSeasonGloryResponse ~= nil then
    	self:setGloryData(data.sanctuaryWarLastSeasonGloryResponse.fighters or {})
        table.insert(self._dispatchList, QSanctuary.EVENT_SANCTUARY_GLORY_UPDATE)
    end

    if data.sanctuaryWarGetScoreRankResponse ~= nil then
    	self:setRankInfo(data.sanctuaryWarGetScoreRankResponse)
        table.insert(self._dispatchList, QSanctuary.EVENT_SANCTUARY_RANK_UPDATE)
    end

    if data.sanctuaryWarSignUpResponse ~= nil then
    	self:setSanctuaryMyInfo(data.sanctuaryWarSignUpResponse.myInfo)
		if data.sanctuaryWarSignUpResponse.battleArmy then
	    	self:setSanctuaryDefense(data.sanctuaryWarSignUpResponse.battleArmy)
	    end
    end

    if data.sanctuaryWarModifyArmyResponse ~= nil then
    	self:setSanctuaryMyInfo(data.sanctuaryWarModifyArmyResponse.myInfo)
		if data.sanctuaryWarModifyArmyResponse.battleArmy then
	    	self:setSanctuaryDefense(data.sanctuaryWarModifyArmyResponse.battleArmy)
	    end
    end

    if data.sanctuaryWarGetGameAreaListResponse ~= nil then
    	self:setSanctuaryGameAreaNameList(data.sanctuaryWarGetGameAreaListResponse.gameAreaNameList)
    end

    if data.sanctuaryWarBetResponse ~= nil then
    	self:setSanctuaryMyInfo(data.sanctuaryWarBetResponse.myInfo, true)
    end

    if data.sanctuaryWarGetTargetBetInfoResponse ~= nil then
    	self:updateSanctuaryBetInfo(data.sanctuaryWarGetTargetBetInfoResponse.info)
		self:dispatchEvent({name = QSanctuary.EVENT_SANCTUARY_MY_UPDATE})
    end

	if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end

    -- 事件
    self:_dispatchAll()
end

--进游戏拉取简单信息
function QSanctuary:sanctuaryWarMyInfoRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--拉取信息
function QSanctuary:sanctuaryWarInfoRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 精英赛海选开始
function QSanctuary:requestSanctuaryFightStartRequest(battleFormation1, battleFormation2, success, fail)
    local gfStartRequest = {battleType = BattleTypeEnum.SANCTUARY_WAR, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

-- 精英赛海选战斗结算
function QSanctuary:requestSanctuaryFightEndRequest(rivalUserId, battleFormation1, battleFormation2, battleKey, success, fail)
    local requestSanctuaryFightEndRequest = {rivalUserId = rivalUserId, fightResult = fightResult}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.SANCTUARY_WAR, battleVerify = battleVerify, fightReportData = fightReportData, sanctuaryWarAuditionFightEndRequest = sanctuaryWarAuditionFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
    	remote.user:addPropNumForKey("todaySanctuaryFightCount")--记录今日全大陆精英赛报名次数
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取战报
function QSanctuary:sanctuaryWarGetReportRequest(currRound, rivalUserId, topReport, isEightReport, isThirdRound, success, fail)
	local sanctuaryWarGetReportRequest = {currRound = currRound, rivalUserId = rivalUserId, topReport = topReport, isEightReport = isEightReport, isThirdRound = isThirdRound}
    local request = {api = "SANCTUARY_WAR_GET_REPORT", sanctuaryWarGetReportRequest = sanctuaryWarGetReportRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取个人战报 
function QSanctuary:sanctuaryWarGetMyReportRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_GET_MY_REPORT"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取8强64战报 
function QSanctuary:sanctuaryWarGetSpecialReportRequest(isEight, success, fail)
	local sanctuaryWarGetNbReportRequest = {isNb8Repoort = isEight}
    local request = {api = "SANCTUARY_WAR_GET_NB_REPORTS", sanctuaryWarGetNbReportRequest = sanctuaryWarGetNbReportRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取防守阵容
function QSanctuary:sanctuaryWarQueryFighterRequest(userId, success, fail)
	local sanctuaryWarQueryFighterRequest = {userId = userId}
    local request = {api = "SANCTUARY_WAR_QUERY_FIGHTER", sanctuaryWarQueryFighterRequest = sanctuaryWarQueryFighterRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--简易积分排名
function QSanctuary:sanctuaryWarGetRankScoreRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_GET_RANK_SCORE"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--报名 
function QSanctuary:sanctuaryWarSignUpRequest(battleFormation1, battleFormation2, replayData, success, fail)
	local sanctuaryWarSignUpRequest = {replayData = replayData}
    local request = {api = "SANCTUARY_WAR_SIGN_UP", sanctuaryWarSignUpRequest = sanctuaryWarSignUpRequest, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	remote.user:addPropNumForKey("todaySanctuarySignUpCount")--记录今日全大陆精英赛报名次数
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--自动报名 
function QSanctuary:sanctuaryWarAutoSignUpRequest(isAutoSignUp, success, fail)
	local sanctuaryWarAutoSignUpRequest = {isAutoSignUp = isAutoSignUp}
    local request = {api = "SANCTUARY_WAR_AUTO_SIGN_UP", sanctuaryWarAutoSignUpRequest = sanctuaryWarAutoSignUpRequest}
    app:getClient():requestPackageHandler(request.api, request, function (data)
    	remote.user:addPropNumForKey("todaySanctuarySignUpCount")--记录今日全大陆精英赛报名次数
    	self:responseHandler(data, success, fail, true)
    end)
end

--更新出战阵容 
function QSanctuary:sanctuaryWarModifyArmyRequest(battleFormation1, battleFormation2, replayData, success, fail)
	local sanctuaryWarModifyArmyRequest = {replayData = replayData}
    local request = {api = "SANCTUARY_WAR_MODIFY_ARMY", sanctuaryWarModifyArmyRequest = sanctuaryWarModifyArmyRequest, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取荣耀墙信息 
function QSanctuary:sanctuaryWarLastSeasonGloryRequest(seasonNo, success, fail)
	local sanctuaryWarLastSeasonGloryRequest = {seasonNo = seasonNo}
    local request = {api = "SANCTUARY_WAR_LAST_SEASON_GLORY"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取战区区服名称 
function QSanctuary:sanctuaryWarFightAreaListRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_GET_GAME_AREA_LIST"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取押注列表
function QSanctuary:sanctuaryWarGetBetInfoRequest(success, fail)
	local request = {api = "SANCTUARY_WAR_GET_BET_INFO"}
	app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--押注某一个玩家
function QSanctuary:sanctuaryWarBetRequest(fighter1Id, fighter2Id, scoreId, betAward, success, fail)
	local sanctuaryWarBetRequest = {fighter1Id = fighter1Id, fighter2Id = fighter2Id, scoreId = scoreId, betAward = betAward}
	local request = {api = "SANCTUARY_WAR_BET", sanctuaryWarBetRequest = sanctuaryWarBetRequest}
	app:getClient():requestPackageHandler(request.api, request, function (response)
    	remote.user:addPropNumForKey("todaySanctuaryBetCount")--记录今日全大陆精英赛报名次数
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--淘汰赛奖励 
function QSanctuary:sanctuaryWarRewardListRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_REWARD_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--淘汰赛领奖
function QSanctuary:sanctuaryWarGetRewardRequest(rewardId, success, fail)
	local sanctuaryWarGetRewardRequest = {rewardId = rewardId}
    local request = {api = "SANCTUARY_WAR_GET_REWARD", sanctuaryWarGetRewardRequest = sanctuaryWarGetRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 获取押注信息
function QSanctuary:sanctuaryWarGetTargetBetInfoRequest(userId1, userId2, success, fail)
	local sanctuaryWarGetTargetBetInfoRequest = {fighter1Id = userId1, fighter2Id = userId2}
    local request = {api = "SANCTUARY_WAR_GET_TARGET_BET_INFO", sanctuaryWarGetTargetBetInfoRequest = sanctuaryWarGetTargetBetInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 领取赠送奖励
function QSanctuary:sanctuaryWarGetSendMoneyRequest(success, fail)
    local request = {api = "SANCTUARY_WAR_GET_SEND_MONEY"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QSanctuary