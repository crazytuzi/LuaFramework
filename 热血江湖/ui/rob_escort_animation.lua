-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_rob_escort_animation = i3k_class("wnd_rob_escort_animation", ui.wnd_base)

function wnd_rob_escort_animation:ctor()
	
end

function wnd_rob_escort_animation:configure(...)
	self._anis = self._layout.anis.c_wancheng	
end

function wnd_rob_escort_animation:onShow()
	
	self._anis.stop()
	self._anis.play(function ()
		g_i3k_ui_mgr:CloseUI(eUIID_RobEscortAnimation)
	end)
	
end

function wnd_create(layout, ...)
	local wnd = wnd_rob_escort_animation.new();
		wnd:create(layout, ...);

	return wnd;
end

