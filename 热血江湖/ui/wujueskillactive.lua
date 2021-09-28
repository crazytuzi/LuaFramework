-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueSkillActive = i3k_class("wnd_wujueSkillActive", ui.wnd_base)

-- 武诀技能激活
-- [eUIID_WujueSkillActive]	= {name = "wujueSkillActive", layout = "wujuejnjh", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_wujueSkillActive:ctor()
end

function wnd_wujueSkillActive:configure()
	local widgets = self._layout.vars
	widgets.Close:onClick(self, self.onCloseUI)
	widgets.Active:onClick(self, self.onActiveBtn)
end

function wnd_wujueSkillActive:refresh(skillID)
	local widgets = self._layout.vars
	self.skillID = skillID
	self.canActive = true
	local skillCfg = i3k_db_wujue_skill[skillID][1]
	widgets.cover:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.coverImg))
	widgets.name:setText(skillCfg.name)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
	widgets.text:setText(i3k_get_string(17700, skillCfg.wujueReq))
	widgets.text:setTextColor(g_i3k_get_cond_color(skillCfg.wujueReq <= g_i3k_game_context:getWujueLevel()))
	if skillCfg.skillReq == 0 then
		widgets.text2:hide()
	else
		widgets.text2:setText(i3k_get_string(17701, i3k_db_wujue_skill[skillCfg.skillReq][1].name, skillCfg.skillLevelReq))
		if g_i3k_game_context:getWujueSkillLevel(skillCfg.skillReq) < skillCfg.skillLevelReq then
			widgets.text2:setTextColor(g_i3k_get_cond_color(false))
			self.canActive = false
		else
			widgets.text2:setTextColor(g_i3k_get_cond_color(true))
		end
	end
	if skillCfg.wujueReq > g_i3k_game_context:getWujueLevel() then
		self.canActive = false
	end
	widgets.desc:setText(skillCfg.effectDesc)
	self:setNeedItem(skillCfg)
	widgets.Active:SetIsableWithChildren(self.canActive)
end

function wnd_wujueSkillActive:setNeedItem()
	local cfg = i3k_db_wujue_skill[self.skillID][1]
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	for k, v in ipairs(cfg.needItems) do
		local ui = require("ui/widgets/wujuejnjht")()
		ui.vars.cover:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		ui.vars.Item:onClick(self, self.onItemTips, v.id)
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
		if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN then
			ui.vars.count:setText(v.count)
		else
			ui.vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. (v.count))
		end
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= (v.count) then
			ui.vars.count:setTextColor(g_i3k_get_cond_color(true))
		else
			ui.vars.count:setTextColor(g_i3k_get_cond_color(false))
		end
		scroll:addItem(ui)
	end
end

function wnd_wujueSkillActive:onActiveBtn(sender)
	if not self.canActive then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17696))
	elseif not g_i3k_db.i3k_db_wujue_consume_is_enough(i3k_db_wujue_skill[self.skillID][1].needItems) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17697))
	else
		i3k_sbean.wujueUpSkill(self.skillID, 1)
	end
end

function wnd_wujueSkillActive:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--------------------------
function wnd_create(layout, ...)
	local wnd = wnd_wujueSkillActive.new()
	wnd:create(layout, ...)
	return wnd;
end
