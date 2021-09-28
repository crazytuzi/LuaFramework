--SharedTaskServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  SharedTaskServlet.lua
 --* Author:  husuorong
 --* Modified: 2016年4月5日
 --* Purpose: 共享任务消息接口
 -------------------------------------------------------------------*/
SharedTaskServlet = class(EventSetDoer, Singleton) 

function SharedTaskServlet:__init()
	self._doer = {
	   [TASK_CS_GET_SHARED_TASK_TIMES] = SharedTaskServlet.doGetSharedTaskTimes,
	   [TASK_CS_ACCEPT_SHARED_TASK] = SharedTaskServlet.doAcceptSharedTask,
	   [TASK_CS_SHARE_TASK] = SharedTaskServlet.doShareTaskToTeamMate,
	   [TASK_CS_CONFIRM_SHARE_TASK] = SharedTaskServlet.doConfirmShareTask,
	   [TASK_CS_LETOUT_MONSTER] = SharedTaskServlet.doFlushTaskMonster,
	   [TASK_CS_GET_SHARED_TASK_PRIZE] = SharedTaskServlet.doGetSharedTaskPrize,
	   [TASK_CS_DELETE_SHARED_TASK] = SharedTaskServlet.doDropSharedTask,
	   [TASK_CS_GET_SHARED_TASK_LIST] = SharedTaskServlet.doRequestSharedTaskList,
	   [TASK_CS_REQ_ADD_SHARED_TASK_TEAM] = SharedTaskServlet.doRequestAddSharedTaskTeam,
}
end

function  SharedTaskServlet:doRequestSharedTaskList(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()

	if player:getLevel() < SHARED_TASK_NEEDLEVEL then
		g_taskServlet:sendErrMsg2Client(player:getID(), -96, 0)
		return
	end
	g_sharedTaskMgr:ComposeSharedTaskList(roleID,sid)
end

function SharedTaskServlet:doRequestAddSharedTaskTeam(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("RequestAddToSharedTaskTeamProtocol" , buffer)
	if not req then
		print('SharedTaskServlet:doRequestAddSharedTaskTeam '..tostring(err))
		return
	end
	local tRoleSid = req.roleSid
	print("SharedTaskServlet:doRequestAddSharedTaskTeam",tRoleSid,taskRank)
	local taskRank = req.taskRank
	g_sharedTaskMgr:RequestAddToSharedTaskTeam(roleID,tRoleSid,taskRank)
end

function SharedTaskServlet:doGetSharedTaskTimes(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	g_sharedTaskMgr:GetSharedTaskPrizeNums(roleID)
end

function SharedTaskServlet:doDropSharedTask(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	g_sharedTaskMgr:deleteSharedTask(roleID,true)
end

function SharedTaskServlet:doAcceptSharedTask(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("AcceptSharedTaskProtocol" , buffer)
	if not req then
		print('SharedTaskServlet:doAcceptSharedTask '..tostring(err))
		return
	end
	local taskRank = req.taskRank
	g_sharedTaskMgr:AcceptSharedTask(roleID,taskRank,1)
end

function SharedTaskServlet:doShareTaskToTeamMate(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("ShareTaskProtocol" , buffer)
	if not req then
		print('SharedTaskServlet:doShareTaskToTeamMate '..tostring(err))
		return
	end
	local taskid = req.taskRank
	g_sharedTaskMgr:ShareTaskToTeamMate(roleID,taskid)
end

function SharedTaskServlet:doConfirmShareTask(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("ConfirmShareTaskProtocol" , buffer)
	if not req then
		print('SharedTaskServlet:doConfirmShareTask '..tostring(err))
		return
	end
	local taskid = req.taskId
	local sRoleID = req.sRoleId
	local result = req.result
	g_sharedTaskMgr:doConfirmSharedTask(roleID,taskid,sRoleID,result)
end

function SharedTaskServlet:doGetSharedTaskPrize(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	g_sharedTaskMgr:doGetSharedTaskPrize(roleID)
end

function SharedTaskServlet:doFlushTaskMonster(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	g_sharedTaskMgr:doFlushTaskMonsters(roleID)
end

function SharedTaskServlet.getInstance()
	return SharedTaskServlet()
end

g_eventMgr:addEventListener(SharedTaskServlet.getInstance())