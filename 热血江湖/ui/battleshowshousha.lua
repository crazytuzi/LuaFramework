module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_shousha = i3k_class("wnd_shousha", ui.wnd_base)
function wnd_shousha:ctor()
end
function wnd_shousha:configure()

end

function wnd_shousha:refresh()
	
end
function wnd_shousha:onUpdate(dTime)

end

function wnd_create(layout)
	local wnd = wnd_shousha.new();
		wnd:create(layout);
	return wnd;
end
