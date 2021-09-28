-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_find_clue = i3k_class("wnd_find_clue", ui.wnd_base)

function wnd_find_clue:ctor()
	
end

function wnd_find_clue:configure()
	
end

function wnd_find_clue:onShow()
	
end

function wnd_find_clue:refresh(text, iconId, percent, isLast)
	self._layout.vars.okBtn:onClick(self, function ()
		g_i3k_ui_mgr:OpenUI(eUIID_ExploreSpotSuccessed)
		g_i3k_ui_mgr:RefreshUI(eUIID_ExploreSpotSuccessed,iconId, percent, isLast)
		g_i3k_ui_mgr:CloseUI(eUIID_FindClue)
	end)
	self._layout.vars.descLabel:setText(text)
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconId))
end


function wnd_create(layout, ...)
	local wnd = wnd_find_clue.new()
	wnd:create(layout, ...)
	return wnd;
end