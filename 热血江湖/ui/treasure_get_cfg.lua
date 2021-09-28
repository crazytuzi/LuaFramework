local pathTable = {
	[1] = "ui/widgets/xblx1",
	[2] = "ui/widgets/xblx2",
	[3] = "ui/widgets/xblx3",
}

local function getNodeCfg(structType, node)
	local treeCfg = i3k_db_treasure_base["struct"..structType]
	local cfgTable = {}
	local count = structType==1 and 4 or (structType==2 and 8) or (structType==3 and 7)
	for i=1, count do
		cfgTable[i] = {}
		cfgTable[i].root = node.vars["root"..i]
		cfgTable[i].lightImg = node.vars["lightImg"..i]
		cfgTable[i].gradeIcon = node.vars["gradeIcon"..i]
		cfgTable[i].icon = node.vars["icon"..i]
		cfgTable[i].btn = node.vars["btn"..i]
		cfgTable[i].darkImg = node.vars["darkImg"..i]
		cfgTable[i].percentLabel = node.vars["percentLabel"..i]
		cfgTable[i].percent = treeCfg["percent"..i]
		cfgTable[i].beforSpot = treeCfg["beforSpot"..i]
	end
	if structType==1 then
		cfgTable[1].lineTable = {}
		cfgTable[2].lineTable = {[1] = node.vars.line2}
		cfgTable[3].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32}
		cfgTable[4].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32, [4] = node.vars.line4}
	elseif structType==2 then
		cfgTable[1].lineTable = {}
		cfgTable[2].lineTable = {[1] = node.vars.line2}
		cfgTable[3].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32}
		cfgTable[4].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32, [4] = node.vars.line4}
		cfgTable[5].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32, [4] = node.vars.line4, [5] = node.vars.line5}
		cfgTable[6].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32, [4] = node.vars.line4, [5] = node.vars.line5, [6] = node.vars.line61, [7] = node.vars.line62}
		cfgTable[7].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32, [4] = node.vars.line4, [5] = node.vars.line5, [6] = node.vars.line61, [7] = node.vars.line62, [8] = node.vars.line7}
		cfgTable[8].lineTable = {[1] = node.vars.line2, [2] = node.vars.line31, [3] = node.vars.line32, [4] = node.vars.line4, [5] = node.vars.line5, [6] = node.vars.line61, [7] = node.vars.line62, [8] = node.vars.line7, [9] = node.vars.line8}
	else
		cfgTable[1].lineTable = {}
		cfgTable[2].lineTable = {[1] = node.vars.line21, [2] = node.vars.line22}
		cfgTable[3].lineTable = {[1] = node.vars.line21, [2] = node.vars.line22, [3] = node.vars.line3}
		cfgTable[4].lineTable = {[1] = node.vars.line21, [2] = node.vars.line22, [3] = node.vars.line3, [4] = node.vars.line4}
		cfgTable[5].lineTable = {[1] = node.vars.line21, [2] = node.vars.line22, [3] = node.vars.line3, [4] = node.vars.line4, [5] = node.vars.line51, [6] = node.vars.line52}
		cfgTable[6].lineTable = {[1] = node.vars.line21, [2] = node.vars.line22, [3] = node.vars.line3, [4] = node.vars.line4, [5] = node.vars.line51, [6] = node.vars.line52, [7] = node.vars.line6}
		cfgTable[7].lineTable = {[1] = node.vars.line21, [2] = node.vars.line22, [3] = node.vars.line3, [4] = node.vars.line4, [5] = node.vars.line51, [6] = node.vars.line52, [7] = node.vars.line6, [8] = node.vars.line7}
	end

	return cfgTable
end

function addTreeWidgetAndGetCfg(structType)
	local node = require(pathTable[structType])()
	local nodeCfg = getNodeCfg(structType, node)
	return node, nodeCfg
end



function finishTheTask(spotCfg)
	--完成任务
	local spotType, id = spotCfg.spotType, spotCfg.arg1
	local pos = {x = 0, y = 0, z = 0}
	local mapId = g_i3k_game_context:GetWorldMapID()
	if spotType==g_KILL_MONSTER then
		pos = g_i3k_db.i3k_db_get_monster_pos(id)
		mapId = g_i3k_db.i3k_db_get_monster_map_id(id)
	elseif spotType==g_DIALOGUE then
		if mapId==g_i3k_db.i3k_db_get_npc_map_id(id) then
			-- g_i3k_ui_mgr:CloseAllOpenedUI()
			g_i3k_logic:OpenBattleUI()
			g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "也许要找的人就在附近"))
			return
		end
		mapId = g_i3k_db.i3k_db_get_npc_map_id(id)
		pos = i3k_db_dungeon_base[mapId].revivePos
	elseif spotType==g_DIG then
		pos = i3k_db_dungeon_base[id].revivePos
		if mapId==id then
			-- g_i3k_ui_mgr:CloseAllOpenedUI()
			g_i3k_logic:OpenBattleUI()
			g_i3k_ui_mgr:PopupTipMessage(string.format("%s", "宝物也许就在附近"))
			return
		else
			pos.x = spotCfg.arg2
			pos.z = spotCfg.arg3
			mapId = id
		end
	else
		pos = g_i3k_db.i3k_db_get_npc_pos(id)
		mapId = g_i3k_db.i3k_db_get_npc_map_id(id)
	end
	-- g_i3k_ui_mgr:CloseAllOpenedUI()
	g_i3k_logic:OpenBattleUI()
--	g_i3k_game_context:SeachBestPathWithMap(mapId, pos)
	g_i3k_game_context:SeachPathWithMap(mapId, pos)
end
