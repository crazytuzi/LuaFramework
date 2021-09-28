module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleOfflineExp = i3k_class("wnd_battleOfflineExp", ui.wnd_base)

function wnd_battleOfflineExp:ctor()

end

function wnd_battleOfflineExp:configure()
	self.offlineRoot = self._layout.vars.offlineRoot
    self._layout.vars.offlineIcon:onClick(self, self.onShowDrugShop)
end

function wnd_battleOfflineExp:refresh()

end



function wnd_battleOfflineExp:onShowDrugShop(sender)
	local maptype = i3k_game_get_map_type()
	if maptype == g_FIELD then
		g_i3k_logic:OpenOfflineExpUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(388))
	end
end

function wnd_create(layout)
	local wnd = wnd_battleOfflineExp.new()
		wnd:create(layout)
	return wnd
end
