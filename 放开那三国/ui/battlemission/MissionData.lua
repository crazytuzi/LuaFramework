-- Filename: MissionData.lua
-- Author: llp
-- Date: 2014-6-10
-- Purpose: 军团任务数据层

module("MissionData", package.seeall)
require "db/DB_Legion_citybattle"
require "script/ui/guild/GuildDataCache"
require "script/model/user/UserModel"
require "db/DB_Corps_quest_config"
require "db/DB_Corps_quest"
--[[
	 * @return
	 * 
	 * 'task_num' => int, 今天已经完成任务的数量
	 * 'forgive_time' => int,放弃任务的时间
	 * 'ref_num' => int, 刷新任务的次数
	  va_guildtask： 
	 * 'task' => array
	 * 		(
	 * 			0 => array( 'id' => int, 'status' => int, 'num' => int, ),
	 * 			1...
	 * 			2...
	 * 		)
	 */

--]]
local _taskInfo = nil


function setTaskInfo( p_data )
	_taskInfo = p_data
end

function getTaskInfo( ... )
	return _taskInfo
end

-- 得到task,目前是3个
function getTask( ... )
	return _taskInfo.va_guildtask.task
end


-- 设置 task，刷新的时候修改 
-- added by zhz
function setRefreshData(p_refreshData)
	_taskInfo.va_guildtask.task = p_refreshData
	_taskInfo.ref_num = tonumber(_taskInfo.ref_num) + 1
end

--完成任务时刷新任务数据
function setDoneTaskData( p_doneTaskData )
	_taskInfo.va_guildtask.task = p_doneTaskData
	_taskInfo.task_num = tonumber(_taskInfo.task_num) + 1
end

--放弃任务时刷新上次放弃任务时间
function setForgiveTime( p_time )
	_taskInfo.forgive_time = p_time
end

--设置任务状态
-- p_status 0 可接受 1 进行中
function setTaskStatus( p_pos,p_status)
	_taskInfo.va_guildtask.task[tonumber(p_pos)]["status"] = p_status
end

--得到任务状态
function getTaskStatus( p_pos )
	return tonumber(_taskInfo.va_guildtask.task[tonumber(p_pos)]["status"])
end

--设置任务进度
function setTaskNum( p_pos, p_num )
	_taskInfo.va_guildtask.task[tonumber(p_pos)]["num"] = tonumber(p_num)
end

--得到任务进度
function getTaskNum( p_pos )
	return tonumber(_taskInfo.va_guildtask.task[tonumber(p_pos)]["num"])
end


--根据任务位置得到任务id
function getTaskIdbyPos( p_pos )
	return tonumber(_taskInfo.va_guildtask.task[tonumber(p_pos)]["id"])
end


-- 得到已完成的任务数量
function getFinlishTaskNum( )
	return _taskInfo.task_num
end


--军统任务功能是否开启
function isGuildMissonOpen( ... )
	local nowHallLevel = GuildDataCache.getGuildHallLevel()
	local nowUserLevel = UserModel.getHeroLevel()
	if(nowHallLevel >= getLimitHallLevel() and nowUserLevel >= getLimitUserLevel()) then
		return true
	else
		return false
	end
end

--得到开启军团大厅等级限制
function getLimitUserLevel( ... )
	return tonumber(DB_Corps_quest_config.getDataById(1).userLv)
end

--得到开启人物等级限制
function getLimitHallLevel( ... )
	return tonumber(DB_Corps_quest_config.getDataById(1).hallLv)
end

-- 得到刷新全部的金币数
-- added by zhz
function getRfcGold( )
	local rfcGoldNumber=0
	local refNum= _taskInfo.ref_num
	local corpsQuestConfig = DB_Corps_quest_config.getDataById(1)
	local refreshPay= corpsQuestConfig.refreshPay
	local addPay = tonumber( lua_string_split( corpsQuestConfig.addPay ,",")[1] )
	refreshPay= refreshPay+ addPay*refNum
	if(refreshPay> getMaxRfcGoldNumber() ) then
		refreshPay = getMaxRfcGoldNumber()
	end
	return refreshPay
end

-- 得到最大的刷新次数
-- added by zhz
function getMaxRfcGoldNumber(  )
	local corpsQuestConfig = DB_Corps_quest_config.getDataById(1)
	local addPay= lua_string_split( corpsQuestConfig.addPay ,",")
	local maxGold = tonumber(addPay[2] )
	return maxGold
end


--获得任务完成进度上限
function getMissonCount( p_taskId )
	local taskInfo = DB_Corps_quest.getDataById(p_taskId)
	local completeConditions = string.split(taskInfo.completeConditions, ",")
	return tonumber(completeConditions[3])
end

--得到使用金币完成任务需要花费的金币
function getCompleteTaskGoldByPos( p_pos )
	local taskId = _taskInfo.va_guildtask.task[tonumber(p_pos)]["id"]
	return tonumber(DB_Corps_quest.getDataById(taskId).completeImmediately)
end

--得到任务奖励数据
function getTaskReward( p_pos )
	
	local taskId = _taskInfo.va_guildtask.task[tonumber(p_pos)]["id"]
	local taskInfo = DB_Corps_quest.getDataById(taskId)
	print("p_pos, taskId", p_pos, taskId)

	print_table("taskInfo", taskInfo)
	return taskInfo["questReward"]
end

--
--破坏 修复
function dOrRfunction()
	local cityid = getId()
	local level = getMissionLevel()
	local typeId = getType()
	local cityData = getDataById(cityid)
	print("cityData.cityLevel"..cityData.cityLevel)
	print("level"..level)
	print("typeId"..typeId)
	if(tonumber(cityData.cityLevel)>=tonumber(level))then
		if(tonumber(typeId) == 5)then
			return 1
		elseif(tonumber(typeId) == 6)then
			return 2
		end
	end
end

--
function getNowTaskInfo( ... )
	local taskInfo = nil
	if(_taskInfo == nil)then
		return nil
	end
	for k,v in pairs(_taskInfo.va_guildtask.task) do
		if(tonumber(v.status) ~= 0) then
			taskInfo = v
		end
	end
	return taskInfo
end


function getNowTaskId( ... )
	local taskInfo = getNowTaskInfo()
	if(taskInfo == nil) then
		return nil
	else
		return tonumber(taskInfo.id)
	end
end

-- 得到当前军团任务的任务类型，如果当前没有接受的军团任务则返回0
-- 1贡献装备，显示上交物品框
-- 2贡献宝物，显示上交物品框
-- 3贡献道具，显示上交物品框
-- 4指定副本，显示立即前往按钮，点击后前往对应副本
-- 5对任意城池进行破坏，显示立即前往按钮，点击后前往城池战地图
-- 6对自己城池进行修复，显示立即前往按钮，点击后前往城池战地图
function getNowTaskType( ... )
	local taskId = getNowTaskId()
	if(taskId == nil) then
		return 0
	else
		local taskDataInfo = DB_Corps_quest.getDataById(taskId)
		return tonumber(taskDataInfo.questType)
	end
end

-- 当前任务是否可完成
function nowTaskIsFinish( ... )
	local nowTaskInfo = getNowTaskInfo()
	if(nowTaskInfo) then
		local taskCount = getMissonCount(nowTaskInfo.id)
		if(tonumber(nowTaskInfo.num) >= taskCount) then
			return true
		end
	end
	return false
end

