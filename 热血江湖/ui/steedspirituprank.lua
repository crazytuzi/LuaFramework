-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedSpiritUpRank = i3k_class("wnd_steedSpiritUpRank", ui.wnd_base)

function wnd_steedSpiritUpRank:ctor()

end

function wnd_steedSpiritUpRank:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_steedSpiritUpRank:refresh()

end

function wnd_create(layout)
	local wnd = wnd_steedSpiritUpRank.new()
	wnd:create(layout)
	return wnd
end