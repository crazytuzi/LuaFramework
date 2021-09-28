--GiveWineServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  GiveWineServlet.lua
 --* Author:  liucheng
 --* Modified: 2016年2月11日
 --* Purpose: 仙翁赐酒消息接口 
 -------------------------------------------------------------------*/

GiveWineServlet = class(EventSetDoer, Singleton)

function GiveWineServlet:__init()
	self._doer = {
		[GIVEWINE_CS_GETWINE] 		= 	GiveWineServlet.GetFreeWine,
		[GIVEWINE_CS_DRINK]			=	GiveWineServlet.Drink,
		[GIVEWINE_CS_GETWINE_NUM] 	= 	GiveWineServlet.GetWineNum,
	}
end

function GiveWineServlet:GetFreeWine(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("GetWineProtocol" , pbc_string)
	if not req then
		print('GiveWineServlet:GetFreeWine '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end

	if g_GiveWineMgr then
		g_GiveWineMgr:GetFreeWine(player)
	end
end

function GiveWineServlet:Drink(buffer1)	
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("DrinkWineProtocol" , pbc_string)
	if not req then
		print('GiveWineServlet:Drink '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local slotIndex = req.slotIndex or 0

	if g_GiveWineMgr then
		g_GiveWineMgr:Drink(player,slotIndex)
	end
end

function GiveWineServlet:GetWineNum(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("GetWineNumReqProtocol" , pbc_string)
	if not req then
		print('GiveWineServlet:Drink '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	if g_GiveWineMgr then
		g_GiveWineMgr:GetWineNum(player)
	end
end

function GiveWineServlet:onDoerActive()	
	g_GiveWineMgr:setxtActive(1)
	g_normalLimitMgr:setActiveState(ACTIVITY_NORMAL_ID.GIVE_WINE, true)
end

function GiveWineServlet:onDoerClose()	
	g_GiveWineMgr:setxtActive(0)
	g_normalLimitMgr:setActiveState(ACTIVITY_NORMAL_ID.GIVE_WINE, false)
end

function GiveWineServlet.getInstance()
	return GiveWineServlet()
end

g_eventMgr:addEventListener(GiveWineServlet.getInstance())