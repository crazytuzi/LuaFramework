-- FileName: MissionMainData.lua
-- Author: 
-- Date: 2014-04-00
-- Purpose: 悬赏榜数据层
--[[TODO List]]

module("MissionMainData", package.seeall)
require "db/DB_Bounty_reward"
require "script/utils/TimeUtil"
local _dataInfo = nil

function setInfo( pMissionInfo )
	_dataInfo = pMissionInfo
end

function getInfo()
	return _dataInfo
end

--[[
	@des:得到当前分组id
--]]
function getTeamId()
	if _dataInfo == nil then
		return -1
	end
	return tonumber(_dataInfo.teamId) or -1
end

--[[
	@des:本轮的名望
--]]
function getCurrFame()
	return tonumber(_dataInfo.fame)
end

--[[
	@des:本轮的名望
--]]
function addCurrFame( pAddNum )
	_dataInfo.fame  = tonumber(_dataInfo.fame) + pAddNum
end

--[[
	@des:本轮捐献的物品数量（这个也可以拿到任务进度里去吧）
--]]
function getDonateItemNum()
	return tonumber(_dataInfo.donate_item_num)
end

--[[
	@des:本轮捐献的物品数量（这个也可以拿到任务进度里去吧）
--]]
function addDonateItemNum( pAddNum )
	_dataInfo.donate_item_num  = tonumber(_dataInfo.donate_item_num) + pAddNum
end

--[[
	@des:本轮做任务获得的名望
--]]
function getSpecMissionFame()
	return tonumber(_dataInfo.spec_mission_fame) 
end

--[[
	@des:每日领奖时间
--]]
function getDayrewardTime()
	return tonumber(_dataInfo.dayreward_time)
end

--[[
	@des:每日领奖时间
--]]
function setDayrewardTime( pTime )
	_dataInfo.dayreward_time = pTime
end

--[[
	@des:设置排名
	@parm:pRank 排名
--]]
function setRank( pRank )
	_dataInfo.rank = pRank
end

--[[
	@des:得到排名
	@parm:pRank 排名
--]]
function getRank()
	return tonumber(_dataInfo.rank) or -1
end

--[[
	@des:任务进度
--]]
function getMissionInfo()
	return _dataInfo.missionInfo
end

--[[
	@des:每日奖励前段展示用
--]]
function getDayRewardConfig()
	return _dataInfo.configInfo.dayRewardArr
end

--[[
	@des:排名奖励前段展示用
--]]
function getRankRewardConfig()
	return _dataInfo.configInfo.rankRewardArr
end

--[[
	@des:得到排名要花费的时间
		 和后端约定为排名花费60s
--]]
function getRankSpendTime()
	return 120
end

--[[
	@des:得到活动数据
--]]
function getActivityData()
	require "script/model/utils/ActivityConfigUtil"
	local activityData = ActivityConfigUtil.getDataByKey("mission")
	return activityData
end

--[[
	@des:得到开始活动时间
	@ret:时间戳
--]]
function getStartTime()
	require "script/model/utils/ActivityConfigUtil"
	local activityData = getActivityData()
	return activityData.start_time
end

--[[
	@des:得到悬赏结束时间
	@ret:时间戳
--]]
function getMissionOverTime()
	require "script/model/utils/ActivityConfigUtil"
	local activityData = getActivityData()
	return activityData.end_time
end

--[[
	@des:得到捐献持续时间
--]]
function getDonateTime()
	require "script/model/utils/ActivityConfigUtil"
	local activityData = getActivityData()
	local timeInfo = string.split(activityData.data[1].time, ",")
	local timeConfig = {86400, 3600, 60, 1}
	local retTime = 0
	for i=1,4 do
		local t = tonumber(timeInfo[i]) or 0
		retTime = retTime + t*timeConfig[i]
	end
	return retTime
end

--[[
	@des:得到当前显示届数
--]]
function getSeason()
	local startTime = getStartTime()
	local nowTime = TimeUtil.getSvrTimeByOffset()
	local configSeason = getConfigSeason()
	if configSeason >0 and startTime > nowTime then
		configSeason = configSeason - 1
	end
	return configSeason
end

--[[
	@des:得到当前配置届数
--]]
function getConfigSeason()
	local activityData = getActivityData()
	local session = tonumber(activityData.data[1].num)
	return session
end


--[[
	@des:得到本届捐献物品上限
--]]
function getDonateLimit()
	local activityData = getActivityData()
	local num = tonumber(activityData.data[1].num_limit)
	return num
end

--[[
	@des:参加等级
--]]
function getNeedJoinLevel()
	local activityData = getActivityData()
	local level = tonumber(activityData.data[1].level)
	return level
end

--[[
	@des:获得奖励id
--]]
function getDayRewardId()
	local rank = getRank() + 1
	local rewarArray = getDayRewardConfig()
	if rank == -1 then
		return tonumber(rewarArray[#rewarArray][2])
	end
	local rewardId = nil
	for i,v in ipairs(rewarArray) do
		local nextInfo = rewarArray[i+1]
		if nextInfo then
			if rank >= tonumber(v[1]) and rank < tonumber(nextInfo[1]) then
				rewardId = tonumber(v[2])
				break
			end
		else
			rewardId = tonumber(v[2])
		end
	end
	return rewardId
end

--[[
	@des:每日领奖奖励列表
	@ret:{
		12|0|10000,
		7|30110|10
	} 返回 nil 表示没有奖励
--]]
function getDayRewardItemList()
	local rewardId = getDayRewardId()
	if rewardId == nil then
		return {}
	end
	local rewardInfo = DB_Bounty_reward.getDataById(rewardId)
	local rewardArr = string.split(rewardInfo.reward, ",")
	return rewardArr
end

--[[
	@des:得到奖励标题
--]]
function getRewardTitle()
	local rewardId = getDayRewardId()
	if rewardId == nil then
		return {}
	end
	local rewardInfo = DB_Bounty_reward.getDataById(rewardId)
	local title = rewardInfo.name
	return title
end

--[[
	@des:判断当前是否可以进入活动
--]]
function isCanJion()
	--1.活动已经开启
	if not ActivityConfigUtil.isActivityOpen("mission") then
		if not table.isEmpty(getActivityData().data) then 
			if getConfigSeason() == 1 then
				return false
			end
		else
			return false
		end
	end
	--2.参加等级是否足够
	if UserModel.getHeroLevel() < MissionMainData.getNeedJoinLevel() then
		return false
	end
	return true
end

--[[
	@des:判断当前是否可以捐献
--]]
function isCanDonate()
	local nowTime = TimeUtil.getSvrTimeByOffset()
	if ActivityConfigUtil.isActivityOpen("mission") then
		local donateEndTime = getStartTime() + getDonateTime()
		local donateStartTime = getStartTime() + getRankSpendTime()
		if nowTime < donateEndTime and nowTime > donateStartTime then
			return true
		end
	end
	return false
end

--[[
	@des:得到活动时间描述
--]]
function getTimeDes()
	local retWord = ""
	local nowTime = TimeUtil.getSvrTimeByOffset()
	local donateTime = getStartTime() + getDonateTime()
	if isCanDonate() then
		local startTime = TimeUtil.getTimeForDayPro(getStartTime())
		local endTime   = TimeUtil.getTimeForDayPro(getStartTime()+getDonateTime())
		startTime = string.gsub(startTime, "-", ".")
		endTime = string.gsub(endTime, "-", ".")
		retWord = GetLocalizeStringBy("lcyx_1948",startTime, endTime)
	elseif nowTime > donateTime and nowTime < donateTime + getRankSpendTime() then
		retWord = GetLocalizeStringBy("lcyx_1949")
	else
		retWord = GetLocalizeStringBy("lcyx_1950")
	end
	return retWord
end

--[[
	@des:每日领取俸禄小红点
--]]
function isShowRedTip()
	--1.活动没开启或者没有分组
	if isCanJion() == false or getTeamId() <=0 then
		return false
	end
	--2.判断当前是否在领奖时间段内
	local nowTime = TimeUtil.getSvrTimeByOffset()
	local donateTime = MissionMainData.getStartTime() + MissionMainData.getDonateTime()
	if nowTime < donateTime +  MissionMainData.getRankSpendTime() and nowTime > MissionMainData.getStartTime() then
		return false
	end
	--3.下届活动开始前两分钟不能领取
	if nowTime < MissionMainData.getStartTime() and MissionMainData.getConfigSeason() > 0 then
		if nowTime > MissionMainData.getStartTime() - MissionMainData.getRankSpendTime() then
			return false
		end
	end
	--4.今天是否已经领过奖励
	local reciveTime = MissionMainData.getDayrewardTime() or 0
	local nowTime = TimeUtil.getSvrTimeByOffset()
	if TimeUtil.isSameDay(reciveTime, nowTime) then
		return false
	end
	return true
end









