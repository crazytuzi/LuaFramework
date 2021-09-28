-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_role_flying_find = i3k_class("wnd_role_flying_find", ui.wnd_base)

function wnd_role_flying_find:ctor()
	self._mapId = 0
end

function wnd_role_flying_find:configure()
	self._layout.vars.enter_btn:onClick(self, self.onEnterDungeon)
end

function wnd_role_flying_find:refresh(mapId)
	self._mapId = mapId
	self._layout.vars.name:setText(i3k_db_flying_position[mapId].name)
	self._layout.vars.desc:setText(i3k_get_string(1684))
end

function wnd_role_flying_find:onEnterDungeon(sender)
	if g_i3k_game_context:IsInRoom() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(142))
		return
	end
	local id = g_i3k_game_context:isFinishFlyingPos(self._mapId)
	local func = function ()
		g_i3k_game_context:ClearFindWayStatus()
		g_i3k_game_context:setIsNeedLoading(i3k_db_at_any_moment[self._mapId].effects)
		i3k_sbean.soaring_map_enter(id, self._mapId)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_create(layout)
	local wnd = wnd_role_flying_find.new()
	wnd:create(layout)
	return wnd
end