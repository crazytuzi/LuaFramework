-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_retrieveActivityTip = i3k_class("wnd_retrieveActivityTip", ui.wnd_base)

function wnd_retrieveActivityTip:ctor()

end

function wnd_retrieveActivityTip:configure()
	self._layout.vars.retrieveBtn:onClick(self, self.gotoAct)
	-- self._layout.anis.ss:play()
end

function wnd_retrieveActivityTip:refresh()
	
end

function wnd_retrieveActivityTip:gotoAct()
	g_i3k_ui_mgr:OpenUI(eUIID_RetrieveChoose)
	g_i3k_ui_mgr:RefreshUI(eUIID_RetrieveChoose)
end

function wnd_create(layout, ...)
	local wnd = wnd_retrieveActivityTip.new()
	wnd:create(layout, ...)
	return wnd;
end