--SmelterServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  SmelterServlet.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年9月12日
 --* Purpose: Implementation of the class SmelterServlet
 -------------------------------------------------------------------*/

SmelterServlet = class(EventSetDoer, Singleton)

function SmelterServlet:__init()
	self._doer = {
			[SMELTER_CS_REQ]			=	SmelterServlet.doResolve,		--SmelterServlet.Req		
		}			
end

--玩家熔解装备
function SmelterServlet:doResolve(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("SmelterReqProtocol" , pbc_string)
	if not req then
		print('SmelterServlet:doResolve '..tostring(err))
		return
	end	

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		print("SmelterServlet:doResolve no player")
		return
	end
	local roleID = player:getID()		--动态ID
	local equipNum = req.itemNum	--熔解数目
	local slotList = {}
	if equipNum<=0 then
		return
	end

	for a=1,equipNum do
		local slotID = req.slotList[a]				--装备所在的背包格子	
		if slotID>0 then
			table.insert(slotList,slotID)
		end
	end

	g_smelterMgr:Resolve(roleID,slotList)
	g_taskMgr:NotifyListener(player, "onEquipDecompose")
end

function SmelterServlet.getInstance()
	return SmelterServlet()
end

g_eventMgr:addEventListener(SmelterServlet.getInstance())