--ArrowServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  ArrowServlet.lua
 --* Author:  liucheng
 --* Modified: 2016年3月30日
 --* Purpose: 穿云箭消息接口 
 -------------------------------------------------------------------*/
 
ArrowServlet = class(EventSetDoer, Singleton)

function ArrowServlet:__init()
	self._doer = {		
		--[SPILLFLOWER_CS_CALLMEMBER] 		= ArrowServlet.CallMemberReq,
		--[SPILLFLOWER_CS_SENDMEMBER] 		= ArrowServlet.SendToMember,
		--[SPILLFLOWER_SS_CALLMEMBER] 		= ArrowServlet.NoticeToMember,		
	}	
end

--使用穿云箭
function ArrowServlet:CallMemberReq(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local RoleID = buffer:popInt()				--玩家动态ID
	local slotIndex = buffer:popShort()

	if RoleID>0 then
		g_ArrowMgr:CallMember(RoleID,slotIndex)
	end
end

--传送到穿云箭玩家周围
function ArrowServlet:SendToMember(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local RoleID = buffer:popInt()				--玩家动态ID
	local TRoleSID = buffer:popInt()
	local TRoleMapID = buffer:popInt()
	local TRolePos = buffer:popString()

	if RoleID>0 and TRoleSID>0 then
		g_ArrowMgr:SendToMember(RoleID,TRoleSID,TRoleMapID,TRolePos)
	end
end

function ArrowServlet:NoticeToMember(event)
	local params = event:getParams()
	local buffer, worldId = params[1], params[2]
	local roleSID = buffer:popInt()
	local factionID = buffer:popInt()
	local curMapID = buffer:popInt()
	local curPos = buffer:popString()
	local RoleName = buffer:popString()

	local buffer1 = LuaEventManager:instance():getLuaRPCEvent(SPILLFLOWER_SC_CALLMEMBER)
	buffer1:pushInt(roleSID)
	buffer1:pushString(RoleName)
	buffer1:pushInt(curMapID)
	buffer1:pushString(curPos)

	local faction = g_factionMgr:getFaction(factionID)
	if not faction then return end

	local allFacMem = faction:getAllMembers()
	local allMem = {}
	for k,v in pairs(allFacMem) do
		if v:getActiveState() and v:getRoleSID()~=roleSID then
			if isLeader then 
				if v:hasDroit(FACTION_DROIT.TakeInMember) then
					table.insert(allMem, v:getRoleSID())
				end
			else
				table.insert(allMem, v:getRoleSID())
			end
		end
	end

	g_frame:sendMsgToPeerGroupBySid(allMem, buffer1)
	--g_factionMgr:send2AllMem(factionID, buffer1)
end

function ArrowServlet.getInstance()
	return ArrowServlet()
end

g_eventMgr:addEventListener(ArrowServlet.getInstance())