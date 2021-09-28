module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleTXAcceptTask = i3k_class("wnd_battleTXAcceptTask", ui.wnd_base)
function wnd_battleTXAcceptTask:ctor()

end

function wnd_battleTXAcceptTask:configure()

end

function wnd_battleTXAcceptTask:refresh()

end

function wnd_battleTXAcceptTask:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTXAcceptTask)
		end)
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleTXAcceptTask.new();
		wnd:create(layout);
	return wnd;
end
