module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleTXFnishiTask = i3k_class("wnd_battleTXFnishiTask", ui.wnd_base)
function wnd_battleTXFnishiTask:ctor()

end

function wnd_battleTXFnishiTask:configure()

end

function wnd_battleTXFnishiTask:refresh()

end

function wnd_battleTXFnishiTask:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_BattleTXFinishTask)
		end)
	end
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleTXFnishiTask.new();
		wnd:create(layout);
	return wnd;
end
