
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_millionsAnswerFailure = i3k_class("wnd_millionsAnswerFailure",ui.wnd_base)

function wnd_millionsAnswerFailure:ctor()

end

function wnd_millionsAnswerFailure:configure()
	local widgets = self._layout.vars
	widgets.exitBtn:onClick(self, self.onCloseUI)

	widgets.tips:setText(i3k_get_string(17153))
	widgets.okBtn:onClick(self, function()
		g_i3k_ui_mgr:CloseUI(eUIID_MillionsAnswerFailure)
	end)
end

function wnd_millionsAnswerFailure:refresh()

end

function wnd_create(layout, ...)
	local wnd = wnd_millionsAnswerFailure.new()
	wnd:create(layout, ...)
	return wnd;
end

