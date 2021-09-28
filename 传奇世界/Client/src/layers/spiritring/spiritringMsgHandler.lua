--接收神戒列表
local recvRingList = function (buff)
	local login = buff:popChar()
	local ringnum1 = buff:popChar()
	log("神戒数量："..ringnum1.."    登陆天数:"..login)
	local rdata = require("src/layers/spiritring/ringdata")
	local list = {}
	list.logindate = login
	list.ringnum = ringnum1
	G_RING_INFO.ringNum = list.ringnum
	for i = 1, ringnum1 do
		list[i]={}
		list[i].id = buff:popChar()
		list[i].lvl = buff:popChar()
		list[i].updateneed = buff:popShort()
	end
	rdata:setRingList(list)
	if g_EventHandler["ringflash"] then
		g_EventHandler["ringflash"]()
	end

	if G_MAINSCENE then
		G_MAINSCENE:addDelayCheckRingNew()
	end
end

g_msgHandlerInst:registerMsgHandler(TALISMAN_SC_SYNC, recvRingList)
