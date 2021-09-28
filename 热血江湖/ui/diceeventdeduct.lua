-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceEventDeduct = i3k_class("wnd_diceEventDeduct", ui.wnd_base)

function wnd_diceEventDeduct:ctor()

end

function wnd_diceEventDeduct:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_diceEventDeduct:onShow()

end

function wnd_diceEventDeduct:refresh(str)
	local widgets = self._layout.vars
	widgets.label:setText(str)
end


function wnd_create(layout, ...)
	local wnd = wnd_diceEventDeduct.new()
	wnd:create(layout, ...)
	return wnd;
end
