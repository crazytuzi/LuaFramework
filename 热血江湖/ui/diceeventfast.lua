-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceEventFast = i3k_class("wnd_diceEventFast", ui.wnd_base)

function wnd_diceEventFast:ctor()

end

function wnd_diceEventFast:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_diceEventFast:onShow()

end

function wnd_diceEventFast:refresh(str)
	local widgets = self._layout.vars
	widgets.label:setText(str)
end


function wnd_create(layout, ...)
	local wnd = wnd_diceEventFast.new()
	wnd:create(layout, ...)
	return wnd;
end
