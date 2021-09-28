--TargetRewardServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  TargetRewardServlet.lua
 --* Author:  liucheng
 --* Modified: 2016年03月21日
 --* Purpose: 目标奖励
 -------------------------------------------------------------------*/

TargetRewardServlet = class(EventSetDoer, Singleton)

function TargetRewardServlet:__init()
	self._doer = {
		[TARGETREWARD_CS_CHECK] = TargetRewardServlet.doDealCheckReward,	--玩家查询可获取的目标奖励	20150302
		[TARGETREWARD_CS_GET] 	= TargetRewardServlet.doDealOwnGetReward,	--玩家领取目标奖励			20150302
}
end

--客户端查询将领取的目标奖励	20150302
function TargetRewardServlet:doDealCheckReward(buffer1)	--	--roleID
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("CheckTargetRewardProtocol" , pbc_string)
	if not req then
		print('TargetRewardServlet:doDealCheckReward '..tostring(err))
		return
	end	

	local tplayer = g_entityMgr:getPlayerBySID(roleSID)
	if not tplayer then
		print("TargetRewardServlet:doDealCheckReward no player")
		return
	end

	local roleID = tplayer:getID()			--玩家动态ID	
	local tSchool = tplayer:getSchool()
	local roleSID = tplayer:getSerialID()
	--local RoleInfo = g_litterfunMgr:getRoleInfo(roleID)
	local RoleInfo = g_TargetRewardMgr:getRoleInfoBySID(roleSID)
	if not RoleInfo then return end

	local TargetRecordID = RoleInfo:GetTargetReward(tSchool)
	if TargetRecordID then
		local retData = {}
		retData.targetRewardID = TargetRecordID
		fireProtoMessage(tplayer:getID(),TARGETREWARD_SC_CHECK_RET,"CheckTargetRewardRetProtocol",retData)
	end
end

--玩家领取目标奖励	20150302
function TargetRewardServlet:doDealOwnGetReward(buffer1)		---	--roleID,Record
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("GetTargetRewardProtocol" , pbc_string)
	if not req then
		print('TargetRewardServlet:doDealOwnGetReward '..tostring(err))
		return
	end	

	local tplayer = g_entityMgr:getPlayerBySID(roleSID)
	if not tplayer then
		print("TargetRewardServlet:doDealOwnGetReward no player")
		return
	end

	local RecordID = req.targetRewardID			--目标奖励在表中的记录ID

	--找到玩家静态ID
	local RoleInfo = g_TargetRewardMgr:getRoleInfoBySID(roleSID)
	if not RoleInfo then
		print("TargetRewardServlet:doDealOwnGetReward not RoleInfo")
		return
	end
	RoleInfo:OwnGetReward(tplayer,RecordID)
end

function TargetRewardServlet.getInstance()
	return TargetRewardServlet()
end

g_eventMgr:addEventListener(TargetRewardServlet.getInstance())