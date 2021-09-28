-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_rob_flag_log = i3k_class("wnd_faction_rob_flag_log", ui.wnd_base)

local LAYER_DQGZT = "ui/widgets/dqgzt"
local RowitemCount = 3

local bg_icons = {3024,3025,3026}

-- 3种底板
local UNOCCUPIED_HIGH_LEVEL_FLAG = 5122
local OCCUPIED_MY_FLAG = 5124
local OCCUPIED_ENEMY_FLAG = 5123


function wnd_faction_rob_flag_log:ctor()
	self.timer = 2--大于1 立即刷新
end

function wnd_faction_rob_flag_log:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.scroll = self._layout.vars.scroll
	self.rule = self._layout.vars.rule
	self._layout.vars.desc1:setText(i3k_get_string(18108))
end

function wnd_faction_rob_flag_log:onShow()

end

function wnd_faction_rob_flag_log:refresh()
	self:updateLog()
	self:updateRule(i3k_get_string(767))
end

function wnd_faction_rob_flag_log:updateLog()
	local tmp_map = {}

	for k,v in pairs(i3k_db_faction_map_flag) do
		table.insert(tmp_map,v)
	end

	table.sort(tmp_map,function (a,b)
		return a.mapId < b.mapId
	end)

	local flagData = g_i3k_game_context:GetFactionFlagData()
	local mySectId = g_i3k_game_context:GetSectId()

	local children = self.scroll:addChildWithCount(LAYER_DQGZT, RowitemCount, #tmp_map)
	for i,v in ipairs(children) do
		local tmpMapId = tmp_map[i].mapId
		v.vars.mapName:setText(i3k_db_dungeon_base[tmpMapId].desc)
		if flagData[tmpMapId] and flagData[tmpMapId].curSect and flagData[tmpMapId].curSect.sectId ~= 0 then
			v.vars.factionName:setText(flagData[tmpMapId].curSect.sectName)
			v.vars.factionIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[flagData[tmpMapId].curSect.sectIcon].iconid))
			if mySectId == flagData[tmpMapId].curSect.sectId then
				v.vars.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(bg_icons[3]))
				if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(tmpMapId) then -- 己方
					v.vars.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(OCCUPIED_MY_FLAG))
				end
				local frameId = i3k_db_faction_map_flag[tmpMapId].occupyFriendFrameIconId
				v.vars.frame:setImage(g_i3k_db.i3k_db_get_icon_path(frameId))
				v.vars.factionName:enableOutline("FF557ac6")
				v.vars.mapName:setTextColor("FF567bc7")
			else
				v.vars.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(bg_icons[2]))
				if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(tmpMapId) then -- 敌方
					v.vars.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(OCCUPIED_ENEMY_FLAG))
				end
				local frameId = i3k_db_faction_map_flag[tmpMapId].occupyOtherFrameIconId
				v.vars.frame:setImage(g_i3k_db.i3k_db_get_icon_path(frameId))
				v.vars.factionName:enableOutline("FFbd492e")
				v.vars.mapName:setTextColor("FFd36344")
			end
			v.vars.state:hide()
			v.vars.factionName:show()
		else
			local frameId = i3k_db_faction_map_flag[tmpMapId].frameIconId
			v.vars.frame:setImage(g_i3k_db.i3k_db_get_icon_path(frameId))
			v.vars.mapName:setTextColor("FF989796")
			v.vars.factionIcon:hide()
			v.vars.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(bg_icons[1]))
			if g_i3k_db.i3k_db_get_factionFlag_high_level_map_id(tmpMapId) then -- 为占领
				v.vars.bg_icon:setImage(g_i3k_db.i3k_db_get_icon_path(UNOCCUPIED_HIGH_LEVEL_FLAG))
			end
			v.vars.state:show()
			v.vars.factionName:hide()
		end
		v.vars.btn:onClick(self, self.onMap, tmpMapId)
	end
end

function wnd_faction_rob_flag_log:updateRule(data)
	self.rule:setText(data)
end

function wnd_faction_rob_flag_log:onUpdate(dTime)
	if self.timer < 1 then
		self.timer = self.timer + dTime
	else
		self.timer = 0
		--更新时间
		local widgets = self._layout.vars
		local cfg = i3k_db_faction_rob_flag.faction_rob_flag
		local isInDay = i3k_get_activity_is_open(cfg.openDays)
		local isIntime = g_i3k_checkIsInTodayTime(cfg.rob_start_time, cfg.rob_end_time)
		local nowtime = i3k_game_get_time()%86400
		if isInDay and isIntime then
			local secs = cfg.rob_end_time - nowtime
			local txt = i3k_get_time_show_text_simple(secs)
			widgets.desc2:setText(i3k_get_string(18110, txt))
		else
			local secs
			if isInDay and nowtime < cfg.rob_start_time then--如果当天未开启
				secs = cfg.rob_start_time - nowtime
			else--不在当天 或者 当天已结束
				local isOpenDay = function(week)
					for i,v in ipairs(cfg.openDays) do
						if v == week then
							return true
						end
					end
					return false
				end
				local totalDay = g_i3k_get_day(i3k_game_get_time())
				local week = math.mod(g_i3k_get_week(totalDay) + 1, 7)
				secs = 86400 - nowtime
				while not isOpenDay(week) do
					secs = secs + 86400
					week = math.mod(week + 1, 7)
				end
				secs = secs + cfg.rob_start_time
			end
			widgets.desc2:setText(i3k_get_string(18109, i3k_get_time_show_text_simple(secs)))
		end
	end
end
function wnd_faction_rob_flag_log:onMap(sender, mapId)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionRobFlagItem)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionRobFlagItem, mapId)
end

function wnd_create(layout, ...)
	local wnd = wnd_faction_rob_flag_log.new();
		wnd:create(layout, ...);

	return wnd;
end
