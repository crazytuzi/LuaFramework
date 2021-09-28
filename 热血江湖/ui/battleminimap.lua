module(..., package.seeall)
local require = require;
-- require("ui/map_set_funcs")
local ui = require("ui/base");
-------------------------------------------------------
wnd_batteMiniMap = i3k_class("wnd_batteMiniMap", ui.wnd_base)


function wnd_batteMiniMap:ctor()

end

function wnd_batteMiniMap:configure()
    local widget=self._layout.vars
    -- self.task_scroll = self._layout.vars.task_scroll
	widget.worldline_btn:onClick(self, self.changeMapLine)----世界换线
	widget.toMapBtn:onClick(self, self.toMap)
end

function wnd_batteMiniMap:refresh()
	-- self:updateMapInfo()
end


function wnd_batteMiniMap:onHide()
	releaseSchedule()
 end

function wnd_batteMiniMap:updateTimeLabel()
	local time = os.date("%H:%M",i3k_game_get_systime())
	self._layout.vars.timeLabel:setText(time)
end

function wnd_batteMiniMap:updateCoordInfo(mapName, msg)
	local color = g_i3k_game_context:GetCurrentLine() == g_WORLD_KILL_LINE and g_i3k_get_red_color() or "FF634624"
	self._layout.vars.mapName:setTextColor(color)
	self._layout.vars.mapName:setText(mapName)
	self._layout.vars.worldCoord:setText(msg)
end

------------监听器---------------------
function wnd_batteMiniMap:toMap(sender)
	local mapId = g_i3k_game_context:GetWorldMapID()
	local mapType = i3k_game_get_map_type()
	if mapType == g_FACTION_TEAM_DUNGEON then
        i3k_sbean.query_map_monster_nums() -- 请求帮派团本中怪物的数量
		g_i3k_ui_mgr:OpenUI(eUIID_FactionTeamDungeonMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionTeamDungeonMap, mapId, i3k_db_faction_team_dungeon)
	elseif mapType == g_ANNUNCIATE then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionTeamDungeonMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionTeamDungeonMap, mapId, i3k_db_annunciate_dungeon)
	elseif mapType == g_FACTION_GARRISON then
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrisonMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionGarrisonMap, mapId, i3k_db_faction_garrsion_minimap[mapId])
	elseif mapType == g_DEMON_HOLE then
		local curFloor, grade = g_i3k_game_context:GetDemonHoleFloorGrade()
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenDungeonMap(mapId, i3k_db_demonhole_fb[grade][curFloor])
	elseif mapType == g_BUDO then
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_ui_mgr:OpenUI(eUIID_ForceWarMap)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_ForceWarMap,"show", mapId,i3k_db_fight_team_fb[mapId])
	elseif mapType == g_GLOBAL_PVE then
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenDungeonMap(mapId, i3k_db_crossRealmPVE_fb[mapId])
	elseif mapType == g_HOME_LAND then
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_ui_mgr:OpenUI(eUIID_HomeLandMap)
		g_i3k_ui_mgr:RefreshUI(eUIID_HomeLandMap, mapId, i3k_db_home_land_minimap[mapId])
    elseif mapType == g_DEFENCE_WAR then -- 城战
        g_i3k_logic:OpenDefenceWarMap(mapId)
	elseif mapType == g_PET_ACTIVITY_DUNGEON then -- 宠物试炼
        g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenPetDungeonMiniMapUI(mapId, i3k_db_pet_dungeon_Map[mapId])
	elseif mapType == g_DESERT_BATTLE then		--决战荒漠
        g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenDroiyanDesertMap(mapId, i3k_db_desert_battle_map[mapId])
	elseif mapType == g_MAZE_BATTLE then		--天魔迷宫
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17757))
	elseif mapType == g_PRINCESS_MARRY then		--公主出嫁
        g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenPrincessMarryMiniMap(mapId, i3k_db_princess_Config[mapId])
	elseif mapType == g_MAGIC_MACHINE then		--神机藏海
        g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenMagicMachineMiniMap(mapId, i3k_db_magic_machine_miniMap[mapId])
	elseif mapType == g_GOLD_COAST then -- 战区地图黄金海岸
        g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenDungeonMap(mapId, i3k_db_war_zone_map_fb[mapId])
	elseif mapType == g_CATCH_SPIRIT then -- 鬼岛驭灵
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenCatchSpiritMiniMap(mapId, i3k_db_catch_spirit_dungeon[mapId])
	elseif mapType == g_SPY_STORY then --密探风云
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenDungeonMap(mapId, i3k_db_spy_story_map[mapId])
	elseif mapType == g_BIOGIAPHY_CAREER then --拳师试炼
		g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenBiographyCareerMiniMap(mapId, i3k_db_wzClassLand_land[mapId])
	else
        g_i3k_game_context:RefreshMiniMapNpc()
		g_i3k_logic:OpenMapUI(mapId)
	end
end

local changeLine = {
	[g_FIELD]			= {func = function() i3k_sbean.sync_worldline() end},
	[g_DEMON_HOLE]		= {tips = "伏魔洞禁止更换分线"},
	[g_GOLD_COAST]		= {func = function() i3k_sbean.global_world_sync() end},
}
function wnd_batteMiniMap:changeMapLine(sender)
	local mapType = i3k_game_get_map_type()
	if changeLine[mapType] then
		local func = changeLine[mapType].func
		if func then
			func()
		end
		local tips = changeLine[mapType].tips
		if tips then
			g_i3k_ui_mgr:PopupTipMessage(tips)
		end
	end
end

-----------------------------------------


function wnd_create(layout)
	local wnd = wnd_batteMiniMap.new();
		wnd:create(layout);
	return wnd;
end
