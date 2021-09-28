
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_firstLoginShow = i3k_class("wnd_firstLoginShow",ui.wnd_base)

function wnd_firstLoginShow:ctor()

end

function wnd_firstLoginShow:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onMyCloseUI)
end

function wnd_firstLoginShow:onMyCloseUI()
	g_i3k_logic:ShowBattleUI(true)
	g_i3k_game_context:LeadCheck() --因为打开界面时关闭了新手引导，关闭的时候需要检查下
	g_i3k_ui_mgr:CloseUI(eUIID_FirstLoginShow)
end

function wnd_create(layout, ...)
	local wnd = wnd_firstLoginShow.new()
	wnd:create(layout, ...)
	return wnd;
end

