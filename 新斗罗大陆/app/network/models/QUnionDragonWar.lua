-- 
-- zxs
-- 宗门武魂战
-- 
local QBaseModel = import("...models.QBaseModel")
local QUnionDragonWar = class("QUnionDragonWar", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")

QUnionDragonWar.EVENT_UPDATE_MYINFO = "EVENT_UPDATE_MYINFO"
QUnionDragonWar.EVENT_UPDATE_DRANGON_INFO = "EVENT_UPDATE_DRANGON_INFO"
QUnionDragonWar.EVENT_UPDATE_FIGHT_COUNT = "EVENT_UPDATE_FIGHT_COUNT"
QUnionDragonWar.EVENT_UPDATE_AWARD = "EVENT_UPDATE_AWARD"
QUnionDragonWar.EVENT_UPDATE_BUFF_INFO = "EVENT_UPDATE_BUFF_INFO"
QUnionDragonWar.EVENT_UPDATE_KILL_INFO = "EVENT_UPDATE_KILL_INFO"

function QUnionDragonWar:ctor(options)
	QUnionDragonWar.super.ctor(self)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUnionDragonWar:didappear()
    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVNET_CONSORTIA_CHANGE, handler(self,self.updateDragonInfo))

	self:resetData()
end

function QUnionDragonWar:disappear()
    if self._userEventProxy ~= nil then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QUnionDragonWar:resetData()
	self._myInfo = {}
	self._dragonLogs = {}
	self._dragonFighter = {}
	self._myDragonInfo = {}
	self._enemyDragonInfo = {}
	self._top5Ranks = {}
	self._fightResult = false 		-- 自己的宗门是否胜利
	self._dailyReward = {}
	self._currSeason = {}
	self._envRank = 0
	self._allRank = 0
	self._dispatchList = {} 		-- 事件
	self._weatherIdList = {}		-- 可出现天气id
	self._openTime = 0
	self._closeTime = 0

	local fightWeather = db:getConfiguration()["dragon_fight_weather"].value
	local weatherIds = string.split(fightWeather, ",")
	for i, weatherId in pairs(weatherIds) do
		table.insert(self._weatherIdList, weatherId)
	end

	local configuration = db:getConfiguration()
	local openTime = configuration["sociaty_dragon_fight_begin_time"].value
	local closeTime = configuration["sociaty_dragon_fight_end_time"].value
	openTime = string.split(openTime, ":")
	closeTime = string.split(closeTime, ":")
	self._openTime = q.getTimeForHMS(tonumber(openTime[1]), tonumber(openTime[2]), tonumber(openTime[3]))
	self._closeTime = q.getTimeForHMS(tonumber(closeTime[1]), tonumber(closeTime[2]), tonumber(closeTime[3]))
end

function QUnionDragonWar:updateDragonInfo()
	if remote.user.userConsortia == nil or remote.user.userConsortia.consortiaId == "" then
		self:resetData()
	end
end

function QUnionDragonWar:refreshTimeHandler(event)
	if event.time == nil or event.time == 5 then
		self._fightAwardsConfigs = db:getDragonFightAwardsByLevel(remote.user.dailyTeamLevel)
    end
end

function QUnionDragonWar:checkDragonWarUnlock(isTips)
	local dragonInfo = remote.dragon:getDragonInfo()
	local openDragonLevel = db:getConfiguration()["sociaty_dragon_fight_open_dragon_level"].value or 5
	if (dragonInfo.level or 0) < openDragonLevel then
		if isTips then
			app.tip:floatTip(string.format("武魂争霸赛将在宗门武魂达到%d级开启~", openDragonLevel))
		end
		return false
	end

	if app.unlock:checkLock("SOCIATY_DRAGON_FIGHT", isTips) == false then
		return false
	end

	return true
end

function QUnionDragonWar:loginEnd()
	if self:checkDragonWarUnlock(false) == false then
    	return false
    end

	-- 战队等级奖励
	self._fightAwardsConfigs = db:getDragonFightAwardsByLevel(remote.user.dailyTeamLevel)

	self:dragonWarGetMyInfoRequest()
	self:dragonWarGetDailyRewardListRequest()
end

function QUnionDragonWar:checkDragonWarOpen()
	local nowTime = q.serverTime()
	if nowTime < self._openTime then
		return false, self._openTime, self._closeTime
	elseif nowTime >= self._openTime and nowTime <= self._closeTime then
		return true, self._openTime, self._closeTime
	elseif nowTime > self._closeTime then
		return false, self._openTime + DAY, self._closeTime + DAY
	end

	return false, self._openTime, self._closeTime
end

function QUnionDragonWar:openDragonWarDialog()
    if self:checkDragonWarUnlock(true) == false then
    	return false
    end

    if remote.user.userConsortia ~= nil then
		local enterTime = remote.user.userConsortia.leave_at/1000 or 0
		if q.serverTime() < enterTime + 24 * HOUR then
			app.tip:floatTip("离开宗门后的24小时内，无法参与武魂争霸战")
			return
		end
	end

	local matchTime = 2 * HOUR
    local isOpen, openTime = self:checkDragonWarOpen()
    if isOpen == false and (q.serverTime() + matchTime) >= openTime then
    	local time1 = q.date("%H:%M", openTime - matchTime)
    	local time2 = q.date("%H:%M", openTime)
    	app.tip:floatTip(string.format("%s到%s是武魂争霸赛匹配时间，魂师大人请稍后再来～", time1,time2))
    	return 
    end
    
	self:dragonWarGetMyInfoRequest(function (data)
		self:dragonWarGetCurrentBattleInfoRequest(function(data)
			local fightInfo = data.dragonWarGetCurrentBattleInfoResponse
			if fightInfo and fightInfo.battleInfo and next(fightInfo.battleInfo) then
				self:dragonWarGetDailyRewardListRequest(function(data)
					app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWar", 
				        options = {}}, {isPopCurrentDialog = true})
				end)
			else
				app.tip:floatTip("魂师大人，当前没有匹配到相应宗门，请稍后再试～")
				return
			end
		end)
	end)
end

function QUnionDragonWar:setMyInfo(data)
	self._myInfo = data.myInfo
	self:dispatchEvent({name = QUnionDragonWar.EVENT_UPDATE_MYINFO})
end

function QUnionDragonWar:setDragonHurtInfo(message)
    if self:checkDragonWarUnlock() == false then
    	return false
    end
	--message.params consortiaId + ";" + unionName + ";" + nickName + ";" + hurt
	if message == nil then return end
	local hurtInfo = {}
	local infos = string.split(message.params, ";")
	hurtInfo.consortiaId = infos[1]
	hurtInfo.unionName = infos[2]
	hurtInfo.userName = infos[3]
	hurtInfo.hurtNum = tonumber(infos[4]) or 0

	self:dispatchEvent({name = QUnionDragonWar.EVENT_UPDATE_KILL_INFO, info = hurtInfo})
end

function QUnionDragonWar:getMyInfo()
	return self._myInfo or {}
end

function QUnionDragonWar:getDragonFighter( )
	return self._dragonFighter
end

--巨龙之战BUFF的总次数
function QUnionDragonWar:getBuffTotalCount()
	if self:getMyDragonFighterInfo() then
		local level = self:getMyDragonFighterInfo().level or remote.union.consortia.level
		local buffCount = db:getSocietyLevel(level).sociaty_dragon_holy or 0
		return buffCount
	end
	return 0
end

function QUnionDragonWar:setDragonInfo(data)
	-- 对战信息
	if data.battleInfo then
		self._dragonFighter = data.battleInfo
		if self._dragonFighter.consortiaBattle1 and self._dragonFighter.consortiaBattle1.consortiaId == remote.user.userConsortia.consortiaId then
			self:setMyDragonInfo(self._dragonFighter.consortiaBattle1)
			self._enemyDragonInfo = self._dragonFighter.consortiaBattle2
		else
			self:setMyDragonInfo(self._dragonFighter.consortiaBattle2)
			self._enemyDragonInfo = self._dragonFighter.consortiaBattle1

			self._fightResult = not data.battleInfo.isConsortia1Win
		end
	end

	-- 日志信息
	if data.battleEvents then
		self._dragonLogs = data.battleEvents
	end

	--后端传空的时候默认没有排行
	self._top5Ranks = data.top5Ranks or {}

	if data.currSeason then
		self._currSeason = data.currSeason
	end

	self:dispatchEvent({name = QUnionDragonWar.EVENT_UPDATE_DRANGON_INFO})
end

function QUnionDragonWar:setMyDragonInfo(data)
	local dragonInfo = clone(data)
	if next(self._myDragonInfo) == nil then
		self._myDragonInfo = dragonInfo
	else
		for key, value in pairs(dragonInfo) do
			self._myDragonInfo[key] = value
		end
	end
end

function QUnionDragonWar:getMyDragonFighterInfo()
	return self._myDragonInfo or {}
end

function QUnionDragonWar:getEnemyDragonFighterInfo()
	return self._enemyDragonInfo or {}
end

-- 这里的 self._fightResult 是 fighter1 的输赢
function QUnionDragonWar:getFightResult(fighter1, fighter2)
	if fighter1 == nil or next(fighter1) == nil or fighter2 == nil or next(fighter2) == nil then
		return false
	end
	self._fightResult = false
	
	local fighter1FullHp = fighter1.dragonFullHp or 0
	local fighter1FullHurt = fighter1.dragonHurtHp or 0
	local fighter2FullHp = fighter2.dragonFullHp or 0
	local fighter2FullHurt = fighter2.dragonHurtHp or 0

	local fight1Percent = fighter1FullHurt/fighter1FullHp
	local fight2Percent = fighter2FullHurt/fighter2FullHp
	if fight1Percent ~= fight2Percent then
		self._fightResult = fight1Percent < fight2Percent
	elseif fighter1FullHurt ~= fighter2FullHurt then
		self._fightResult = fighter1FullHurt < fighter2FullHurt
	end

	return self._fightResult
end

function QUnionDragonWar:getDragonLogs()
	return self._dragonLogs or {}
end

function QUnionDragonWar:getTop5Ranks()
	return self._top5Ranks or {}
end

function QUnionDragonWar:getCurrentSeasonInfo()
	return self._currSeason
end

-- 根据日期计算出一个天气id，循环周期为41(随便定义的)
function QUnionDragonWar:getUnionDragonWarWeatherId()
	local count = #self._weatherIdList
	local round = 41	-- 循环
	local timeTbl = q.date("*t", q.serverTime())
	local totalNum = timeTbl.year + timeTbl.month*timeTbl.month + timeTbl.day*timeTbl.day
	local randNum = totalNum%round
    local index = randNum%count+1
    return self._weatherIdList[index] or 1
end

function QUnionDragonWar:getUnionDragonWarWeather()
	local weatherId = self:getUnionDragonWarWeatherId()
	local weather = db:getDragonWarWeatherById(weatherId)
	return weather
end

function QUnionDragonWar:getUnionDragonWinBuffer(bufferId)
    if bufferId == nil or bufferId == 1 then
    	return nil 
    end

    local configuration = db:getConfiguration()
    local index = 2
    local value = 1
    while configuration["union_dragon_war_victory_time_"..index] do
    	if bufferId == index then
    		value = configuration["union_dragon_war_victory_time_"..index].value
    	end
    	index = index + 1 
    end

    if bufferId >= index then
    	index = index - 1
    	value = configuration["union_dragon_war_victory_time_"..index].value
    end

    return (value - 1) * 100
end

function QUnionDragonWar:getDragonWarScoreRewards()
    -- 获取第一个奖励
    if self._dailyReward and self._dailyReward[1] then 
        return self._dailyReward[1]
    end
end

--更新奖励 删除已领取的
function QUnionDragonWar:updateDragonWarScoreRewards(rewardId)
    if self._dailyReward then
        for i, rewards in pairs(self._dailyReward) do
            if rewards.rewardId == rewardId then
                table.remove( self._dailyReward, i )
                break
            end
        end
        self:dispatchEvent({name = QUnionDragonWar.EVENT_UPDATE_AWARD})
    end
end

function QUnionDragonWar:checkMyHolyBuffer()
	local myFighterInfo = self:getMyInfo()
	local nowTime = q.serverTime()
	if nowTime < (myFighterInfo.holyStsEndAt or 0)/1000 then
		local offsetTime = (myFighterInfo.holyStsEndAt or 0)/1000 - nowTime
		return true, offsetTime
	end
	return false, -1 
end

function QUnionDragonWar:checkDragonWarRedTip()
	if self:checkDragonWarUnlock() == false then 
		return false
	end	

	local fighterInfo = self:getMyDragonFighterInfo()
	if fighterInfo == nil or next(fighterInfo) == nil then
		return false
	end

	local awards = self:getDragonWarScoreRewards()
	if awards ~= nil and next(awards) ~= nil then
		return true
	end

	if self:checkDragonDailyAward() then
		return true
	end

	if self:checkDragonWarShopTip() then
		return true
	end

	return false
end

function QUnionDragonWar:checkDragonDailyAward()
	local myInfo = self:getMyInfo()
	local dragonInfo = self:getEnemyDragonFighterInfo()
	local todayHurt = (myInfo.todayHurt or 0)
	local hurtIds = {}
	if myInfo.todayAwardedHurtIds ~= nil then
		for _,id in pairs(myInfo.todayAwardedHurtIds) do
			hurtIds[id] = true
		end
	end
	for _, config in pairs(self._fightAwardsConfigs or {}) do
		if todayHurt >= config.condition and hurtIds[config.ID] == nil then
			return true
		end
	end
	return false
end

function QUnionDragonWar:checkDragonWarShopTip()
	if self:checkDragonWarUnlock() == false then
		return false
	end

	return remote.exchangeShop:checkExchangeShopRedTipsById(SHOP_ID.dragonWarShop)
end

function QUnionDragonWar:checkHaveFightCount()
	if self:checkDragonWarUnlock() == false then 
		return false
	end	

	-- 已结束
    local isOpen = self:checkDragonWarOpen()
    if not isOpen then
    	return false
    end

	local freeFightCount = db:getConfiguration()["sociaty_dragon_fight_initial"].value
	local myInfo = self:getMyInfo()
    local buyCount = myInfo.buyFightCount or 0
	local count = freeFightCount + buyCount - (myInfo.fightCount or 0)
	if count > 0 then
		return true
	end

	return false
end

--获取龙战的宗门阶段
function QUnionDragonWar:getDragonFloor()
	local floor = 0
	if self:checkDragonWarUnlock() == true then
		local myInfo = self:getMyDragonFighterInfo()
		if myInfo ~= nil then
			floor = myInfo.floor or 0
		end
	end
	return floor
end

--获取龙战每天排名信息
function QUnionDragonWar:getDailyRankInfo()
	return self._envRank, self._allRank
end

function QUnionDragonWar:encodeDragonWarLogsByType(content)
	if content == nil then return "" end

	local data = string.split(content, ";")
	local logInfo = {}
	for _, value in pairs(data) do
		local info = string.split(value, "=")
		logInfo[info[1]] = info[2]
	end
	local myConsortiaId = remote.user.userConsortia.consortiaId
	local realContent = ""
	local logDate = db:getUnionLogByID(tonumber(logInfo.type))
	if logDate.id == 21 then
		local defenseUnionName = ""
		local attackUserName = ""
		local attackUnionName = ""

		local hurt, word = q.convertLargerNumber(logInfo.myHurt or 0)
		if myConsortiaId == logInfo.myConsortiaId then
			attackUnionName = "##K".."【"..(logInfo.myConsortiaName or "").."】"
			defenseUnionName = "##N".."【"..(logInfo.tgtConsortiaName or "").."】"
			attackUserName = "##K"..(logInfo.myName or "")
			hurt = "##K"..hurt..word
		else
			attackUnionName = "##N".."【"..(logInfo.myConsortiaName or "").."】"
			defenseUnionName = "##K".."【"..(logInfo.tgtConsortiaName or "").."】"
			attackUserName = "##N"..(logInfo.myName or "")
			hurt = "##N"..hurt..word
		end

		realContent = string.format(logDate.content, attackUnionName, attackUserName, defenseUnionName, hurt)
	end
	if logDate.id == 22 then
		local unionName = ""
		local dragonName = ""
		
		local blood, word = q.convertLargerNumber(logInfo.tgtDragonCurrHp or 0)
		local dragonConfig = db:getUnionDragonConfigById(logInfo.tgtDragonId)
		if myConsortiaId == logInfo.myConsortiaId then
			unionName = "##N".."【"..(logInfo.tgtConsortiaName or "").."】"
			dragonName = "##N"..(dragonConfig.dragon_name or "")
			blood = "##N"..blood..word
		else
			unionName = "##K".."【"..(logInfo.tgtConsortiaName or "").."】"
			dragonName = "##K"..(dragonConfig.dragon_name or "")
			blood = "##K"..blood..word
		end

		realContent = string.format(logDate.content, unionName, dragonName, blood)
	end
	if logDate.id == 23 then
		local defenseUnionName = ""
		local dragonName = ""
		local attackUnionName = ""
		
		local dragonConfig = db:getUnionDragonConfigById(logInfo.tgtDragonId)
		if myConsortiaId == logInfo.myConsortiaId then
			defenseUnionName = "##N".."【"..(logInfo.tgtConsortiaName or "").."】"
			attackUnionName = "##K".."【"..(logInfo.myConsortiaName or "").."】"
			dragonName = "##N"..(dragonConfig.dragon_name or "")
		else
			defenseUnionName = "##K".."【"..(logInfo.tgtConsortiaName or "").."】"
			attackUnionName = "##N".."【"..(logInfo.myConsortiaName or "").."】"
			dragonName = "##K"..(dragonConfig.dragon_name or "")
		end

		realContent = string.format(logDate.content, defenseUnionName, dragonName, attackUnionName)
	end

	return realContent, tonumber(logInfo.createAt or 0)
end

-- 战报
function QUnionDragonWar:openUnionDragonWarFightReport(replayId)
    self:dragonWarGetHistoryBattleInfoRequest(replayId, function(data)
            local info = data.dragonWarGetHistoryBattleInfoResponse
            if info and info.battleInfo and next(info.battleInfo) then
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionDragonWarFightReport", 
                    options = {eventsInfo = info.battleEvents, fighterInfo = info.battleInfo}}, {isPopCurrentDialog = false})
            else
            	app.tip:floatTip("战报信息已过期")
            end
        end)
end

--段位
function QUnionDragonWar:getFloorTextureName(floor)
	if floor == nil then return nil, nil end

	local icon, num
    local config = db:getUnionDragonFloorInfoByFloor(floor)
    local floorIcon = string.split(config.dan_icon or "", "^")
    if floorIcon[1] then
    	icon = QResPath("dragon_war_floor_icon")[tonumber(floorIcon[1])]
    end
    if floorIcon[2] then
        num = QResPath("dragon_war_floor_num")[tonumber(floorIcon[2])]
    end
	return config.name, icon, num
end

function QUnionDragonWar:newDayUpdate()
	self._myInfo.todayAwardedHurtIds = {}
	self._myInfo.todayHurt = 0
	self._myInfo.todayMaxPerHurt = 0
	self:dispatchEvent({name = QUnionDragonWar.EVENT_UPDATE_MYINFO})
end

function QUnionDragonWar:checkCanFastBattle()
	local hurt = self:getMyInfo().todayMaxPerHurt or 0
	return hurt > 0
end

function QUnionDragonWar:encodeConsortiaWarLogsByType(param)
	if param == nil then return "" end

	local data = string.split(param, ";")
	local logInfo = {}
	for _, value in pairs(data) do
		local info = string.split(value, "=")
		logInfo[info[1]] = info[2]
	end
	
	return ""
end

function QUnionDragonWar:_dispatchAll()
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
-- DRAGON_WAR_GET_MY_INFO                      = 8201;                     //龙战-获取我的信息,DragonWarGetMyInfoRequest
-- DRAGON_WAR_BUY_FIGHT_COUNT                  = 8202;                     //龙战-购买战斗次数,DragonWarBuyFightCountRequest
-- DRAGON_WAR_GET_CURRENT_BATTLE_INFO          = 8205;                     //龙战-获取当前的对战信息和对战事件,DragonWarGetCurrentBattleInfoRequest
-- DRAGON_WAR_GET_HISTORY_BATTLE_LIST          = 8206;                     //龙战-获取历史的对战列表,DragonWarGetHistoryBattleListRequest
-- DRAGON_WAR_GET_HISTORY_BATTLE_INFO          = 8207;                     //龙战-获取历史的对战信息和对战事件,DragonWarGetHistoryBattleInfoRequest
-- DRAGON_WAR_GET_BATTLE_EVENTS                = 8208;                     //龙战-获取对战事件,DragonWarGetBattleEventsRequest
-- DRAGON_WAR_GET_FIGHT_HURT_LIST              = 8209;                     //龙战-获取公会成员龙战伤害排行,DragonWarGetFightHurtListRequest
-- DRAGON_WAR_GET_HOLY_STS_LIST                = 8210;                     //龙战-获取神圣祝福加成排行,DragonWarGetHolyStsListRequest
-- DRAGON_WAR_SET_USER_HOLY_STS                = 8211;                     //龙战-公会玩家设置武魂祝福状态,DragonWarSetUserHolyStsRequest
-- DRAGON_WAR_GET_TODAY_HURT_REWARD            = 8212;                     //龙战-领取每日伤害目标奖励,DragonWarGetTodayHurtRewardRequest
-- DRAGON_WAR_GET_DAILY_REWARD_LIST            = 8213;                     //龙战-获取日结算奖励列表,DragonWarGetDailyRewardListRequest
-- DRAGON_WAR_GET_DAILY_REWARD                 = 8214;                     //龙战-领取日结算奖励,DragonWarGetDailyRewardRequest
-- DRAGON_WAR_GET_WALL_INFO                    = 8215;                     //龙战-荣誉墙信息,DragonWarGetWallInfoRequest response DragonWarGetWallInfoResponse
------------------------------------------------------

function QUnionDragonWar:responseHandler(data, success, fail, succeeded)
	-- 获取我的信息
	if data.dragonWarGetMyInfoResponse then
		self:setMyInfo(data.dragonWarGetMyInfoResponse)
		if data.dragonWarGetMyInfoResponse.myConsortiaInfo then
			self:setMyDragonInfo(data.dragonWarGetMyInfoResponse.myConsortiaInfo)
		end
	end

	--购买战斗次数
	if data.dragonWarBuyFightCountResponse then
		self:setMyInfo(data.dragonWarBuyFightCountResponse)
		table.insert(self._dispatchList, QUnionDragonWar.EVENT_UPDATE_FIGHT_COUNT)
	end

	--获取当前的对战信息和对战事件
	if data.dragonWarGetCurrentBattleInfoResponse then
		self:setDragonInfo(data.dragonWarGetCurrentBattleInfoResponse)
	end

	--获取历史的对战列表
	if data.dragonWarGetHistoryBattleListResponse then
	end

	--获取历史的对战信息和对战事件
	if data.dragonWarGetHistoryBattleInfoResponse then
	end

	--获取对战事件
	if data.dragonWarGetBattleEventsResponse then
	end

	--公会玩家设置武魂祝福状态
	if data.dragonWarSetUserHolyStsResponse  then
		if data.dragonWarSetUserHolyStsResponse.myInfo  then
			self:setMyInfo(data.dragonWarSetUserHolyStsResponse)
		end
		if self._myDragonInfo ~= nil then
			self._myDragonInfo.holyCount = data.dragonWarSetUserHolyStsResponse.holyCount
		end
	end

	--获取公会成员龙战伤害排行
	if data.dragonWarGetTodayHurtRewardResponse then
		if data.dragonWarGetTodayHurtRewardResponse.myInfo then
			self:setMyInfo(data.dragonWarGetTodayHurtRewardResponse)
		end
	end

	--获取日结算奖励列表
	if data.dragonWarGetDailyRewardListResponse then
		self._dailyReward = data.dragonWarGetDailyRewardListResponse.dailyRewards or {}
		self._envRank = data.dragonWarGetDailyRewardListResponse.envRank or 1
		self._allRank = data.dragonWarGetDailyRewardListResponse.allRank or 2
		table.insert(self._dispatchList, QUnionDragonWar.EVENT_UPDATE_AWARD)
	end

	--领取日结算奖励
	if data.dragonWarGetDailyRewardResponse then
	end

	--荣誉墙
	if data.dragonWarGetWallInfoResponse then
	end

	-- 战斗结束
	if data.gfEndResponse and data.gfEndResponse.dragonWarFightEndResponse then
		self:setMyInfo(data.gfEndResponse.dragonWarFightEndResponse)
		self:setDragonInfo(data.gfEndResponse.dragonWarFightEndResponse)
	end

	-- 扫荡结束
	if data.gfQuickResponse and data.gfQuickResponse.dragonWarQuickFightResponse then
		self:setMyInfo(data.gfQuickResponse.dragonWarQuickFightResponse)
		self:setDragonInfo(data.gfQuickResponse.dragonWarQuickFightResponse)
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

-- DRAGON_WAR_GET_MY_INFO                      = 8201;                     //龙战-获取我的信息,DragonWarGetMyInfoRequest
function QUnionDragonWar:dragonWarGetMyInfoRequest(success, fail, status)
	local request = {api = "DRAGON_WAR_GET_MY_INFO"}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_MY_INFO", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_BUY_FIGHT_COUNT                  = 8202;                     //龙战-购买战斗次数,DragonWarBuyFightCountRequest
function QUnionDragonWar:dragonWarBuyFightCountRequest(success, fail, status)
	local request = {api = "DRAGON_WAR_BUY_FIGHT_COUNT"}
	app:getClient():requestPackageHandler("DRAGON_WAR_BUY_FIGHT_COUNT", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_CURRENT_BATTLE_INFO          = 8205;                     //龙战-获取当前的对战信息和对战事件,DragonWarGetCurrentBattleInfoRequest
function QUnionDragonWar:dragonWarGetCurrentBattleInfoRequest(success, fail, status, isHandlerError)
	local request = {api = "DRAGON_WAR_GET_CURRENT_BATTLE_INFO"}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_CURRENT_BATTLE_INFO", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end, nil, nil, isHandlerError)
end

-- DRAGON_WAR_GET_HISTORY_BATTLE_LIST          = 8206;                     //龙战-获取历史的对战列表,DragonWarGetHistoryBattleListRequest
function QUnionDragonWar:dragonWarGetHistoryBattleListRequest(success, fail, status)
	local request = {api = "DRAGON_WAR_GET_HISTORY_BATTLE_LIST"}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_HISTORY_BATTLE_LIST", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_HISTORY_BATTLE_INFO          = 8207;                     //龙战-获取历史的对战信息和对战事件,DragonWarGetHistoryBattleInfoRequest
function QUnionDragonWar:dragonWarGetHistoryBattleInfoRequest(matchingId, success, fail, status)
	local dragonWarGetHistoryBattleInfoRequest = {matchingId = matchingId}
	local request = {api = "DRAGON_WAR_GET_HISTORY_BATTLE_INFO", dragonWarGetHistoryBattleInfoRequest = dragonWarGetHistoryBattleInfoRequest}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_HISTORY_BATTLE_INFO", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end


-- DRAGON_WAR_GET_BATTLE_EVENTS                = 8208;                     //龙战-获取对战事件,DragonWarGetBattleEventsRequest
function QUnionDragonWar:dragonWarGetBattleEventsRequest(matchingId, startCount, success, fail, status)
	local dragonWarGetBattleEventsRequest = {matchingId = matchingId, startCount = startCount}
	local request = {api = "DRAGON_WAR_GET_BATTLE_EVENTS", dragonWarGetBattleEventsRequest = dragonWarGetBattleEventsRequest}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_BATTLE_EVENTS", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_FIGHT_HURT_LIST              = 8209;                     //龙战-获取公会成员龙战伤害排行,DragonWarGetFightHurtListRequest
function QUnionDragonWar:dragonWarGetFightHurtListRequest(success, fail)
	local request = {api = "DRAGON_WAR_GET_FIGHT_HURT_LIST"}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_FIGHT_HURT_LIST", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_HOLY_STS_LIST                = 8210;                     //龙战-获取神圣祝福加成排行,DragonWarGetHolyStsListRequest
function QUnionDragonWar:dragonWarGetHolyStsListRequest(success, fail)
	local request = {api = "DRAGON_WAR_GET_HOLY_STS_LIST"}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_HOLY_STS_LIST", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_SET_USER_HOLY_STS                = 8211;                     //龙战-公会玩家设置武魂祝福状态,DragonWarSetUserHolyStsRequest
function QUnionDragonWar:dragonWarSetUserHolyStsRequest(memberId, success, fail)
	local dragonWarSetUserHolyStsRequest = {memberId = memberId}
	local request = {api = "DRAGON_WAR_SET_USER_HOLY_STS", dragonWarSetUserHolyStsRequest = dragonWarSetUserHolyStsRequest}
	app:getClient():requestPackageHandler("DRAGON_WAR_SET_USER_HOLY_STS", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_TODAY_HURT_REWARD            = 8212;                     //龙战-领取每日伤害目标奖励,DragonWarGetTodayHurtRewardRequest
function QUnionDragonWar:dragonWarGetTodayHurtRewardRequest(rewardIds, success, fail)
	local dragonWarGetTodayHurtRewardRequest = {rewardIds = rewardIds}
	local request = {api = "DRAGON_WAR_GET_TODAY_HURT_REWARD", dragonWarGetTodayHurtRewardRequest = dragonWarGetTodayHurtRewardRequest}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_TODAY_HURT_REWARD", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_DAILY_REWARD_LIST            = 8213;                     //龙战-获取日结算奖励列表,DragonWarGetDailyRewardListRequest
function QUnionDragonWar:dragonWarGetDailyRewardListRequest(success, fail)
	local request = {api = "DRAGON_WAR_GET_DAILY_REWARD_LIST"}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_DAILY_REWARD_LIST", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_DAILY_REWARD                 = 8214;                     //龙战-领取日结算奖励,DragonWarGetDailyRewardRequest
function QUnionDragonWar:dragonWarGetDailyRewardRequest(rewardId, success, fail)
	local dragonWarGetDailyRewardRequest = {rewardId = rewardId}
	local request = {api = "DRAGON_WAR_GET_DAILY_REWARD", dragonWarGetDailyRewardRequest = dragonWarGetDailyRewardRequest}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_DAILY_REWARD", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

-- DRAGON_WAR_GET_WALL_INFO                    = 8215;                     //龙战-荣誉墙信息,DragonWarGetWallInfoRequest response DragonWarGetWallInfoResponse
function QUnionDragonWar:dragonWarGetWallInfoRequest(success, fail)
	local dragonWarGetWallInfoRequest = {}
	local request = {api = "DRAGON_WAR_GET_WALL_INFO", dragonWarGetWallInfoRequest = dragonWarGetWallInfoRequest}
	app:getClient():requestPackageHandler("DRAGON_WAR_GET_WALL_INFO", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

--[[
	龙战战斗开始
]]
function QUnionDragonWar:dragonWarFightStartRequest(battleFormation, success, fail, status)
	local gfStartRequest = {battleType = BattleTypeEnum.DRAGON_WAR, battleFormation = battleFormation}
	local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
	app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

--[[
	龙战战斗结束
]]
function QUnionDragonWar:dragonWarFightEndRequest(hurt, battleKey, isWin, success, fail, status)
	local dragonWarFightEndRequest = {matchingId = self._dragonFighter.matchingId, hurt = hurt}
	local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    dragonWarFightEndRequest.battleVerify = q.battleVerifyHandler(battleKey)

    local gfEndRequest = {battleType = BattleTypeEnum.DRAGON_WAR, dragonWarFightEndRequest = dragonWarFightEndRequest, 
    	battleVerify = dragonWarFightEndRequest.battleVerify, isQuick = false, fightReportData = fightReportData}
	local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
	app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

--[[
	龙战扫荡
]]
function QUnionDragonWar:dragonWarFastBattleRequest(battleType, success, fail)
	local gfQuickRequest = {battleType = battleType}
	local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
	app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function(response)
			self:responseHandler(response, success, nil, true, kind)
		end,
		function(response)
			self:responseHandler(response, nil, fail, nil, kind)
		end)
end

return QUnionDragonWar