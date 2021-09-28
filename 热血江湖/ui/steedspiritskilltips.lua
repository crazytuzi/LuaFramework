-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedSpiritSkillTips = i3k_class("wnd_steedSpiritSkillTips", ui.wnd_base)

function wnd_steedSpiritSkillTips:ctor()

end

function wnd_steedSpiritSkillTips:configure( )
	local widgets = self._layout.vars
	self.skillIcon = widgets.skillIcon
	self.skillName = widgets.skillName
	self.skillLvl = widgets.skillLvl
	self.curTitle = widgets.curTitle
	self.curEffect = widgets.curEffect
	widgets.close:onClick(self, self.onCloseUI)
end

function wnd_steedSpiritSkillTips:refresh(id, lvl)
	local dbCfg = i3k_db_steed_fight_spirit_skill[id]
	local cfg = dbCfg[lvl]
	self.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.skillIconID))
	self.skillName:setText(cfg.skillName)
	self.skillLvl:setText(i3k_get_string(1291, lvl))
	self.curTitle:setText(i3k_get_string(1292, lvl))
	self.curEffect:setText(cfg.skillDesc)
end

function wnd_create(layout)
	local wnd = wnd_steedSpiritSkillTips.new()
	wnd:create(layout)
	return wnd
end
