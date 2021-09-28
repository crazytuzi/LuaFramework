-------------------------------------------------------
module(..., package.seeall)

local require = require;
local ui = require("ui/base");

-------------------------------------------------------
wnd_breaksceneani = i3k_class("wnd_breaksceneani", ui.wnd_base)

function wnd_breaksceneani:ctor()
end

function wnd_breaksceneani:configure()
	self._layout.vars.breakBtn1:onClick(self,self.onClose)
	self._layout.vars.breakBtn2:onClick(self,self.onClose)
end

function wnd_breaksceneani:setBreakType(breakType)
	self._layout.vars.upBar1:setVisible(breakType == 1)
	self._layout.vars.upBar2:setVisible(breakType == 2)
end

function wnd_breaksceneani:onClose(sender)
	i3k_game_stop_scene_ani()
end

function wnd_create(layout, ...)
	local wnd = wnd_breaksceneani.new();
		wnd:create(layout, ...);
	return wnd;
end
