-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridianDash = i3k_class("wnd_meridianDash",ui.wnd_base)

function wnd_meridianDash:ctor()
end

function wnd_meridianDash:configure(...)
	local widgets	= self._layout.vars

	widgets.closeBtn:onClick(self, self.onCloseUI)	
end

function wnd_meridianDash:refresh(id)
	self:onShow(id)
end

function wnd_meridianDash:onShow(id)
	
end

function wnd_create(layout)
	local wnd = wnd_meridianDash.new()
	wnd:create(layout)
	return wnd
end
