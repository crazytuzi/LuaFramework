-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_showLoveItemUI = i3k_class("wnd_showLoveItemUI", ui.wnd_base)

function wnd_showLoveItemUI:ctor()

end

function wnd_showLoveItemUI:configure()

end

function wnd_showLoveItemUI:onShow()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_xin03
	if anis then
		anis.stop()
		anis.play(function ()
			g_i3k_ui_mgr:CloseUI(eUIID_ShowLoveItemUI)
		end)
	end
end



function wnd_create(layout, ...)
	local wnd = wnd_showLoveItemUI.new()
	wnd:create(layout, ...)
	return wnd;
end
