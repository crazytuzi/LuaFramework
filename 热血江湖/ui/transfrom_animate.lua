-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_transfrom_animate = i3k_class("wnd_transfrom_animate", ui.wnd_base)

function wnd_transfrom_animate:ctor()
	
end

function wnd_transfrom_animate:configure()
	self._layout.vars.sure_btn:onClick(self, self.onCloseUI)
end

function wnd_transfrom_animate:refresh(name)
	self._layout.vars.des:setText(i3k_get_string(119, name))
end

function wnd_create(layout)
	local wnd = wnd_transfrom_animate.new()
	wnd:create(layout)
	return wnd
end