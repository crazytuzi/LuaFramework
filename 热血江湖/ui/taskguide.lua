
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_taskGuide = i3k_class("wnd_taskGuide",ui.wnd_base)

function wnd_taskGuide:ctor()

end

function wnd_taskGuide:configure()

end

function wnd_create(layout, ...)
	local wnd = wnd_taskGuide.new()
	wnd:create(layout, ...)
	return wnd;
end

