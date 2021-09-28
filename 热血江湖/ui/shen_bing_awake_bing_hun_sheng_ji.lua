-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_shen_bing_bing_hun_sheng_ji = i3k_class("wnd_shen_bing_bing_hun_sheng_ji",ui.wnd_base)

local T1 = "ui/widgets/shenbingbinghunsjt"

local SKILLTYPE_A = 2 --兵魂技能类型
local SKILLTYPE_B = 3
function wnd_shen_bing_bing_hun_sheng_ji:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.look_btn:onClick(self, self.onLookBtnClick)
	widgets.up_btn:onClick(self, self.onUpBtnClick)
end

function wnd_shen_bing_bing_hun_sheng_ji:refresh(info)
	--info.weaponID
	--info.skillID
	self.info = info or self.info
	local info = self.info
	local widgets = self._layout.vars
	local level = g_i3k_game_context:GetBingHunLevel(info.weaponID, info.skillID)
	local skillCfg = i3k_db_shen_bing_bing_hun_skill[info.skillID][level]
	local nextCfg = i3k_db_shen_bing_bing_hun_skill[info.skillID][level + 1]
	if not nextCfg then
		self:onCloseUI()
		return
	end
	local cfg = i3k_db_shen_bing_awake[info.weaponID]
	local shenYaoCfg = i3k_db_shen_bing_shen_yao[cfg.shenYaoID][1]
	widgets.curName:setText(skillCfg.name..level.."级")
	widgets.nextName:setText(nextCfg.name..(level + 1).."级")
	widgets.curDes:setText(self:SkillDesc(skillCfg))
	widgets.nextDes:setText(self:SkillDesc(nextCfg))
	local shenYaoLvl = g_i3k_game_context:GetShenYaoLevel(cfg.shenYaoID)
	local maxShenYaoLvl = #i3k_db_shen_bing_shen_yao[cfg.shenYaoID]
	widgets.condition:setText(string.format("%s%d级可升级(%d/%d)", shenYaoCfg.name, nextCfg.preConditionLvl, shenYaoLvl, nextCfg.preConditionLvl))
	widgets.condition:setTextColor(g_i3k_get_cond_color(nextCfg.preConditionLvl <= shenYaoLvl))
	self.isConditionSatisfy = nextCfg.preConditionLvl <= shenYaoLvl
	self.consume = nextCfg.consume
	self:setNeedItem()
end
function wnd_shen_bing_bing_hun_sheng_ji:SkillDesc(skillCfg)
	--兵魂技能特殊经验加成
	local desc = ""
	local heroLvl = g_i3k_game_context:GetLevel()
	if skillCfg.skillType and skillCfg.skillType == SKILLTYPE_A then
		local rankCoefficient = i3k_db_exp[heroLvl].artifactSkillExp1
		desc = string.format(skillCfg.desc, rankCoefficient)
	elseif skillCfg.skillType and skillCfg.skillType == SKILLTYPE_B then
		local rankCoefficient = i3k_db_exp[heroLvl].artifactSkillExp2
		desc = string.format(skillCfg.desc, rankCoefficient)
	else
		desc = string.gsub(skillCfg.desc, '%d+','<c=green>%1</c>')
	end
	return desc
end

function wnd_shen_bing_bing_hun_sheng_ji:setNeedItem()
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	self.isMaterialEnough = true
	for i, e in ipairs(self.consume) do
		local T1 = require(T1)()
		local widget = T1.vars
		widget.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(e.itemID))
		widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID,i3k_game_context:IsFemaleRole()))
		widget.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		if e.itemID == g_BASE_ITEM_DIAMOND or e.itemID == g_BASE_ITEM_COIN then
			widget.item_count:setText(e.itemCount or e.count)
		else
			widget.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID) .."/".. e.count)
		end
		if self.isMaterialEnough then
			self.isMaterialEnough = g_i3k_game_context:GetCommonItemCanUseCount(e.itemID) >= e.count
		end
		widget.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.itemID) >= e.count))
		widget.bt:onClick(self, self.onItemTips, e.itemID)
		scroll:addItem(T1)
	end
end

function wnd_shen_bing_bing_hun_sheng_ji:onLookBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBingShenYao)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingShenYao, self.info.weaponID)
end

function wnd_shen_bing_bing_hun_sheng_ji:onUpBtnClick(sender)
	if self.isConditionSatisfy then
		if self.isMaterialEnough then
			i3k_sbean.weapon_skill_level_up(self.info.weaponID, self.info.skillID)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5343))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5345))
	end
end

function wnd_shen_bing_bing_hun_sheng_ji:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_shen_bing_bing_hun_sheng_ji.new()
	wnd:create(layout)
	return wnd
end
