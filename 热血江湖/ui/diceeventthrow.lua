-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_diceEventThrow = i3k_class("wnd_diceEventThrow", ui.wnd_base)

function wnd_diceEventThrow:ctor()

end

function wnd_diceEventThrow:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_diceEventThrow:onShow()

end

function wnd_diceEventThrow:refresh(str)
	local widgets = self._layout.vars
	widgets.label:setText(str)
end


function wnd_create(layout, ...)
	local wnd = wnd_diceEventThrow.new()
	wnd:create(layout, ...)
	return wnd;
end
