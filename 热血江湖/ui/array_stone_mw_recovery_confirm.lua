------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_array_stone_mw_recovery_confirm = i3k_class("wnd_array_stone_mw_recovery_confirm",ui.wnd_base)

function wnd_array_stone_mw_recovery_confirm:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.ok:onClick(self, self.onOk)
	widgets.editBox:setPlaceHolder(i3k_get_string(18446))
end

function wnd_array_stone_mw_recovery_confirm:refresh(cb)
	self.cb = cb
end

function wnd_array_stone_mw_recovery_confirm:onOk(sender)
	if self._layout.vars.editBox:getText() == "sell" then
		self.cb()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18447))
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_array_stone_mw_recovery_confirm.new()
	wnd:create(layout,...)
	return wnd
end