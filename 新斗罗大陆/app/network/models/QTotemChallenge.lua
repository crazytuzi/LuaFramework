-- @Author: xurui
-- @Date:   2019-12-25 15:39:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-14 16:41:24
local QBaseModel = import("...models.QBaseModel")
local QTotemChallenge = class("QTotemChallenge", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")

-- QTotemChallenge.MAX_DUNGEON_NUM = 7  --每一层最大关卡数量 ps:这个参数废弃不用，圣柱二期优化修改了量表结构
QTotemChallenge.MAX_FLOOR_NUM = 3  --最大层数量
QTotemChallenge.RESETTIME_WEEKDAY = 2  --赛季重置对应周天数
QTotemChallenge.RESETTIME_HOUR = 5  --赛季重置对应小时数
QTotemChallenge.HARD_TYPE = 2 -- 困难模式
QTotemChallenge.NORMAL_TYPE = 1 -- 普通模式
QTotemChallenge.NO_TYPE = 0 -- 还没选择

QTotemChallenge.NO_ID = 9999999 -- 未知的关卡

QTotemChallenge.UPDATE_RESET_TIME_STR = "UPDATE_RESET_TIME_STR"  --更新刷新时间字段
QTotemChallenge.UPDATE_EVENT = "QTOTEMCHALLENGE.UPDATE_EVENT"  --选择模式之后刷新一下界面
QTotemChallenge.UPDATE_ACHIEVEMENT_EVENT = "UPDATE_ACHIEVEMENT_EVENT" --更新圣柱成就
function QTotemChallenge:ctor(options)
	QTotemChallenge.super.ctor(self, options)

	self._totemChallengeConfigDict = {}        	--关卡配置信息，二维数组[floor][id]
	self._idConfigDict = {}                 	--关卡配置信息，一维数组[id]
	self._hardModelFloorDict = {}               --拥有困难模式的层级
	self._totemChallengeRewardDict = {}			--关卡奖励配置信息
	self._totemChallengeFloorRewardDict = {}    --层级奖励配置信息
	self._totemChallengeInfoDict = {} 			--当前玩家关卡信息
	self._totemChallengeRivalsList = {}  		--当前层对手列表
	self._totemChallengeWeekAwards = {}			--周奖励信息
	self._totemChallengeFloorAwards = {}		--层通关奖励信息
end

function QTotemChallenge:didappear()
	
end

function QTotemChallenge:disappear()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end
end

function QTotemChallenge:loginEnd(success)
	if self:checkTotemChallengeUnlock() then
		self:requestTotemChallengeMyInfo(function()
			self:createResetTimeScheduler()
			if success then
				success()
			end
		end)
	else
		if success then
			success()
		end
	end
end

function QTotemChallenge:openDialog(isTutoria)
	if self:checkTotemChallengeUnlock(true) then
		self:requestTotemChallengeMainInfo(function ()
			local recordManager = app:getUserOperateRecord()
			recordManager:setRecordByType(recordManager.RECORD_TYPES.TOTEMCHALLENGE_FIGHT_TIME, q.serverTime())
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTotemChallengeMain"},{isPopCurrentDialog = false})
			if isTutoria then
				QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_TOTEMCHALLEGENGE_CLOSE})
			end
		end)
	end
end

function QTotemChallenge:checkTotemChallengeUnlock(isTip)
	if app.unlock:checkLock("UNLOCK_SHENGZHUTIAOZHAN", isTip) then
		return true
	end

	return false
end


function QTotemChallenge:getRefreshCost()
	local times=self._refreshRivalsCount or 0
	local config,isCanRefresh = QStaticDatabase:sharedDatabase():getTokenConsume("shengzhu_fresh", times+1)

	return config.money_num or 0,isCanRefresh
	
end


function QTotemChallenge:checkTips()
	if self:checkTotemChallengeUnlock() == false then return false end

	local recordManager = app:getUserOperateRecord()
	local lastEnterTime = recordManager:getRecordByType(recordManager.RECORD_TYPES.TOTEMCHALLENGE_FIGHT_TIME)
	if lastEnterTime == nil then return true end
	
	local resetTime = self:getResetTime()
	local startTime = resetTime - (7 * DAY)
	if lastEnterTime < startTime then
		return true
	end
	return false
end

function QTotemChallenge:checkStoreTips()
	if self:checkTotemChallengeUnlock() == false then return false end

	if remote.stores:checkFuncShopRedTips(SHOP_ID.godarmShop) then
		return true
	end
	return false
end

function QTotemChallenge:createResetTimeScheduler()
	if self._countdownSchedule then
		scheduler.unscheduleGlobal(self._countdownSchedule)
		self._countdownSchedule = nil
	end

	local resetTime = self:getResetTime()

	local setTimeStrFunc = function ( ... )
	  	local timeStr = q.timeToDayHourMinute(resetTime - q.serverTime())
		self:dispatchEvent({name = QTotemChallenge.UPDATE_RESET_TIME_STR, timeStr = timeStr})
	end

	if resetTime - q.serverTime() > 0 then
		self._countdownSchedule = scheduler.scheduleGlobal(function (  )
			if resetTime - q.serverTime() >= 0 then
				setTimeStrFunc()
			else
				if self._countdownSchedule then
					scheduler.unscheduleGlobal(self._countdownSchedule)
					self._countdownSchedule = nil
				end
				self:requestTotemChallengeMainInfo(function()
					self:createResetTimeScheduler()
					self:dispatchEvent({name = QTotemChallenge.UPDATE_RESET_TIME_STR, isReset = true})
				end)
			end
		end, 1)
		setTimeStrFunc()
	end
end

function QTotemChallenge:getResetTime()
	local resetTime = 0
	local curDate = q.date("*t", q.serverTime())
	local offsetDay = 0
	if curDate.wday > self.RESETTIME_WEEKDAY or (curDate.wday == self.RESETTIME_WEEKDAY and curDate.hour >= self.RESETTIME_HOUR) then
		offsetDay = 7
	end
	curDate.day = curDate.day + self.RESETTIME_WEEKDAY - curDate.wday + offsetDay
	curDate.hour = self.RESETTIME_HOUR
	curDate.min = 0
	curDate.sec = 2
	resetTime = q.OSTime(curDate)

	return resetTime
end

function QTotemChallenge:setDungeonPassRivalPos(rivalPos)
	self._passDungeonRivalPos = rivalPos
end

function QTotemChallenge:getDungeonPassRivalPos()
	return self._passDungeonRivalPos
end

------------------ database ------------------

function QTotemChallenge:getDungeonConfigByLevel(floor)
	if floor == nil then return end
	if q.isEmpty(self._totemChallengeConfigDict[tostring(floor)]) then
		local configs = db:getStaticByName("shengzhutiaozhan_level")
		local floorConfig = configs[tostring(floor)]
		if floorConfig then
			self._totemChallengeConfigDict[tostring(floor)] = {}
			for _, value in pairs(floorConfig) do
				if value.type == self.HARD_TYPE then
					self._hardModelFloorDict[tostring(floor)] = true
				end
				self._totemChallengeConfigDict[tostring(floor)][tostring(value.id)] = value
			end
		end
	end
	
	return self._totemChallengeConfigDict[tostring(floor)]
end

function QTotemChallenge:getDungeonConfigByFloorAndId(floor, id)
	local config = {}
	if floor == nil or id == nil then return config end

	local levelConfig = self:getDungeonConfigByLevel(floor) or {}
	
	return levelConfig[tostring(id)] or {}
end

function QTotemChallenge:getDungeonConfigById(id)
	if not id then return end

	if q.isEmpty(self._idConfigDict[tostring(id)]) then
		local configs = db:getStaticByName("shengzhutiaozhan_level")
		for _, floorConfig in pairs(configs) do
			for _, value in pairs(floorConfig) do
				if value.type == self.HARD_TYPE then
					self._hardModelFloorDict[tostring(value.level)] = true
				end
				self._idConfigDict[tostring(value.id)] = value
			end
		end
	end

	return self._idConfigDict[tostring(id)]
end

-- 判断该层级有没有困难模式
function QTotemChallenge:hasHardModelByFloor(floor)
	return self._hardModelFloorDict[tostring(floor)]
end

function QTotemChallenge:getAwardConfigDict()
	if q.isEmpty(self._totemChallengeRewardDict) then
		self._totemChallengeRewardDict = db:getStaticByName("shengzhutiaozhan_reward")
	end

	return self._totemChallengeRewardDict
end

function QTotemChallenge:getDungeonRewardConfigById(id)
	local config = {}
	if id == nil then return config end

	local totemChallengeRewardDict = self:getAwardConfigDict()

	local teamLevel = remote.user.level or 1
	local data = totemChallengeRewardDict[tostring(id)] or {}
	for _, value in pairs(data) do
		if teamLevel >= tonumber(value.rewardminpower) and teamLevel <= tonumber(value.rewardmaxpower) then
			config = value
			break
		end
	end
	
	return config
end


function QTotemChallenge:getFloorRewardConfigByFloor(floor)
	local teamLevel = remote.user.level or 1
	if self._totemChallengeFloorRewardDict[tostring(floor)] then 
		local chooseType = self:getTotemUserDungeonInfo().intoLayer and self:getTotemUserDungeonInfo().intoLayer ~= self.NO_TYPE and self:getTotemUserDungeonInfo().intoLayer or self.NORMAL_TYPE
		local data = self._totemChallengeFloorRewardDict[tostring(floor)][tostring(chooseType)] or {}
		for _, value in pairs(data) do
			if teamLevel >= tonumber(value.rewardminpower) and teamLevel <= tonumber(value.rewardmaxpower) then
				return value
			end
		end
	end

	local config = {}
	if floor == nil then return config end

	local totemChallengeRewardDict = self:getAwardConfigDict()

	for _, config in pairs(totemChallengeRewardDict) do
		if config[1].chapter_reward then
			local _config = self:getDungeonConfigById(config[1].id)
			if _config then
				if not self._totemChallengeFloorRewardDict[tostring(_config.level)] then
					self._totemChallengeFloorRewardDict[tostring(_config.level)] = {}
				end
				self._totemChallengeFloorRewardDict[tostring(_config.level)][tostring(_config.type)] = config
			end
		end
	end

	local chooseType = self:getTotemUserDungeonInfo().intoLayer and self:getTotemUserDungeonInfo().intoLayer ~= self.NO_TYPE and self:getTotemUserDungeonInfo().intoLayer or self.NORMAL_TYPE
	local data = self._totemChallengeFloorRewardDict[tostring(floor)][tostring(chooseType)] or {}
	for _, value in pairs(data) do
		if teamLevel >= tonumber(value.rewardminpower) and teamLevel <= tonumber(value.rewardmaxpower) then
			config = value
			break
		end
	end
	
	return config
end

function QTotemChallenge:getBuffConfigById(bufferId)
	local config = db:getStaticByName("shengzhutiaozhan_rule") or {}

	return config[tostring(bufferId)] or {}
end

----------------------- server --------------------------

function QTotemChallenge:getTotemUserDungeonInfo()
	return self._totemChallengeInfoDict
end

--[[
/**
 * 圣柱挑战--对手信息
 */
message TotemChallengeRivalUserInfo {
    optional int32 rivalPos = 1; //对手关卡编号
    optional string nickname = 2; //昵称
    optional int32 defaultActorId = 3; //默认魂师Id
    optional int32 defaultSkinId = 4; //默认皮肤Id
    optional int64 force = 5; //对手战斗力
    optional bool isPass = 6; //是否通关
    repeated HeroInfo mainHeros=7;//英雄ID+战斗力
}
]]
function QTotemChallenge:getTotemChallengeRivals()
	return self._totemChallengeRivalsList
end

function QTotemChallenge:getTotemChallengeRivalsByrivalPos(rivalPos)
	for k,v in pairs(self._totemChallengeRivalsList or {}) do
		if v.rivalPos == rivalPos then
			return clone(v or {})
		end
	end
	return nil
end

--[[
/**
 * 圣柱挑战--周结算信息
 */
message TotemChallengeWeekEndRewardInfo {
    optional int32 rivalPos = 1; //最高通关对手编号
    optional string reward = 2; //奖励
    optional int32 dateYmd = 3; //奖励日期
}
]]
function QTotemChallenge:setTotemChallengeWeekAward(awardInfo)
	self._totemChallengeWeekAwards = awardInfo
end

function QTotemChallenge:getTotemChallengeWeekAward()
	return self._totemChallengeWeekAwards
end

function QTotemChallenge:setTotemChallengeFloorAward(awardInfo)
	self._totemChallengeFloorAwards = awardInfo
end

function QTotemChallenge:getTotemChallengeFloorAward()
	return self._totemChallengeFloorAwards
end

function QTotemChallenge:getTotemChallengeRivalsCount()
	local maxRefresh = db:getConfigurationValue("SHENGZHU_FRESH_TIMES")
	return maxRefresh - self._refreshRivalsCount or 0
end

function QTotemChallenge:updateTotemChallengeRivalsListByNewData(rival)

	local oldRivalsList = clone(self._totemChallengeRivalsList or {})
	self._totemChallengeRivalsList = {}

	for k,v in pairs(oldRivalsList or {}) do
		if v.rivalPos == rival.rivalPos then
			table.insert(self._totemChallengeRivalsList, rival)
		else
			table.insert(self._totemChallengeRivalsList, v)
		end
	end
end

--[[
/**
 * 圣柱挑战--进入信息
 */
message TotemChallengeGetInfoResponse {
    optional int32 stairsNum = 1; //层级
    repeated TotemChallengeRivalUserInfo rivals = 2; //对手列表
    optional TotemChallengeWeekEndRewardInfo rewardInfo = 3;//周奖励信息 getInfo
}
]]
function QTotemChallenge:updateTotemChallengeInfo(data)
	if data.rivalPosHistoryMax then
		-- 后面的判断需要用到
		self._totemChallengeInfoDict.rivalPosHistoryMax = data.rivalPosHistoryMax
	end

	if data.intoLayer then
		self._totemChallengeInfoDict.intoLayer = data.intoLayer
	end

	if data.stairsNum then
		self:_calculateCurInfo(data.stairsNum)
		self._totemChallengeInfoDict.fightSuccessCount = data.fightSuccessCount or 0
		self._totemChallengeInfoDict.team1IsQuickPass = data.team1IsQuickPass
		self._totemChallengeInfoDict.team2IsQuickPass = data.team2IsQuickPass
		self._totemChallengeInfoDict.stairsNum = data.stairsNum
		self._totemChallengeInfoDict.hardCount = data.hardCount or 0
		QKumo(self._totemChallengeInfoDict)
	end
	if data.rivals then
		self._totemChallengeRivalsList = data.rivals
	end
	if data.rewardInfo then
		self:setTotemChallengeWeekAward(data.rewardInfo)
	end
	if data.stairsPassReward then
		self:setTotemChallengeFloorAward(data.stairsPassReward)
	end
	if data.refreshRivalsCount then
		self._refreshRivalsCount = data.refreshRivalsCount
	end

	self:dispatchEvent({name = QTotemChallenge.UPDATE_ACHIEVEMENT_EVENT})
end

function QTotemChallenge:checkUnlockModelChooseByFloor( floor )
	if self._totemChallengeInfoDict and self._totemChallengeInfoDict.rivalPosHistoryMax then
		local historyMaxId = tonumber(self._totemChallengeInfoDict.rivalPosHistoryMax)

		if not self._isUnlockModelChoose then
			self._isUnlockModelChoose = {}
		end
		if self._lastRivalPosHistoryMax and self._lastRivalPosHistoryMax == historyMaxId then
			return floor and self._isUnlockModelChoose[tostring(floor)] or false
		end

		local _floor = 1
		while true do
			local floorConfig = self:getDungeonConfigByLevel(_floor)
			if floorConfig then
				local hasHardModel = self:hasHardModelByFloor(_floor)
				if hasHardModel then
					local lastNormalWave = 1
					local lastNormalId = 0
					for _, config in pairs(floorConfig) do
						if tonumber(config.wave) > lastNormalWave and tonumber(config.type) == self.NORMAL_TYPE then
							lastNormalWave = tonumber(config.wave)
							lastNormalId = tonumber(config.id)
						end
					end
					if historyMaxId >= lastNormalId then
						self._isUnlockModelChoose[tostring(_floor)] = true
					end
				end
				_floor = _floor + 1
			else
				break
			end
		end

		self._lastRivalPosHistoryMax = historyMaxId
		return floor and self._isUnlockModelChoose[tostring(floor)] or false
	else
		return false
	end
end

function QTotemChallenge:updateTotemChallengeRefresh(data)
	if data.rival then
		self:updateTotemChallengeRivalsListByNewData(data.rival)
	end
	if data.refreshRivalsCount then
		self._refreshRivalsCount = data.refreshRivalsCount
	end
end
----------------------- request --------------------------

function QTotemChallenge:responseDataHandler(data, success, fail, succeeded)
	if data.totemChallengeGetInfoResponse then
		self:updateTotemChallengeInfo(data.totemChallengeGetInfoResponse)
	end
	if data.totemChallengeFightEndResponse then
		self:updateTotemChallengeInfo(data.totemChallengeFightEndResponse)
	end
	if data.gfQuickResponse and data.gfQuickResponse.totemChallengeFightEndResponse then
		self:updateTotemChallengeInfo(data.gfQuickResponse.totemChallengeFightEndResponse)
	end
	if data.totemChallengeRefreshResponse then
		self:updateTotemChallengeRefresh(data.totemChallengeRefreshResponse)
	end

	if data.api == "TOTEM_CHALLENGE_INTO_LAYER" then
		self:dispatchEvent({name = QTotemChallenge.UPDATE_EVENT})
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	查询自己信息协议请求
]]
function QTotemChallenge:requestTotemChallengeMyInfo(success, fail, status)
    local request = {api = "TOTEM_CHALLENGE_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--[[
	查询完整信息协议请求
]]
function QTotemChallenge:requestTotemChallengeMainInfo(success, fail, status)
    local request = {api = "TOTEM_CHALLENGE_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--[[
	查询对手信息协议请求
	required int32 rivalPos = 1; //对手关卡编号
]]
function QTotemChallenge:requestTotemChallengeFighterInfo(rivalPos, success, fail, status)
	local totemChallengeQueryFighterRequest = {rivalPos = rivalPos}
    local request = {api = "TOTEM_CHALLENGE_QUERY_FIGHTER", totemChallengeQueryFighterRequest = totemChallengeQueryFighterRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function(response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--[[
	领取周结算奖励
	optional int32 dateYmd = 1; //奖励日期
]]
function QTotemChallenge:requestTotemChallengeWeekAwards(dateYmd, success, fail, status)
	local totemChallengeGetWeekEndRewardRequest = {dateYmd = dateYmd}
    local request = {api = "TOTEM_CHALLENGE_GET_WEEK_REWARD", totemChallengeGetWeekEndRewardRequest = totemChallengeGetWeekEndRewardRequest}
    app:getClient():requestPackageHandler(request.api, request, function(response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end


--[[
	刷新对手信息协议请求
]]
function QTotemChallenge:requestTotemChallengeRefresh(success, fail, status)
    local request = {api = "TOTEM_CHALLENGE_REFRESH"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end


function QTotemChallenge:requestTotemChallengeFightStartRequest(rivalPos, battleFormation1, battleFormation2, success, fail)
    local totemChallengeFightStartCheckRequest = {rivalPos = rivalPos}
    local gfStartRequest = {battleType = BattleTypeEnum.TOTEM_CHALLENGE, battleFormation = battleFormation1, battleFormation2 = battleFormation2,
    						 totemChallengeFightStartCheckRequest = totemChallengeFightStartCheckRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, success, fail)
end

--战斗结算
function QTotemChallenge:requestTotemChallengeFightEndRequest(rivalPos, battleKey, battleFormation1, battleFormation2, success, fail)
    local totemChallengeFightEndRequest = {rivalPos = rivalPos, fightResult = fightResult, damages = verifyDamages}
    local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    local battleVerify = q.battleVerifyHandler(battleKey)
    local gfEndRequest = {battleType = BattleTypeEnum.TOTEM_CHALLENGE, battleVerify = battleVerify, isQuick = false, isWin = nil,
                         fightReportData = fightReportData, totemChallengeFightEndRequest = totemChallengeFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation1, battleFormation2 = battleFormation2}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function(response)

		remote.user:addPropNumForKey("todayTotemChallengeFightCount")--记录今日圣柱挑战战斗次数
		local donotRefresh = false
    	if  rivalPos then
			local config = self:getDungeonConfigByLevel(1)
			if config and config[tostring(rivalPos)] and not config[tostring(tonumber(rivalPos) + 1)] then
				local scoreList = response.gfEndResponse.totemChallengeFightEndResponse and response.gfEndResponse.totemChallengeFightEndResponse.scoreList or {}
			    local heroScore, enemyScore = 0, 0
			    for _, score in ipairs(scoreList or {}) do 
			        if score then
			            heroScore = heroScore + 1
			        else
			            enemyScore = enemyScore + 1
			        end
			    end
			    local isWin = heroScore >= 2 and true or false
			    if isWin then
	    			remote.user:addPropNumForKey("todayTotemChallengeChapterCount")--记录今日圣柱挑战通关第一层
	    		else
	    			donotRefresh = true
			    end
		   	end
    	end

    	if donotRefresh then
    		-- 神罚一队，然后战斗失败（不走快速战斗，跳过战斗），由于后端的totemChallengeFightEndResponse结构里没有team1IsQuickPass、team2IsQuickPass字段，所以会导致战斗失败之后，前端会刷新掉神罚的状态。
    		-- 然后和澎湃沟通了一下，后端不太方便加这个字段，那么前端在这里判断一下，如果战斗失败，则用现有的神罚状态继续保留。
    		if response.gfEndResponse and response.gfEndResponse.totemChallengeFightEndResponse then
    			if response.gfEndResponse.totemChallengeFightEndResponse.team1IsQuickPass == nil then
    				response.gfEndResponse.totemChallengeFightEndResponse.team1IsQuickPass = self._totemChallengeInfoDict.team1IsQuickPass
    			end
    			if response.gfEndResponse.totemChallengeFightEndResponse.team2IsQuickPass == nil then
    				response.gfEndResponse.totemChallengeFightEndResponse.team2IsQuickPass = self._totemChallengeInfoDict.team2IsQuickPass
    			end
    		end
    	end

    	self:responseDataHandler(response.gfEndResponse, success, nil, true)
	end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

-- TOTEM_CHALLENGE_INTO_LAYER                      = 10150;                    //圣柱挑战模式选择 TotemChallengeIntoLayerRequest TotemChallengeGetInfoResponse
-- TOTEM_CHALLENGE_SET_TEAM_QUICK_PASS             = 10151;                    //圣柱挑战模式选择 TotemChallengeTeamSetQuickPass
--[[
	圣柱挑战模式选择
	optional int32 intoLayer = 1; //选择进入的是什么模式 0 表示普通进入第三层  1表示困难进入第四层
]]
function QTotemChallenge:requestTotemChallengeIntoLayer(intoLayer, success, fail, status)
	local totemChallengeIntoLayerRequest = {intoLayer = intoLayer}
    local request = {api = "TOTEM_CHALLENGE_INTO_LAYER", totemChallengeIntoLayerRequest = totemChallengeIntoLayerRequest}
    app:getClient():requestPackageHandler(request.api, request, function(response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--[[
	神罚
	optional bool team1QuickPass = 1;//一小队神罚
	optional bool team2QuickPass = 2;//二小队神罚
]]
function QTotemChallenge:requestTotemChallengeSetQuickPass(team1QuickPass, team2QuickPass, success, fail, status)
	local totemChallengeTeamSetQuickPassRequest = {team1QuickPass = team1QuickPass, team2QuickPass = team2QuickPass}
    local request = {api = "TOTEM_CHALLENGE_SET_TEAM_QUICK_PASS", totemChallengeTeamSetQuickPassRequest = totemChallengeTeamSetQuickPassRequest}
    app:getClient():requestPackageHandler(request.api, request, function(response)
    	local totemUserDungeonInfo = self:getTotemUserDungeonInfo()
    	if totemUserDungeonInfo then
    		if team1QuickPass then
    			totemUserDungeonInfo.team1IsQuickPass = true
    		end
    		if team2QuickPass then
    			totemUserDungeonInfo.team2IsQuickPass = true
    		end
    	end
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end


--[[
    全部神罚，跳过战斗
    message TotemChallengeQuickFightRequest {
	    required int32 rivalPos = 1; //对手关卡编号
	}

]]
function QTotemChallenge:responsFightQuickPass(rivalPos, success, fail)
    local totemChallengeQuickFightRequest = {rivalPos = rivalPos}
    local gfQuickRequest = {battleType = BattleTypeEnum.TOTEM_CHALLENGE, totemChallengeQuickFightRequest = totemChallengeQuickFightRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function (response)
        self:responseDataHandler(response, success, nil, true)
    end, function (response)
        self:responseDataHandler(response, nil, fail)
    end)
end

--判断当前是否是困难难度
function QTotemChallenge:checkIsHardType()
	if self._totemChallengeInfoDict and self._totemChallengeInfoDict.intoLayer == self.HARD_TYPE then
		return true
	end
	return false
end


function QTotemChallenge:_calculateCurInfo(passId)
	print("QTotemChallenge:_calculateCurInfo() passId = ", passId)
	local passConfig = self:getDungeonConfigById(passId)
	if not q.isEmpty(passConfig) then
		local passFloor = passConfig.level
		local passWave = passConfig.wave
		local curConfig = self:getDungeonConfigById(passId + 1)
		if not q.isEmpty(curConfig) then
			local curFloor = curConfig.level
			local curWave = curConfig.wave
			if curFloor == passFloor then
				-- 没有晋级层级
				if curWave > passWave then
					-- 同层过关
					self._totemChallengeInfoDict.currentFloor = curFloor
					self._totemChallengeInfoDict.currentDungeon = curWave
					self._totemChallengeInfoDict.totalNum = curConfig.id
				else
					-- 本层有普通困难2个级别（量表配置困难衔接在普通后面），这种情况则视为本层通关
					curFloor = passFloor + 1
					local floorConfig = self:getDungeonConfigByLevel(curFloor)
					if not q.isEmpty(floorConfig) then
						-- 有下一个层级
						if self:checkUnlockModelChooseByFloor(curFloor) then
							if self._totemChallengeInfoDict.intoLayer == nil or self._totemChallengeInfoDict.intoLayer == self.NO_TYPE then
								-- 未选择
								self._totemChallengeInfoDict.currentFloor = passFloor
								self._totemChallengeInfoDict.currentDungeon = passWave
								self._totemChallengeInfoDict.totalNum = self.NO_ID -- id
							else
								for _, config in pairs(floorConfig) do
									if config.wave == 1 and tonumber(config.type) == tonumber(self._totemChallengeInfoDict.intoLayer) then
										self._totemChallengeInfoDict.currentFloor = curFloor
										self._totemChallengeInfoDict.currentDungeon = 1
										self._totemChallengeInfoDict.totalNum = config.id
										break
									end
								end
							end
						else
							-- 进入下一层普通第一关
							for _, config in pairs(floorConfig) do
								if config.wave == 1 and tonumber(config.type) == self.NORMAL_TYPE then
									self._totemChallengeInfoDict.currentFloor = curFloor
									self._totemChallengeInfoDict.currentDungeon = 1
									self._totemChallengeInfoDict.totalNum = config.id
									return
								end
							end
						end
					else
						-- 没有下一个层级的配置，比如3-7（21）通关
						self._totemChallengeInfoDict.currentFloor = passFloor
						self._totemChallengeInfoDict.currentDungeon = passWave
						self._totemChallengeInfoDict.totalNum = self.NO_ID
					end
				end
			else
				-- 晋级下一层级
				local floorConfig = self:getDungeonConfigByLevel(curFloor)
				if self:checkUnlockModelChooseByFloor(curFloor) then
					if self._totemChallengeInfoDict.intoLayer == nil or self._totemChallengeInfoDict.intoLayer == self.NO_TYPE then
						-- 未选择
						self._totemChallengeInfoDict.currentFloor = passFloor
						self._totemChallengeInfoDict.currentDungeon = passWave
						self._totemChallengeInfoDict.totalNum = self.NO_ID -- id
					else
						for _, config in pairs(floorConfig) do
							if config.wave == 1 and tonumber(config.type) == tonumber(self._totemChallengeInfoDict.intoLayer) then
								self._totemChallengeInfoDict.currentFloor = curFloor
								self._totemChallengeInfoDict.currentDungeon = 1
								self._totemChallengeInfoDict.totalNum = config.id
								break
							end
						end
					end
				else
					-- 进入下一层普通第一关
					for _, config in pairs(floorConfig) do
						if config.wave == 1 and tonumber(config.type) == self.NORMAL_TYPE then
							self._totemChallengeInfoDict.currentFloor = curFloor
							self._totemChallengeInfoDict.currentDungeon = 1
							self._totemChallengeInfoDict.totalNum = config.id
							return
						end
					end
				end
			end
		else
			-- 全部通关，比如3-7（28）通关
			self._totemChallengeInfoDict.currentFloor = passFloor
			self._totemChallengeInfoDict.currentDungeon = passWave
			self._totemChallengeInfoDict.totalNum = self.NO_ID -- id
		end
	elseif passId == 0 then
		-- 第一关
		self._totemChallengeInfoDict.currentFloor = 1
		self._totemChallengeInfoDict.currentDungeon = 1
		self._totemChallengeInfoDict.totalNum = 1
	end
end

return QTotemChallenge