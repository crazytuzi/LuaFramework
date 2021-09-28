-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_at_any_moment_animate = i3k_class("wnd_at_any_moment_animate",ui.wnd_base)

function wnd_at_any_moment_animate:ctor()
	self._time = 0
end

function wnd_at_any_moment_animate:configure()
	
end

function wnd_at_any_moment_animate:refresh(modelId)
	ui_set_hero_model(self._layout.vars.model, modelId)
end

function wnd_at_any_moment_animate:onUpdate(dTime)
	self._time = self._time + dTime
	if self._time >= 1 then
		self._time = 0
		g_i3k_ui_mgr:AddTask(self, {}, function()
			g_i3k_ui_mgr:CloseUI(eUIID_AtAnyMomentAnimate)
		end, 1)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_at_any_moment_animate.new()
	wnd:create(layout, ...)
	return wnd;
end