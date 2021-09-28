-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_progress_success = i3k_class("wnd_progress_success", ui.wnd_base)

function wnd_progress_success:ctor()

end
function wnd_progress_success:refresh()
	self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function( time )
		g_i3k_ui_mgr:CloseUI(eUIID_ProgressSuccess)
	end, 3, false)
end
function wnd_progress_success:onHideImpl( )
	self:releaseScheduler()
end
function wnd_progress_success:releaseScheduler()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end
end
function wnd_progress_success:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_create(layout)
	local wnd = wnd_progress_success.new()
	wnd:create(layout)
	return wnd
end
