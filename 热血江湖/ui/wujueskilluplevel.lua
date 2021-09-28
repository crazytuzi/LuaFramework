-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujueSkillUpLevel = i3k_class("wnd_wujueSkillUpLevel", ui.wnd_base)

-- 武诀技能升级
-- [eUIID_WujueSkillUpLevel]	= {name = "wujueSkillUpLevel", layout = "wujuejnsj", order = eUIO_TOP_MOST,},
-------------------------------------------------------

function wnd_wujueSkillUpLevel:ctor()

end

function wnd_wujueSkillUpLevel:configure()
	local widgets = self._layout.vars
	widgets.Close:onClick(self, self.onCloseUI)
	widgets.Active:onClick(self, self.onActiveBtn)
	widgets.leftBtn:onClick(self, self.onLeftBtnClick, -1)
	widgets.rightBtn:onClick(self, self.onLeftBtnClick, 1)
end

function wnd_wujueSkillUpLevel:refresh(skillID)
	self.skillID = skillID
	local widgets = self._layout.vars
	local skillLvl = g_i3k_game_context:getWujueSkillLevel(skillID)
	self.skillLvl = skillLvl
	local skillCfg = i3k_db_wujue_skill[skillID][skillLvl]
	local nextCfg = i3k_db_wujue_skill[skillID][skillLvl + 1]
	local wujueLevel = g_i3k_game_context:getWujueLevel()
	widgets.cover:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.coverImg))
	widgets.name:setText(skillCfg.name)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
	widgets.level:setText(string.format("%s/%s", skillLvl, #i3k_db_wujue_skill[skillID]))
	widgets.curTitle:setText(i3k_get_string(17702, skillLvl))
	widgets.curEffect:setText(skillCfg.effectDesc)
	self:setNextDesc(skillLvl + 1)
	self:setNeedItem()
end

function wnd_wujueSkillUpLevel:setNextDesc(skillLvl)
	local widgets = self._layout.vars
	local wujueLevel = g_i3k_game_context:getWujueLevel()
	local nextCfg = i3k_db_wujue_skill[self.skillID][skillLvl]
	widgets.nextTitle:setText(i3k_get_string(17702, skillLvl))
	widgets.nextEffect:setText(nextCfg.effectDesc)
	local str = i3k_get_string(17704, wujueLevel >= nextCfg.wujueReq and "green" or "red", nextCfg.wujueReq)
	if skillLvl - self.skillLvl == 1 then
		self._canBreak = g_i3k_game_context:getWujueLevel() >= nextCfg.wujueReq
	end
	if i3k_db_wujue_skill[nextCfg.skillReq] then
		local skillName = i3k_db_wujue_skill[nextCfg.skillReq][1].name
		local nextReqSkillLevel = g_i3k_game_context:getWujueSkillLevel(nextCfg.skillReq)
		str = str..i3k_get_string(17705, nextReqSkillLevel >= nextCfg.skillLevelReq and "green" or "red", skillName, nextCfg.skillLevelReq)
		if self._canBreak and skillLvl - self.skillLvl == 1 then
			self._canBreak = nextReqSkillLevel >= nextCfg.skillLevelReq
		end
	end
	widgets.des3:setText(str)
end

function wnd_wujueSkillUpLevel:setNeedItem()
	local skillLevel = g_i3k_game_context:getWujueSkillLevel(self.skillID)
	local cfg = i3k_db_wujue_skill[self.skillID][skillLevel + 1]
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
			ui.vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id).."/"..(v.count))
		end
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= (v.count) then
			ui.vars.count:setTextColor(g_i3k_get_cond_color(true))
		else
			ui.vars.count:setTextColor(g_i3k_get_cond_color(false))
		end
		scroll:addItem(ui)
	end
end

function wnd_wujueSkillUpLevel:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end


function wnd_wujueSkillUpLevel:onActiveBtn(sender)
	if not self._canBreak then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17696))
	elseif not g_i3k_db.i3k_db_wujue_consume_is_enough(i3k_db_wujue_skill[self.skillID][self.skillLvl + 1].needItems) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17697))
	else
		i3k_sbean.wujueUpSkill(self.skillID, self.skillLvl + 1)
	end
end

function wnd_wujueSkillUpLevel:onLeftBtnClick(sender, direction)
	local skillLvl = g_i3k_game_context:getWujueSkillLevel(self.skillID)
	self.targetLvl =math.max(1, math.min((self.targetLvl and self.targetLvl or (skillLvl + 1))+ direction, #i3k_db_wujue_skill[self.skillID]))
	self:setNextDesc(self.targetLvl)
end

function wnd_create(layout, ...)
	local wnd = wnd_wujueSkillUpLevel.new()
	wnd:create(layout, ...)
	return wnd;
end
