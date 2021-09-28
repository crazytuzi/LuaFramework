--ShaWarServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  ShaWarServlet.lua
 --* Author:  seezon
 --* Modified: 2015年8月26日
 --* Purpose: 沙巴克系统消息接口
 -------------------------------------------------------------------*/

ShaWarServlet = class(EventSetDoer, Singleton)

function ShaWarServlet:__init()
	self._doer = {
	    [SHAWAR_CS_GOTOSHA]	=			ShaWarServlet.doGotoSha,
		[SHAWAR_CS_PICKREWARD]	=		ShaWarServlet.doPickShaReward,
		[SHAWAR_CS_GETSHAINFO]	=		ShaWarServlet.doGetShaInfo,
		[SHAWAR_CS_DEALHOLD]	=		ShaWarServlet.doDealHold,
		[SHAWAR_CS_GETRECORD]	=		ShaWarServlet.doGetRecord,
		[SHAWAR_CS_GETLEADER]	=		ShaWarServlet.doGetLeader,
		[SHAWAR_CS_NEED_RELIVE]	=		ShaWarServlet.doNeedRelive,
		[SHAWAR_CS_REQUEST_UPDATE_MONIWAR_STAGE]	=		ShaWarServlet.requestUpdateMoniWarStage,
}
end

--传送去沙巴克
function ShaWarServlet:doGotoSha(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GotoShaProtocol" , pbc_string)
	if not req then
		print('ShaWarServlet:doGotoSha '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

    g_shaWarMgr:gotoSha(player:getID())
end

--领取每日奖励
function ShaWarServlet:doPickShaReward(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ShaPickRewardProtocol" , pbc_string)
	if not req then
		print('ShaWarServlet:doPickShaReward '..tostring(err))
		return
	end

	local roleID = dbid

    g_shaWarMgr:pickShaReward(roleID)
end

--获取沙巴克界面信息
function ShaWarServlet:doGetShaInfo(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GetShaInfoProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doGetShaInfo '..tostring(err))
		return
	end

	g_shaWarMgr:getShaInfo(dbid)
end

--处理驻守事件
function ShaWarServlet:doDealHold(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("DealHoldProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doDealHold '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

	local doorIndex = req.holeIndex
	local dealType = req.dealType

    g_shaWarMgr:dealHold(player:getID(), dealType, doorIndex)
end

--拉取攻沙日志
function ShaWarServlet:doGetRecord(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ShaGetRecordProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doGetRecord '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

    g_shaWarMgr:getRecord(player:getID())
end

--拉取沙巴克城主信息
function ShaWarServlet:doGetLeader(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ShaGetLeaderProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doGetLeader '..tostring(err))
		return
	end
	print("ShaWarServlet:doGetLeader>>>>>>>",dbid)
	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

    local shaFacId = g_shaWarMgr:getShaFactionId()
    local faction = g_factionMgr:getFaction(shaFacId)

    local ret = {}
    if faction then
    	local leader = faction:getMember(faction:getLeaderID())
		if leader then
			ret.sex = leader:getSex()
			ret.school = leader:getSchool()
			ret.name = faction:getLeaderName()
		end 
    end
	fireProtoMessage(player:getID(), SHAWAR_SC_GETLEADER_RET, 'ShaGetLeaderRetProtocol', ret)
end

--原地复活
function ShaWarServlet:doNeedRelive(event)
    local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ShaNeedReliveProtocol" , pbc_string)
	if not req then
		print('TaskServlet:doNeedRelive '..tostring(err))
		return
	end

	local roleID = dbid
	local player = g_entityMgr:getPlayerBySID(roleID)

    g_shaWarMgr:needRelive(player:getID())
end

function ShaWarServlet:requestUpdateMoniWarStage(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("ShaWarRequestUpdateMoniWarStage" , pbc_string)
	if not req then
		print('ShaWarServlet:requestUpdateMoniWarStage '..tostring(err))
		return
	end
	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print('cannot find role by sid('..roleSID..')')
	end
	local taskID = g_taskMgr:getMainTaskId(player:getID())
	if not taskID or taskID ~= 10041 then
		print(''..roleSID..' has no monishawar task')
		return
	end
	huang_gong_mapid = 2117
	if req.stage == 1 then
		if player:getMapID() ~= 2116 then
			print(''..roleSID..' is not in map(2116)')
			return
		end
		if player:getMapID() == huang_gong_mapid then
			print(''..roleSID..' is in map('..huang_gong_mapid..')')
			return
		end
		local roleInfo = g_taskMgr:getRoleTaskInfoBySID(player:getSerialID())
		if not roleInfo then
			print(''..roleSID..' cannot find task info')
			return
		end
		if roleInfo:getMainTask():getStatus() == TaskStatus.Done then
			print(''..roleSID..' moni-shawar task has been done')
			return
		end
			
		local ret = g_sceneMgr:enterPublicScene(player:getID(), huang_gong_mapid, 24, 25)
		if not ret then
			print(''..roleSID..' cannot enter '..huang_gong_mapid)
			return
		end
	end
	if req.stage == 2 then
		if player:getMapID() ~= huang_gong_mapid then
			print(''..roleSID..' is not in map('..huang_gong_mapid..')')
			return
		end
		player:setCampID(0)
		player:getBuffMgr():addBuff(30, errCode, player, 0, 30*60*1000)
	end
	if req.stage == 3 then
		if player:getMapID() ~= huang_gong_mapid then
			print(''..roleSID..' is not in map('..huang_gong_mapid..')')
			return
		end
		g_taskMgr:NotifyListener(player, "onShabakeSuc")
		g_sceneMgr:enterPublicScene(player:getID(), player:getLastMapID(), player:getLastPosX(), player:getLastPosY())
	end
end


--给客户端发送错误提示的接口
function ShaWarServlet:sendErrMsg2Client(roleId, errId, paramCount, params)
	local ret = {}
	ret.eventId = EVENT_SHAWAR_SET
	ret.eCode = errId
	ret.mesId = self:getCurEventID()
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end
	
	
	if roleId > 0 then
		fireProtoMessage(roleId, FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
	else
		boardProtoMessage(FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
	end
end

--给客户端发送错误提示的接口
function ShaWarServlet:sendErrMsg2Client2(dbId, hGate, errId, paramCount, params)
	fireProtoSysMessageBySid(self:getCurEventID(), dbId, EVENT_SHAWAR_SET, errId, paramCount, params)
end

--只给皇宫和沙巴克的人广播
function ShaWarServlet:notifyShaPlayer(errId, paramCount, params)
	local ret = {}
	ret.eventId = EVENT_SHAWAR_SET
	ret.eCode = errId
	ret.mesId = self:getCurEventID()
	ret.param = {}
	paramCount = paramCount or 0
	for i=1, paramCount do
		table.insert(ret.param, params[i] and tostring(params[i]) or "")
	end

	local scene = g_sceneMgr:getPublicScene(SHAWAR_MAP_ID)
	boardSceneProtoMessage(scene:getID(), FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
	scene = g_sceneMgr:getPublicScene(SHAWAR_PALACE_MAP_ID)
	boardSceneProtoMessage(scene:getID(), FRAME_SC_MESSAGE, 'FrameScMessageProtocol', ret)
end

function ShaWarServlet.getInstance()
	return ShaWarServlet()
end

g_eventMgr:addEventListener(ShaWarServlet.getInstance())