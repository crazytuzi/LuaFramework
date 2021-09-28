-- modify by zhangbing 2018/07/18
-- eUIID_HuoBanCopy
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_huobanCopy= i3k_class("wnd_huobanCopy",ui.wnd_base)

function wnd_huobanCopy:ctor()

end

function wnd_huobanCopy:configure()
	local widgets = self._layout.vars

	self.lvlLimit	= widgets.lvlLimit
	self.enterTimes	= widgets.enterTimes
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.sure_btn:onClick(self, self.onCloseUI)
	widgets.open_code_btn:onClick(self, self.openCode)
end

function wnd_huobanCopy:openCode(sender)
	local cfg = i3k_db_partner_base.cfg
	local roleLvl = g_i3k_game_context:GetLevel()
	if roleLvl < cfg.openLvl or roleLvl > cfg.maxLvl then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17381))
	end
	g_i3k_logic:OpenPartnerUI()
end

function wnd_huobanCopy:refresh(npcDungeonID)
	local dungeonCfg = i3k_db_NpcDungeon[npcDungeonID]
	local cfg = i3k_db_partner_base.cfg
	self.lvlLimit:setText(i3k_get_string(17383, cfg.openLvl, cfg.maxLvl))
	self.enterTimes:setText(dungeonCfg.joinCnt)
end

function wnd_create(layout)
	local wnd = wnd_huobanCopy.new()
	wnd:create(layout)
	return wnd
end