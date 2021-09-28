-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_goldCoastPk = i3k_class("wnd_goldCoastPk",ui.wnd_base)

function wnd_goldCoastPk:ctor()
end

function wnd_goldCoastPk:configure()
	local widget = self._layout.vars
	widget.close:onClick(self, self.onCloseUI)
	widget.btn4:onClick(self, self.onUpdatePKMode, g_SeverMode)
	widget.btn3:onClick(self, self.onUpdatePKMode, g_FactionMode)
end

function wnd_goldCoastPk:onUpdatePKMode(sender, mode)
	local hero = i3k_game_get_player_hero()
	
	if hero._PVPStatus ~= mode then
		i3k_sbean.set_attackmode(mode)
	end
	
	self:onCloseUI()
end

function wnd_goldCoastPk:refresh()
	
end

function wnd_create(layout)
	local wnd = wnd_goldCoastPk.new()
	wnd:create(layout)
	return wnd
end
