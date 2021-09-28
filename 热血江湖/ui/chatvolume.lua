-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chatVolume = i3k_class("wnd_chatVolume", ui.wnd_base)

function wnd_chatVolume:ctor()
end

function wnd_chatVolume:configure()
end

function wnd_chatVolume:refresh()
end

function wnd_create(layout, ...)
	local wnd = wnd_chatVolume.new();
	wnd:create(layout, ...);
	
	return wnd;
end
