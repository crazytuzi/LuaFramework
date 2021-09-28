-- Filename：	LimitShopData.lua
-- Author：		Zhang Zihang
-- Date：		2014-11-24
-- Purpose：		限时商店数据层

module("LimitShopData", package.seeall)

require "script/model/utils/ActivityConfigUtil"
require "script/utils/TimeUtil"

local _configData 			--活动配置数据
local _serverInfo 			--后端返回数据
local _curDay				--当前天数
local _curDayTable 			--当天活动配置
local _nextDayTime 			--刷新时间

--[[
	@des 	:设置活动配置信息
--]]
function setConfigInfo()
	_configData = ActivityConfigUtil.getDataByKey("limitShop")
end

--[[
	@des 	:设置后端返回数据信息
	@param 	:后端返回数据
--]]
function setServerInfo(p_ret)
	_serverInfo = p_ret
end

--[[
	@des 	:通过id得到后端返回数据信息
	@param 	:id
	@return :信息
--]]
function getCostNum(p_id)
	if _serverInfo[tostring(p_id)] == nil then
		return 0
	else
		return tonumber(_serverInfo[tostring(p_id)].num)
	end
end

function setBuyNum(p_id,p_num)
	if _serverInfo[tostring(p_id)] == nil then
		_serverInfo[tostring(p_id)] = {}
		_serverInfo[tostring(p_id)].num = p_num
	else
		_serverInfo[tostring(p_id)].num = tonumber(_serverInfo[tostring(p_id)].num) + p_num
	end
end

--[[
	@des 	:剩余购买次数
	@param 	:id
	@return :次数
--]]
function remainNum(p_id)
	local remainTime = tonumber(_curDayTable[p_id].buyNum) - getCostNum(_curDayTable[p_id].id)

	return remainTime
end

--[[
	@des 	:设置当前天数
--]]
function setCurDay()
	--活动开始当天0点，因为活动过了24点算第二天
	local zeroTime = TimeUtil.getCurDayZeroTime(getStartTime())
	local dayOffset = math.floor((TimeUtil.getSvrTimeByOffset() - zeroTime)/(24*3600))

	_curDay = dayOffset + 1
end

--[[
	@des 	:得到当前天的活动配置
	@return :当天配置
--]]
function setCurDayInfo()
	local configData = _configData.data

	_curDayTable = {}

	--这样遍历好无奈
	for i = 1,#configData do
		local refreshTable = string.split(configData[i].RefreshTime,",")
		for j = 1,#refreshTable do
			if tonumber(refreshTable[j]) == _curDay then
				table.insert(_curDayTable,configData[i])
				break
			end
		end
	end
end

--[[
	@des 	:通过id得到当前cell的信息
	@param 	:cell的id
	@return :信息
--]]
function getCurCellInfoById(p_id)
	return _curDayTable[p_id]
end

--[[
	@des 	:得到活动开始时间
	@return :活动开始时间
--]]
function getStartTime()
	return tonumber(ActivityConfigUtil.getDataByKey("limitShop").start_time)
end

--[[
	@des 	:得到活动结束时间
	@return :活动结束时间
--]]
function getEndTime()
	return tonumber(ActivityConfigUtil.getDataByKey("limitShop").end_time)
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
	@des 	:物品倒计时
	@return :格式调整好的倒计时
--]]
function itemCountDown()
	return TimeUtil.getRemainTimeHMS(_nextDayTime)
end

--[[
	@des 	:设置刷新时间
--]]
function setRefreshTime()
	local zeroTime = TimeUtil.getCurDayZeroTime(TimeUtil.getSvrTimeByOffset())
	_nextDayTime = zeroTime + 24*3600
end

--[[
	@des 	:得到物品数目
	@return :cell数目
--]]
function giftsNum()
	return #_curDayTable
end

--[[
	@des 	:得到当日奖励信息
	@param  :物品id串
	@return :奖励信息
--]]
function getCurDayReward(p_id)
	return ItemUtil.getItemsDataByStr(p_id)
end

--[[
	@des 	:判断活动是否结束
	@return :true 已结束    false 未结束
--]]
function gameOverOrNot()
	if tonumber(TimeUtil.getSvrTimeByOffset()) >= getEndTime() then
		return true
	else
		return false
	end
end

--[[
	@des 	:判断是否刷新
	@return :true 已刷新    false 未刷新
--]]
function refreshOrNot()
	if tonumber(TimeUtil.getSvrTimeByOffset()) >= _nextDayTime then
		return true
	else
		return false
	end
end

--[[
	@des 	:得到特效路径
	@param  :1 热卖 		2 折扣 		3 vip
	@return :路径
--]]
function getEffectPath(p_type)
	if p_type == 1 then
		return "images/base/effect/remai/remai"
	elseif p_type == 2 then
		return "images/base/effect/sdzhekou/sdzhekou"
	else
		return "images/base/effect/sdvip/sdvip"
	end
end