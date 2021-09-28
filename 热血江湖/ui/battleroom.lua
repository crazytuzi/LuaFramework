module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleRoom = i3k_class("wnd_battleRoom", ui.wnd_base)
function wnd_battleRoom:ctor()

end

function wnd_battleRoom:configure()

end

function wnd_battleRoom:refresh()

end

function wnd_battleRoom:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleRoom)
		end)
	end
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleRoom.new();
		wnd:create(layout);
	return wnd;
end
