--QQVipRewardServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  QQVipRewardServlet.lua
 --* Author:  zhihua chu
 --* Modified: 2016年8月8日
 -------------------------------------------------------------------*/

 QQVipRewardServlet = class(EventSetDoer, Singleton)

function QQVipRewardServlet:__init()
	self._doer = {
		[QQVIP_CS_REWARD_INFO]	=		QQVipRewardServlet.doGetQQVipRewardInfo,
		[QQVIP_CS_GET_REWARD]	=		QQVipRewardServlet.doGetReward,
		[QQVIP_CS_CHARGE_FINISH]	=		QQVipRewardServlet.doFinishCharge,
}
end

function QQVipRewardServlet:doGetQQVipRewardInfo(event)
	print("QQVipRewardServlet:doGetQQVipRewardInfo")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("QQVipRewardInfoRequest" , pbc_string)
	if not req then
		print('QQVipRewardServlet:doGetQQVipRewardInfo '..tostring(err))
		return
	end

	local  roleSID = tostring(dbid)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_QQVipRewardMgr:getQQVipRewardInfo(roleSID)
	end
end

function QQVipRewardServlet:doGetReward(event)
	print("QQVipRewardServlet:doGetReward")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("QQVipGetRewardRequest" , pbc_string)
	if not req then
		print('QQVipRewardServlet:doGetReward '..tostring(err))
		return
	end

	local  roleSID = tostring(dbid)
	local id = req.type
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_QQVipRewardMgr:getReward(roleSID, id)
	end
end

function QQVipRewardServlet:doFinishCharge(event)
	print("QQVipRewardServlet:doFinishCharge")
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("QQVipChargeFinishRequest" , pbc_string)
	if not req then
		print('QQVipRewardServlet:doFinishCharge '..tostring(err))
		return
	end

	local  roleSID = tostring(dbid)
	local chargeType = req.type
	local accessToken = req.accessToken
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_QQVipRewardMgr:finishCharge(roleSID, chargeType, accessToken)
	end
end

function QQVipRewardServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(self:getCurEventID(), roleId, EVENT_QQVIP_SETS, errId, paramCount, params)
end

function QQVipRewardServlet.getInstance()
	return QQVipRewardServlet()
end

g_eventMgr:addEventListener(QQVipRewardServlet.getInstance())