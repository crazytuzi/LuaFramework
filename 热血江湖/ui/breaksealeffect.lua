module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_breakSealEffect = i3k_class("breakSealEffect", ui.wnd_base)

function wnd_breakSealEffect:ctor()
	self._timeTick = 0
end

function wnd_breakSealEffect:configure()
	
end

function wnd_breakSealEffect:onUpdate(dTime)
	self._timeTick = self._timeTick + dTime
	if self._timeTick >= 7 then
		g_i3k_ui_mgr:CloseUI(eUIID_BreakSealEffect)
	end
end

function wnd_breakSealEffect:onShow()
	--local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	--if anis then
	--	anis.stop()
	--	anis.play(function ()
	--		g_i3k_ui_mgr:CloseUI(eUIID_BreakSealEffect)
	--	end)
	--end
end

function wnd_create(layout)
	local wnd = wnd_breakSealEffect.new();
		wnd:create(layout);
	return wnd;
end