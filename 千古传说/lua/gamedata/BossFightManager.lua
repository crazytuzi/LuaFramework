--[[
******活动管理*******

	-- by Stephen.tao
	-- 2011/1/14
]]


local BossFightManager = class("BossFightManager")
local BossFightData = require('lua.table.t_s_boss_battle')
local BossFightRewardConfig = require("lua.table.t_s_boss_battle_reward")

BossFightManager.UPDATEDAILY = "BossFightManager.UPDATEDAILY"

function BossFightManager:ctor(data)
    TFDirector:addProto(s2c.WORLD_BOSS_INFO_LIST, self,    self.onReceiveBossFightInfo)
    --TFDirector:addProto(s2c.RANKING_LIST_WORLD_BOSS, self,    self.onReceiveBossFightRanKInfo)

    self.bossFightInfo = {}

    self:restart()

       --监听数据请求回调
	self.requestDataCallBack = function (event)
		local userData = event.data[1][1]
		self:onReceiveBossFightRanKInfo(userData)
		RankManager:setDelayTimeZero(RankListType.Rank_List_fumo)
	end
	TFDirector:addMEGlobalListener(RankManager.POST_MSG_BOSSFIGHT, self.requestDataCallBack)

end

--活动管理器清空
function BossFightManager:restart()


	-- required int32 id = 1; 				//BOSS配置ID类型
	-- required int32 total = 2;			//当日伤害总量
	-- required int32 best = 3;			//当日单次最高伤害
	-- required int32 todayTimes = 4;		//当日已经使用的挑战次数
	-- required int32 todayPayTimes=5;		//当日已经使用的付费挑战次数
	-- required int32 totalTimes = 6;		//累计使用过的挑战次数
	-- required int32 totalPayTimes = 7;	//累计使用过的付费挑战次数
	-- required int64 lastUpdate = 8;		//最后一次更新信息的系统时间
	-- required int64 lastReward = 9;		//最后一次奖励时间

	self.bossFightInfo.total = 0
	self.bossFightInfo.best = 0
	self.bossFightInfo.todayTimes = 0
	self.bossFightInfo.todayPayTimes = 0
	self.bossFightInfo.totalTimes = 0
	self.bossFightInfo.totalPayTimes = 0
	self.bossFightInfo.lastUpdate = 0
	self.bossFightInfo.lastReward = 0
end



function BossFightManager:onReceiveBossFightInfo(event)
	local WorldBossInfo = event.data.info[1]

	print("WorldBossInfo = ", WorldBossInfo)

	self.bossFightInfo.total = WorldBossInfo.total
	self.bossFightInfo.best = WorldBossInfo.best
	self.bossFightInfo.todayTimes =  WorldBossInfo.todayTimes
	self.bossFightInfo.todayPayTimes =  WorldBossInfo.todayPayTimes
	self.bossFightInfo.totalTimes =  WorldBossInfo.totalTimes
	self.bossFightInfo.totalPayTimes =  WorldBossInfo.totalPayTimes
	self.bossFightInfo.lastUpdate =  WorldBossInfo.lastUpdate
	self.bossFightInfo.lastReward =  WorldBossInfo.lastReward
end

function BossFightManager:onReceiveBossFightRanKInfo(event)
	-- //世界BOSS排行榜
	-- // code = 0x4005
	-- message RankingListWorldBoss{
	-- 	repeated RankInfoWorldBoss rankInfo = 1;			//排名
	-- 	required int32 last = 2;							//最低入榜排名总伤害
	-- 	required int32 myRanking = 3;						//我的最佳排名,0表示未入榜
	-- 	required int32 myBestValue = 4;						//我的最佳成绩，用户跟lastValue比较
	-- 	required int32 praiseCount = 5;						//我自己拥有的赞数量
	-- 	required int32 betterRewardValue = 6;				//更好的奖励的总伤害，如果为0表示没有更好的了
	-- 	required int32 rewardId = 7;						//当前奖励ID
	-- }

	-- //世界BOSS榜单个排名信息
	-- message RankInfoWorldBoss{
	-- 	required int32 ranking = 1;						//排名，1~N
	-- 	required int32 playerId = 2;					//玩家ID
	-- 	required int32 power = 3;						//战力
	-- 	required string name = 4;						//昵称
	-- 	required int32 level = 5;						//等级
	-- 	required int32 vipLevel = 6;					//VIP等级
	-- 	required int32 goodNum = 7;						//赞次数
	-- 	repeated RankInfoFormation formation = 8;		//布阵信息
	-- 	required int32 totalDamage = 9;					//总伤害
	-- }


	local WorldBossInfo = event

	-- print("WorldBossInfo = ", WorldBossInfo)
	self.WorldBossInfo = WorldBossInfo
	print("self.bossfightStatus = ", self.bossfightStatus)
	if self.bossfightStatus == nil or self.bossfightStatus == false then
		return
	end
	self.bossfightStatus = false

	hideLoading()	
	self:openBossMainLayer()
end


function BossFightManager:requestBossFight()

	self.bossfightStatus = true

	-- self:openBossMainLayer()
	local Msg = 
	{
		6,
		0,
		3,0,0,0
	}

	TFDirector:send(c2s.QUERY_RANKING_BASE_INFO, Msg)
	showLoading();
end

function BossFightManager:requestAttackBoss(fightType)
	local bossData = BossFightManager:getBossFightInfo()

	if self.bossFightInfo.todayTimes >= bossData.max_times then
		-- toastMessage("今日挑战次数已用完")
		toastMessage(localizable.BossFightManager_no_changlle_time)
		return false
	end

	showLoading()
	if fightType == nil then
		fightType = 0
	end
	TFDirector:send(c2s.CHALLENGE_WORLD_BOSS, {bossData.id,fightType})

	return true
end

--显示某个活动界面
function BossFightManager:openBossMainLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.bossfight.BossFightMainLayer");

    AlertManager:show()
end


function BossFightManager:setBossFightStatus(status)
	self.bossfightStatus = status
end

function BossFightManager:findBossWithDayIndex(dayIndexOfWeek)
	local bossData = nil

	dayIndexOfWeek = tonumber(dayIndexOfWeek)

	if dayIndexOfWeek == 0 then
		dayIndexOfWeek = 7
	end

	for v in BossFightData:iterator() do
		local displayDay = v.day_of_week
		-- print("mark1 = ", bit_and(mark,2)) -- 0010 -- 新服
		-- print("mark2 = ", bit_and(mark,4)) -- 0100 -- 推荐
		-- print("mark3 = ", bit_and(mark,8)) -- 1000 -- 火爆
		local day0 = bit_and(displayDay,1)
		local day1 = bit_and(displayDay,2)
		local day2 = bit_and(displayDay,4)
		local day3 = bit_and(displayDay,8)
		local day4 = bit_and(displayDay,16)
		local day5 = bit_and(displayDay,32)
		local day6 = bit_and(displayDay,64)

		-- %w
		local dayList = {day1,day2,day3,day4,day5,day6,day0}

		print("displayDay",  displayDay)
		-- print("---dayList ",  v.boss_id)
		print(dayList)

		-- print("dayList[dayIndexOfWeek] = ", dayList[dayIndexOfWeek])
		-- print("dayIndexOfWeek = ", dayIndexOfWeek)
		-- print("dayList[5] = ", dayList[5])

		if dayList and dayList[dayIndexOfWeek] ~= nil and dayList[dayIndexOfWeek] > 0 then
			print("find the boss , id = ", v.boss_id)
			bossData = v

			return bossData
		end
	end

	print("can't find boss , use first boss")
	if bossData == nil then
		bossData = BossFightData:objectAt(1)
	end

	return bossData
end

function BossFightManager:getBossFightInfo()
	-- day_of_week
	local day_of_week = {}


	local dayIndexOfWeek = os.date("%w",MainPlayer:getNowtime())

	print("---dayIndexOfWeek = ", dayIndexOfWeek)

	local bossData = self:findBossWithDayIndex(dayIndexOfWeek) -- BossFightData:objectAt(1)

	
	self.BossData = {}

	self.BossData.id 		= bossData.id
	self.BossData.boss_id 	= bossData.boss_id
	self.BossData.bossName 	= bossData.name --"走火入魔的鸠摩智"
	self.BossData.posInfo  	= bossData.formation
	self.BossData.max_times = bossData.max_times
	self.BossData.rewardId 	= bossData.max_times
	self.BossData.power 	= bossData.power--1000000

	self.BossData.beginTime = bossData.open_time
	self.BossData.endTime 	= bossData.end_time

	self.BossData.imgdesc 	= bossData.display
	self.BossData.effect 	= bossData.effect
	self.BossData.effectx 	= bossData.effect_x
	self.BossData.effecty 	= bossData.effect_y

	local npcInfo 			= NPCData:objectByID(bossData.boss_id)	--pck change head icon and head icon frame
	self.BossData.icon		= npcInfo.role_id						--end

	return self.BossData
end

function BossFightManager:getBossFightTotalInfo()
	return self.bossFightInfo
end

function BossFightManager:getBossFightRankInfo()
	return self.WorldBossInfo
end

function BossFightManager:getRankRewards(rank)
	local reward_id = 0
    for v in BossFightRewardConfig:iterator() do
        if v.min_pos <= rank and rank <= v.max_pos then
            reward_id = v.reward_id
            return reward_id
        end
    end

   	local bossReward = BossFightRewardConfig:back()

   	if bossReward then
   		reward_id = bossReward.reward_id
   	end

    -- 
    print("找不到名次对应的奖励 rank = ",rank)

    return reward_id
end

function BossFightManager:enterBossRank()

    --toastMessage("点击了排行榜")
    local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.leaderboard.Leaderboard.lua")
	layer:setIndex(RankListType.Rank_List_Hero)
    AlertManager:show();
end

function BossFightManager:isBossFightOpen()
	-- self.BossData.beginTime = bossData.open_time
	-- self.BossData.endTime 	= bossData.end_time
	local function getBossFightTime(time)
		-- local date = os.date("%x", MainPlayer:getNowtime())

		-- date = date .. " "..time

		-- print("先转换成当前时间 = ", date)
		-- -- 转换成服务器时间
		-- local timeSec 	= os.time(date)

		-- print("在转成服务器时间 = ", timeSec)
		local c 		= split(time, ":")
		local nextDate  = {hour=c[1], min=c[2], sec=c[3]}
    	local date 	= os.date("*t", MainPlayer:getNowtime())

		date.hour = nextDate.hour
		date.min  = nextDate.min
		date.sec  = nextDate.sec

		-- date.
		local timeSec 	= os.time(date)

		return timeSec
	end

	local nowTime = MainPlayer:getNowtime()
	local full = os.date("%c", nowTime)

	print("当前服务器时间 = ", full)		

	local time1 = getBossFightTime(self.BossData.beginTime)
	local time2 = getBossFightTime(self.BossData.endTime)
	print("time1 	= ", time1)
	print("time2 	= ", time2)
	print("nowTime 	= ", nowTime)
	if nowTime >= time1 and nowTime <= time2 then
		return true
	end

	return false
end

function BossFightManager:resetData12oClock()
	self.bossFightInfo.todayTimes = 0
	TFDirector:dispatchGlobalEventWith(BossFightManager.UPDATEDAILY, {})
end

return BossFightManager:new()