
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_millionsAnswerSuccess = i3k_class("wnd_millionsAnswerSuccess",ui.wnd_base)

function wnd_millionsAnswerSuccess:ctor()

end

function wnd_millionsAnswerSuccess:configure()
	local widgets = self._layout.vars
	widgets.exitBtn:onClick(self, self.onCloseUI)

	widgets.desc:setText(i3k_get_string(17158))
	widgets.ok:onClick(self, function()
		g_i3k_ui_mgr:CloseUI(eUIID_MillionsAnswerSuccess)
	end)
end

function wnd_millionsAnswerSuccess:refresh()
end

function wnd_create(layout, ...)
	local wnd = wnd_millionsAnswerSuccess.new()
	wnd:create(layout, ...)
	return wnd;
end

