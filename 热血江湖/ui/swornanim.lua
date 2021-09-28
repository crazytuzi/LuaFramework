module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_swornAnim = i3k_class("wnd_swornAnim", ui.wnd_base)

function wnd_swornAnim:ctor()
end

function wnd_swornAnim:configure()
end

function wnd_swornAnim:refresh()
end

function wnd_swornAnim:onUpdate(dTime)
end

function wnd_swornAnim:onShow()
end

function wnd_swornAnim:onHide()
end

function wnd_create(layout)
	local wnd = wnd_swornAnim.new()
	wnd:create(layout)
	return wnd
end