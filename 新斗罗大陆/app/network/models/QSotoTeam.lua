-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 16:50:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-09 17:33:33
-- 
local QBaseModel = import("...models.QBaseModel")
local QSotoTeam = class("QSotoTeam", QBaseModel)
local QUIViewController = import("...ui.QUIViewController")

QSotoTeam.EVENT_SOTO_TEAM_UPDATE = "EVENT_SOTO_TEAM_UPDATE"
QSotoTeam.EVENT_SOTO_TEAM_MY_INFO = "EVENT_SOTO_TEAM_MY_INFO"

QSotoTeam.SeasonType={ 
    SOTO_TEAM_ORIGIN = "SOTO_TEAM_ORIGIN" , 
    SOTO_TEAM_INHERIT = "SOTO_TEAM_INHERIT",
    SOTO_TEAM_EQUILIBRIUM = "SOTO_TEAM_EQUILIBRIUM",
}


function QSotoTeam:ctor(options)
	QSotoTeam.super.ctor(self)
end

function QSotoTeam:didappear()
	self:resetData()
end

function QSotoTeam:disappear()
end

function QSotoTeam:loginEnd()
	if self:checkSotoTeamIsOpen() then
		self:sotoTeamWarMyInfoRequest()
	end
end

function QSotoTeam:resetData()
    self._todayWorshipInfo = {}
    self._rewardInfo = {}
	self._dispatchList = {}
	self._sotoTeamInfo = {}
	self._myInfo = {}
    self._myFighter = {}
    self._worshipFighter = {}
    self._rivalFighters = {}
    self._sotoTeamSeasonInfo = {}
    self._sotoTeamSeasonReward = {}
    self._recordTip = false

end

function QSotoTeam:openDialog(callback)
	if not self:checkSotoTeamIsOpen(true) then
		return
	end
	self:sotoTeamWarInfoRequest(function ()
		app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSotoTeam"}, {isPopCurrentDialog = true})
        if callback then
            callback()
        end
	end)
end

--更新本地防守阵容
function QSotoTeam:updateDefenseTeam( data )
    -- body
    local battleFormation = data.battleFormation or {}
    if not battleFormation.mainHeroIds then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.SOTO_TEAM_DEFEND_TEAM)
        battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:sotoTeamChangeDefenseHeroRequest(battleFormation)
    end   
    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM)
    teamVO:setTeamDataWithBattleFormation(battleFormation) 
end

function QSotoTeam:setSotoTeamDefense(battleArmy)
    self._battleArmy = battleArmy
    self:updateDefenseTeam( battleArmy )

    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM)
    local teamVOMain = teamVO:getTeamActorsByIndex(1)
    local teamSoulSpirit = teamVO:getTeamSpiritsByIndex(1)
    local teamAlternate = teamVO:getTeamAlternatesByIndex(1)
    local teamSub1 = teamVO:getTeamActorsByIndex(2)
    local teamSub2 = teamVO:getTeamActorsByIndex(3)
    local teamSub3 = teamVO:getTeamActorsByIndex(4)
    
    self._myFighter = self._myInfo.fighter or {}
    self._myFighter.heros = {}
    self._myFighter.alternateHeros = {}
    self._myFighter.subheros = {}
    self._myFighter.sub2heros = {}
    self._myFighter.sub3heros = {}

    local insertFunc = function (srcHeros, destHeros)
        for _,actorId in pairs(srcHeros or {}) do
            table.insert(destHeros, remote.herosUtil:getHeroByID(actorId))
        end
    end
    insertFunc(teamVOMain, self._myFighter.heros)
    insertFunc(teamAlternate, self._myFighter.alternateHeros)
    insertFunc(teamSub1, self._myFighter.subheros)
    insertFunc(teamSub2, self._myFighter.sub2heros)
    insertFunc(teamSub3, self._myFighter.sub3heros)
    
    self._myFighter.activeSubActorId = teamSub1[1]
    self._myFighter.activeSub2ActorId = teamSub2[2]
    self._myFighter.activeSub3ActorId = teamSub3[3]

    local teamForce = remote.teamManager:getBattleForceForAllTeam(remote.teamManager.SOTO_TEAM_DEFEND_TEAM)
    self._myFighter.force = teamForce

    self._myFighter.sotoTeamTopnForce = battleArmy.sotoTeamTopnForce or 0
    if self._myFighter.sotoTeamTopnForce ~= 0 then
        local helpTeam1 = remote.teamManager:getActorIdsByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, 1)
        local helpTeam = #remote.teamManager:getAlternateIdsByKey(remote.teamManager.SOTO_TEAM_DEFEND_TEAM, 1)-- 替补
        local inherit_force = remote.herosUtil:countForceByHeros(helpTeam1, islocal) * 0.25 *helpTeam
        self._myFighter.sotoTeamTopnForce  = teamForce + inherit_force
    end


    if remote.selectServerInfo then
        self._myFighter.game_area_name = remote.selectServerInfo.name
    end
    if not self._myFighter.game_area_name then
        self._myFighter.game_area_name = ""
    end
    self._myFighter.rank = self._myInfo.curRank or 10001

    self:updatePlayerInfo(self._myFighter)
end

function QSotoTeam:setSotoTeamMyInfo(myInfo)
    self._myInfo = myInfo

    self._todayWorshipInfo = {}
    self._rewardInfo = {}
    if self._myInfo.todayWorshipPos then
        local posTbl = string.split(self._myInfo.todayWorshipPos, ";")
        for _,value in ipairs(posTbl) do
            if value ~= "" then
                self._todayWorshipInfo[tonumber(value)] = true
            end
        end
    end
    if self._myInfo.rewardInfo then
        local rewardTbl = string.split(self._myInfo.rewardInfo, ";")
        for _,value in ipairs(rewardTbl) do
            if value ~= "" then
                table.insert(self._rewardInfo, tonumber(value))
            end
        end
    end
    if self._myInfo.topRank ~= remote.user.sotoTeamTopRank then
        remote.user:update({sotoTeamTopRank = self._myInfo.topRank})
    end
    if self._myInfo.totalFightCount ~= remote.user.totalSotoTeamFightCount then
        remote.user:update({totalSotoTeamFightCount = self._myInfo.totalFightCount})
    end
end

function QSotoTeam:setWorshipFighter(worshipFighter)
    self._worshipFighter = worshipFighter
end

function QSotoTeam:getWorshipFighters()
    return self._worshipFighter
end

function QSotoTeam:getSotoTeamWorship()
    local worships = {}
    if self._worshipFighter ~= nil then
        for i, fighter in ipairs(self._worshipFighter) do
            local worship = {}
            worship.userId = fighter.userId
            worship.pos = i
            table.insert(worships, worship)
        end
    end
    return worships
end

function QSotoTeam:setRivalFighters(rivalFighters)
    self._rivalFighters = rivalFighters
end

function QSotoTeam:getRivalFighters()
    return self._rivalFighters or {}
end

function QSotoTeam:setSotoTeamSeasonInfo(sotoTeamSeasonInfo)
    self._sotoTeamSeasonInfo = sotoTeamSeasonInfo
end
-- message SotoTeamSeasonInfo {
--     optional int32 seasonNo = 1;            //  赛季
--     optional int64 seasonStartAt = 2;       //  赛季开始时间
--     optional int64 seasonEndAt = 3;         //  赛季结束时间
--     optional SeasonType seasonType = 4;     //  赛季类型
-- }
function QSotoTeam:getSotoTeamSeasonInfo()
    return self._sotoTeamSeasonInfo or {}
end

function QSotoTeam:setSotoTeamSeasonReward(sotoTeamSeasonReward)
    self._sotoTeamSeasonReward = sotoTeamSeasonReward
end
-- message SotoTeamSeasonReward {
--     optional string rewards  = 1;           //奖励内容
--     optional int32  oldMaxRank = 2;         //上赛季历史最高排名
--     optional int32  oldEnvRank = 3;         //上赛季区服最终排名
--     optional int32 oldRank = 4;             //上赛季全服最终排名
--     optional int32 seasonNo = 5;            //赛季
--     optional SeasonType seasonType = 6;     //  赛季类型
-- }
function QSotoTeam:getSotoTeamSeasonReward()
    return self._sotoTeamSeasonReward or {}
end


function QSotoTeam:checkIsInheritSeason()
    if not self._sotoTeamSeasonInfo or not self._sotoTeamSeasonInfo.seasonType then 
        return false 
    end

    return  self._sotoTeamSeasonInfo.seasonType == "SOTO_TEAM_INHERIT" 
end

function QSotoTeam:checkIsEquilibriumSeason()
    if not self._sotoTeamSeasonInfo or not self._sotoTeamSeasonInfo.seasonType then 
        return false 
    end
    
    return  self._sotoTeamSeasonInfo.seasonType == "SOTO_TEAM_EQUILIBRIUM" 
end

function QSotoTeam:checkIsInSeason()
    if not self._sotoTeamSeasonInfo.seasonStartAt  then return false end
    local curTime = q.serverTime()

    local startAt = self._sotoTeamSeasonInfo.seasonStartAt or 0
    local endAt = self._sotoTeamSeasonInfo.seasonEndAt  or 0
    startAt = startAt /1000
    endAt = endAt /1000
    if startAt and endAt  then
        if curTime <= endAt and curTime >= startAt then
            return true 
        end
    end
    return false 
end


function QSotoTeam:updatePlayerInfo(curFighter)
    for _,fighter in pairs(self._worshipFighter or {}) do
        if fighter.userId == curFighter.userId then
            fighter.force = curFighter.force
            break
        end
    end
    for _,fighter in pairs(self._rivalFighters or {}) do
        if fighter.userId == curFighter.userId then
            fighter.force = curFighter.force
            break
        end
    end
end

function QSotoTeam:getMyInfo()
	return self._myInfo
end

function QSotoTeam:getMyPlayerInfo()
    return self._myFighter
end

function QSotoTeam:getSotoTeamInfo()
	return self._sotoTeamInfo
end

function QSotoTeam:getDailyScore()
	return self._myInfo.integral or 0
end

function QSotoTeam:setTopRankUpdate( result, rivalId )
    -- body
    self._fightWinResult = result
    self._fightWinRivalId = rivalId
end

function QSotoTeam:getTopRankUpdate()
    return self._fightWinResult, self._fightWinRivalId
end

function QSotoTeam:dailyRewardInfoIsGet(rewardId)
	for _,id in ipairs(self._rewardInfo) do
		if id == rewardId then
			return true
		end
	end
	return false
end

function QSotoTeam:checkSotoTeamIsOpen(isTips)
	if not app.unlock:checkLock("UNLOCK_SOTO_TEAM", isTips) then
		return false
	end

	return true
end

function QSotoTeam:checkTodayWorshipByPos(pos)
    return self._todayWorshipInfo[pos]
end

function QSotoTeam:setSotoTeamRecordTip(state)
    self._recordTip = state
end

-- 战报记录
function QSotoTeam:checkFightRecordTip()
    return self._recordTip
end

--每日积分是否有可领取的
function QSotoTeam:checkScoreRewardRedTips()
    local dailyScore = self:getDailyScore()
    local configs = db:getStaticByName("soto_team_reward")
    for _,value in pairs(configs) do
        if self:dailyRewardInfoIsGet(value.ID) == false and value.condition <= dailyScore then
            return true
        end
    end
    return false
end

-- 挑战提示
function QSotoTeam:checkFightRedTips()
    if not self:checkSotoTeamIsOpen() then--添加判断云顶之战是否开启
        return false
    end       
    if not self:checkIsInSeason() then--添加判断云顶之战赛季是否开启
        return false
    end      
    local configTotalCount = db:getConfiguration().soto_team_free_fight_count.value or 0
    local fightCountBuy = self._myInfo.fightCountBuy or 0
    local fightCount = self._myInfo.fightCount or 0
    local leftCount = configTotalCount + fightCountBuy - fightCount
    return leftCount > 0
end

--商店红点
function QSotoTeam:checkShopRedTips(  )
    -- if remote.stores:checkFuncShopRedTips(SHOP_ID.sotoTeamShop) then
    --     return true
    -- end
    return false
end

-- 阵容提示
function QSotoTeam:checkTeamRedTips()
    local teamFull = remote.teamManager:checkTeamStormIsFull(remote.teamManager.SOTO_TEAM_DEFEND_TEAM)
    if teamFull then
        return false
    end
    return true
end

-- 红点
function QSotoTeam:checkRedTips()
	if not self:checkSotoTeamIsOpen() then
		return false
	end
    if not self:checkIsInSeason() then--添加判断云顶之战赛季是否开启
        return false
    end     
    
    if self:checkFightRecordTip() then
        return true
    end
    if self:checkScoreRewardRedTips() then
        return true
    end
	-- if self:checkFightRedTips() then
	-- 	return true
	-- end
	if self:checkShopRedTips() then
		return true
	end
	if self:checkTeamRedTips() then
		return true
	end

	return false
end

function QSotoTeam:getSotoTeamAddProps()
    local prop = {hp = 0, attack = 0, magicArmor = 0, physicalArmor = 0, hit = 0, dodge = 0, block = 0, crit = 0, haste = 0, 
    physical_penetration = 0, magic_penetration = 0, crit_reduce_rating = 0, physical_damage_percent_attack = 0, physical_damage_percent_beattack_reduce = 0, 
    magic_damage_percent_attack = 0, magic_damage_percent_beattack_reduce = 0}
    return prop
end


function QSotoTeam:_dispatchAll()
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
function QSotoTeam:responseHandler(data, success, fail, succeeded)
	--进游戏拉取简单信息
	if data.sotoTeamUserInfoResponse ~= nil then
        if data.sotoTeamUserInfoResponse.myInfo then
    	   self:setSotoTeamMyInfo(data.sotoTeamUserInfoResponse.myInfo)
            table.insert(self._dispatchList, QSotoTeam.EVENT_SOTO_TEAM_MY_INFO)
        end

        if data.sotoTeamUserInfoResponse.battleArmy then
            self:setSotoTeamDefense(data.sotoTeamUserInfoResponse.battleArmy)
            table.insert(self._dispatchList, QSotoTeam.EVENT_SOTO_TEAM_UPDATE)
        end

        if data.sotoTeamUserInfoResponse.worships then
            self:setWorshipFighter(data.sotoTeamUserInfoResponse.worships)
        end
        
        if data.sotoTeamUserInfoResponse.rivals then
            self:setRivalFighters(data.sotoTeamUserInfoResponse.rivals)
            table.insert(self._dispatchList, QSotoTeam.EVENT_SOTO_TEAM_UPDATE)
        end
        --赛季信息刷新
        if data.sotoTeamUserInfoResponse.sotoTeamSeasonInfo then
            self:setSotoTeamSeasonInfo(data.sotoTeamUserInfoResponse.sotoTeamSeasonInfo)
        end
        --赛季奖励刷新
        if data.sotoTeamUserInfoResponse.sotoTeamSeasonReward then
            self:setSotoTeamSeasonReward(data.sotoTeamUserInfoResponse.sotoTeamSeasonReward)
        end
    end
    if data.towerFightersDetail then
        local rivalInfo = data.towerFightersDetail[1]
        self:updatePlayerInfo(rivalInfo)
        table.insert(self._dispatchList, QSotoTeam.EVENT_SOTO_TEAM_UPDATE)
    end

    -- 事件
    self:_dispatchAll()
    
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



-- SOTO_TEAM_GET_MY_INFO                           = 10041;                     // 索托团队赛--我的信息 SotoTeamUserInfoResponse
-- SOTO_TEAM_GET_MAIN_INFO                         = 10042;                     // 索托团队赛--主界面信息 SotoTeamUserInfoResponse
-- SOTO_TEAM_REFRESH                               = 10043;                     // 索托团队赛--刷新 SotoTeamRefreshRequest SotoTeamUserInfoResponse
-- SOTO_TEAM_QUERY_FIGHTER                         = 10044;                     // 索托团队赛--查看玩家的防守阵容 SotoTeamQueryDefenseHerosRequest SotoTeamUserInfoResponse
-- SOTO_TEAM_CHANGE_DEFENSE_HEROS                  = 10045;                     // 索托团队赛--设置防守阵容 SotoTeamChangeDefenseHeroRequest SotoTeamUserInfoResponse
-- SOTO_TEAM_BUY_FIGHT_COUNT                       = 10046;                     // 索托团队赛--打斗次数购买 SotoTeamUserInfoResponse
-- SOTO_TEAM_FIGHT_HISTORY                         = 10047;                     // 索托团队赛--查看自己最近20次战斗纪录 SotoTeamUserInfoResponse
-- SOTO_TEAM_WORSHIP                               = 10048;                     // 索托团队赛--膜拜 SotoTeamWorshipRequest SotoTeamUserInfoResponse
-- SOTO_TEAM_GET_DEFENSE_HERO                      = 10049;                     // 索托团队赛--查看玩家的防守阵容 SotoTeamQueryDefenseHerosRequest SotoTeamUserInfoResponse
-- SOTO_TEAM_INTEGRAL_REWARD                       = 10050;                     // 索托团队赛--每日积分奖励 SotoTeamIntegralRewardRequest SotoTeamUserInfoResponse

 
--进游戏拉取简单信息
function QSotoTeam:sotoTeamWarMyInfoRequest(success, fail)
    local request = {api = "SOTO_TEAM_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--拉取信息
function QSotoTeam:sotoTeamWarInfoRequest(success, fail)
    local request = {api = "SOTO_TEAM_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--刷新对手
function QSotoTeam:sotoTeamRefreshRequest(success, fail)
    local request = {api = "SOTO_TEAM_REFRESH"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--查询阵容 
function QSotoTeam:sotoTeamQueryFighterRequest(userId, success, fail)
	local sotoTeamQueryFighterRequest = {userId = userId}
    local request = {api = "SOTO_TEAM_QUERY_FIGHTER", sotoTeamQueryFighterRequest = sotoTeamQueryFighterRequest, battleFormation = battleFormation}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--更新出战阵容 
function QSotoTeam:sotoTeamChangeDefenseHeroRequest(battleFormation, success, fail)
    local request = {api = "SOTO_TEAM_CHANGE_DEFENSE_HEROS", battleFormation = battleFormation}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--购买次数
function QSotoTeam:sotoTeamBuyFightCountRequest(success, fail)
    local request = {api = "SOTO_TEAM_BUY_FIGHT_COUNT"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--查询战报
function QSotoTeam:sotoTeamFightHistoryRequest(success, fail)
    local request = {api = "SOTO_TEAM_FIGHT_HISTORY"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 膜拜
function QSotoTeam:sotoTeamWorshipRequest(userId, pos, success, fail)
	-- local sotoTeamWorshipRequest = {userId = userId, pos = pos}
    local sotoTeamWorshipRequest = {posIds = {pos}, isSecretaryGet = false}
    local request = {api = "SOTO_TEAM_WORSHIP", sotoTeamWorshipRequest = sotoTeamWorshipRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 积分领取
function QSotoTeam:sotoTeamIntegralRewardRequest(boxIds, success, fail)
	local sotoTeamIntegralRewardRequest = {boxIds = boxIds}
    local request = {api = "SOTO_TEAM_INTEGRAL_REWARD", sotoTeamIntegralRewardRequest = sotoTeamIntegralRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        app.taskEvent:updateTaskEventProgress(app.taskEvent.SOTO_TEAM_REWARD_COUNT_EVENT, #boxIds)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--战斗开始前检查排名
function QSotoTeam:sotoTeamFightStartCheckRequest(selfUserId, selfPos, rivalUserId, rivalPos, success, fail)
    local sotoTeamFightStartCheckRequest = {selfUserId = selfUserId, selfPos = selfPos, rivalUserId = rivalUserId, rivalPos = rivalPos}
    local gfStartCheckRequest = {battleType = BattleTypeEnum.SOTO_TEAM, sotoTeamFightStartCheckRequest = sotoTeamFightStartCheckRequest}   
    local request = {api = "GLOBAL_FIGHT_START_CHECK", gfStartCheckRequest = gfStartCheckRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START_CHECK", request, success, fail)
end

-- 战斗开始
function QSotoTeam:sotoTeamFightStartRequest(rivalUserId, battleFormation, success, fail)
    local sotoTeamFightStartRequest = {rivalUserId = rivalUserId}
    local gfStartRequest = {battleType = BattleTypeEnum.SOTO_TEAM, battleFormation = battleFormation, sotoTeamFightStartRequest = sotoTeamFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

-- 战斗结束
function QSotoTeam:sotoTeamFightEndRequest(rivalUserId, pos, battleFormation, fightResult, verifyDamages, battleKey, success, fail)
    local sotoTeamFightEndRequest = {rivalUserId = rivalUserId, pos = pos, fightResult = fightResult, damage = {damages = verifyDamages}}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.SOTO_TEAM, battleVerify = battleVerify, fightReportData = fightReportData, sotoTeamFightEndRequest = sotoTeamFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 扫荡结束
function QSotoTeam:sotoTeamQuickFightRequest(rivalUserId, pos, success, fail, status)
    local sotoTeamQuickFightRequest = {rivalUserId = rivalUserId, pos = pos}
    local gfQuickRequest = {battleType = BattleTypeEnum.SOTO_TEAM, sotoTeamQuickFightRequest = sotoTeamQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


--云顶之战赛季奖励领取
function QSotoTeam:sotoTeamGetSeasonRewardRequest(seasonNo_,success, fail)
    local sotoTeamGetSeasonRewardRequest = {seasonNo = seasonNo_}

    local request = {api = "SOTO_TEAM_GET_SEASON_REWARD",sotoTeamGetSeasonRewardRequest = sotoTeamGetSeasonRewardRequest}
    app:getClient():requestPackageHandler("SOTO_TEAM_GET_SEASON_REWARD", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QSotoTeam
