--TaskEventParse.lua
--/*-----------------------------------------------------------------
 --* Module:  TaskEventParse.lua
 --* Author:  seezon
 --* Modified: 2014年4月11日
 --* Purpose: Implementation of the class TaskEventParse
 -------------------------------------------------------------------*/



-- 悬赏任务20160106
--TASK_CS_REWARDTASK_REQ
CSREWARDTAKREQ = {}
CSREWARDTAKREQ.readFun = function(buffer)
	local roleID = buffer:popInt()
	local actionType = buffer:popInt()
	local param1 = buffer:popInt()
	local param2 = buffer:popInt()
	local data = {}
	data[1] = roleID
	data[2] = actionType
	data[3] = param1
	data[4] = param2
	return data
end

--TASK_SC_ADD_REWARD_TASK
SCADDREWARDTASK = {}
SCADDREWARDTASK.writeFun = function(taskID, isNew, taskGUID, targetStateData)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TASK_SC_ADD_REWARD_TASK)
	retBuff:pushInt(taskID)
	retBuff:pushChar(isNew)
	retBuff:pushInt(taskGUID)
	local targetNum = table.size(targetStateData)
	retBuff:pushChar(targetNum)
	for i=1,targetNum do
		retBuff:pushInt(targetStateData[i])
	end
	return retBuff
end

SCFINISHREWARDTASK = {}
SCFINISHREWARDTASK.writeFun = function(actionType)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TASK_SC_FINISH_REWARD_TASK)
	retBuff:pushInt(actionType)
	return retBuff
end

SCREWARDTASKTARRGETSTATECHANGE = {}
SCREWARDTASKTARRGETSTATECHANGE.writeFun = function(taskID, targetStateData)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(TASK_SC_REWARD_TARGET_STATE_CHANGE)
	retBuff:pushInt(taskID)
	local targetNum = table.size(targetStateData)
	retBuff:pushChar(targetNum)
	for i=1,targetNum do
		retBuff:pushInt(targetStateData[i])
	end
	
	return retBuff
end

SCADDSHAREDTASK = {}
SCADDSHAREDTASK.writeFun = function(taskID,targetStateData,taskOwner,targetPos)
	--print("SCADDSHAREDTASK.writeFun",toString(targetPos),serialize(targetPos))
	local ret = {}
	ret.taskId = taskID
	ret.taskOwner = taskOwner
	local targetNum = 0
	if taskID > 0 then
		targetNum = table.size(targetStateData)
	else
		targetNum = 0
	end
	ret.taskNum = targetNum
	ret.taskState = {}
	for i=1,targetNum do
		table.insert(ret.taskState,targetStateData[i])
	end
	ret.taskTargetPos = serialize(targetPos)
	return ret
end
SCFINISHSHAREDTASK = {}
--TASK_SC_FINISH_DAILY_TASK后端写消息
SCFINISHSHAREDTASK.writeFun = function(taskID)
	--local retBuff = LuaEventManager:instance():getLuaRPCEvent(TASK_SC_FINISH_SHARED_TASK)
	--retBuff:pushInt(taskID)
	local ret = {}
	ret.taskId = taskID
	return ret
end

SCSHAREDTASKTARRGETSTATECHANGE = {}
SCSHAREDTASKTARRGETSTATECHANGE.writeFun = function(taskID, targetStateData)
	--[[local retBuff = LuaEventManager:instance():getLuaRPCEvent(TASK_SC_SHARED_TARGET_STATE_CHANGE)
	retBuff:pushInt(taskID)
	local targetNum = table.size(targetStateData)
	retBuff:pushChar(targetNum)
	for i=1,targetNum do
		retBuff:pushInt(targetStateData[i])
	end]]
	local ret = {}
	ret.taskId = taskID
	local targetNum = table.size(targetStateData)
	ret.taskNum = targetNum
	ret.taskStates = {}
	for i=1,targetNum do
		table.insert(ret.taskStates,targetStateData[i])
	end
	return ret
end