-- FileName: SignleRechargeData.lua 
-- Author: fuqiongqiong
-- Date: 2016-3-3
-- Purpose: 单充回馈数据层

module("SignleRechargeData",package.seeall)
require "script/utils/TimeUtil"
local _rewardData = nil
local _times = nil
local _toReward = nil
--获取数据
function getAllInfo( ... )
	_rewardData = ActivityConfigUtil.getDataByKey("oneRecharge").data
	return _rewardData
end

--活动开始时间
function getStartTime( ... )
	return tonumber(ActivityConfigUtil.getDataByKey("oneRecharge").start_time)
end
--活动结束时间
function getEndTime( ... )
	local endTime = tonumber(ActivityConfigUtil.getDataByKey("oneRecharge").end_time)
	return endTime - 3600
end
--判断活动结束
function isActiveOver( ... )
	if tonumber(TimeUtil.getSvrTimeByOffset()) >= getEndTime() then
		return true
	else
		return false
	end
end
-- 活动是否开启
function isOpen( ... )
	if not ActivityConfigUtil.isActivityOpen("oneRecharge") then
		return false
	end
	local curTime = TimeUtil.getSvrTimeByOffset()
	print("curTime-------",curTime)
	print("getEndTime()-------",getEndTime())
	return curTime < getEndTime()
end
--[[
	@des 	:得到TimeUtils里规格化了的活动日期
	@param 	:1 开始时间 		2 结束时间
	@return :活动规格化时间
--]]
function getFormatDate(p_index)
	if p_index == 1 then
		return TimeUtil.getTimeForDayTwo(getStartTime())
	else
		return TimeUtil.getTimeForDayTwo(getEndTime())
	end
end


--[[
	@des 	:活动时间倒计时
	@return :格式调整好了的倒计时
--]]
function activeCountDown()
	return TimeUtil.getRemainTime(getEndTime())
end

--[[
	@des 	: 根据奖励id获取奖励的数据
	@param 	: 
	@return : 
--]]
function getRewardInfoById(id)
	local tReward = ActivityConfigUtil.getDataByKey("oneRecharge").data[id]
	return tReward
end
function getActivityDays( ... )
	return table.count(ActivityConfigUtil.getDataByKey("oneRecharge").data)
end

--设置已经奖励的信息
function setHasInfo( p_Info )
    _times = p_Info
end
--获取已经领取的信息
function getHasInfo( p_id )
	local num = 0
	if(not table.isEmpty(_times) )then
		for k,v in pairs(_times) do
			if(tonumber(k) == p_id)then
				-- num = tonumber(v)
				num = table.count(v)
				break
			end
		end		
	end
   return num
end

function getCanRechargeNum( p_id )
	local num = 0
	if(not table.isEmpty(_toReward) )then
		for k,v in pairs(_toReward) do
			if(tonumber(k) == p_id)then
				num = tonumber(v)
				break
			end
		end		
	end
   return num
end
--获取toReward的内容
function gettoReward( p_Reward )
	_toReward = p_Reward or {}
end
--判断是领取还是去充值,true为领取，false为充值
function getOrRecharge( p_id )
	local getOrRecharge = false 
	if( table.isEmpty(_toReward) )then
		getOrRecharge = false
	else
		for k,v in pairs(_toReward) do
			if(tonumber(p_id) == tonumber(k))then
				getOrRecharge = true
				break
			end
		end
	end
	return getOrRecharge
end
--获取剩余次数
function getremainNum( p_id )
	local remainTimes = 0
	local allTimes = tonumber(getRewardInfoById(p_id).daytimes)
    remainTimes = allTimes - getHasInfo(p_id)
    return remainTimes
end

--获取奖励
function getRewardArray( p_id )
	local data = getRewardInfoById(p_id)
	local rewardata = data.payReward or {}
	local rewardArray = string.split(rewardata,",")
	return rewardArray
end
--获取已经充值的次数
function getallredayRechargeNum( p_id )
	local num = getHasInfo(p_id) + getCanRechargeNum(p_id)
	return num
end

--单充回馈的小红点显示
function getRedTipNum( )
    local num = 0
    for k,v in pairs(_toReward) do
       num =  v + num
    end
    return num
end

--用于剩余次数刷新
function refreshRemainNum( p_id )
	local num = 1
	local lenght = #_toReward
	if( not table.isEmpty(_toReward))then
		
	end	
	return num
end

--用于判断奖励是否是多选一
function isRewardForSelected( pId )
	local tbConfig = getRewardInfoById(tonumber(pId))
	print("isRewardForSelected id: ", pId, " type: ", tbConfig == nil and "config is nil" or tbConfig.type)
	local nType = (tbConfig == nil or tbConfig.type == nil) and 1 or tonumber(tbConfig.type)

	local bNeedSelected = false
	if nType == 1 then    --type: 1:全选  2:N选1
		bNeedSelected = false
	elseif nType == 2 then
		bNeedSelected = true
	end

	return bNeedSelected
end