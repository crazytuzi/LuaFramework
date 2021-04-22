--
--  zxs
--  搏击俱乐部消息管理
--
local QBaseModel = import("...models.QBaseModel")
local QFightClub = class("QFightClub",QBaseModel)

local QUIViewController = import("...ui.QUIViewController")

QFightClub.FIGHT_CLUB_REDTIPS_CHANGE = "FIGHT_CLUB_REDTIPS_CHANGE"
QFightClub.FIGHT_CLUB_REFRESH = "FIGHT_CLUB_REFRESH"
QFightClub.FIGHT_CLUB_RESET = "FIGHT_CLUB_RESET"
QFightClub.FIGHT_CLUB_AWARD_UPDATE = "FIGHT_CLUB_AWARD_UPDATE"
QFightClub.FIGHT_CLUB_QUICK_ERROR = "FIGHT_CLUB_QUICK_ERROR"

QFightClub.STATE_DOWN = 1
QFightClub.STATE_KEEP = 2
QFightClub.STATE_UP = 3

QFightClub.QUICK_FIGHT = "QUICK_FIGHT"
QFightClub.FAST_FIGHT = "FAST_FIGHT"


function QFightClub:ctor(options)
	QFightClub.super.ctor(self)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

--创建时初始化事件
function QFightClub:didappear()
    self._fightClubMainLastInfo = {}    -- 战斗前主要信息
    self._fightClubMyLastInfo = {}      -- 战斗前我的信息
    self._fightClubMyInfo = {}          -- 我的信息
    self._fightClubRivalFighter = {}    -- 对手信息 
    self._isInBattle = false            -- 是否在战斗
    self._fightClubRewards = nil        -- 奖励
    self._floor = 0                     -- 段位
    self._winCountTips = false          -- 战报红点
    self._showPlunderTips = false       -- 可掠夺红点
    self._battleArmyList = {}           --对手阵容集合
    self._fightEndInfo = {}             --快速战斗结束信息
    self:resetData()
end

function QFightClub:disappear()
	
end

function QFightClub:resetData(delete_fast)
    self._fightClubMainInfo = {}        -- 当前赛季主要信息
    self._fightClubRivalFailList = {}   -- 已击败对手列表
    if not delete_fast then
        self._fightClubQuickFightInfo = nil -- 快速挑战信息
    end
    self._quickFightAwardStr = nil      -- 快速挑战奖励
    self._seasonReward = nil            -- 赛季奖励
    self._battleArmyList = {}           --对手阵容集合
    self._fightEndInfo = {}             --快速战斗结束信息

end

function QFightClub:loginEnd()
    -- 登录时获取一些简单信息
    if app.unlock:getUnlockFightClub() then   
        self:requestFightClubSimpleInfo()
        self:requestFightClubInfo(false,nil, nil, false)
    end
end

function QFightClub:openDialog()
    if not app.unlock:getUnlockFightClub(true) then
        return
    end
    if not self:checkCanFight() then
        local errorCode = db:getErrorCode("FIGHT_CLUB_CLOSED")
        app.tip:floatTip(errorCode.desc)
        return
    end
    self:requestFightClubInfo(true,function(data)
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogFightClub"})
    end)
end

-- 获取距离当前赛季结束点时间戳  每个赛季两周
function QFightClub:getSeasonEndTimeAt( )
    local endTimeAt = self._seasonStartAt / 1000
    if q.serverTime() > endTimeAt then
        endTimeAt = endTimeAt + DAY*7-3*HOUR
    end
    return endTimeAt
end

-- 是否当前赛季已结束
function QFightClub:getIsSeasonEnd()
    if self._seasonStartAt then
        local endTime = self:getSeasonEndTimeAt()
        if endTime < q.serverTime() then
            return true
        end
    end
    return false
end

-- 返回倒计时
function QFightClub:updateTime()
    local timeStr = "00：00：00" -- 倒计时的字符串
    if not self._seasonStartAt or self._seasonStartAt == 0 then
        return nil, timeStr, nil
    end
    local isInSeason = true -- 是否处于赛季阶段
    local endTime = self:getSeasonEndTimeAt()
    local color = GAME_COLOR_SHADOW.stress
    if q.serverTime() < endTime then
        local sec = endTime - q.serverTime()
        if sec >= 30*60 then
            color = GAME_COLOR_SHADOW.stress
        else
            color = GAME_COLOR_SHADOW.warning
        end

        timeStr = q.timeToDayHourMinute( sec )
    end

    return isInSeason, timeStr, color
end

--更新本地防守阵容
function QFightClub:updateFightClubDefenseTeam( data )
    -- body
    local battleFormation = data.battleFormation or {}
    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
    if not battleFormation.mainHeroIds then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
        battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:requestModifyFightClubDefenseTeam(battleFormation)
    end   
    teamVO:setTeamDataWithBattleFormation(battleFormation) 
end

--设置本地默认防守阵容
function QFightClub:checkFightClubDefenseTeam()
    -- body
    local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
    if q.isEmpty(actorIds) then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
        local battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:requestModifyFightClubDefenseTeam(battleFormation)

        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
        teamVO:setTeamDataWithBattleFormation(battleFormation) 
    end   
end

--检查防守阵容是否发生变化需要更新信息
function QFightClub:checkDefenseUpdate()
    local teamForce = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
    self.myInfo = remote.fightClub:getMyInfo()
    if self.myInfo.force and teamForce ~=  self.myInfo.force then
        local callback = function()
            remote.fightClub:requestFightClubInfo()
        end
        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.FIGHT_CLUB_DEFEND_TEAM)
        local heroIdList = teamVO:getAllTeam()
        local battleFormation = remote.teamManager:encodeBattleFormation(heroIdList)
        self:requestModifyFightClubDefenseTeam(battleFormation, callback )
    end
end

function QFightClub:checkCanFight()
    local nowTime = q.serverTime() 
    local nowDateTable = q.date("*t", nowTime)
    if nowDateTable.hour == 21 and nowDateTable.min <= 15 then
        return false
    end
    return true
end

--设置是否从战斗中出来
function QFightClub:setInBattle(b)
    self._isInBattle = b
end

--查询是否从战斗中出来
function QFightClub:getInBattle()
    return self._isInBattle
end

-- 晋级
function QFightClub:checkFightClubRiseRedTips()
    local winCount = self._fightClubMyInfo.fightClubWinCount or 0
    local riseCount = db:getConfiguration()["FIGHT_CLUB_NUM"].value or 9
    if winCount >= riseCount then
        return true
    end

    return false
end

-- 快速挑战
function QFightClub:checkFightClubQuickRedTips()
    local maxRank = self:getFightClubMaxRank()
    if self._fightClubMainInfo.floor >= maxRank then
        local cdTime = remote.fightClub:getQuickFightTimeLimit() or 0
        if cdTime <= 0 then
            return true
        end
    end
    return false
end

function QFightClub:checkFightClubRedTips()
    -- 奖励
    if self:getAwardInfo() then
        return true
    end
    if self:getWinCountTips() then
        return true
    end

    -- if self:checkFightClubRiseRedTips() then
    --     return true
    -- end

    -- if self:checkFightClubQuickRedTips() then
    --     return true
    -- end

    return false
end

--快速挑战
function QFightClub:getQuickFightTimeLimit()
    if self._lastQuickFightAt then
        local lastTimeAt = self._lastQuickFightAt / 1000
        local nextStartTime = lastTimeAt + 30*60
        if q.serverTime() < nextStartTime then
            local sec = nextStartTime - q.serverTime()
            return sec
        end
    end
end

function QFightClub:getSeasonReward()
    return self._seasonReward
end

function QFightClub:setFloor(floor)
    if floor then
        self._floor = floor
    end
end

function QFightClub:getFloor()
    return self._floor
end

function QFightClub:setWinCountTips(isShow)
    self._winCountTips = isShow
end

function QFightClub:getWinCountTips()
    return self._winCountTips
end

function QFightClub:getQuickSuccessAward()
    local str = self._quickFightAwardStr
    self._quickFightAwardStr = nil
    return str
end

function QFightClub:getMainLastInfo()
    return self._fightClubMainLastInfo
end

function QFightClub:updateMainLastInfo()
    self._fightClubMainLastInfo = clone(self._fightClubMainInfo)
end

function QFightClub:getMyLastInfo()
    return self._fightClubMyLastInfo
end

function QFightClub:updateMyLastInfo()
    self._fightClubMyLastInfo = clone(self._fightClubMyInfo)
end

function QFightClub:getMainInfo()
    return self._fightClubMainInfo
end

function QFightClub:getMyInfo()
    return self._fightClubMyInfo
end

function QFightClub:getRivalFighter()
    return self._fightClubRivalFighter
end

function QFightClub:getFightClubBattleArmy()
    return self._battleArmyList
end

function QFightClub:getFightClubQuickFightEndInfo()
    return self._fightEndInfo
end

-- 对手是否被击败
function QFightClub:getIsRivalFailed(userId)
    for i, failId in pairs(self._fightClubRivalFailList) do
        if userId == failId then
            return true
        end
    end
    return false
end

function QFightClub:getFightClubQuickFightInfo()
    return self._fightClubQuickFightInfo
end

function QFightClub:getAwardInfo()
    -- 获取第一个奖励
    if self._fightClubRewards and self._fightClubRewards[1] then 
        return self._fightClubRewards[1]
    end
end

--更新奖励 删除已领取的
function QFightClub:updateReaward(rewardId)
    if self._fightClubRewards then
        for i, rewards in pairs(self._fightClubRewards) do
            if rewards.rewardId == rewardId then
                table.remove( self._fightClubRewards, i )
                break
            end
        end
        self:dispatchEvent({name = QFightClub.FIGHT_CLUB_AWARD_UPDATE})
    end
end

function QFightClub:getFightClubRankInfo(floor)
    local rankConfigs = db:getFightClubRankInfo() 
    for _,v in ipairs(rankConfigs) do
        if floor == v.id then
            return v
        end
    end
end

function QFightClub:getFightClubMaxRank()
    local rankConfigs = db:getFightClubRankInfo()
    local rank = 0
    for i, v in pairs(rankConfigs) do
        if v.id > rank then
            rank = v.id
        end
    end
    return rank
end

-- 根据房间排名获取保级，升级，降级
function QFightClub:getRoomState(floor, roomRank)
    if not roomRank then 
        roomRank = 1
    end
    local rankInfo = self:getFightClubRankInfo(floor) 
    if not rankInfo then
        return QFightClub.STATE_KEEP
    end

    if roomRank <= rankInfo.num_up then
        return QFightClub.STATE_UP
    elseif roomRank <= (rankInfo.num_up + rankInfo.num_keep) then
        return QFightClub.STATE_KEEP
    else
        return QFightClub.STATE_DOWN
    end
end

--根据榜内段位排名获取奖励配置
function QFightClub:getAwardByFloorRank(floor, roomRank)
    local awards = {}
    local rankInfo = self:getFightClubRankInfo(floor) 
    if not rankInfo then
        return awards
    end

    local roomState = self:getRoomState(floor, roomRank)
    local awardStr = "reward_keep"
    if roomState == remote.fightClub.STATE_DOWN then
        awardStr = "reward_down"
    elseif roomState == remote.fightClub.STATE_KEEP then
        awardStr = "reward_keep"
    elseif roomState == remote.fightClub.STATE_UP then
        awardStr = "reward_up"
    end

    local awardConfig = db:getLuckyDraw(rankInfo[awardStr]) or {}
    local index = 1
    while true do
        local typeName = awardConfig["type_"..index]
        local id = awardConfig["id_"..index]
        local count = awardConfig["num_"..index]
        if typeName ~= nil then
            table.insert(awards, {id = id, typeName = typeName, count = count})
        else
            break
        end
        index = index + 1
    end

    return awards
end

--搏击俱乐部段位0-6，对应图片下标1-7
function QFightClub:getFloorTextureName(floor)
    if floor < 0 then
        floor = 0
    end
    if floor > 6 then
        floor = 6
    end
    local floorRes = QResPath("fight_club_floor")[floor+1]
    local rankInfo = self:getFightClubRankInfo(floor)
    if floorRes then
        return rankInfo.name, floorRes
    end
end

--搏击俱乐部段位0-9背景
function QFightClub:getMapInfo(floor)
    local bgNum = 1
    -- 王者
    if floor >= 6 then
        bgNum = 2
    end
    local floorRes = QResPath("fight_club_main_bg")[bgNum]
    if floorRes then
        local map = CCTextureCache:sharedTextureCache():addImage(floorRes)
        return map
    end
end

function QFightClub:updateFighterDefenseTeam( curFighter )
    if not self._fightClubRivalFighter then
        return
    end

    local needUpdate = false
    for i, fighter in pairs(self._fightClubRivalFighter) do 
        if fighter.userId == curFighter.userId and fighter.force ~= curFighter.force then
            needUpdate = true
            break
        end
    end

    if needUpdate then
        self:requestFightClubInfo()
    end
end

function QFightClub:setFightClubRewards(rewards)
    self._fightClubRewards = {}
    for i, v in pairs(rewards) do
        -- 新赛季结算保级奖励只能新赛季领取
        if v.type == 3 then
            if (self._seasonStartAt or 0)/1000 <= q.serverTime() then
                table.insert(self._fightClubRewards, v)
            end
        else
            table.insert(self._fightClubRewards, v)
        end
    end
    table.sort(self._fightClubRewards, function(a, b)
            return a.rewardId < b.rewardId
        end)
end
--主信息
function QFightClub:fightClubSimpleInfo( data )
    local response = data.fightClubResponse
    if not response then
        return
    end
    self._seasonNO = response.seasonNO
    self._seasonStartAt = response.seasonStartAt
    self._lastQuickFightAt = response.lastQuickFightAt
    
    if response.rewards then
        self:setFightClubRewards(response.rewards)
        self:dispatchEvent({name = QFightClub.FIGHT_CLUB_REDTIPS_CHANGE})
    end

    response.battleArmy = response.battleArmy or {}
    self:updateFightClubDefenseTeam(response.battleArmy)
end

--奖励信息更新
function QFightClub:fightClubRewardList(data)
    local response = data.fightClubResponse
    if not response then
        return
    end
    if response.rewards then
        self:setFightClubRewards(response.rewards)
    end
end

-- 是否提示可掠夺
function QFightClub:checkFightClubPlunderInfo()
    self._showPlunderTips = false
    local myForce = self._fightClubMyInfo.force
    for i, fighter in pairs(self._fightClubRivalFighter) do
        local isFailed = self:getIsRivalFailed(fighter.userId)
        if not isFailed and fighter.force < myForce then
            self._showPlunderTips = true
            self:dispatchEvent({name = QFightClub.FIGHT_CLUB_REDTIPS_CHANGE})
            break
        end
    end
end

function QFightClub:setShowPlunderTips(bShow)
    self._showPlunderTips = bShow
end

function QFightClub:getShowPlunderTips()
    return self._showPlunderTips
end

--快速挑战信息
function QFightClub:fightClubQuickFighters( data )
    local response = data.fightClubResponse
    if not response then
        return
    end
    self._fightClubQuickFightInfo = response.fightClubQuickFightInfo
end

function QFightClub:fightClubClosed( )
    self:resetData()
    self:dispatchEvent({name = QFightClub.FIGHT_CLUB_RESET})
end

function QFightClub:fightClubBeAttack( )
    self._winCountTips = true
    self:dispatchEvent({name = QFightClub.FIGHT_CLUB_REDTIPS_CHANGE})
end

--主要信息更新
function QFightClub:fightClubRefresh(data)
    local response = data.fightClubResponse
    if not response then
        return
    end

    self:resetData(data.api == "GLOBAL_FIGHT_END")

    if response.userInfo then
        self._fightClubMainInfo = response.userInfo
        local failUserId  = response.userInfo.failUserId 
        if failUserId then
            self._fightClubRivalFailList = failUserId
        end
        if self._fightClubMainInfo.floor then
            self._floor = self._fightClubMainInfo.floor
        end
    end
    if response.rivalFighter then
        self._fightClubRivalFighter = response.rivalFighter 
        for i, fighter in pairs(self._fightClubRivalFighter) do 
            if fighter.userId == remote.user.userId then
                self._fightClubMyInfo = fighter
            end
        end
    end

    if response.rewards then
        self:setFightClubRewards(response.rewards)
        self:dispatchEvent({name = QFightClub.FIGHT_CLUB_REDTIPS_CHANGE})
        self:updateReaward()
    end
    self._seasonReward = response.seasonReward

    if response.seasonStartAt then
        self._seasonStartAt = response.seasonStartAt
    end

    if data.api == "FIGHT_CLUB_GET_MAIN_INFO" and response.lastQuickFightAt then
        self._lastQuickFightAt = response.lastQuickFightAt
    end

    if response.fightClubQuickFightInfo then
        self._fightClubQuickFightInfo = response.fightClubQuickFightInfo
    end

    if response.awardStr then
        self._quickFightAwardStr = response.awardStr
    end

    if response.battleArmy then
        self:updateFightClubDefenseTeam(response.battleArmy)
    end
    --对手阵容刷新
    if response.battleArmyList then
        self._battleArmyList = response.battleArmyList
    end
    --快速战斗结束信息
    if response.fightEndInfo then
        self._fightEndInfo = response.fightEndInfo
    end

    --检测是否有防守阵容
    self:checkFightClubDefenseTeam()

    --检测是否有可掠夺的血腥玛丽
    self:checkFightClubPlunderInfo()


 

    self:dispatchEvent({name = QFightClub.FIGHT_CLUB_REFRESH})
end

function QFightClub:failCallback(data, fail)
    if data.error == "FIGHT_CLUB_CLOSED" then
        self:fightClubClosed()
    elseif data.api == "GLOBAL_FIGHT_END" then
        self:dispatchEvent({name = QFightClub.FIGHT_CLUB_QUICK_ERROR})
    end
    if fail then
        fail(data)
    end
end

--获取俱乐部赛季信息和个人赛季结算
function QFightClub:requestFightClubSimpleInfo(success, fail)
	local request = {api = "FIGHT_CLUB_GET_MY_INFO"}
    local successCallback = function (data)
        self:fightClubSimpleInfo(data)
        if success then
            success()
        end
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_GET_MY_INFO", request, successCallback, fail)
end

--获取俱乐部个人详细信息
function QFightClub:requestFightClubInfo(isMainInfo,success, fail, showError)
    self:requestFightClubRewardList(false)
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    local fightClubGetMainInfoRequest = {isMainInfo = isMainInfo or false}
    local request = {api = "FIGHT_CLUB_GET_MAIN_INFO",fightClubGetMainInfoRequest = fightClubGetMainInfoRequest} 
    app:getClient():requestPackageHandler("FIGHT_CLUB_GET_MAIN_INFO", request, function ( data )
            self._fightClubRivalFighter = {}
            self._fightClubMyInfo = {}
            self:fightClubRefresh(data)
            if success then
                success()
            end
        end,failCallback, nil, nil, showError)
end

--更新防守阵容
function QFightClub:requestModifyFightClubDefenseTeam(battleFormation, success, fail)
    local request = {api = "FIGHT_CLUB_MODIFY_ARMY", battleFormation = battleFormation}
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_MODIFY_ARMY", request, success, failCallback)
end

--防守阵容查询
function QFightClub:requestQueryFightClubDefendTeam(userId, success, fail)
    local fightClubQueryFighterRequest = {userId = userId}
    local successCallback = function (data)
        if success then
            success(data)
        end
    end
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    local request = {api = "FIGHT_CLUB_QUERY_FIGHTER",fightClubQueryFighterRequest = fightClubQueryFighterRequest}
    app:getClient():requestPackageHandler("FIGHT_CLUB_QUERY_FIGHTER", request, success, failCallback)
end

--快速挑战 老版本一直挑战
function QFightClub:requestFightClubQuickFight( success, fail )
    local request = {api = "FIGHT_CLUB_QUICK_FIGHT"}
    local successCallback = function (data)
        self:fightClubQuickFighters(data)
        self._fightClubMyLastInfo = clone(self._fightClubMyInfo)
        self._fightClubMainLastInfo = clone(self._fightClubMainInfo)
        if success then
            success(data)
        end
    end
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_QUICK_FIGHT", request, successCallback, failCallback)
end

--快速挑战结束
function QFightClub:requestFightClubQuickFightEnd( rivalUserId, wave, battleFormation, battleKey, success, fail, isShow)
    local fightClubQuickFightEndRequest = {rivalUserId = rivalUserId, wave = wave ,isQuick = false}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local successCallback = function (data)
        -- 重连的时候，继续打但是没有保留上次信息
        if not self._fightClubMainLastInfo or not next(self._fightClubMainLastInfo) then
            self._fightClubMyLastInfo = clone(self._fightClubMyInfo)
            self._fightClubMainLastInfo = clone(self._fightClubMainInfo)
        end
        self:fightClubRefresh(data)
        if success then
            success(data)
        end
    end
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    local gfEndRequest = {battleType = BattleTypeEnum.FIGHT_CLUB, battleVerify = battleVerify, fightReportData = fightReportData, 
        fightClubQuickFightEndRequest = fightClubQuickFightEndRequest, battleFormation = battleFormation}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, failCallback, isShow)
end

--战斗开始前检查排名
function QFightClub:requestFightClubFightStart(rivalUserId, battleFormation, success, fail, isShow)
    local fightClubFightStartRequest = {rivalUserId = rivalUserId}
    local gfStartRequest = {battleType = BattleTypeEnum.FIGHT_CLUB, battleFormation = battleFormation, fightClubFightStartRequest = fightClubFightStartRequest}   
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail, isShow)
end

--战斗结算
function QFightClub:requestFightClubFightEnd(rivalUserId, battleFormation, battleKey, success, fail)
    local fightClubFightEndRequest = {rivalUserId = rivalUserId}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local successCallback = function (data)
        self:fightClubRefresh(data)
        if success then
            success(data)
        end
    end
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    local gfEndRequest = {battleType = BattleTypeEnum.FIGHT_CLUB, battleVerify = battleVerify, fightReportData = fightReportData, 
        fightClubFightEndRequest = fightClubFightEndRequest, battleFormation = battleFormation}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, failCallback)
end

--奖励信息
function QFightClub:requestFightClubRewardList(showError)
    local request = {api = "FIGHT_CLUB_GET_REWARD_LIST"}
    local successCallback = function (data)
        self:fightClubRewardList(data)
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_GET_REWARD_LIST", request, successCallback, fail, nil, nil, showError)
end

--领取奖励
function QFightClub:requestFightClubGetReward( rewardId, success, fail )
    local fightClubFightGetRewardRequest = {rewardId = rewardId}
    local request = {api = "FIGHT_CLUB_GET_REWARD", fightClubFightGetRewardRequest = fightClubFightGetRewardRequest}
    local successCallback = function (data)
        if success then
            success(data)
        end
    end
    local failCallback = function (data)
        self:failCallback(data, fail)
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_GET_REWARD", request, successCallback, failCallback)
end

--战报
function QFightClub:requestFightClubGetReportList(success, fail)
    local request = {api = "FIGHT_CLUB_GET_REPORT_LIST"}
    app:getClient():requestPackageHandler("FIGHT_CLUB_GET_REPORT_LIST", request, success, fail)
end

-- 晋级
function QFightClub:requestFightClubRise(success, fail)
    local request = {api = "FIGHT_CLUB_PROMOTION"}
    local successCallback = function (data)
        self._fightClubMyLastInfo = clone(self._fightClubMyInfo)
        self._fightClubMainLastInfo = clone(self._fightClubMainInfo)
        self:fightClubRefresh(data)

        app.taskEvent:updateTaskEventProgress(app.taskEvent.FIGHT_CLUB_CLASS_UP_EVENT, 1)

        if success then
            success(data)
        end
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_PROMOTION", request, successCallback, fail)
end

--换房
function QFightClub:requestChangeRoom(success, fail)
    local request = {api = "FIGHT_CLUB_CHANGE_ROOM"}
    local successCallback = function (data)
        self:fightClubRefresh(data)
        if success then
            success(data)
        end
    end
    app:getClient():requestPackageHandler("FIGHT_CLUB_CHANGE_ROOM", request, successCallback, fail)
end

--一键扫荡所有未挑战玩家  新版本
function QFightClub:fightClubQuickFightRequest(myData , userDataList, success, fail)
    local fightClubQuickFightEndRequest = {isQuick = true , myData = myData , userDataList = userDataList}
    local successCallback = function (data)
        remote.user:addPropNumForKey("todayFightClubCount")
        self:fightClubRefresh(data)
        if success then
            success(data)
        end
    end
   local failCallback = function (data)
        self:failCallback(data, fail)
    end
    local gfEndRequest = {battleType = BattleTypeEnum.FIGHT_CLUB , fightClubQuickFightEndRequest = fightClubQuickFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, successCallback, failCallback)
end



return QFightClub