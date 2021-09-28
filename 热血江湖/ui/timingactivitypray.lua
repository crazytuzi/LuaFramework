------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_timingActivity_pray = i3k_class("wnd_timingActivity_pray",ui.wnd_base)

function wnd_timingActivity_pray:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.ok:onClick(self, self.onOkBtn)
	widgets.txt:setPlaceHolder(i3k_get_string(18282,  i3k_db_common.inputlen.timingPrayMaxLen))
	local selfContent = g_i3k_game_context:getTimingActivityPrayInfo()
	widgets.txt:setText(selfContent and selfContent.selfPray.content or "")
end

function wnd_timingActivity_pray:onOkBtn(sender)
	local txt = self._layout.vars.txt:getText()
	local len = i3k_get_utf8_len(txt)
	if len > i3k_db_common.inputlen.timingPrayMaxLen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18283))
	elseif len < i3k_db_common.inputlen.timingPrayMinLen then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18284, i3k_db_common.inputlen.timingPrayMinLen))
	else
		i3k_sbean.regular_pray(txt)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_timingActivity_pray.new()
	wnd:create(layout,...)
	return wnd
end