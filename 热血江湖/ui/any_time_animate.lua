-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_any_time_animate = i3k_class("wnd_any_time_animate", ui.wnd_base)

function wnd_any_time_animate:ctor()
	self._time = 0
end

function wnd_any_time_animate:configure()
	
end

function wnd_any_time_animate:refresh()
	
end

function wnd_any_time_animate:onUpdate(dTime)
	self._time = self._time + dTime
	if self._time >= 1.2 then
		self._time = 0
		self._layout.anis.c_dakai.stop()
		g_i3k_ui_mgr:AddTask(self, {}, function()
			g_i3k_ui_mgr:CloseUI(eUIID_AnyTimeAnimate)
		end, 1)
	end
end

function wnd_create(layout)
	local wnd = wnd_any_time_animate.new()
	wnd:create(layout)
	return wnd
end