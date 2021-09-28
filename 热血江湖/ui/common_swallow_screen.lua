-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_common_swallow_screen = i3k_class("wnd_common_swallow_screen", ui.wnd_base)

function wnd_common_swallow_screen:ctor()
end

function wnd_common_swallow_screen:configure(...)
	self._layout.vars.btn1:onClick(self, self.toTips)
	self._layout.vars.btn2:onClick(self, self.toTips)
	self._layout.vars.btn3:onClick(self, self.toTips)
	self._layout.vars.btn4:onClick(self, self.toTips)
end

function wnd_common_swallow_screen:onShow()
	
end

function wnd_common_swallow_screen:toTips(sender)
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(140))
end

function wnd_create(layout, ...)
	local wnd = wnd_common_swallow_screen.new();
		wnd:create(layout, ...);

	return wnd;
end