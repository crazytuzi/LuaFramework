-- @Author: xurui
-- @Date:   2016-10-26 11:23:43
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-04-26 17:01:33
local QBaseModel = import("...models.QBaseModel")
local QWorldBoss = class("QWorldBoss", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")

QWorldBoss.AWARDS_IS_READY = 1         		-- 奖励可领取
QWorldBoss.AWARDS_IS_NONE = 2        	 	-- 奖励未领取
QWorldBoss.AWARDS_IS_DONE = 3        	 	-- 奖励已领取

QWorldBoss.UPDATE_WORLDBOSS_INFO = "UPDATE_WORLDBOSS_INFO"
QWorldBoss.SEND_WORLDBOSS_KILL_INFO = "SEND_WORLDBOSS_KILL_INFO"
QWorldBoss.UPDATE_WORLDBOSS_AWARDS_INFO = "UPDATE_WORLDBOSS_AWARDS_INFO"
QWorldBoss.UPDATE_WORLDBOSS_BUY_COUNT = "UPDATE_WORLDBOSS_BUY_COUNT"

function QWorldBoss:ctor()
	QWorldBoss.super.ctor(self)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._bossInfo = {}
	self._logs = {}	

	self._unlockTime = {}     	-- 世界boss开始挑战时间
	self._lockTime = {}			-- 世界boss结束挑战时间

	-- 世界boss奖励信息
	self._awardsInfos = {}        -- 1是荣耀奖励, 2是伤害奖励

	self._rankInfo = {}
end

function QWorldBoss:didappear()
	QWorldBoss.super.didappear(self)
end

function QWorldBoss:disappear()
	QWorldBoss.super.disappear(self)
end

function QWorldBoss:loginEnd()
	if app.unlock:getUnlockWorldBoss() then
		self:requestWorldBossInfo()
	end
end

function QWorldBoss:setWorldBossInfo(bossInfo)
	if bossInfo == nil then return end

	bossInfo.isShow = true
	if bossInfo.startAt then
		local refereshTime = db:getConfiguration()["YAOSAI_SHUAXIN_TIME"].value or 15
		local nowTime = q.serverTime()
		if nowTime <= ( refereshTime + bossInfo.startAt/1000 ) and bossInfo.bossLevel > 1 then
			bossInfo.isShow = false
		end
	end
	self._bossInfo = bossInfo

	self:updateAwardsInfo()
end

function QWorldBoss:updateWorldBossParam(newInfo)
	if newInfo == nil then return end

	for key, value in pairs(newInfo) do
		self._bossInfo[key] = value 
	end
end 

function QWorldBoss:receiveServerSendBossInfo(message)
	if app.unlock:getUnlockWorldBoss() == false or self:checkWorldBossIsUnlock() == false or self._bossInfo.isShow == false then return end

	if message == nil then return end
	local killInfo = {}
	local bossInfo = {}
	local infos = string.split(message.params, "|=|")
	killInfo.userName = infos[2]
	killInfo.hurtNum = tonumber(infos[6]) or 500
	bossInfo.startAt = tonumber(infos[3]) or 0
	bossInfo.bossLevel = tonumber(infos[4]) or 1
	bossInfo.bossHp = tonumber(infos[5]) or 0
	killInfo.gameArea = infos[7]

	if self._bossInfo.bossLevel ~= bossInfo.bossLevel then
		remote.worldBoss:requestWorldBossInfo(nil, function()
				self:dispatchEvent({name = QWorldBoss.UPDATE_WORLDBOSS_INFO})
			end)
	end
	self:updateWorldBossParam(bossInfo)
	self:dispatchEvent({name = QWorldBoss.UPDATE_WORLDBOSS_INFO})
	if infos[1] and infos[1] ~= remote.user.userId then
		self:dispatchEvent({name = QWorldBoss.SEND_WORLDBOSS_KILL_INFO, info = killInfo})
	end 
end

function QWorldBoss:getWorldBossInfo()
	return self._bossInfo
end

function QWorldBoss:setWorldBossLogs(logs)
	if logs == nil then return end
	self._logs = clone(logs)
end

function QWorldBoss:getWorldBossLog()
	return self._logs
end

function QWorldBoss:getWorldBossFightCount()
	local nowTime = q.serverTime()
	local bossInfo = self:getWorldBossInfo()
	local defaultNum = db:getConfiguration()["MOREN_CISHU"].value
	local replyTime = db:getConfiguration()["HUIFU_JIANGE"].value * 60
	local fightCount = 0
	local unlockTime = nowTime

	for i = 1, #self._unlockTime do
		if q.date("*t", self._unlockTime[i]).wday == q.date("*t", nowTime).wday then
			unlockTime = self._unlockTime[i] 
			break
		end
	end

	if bossInfo.buyFightCount and bossInfo.fightCount then
		fightCount =  defaultNum + math.floor(( nowTime-unlockTime ) / replyTime ) + bossInfo.buyFightCount - bossInfo.fightCount
	else
		fightCount =  defaultNum + math.floor(( nowTime-unlockTime ) / replyTime )
	end

	return fightCount, unlockTime
end

-- 检查世界BOSS是否开启
function QWorldBoss:checkWorldBossIsUnlock()
	local nowTime = q.serverTime()

	if self._unlockTime == nil or next(self._unlockTime) == nil then
		local unlockWday = string.split( db:getConfiguration()["OPEN_TIME_TIAN"].value, ";" )
		local unlockHour = string.split( db:getConfiguration()["OPEN_TIME_SHI"].value, ";" )

		local creatTime = function(wday, hour)
				local time = q.date("*t", nowTime)
				local offsetday = wday - time.wday
				time.day = time.day + offsetday
				time.hour = hour
				time.min = 0
				time.sec = 0
		    	time = q.OSTime(time)
		    	return time
			end

		if unlockWday[2] and tonumber(unlockWday[2]) == 7 then
			local temp = tonumber(unlockWday[2]) 
			unlockWday[2] = unlockWday[1]
			unlockWday[1] = temp
		end

		for i = 1, #unlockWday do
			unlockWday[i] = tonumber(unlockWday[i]) == 7 and 1 or unlockWday[i] + 1
			self._unlockTime[i] = creatTime(unlockWday[i], unlockHour[1])
			self._lockTime[i] = creatTime(unlockWday[i], unlockHour[2])
		end
	end


	local isUnlock = false
	local nextUnlockTime = 0
	local nextlockTime = 0
	local isReadyTime = false -- 是否处于开启前的准备时间（当天的0～12点）
	for i = 1, #self._unlockTime do
		if nowTime >= self._unlockTime[i] and nowTime <= self._lockTime[i] then
			isUnlock = true
			nextUnlockTime =  self._unlockTime[i]
			nextlockTime =  self._lockTime[i]
			break
		elseif nowTime < self._unlockTime[i] then
			local unlockTime = q.date("*t", self._unlockTime[i])
			local time = q.date("*t", nowTime)
			if unlockTime.day == time.day then
				isReadyTime = true
			end
			nextUnlockTime = self._unlockTime[i]
			nextlockTime = self._lockTime[i]
			break
		end
	end
	if nextUnlockTime == 0 then 
		nextUnlockTime = self._unlockTime[1] + 7*24*3600
	end
	if nextlockTime == 0 then 
		nextlockTime = self._lockTime[1] + 7*24*3600
	end

	return isUnlock, nextUnlockTime+2, nextlockTime-2, isReadyTime
end

-- 倒计时
function QWorldBoss:updateTime()
	if not self.endAt then
		local _, _, nextlockTime = self:checkWorldBossIsUnlock()
		self.endAt = nextlockTime + 2
	end
	local isOvertime = false
	local endTime = self.endAt
	local nowTime = q.serverTime()

	local timeStr = ""
	local color = ccc3(255, 63, 0) -- 红色
	if nowTime >= endTime then
		isOvertime = true
	else
		local sec = endTime - nowTime
		if sec >= 30*60 then
			color = ccc3(255, 216, 44)
		else
			color = ccc3(255, 63, 0)
		end
		local h, m, s = self:_formatSecTime( sec )
		timeStr = string.format("%02d:%02d:%02d", h, m, s)
	end
	return isOvertime, timeStr, color
end

-- 将秒为单位的数字转换成 00：00：00格式
function QWorldBoss:_formatSecTime( sec )
	local h = math.floor((sec/3600)%24)
	local m = math.floor((sec/60)%60)
	local s = math.floor(sec%60)

	return h, m, s
end

-- 计算世界BOSS奖励
function QWorldBoss:updateAwardsInfo()
	local data1 = QStaticDatabase:sharedDatabase():getIntrusionReward(2) -- 个人荣誉
	local data2 = QStaticDatabase:sharedDatabase():getIntrusionReward(3) -- 击杀奖励
	local data3 = QStaticDatabase:sharedDatabase():getIntrusionReward(4) -- 宗门荣誉
	local bossInfo = self:getWorldBossInfo()
	local isHaveAwards1 = bossInfo.hurtReward or 0
	local isHaveAwards2 = bossInfo.killReward or 0
	local isHaveAwards3 = bossInfo.consortiaHurtReward or 0

	isHaveAwards1 = string.split( isHaveAwards1, "#" )
	isHaveAwards2 = string.split( isHaveAwards2, "#" )
	isHaveAwards3 = string.split( isHaveAwards3, "#" )
	local conditionLevel = bossInfo.validTeamLevel or 1

	local awards1 = {}
	local awards2 = {}
	local awards3 = {}
	local filterFunc = function(data, haveAwards, condition)
		local awards = {}
		for i = 1, #data do
			if conditionLevel and conditionLevel >= data[i].lowest_levels and conditionLevel <= data[i].maximum_levels then
				-- 计算是否是已领取状体
				data[i].state = QWorldBoss.AWARDS_IS_NONE
				for j = 1, #haveAwards do
					if data[i].id == tonumber(haveAwards[j]) then
						data[i].state = QWorldBoss.AWARDS_IS_DONE
						break
					end
				end
				-- 计算是否是可领取状态
				if data[i].state == QWorldBoss.AWARDS_IS_NONE and data[i].meritorious_service <= condition then
					data[i].state = QWorldBoss.AWARDS_IS_READY
				end
				awards[#awards+1] = data[i]
			end
		end
		return awards
	end
	awards1 = filterFunc(data1, isHaveAwards1, math.floor((bossInfo.allHurt or 0)/1000) or 0)
	awards2 = filterFunc(data2, isHaveAwards2, (bossInfo.bossLevel or 1)-1)
	awards3 = filterFunc(data3, isHaveAwards3, math.floor((bossInfo.consortiaTotalHurt or 0)/1000) or 0)

	local sortFunc
	sortFunc = function(a, b)
			if a.state ~= b.state then
				return a.state < b.state
			else
				return a.meritorious_service < b.meritorious_service
			end
		end
	table.sort(awards1, sortFunc)
	table.sort(awards2, sortFunc)
	table.sort(awards3, sortFunc)

	self._awardsInfos[1] = clone(awards1)
	self._awardsInfos[2] = clone(awards2)
	self._awardsInfos[3] = clone(awards3)
	self:dispatchEvent({name = QWorldBoss.UPDATE_WORLDBOSS_AWARDS_INFO})
end

function QWorldBoss:getAwardsData(awardsType)
	return self._awardsInfos[awardsType] or {}
end

function QWorldBoss:updateRankInfo(info, kind)
	if kind == nil then return {} end
	self._rankInfo[kind] = info
end

function QWorldBoss:getRankInfoByType(kind)
	return self._rankInfo[kind] or {}
end

function QWorldBoss:checkWorldBossRedTips()
	if app.unlock:getUnlockWorldBoss() == false then
		return false
	end

	if self:checkWorldBossIsUnlock() and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.WORLDBOSS) then
		return true
	elseif self:checkAwardsRedTips() then
		return true
	elseif self:checkFightCountRedTips() then
		return true
	end

	return false
end

function QWorldBoss:checkAwardsRedTips()
	local worldBossInfo = self:getWorldBossInfo()
	if self:checkAwardsState(1)then
		return true
	elseif self:checkAwardsState(2) then
		return true
	elseif self:checkAwardsState(3) then
		return true
	end

	return false
end

function QWorldBoss:checkScoreRedTips()
	return false
end

function QWorldBoss:checkFightCountRedTips()
	local isUnlock = self:checkWorldBossIsUnlock()
	if isUnlock then
		local count = self:getWorldBossFightCount()
		return count > 0
	end
	return false
end

function QWorldBoss:checkAwardsState(awardsType)
	if self._awardsInfos[awardsType] == nil then return false end

	for i = 1, #self._awardsInfos[awardsType] do
		if self._awardsInfos[awardsType][i].state == QWorldBoss.AWARDS_IS_READY then
			return true
		end
	end

	return false
end

function QWorldBoss:updateBuyCount()
	self:dispatchEvent({name = QWorldBoss.UPDATE_WORLDBOSS_BUY_COUNT})
end

function QWorldBoss:getBuffTimeHoursById( id )
    local startHour, endHour
    if id == 1 then
        startHour = 12
        endHour = 14
    elseif id == 2 then
        startHour = 14
        endHour = 16
    elseif id == 3 then
        startHour = 16
        endHour = 18
    elseif id == 4 then
        startHour = 18
        endHour = 20
    elseif id == 5 then
        startHour = 20
        endHour = 22
    end

	return startHour, endHour
end

-- 1,12_14;   2,14_16;   3,16_18;    4,18_20;    5,20_22;
function QWorldBoss:updateBuffColor()
    local startHour, endHour = self:getBuffTimeHoursById( self._bossInfo.additionTimeId )
	local isInTime = false
	local color = COLORS.f

    if startHour and endHour then
	    local nowTime = q.serverTime()
	    local time = q.date("*t", nowTime)
    	if time.hour >= startHour and time.hour < endHour then
	        isInTime = true
	        color = COLORS.b
       	end
    end

	return isInTime, color
end

----------------------------- 协议 -----------------------------

function QWorldBoss:responseHandler(data, success, fail, succeeded)
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

--[[
	拉取世界boss信息协议请求
]]
function QWorldBoss:requestWorldBossInfo(isQuit, success, fail, status)
	local sceneRequest
	if isQuit ~= nil then
		sceneRequest = {isQuit = isQuit, scene = SceneEnum.SCENE_WORLD_BOSS}
	end
    local request = {api = "WORLD_BOSS_GET_INFO", sceneRequest = sceneRequest}
    app:getClient():requestPackageHandler("WORLD_BOSS_GET_INFO", request, function (response)
        self:responseWorldBossInfo(response, success, nil, true)
    end, function (response)
        self:responseWorldBossInfo(response, nil, fail)
    end)
end

--[[
	拉取世界boss信息协议返回
]]
function QWorldBoss:responseWorldBossInfo(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:setWorldBossInfo(data.userWorldBossResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	世界boss开始战斗协议请求
	@param bossLevel:  boss等级
	@param battleFormation:	 战队信息
]]
function QWorldBoss:requestWorldBossFightStart(bossLevel, battleFormation, success, fail, status)
	local worldBossFightStartRequest = {bossLevel = tonumber(bossLevel)}
    local gfStartRequest = {battleType = BattleTypeEnum.WORLD_BOSS, battleFormation = battleFormation, worldBossFightStartRequest = worldBossFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (response)
        self:responseWorldBossFightStart(response, success, nil, true)
    end, function (response)
        self:responseWorldBossFightStart(response, nil, fail)
    end)
end

--[[
	世界boss开始战斗协议返回
]]
function QWorldBoss:responseWorldBossFightStart(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:setWorldBossInfo(data.userWorldBossResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	世界boss结束战斗协议请求
	@param bossHp:  boos剩余血量
	@param battleKey:  战斗校验的Key
]]
function QWorldBoss:requestWorldBossFightEnd(bossHp, bossLevel, battleKey, success, fail, status)
	local worldBossFightEndRequest = {bossHp = bossHp, bossLevel = bossLevel}
	local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)
    worldBossFightEndRequest.battleVerify = q.battleVerifyHandler(battleKey)
   
    local  gfEndRequest = {battleType = BattleTypeEnum.WORLD_BOSS, battleVerify = worldBossFightEndRequest.battleVerify, isQuick = false, isWin = nil
						, fightReportData = fightReportData, worldBossFightEndRequest = worldBossFightEndRequest}
	local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
	app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function(response)
			self:responseWorldBossFightEnd(response, success, nil, true)
		end,
		function(response)
			self:responseWorldBossFightEnd(response, nil, fail)
		end)
end

--[[
	世界boss结束战斗协议返回
]]
function QWorldBoss:responseWorldBossFightEnd(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:setWorldBossInfo(data.userWorldBossResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	领取荣耀奖励协议请求
	@param rewardIds: 奖励的ID数组
]]
function QWorldBoss:requestWorldBossGloryAwards(rewardIds, success, fail, status)
	local luckyDrawWorldBossHurtRewardRequest = {rewardIds = rewardIds}
	local request = {api = "LUCKY_DRAW_WORLD_BOSS_HURT_REWARD", luckyDrawWorldBossHurtRewardRequest = luckyDrawWorldBossHurtRewardRequest}
	app:getClient():requestPackageHandler("LUCKY_DRAW_WORLD_BOSS_HURT_REWARD", request, function(response)
			self:responseWorldBossGloryAwards(response, success, nil, true)
		end,
		function(response)
			self:responseWorldBossGloryAwards(response, nil, fail)
		end)
end

--[[
	领取荣耀奖励协议返回
]]
function QWorldBoss:responseWorldBossGloryAwards(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:updateWorldBossParam(data.userWorldBossResponse)
		self:updateAwardsInfo()
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	领取宗门荣耀奖励协议请求 LuckyDrawWorldBossConsortiaHurtRewardRequest
	@param rewardIds: 奖励的ID数组
]]
function QWorldBoss:requestWorldBossUnionGloryAwards(rewardIds, success, fail, status)
	local luckyDrawWorldBossConsortiaHurtRewardRequest = {rewardIds = rewardIds}
	local request = {api = "LUCKY_DRAW_WORLD_BOSS_CONSORTIA_HURT_REWARD", luckyDrawWorldBossConsortiaHurtRewardRequest = luckyDrawWorldBossConsortiaHurtRewardRequest}
	app:getClient():requestPackageHandler("LUCKY_DRAW_WORLD_BOSS_CONSORTIA_HURT_REWARD", request, function(response)
			self:responseWorldBossUnionGloryAwards(response, success, nil, true)
		end,
		function(response)
			self:responseWorldBossUnionGloryAwards(response, nil, fail)
		end)
end

--[[
	领取宗门荣耀奖励协议返回
]]
function QWorldBoss:responseWorldBossUnionGloryAwards(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:updateWorldBossParam(data.userWorldBossResponse)
		self:updateAwardsInfo()
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	领取击杀奖励协议请求
	@param rewardIds: 奖励的ID数组
]]
function QWorldBoss:requestWorldBossKillAwards(rewardIds, success, fail, status)
	local luckyDrawWorldBossKillRewardRequest = {rewardIds = rewardIds}
	local request = {api = "LUCKY_DRAW_WORLD_BOSS_KILL_REWARD", luckyDrawWorldBossKillRewardRequest = luckyDrawWorldBossKillRewardRequest}
	app:getClient():requestPackageHandler("LUCKY_DRAW_WORLD_BOSS_KILL_REWARD", request, function(response)
			self:responseWorldBossKillAwards(response, success, nil, true)
		end,
		function(response)
			self:responseWorldBossKillAwards(response, nil, fail)
		end)
end

--[[
	领取击杀奖励协议返回
]]
function QWorldBoss:responseWorldBossKillAwards(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:updateWorldBossParam(data.userWorldBossResponse)
		self:updateAwardsInfo()
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	拉取战报日志协议请求
]]
function QWorldBoss:requestWorldBossLog(success, fail, status)
	local request = {api = "WORLD_BOSS_GET_LOG"}
	app:getClient():requestPackageHandler("WORLD_BOSS_GET_LOG", request, function(response)
			self:responseWorldBossLog(response, success, nil, true)
		end,
		function(response)
			self:responseWorldBossLog(response, nil, fail)
		end)
end

--[[
	拉取战报日志协议返回
]]
function QWorldBoss:responseWorldBossLog(data, success, fail, succeeded)
	if data.worldBossLogResponse then
		self:setWorldBossLogs(data.worldBossLogResponse.logs)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	购买世界boss挑战次数协议请求
]]
function QWorldBoss:requestBuyWorldBossFightCount(success, fail, status)
	local request = {api = "WORLD_BOSS_BUY_FIGHT_COUNT"}
	app:getClient():requestPackageHandler("WORLD_BOSS_BUY_FIGHT_COUNT", request, function(response)
			self:responseBuyWorldBossFightCount(response, success, nil, true)
		end,
		function(response)
			self:responseBuyWorldBossFightCount(response, nil, fail)
		end)
end

--[[
	购买世界boss挑战次数协议返回
]]
function QWorldBoss:responseBuyWorldBossFightCount(data, success, fail, succeeded)
	if data.userWorldBossResponse then
		self:updateWorldBossParam(data.userWorldBossResponse)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
	拉取世界boss排行协议请求
	@param kind:  排行榜类型(WORLD_BOSS_USER_HURT:玩家伤害排行,  WORLD_BOSS_CONSORTIA_HURT:宗门伤害排行)
	@param userId:  玩家的userId
]]
function QWorldBoss:requestWorldBossRank(kind, userId, success, fail, status)
	local rankingsRequest = {kind = kind, userId = userId}
	local request = {api = "RANKINGS", rankingsRequest = rankingsRequest}
	app:getClient():requestPackageHandler("RANKINGS", request, function(response)
			self:responseWorldBossRank(response, success, nil, true, kind)
		end,
		function(response)
			self:responseWorldBossRank(response, nil, fail, nil, kind)
		end)
end

--[[
	拉取世界boss排行协议返回
]]
function QWorldBoss:responseWorldBossRank(data, success, fail, succeeded, kind)
	if kind == "WORLD_BOSS_USER_HURT" then
		self:updateRankInfo(kind, data.rankings)
	elseif kind == "WORLD_BOSS_CONSORTIA_HURT"  then
		self:updateRankInfo(kind, data.consortiaRankings)
	end
	self:responseHandler(data, success, fail, succeeded)
end

--[[
 	CHOOSE_ADDITION_TIME                        = 7908;                     //选择公会加成的时间段 参数 WorldBossChooseAdditionTimeRequest
 	optional int32 additionTimeId = 1;                                         // 选择的时间段的Id
 	-- 1,12_14;	  2,14_16;	 3,16_18;	 4,18_20;	 5,20_22;
 ]]
function QWorldBoss:worldBossChooseAdditionTimeRequest(additionTimeId, success, fail, status)
	local worldBossChooseAdditionTimeRequest = {additionTimeId = additionTimeId}
    local request = { api = "CHOOSE_ADDITION_TIME", worldBossChooseAdditionTimeRequest = worldBossChooseAdditionTimeRequest }
    app:getClient():requestPackageHandler("CHOOSE_ADDITION_TIME", request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

return QWorldBoss