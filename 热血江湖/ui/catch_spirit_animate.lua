-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_catch_spirit_animate = i3k_class("wnd_catch_spirit_animate", ui.wnd_base)

function wnd_catch_spirit_animate:ctor()
	self._countdown = 0
end

function wnd_catch_spirit_animate:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_catch_spirit_animate:refresh()
	
end

function wnd_catch_spirit_animate:onUpdate(dTime)
	self._countdown = self._countdown + dTime
	if self._countdown >= 2 then
		self._countdown = 0
		g_i3k_ui_mgr:AddTask(self, {}, function()
			g_i3k_ui_mgr:CloseUI(eUIID_CatchSpiritAnimate)
		end, 1)
	end
end

function wnd_create(layout)
	local wnd = wnd_catch_spirit_animate.new()
	wnd:create(layout)
	return wnd
end