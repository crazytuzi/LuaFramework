--LitterfunServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  LitterfunServlet.lua
 --* Author:  seezon
 --* Modified: 2014年12月19日
 --* Purpose: 小功能消息接口
 -------------------------------------------------------------------*/

LitterfunServlet = class(EventSetDoer, Singleton)

function LitterfunServlet:__init()
	self._doer = {
		[FRAME_CS_ACCELERATE] = LitterfunServlet.doDealAccelerate,
		--[LITTERFUN_TARGET_CS_CHECK] = LitterfunServlet.doDealCheckReward,			--玩家查询可获取的目标奖励	20150302
		--[LITTERFUN_TARGET_CS_OWNGET] = LitterfunServlet.doDealOwnGetReward,		--玩家领取目标奖励			20150302
}
end

function LitterfunServlet:doDealAccelerate(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local player = g_entityMgr:getPlayer(roleID)
	local roleInfo = g_litterfunMgr:getRoleInfo(roleID)
	if player and roleInfo then
		local locktime= {0,600,3600,21600,86400,604800}
		local accelerateData = roleInfo:getAccelerateData()
		local accelerateCnt = accelerateData.cnt or 0
		local accelerateTime = accelerateData.t or 0
		local nd = time.toedition("day")
		if nd == accelerateTime then
			accelerateData.cnt = accelerateCnt + 1
		else 
			accelerateData.cnt = 1
			accelerateData.t = nd
		end
		local tips = {[1]=6,[2]=7,[3]=8,[4]=9,[5]=10,[6]=11}
		self:sendErrMsg2Client(roleID, tips[accelerateData.cnt] or tips[1], 0)
		if locktime[accelerateData.cnt] and locktime[accelerateData.cnt] > 0 then
			g_entityDao:lockUser(player:getSerialID(), os.time() + locktime[accelerateData.cnt])
			print("[Lock User]! %d",player:getSerialID())
		end
	end
end

--给客户端发送错误提示的接口
function LitterfunServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(EVENT_LITTERFUN_SETS)
	retBuff:pushShort(errId)
	retBuff:pushShort(self:getCurEventID())
	retBuff:pushChar(paramCount)
	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end

	g_engine:fireLuaEvent(roleId, retBuff)
end

function LitterfunServlet.getInstance()
	return LitterfunServlet()
end


g_eventMgr:addEventListener(LitterfunServlet.getInstance())