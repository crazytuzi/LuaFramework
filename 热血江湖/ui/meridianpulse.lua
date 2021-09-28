-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridianPulse = i3k_class("wnd_meridianPulse",ui.wnd_base)

function wnd_meridianPulse:ctor()
end

function wnd_meridianPulse:configure(...)
	local widgets	= self._layout.vars
	self.name		= widgets.name;
	self.desc		= widgets.desc;
	widgets.cancel:onClick(self, self.onCloseUI)	
end

function wnd_meridianPulse:refresh(pulse)
	self.name:setText(pulse.name);
	self.desc:setText(pulse.desc);
end

function wnd_create(layout)
	local wnd = wnd_meridianPulse.new()
	wnd:create(layout)
	return wnd
end
