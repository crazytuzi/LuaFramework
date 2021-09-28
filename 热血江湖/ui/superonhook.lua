-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_superOnHook = i3k_class("wnd_superOnHook",ui.wnd_base)

function wnd_superOnHook:ctor()

end

function wnd_superOnHook:configure()
	local widgets = self._layout.vars
	widgets.cancleBtn:onClick(self, self.onCloseUI)
end

function wnd_superOnHook:refresh()

end

function wnd_superOnHook:onCloseUI(sender)
	g_i3k_game_context:SetAutoFight(false)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1824))
	g_i3k_ui_mgr:CloseUI(eUIID_SuperOnHook)
end

function wnd_create(layout)
	local wnd = wnd_superOnHook.new()
	wnd:create(layout)
	return wnd
end
