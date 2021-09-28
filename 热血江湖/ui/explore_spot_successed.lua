-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_explore_successed = i3k_class("wnd_explore_successed", ui.wnd_base)

function wnd_explore_successed:ctor()
	
end

function wnd_explore_successed:configure()
	
end

function wnd_explore_successed:onShow()
	
end

function wnd_explore_successed:refresh(iconId, percent, isLast)
	self._layout.vars.okBtn:onClick(self, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_ExploreSpotSuccessed)
	end)
	local textId = isLast and 15092 or 15091
	self._layout.vars.descLabel:setText(i3k_get_string(textId))
	self._layout.vars.percentLabel:setText(string.format("完成度 +%d", percent))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
	g_i3k_ui_mgr:RefreshUI(eUIID_BattleTreasure)
end


function wnd_create(layout, ...)
	local wnd = wnd_explore_successed.new()
	wnd:create(layout, ...)
	return wnd;
end
