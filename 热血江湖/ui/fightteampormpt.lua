-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamPrompt = i3k_class("wnd_fightTeamPrompt", ui.wnd_base)

function wnd_fightTeamPrompt:ctor()

end

function wnd_fightTeamPrompt:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_fightTeamPrompt:refresh()
	self._layout.vars.desc:setText(i3k_get_string(1255))
end

function wnd_create(layout)
	local wnd = wnd_fightTeamPrompt.new()
	wnd:create(layout)
	return wnd
end