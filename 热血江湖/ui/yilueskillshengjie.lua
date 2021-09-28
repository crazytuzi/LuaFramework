------------------------------------------------------
module(...,package.seeall)

local require = require

require("ui/ui_funcs")

local ui = require('ui/base')
------------------------------------------------------
wnd_yilueSkillShengjie = i3k_class("wnd_yilueSkillShengjie",ui.wnd_base)

function wnd_yilueSkillShengjie:configure()
	self.ui = self._layout.vars
	self.id = 0
	self.ui.Close:onClick(self, self.onCloseUI)
	self.skill = {}
	self.skillJieData = {}
	self.ui.Active:onClick(self, self.onShengjieSkill)
	self.isEnough = true
end

function wnd_yilueSkillShengjie:refresh(id, level)
	self.id = id
	self.skill = i3k_db_bagua_yilue_skill[id]   --技能基本信息
	self.skillJieData = self.skill.skillJie[level + 1]

	self.ui.cover:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_bagua_cfg.yilueType[self.skill.skillType].skillKuangID))
	self.ui.icon:setImage(g_i3k_db.i3k_db_get_icon_path(self.skill.iconID))
	self.ui.name:setText(self.skill.skillName)
	self.ui.level:setText(level.."/"..#self.skill.skillJie)
	self.ui.curTitle:setText(i3k_get_string(17702, level))
	self.ui.nextTitle:setText(i3k_get_string(17702, level + 1))
	self.ui.maxCount1:setText(i3k_get_string(18239, self.skill.skillJie[level].maxCount))
	self.ui.maxCount2:setText(i3k_get_string(18239, self.skill.skillJie[level + 1].maxCount))
	self.ui.effect1:setText(self.skill.skillJie[level].skillDesc)
	self.ui.effect2:setText(self.skill.skillJie[level + 1].skillDesc)

	self:refreshItemList()
end

function wnd_yilueSkillShengjie:refreshItemList()
	self.isEnough = true
	self.ui.scroll:removeAllChildren()
	for id,count in pairs(self.skillJieData.needCfg) do
		local item = require("ui/widgets/baguaysjnjst")()
		item.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		item.vars.cover:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		if g_i3k_db.i3k_db_check_item_haveCount_isShow(id) then
			item.vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(id).."/"..count)
		else
			item.vars.count:setText(count)
		end

		item.vars.count:setTextColor(g_i3k_get_cond_color(count <= g_i3k_game_context:GetCommonItemCanUseCount(id)))
		if self.isEnough then
			self.isEnough = count <= g_i3k_game_context:GetCommonItemCanUseCount(id)
		end
		item.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(id))
		item.vars.Item:onClick(self, self.onItemTips, id)
		self.ui.scroll:addItem(item)
	end
end

function wnd_yilueSkillShengjie:onShengjieSkill()
	if self.isEnough then
		i3k_sbean.BaguaSkillUplevel(self.id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18246))
	end
end

function wnd_yilueSkillShengjie:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_yilueSkillShengjie.new()
	wnd:create(layout,...)
	return wnd
end
