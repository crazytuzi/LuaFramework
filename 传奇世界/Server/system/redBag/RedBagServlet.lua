--RedBagServlet.lua
--/*-----------------------------------------------------------------
--* Module:  RedBagServlet.lua
--* Author:  Andy
--* Modified: 2016年05月09日
--* Purpose: Implementation of the class RedBagServlet
-------------------------------------------------------------------*/

RedBagServlet = class(EventSetDoer, Singleton)

function RedBagServlet:__init()
	self._doer = {
		[PUSH_CS_RED_BAG]	= RedBagServlet.getRedBag,
	}
end

-- 抢红包
function RedBagServlet:getRedBag(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req, errorCode = protobuf.decode("PushGetRedBag", pbc_string)
	if not player or not req then
		print("decodeProto error! RedBagServlet:PushGetRedBag", errorCode)
		return
	end
	local roleID = player:getID()
	local redBagID = req.redBagID
	if g_RedBagMgr:canGetRedBag(redBagID, roleID) then
		local timeTick = time.toedition("day")
		if g_RedBagMgr:getPlayerTime(roleID) ~= timeTick then
			g_RedBagMgr:setPlayerCount(roleID, 0)
			g_RedBagMgr:setPlayerTime(roleID, timeTick)
		end
		local count, num = math.random(1, 3), g_RedBagMgr:getplayerCount(roleID)
		if num >= REDBAG_DAY_MAX then
			g_RedBagMgr:sendErrMsg2Client(roleID, REDBAG_ERR_MAX, 0, {})
			return
		elseif num + count > REDBAG_DAY_MAX then
			count = REDBAG_DAY_MAX - num
		end
		g_RedBagMgr:setPlayerCount(roleID, num + count)
		g_RedBagMgr:cast2db(roleID)
		player:setBindIngot(player:getBindIngot() + count)
		g_logManager:writeMoneyChange(player:getSerialID(), "", 4, 61, player:getBindIngot(), count, 1)
		local redBag = g_RedBagMgr:getRedBag(redBagID)
		redBag.num = redBag.num - 1
		g_RedBagMgr:sendErrMsg2Client(roleID, REDBAG_ERR_GETREDBAG, 2, {redBag.name, count})
		g_RedBagMgr:addRedbagUser(redBagID, roleID)
		-- local bagPlayer = g_entityMgr:getPlayerBySID(redBag.roleSID)
		-- if bagPlayer then
		-- 	ChatSystem.getInstance():doSystemChat(roleID, "REDBAG_WORDS", {bagPlayer:getID()}, 1)
		-- end
	else
		g_RedBagMgr:sendErrMsg2Client(roleID, REDBAG_ERR_NOBAG, 0, {})
	end
end

function RedBagServlet.getInstance()
	return RedBagServlet()
end

g_eventMgr:addEventListener(RedBagServlet.getInstance())