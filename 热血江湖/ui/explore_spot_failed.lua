-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_explore_failed = i3k_class("wnd_explore_failed", ui.wnd_base)

function wnd_explore_failed:ctor()
	self._timeTick = 0
end

function wnd_explore_failed:configure()
	
end

function wnd_explore_failed:onShow()
	
end

function wnd_explore_failed:refresh(text, iconId)
	self._layout.vars.descLabel:setText(text)
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
end

function wnd_explore_failed:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	if self._timeTick>2.5 then
		g_i3k_ui_mgr:CloseUI(eUIID_ExploreSpotFailed)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_explore_failed.new()
	wnd:create(layout, ...)
	return wnd;
end