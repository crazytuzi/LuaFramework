module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_afterTenYears = i3k_class("wnd_afterTenYears", ui.wnd_base)

function wnd_afterTenYears:ctor()
end
function wnd_afterTenYears:configure()
	self._layout.vars.close_btn:onClick(self,self.onClose)
end

function wnd_afterTenYears:refresh()
end

function wnd_afterTenYears:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_AfterTenYears)
end

function wnd_create(layout, ...)
	local wnd = wnd_afterTenYears.new();
		wnd:create(layout, ...);
	return wnd;
end