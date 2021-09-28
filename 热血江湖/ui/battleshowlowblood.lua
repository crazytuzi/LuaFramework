module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleLowBlood = i3k_class("wnd_battleLowBlood", ui.wnd_base)
function wnd_battleLowBlood:ctor()
end
function wnd_battleLowBlood:configure()

end

function wnd_battleLowBlood:refresh()
	
end
function wnd_battleLowBlood:onUpdate(dTime)

end

function wnd_battleLowBlood:UpdateShow(show)
	if show then
		self._layout.anis.c_dakai.play(-1)
	else
		self._layout.anis.c_dakai.stop()
	end

end

function wnd_create(layout)
	local wnd = wnd_battleLowBlood.new();
		wnd:create(layout);
	return wnd;
end
