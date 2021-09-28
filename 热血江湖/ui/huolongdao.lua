module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_huoLongDao = i3k_class("wnd_huoLongDao", ui.wnd_base)

function wnd_huoLongDao:ctor()
end
function wnd_huoLongDao:configure()
	self._layout.vars.closebtn:onClick(self,self.onClose)
end

function wnd_huoLongDao:refresh()
end

function wnd_huoLongDao:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_HuoLongDao)
end

function wnd_create(layout, ...)
	local wnd = wnd_huoLongDao.new();
		wnd:create(layout, ...);
	return wnd;
end