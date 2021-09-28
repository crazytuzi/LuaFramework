-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_petWakenStep = i3k_class("wnd_petWakenStep",ui.wnd_base)

function wnd_petWakenStep:ctor()
end

function wnd_petWakenStep:configure(...)
	local widgets	= self._layout.vars

	widgets.closeBtn:onClick(self, self.onCloseUI)	
end

function wnd_petWakenStep:refresh(id)
	self:onShow(id)
end

function wnd_petWakenStep:onShow(id)
	
end

function wnd_create(layout)
	local wnd = wnd_petWakenStep.new()
	wnd:create(layout)
	return wnd
end
