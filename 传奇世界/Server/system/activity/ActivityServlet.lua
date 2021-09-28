--ActivityServlet.lua
--/*-----------------------------------------------------------------
--* Module:  ActivityServlet.lua
--* Author:  Andy
--* Modified: 2015年9月26日
--* Purpose: Implementation of the class ActivityServlet
-------------------------------------------------------------------*/

ActivityServlet = class(EventSetDoer, Singleton)

function ActivityServlet:__init()
	self._doer = {
		[ACTIVITY_CS_REQ]		    = ActivityServlet.ActivityReq,
		[ACTIVITY_CS_SIGNIN]		= ActivityServlet.SignIn,
		[ACTIVITY_CS_RESIGN_REQ]	= ActivityServlet.ReSign,
		[ACTIVITY_CS_ACTICODE_REQ]	= ActivityServlet.Acticode,
	}
end

-- 活动数据请求
function ActivityServlet:ActivityReq(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "ActivityReq")
	if not req then
		warning("require param nil.")
		return
	elseif not player then
		warning("not player by dbid:" .. dbid)
		return
	end
	local modelID, activityID, flag = req.modelID, req.activityID, req.flag 	-- flag:0:请求 1:领奖 2:月卡续费
	local User = g_ActivityMgr:getUserActivity(player:getID(), modelID, activityID)
	if User then
		if flag == 0 then
			User:req(req.index)
		elseif flag == 1 then
			User:reward(req.index)
		elseif flag == 2 then
			User:renew(req.index)
		else
			warning("require flag error. flag:" .. flag)
		end
	else
		warning("not userActivity. dbid:" .. dbid .. "modelID:" .. modelID .."activityID:" .. activityID)
	end
end

-- 签到
function ActivityServlet:SignIn(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then return end
	local User = g_ActivityMgr:getUserActivity(player:getID(), ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID)
	if User then
	    User:signIn()
	end
end

-- 补签
function ActivityServlet:ReSign(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityReSignIn")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then return end
	local times = req.times
	local User = g_ActivityMgr:getUserActivity(player:getID(), ACTIVITY_MODEL.SIGNIN, ACTIVITY_SIGNIN_ID)
	if User then
	    User:reSign(times)
	end
	
end

-- 输入激活码进行激活
function ActivityServlet:Acticode(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityActCode")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then return end
	local User = g_ActivityMgr._UserCode[player:getID()]
	if User then
		User:newUseCode(req.code, req.gameID)
	end
end

--使用物品
function ActivityServlet:UseItem(dbid,nItemId,nActivityModule,nActivityId)
	--print("---use2.5---"..tostring(dbid))
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then 
		return 0; 
	end
	--print("---use3---"..tostring(player:getID()).."--"..tostring(nActivityModule).."--"..tostring(nActivityId))
	local tActivity = g_ActivityMgr:getUserActivity(player:getID(), nActivityModule, nActivityId)
	if tActivity then
		--print("---use4---")
		return tActivity:useItem(nItemId,nActivityModule,nActivityId);
	end
	return 0;
end

function ActivityServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! ActivityServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function ActivityServlet.getInstance()
	return ActivityServlet()
end

g_eventMgr:addEventListener(ActivityServlet.getInstance())

g_ActivityServlet = ActivityServlet.getInstance()
