-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------
wnd_starDishLead = i3k_class("wnd_starDishLead",ui.wnd_base)

function wnd_starDishLead:ctor()

end

function wnd_starDishLead:configure()
	local widgets = self._layout.vars
	widgets.replayBtn:onClick(self, self.onReplayBtn)
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_starDishLead:refresh(starId)
	self:PalyAction();
end

function wnd_starDishLead:onReplayBtn(sender)
	self:PalyAction();
end

function wnd_starDishLead:PalyAction()
	self._layout.anis.c_zy.play()
end

function wnd_create(layout)
	local wnd = wnd_starDishLead.new()
	wnd:create(layout)
	return wnd
end
	