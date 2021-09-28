-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_desertFindWayStateTips = i3k_class("wnd_desertFindWayStateTips", ui.wnd_base)

function wnd_desertFindWayStateTips:ctor()
end

function wnd_desertFindWayStateTips:configure()
	
end

function wnd_desertFindWayStateTips:refresh()

end

function wnd_create(layout, ...)
	local wnd = wnd_desertFindWayStateTips.new()
	wnd:create(layout, ...)
	return wnd;
end
