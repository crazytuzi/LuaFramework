module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleTXUpLevel = i3k_class("wnd_battleTXUpLevel", ui.wnd_base)
function wnd_battleTXUpLevel:ctor()

end

function wnd_battleTXUpLevel:configure()

end

function wnd_battleTXUpLevel:refresh()

end

function wnd_battleTXUpLevel:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_wancheng
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTXUpLevel)
		end)
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleTXUpLevel.new();
		wnd:create(layout);
	return wnd;
end
