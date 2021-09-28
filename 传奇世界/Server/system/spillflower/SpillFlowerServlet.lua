--SpillFlowerServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  SpillFlowerServlet.lua
 --* Author:  liucheng
 --* Modified: 2015年8月26日
 --* Purpose: 撒花功能消息接口 
 -------------------------------------------------------------------*/

require "system.spillflower.SpillFlowerManager"

SpillFlowerServlet = class(EventSetDoer, Singleton)

function SpillFlowerServlet:__init()
	self._doer = {
		--[SPILLFLOWER_CS_REQ] = SpillFlowerServlet.SpillFlowerReq,
		[SPILLFLOWER_CS_CALLMEMBER] 		= SpillFlowerServlet.CallMemberReq,
		[SPILLFLOWER_CS_SENDMEMBER] 		= SpillFlowerServlet.SendToMember,
		
		[RELATION_CS_GIVEFLOWER]			= SpillFlowerServlet.GiveFlower,
		[RELATION_CS_GETREMAINFLOWERNUM]	= SpillFlowerServlet.GetFlowerSendInfo,
		[RELATION_CS_FLOWERRECORD]			= SpillFlowerServlet.GetFlowerRecord,
		[RELATION_CS_TOTALFLOWER]			= SpillFlowerServlet.GetAllSendFlower,
	}

	if g_spaceID == 0 or g_spaceID == SPILLFLOWER_PUBLIC_SPACE then			
		--g_frame:registerMsg(TEAM_CS_GET_TEAMINFO, false)
		require "system.spillflower.SpillFlowerPublic"
	end
end

--使用穿云箭
function SpillFlowerServlet:CallMemberReq(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("CallFactionMemProtocol" , pbc_string)
	if not req then
		print('SpillFlowerServlet:CallMemberReq '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SpillFlowerServlet:CallMemberReq no player")
		return
	end
	local slotIndex = req.slotIndex or 0

	if g_SpillFlowerMgr:getArrowActive()<1 then return end
	g_SpillFlowerMgr:CallMember(player,slotIndex)
end

--传送到穿云箭玩家周围
function SpillFlowerServlet:SendToMember(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local req, err = protobuf.decode("SendFactionMemProtocol" , pbc_string)
	if not req then
		print('FactionServlet:doCreateFaction '..tostring(err))
		return
	end

	local roleSID = params[2]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SpillFlowerServlet:SendToMember no player")
		return
	end

	local TRoleSID = req.targetSID
	local TRoleMapID = req.targetMapID
	local TRolePos = req.targetPos

	if g_SpillFlowerMgr:getArrowActive()<1 then return end
	if TRoleSID ~= "" then 		--TRoleSID>0
		g_SpillFlowerMgr:SendToMember(player,TRoleSID,TRoleMapID,TRolePos)
	end
end

function SpillFlowerServlet:GiveFlower(event)
	local params = event:getParams()
	local pbc_string, dbid, hGate = params[1], params[2], params[3]
	local req, err = protobuf.decode("GiveFlowerProtocol" , pbc_string)
	if not req then
		print('SpillFlowerServlet:GiveFlower '..tostring(err))
		return
	end

	local roleSID = dbid
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SpillFlowerServlet:GiveFlower no player")
		return
	end

    local targetSid = req.targetSID
	local targetName = req.targetName
    local giveType = req.giveType
    local giveNum = req.giveNum
    if g_SpillFlowerMgr:getFlowerActive()<1 then return end
	g_SpillFlowerMgr:GiveFlower(player,targetSid,targetName,giveType,giveNum)
end

function SpillFlowerServlet:GetFlowerSendInfo(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("GetRemainFlowerProtocol" , pbc_string)
	if not req then
		print('SpillFlowerServlet:GetFlowerSendInfo '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SpillFlowerServlet:GetFlowerSendInfo no player")
		return
	end
	
	if g_SpillFlowerMgr:getFlowerActive()<1 then return end
	g_SpillFlowerMgr:getRemainFlowerNum(player)
end

function SpillFlowerServlet:GetFlowerRecord(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("GetFlowerRecordProtocol" , pbc_string)
	if not req then
		print('SpillFlowerServlet:GetFlowerRecord '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SpillFlowerServlet:GetFlowerRecord no player")
		return
	end
	
	if g_SpillFlowerMgr:getFlowerActive()<1 then return end
	g_SpillFlowerMgr:getFlowerRecord(player)
end

function SpillFlowerServlet:GetAllSendFlower(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("GetTotalFlowerProtocol" , pbc_string)
	if not req then
		print('SpillFlowerServlet:GetFlowerRecord '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SpillFlowerServlet:GetFlowerRecord no player")
		return
	end
	local roleID = player:getID()
	--local retNum = player:getTotalGlamour()
	local retNum = player:getGlamour()

	local retData = {}
	retData.totalFlower = retNum
	fireProtoMessage(roleID,RELATION_SC_TOTALFLOWER_RET,"TotalFlowerRetProtocol",retData)
end

function SpillFlowerServlet.getInstance()
	return SpillFlowerServlet()
end

g_eventMgr:addEventListener(SpillFlowerServlet.getInstance())