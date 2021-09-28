-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_add_diamond = i3k_class("wnd_add_diamond", ui.wnd_base)

function wnd_add_diamond:ctor()
	
end

function wnd_add_diamond:configure()
	
end

function wnd_add_diamond:onShow()
	
end

function wnd_add_diamond:refresh(count)
	self._layout.vars.countLabel:setText("+"..count)
end


function wnd_create(layout, ...)
	local wnd = wnd_add_diamond.new()
	wnd:create(layout, ...)
	return wnd;
end