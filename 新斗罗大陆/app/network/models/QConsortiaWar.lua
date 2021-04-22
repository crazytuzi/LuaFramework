-- @Author: zhouxiaoshu
-- @Date:   2019-04-26 10:57:55
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-26 18:18:14
local QBaseModel = import("...models.QBaseModel")
local QConsortiaWar = class("QConsortiaWar", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QActorProp = import("...models.QActorProp")

QConsortiaWar.STATE_NONE = "STATE_NONE"				-- 无战事
QConsortiaWar.STATE_READY = "STATE_READY"			-- 准备期
QConsortiaWar.STATE_READY_END = "STATE_READY_END"	-- 准备期结束
QConsortiaWar.STATE_FIGHT = "STATE_FIGHT"			-- 战斗期
QConsortiaWar.STATE_FIGHT_END = "STATE_FIGHT_END"	-- 战斗期结束

QConsortiaWar.READY_AT = 9
QConsortiaWar.READY_END = 11
QConsortiaWar.START_AT = 12
QConsortiaWar.START_END = 23

QConsortiaWar.FLAG_COUNT = 8

QConsortiaWar.EVENT_CONSORTIA_WAR_UPDATE_INFO = "EVENT_CONSORTIA_WAR_UPDATE_INFO"
QConsortiaWar.EVENT_CONSORTIA_WAR_UPDATE_AWARD = "EVENT_CONSORTIA_WAR_UPDATE_AWARD"
QConsortiaWar.EVENT_CONSORTIA_WAR_UPDATE_FORCE = "EVENT_CONSORTIA_WAR_UPDATE_FORCE"

function QConsortiaWar:ctor(options)
	QConsortiaWar.super.ctor(self)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QConsortiaWar:didappear()
	self:resetData()
end

function QConsortiaWar:disappear()
    if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
end

function QConsortiaWar:loginEnd()
    if app.unlock:checkLock("UNLOCK_CONSORTIA_WAR") then
		self:consortiaWarGetMyInfoRequest()
    end
end

function QConsortiaWar:resetData()
	self._currSeason = {}			-- 赛季信息
	self._myConsortiaInfo = {}		-- 宗门战信息
	self._myInfo = {}				-- 我的信息
	self._teamInfo = {}				-- 战队信息
	self._tempHallPlayers = {}		-- 成员缓存
	self._hallInfoList = {}			-- 堂列表信息
	self._memberList = {}			-- 宗门成员列表

	self._consortiaInfo1 = {}		-- 左边宗门战信息
	self._consortiaInfo2 = {}		-- 右边宗门战信息
	self._hallBattleList1 = {}		-- 左边堂列表信息
	self._hallBattleList2 = {}		-- 右边堂列表信息

	self._rewardList = {}			-- 奖励列表
	self._envRank = 0
	self._allRank = 0

	self._readyStartTime = q.getTimeForHMS(QConsortiaWar.READY_AT, 0, 0)
	self._readyEndTime = q.getTimeForHMS(QConsortiaWar.READY_END, 0, 0)
	self._fightStartTime = q.getTimeForHMS(QConsortiaWar.START_AT, 0, 0)
	self._fightEndTime = q.getTimeForHMS(QConsortiaWar.START_END, 0, 0)

	-- hall
    self._hallConfigs = db:getStaticByName("consortia_war_hall")
    -- 设置默认
    for i = 1, 4 do
    	local hallInfo = {
			hallId = i,
   			memberCount = 0,
    		breakThroughMemberCount = 0,
    		remainFlagCount = 0,
    		memberList = {},
    		isLeaderBreakThrough = false,
    		isBreakThrough = false,
    	}
    	self._hallInfoList[i] = hallInfo
    	self._hallBattleList1[i] = hallInfo
    	self._hallBattleList2[i] = hallInfo
    end
end

function QConsortiaWar:openDialog()
	local callback = function()
		self:resetTimeCount()
		remote.consortiaWar:consortiaWarGetDailyRewardListRequest(function()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogConsortiaWar"})
		end)
	end
 	if app.unlock:checkLock("UNLOCK_CONSORTIA_WAR", true) then
		self:resetData()
		self:consortiaWarGetMainInfoRequest(callback)
	end
end

--开始计时
function QConsortiaWar:resetTimeCount()
	if self._timeHandler ~= nil then
		scheduler.unscheduleGlobal(self._timeHandler)
		self._timeHandler = nil
	end
	local state, nextAt = self:getStateAndNextStateAt()
	local offsetTime = nextAt - q.serverTime()
	self._timeHandler = scheduler.performWithDelayGlobal(function()
			self:consortiaWarGetMainInfoRequest(function()
	        	self:dispatchEvent({name = QConsortiaWar.EVENT_CONSORTIA_WAR_UPDATE_INFO})
	        end)
		end, offsetTime+3)
end

-- 赛季开始时间
function QConsortiaWar:getSeasonStartAt()
    return (self._currSeason.seasonStartAt or 0)/ 1000
end

-- 当前状态和现在状态开始时间
function QConsortiaWar:getStateAndNextStateAt()
	local startAt = self:getSeasonStartAt()
	local curTime = q.serverTime()
	local offsetTime = q.serverTime() - startAt
	offsetTime = offsetTime % (2*WEEK)
	if offsetTime <= DAY then
		return QConsortiaWar.STATE_READY, self._fightStartTime + DAY
	elseif offsetTime <= DAY + QConsortiaWar.READY_AT*HOUR then
		return QConsortiaWar.STATE_READY, self._fightStartTime
	elseif offsetTime <= WEEK then
		if curTime < self._readyStartTime then
			return QConsortiaWar.STATE_FIGHT_END, self._readyStartTime
		elseif curTime < self._readyEndTime then	
			return QConsortiaWar.STATE_READY, self._fightStartTime
		elseif curTime < self._fightStartTime then
			return QConsortiaWar.STATE_READY_END, self._fightStartTime
		elseif curTime < self._fightEndTime then
			return QConsortiaWar.STATE_FIGHT, self._fightEndTime
		else
			return QConsortiaWar.STATE_FIGHT_END, self._readyStartTime + DAY
		end
	else
		return QConsortiaWar.STATE_NONE, startAt + WEEK*2
	end
end


function QConsortiaWar:getIsInSeasonTimeForWeeklyTask()
	local startAt = self:getSeasonStartAt()
	if app.unlock:checkLock("UNLOCK_CONSORTIA_WAR") and startAt ~= 0 then
		if startAt + WEEK + HOUR * 5 > q.serverTime() then --任务的刷新时间为 周一5点
			return true
		end
	end
	return false
end


function QConsortiaWar:checkGameShowTips()
	local startAt = self:getSeasonStartAt()
	local offsetTime = q.serverTime() - startAt
	offsetTime = offsetTime % (2*WEEK)
	if offsetTime <= DAY then
		return true
	end
	return false
end

-- 堂配置
function QConsortiaWar:getHallConfigByHallId(hallId)
	local hallConfig = self._hallConfigs[tostring(hallId)]
	return hallConfig
end

-- 我的宗门战信息
function QConsortiaWar:getMyInfo()
	return self._myInfo
end

-- 宗门战信息
function QConsortiaWar:getConsortiaWarInfo()
	return self._myConsortiaInfo
end

-- 备战我方堂信息
function QConsortiaWar:getHallInfoByHallId(hallId)
	return self._hallInfoList[hallId] or {}
end

-- 战斗堂列表
function QConsortiaWar:getBattleHallInfoList(isMe)
	if isMe then
		return self._hallBattleList1
	else
		return self._hallBattleList2
	end
end

-- 战斗堂信息
function QConsortiaWar:getBattleConsortiaInfoList(isMe)
	if isMe then
		return self._consortiaBattle1
	else
		return self._consortiaBattle2
	end
end

-- 我方堂信息
function QConsortiaWar:getMyHallInfoByHallId(hallId)
	local hallList = self:getBattleHallInfoList(true)
	return hallList[hallId] or {}
end

-- 敌方堂信息
function QConsortiaWar:getEnemyHallInfoByHallId(hallId)
	local hallList = self:getBattleHallInfoList(false)
	return hallList[hallId] or {}
end

-- 获取集火设置
function QConsortiaWar:getAttackOrderList()
	return self._attackOrderList or {}
end

function QConsortiaWar:getSetFireFlagHallId( )
	local attackOrderList = self:getAttackOrderList()
	local lifeHalls = {}
	for _,v in pairs(attackOrderList) do
		local hallInfo = self:getEnemyHallInfoByHallId(v.hallId)
		if not hallInfo.isBreakThrough then
			table.insert(lifeHalls,v)
		end
	end
	if q.isEmpty(lifeHalls) then
		return nil
	else
		table.sort( lifeHalls, function(a,b)
			return a.order < b.order
		end )
		return lifeHalls[1].hallId
	end
end

--自己的堂
function QConsortiaWar:getMyHallInfo()
	local hallList = {}
	local state = self:getStateAndNextStateAt()
	if state == QConsortiaWar.STATE_READY or state == QConsortiaWar.STATE_READY_END then
		hallList = self._hallInfoList or {}
	else
		hallList = self:getBattleHallInfoList(true)
	end
	local userId = remote.user.userId
	for i, hallInfo in pairs(hallList) do
		for i, player in pairs(hallInfo.memberList or {}) do
			if player.memberId == userId then
				return hallInfo, player.isLeader
			end
		end
	end
	return nil, false
end

-- 获取准备期堂旗帜数
function QConsortiaWar:getReadyHallTotalFlags( hallId )
	local hallList = self._hallInfoList or {}
	local flags = 0
	local memberList = hallList[hallId].memberList or {}
	for i, member in pairs(memberList) do
		flags = flags + member.remainFlagCount
	end
	flags = flags + QConsortiaWar.FLAG_COUNT - (hallList[hallId].pickFlagCount or 0)
	return flags
end

-- 获取堂旗帜数
function QConsortiaWar:getHallTotalFlags(isMe, hallId)
	local hallList = self:getBattleHallInfoList(isMe)
	local flags = 0
	local memberList = hallList[hallId].memberList or {}
	for i, member in pairs(memberList) do
		flags = flags + member.remainFlagCount
	end
	flags = flags + QConsortiaWar.FLAG_COUNT - (hallList[hallId].pickFlagCount or 0)
	return flags
end

-- 获取总的旗帜数
function QConsortiaWar:getTotalFlags(isMe)
	local flags = 0
	for hallId = 1, 4 do
		flags = flags + self:getHallTotalFlags(isMe, hallId)
	end
	return flags
end

function QConsortiaWar:getRankConfig()
    local configs = {}
	local level = remote.user.level
    local rankConfigs = db:getStaticByName("consortia_war_rank")
    for _, value in pairs(rankConfigs) do
        if value.level_min <= level and value.level_max >= level then
            table.insert(configs, value)
        end
    end
    return configs
end

function QConsortiaWar:getRewardConfig()
    local configs = {}
	local level = remote.user.level
    local rewardConfigs = db:getStaticByName("consortia_war_per_fight_reward")
    for _, value in pairs(rewardConfigs) do
        if value.level_min <= level and value.level_max >= level then
            return value
        end
    end
    return {}
end

function QConsortiaWar:getRankInfo(floor)
    local rankConfigs = self:getRankConfig()
    for _,v in pairs(rankConfigs) do
        if floor == v.dan then
            return v
        end
    end
    return {}
end

local FLOOR_FRAME_COLOR = {
	{ccc3(166,199,189), ccc3(34,51,46)},
	{ccc3(205,232,250), ccc3(57,78,91)},
	{ccc3(255,253,19), ccc3(114,69,35)},
	{ccc3(216,249,255), ccc3(34,51,46)},
	{ccc3(216,249,255), ccc3(74,44,152)},
	{ccc3(255,246,145), ccc3(135,78,0)},
	{ccc3(255,246,145), ccc3(135,78,0)},
}

function QConsortiaWar:getColorByBigFloor(bigFloor)
   	return FLOOR_FRAME_COLOR[bigFloor]
end

--段位
function QConsortiaWar:getFloorTextureName(floor)
	if floor == nil then return nil, nil end

	local icon, num
    local config = self:getRankInfo(floor)
    local floorIcon = string.split(config.dan_icon or "", "^")
    if floorIcon[1] then
    	icon = QResPath("union_war_floor_icon")[tonumber(floorIcon[1])]
    end
    if floorIcon[2] then
        num = QResPath("union_war_floor_num")[tonumber(floorIcon[2])]
    end
	return config.name, icon, num
end

-- 堂buff属性
function QConsortiaWar:getHallBuffPropByHallId(hallId)
	local hallConfig = self._hallConfigs[tostring(hallId)] or {}
	local props = {}
	for key, value in pairs(hallConfig) do
		if QActorProp._field[key] then
			local prop = {}
			local name = QActorProp._field[key].uiName or QActorProp._field[key].name
			prop.name = name
			prop.value = value
			table.insert(props, prop)
		end
	end
	return props
end

-- 堂buff的id二进制合并
function QConsortiaWar:getBreakHallIdNum()
	local idNum = 0
	local hallList = self:getBattleHallInfoList(false)
	for i, hall in pairs(hallList) do
		if hall.isBreakThrough then
			local bitNum = bit.lshift(1, hall.hallId - 1)
			idNum = bit.bor(idNum, bitNum)
		end
	end
	return idNum
end

-- 堂图片，特效
function QConsortiaWar:getHallResByHallId(hallId, hallNum, isMe)
	local hallPic = nil
	if isMe then
		hallPic = QResPath("union_war_hall_blue")[hallId] or {}
	else
		hallPic = QResPath("union_war_hall_red")[hallId] or {}
	end
	local hallEffect = QResPath("union_war_hall_effect")[hallId] or {}

    return hallPic[hallNum], hallEffect[hallNum]
end

--获取的成员列表
function QConsortiaWar:getConsortiaWarMemberList()
	return self._memberList
end

function QConsortiaWar:getFigherHallIdByUserId(userId)
	for i, hallInfo in pairs(self._tempHallList or {}) do
		for i, player in pairs(hallInfo.memberList or {}) do
			if player.memberId == userId then
				return hallInfo.hallId
			end
		end
	end
	return 0
end

-- 更新堂信息
function QConsortiaWar:updateHallInfo(hallInfo)
	self._hallInfoList[hallInfo.hallId] = hallInfo
end

-- 更新堂信息
function QConsortiaWar:updateHallBattleInfo(hallInfo, isMe)
	local hallList = self:getBattleHallInfoList(isMe)
	hallList[hallInfo.hallId] = hallInfo
end

-- 更新战斗信息
function QConsortiaWar:updateBattleInfo(battleInfo)
	-- 自己的放在左边
	if battleInfo.consortiaBattle1.consortiaId == remote.user.userConsortia.consortiaId then
		self._consortiaBattle1 = battleInfo.consortiaBattle1
		self._consortiaBattle2 = battleInfo.consortiaBattle2
		for i, hallInfo in pairs(battleInfo.hallInfoList1 or {}) do
			self:updateHallBattleInfo(hallInfo, true)
		end
		for i, hallInfo in pairs(battleInfo.hallInfoList2 or {}) do
			self:updateHallBattleInfo(hallInfo, false)
		end
	else
		self._consortiaBattle1 = battleInfo.consortiaBattle2
		self._consortiaBattle2 = battleInfo.consortiaBattle1
		for i, hallInfo in pairs(battleInfo.hallInfoList2 or {}) do
			self:updateHallBattleInfo(hallInfo, true)
		end
		for i, hallInfo in pairs(battleInfo.hallInfoList1 or {}) do
			self:updateHallBattleInfo(hallInfo, false)
		end
	end
end

-- 获取第一个奖励
function QConsortiaWar:getRewardInfo()
    if self._rewardList and self._rewardList[1] then 
        return self._rewardList[1]
    end
end

--更新奖励 删除已领取的
function QConsortiaWar:updateReward(rewardId)
    if self._rewardList then
        for i, rewards in pairs(self._rewardList) do
            if rewards.rewardId == rewardId then
                table.remove( self._rewardList, i )
                break
            end
        end
        self:dispatchEvent({name = QConsortiaWar.EVENT_CONSORTIA_WAR_UPDATE_AWARD})
    end
end

--获取每天排名信息
function QConsortiaWar:getDailyRankInfo()
	return self._envRank, self._allRank
end

--设置缓存的成员
function QConsortiaWar:setTempHallList()
	self._tempHallList = clone(self._hallInfoList or {})
end

--获得缓存成员
function QConsortiaWar:getTempHallByHallId(hallId)
	return self._tempHallList[hallId] or {}
end

--更新缓存的成员
function QConsortiaWar:updateTempHall(isUp, hallId, member)
	local hallInfo = self:getTempHallByHallId(hallId)
	hallInfo.memberList = hallInfo.memberList or {}
	if isUp then
		-- 相同的
		for i, v in pairs(hallInfo.memberList) do
			if v.memberId == member.memberId then
				return
			end
		end
		table.insert(hallInfo.memberList, member)
	else
		for i, v in pairs(hallInfo.memberList) do
			if v.memberId == member.memberId then
				table.remove(hallInfo.memberList, i)
				break
			end
		end
	end
end

--获取防守阵容
function QConsortiaWar:getConsortiaWarDefense()
	return self._defenseInfo or {}
end

--设置防守阵容
function QConsortiaWar:setConsortiaWarDefense(defenseInfo)
	self._defenseInfo = defenseInfo

	local battleFormation1 = {}
	local battleFormation2 = {}
	if defenseInfo.battleFormation then
		battleFormation1 = defenseInfo.battleFormation
	end
	if defenseInfo.battleFormation2 then
		battleFormation2 = defenseInfo.battleFormation2
	end
	-- QPrintTable(defenseInfo)
	local teamV1 = remote.teamManager:getTeamByKey(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1, false)
	teamV1:setTeamDataWithBattleFormation(battleFormation1)
	local teamV2 = remote.teamManager:getTeamByKey(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2, false)
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

    local team1Force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1)
    local team2Force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2)
    self._teamInfo.force = team1Force + team2Force

    self._teamInfo.game_area_name = remote.user.myGameAreaName or ""
    self._teamInfo.userId = remote.user.userId
    self._teamInfo.title = remote.user.title
    self._teamInfo.soulTrial = remote.user.soulTrial
    self._teamInfo.name = remote.user.nickname

	self:dispatchEvent({name = QConsortiaWar.EVENT_UPDATE_FORCE})
end

--获取当前赛季
function QConsortiaWar:getTeamInfo()
	return self._teamInfo
end

--获取每日战斗总次数
function QConsortiaWar:getTotalFightCount()
	local hallInfo, isLeader = self:getMyHallInfo()
	if isLeader then
		return db:getConfiguration()["CONSORTIA_WAR_HALL_ATTACK_TIME"].value
	else
		return db:getConfiguration()["CONSORTIA_WAR_ATTACK_TIME"].value
	end
end

-- 堂最大人数
function QConsortiaWar:getHallMemberCount()
	return 11--db:getConfiguration()["society_battle_number"].value
end

-- 战队红点
function QConsortiaWar:checkTeamRedTips()
	local state = self:getStateAndNextStateAt()
	if state ~= QConsortiaWar.STATE_READY then
		return false
	end

    local team1Main = remote.teamManager:checkTeamIsFull(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1, 1)
    local team1Help = remote.teamManager:checkTeamIsFull(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM1, 2)
    local team2Main = remote.teamManager:checkTeamIsFull(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2, 1)
    local team2Help = remote.teamManager:checkTeamIsFull(remote.teamManager.CONSORTIA_WAR_DEFEND_TEAM2, 2)
    if team1Main and team1Help and team2Main and team2Help then
        return false
    end

    return true
end

function QConsortiaWar:getIsInSeasonTime()
	local state = self:getStateAndNextStateAt()
	return state ~= QConsortiaWar.STATE_NONE
end

-- 挑战提示
function QConsortiaWar:checkFightRedTips()
	if not app.unlock:checkLock("UNLOCK_CONSORTIA_WAR") then
		return false
	end
	local state = self:getStateAndNextStateAt()
	if state ~= QConsortiaWar.STATE_FIGHT then
		return false
	end
	local myInfo = self:getMyInfo()
	if (myInfo.fightCount or 0) < self:getTotalFightCount() then
		return true
	end
	return false
end

-- 红点
function QConsortiaWar:checkRedTips()
	if not app.unlock:checkLock("UNLOCK_CONSORTIA_WAR") then
		return false
	end
	if self:checkTeamRedTips() then
		return true
	end
	if self:checkFightRedTips() then
		return true
	end
	return false
end

-- //公会战API定义
-- CONSORTIA_WAR_GET_MY_INFO                   = 6201;                     // 公会战-获取主界面信息（对战主界面或布阵主界面）ConsortiaWarGetMyInfoRequest ConsortiaWarGetMyInfoResponse
-- CONSORTIA_WAR_GET_MAIN_INFO                 = 6202;                     // 公会战-获取我的信息 ConsortiaWarGetMainInfoRequest ConsortiaWarGetMainInfoResponse
-- CONSORTIA_WAR_SET_DEFENSE_ARMY              = 6203;                     // 公会战-设置个人防守阵容
-- CONSORTIA_WAR_SET_HALL_AUTO_FILL            = 6204;                     // 公会战-设置开战前是否自动填补阵容 ConsortiaWarSetHallAutoFillRequest ConsortiaWarSetHallAutoFillResponse
-- CONSORTIA_WAR_GET_ALL_HALL_DEFENSE_INFO     = 6205;                     // 公会战-获取所有堂的防守信息 ConsortiaWarGetAllHallDefenseInfoRequest ConsortiaWarGetAllHallDefenseInfoResponse
-- CONSORTIA_WAR_SET_HALL_DEFENSE_INFO         = 6206;                     // 公会战-设置某一个堂的防守信息 ConsortiaWarSetHallDefenseInfoRequest ConsortiaWarSetHallDefenseInfoResponse
-- CONSORTIA_WAR_GET_MEMBER_LIST_FOR_DEFENSE   = 6207;                     // 公会战-获取公会成员列表用于设置堂的防守信息 ConsortiaWarGetMemberListForDefenseRequest ConsortiaWarGetMemberListForDefenseResponse
-- CONSORTIA_WAR_GET_GET_ONE_HALL_BATTLE_INFO  = 6208;                     // 公会战-获取一个堂的战斗信息 ConsortiaWarGetOneHallBattleInfoRequest ConsortiaWarGetOneHallBattleInfoResponse
-- CONSORTIA_WAR_PICK_UP_FLAG                  = 6209;                     // 公会战-摧毁散落在地的旗子 ConsortiaWarPickUpFlagRequest ConsortiaWarPickUpFlagReeponse
-- CONSORTIA_WAR_GET_BATTLE_LIST               = 6210;                     // 公会战-获取个人战报列表 ConsortiaWarGetBattleListRequest ConsortiaWarGetBattleListResponse
-- CONSORTIA_WAR_GET_BATTLE_EVENT_LIST         = 6211;                     // 公会战-获取公会战斗事件列表 ConsortiaWarGetBattleEventListRequest ConsortiaWarGetBattleEventListResponse
-- CONSORTIA_WAR_GET_DAILY_REWARD_LIST         = 6212;                     // 公会战-获取个人每日奖励列表 ConsortiaWarGetDailyRewardListRequest ConsortiaWarGetDailyRewardListResponse
-- CONSORTIA_WAR_GET_DAILY_REWARD              = 6213;                     // 公会战-领取个人每日奖励 ConsortiaWarGetDailyRewardRequest ConsortiaWarGetDailyRewardResponse

function QConsortiaWar:responseHandler(data, success, fail, succeeded)
	if data.consortiaWarGetMyInfoResponse then
		if data.consortiaWarGetMyInfoResponse.myInfo then
			self._myInfo = data.consortiaWarGetMyInfoResponse.myInfo
		end
		if data.consortiaWarGetMyInfoResponse.myConsortiaInfo then
			self._myConsortiaInfo = data.consortiaWarGetMyInfoResponse.myConsortiaInfo
		end
		if data.consortiaWarGetMyInfoResponse.currSeason then
			self._currSeason = data.consortiaWarGetMyInfoResponse.currSeason
		end
		if data.consortiaWarGetMyInfoResponse.battleArmy then
        	self:setConsortiaWarDefense(data.consortiaWarGetMyInfoResponse.battleArmy)
        end
	end
	if data.consortiaWarGetMainInfoResponse then
		if data.consortiaWarGetMainInfoResponse.mainStatus then
			self._mainStatus = data.consortiaWarGetMainInfoResponse.mainStatus
		end
		if data.consortiaWarGetMainInfoResponse.myInfo then
			self._myInfo = data.consortiaWarGetMainInfoResponse.myInfo
		end
		if data.consortiaWarGetMainInfoResponse.myConsortiaInfo then
			self._myConsortiaInfo = data.consortiaWarGetMainInfoResponse.myConsortiaInfo
			if data.consortiaWarGetMainInfoResponse.myConsortiaInfo.attackOrderList then
				self._attackOrderList = data.consortiaWarGetMainInfoResponse.myConsortiaInfo.attackOrderList
			end
		end

		if data.consortiaWarGetMainInfoResponse.battleArmy then
        	self:setConsortiaWarDefense(data.consortiaWarGetMainInfoResponse.battleArmy)
        end
        if data.consortiaWarGetMainInfoResponse.battleInfo then
			local battleInfo = data.consortiaWarGetMainInfoResponse.battleInfo
			self:updateBattleInfo(battleInfo)
		end
		if data.consortiaWarGetMainInfoResponse.hallInfoList then
			local hallInfoList = data.consortiaWarGetMainInfoResponse.hallInfoList
			for i, hallInfo in pairs(hallInfoList) do
				self:updateHallInfo(hallInfo)
			end
		end
		if data.consortiaWarGetMainInfoResponse.currSeason then
			self._currSeason = data.consortiaWarGetMainInfoResponse.currSeason
		end
	end

	if data.consortiaWarSetHallAutoFillResponse then
		if data.consortiaWarSetHallAutoFillResponse.myConsortiaInfo then
			self._myConsortiaInfo = data.consortiaWarSetHallAutoFillResponse.myConsortiaInfo
		end
	end

	if data.consortiaWarGetAllHallDefenseInfoResponse then
		if data.consortiaWarGetAllHallDefenseInfoResponse.hallInfoList then
			local hallInfoList = data.consortiaWarGetAllHallDefenseInfoResponse.hallInfoList
			for i, hallInfo in pairs(hallInfoList) do
				self:updateHallInfo(hallInfo)
			end
		end
	end
	if data.consortiaWarSetHallDefenseInfoResponse then
		if data.consortiaWarSetHallDefenseInfoResponse.hallInfoList then
			local hallInfoList = data.consortiaWarSetHallDefenseInfoResponse.hallInfoList
			for i, hallInfo in pairs(hallInfoList) do
				self:updateHallInfo(hallInfo)
			end
        	self:dispatchEvent({name = QConsortiaWar.EVENT_CONSORTIA_WAR_UPDATE_INFO})
		end
	end

	if data.consortiaWarGetMemberListForDefenseResponse then
		self._memberList = data.consortiaWarGetMemberListForDefenseResponse.memberList or {}
	end

	if data.consortiaWarPickUpFlagResponse then
		if data.consortiaWarPickUpFlagResponse.myInfo then
			self._myInfo = data.consortiaWarPickUpFlagResponse.myInfo
		end
		if data.consortiaWarPickUpFlagResponse.hallInfo then
			self:updateHallInfo(data.consortiaWarPickUpFlagResponse.hallInfo)
		end
	end
	if data.consortiaWarGetDailyRewardListResponse then
		self._rewardList = data.consortiaWarGetDailyRewardListResponse.rewardList or {}
		self._envRank = data.consortiaWarGetDailyRewardListResponse.envRank or 1
		self._allRank = data.consortiaWarGetDailyRewardListResponse.allRank or 2
	end

	--战斗结束
	if data.gfEndResponse and data.gfEndResponse.consortiaWarFightEndResponse then
    	remote.user:addPropNumForKey("todayConsortiaWarFightCount")--记录宗门战战斗
		if data.gfEndResponse.consortiaWarFightEndResponse.breakThroughFlagCount 
			and data.gfEndResponse.consortiaWarFightEndResponse.breakThroughFlagCount > 0 then
			remote.user:addPropNumForKey("todayConsortiaWarDestoryFlagCount")--记录宗门战夺旗次数
		end
    	if data.gfEndResponse.consortiaWarFightEndResponse.myInfo then
			self._myInfo = data.gfEndResponse.consortiaWarFightEndResponse.myInfo
		end
    end

    if data.consortiaWarAttackOrderResponse then
    	self._attackOrderList = data.consortiaWarAttackOrderResponse.attackOrderList
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
end

--进游戏拉取简单信息
function QConsortiaWar:consortiaWarGetMyInfoRequest(success, fail)
    local request = {api = "CONSORTIA_WAR_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end, nil, nil, false)
end

--拉取信息
function QConsortiaWar:consortiaWarGetMainInfoRequest(success, fail)
    local request = {api = "CONSORTIA_WAR_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--更新出战阵容 
function QConsortiaWar:consortiaWarSetDefenseArmyRequest(battleFormation1, battleFormation2, success, fail)
    local request = {api = "CONSORTIA_WAR_SET_DEFENSE_ARMY", battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler(request.api, request, function ()
    	local response = {}
    	response.consortiaWarGetMainInfoResponse = {}
    	response.consortiaWarGetMainInfoResponse.battleArmy = {
    		battleFormation = battleFormation1,
    		battleFormation2 = battleFormation2,
    	}
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--自动填满
function QConsortiaWar:consortiaWarSetHallAutoFillRequest(isHallAutoFill, success, fail)
	local consortiaWarSetHallAutoFillRequest = {isHallAutoFill = isHallAutoFill}
    local request = {api = "CONSORTIA_WAR_SET_HALL_AUTO_FILL", consortiaWarSetHallAutoFillRequest = consortiaWarSetHallAutoFillRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取堂防守阵容
function QConsortiaWar:consortiaWarGetAllHallDefenseInfoRequest(success, fail)
	local consortiaWarGetAllHallDefenseInfoRequest = {}
    local request = {api = "CONSORTIA_WAR_GET_ALL_HALL_DEFENSE_INFO", consortiaWarGetAllHallDefenseInfoRequest = consortiaWarGetAllHallDefenseInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--设置堂防守阵容
function QConsortiaWar:consortiaWarSetHallDefenseInfoRequest(defenseInfoList, success, fail)
	local consortiaWarSetHallDefenseInfoRequest = {defenseInfoList = defenseInfoList}
    local request = {api = "CONSORTIA_WAR_SET_HALL_DEFENSE_INFO", consortiaWarSetHallDefenseInfoRequest = consortiaWarSetHallDefenseInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取堂防守成员阵容
function QConsortiaWar:consortiaWarGetMemberListForDefenseRequest(success, fail)
	local consortiaWarGetMemberListForDefenseRequest = {}
    local request = {api = "CONSORTIA_WAR_GET_MEMBER_LIST_FOR_DEFENSE", consortiaWarGetMemberListForDefenseRequest = consortiaWarGetMemberListForDefenseRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取一个堂的战斗信息
function QConsortiaWar:consortiaWarGetOneHallBattleInfoRequest(hallId, isMyConsortia, success, fail)
	local consortiaWarGetOneHallBattleInfoRequest = {hallId = hallId, isMyConsortia = isMyConsortia}
    local request = {api = "CONSORTIA_WAR_GET_GET_ONE_HALL_BATTLE_INFO", consortiaWarGetOneHallBattleInfoRequest = consortiaWarGetOneHallBattleInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
		local hallInfo = response.consortiaWarGetOneHallBattleInfoResponse.hallInfo
		if hallInfo then
			self:updateHallBattleInfo(hallInfo, isMyConsortia)
			if isMyConsortia then
				self:updateHallInfo(hallInfo)
			end
		end
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--摧毁散落在地的旗子
function QConsortiaWar:consortiaWarPickUpFlagRequest(hallId, success, fail)
	local consortiaWarPickUpFlagRequest = {hallId = hallId}
    local request = {api = "CONSORTIA_WAR_PICK_UP_FLAG", consortiaWarPickUpFlagRequest = consortiaWarPickUpFlagRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	remote.user:addPropNumForKey("todayConsortiaWarDestoryFlagCount")--记录摧毁旗子次数
    	remote.user:addPropNumForKey("todayConsortiaWarFightCount")--记录宗门战战斗次数
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取个人战报列表
function QConsortiaWar:consortiaWarGetBattleListRequest(success, fail)
    local request = {api = "CONSORTIA_WAR_GET_BATTLE_LIST"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
       self:responseHandler(response, nil, fail)
    end)
end

--获取公会战斗事件列表
function QConsortiaWar:consortiaWarGetBattleEventListRequest(success, fail)
    local request = {api = "CONSORTIA_WAR_GET_BATTLE_EVENT_LIST"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
       self:responseHandler(response, nil, fail)
   end)
end

--获取个人每日奖励列表
function QConsortiaWar:consortiaWarGetDailyRewardListRequest(success, fail)
    local request = {api = "CONSORTIA_WAR_GET_DAILY_REWARD_LIST"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--领取个人每日奖励
function QConsortiaWar:consortiaWarGetDailyRewardRequest(rewardId, success, fail)
	local consortiaWarGetDailyRewardRequest = {rewardId = rewardId}
    local request = {api = "CONSORTIA_WAR_GET_DAILY_REWARD", consortiaWarGetDailyRewardRequest = consortiaWarGetDailyRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	local response = {}
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--获取的成员列表
function QConsortiaWar:consortiaWarGetMemberListForDefenseRequest(success, fail)
    local request = {api = "CONSORTIA_WAR_GET_MEMBER_LIST_FOR_DEFENSE"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--查询阵容
function QConsortiaWar:consortiaWarQueryFighterRequest(userId, success, fail, status)
    local request = {api = "CONSORTIA_WAR_QUERY_FIGHTER", consortiaWarQueryFighterRequest = {userId = userId}}
    app:getClient():requestPackageHandler("CONSORTIA_WAR_QUERY_FIGHTER", request, success, fail)
end

-- 战斗开始
function QConsortiaWar:consortiaWarFightStartRequest(hallId, enemyUserId, battleFormation1, battleFormation2, success, fail)
	local consortiaWarFightStartRequest = {hallId = hallId, enemyUserId = enemyUserId}
    local gfStartRequest = {battleType = BattleTypeEnum.CONSORTIA_WAR, battleFormation = battleFormation1, battleFormation2 = battleFormation2, consortiaWarFightStartRequest = consortiaWarFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

-- 战斗结束
function QConsortiaWar:consortiaWarFightEndRequest(hallId, enemyUserId, battleFormation1, battleFormation2, battleKey, success, fail)
    local consortiaWarFightEndRequest = {hallId = hallId, enemyUserId = enemyUserId}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.CONSORTIA_WAR, battleVerify = battleVerify, fightReportData = fightReportData, consortiaWarFightEndRequest = consortiaWarFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--宗门战集火设置
function QConsortiaWar:consortiaWarSetAttackOrderRequest(attackOrderList, success, fail, status)
	local consortiaWarSetAttackOrderRequest = {orderList = attackOrderList}
    local request = {api = "CONSORTIA_WAR_SET_ATTACK_ORDER", consortiaWarSetAttackOrderRequest = consortiaWarSetAttackOrderRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
    	self:responseHandler(response, success, fail, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QConsortiaWar
