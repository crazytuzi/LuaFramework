--ActivityNormalServlet.lua
--/*-----------------------------------------------------------------
--* Module:  ActivityNormalServlet.lua
--* Author:  Andy
--* Modified: 2016年06月07日
--* Purpose: Implementation of the class ActivityNormalServlet
-------------------------------------------------------------------*/

ActivityNormalServlet = class(EventSetDoer, Singleton)

function ActivityNormalServlet:__init()
	self._doer = {
		[ACTIVITY_NORMAL_CS_REQ]					= ActivityNormalServlet.reqNormalData,
		[ACTIVITY_NORMAL_CS_ACTIVENESS_REWARD]		= ActivityNormalServlet.reward,
		[ACTIVITY_NORMAL_CS_FIND_REWARD_LIST] 		= ActivityNormalServlet.reqFindRewardList,
		[ACTIVITY_NORMAL_CS_GET_FIND_REWARD] 		= ActivityNormalServlet.reqGetFindReward,
		[ACTIVITY_NORMAL_CS_GET_ALL_FIND_REWARD] 	= ActivityNormalServlet.reqGetAllFindReward,
		[ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN]			= ActivityNormalServlet.canJoin,
		[ACTIVITY_NORMAL_CS_CALENDAR]				= ActivityNormalServlet.getCalendar,
		[ACTIVITY_NORMAL_CS_ACTIVENESS_REQ]			= ActivityNormalServlet.getActiveness,
	}
end

--请求日常活动数据
function ActivityNormalServlet:reqNormalData(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityNormalReq")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then
		return
	end
	local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
	local normalConfig = g_normalMgr:getNormalConfigByTab(req.tab)
	if not normalConfig or not playerInfo then
		return
	end
	local level, factionID = player:getLevel(), player:getFactionID()
	local info = {}
	for _, config in pairs(normalConfig) do
		local tmp = {}
		tmp.id = config.id
		tmp.times = playerInfo:getActivenessTimes(config.type)
		tmp.errCode = ACTIVITY_NORMAL_ERR_CODE.CAN_JOIN
		if level < config.level then
			tmp.errCode = ACTIVITY_NORMAL_ERR_CODE.LEVEL
			tmp.arg = config.level
		elseif config.type == ACTIVENESS_TYPE.MANOR_WAR or config.type == ACTIVENESS_TYPE.CENTER_WAR or config.type == ACTIVENESS_TYPE.SHA_WAR or config.type == ACTIVENESS_TYPE.FACTION_DART
			or config.type == ACTIVENESS_TYPE.FACTION_TASK then
			local faction = g_factionMgr:getFaction(factionID)
			if not faction then
				tmp.errCode = ACTIVITY_NORMAL_ERR_CODE.NO_FACTION
			end
		elseif config.type == ACTIVENESS_TYPE.FACTION_BOSS or config.type == ACTIVENESS_TYPE.INVADE or config.type == ACTIVENESS_TYPE.GOU_HUO then
			local faction = g_factionMgr:getFaction(factionID)
			if (config.type == ACTIVENESS_TYPE.INVADE or config.type == ACTIVENESS_TYPE.GOU_HUO) and (not faction or faction:getLevel() < FACTION_AREA_NEED_LEVEL) then
				tmp.errCode = ACTIVITY_NORMAL_ERR_CODE.FACTION_LEVEL
				tmp.arg = FACTION_AREA_NEED_LEVEL
			elseif config.type == ACTIVENESS_TYPE.FACTION_BOSS and (not faction or faction:getLevel() < 2) then
				tmp.errCode = ACTIVITY_NORMAL_ERR_CODE.FACTION_LEVEL
				tmp.arg = 2
			end
		end
		if tmp.errCode == ACTIVITY_NORMAL_ERR_CODE.CAN_JOIN and config.activityID > 0 then
			local startTime = g_normalLimitMgr:getActivityStartTime(config.activityID)
			if startTime > 0 then
				tmp.errCode = ACTIVITY_NORMAL_ERR_CODE.CLOSE
				tmp.arg = startTime
			end
		end
		table.insert(info, tmp)
	end
	fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_RET, "ActivityNormalRet", {info = info})
end

--领取活跃度奖励
function ActivityNormalServlet:reward(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityNormalActivenessReward")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end
	local roleID = player:getID()
	local playerInfo = g_normalMgr:getPlayerInfo(roleID)
	local itemMgr = player:getItemMgr()
	if itemMgr and playerInfo and req and playerInfo:activenessReward(req.integral) then
		local reward = g_normalMgr:getActivenessReward(req.integral)
		if reward then
			if itemMgr:getEmptySize(Item_BagIndex_Bag) < table.size(reward) then
				g_ActivityMgr:sendRewardByEmail(player:getSerialID(), reward, 37)
			else
				for _, item in pairs(reward) do
					itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
					g_logManager:writePropChange(dbid, 1, 37, item.itemID, 0, item.count, item.bind)
				end
				g_ActivityMgr:sendErrMsg2Client(roleID, ACTIVITY_ERR_SUCCESS, 0, {})
			end
			g_normalMgr:pushActiveness(roleID)
			g_tlogMgr:TlogActivityRewardFlow(player, playerInfo:getIntegral(), ACTIVENESS_DROPID[req.integral])
		end
	end
	-- fireProtoMessage(roleID, ACTIVITY_NORMAL_SC_ACTIVENESS_REWARD_RET, "ActivityNormalActivenessRewardRet", {status = status})
end

function _sendFindRewardList(player)
	local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
	if not playerInfo then
		return
	end
	local list = {}
	local findReward = playerInfo:getCanGetFindReward()
	for _, reward in pairs(findReward) do
		local tmp = {}
		tmp.id = reward.id
		tmp.times = reward.times
		table.insert(list, tmp)
	end
	fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_FIND_REWARD_LIST_RET, "ActivityNormalFindRewardListRet", {list = list})
end

--请求找回奖励列表
function ActivityNormalServlet:reqFindRewardList(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityNormalFindRewardList")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then
		return
	end
	_sendFindRewardList(player)
end

--请求领取找回奖励
function ActivityNormalServlet:reqGetFindReward(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityNormalGetFindReward")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then
		return
	end
	local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
	if not playerInfo then
		return
	end
	if 2 == req.type then
		if not playerInfo:getFindReward2(player, req.id) then
			fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_FIND_REWARD_RET, "ActivityNormalGetFindRewardRet", {id = req.id, type = req.type, result = 1})
		end
		return
	end
	local result = 1
	local str
	local res = false
	local byEmail = false
	res, str, byEmail = playerInfo:getFindRewardById(player, req.id, req.type)
	if res then
		result = 0
	else
		result = 1
	end
	fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_FIND_REWARD_RET, "ActivityNormalGetFindRewardRet", {id = req.id, type = req.type, result = result})
	_sendFindRewardList(player)
	if str and string.len(str) ~= 0 then
		if not byEmail then
			g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_NORMAL_GET_FIND_REWARE_TIPS, 1, {str})
		else
			g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_EMAIL_GET_FIND_REWARE_TIPS, 0, {})
		end
	end
end

--请求一键领取找回奖励
function ActivityNormalServlet:reqGetAllFindReward(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityNormalGetAllFindReward")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then
		return
	end
	local playerInfo = g_normalMgr:getPlayerInfo(player:getID())
	if not playerInfo then
		return
	end
	local result = 1
	local str
	local res = false
	local byEmail = false
	res, str, byEmail = playerInfo:getAllFindReward(player, req.type)
	if 2 == req.type then	--元宝支付异步处理
		if res then
			return
		else
			fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_ALL_FIND_REWARD_RET, "ActivityNormalGetAllFindRewardRet", {type = req.type, result = result})
		end
	end
	if res then
		result = 0
	else
		result = 1
	end
	fireProtoMessage(player:getID(), ACTIVITY_NORMAL_SC_GET_ALL_FIND_REWARD_RET, "ActivityNormalGetAllFindRewardRet", {type = req.type, result = result})
	_sendFindRewardList(player)
	if str and string.len(str) ~= 0 then
		--str = "奖励领取成功！"
		if not byEmail then
			g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_NORMAL_GET_ALL_FIND_REWARE_TIPS, 0, {})
		else
			g_normalMgr:sendErrMsg2Client(player:getID(), ACTIVITY_EMAIL_GET_FIND_REWARE_TIPS, 0, {})
		end
	end
end

function ActivityNormalServlet:canJoin(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local req = self:decodeProto(pbc_string, "ActivityNormalCanJoin")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not req or not player then
		return
	end
	local roleID = player:getID()
	fireProtoMessage(roleID, ACTIVITY_NORMAL_CS_CHECK_CAN_JOIN_RET, "ActivityNormalCanJoinRet", {canJoin = g_normalLimitMgr:canJoin(roleID, req.activityID)})
end

function ActivityNormalServlet:getCalendar(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local ret = {}
	local _, timeStr = g_manorWarMgr:getManorOpenTime()
	ret.show1, ret.week1 = self:calendarOpen(timeStr)
	_, timeStr = g_manorWarMgr:getZhongzhouOpenTime()
	ret.show2, ret.week2 = self:calendarOpen(timeStr)
	_, timeStr = g_shaWarMgr:getOpenTime()
	ret.show3, ret.week3 = self:calendarOpen(timeStr)
	fireProtoMessageBySid(dbid, ACTIVITY_NORMAL_SC_CALENDAR_RET, "ActivityNormalCalendarRet", ret)
end

function ActivityNormalServlet:calendarOpen(timeStr)
	-- timeStr = "*,*,*,6,19:00:00-20:00:00,25"
	local data = StrSplit(timeStr, ",")
	local now, startTime, delayDay = os.time(), g_ActivityMgr:getStartTime(), data[6] or 0
	local timeTick = startTime + delayDay * DAY_SECENDS
	local week = g_normalLimitMgr:nowWeek(timeTick)
	timeTick = timeTick + (7 - week) * DAY_SECENDS
	local t = os.date("*t", timeTick)
	-- timeTick:活动开启那周周日最后一刻
	timeTick = os.time({year = t.year, month = t.month, day = t.day, hour = 23, min = 59, sec = 59})
	if now > timeTick then
		return true, 0
	else
		if math.ceil(os.difftime(timeTick, WEEK_START_TIME) / WEEK_SECENDS) == math.ceil(os.difftime(now, WEEK_START_TIME) / WEEK_SECENDS) then
			return true, week
		else
			return false, 0
		end
	end
end

function ActivityNormalServlet:getActiveness(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then
		g_normalMgr:pushActiveness(player:getID())
	end
end

function ActivityNormalServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! ActivityNormalServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function ActivityNormalServlet.getInstance()
	return ActivityNormalServlet()
end

g_eventMgr:addEventListener(ActivityNormalServlet.getInstance())