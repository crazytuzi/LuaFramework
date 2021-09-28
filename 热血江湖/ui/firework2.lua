module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_firework1 = i3k_class("wnd_firework1", ui.wnd_base)
function wnd_firework1:ctor()

end

function wnd_firework1:configure()

end

function wnd_firework1:refresh()

end

function wnd_firework1:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_Firework2)
		end)
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_firework1.new();
		wnd:create(layout);
	return wnd;
end
