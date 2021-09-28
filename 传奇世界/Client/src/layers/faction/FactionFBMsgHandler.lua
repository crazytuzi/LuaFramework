
local NotifyOpen = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("FactionCopyOpenNotify", buff) 
    
    local copyId = t.copyID
	local time = t.startTime
	print("NotifyOpen ........................." .. copyId)
	G_FACTION_INFO.StartFbId = copyId
	G_FACTION_INFO.StartFbTime = time
	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_PASS_TIME, "FactionCopyGetPassTime", {})
	
--	local data = require("src/config/FactionCopyDB")
--	local monsterID 
--	for i=1, #data do
--		if data[i].ID == copyId then
--			monsterID = data[i].monsterID
--			break
--		end
--	end
--	if monsterID then
--		local monsterCfg = getConfigItemByKey( "monster", "q_id" )[tonumber(monsterID)]
--		local strLab = getConfigItemByKeys("clientmsg",{"sth","mid"},{15900, -15})
--		strLab = string.format(strLab.msg, monsterCfg.q_name or "")
--		TIPS( {str = strLab , type = 1})
--	end
	
	if G_MAINSCENE then
		G_MAINSCENE:createBaseButton()
		G_MAINSCENE:showBaseButtonFactionBoss(true, false)
	end

	if G_MAINSCENE then
 		G_MAINSCENE:setFactionRedPointVisible(2, true)
    end

end


local NotifySetOpen = function(buff)
    local t = g_msgHandlerInst:convertBufferToTable("FactionCopySetOpenNotify", buff)
    local copyId = t.copyID
	local strTime = t.openTime

	log("[Faction NotifySetOpen] copyId = %s, strTime = %s.", copyId, strTime)

	local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{15900,-20})
	TIPS(msg_item)

	-------------------------------------------------------

	local currFactionMoney = 0
	local costFactionMoney = 0

	if G_FACTION_INFO.Money then
		currFactionMoney = G_FACTION_INFO.Money
	end

	local fbData = require("src/config/FactionCopyDB")
	if copyId then
		for i = 1, #fbData do
			if copyId == tonumber(fbData[i].ID) then
				costFactionMoney = fbData[i].costResource
				break
			end
		end
	end

	if currFactionMoney < costFactionMoney then
		MessageBox(game.getStrByKey("faction_hintMoneyNotEnough"), game.getStrByKey("confirm"), nil)
	end

end


local NotifyAutoOpenFail = function(buff)
	local t = g_msgHandlerInst:convertBufferToTable("FactionCopyAutoOpenFailNotify", buff) 
    local copyId = t.copyID
	local errCode = t.errcode
	local param = t.param

	log("[Faction NotifyAutoOpenFail] copyId = %s, errCode = %s, param = %s.", copyId, errCode, param)

	local msg_item = getConfigItemByKeys("clientmsg",{"sth","mid"},{15900,errCode})
	if errCode == -24 then
		msgStr = string.format( msg_item.msg , param )
		TIPS( { type = msg_item.tswz , str = msgStr , flag = msg_item.flag } )
	else
		TIPS(msg_item)
	end

	g_msgHandlerInst:sendNetDataByTableExEx(FACTIONCOPY_CS_GET_PASS_TIME, "FactionCopyGetPassTime", {})
end


g_msgHandlerInst:registerMsgHandler(FACTIONCOPY_SC_NOTIFY_OPEN, NotifyOpen)
g_msgHandlerInst:registerMsgHandler(FACTIONCOPY_SC_NOTIFY_SETOPEN, NotifySetOpen)
g_msgHandlerInst:registerMsgHandler(FACTIONCOPY_SC_NOTIFY_AUTOOPENFAIL, NotifyAutoOpenFail)

