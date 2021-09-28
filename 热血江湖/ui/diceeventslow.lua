-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceEventSlow = i3k_class("wnd_diceEventSlow", ui.wnd_base)

function wnd_diceEventSlow:ctor()

end

function wnd_diceEventSlow:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_diceEventSlow:onShow()

end

function wnd_diceEventSlow:refresh(str)
	local widgets = self._layout.vars
	widgets.label:setText(str)
end


function wnd_create(layout, ...)
	local wnd = wnd_diceEventSlow.new()
	wnd:create(layout, ...)
	return wnd;
end
