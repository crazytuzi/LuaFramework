-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_matching = i3k_class("wnd_matching", ui.wnd_base)

function wnd_matching:ctor()
	
end

function wnd_matching:configure()
	self._layout.vars.cancelBtn:onClick(self, self.onClose)
end

function wnd_matching:onShow()
	
end

function wnd_matching:refresh()
	
end

function wnd_matching:onClose()
	i3k_sbean.cancel_mate()
end

function wnd_create(layout, ...)
	local wnd = wnd_matching.new()
	wnd:create(layout, ...)
	return wnd;
end