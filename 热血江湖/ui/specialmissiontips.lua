-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_specialmissionTips = i3k_class("wnd_specialmissionTips", ui.wnd_base)

function wnd_specialmissionTips:ctor()
	
end

function wnd_specialmissionTips:configure()
--[[	local showModule = self._layout.vars.module
	local path = i3k_db_models[323].path
	local uiscale = i3k_db_models[323].uiscale
	showModule:setSprite(path)
	showModule:setSprSize(uiscale)
	showModule:playAction("you")--]]
end

function wnd_specialmissionTips:onShow()
	
end

function wnd_specialmissionTips:refresh()

end

function wnd_create(layout, ...)
	local wnd = wnd_specialmissionTips.new()
	wnd:create(layout, ...)
	return wnd;
end