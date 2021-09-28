------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_huoban_unbind = i3k_class("wnd_huoban_unbind",ui.wnd_base)

function wnd_huoban_unbind:configure()
	local widget = self._layout.vars
	widget.close:onClick(self,self.onCloseUI)
	widget.desc:setText(i3k_get_string(18214))
	widget.unbind:onClick(self, self.onUnbindClick)
end

function wnd_huoban_unbind:refresh(code)
	self._layout.vars.code:setText(code)
end

function wnd_huoban_unbind:onUnbindClick(sender)
	local _, unbindTime = g_i3k_game_context:GetPartnerUnBindTime()
	local cd = i3k_db_partner_base.cfg.unbindCD2
	if i3k_game_get_time() - unbindTime < cd then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17890, i3k_get_show_rest_time(cd - (i3k_game_get_time() - unbindTime))))
	else
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(18215, cd / 3600 / 24),
			function(bValue)
				if bValue then
					i3k_sbean.unbind_upper_partner()
				end
			end)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_huoban_unbind.new()
	wnd:create(layout,...)
	return wnd
end