-- FileName: MissonTaskCell.lua
-- Author: shengyixian
-- Date: 2015-08-28
-- Purpose: 悬赏榜任务数据
module("MissionTaskData",package.seeall)
require "db/DB_Bounty_task"

-- 任务信息
local _taskInfo = nil
-- 今日任务累计获得名望值
local _totalFameValue = 0
local _callFunc = nil
--[[
	@des 	: 从后端获取任务进度数据
	@param 	: 
	@return : 
--]]
function getTaskProgressInfo(fun)
	_callFunc = fun
	_taskInfo = {}
	initTaskInfoByDB()
	MissionMainService.getMissionInfo(parseData)
end
--[[
	@des 	: 排序函数，根据任务完成度和id进行排序
	@param 	: 
	@return : 
--]]
function sortFunc(v1,v2)
	if v1[#v1] < v1.maxNum then
		if v2[#v2] < v2.maxNum then
			return v1.id < v2.id
		else
			return true
		end
	else
		if v2[#v2] < v2.maxNum then
			return false
		else
			return v1.id < v2.id
		end
	end
end
--[[
	@des 	: 解析配置初始化任务信息
	@param 	: 
	@return : 
--]]
function initTaskInfoByDB()
	for k,v in pairs(DB_Bounty_task.Bounty_task) do
		local t = DB_Bounty_task.getDataById(v[1])
		-- 增加一个元素，表示当前已经完成的次数
		t[#t + 1] = 0
		table.insert(_taskInfo,t)
	end
	table.sort(_taskInfo,function (v1,v2)
		return v1.id < v2.id
	end)
end
--[[
	@des 	: 解析获取到的数据，将任务进度添加到任务信息中
	@param 	: 
	@return : 
--]]
function parseData(data)
	local taskData = data.missionInfo
	_totalFameValue = 0
	for k,v in pairs(taskData) do
		k = tonumber(k)
		local num = tonumber(v.num)
		if (num > _taskInfo[k].maxNum) then
			num = _taskInfo[k].maxNum
		end
		_taskInfo[k][#(_taskInfo[k]) + 1] = num
		-- 计算累计获得的名望值
		_totalFameValue = _totalFameValue + _taskInfo[k].fame * num
	end
	table.sort(_taskInfo,sortFunc)
	_callFunc()
end
--[[
	@des 	: 获取任务信息
	@param 	: 
	@return : 
--]]
function getTaskInfo( ... )
	return _taskInfo
end
--[[
	@des 	: 获取累计获得的名望值
	@param 	: 
	@return : 
--]]
function getTotalFameValue( ... )
	return _totalFameValue
end












