module(..., package.seeall)

local require = require;

local ui = require("ui/base")

wnd_world_map = i3k_class("wnd_world_map", ui.wnd_base)

-- 帮派夺旗底图背景图片id
local HEIGH_LEVEL_FLAG_UNOCCUPIED = 5125
local LOW_LEVEL_FLAG_OCCUPIED = 5126
local HEIGH_LEVEL_FLAG_OCCUPIED = 5127


function wnd_world_map:ctor()

end

function wnd_world_map:configure()
	local widget = self._layout.vars
	widget.closeBtn:onClick(self, self.onCloseUI)
	widget.scroll:setDirection(0)
	-- 非野外大地图进入Func
	self._dungeonMapFunc = {
		[g_GOLD_COAST] = self.onEnterWarzone,
		[g_CATCH_SPIRIT] = self.onEnterCatchSpirit,
	}
end

function wnd_world_map:onShow()

	local worldScene = require("ui/widgets/sjdt2t2")()
	self._layout.vars.scroll:addItem(worldScene)
	self._layout.vars.scroll:jumpToListPercent(i3k_db_common.worldMapScroll)
	local widgets = worldScene.vars

	self._btnTable = {}
	local mapIcons = i3k_db_world_map.mapIcons
	for i,v in pairs(widgets) do
		local isBtn = string.find(i, "btn")
		if isBtn then
			local node = {}
			local microMapId = tonumber(string.sub(i, 4, #i))
			for _,t in pairs(i3k_db_field_map) do
				if t.imageId==microMapId then
					node.mapId = t.id
					node.btn = v
					
					node.lightImage = widgets["img"..microMapId]
					node.titleImage = widgets["title"..microMapId]
					node.roleImg = widgets["roleImg"..microMapId]
					node.titleImageId = mapIcons[microMapId]
					node.flagBase = widgets["base"..microMapId]  -- 帮派夺旗底图，用来区分旗子等级
					if widgets["flag"..microMapId] then
						node.flag = widgets["flag"..microMapId]
					end
					table.insert(self._btnTable, node)
					break
				end
			end
		end
	end

	self:loadNotFieldMapData(widgets)

	local flag_data = g_i3k_game_context:GetFactionFlagData()
	local world = i3k_game_get_world()
	local mapId = world._cfg.mapID
	for _, v in ipairs(self._btnTable) do
		local needValue = {node = v, mapId = v.mapId}
		v.btn:onTouchEvent(self, self.selectCB, needValue)
		if v.mapId==mapId or (mapId == 114 and v.mapId == 75001) then--加个龙穴的特殊判断
			v.lightImage:show()
			v.roleImg:show()
			v.btn:onClick(self, self.onClickDoNothing)
			v.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(v.titleImageId.pressed))
		else
			v.roleImg:hide()
			v.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(v.titleImageId.normal))
			v.lightImage:hide()
			local open = g_i3k_db.i3k_db_check_world_map_open(v.mapId)
			if not open then
				v.btn:onClick(self, self.notOpen, needValue)
			end
		end
		
		if v.flag then
			if flag_data[v.mapId] and flag_data[v.mapId].curSect.sectId ~= 0 then -- 被占领了
				v.flag:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[flag_data[v.mapId].curSect.sectIcon].iconid))
				if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(v.mapId) then
					v.flagBase:setImage(g_i3k_db.i3k_db_get_icon_path(HEIGH_LEVEL_FLAG_OCCUPIED)) -- 高等级被占领
				else
					v.flagBase:setImage(g_i3k_db.i3k_db_get_icon_path(LOW_LEVEL_FLAG_OCCUPIED)) -- 低等级被占领
				end
			else
				if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(v.mapId) then
					v.flagBase:setImage(g_i3k_db.i3k_db_get_icon_path(HEIGH_LEVEL_FLAG_UNOCCUPIED)) -- 高等级未被占领
				end
			end
		end
	end
end

function wnd_world_map:selectCB(sender, eventType, needValue)
	if eventType==ccui.TouchEventType.began then
		needValue.node.lightImage:show()
		needValue.node.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(needValue.node.titleImageId.pressed))
	elseif eventType==ccui.TouchEventType.ended then
		needValue.node.lightImage:hide()
		needValue.node.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(needValue.node.titleImageId.normal))
		--切换地图的一系列操作to v.mapId
		local mapId = needValue.mapId
		if mapId then
		g_i3k_logic:OpenMapUI(mapId)
		g_i3k_ui_mgr:CloseUI(eUIID_WorldMap)
		else
			if needValue.mapType then
				local func = self._dungeonMapFunc[needValue.mapType]
				if func then
					func(self)
				end
			end
		end
	elseif eventType==ccui.TouchEventType.canceled then
		needValue.node.lightImage:hide()
		needValue.node.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(needValue.node.titleImageId.normal))
	end
end

function wnd_world_map:notOpen(sender, arg)
	if arg.mapType and arg.mapType == g_CATCH_SPIRIT then
		g_i3k_ui_mgr:OpenUI(eUIID_CatchSpiritPreview)
		g_i3k_ui_mgr:RefreshUI(eUIID_CatchSpiritPreview)
	else
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5795))
	end
end

-- 显示在世界地图中的特殊地图
function wnd_world_map:loadNotFieldMapData(widgets)
	for imageID, e in pairs(i3k_db_not_filed_map) do
		local btn = widgets["dungeon"..imageID] --非大地图副本btn命名必须为dungeon为前缀
		local node = {
			lightImage = widgets["img"..imageID],
			titleImage = widgets["title"..imageID],
			roleImg = widgets["roleImg"..imageID],
			titleImageId = {normal = e.normalImgID, pressed = e.pressedImgID},
		}
		local arg = {node = node, mapType = e.mapType}
		node.roleImg:hide()
		node.titleImage:setImage(g_i3k_db.i3k_db_get_icon_path(e.normalImgID))
		node.lightImage:hide()
		if e.open == 1 then
			btn:onTouchEvent(self, self.selectCB, arg)
		else
			btn:onClick(self, self.notOpen, arg)
		end
	end
end

function wnd_world_map:onEnterWarzone()
	local func = function()
		g_i3k_logic:OpenEnterWarZone()
end
	g_i3k_logic:OpenWarZoneUI(func)
end
function wnd_world_map:onEnterCatchSpirit(sender)
	local ghostInfo = g_i3k_game_context:getGhostSkillInfo()
	local skillState = ghostInfo.skillFlag
	if skillState == 0 then
		local callback = function (isOk)
			if isOk then
				g_i3k_game_context:GotoNpc(i3k_db_catch_spirit_base.npc.findwayNpc)
				g_i3k_ui_mgr:CloseUI(eUIID_WorldMap)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18637), callback)
	elseif i3k_get_catch_spirit_countdown() == 0 then
		local time = string.split(i3k_db_catch_spirit_base.common.openTime, ":")
		local startTime = tonumber(time[1]) * 3600 + tonumber(time[2]) * 60 + tonumber(time[3])
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18638, time[1], math.floor((startTime + i3k_db_catch_spirit_base.common.lastTime)/3600)))
	else
		if g_i3k_game_context:IsInRoom() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
			return
		end
		local func = function ()
			g_i3k_game_context:ClearFindWayStatus()
			i3k_sbean.ghost_island_enter()
		end
		g_i3k_game_context:CheckMulHorse(func)
	end
end

function wnd_world_map:onClickDoNothing(sender)
	-- do nothing
end

function wnd_create(layout, ...)
	local wnd = wnd_world_map.new();
	wnd:create(layout, ...);

	return wnd;
end
