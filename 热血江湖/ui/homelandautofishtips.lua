-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_homeLandAutoFishTips = i3k_class("wnd_homeLandAutoFishTips", ui.wnd_base)

function wnd_homeLandAutoFishTips:ctor()
end

function wnd_homeLandAutoFishTips:configure()
	
end

function wnd_homeLandAutoFishTips:refresh()

end

function wnd_create(layout, ...)
	local wnd = wnd_homeLandAutoFishTips.new()
	wnd:create(layout, ...)
	return wnd;
end
