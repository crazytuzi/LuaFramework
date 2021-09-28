-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_forcewar_matching = i3k_class("wnd_forcewar_matching", ui.wnd_base)

function wnd_forcewar_matching:ctor()
	
end

function wnd_forcewar_matching:configure()
	self._layout.vars.cancelBtn:onClick(self, self.onClose)
end

function wnd_forcewar_matching:onShow()
	
end

function wnd_forcewar_matching:refresh()
	
end

function wnd_forcewar_matching:onClose()
	i3k_sbean.quit_join_forcewar()
end

function wnd_create(layout, ...)
	local wnd = wnd_forcewar_matching.new()
	wnd:create(layout, ...)
	return wnd;
end