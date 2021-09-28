-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_createHomeLandTips = i3k_class("wnd_createHomeLandTips", ui.wnd_base)


function wnd_createHomeLandTips:ctor()
	
end

function wnd_createHomeLandTips:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onClose)
	widgets.createBtn:onClick(self, self.onCreateHomeLand)
	widgets.desc:setText(i3k_get_string(5490))
end

function wnd_createHomeLandTips:onCreateHomeLand(sender)
	g_i3k_logic:OpenBattleUI()
	g_i3k_game_context:GotoNpc(i3k_db_home_land_base.baseCfg.npcID)
end

function wnd_createHomeLandTips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_CreateHomeLandTips)
end

function wnd_create(layout)
	local wnd = wnd_createHomeLandTips.new()
	wnd:create(layout)
	return wnd
end