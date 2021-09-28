------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_faction_dungeon_ani = i3k_class("wnd_faction_dungeon_ani",ui.wnd_base)

function wnd_faction_dungeon_ani:configure()
	self._layout.anis.c_wancheng.play(function()
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonOpenAni)
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonResetAni)
	end)
end

---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_faction_dungeon_ani.new()
	wnd:create(layout,...)
	return wnd
end
