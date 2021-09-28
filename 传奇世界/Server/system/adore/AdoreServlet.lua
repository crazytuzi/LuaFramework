--AdoreServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  AdoreServlet.lua
 --* Author:  seezon
 --* Modified: 2015年7月27日
 --* Purpose: 膜拜系统消息接口
 -------------------------------------------------------------------*/

AdoreServlet = class(EventSetDoer, Singleton)

function AdoreServlet:__init()
	self._doer = {
	    [ADORE_CS_ADOREKING]	=		AdoreServlet.doAdoreKing,
		[ADORE_CS_GETDATA]	=		AdoreServlet.doGetData,
}
end

--膜拜中州城主
function AdoreServlet:doAdoreKing(event)
    local params = event:getParams()
	local pbc_string, roleSID, hGate = params[1], params[2], params[3]
	local data = protobuf.decode("AdoreKingProtocol" , pbc_string)
	
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local useIngot = data.useIngot or 0
	if player then 
		g_adoreMgr:adoreKing(player:getID(), useIngot)
	end
	
end

--获取膜拜数据
function AdoreServlet:doGetData(event)
    local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then 
    	g_adoreMgr:getData(player:getID())
    end
end

--给客户端发送错误提示的接口
function AdoreServlet:sendErrMsg2Client(roleID, eCode, paramCnt, params)
	fireProtoSysMessage(self:getCurEventID(), roleID, EVENT_ADORE_SET, eCode, paramCnt, params)
end

function AdoreServlet.getInstance()
	return AdoreServlet()
end

g_eventMgr:addEventListener(AdoreServlet.getInstance())