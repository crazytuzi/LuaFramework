module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleFight = i3k_class("wnd_battleFight", ui.wnd_base)
function wnd_battleFight:ctor()

end

function wnd_battleFight:configure()

end

function wnd_battleFight:onShow()
	
end

function wnd_battleFight:refresh()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_ArenaSwallow)
			g_i3k_ui_mgr:CloseUI(eUIID_BattleFight)
		end)
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleFight.new();
		wnd:create(layout);
	return wnd;
end
