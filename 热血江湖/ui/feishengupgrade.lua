module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local wnd_feishengUpgrade= i3k_class("wnd_feishengUpgrade", ui.wnd_base)
function wnd_feishengUpgrade:ctor()
	
end

function wnd_feishengUpgrade:configure()
	self.ui = self._layout.vars
	self.ui.cancel:onClick(self, self.onCloseUI)
end

function wnd_feishengUpgrade:refresh()
	local fs = g_i3k_game_context:getFeishengInfo()
	
	self.ui.desc:setText(i3k_get_string(1760, fs._level + 1))
	ui_set_hero_model(self.ui.module, i3k_db_feisheng_misc.mod)
	
	self.ui.upgrade:onClick(self, function()
		local nxtLvlCfg =  i3k_db_role_flying[fs._level + 1]
		local missionID = nxtLvlCfg.upgradeMission

		i3k_sbean.soaring_task_open(fs._level + 1, function(ok)
			g_i3k_ui_mgr:CloseUI(eUIID_FeiSheng)
			g_i3k_ui_mgr:CloseUI(eUIID_FeiShengUpgrade)
			if ok > 0 then
				g_i3k_game_context._feisheng._upgraing = true
				g_i3k_logic:OpenBattleUI()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1767, fs._upgradeCfg.name))
			else
				g_i3k_logic:OpenBattleUI()
				g_i3k_ui_mgr:PopupTipMessage("Fail to get feisheng mission")
			end
		end)
	end)
end


function wnd_create(layout)
	local wnd = wnd_feishengUpgrade.new()
	wnd:create(layout)
	return wnd
end