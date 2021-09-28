------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/shen_dou')
local BASE = ui.wnd_martial_soul_shen_dou
------------------------------------------------------
wnd_shen_dou_rank = i3k_class("wnd_shen_dou_rank", BASE)

local PROP_WIDGET = "ui/widgets/shendouphbt"

function wnd_shen_dou_rank:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.wuhunBtn:onClick(self, self.onWeaponSoulClick)
	widgets.xingyaoBtn:onClick(self, self.onStarDishClick)
	widgets.shendouBtn:stateToPressed()
	self.PROP_WIDGET = PROP_WIDGET
end

function wnd_shen_dou_rank:refresh(info)
	self.info = info
	self.lvl = info.godStar.curLevel
	self.starType = i3k_db_star_soul[info.curStar].type
	self.skillData = info.godStar.skills
	self.ACTIVE = i3k_db_martial_soul_type[self.starType].starIcon
	self:setMainPart()
	self:setPropScorll()
	self:hideAllRed()
end

function wnd_shen_dou_rank:hideAllRed()
	local widgets = self._layout.vars
	for i, v in ipairs(i3k_db_matrail_soul_shen_dou_xing_shu) do
		widgets['skillRed'..i]:hide()
	end
end

function wnd_shen_dou_rank:onWeaponSoulClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RankListWeaponSoul)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListWeaponSoul, self.info)
	self:onCloseUI()
end

function wnd_shen_dou_rank:onStarDishClick(sender)
	if self.info.curStar > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_RankStarDish)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankStarDish, self.info)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1148))
	end
end

function wnd_shen_dou_rank:onSkillBtn(sender)
	--do nothing
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_rank.new()
	wnd:create(layout,...)
	return wnd
end