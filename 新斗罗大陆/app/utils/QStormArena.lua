local QBaseModel = import("..models.QBaseModel")
local QStormArena = class("QStormArena",QBaseModel)
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIViewController = import("..ui.QUIViewController")

QStormArena.STORM_ARENA_REDTIPS_CHANGE = "STORM_ARENA_REDTIPS_CHANGE"
QStormArena.STORM_ARENA_REFRESH= "STORM_ARENA_REFRESH"
QStormArena.STORM_ARENA_AVATAR_REFRESH= "STORM_ARENA_AVATAR_REFRESH"

QStormArena.STORM_ARENA_RECORD_REFRESH= "STORM_ARENA_RECORD_REFRESH"

function QStormArena:ctor(options)
	QStormArena.super.ctor(self)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
   	
end

--创建时初始化事件
function QStormArena:didappear()
   	self._stormArenaMyInfo = {}
   	self._oldstormArenaMyInfo = {}
    self._stormArenaRivals = {}
    self._stormArenaWorshipFighter = {}
    self._stormArenaFightCount = 0  --剩余挑战次数
    self._stormArenaCanFight = false
    self._stormArenaFreeFightCount = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_FREE_FIGHT_COUNT") or 0
    self._stormArenaCDTime = QStaticDatabase:sharedDatabase():getConfigurationValue("STORM_ARENA_CD") or 0
    self._stormArenaTodayWorshipInfo = {}   
    self._stormArenaRefreshTimes = 0
    self._seasonStartAt = 0

    self.isAllServersHistory = true -- 是否展示全服王者
    self.seasonNO = 0 -- 当前赛季
    self._seasonInfo = {} -- 赛季信息
end

function QStormArena:disappear()
	
end

function QStormArena:loginEnd()
	-- body
    if app.unlock:getUnlockStormArena() then
        self:requestStormSimpleInfo()
    end
end

function QStormArena:openDialog()
    if app.unlock:getUnlockStormArena(true) then
        remote.stormArena:requestStormArenaInfo(nil, function(data)
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogStormArena"})
        end)
    end
end

function QStormArena:setStormArenaRecordTip(stated, isDispatchEvent)
    self._stormArenaRecordTip = stated

    if isDispatchEvent then
        self:dispatchEvent({name = QStormArena.STORM_ARENA_RECORD_REFRESH})
    end
end

function QStormArena:getStormArenaRecordTip()
    return self._stormArenaRecordTip
end

function QStormArena:getStormInfoByLogin( success, fail)
    -- body
    if app.unlock:getUnlockStormArena() then
        self:requestgetStormArenaDefendTeam(function (data)
            if success then
                success()
            end
        end, fail)
    else
        if success then
            success()
        end
    end
end

-- 获取距离当前赛季结束点时间戳
function QStormArena:getSeasonEndTimeAt( startTimeAt )
    local seasonStartAt = startTimeAt or self._seasonStartAt
    if not seasonStartAt or seasonStartAt == 0 then
        return 0
    end

    local seasonLeftSec = 0
    local startTimeTbl = q.date("*t", seasonStartAt / 1000)
    if startTimeTbl.wday == 2 and startTimeTbl.hour == 5 and startTimeTbl.min == 0 and startTimeTbl.sec == 0 then
        -- 周一／5:00 , 正常赛季开始时间
        seasonLeftSec = 13 * DAY + 16 * HOUR
    else
        local seasonUseDay = 7 - (startTimeTbl.wday - 1) + 7 -- 首周减去开始的日子加上下周一整个周期
        local firstDayUseHour = 21 - startTimeTbl.hour -- 赛季首日开始的时间到当天21点的小时数
        seasonLeftSec = seasonUseDay * DAY + 1 * firstDayUseHour * HOUR
    end
    local endTimeAt = seasonStartAt / 1000 + seasonLeftSec

    return endTimeAt
end

-- 获取距离当前结算结束点时间戳
function QStormArena:getReadyEndTimeAt()
    if not self._seasonStartAt or self._seasonStartAt == 0 then
        return 0
    end
    local seasonReadySec = 0
    local seasonEndTimeAt = self:getSeasonEndTimeAt()
    if not seasonEndTimeAt or seasonEndTimeAt == 0 then
        return 0
    end
    local curTimeAt = q.serverTime() 
    if curTimeAt >= seasonEndTimeAt or curTimeAt < self._seasonStartAt / 1000 then
        -- 结算阶段
        -- 由于seasonStartAt在结算阶段的某个环节更新（后端也不清楚具体的时间点），所以，可能在结算阶段的时候，seasonStartAt更新为下一赛季的开启时间（周一5:00）。
        seasonReadySec = ((24 + 5) - 21) * HOUR
    else
        -- 赛季阶段
        return 0
    end

    local endTimeAt = seasonEndTimeAt + seasonReadySec
    if curTimeAt < self._seasonStartAt / 1000 then
        endTimeAt = self._seasonStartAt / 1000
    end
    local endTimeTbl = q.date("*t", endTimeAt)

    return endTimeAt
end

-- 返回倒计时
function QStormArena:updateTime()
    local timeStr = "00：00：00" -- 倒计时的字符串
    if not self._seasonStartAt or self._seasonStartAt == 0 then
        return nil, timeStr, nil
    end
    local isInSeason = false -- 是否处于赛季阶段
    local endTime = self:getReadyEndTimeAt()
    if not endTime or endTime == 0 then
        -- 处于赛季结算，未到结算阶段
        isInSeason = true
        endTime = self:getSeasonEndTimeAt()
    end
    
    local color = ccc3(255, 255, 255)

    if q.serverTime() < endTime then
        local sec = endTime - q.serverTime()
        if sec < 30*MIN then
            color = ccc3(255, 63, 0) -- 红色
        end
        timeStr = q.timeToDayHourMinute(sec)
    end

    return isInSeason, timeStr, color
end

-- 将秒为单位的数字转换成 00 天 00：00：00格式
function QStormArena:formatSecTime( sec )
    local d = math.floor(sec/DAY)
    local h = math.floor((sec/HOUR)%24)
    local m = math.floor((sec/MIN)%MIN)
    local s = math.floor(sec%MIN)

    return d, h, m, s
end

-- 将秒为单位的数字转换成 2016.7.4格式
function QStormArena:formatDate( sec )
    local timeTbl = q.date("*t", sec)
    return string.format("%d.%02d.%02d", timeTbl.year, timeTbl.month, timeTbl.day)
end

--风暴斗魂场 积分
function QStormArena:getStormArenaScore(  )
	-- body
	local score = self._stormArenaMyInfo.arenaRewardIntegral or 0
    return score
end

-- 每日积分奖励是否领取
function QStormArena:dailyStormArenaScoreIsGet( rewardId )
	-- body
  	if self._stormArenaMyInfo.arenaRewardInfo then
        for _,id in ipairs(self._stormArenaMyInfo.arenaRewardInfo) do
            if id == rewardId then
                return true
            end
        end
    end
    return false
end

function QStormArena:stormArenaTodayWorshipByPos( pos )
    -- body
    return self._stormArenaTodayWorshipInfo[pos]
end


function QStormArena:getStormMoneyByRivals( pos, rank )
    -- body
    if pos == nil then return end
    rank = math.min(rank, self._stormArenaMyInfo.rank)
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
   
    if config["STORM_ARENA_NPC_"..pos] ~= nil then
      
        local rate = config["STORM_ARENA_NPC_"..pos].value
        local rankItemInfo = QStaticDatabase:sharedDatabase():getAreanRewardConfigByRank(rank, remote.user.level)
        local stormMoney = math.floor(rankItemInfo.storm_arena_victory * rate)
        print("  stormMoney ", stormMoney, rankItemInfo.storm_arena_victory)
        stormMoney = math.floor(stormMoney + 1 * ((math.floor((remote.user.level - 10) / 20)) * 5 + 30))
        return math.floor(stormMoney * 2)
    end
    return 0
end

function QStormArena:setTopRankUpdate( result, rivalId )
    -- body
    self.stormArenaFightWinResult = clone(result)
    self.stormArenaRivalId = rivalId
end


function QStormArena:getTopRankUpdate()
    return self.stormArenaFightWinResult, self.stormArenaRivalId
end

function QStormArena:updateStormArenaBuyCount(  )
    self:stormArenaRefresh({
            stormResponse = {
                mySelf = {
                    fightBuyCount = self._stormArenaMyInfo.fightBuyCount + 1
                }
            }
        })
end

function QStormArena:updateStormDefendTeam( data )
    local battleFormation1 = data.defenseFormation1 or {}
    if q.isEmpty(battleFormation1) then
        battleFormation1 = remote.teamManager:getDefaultTeam(remote.teamManager.STORM_ARENA_DEFEND_TEAM1)
    end
    if q.isEmpty(battleFormation1) == false then
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM1, false)
        teamVO:setTeamDataWithBattleFormation(battleFormation1)
    end   

    local battleFormation2 = data.defenseFormation2 or {}
    if q.isEmpty(battleFormation2) then
        battleFormation2 = remote.teamManager:getDefaultTeam(remote.teamManager.STORM_ARENA_DEFEND_TEAM2)
    end
    if q.isEmpty(battleFormation2) == false then
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM2, false)
        teamVO:setTeamDataWithBattleFormation(battleFormation2)
    end
end

function QStormArena:setStormArenaTodayWorshipInfo( worshipStr )
	-- body
    if worshipStr ~= nil then
        local pos = string.split(worshipStr, ";")
        for _,value in ipairs(pos) do
            if value ~= "" then
                self._stormArenaTodayWorshipInfo[tonumber(value)+1] = true
            end
        end
    end
end

function QStormArena:checkCanFight()
    local isInSeason = self:updateTime()
    if not isInSeason then
        return false
    end

    local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
    if nowDateTable.hour == 21 and nowDateTable.min < 16 then
        return false
    end
    
    if self._stormArenaCanFight then
        return true
    end

    return false
end

-- 红点检查机制

---积分奖励 红点
function QStormArena:checkStormArenaScoreAwardRedtips( )
    -- body
    local configs = QStaticDatabase:sharedDatabase():getStormArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    local curScore = self._stormArenaMyInfo.arenaRewardIntegral or 0
    for k ,v in pairs(configs) do
        local isGet = self:dailyStormArenaScoreIsGet(v.ID)
        if not isGet and curScore >= v.condition then
            return true
        end
    end
    return false

end

function QStormArena:checkStormArenaRecordRedTips(  )
    -- body
    return false
end

--商店红点
function QStormArena:checkStormArenaShopRedTips(  )
    -- body
    if remote.stores:checkFuncShopRedTips(SHOP_ID.artifactShop) then
        return true
    end
    return false
end

function QStormArena:checkStormArenaRedTips()
    --积分奖励没有领取
    if self:checkStormArenaScoreAwardRedtips() then
        return true
    end

    if self:checkStormArenaShopRedTips( ) then
         return true
    end
    
    if self:getStormArenaRecordTip() then
        return true
    end

    return false
end

function QStormArena:checkTeamIsFull()
    local team1Main = remote.teamManager:checkTeamIsFull(remote.teamManager.STORM_ARENA_DEFEND_TEAM1, 1)
    local team1Help = remote.teamManager:checkTeamIsFull(remote.teamManager.STORM_ARENA_DEFEND_TEAM1, 2)
    local team2Main = remote.teamManager:checkTeamIsFull(remote.teamManager.STORM_ARENA_DEFEND_TEAM2, 1)
    local team2Help = remote.teamManager:checkTeamIsFull(remote.teamManager.STORM_ARENA_DEFEND_TEAM2, 2)

    if team1Main and team1Help and team2Main and team2Help then
        return true
    end

    return false
end

function QStormArena:changeStormArenaMyTeamInfo(isNeedDispatch, battleFormation1, battleFormation2)
    if battleFormation1 and battleFormation2 then
        local data = {defenseFormation1 = battleFormation1, defenseFormation2 = battleFormation2}
        self:updateStormDefendTeam(data)
    end

    local teamV1 = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM1)
    local teamV2 = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM2)
    local team1Main = teamV1:getTeamActorsByIndex(1)
    local team1Help = teamV1:getTeamActorsByIndex(2)
    local team1Skill = teamV1:getTeamSkillByIndex(2)
    local team2Main = teamV2:getTeamActorsByIndex(1)
    local team2Help = teamV2:getTeamActorsByIndex(2)
    local team2Skill = teamV2:getTeamSkillByIndex(2)
    
    self._stormArenaMyInfo.heros = {}
    self._stormArenaMyInfo.subheros = {}
    self._stormArenaMyInfo.main1Heros = {}
    self._stormArenaMyInfo.sub1heros = {}

    local insertFunc = function (srcHeros, destHeros)
        if srcHeros ~= nil then
            for _,actorId in pairs(srcHeros) do
                table.insert(destHeros, remote.herosUtil:getHeroByID(actorId))
            end
        end
    end
        
    insertFunc(team1Main, self._stormArenaMyInfo.heros)
    insertFunc(team1Help, self._stormArenaMyInfo.subheros)
    insertFunc(team2Main, self._stormArenaMyInfo.main1Heros)
    insertFunc(team2Help, self._stormArenaMyInfo.sub1heros)
    
    self._stormArenaMyInfo.activeSubActorId = team1Skill[1]
    self._stormArenaMyInfo.active1SubActorId = team1Skill[2]
    self._stormArenaMyInfo.activeSub2ActorId = team2Skill[1]
    self._stormArenaMyInfo.active1Sub2ActorId = team2Skill[2]

    local team1Force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.STORM_ARENA_DEFEND_TEAM1)
    local team2Force = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.STORM_ARENA_DEFEND_TEAM2)
    self._stormArenaMyInfo.force = team1Force + team2Force

    self:updateStormArenaSelfInWorship()

    if remote.selectServerInfo then
        self._stormArenaMyInfo.game_area_name = remote.selectServerInfo.name
    end
    if not self._stormArenaMyInfo.game_area_name then
        self._stormArenaMyInfo.game_area_name = ""
    end

    if isNeedDispatch then
    	self:dispatchEvent({name = QStormArena.STORM_ARENA_REFRESH, isNotRefreshAvatar = true})
    end
end


--[[
    检查自己是不是在膜拜阵容里面
]]
function QStormArena:updateStormArenaSelfInWorship()
    if self._stormArenaWorshipFighter ~= nil and self._stormArenaWorshipFighter.fighter ~= nil then
        for _,fighter in ipairs(self._stormArenaWorshipFighter.fighter) do
            if fighter.userId == self._stormArenaMyInfo.userId then
                fighter.heros = self._stormArenaMyInfo.heros
                fighter.subheros = self._stormArenaMyInfo.subheros
                fighter.force = self._stormArenaMyInfo.force
                fighter.main1Heros = self._stormArenaMyInfo.main1Heros
                fighter.sub1heros = self._stormArenaMyInfo.sub1heros
            end
        end

        table.sort(self._stormArenaWorshipFighter.fighter, function (a,b)
            if a.rank ~= b.rank then
                return a.rank < b.rank
            end
            return a.userId > b.userId
        end)
    end
end

function QStormArena:updateStormArenaSelfInfo( data)
	-- body
	   --设置 膜拜信息
    local selfInfoChange = false
    if data.todayWorshipPos then
        self:setStormArenaTodayWorshipInfo(data.todayWorshipPos)
    end

    if data.arenaRewardInfo and #data.arenaRewardInfo ~= #(self._stormArenaMyInfo.arenaRewardInfo or {}) then
        selfInfoChange = true 
    end

    if data.arenaRewardIntegral and data.arenaRewardIntegral ~= (self._stormArenaMyInfo.arenaRewardIntegral or 0)  then
        selfInfoChange = true
    end

    if data.topRank and data.topRank ~= (remote.user.stormTopRank or 999999) then
        remote.user:update({stormTopRank = data.topRank})
        selfInfoChange = true
    end

    for key,value in pairs(data) do
        self._stormArenaMyInfo[key] = value
    end

    local teamV1 = remote.teamManager:getTeamByKey(remote.teamManager.STORM_ARENA_DEFEND_TEAM1)
    local team1Main = teamV1:getTeamActorsByIndex(1)
    if q.isEmpty(team1Main) then
        self:requestgetStormArenaDefendTeam(function (data)
            self:changeStormArenaMyTeamInfo(true)
        end)
    else
        self:changeStormArenaMyTeamInfo()
    end

    --更新斗魂场可攻打次数
    local stormArenaCanFight = false
    local totalCount = self._stormArenaFreeFightCount + self._stormArenaMyInfo.fightBuyCount
    self._stormArenaFightCount =  totalCount - self._stormArenaMyInfo.fightCount
    if self._stormArenaFightCount > 0 then
        local canFightTime = (self._stormArenaMyInfo.lastFrozenTime or 0)/1000 + self._stormArenaCDTime
        local passTime = canFightTime - q.serverTime()
        if passTime > 0  then
            stormArenaCanFight = false
            app:getAlarmClock():createNewAlarmClock("StormArenaCanFight", canFightTime, function (  )
                -- body
               self._stormArenaCanFight = true
               self:dispatchEvent({name = QStormArena.STORM_ARENA_REDTIPS_CHANGE})
            end)
        else
            stormArenaCanFight = true
        end
    end

    if stormArenaCanFight ~= self._stormArenaCanFight then
        selfInfoChange = true
        self._stormArenaCanFight = stormArenaCanFight
    end

    if selfInfoChange then
        self:dispatchEvent({name = QStormArena.STORM_ARENA_REDTIPS_CHANGE})
    end
end

function QStormArena:updateStormArenaRivalsInfo( rivals )
    -- body
    self._stormArenaRivals = {}
    for _, value in pairs(rivals) do
        self._stormArenaRivals[#self._stormArenaRivals+1] = value
    end
    
    table.sort(self._stormArenaRivals, function (a,b)
            if a.rank ~= b.rank then
                return a.rank < b.rank
            end
            return a.userId > b.userId
        end)

end

function QStormArena:setSeasonInfo( data )
    if not data or #data == 0 then
        return
    end

    self._seasonInfo = {}
    for _, value in pairs( data ) do
        table.insert(self._seasonInfo, value)
    end

    table.sort(self._seasonInfo, function(a, b)
            return a.seasonNo < b.seasonNo
        end)
end

function QStormArena:getSeasonInfoBySeasonNO( seasonNO )
    for _, value in pairs( self._seasonInfo ) do
        if tonumber(value.seasonNo) == tonumber(seasonNO) then
            return value
        end
    end
end

function QStormArena:refreshDailyInfo()
    self._stormArenaMyInfo.arenaRewardInfo = nil
    self._stormArenaMyInfo.arenaRewardIntegral = 0 
    self._stormArenaMyInfo.fightBuyCount = 0
    self._stormArenaMyInfo.fightCount = 0
    self._stormArenaRefreshTimes = 0
    self._stormArenaTodayWorshipInfo = {}
end

----------------------------- server info ----------------------------------

--[[
    optional Fighter
--]]
function QStormArena:getStormArenaInfo()
    return self._stormArenaMyInfo or {}
end

--[[
    optional int32 refreshTimes
--]]
function QStormArena:getStormArenaRefreshTime()
    return self._stormArenaRefreshTimes or 0
end

--[[
    {
        optional Fighter
    }
--]]
function QStormArena:getStormArenaRivalsInfo()
    return self._stormArenaRivals or 0
end

--[[
    {
        optional Fighter
    }
--]]
function QStormArena:getStormArenaWorshipInfo()
    return self._stormArenaWorshipFighter or 0
end

function QStormArena:getStormArenaWorship()
    local worships = {}
    if self._stormArenaWorshipFighter ~= nil and self._stormArenaWorshipFighter.fighter ~= nil then
        for i, fighter in ipairs(self._stormArenaWorshipFighter.fighter) do
            local worship = {}
            worship.userId = fighter.userId
            worship.pos = i
            table.insert(worships, worship)
        end
    end
    return worships
end

function QStormArena:setStormArenaWorshipInfoFighter(fighter)
    if self._stormArenaWorshipFighter then
        self._stormArenaWorshipFighter.fighter = fighter
        self:updateStormArenaSelfInWorship()
    end
end

function QStormArena:getSeasonInfo()
    return self._seasonInfo
end

----------------------------- request handler ------------------------------

function QStormArena:stormArenaRefresh( data , isNotNeedDispatch )
	-- body

	local stormData = data.stormResponse
    if stormData == nil then
        return
    end
    -- 
    local isNotRefreshAvatar = true
    if stormData.mySelf then
        self:updateStormArenaSelfInfo(stormData.mySelf)
      
    end
    --膜拜玩家信息
    if stormData.worshipFighter ~= nil then
        self._stormArenaWorshipFighter = stormData.worshipFighter
        self:updateStormArenaSelfInWorship()
        isNotRefreshAvatar = false
    end

    if stormData.rivals ~= nil  then
        self:updateStormArenaRivalsInfo(stormData.rivals)
        isNotRefreshAvatar = false
    end

    if stormData.refreshTimes ~= nil then
        self._stormArenaRefreshTimes = stormData.refreshTimes
    end

    if stormData.seasonStartAt ~= nil then
        self._seasonStartAt = stormData.seasonStartAt
    end

    if not isNotNeedDispatch then
        self:dispatchEvent({name = QStormArena.STORM_ARENA_REFRESH, isNotRefreshAvatar = isNotRefreshAvatar})
    end

end

function QStormArena:requestStormSimpleInfo( success, fail )
	-- body
	local request = {api = "STORM_GET_INFO"}
    local successCallback = function (data)
        self:stormArenaRefresh(data)
        if success then
            success()
        end
    end
    app:getClient():requestPackageHandler("STORM_GET_INFO", request, successCallback, fail)
end

function QStormArena:requestStormArenaInfo(isManualRefresh, callBack)
    if isManualRefresh == nil then isManualRefresh = false end
    
    local stormRefreshRequest = {isManualRefresh = isManualRefresh}
    local request = {api = "STORM_REFRESH", stormRefreshRequest = stormRefreshRequest}
    app:getClient():requestPackageHandler("STORM_REFRESH", request, function ( data )
        -- body
        self:stormArenaRefresh(data)
        if callBack then
            callBack()
        end
    end, fail)
end

function QStormArena:requestStormArenaFightStartRequest(battleType, rivalUserId, battleFormation1, battleFormation2, success,fail)
    -- local arenaFightStartRequest = {rivalUserId = rivalUserId}
    local gfStartRequest = {battleType = battleType, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

--战斗结算
function QStormArena:requestStormArenaFightEndRequest(rivalUserId, battleFormation1, battleFormation2, pos, fightResult, verifyDamages, battleKey, success, fail)
    local stormFightEndRequest = {rivalUserId = rivalUserId, pos = pos, fightResult = fightResult, damage = {damages = verifyDamages}}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.STORM, battleVerify = battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData, stormFightEndRequest = stormFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, success, fail)
end


function QStormArena:requestStormArenaBuyFightTimes(success )
    -- body
    local request = {api = "STORM_BUY_FIGHT_COUNT"}
    app:getClient():requestPackageHandler("STORM_BUY_FIGHT_COUNT", request, success, fail)
end

function QStormArena:requestStormArenaCleanFightCD(success )
    -- body
    local request = {api = "STORM_CLEAR_FROZEN_TIME"}
    app:getClient():requestPackageHandler("STORM_CLEAR_FROZEN_TIME", request, success, fail)
end


function QStormArena:requestStormArenaWorship( userId, pos ,success, fail)
    -- body
    local stormWorshipRequest = {userId = userId, pos = pos}
    local request = {api = "STORM_WORSHIP", stormWorshipRequest = stormWorshipRequest}
    app:getClient():requestPackageHandler("STORM_WORSHIP", request, success, fail)
end

--请求领取每日积分奖励
function QStormArena:requestStormArenaIntegralReward(box_ids, success, fail)
    local request = {api = "STORM_INTEGRAL_REWARD", stormIntegralRewardRequest = {box_ids = box_ids}}
    app:getClient():requestPackageHandler("STORM_INTEGRAL_REWARD", request, success, fail)
end


function QStormArena:requestStormArenaQuickFight( rivalUserId,pos, success, fail )
    local stormQuickFightRequest = {rivalUserId = rivalUserId, pos = pos,isSecretary = false,buyFiveCount = false}
    local gfQuickRequest = {battleType = BattleTypeEnum.STORM, stormQuickFightRequest = stormQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, success, fail, false)
end


function QStormArena:requestReceiveRewards( success )
	-- body
	local request = {api = "STORM_RECEIVE_REWARD"}
    app:getClient():requestPackageHandler("STORM_RECEIVE_REWARD", request, success, fail, false)
end


function QStormArena:requestgetStormArenaDefendTeam( success, fail, isNeedShowError )
    -- body
    local request = {api = "STORM_GET_CENTER_DEFENSE_ARMY"}
    local successCallback = function (data)
        print("索托防守阵容信息")
        QPrintTable(data.stormDefenseArmyResponse)
        self:updateStormDefendTeam(data.stormDefenseArmyResponse or {})
        if success then
        	success()
        end
    end
    app:getClient():requestPackageHandler("STORM_GET_CENTER_DEFENSE_ARMY", request, successCallback, fail, nil, nil, isNeedShowError)
end

function QStormArena:requestChangeStormDefendTeam(battleFormation1, battleFormation2, success, fail, status)
    local request = {api = "STORM_CHANGE_DEFENSE_HEROS", battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    local successCallback = function (response)
        self:changeStormArenaMyTeamInfo(true, battleFormation1, battleFormation2)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.STORM_ARENA_SET_DEFENCE_EVENT, 1)
        if success then
        	success()
        end
    end
    app:getClient():requestPackageHandler("STORM_CHANGE_DEFENSE_HEROS", request, successCallback, fail)
end

function QStormArena:requestStormReceiveReward( success, fail )
    -- body
    local request = {api = "STORM_RECEIVE_REWARD"}
    local successCallback = function (data)
        self:stormArenaRefresh(data)
        if success then
            success(data)
        end
    end
    app:getClient():requestPackageHandler("STORM_RECEIVE_REWARD", request, successCallback, fail)
end

--[[
/**
 * 风暴斗魂场用户查询
 */
 --]]
function QStormArena:stormArenaQueryDefenseHerosRequest(user_Id, success, fail, status)
    local request = {api = "STORM_QUERY_FIGHTER", stormQueryFighterRequest = {userId = user_Id}}
    app:getClient():requestPackageHandler("STORM_QUERY_FIGHTER", request, success, fail)
end


function QStormArena:requestStormArenaAgainstRecord(success, fail, status)
    local request = {api = "STORM_QUERY_HISTORY"}
    app:getClient():requestPackageHandler("STORM_QUERY_HISTORY", request, success, fail)
end

--[[
/**
 * 查询风暴斗魂场排名变化
 */
 --]]
function QStormArena:stormFightStartCheckRequest(selfUserId, selfPos, rivalUserId, rivalPos, success, fail, status)
    local stormFightStartCheckRequest = {selfUserId = selfUserId, selfPos = selfPos, rivalUserId = rivalUserId, rivalPos = rivalPos}
    local gfStartCheckRequest = {battleType = BattleTypeEnum.STORM,stormFightStartCheckRequest = stormFightStartCheckRequest}
    local request = {api = "GLOBAL_FIGHT_START_CHECK", gfStartCheckRequest = gfStartCheckRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START_CHECK", request, success, fail)
end

--[[
/**
 * 风暴斗魂场－获取赛季王者信息
 */
    optional int32 seasonNo = 1;                                                // 赛季号 填0获取默认上赛季的王者信息
    optional bool  isAllServers = 2;                                            // 是否全服
 --]]
function QStormArena:stormGetGloryWallInfoRequest(seasonNo, isAllServers, success, fail, status)
    local stormGetGloryWallInfoRequest = {seasonNo = seasonNo, isAllServers = isAllServers}
    local request = {api = "STORM_GET_GLORY_WALL_INFO", stormGetGloryWallInfoRequest = stormGetGloryWallInfoRequest}
    app:getClient():requestPackageHandler("STORM_GET_GLORY_WALL_INFO", request, success, fail)
end

--[[
/**
 * 获取赛季列表
 */
 --]]
function QStormArena:stormGetSeasonInfoRequest(success, fail, status)
    local request = {api = "STORM_GET_SEASON_INFO"}
    app:getClient():requestPackageHandler("STORM_GET_SEASON_INFO", request, success, fail)
end

return QStormArena