-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_wait = i3k_class("wnd_wait", ui.wnd_base)

function wnd_wait:ctor()
	
end

function wnd_wait:configure()
end

function wnd_wait:onShow()
	
	
end

function wnd_wait:onHide()
end

function wnd_wait:refresh()
	
end

function wnd_create(layout)
	local wnd = wnd_wait.new();
	wnd:create(layout);
	return wnd;
end

