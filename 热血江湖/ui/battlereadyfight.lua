module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleReadyFight = i3k_class("wnd_battleReadyFight", ui.wnd_base)

function wnd_battleReadyFight:ctor()

end

function wnd_battleReadyFight:configure()

end

function wnd_battleReadyFight:onShow()
	
end

function wnd_battleReadyFight:refresh()
	local anis = self._layout and self._layout.anis and self._layout.anis.c_dakai
	if anis then
		anis.stop()
		anis.play()
	end
end

function wnd_create(layout)
	local wnd = wnd_battleReadyFight.new();
		wnd:create(layout);
	return wnd;
end
