-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_catch_spirit_preview = i3k_class("wnd_catch_spirit_preview", ui.wnd_base)

function wnd_catch_spirit_preview:ctor()
	
end

function wnd_catch_spirit_preview:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_catch_spirit_preview:refresh()
	
end

function wnd_create(layout)
	local wnd = wnd_catch_spirit_preview.new()
	wnd:create(layout)
	return wnd
end