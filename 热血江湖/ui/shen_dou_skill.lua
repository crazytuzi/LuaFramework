------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_shen_dou_skill = i3k_class("wnd_shen_dou_skill",ui.wnd_base)

local ITEM_WIGDET = "ui/widgets/shoudoujnjht"
local DESC_WIDGET = "ui/widgets/shendoujnsjt"

function wnd_shen_dou_skill:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	if widgets.okBtn then
		widgets.okBtn:onClick(self, self.onOkBtnClick)
	end
	if widgets.left then
		widgets.left:onClick(self, self.onNextPageClick, -1)
	end
	if widgets.right then
		widgets.right:onClick(self, self.onNextPageClick, 1)
	end
	if widgets.help then
		widgets.help:onClick(self, self.onHelpBtn)
	end
end

function wnd_shen_dou_skill:refresh(skillId)
	local widgets = self._layout.vars
	local lvl = g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(skillId)
	local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[skillId][math.max(1, lvl)]
	local nextCfg = i3k_db_matrail_soul_shen_dou_xing_shu[skillId][lvl + 1]
	self.nextCfg = nextCfg
	self.cfg = cfg
	self.skillId = skillId
	self.lvl = lvl
	self.condition = true
	widgets.name:setText(cfg.name)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconID))
	self:setNeedItem()
	self:setDesc1()
	self:setDesc2()
end

function wnd_shen_dou_skill:setUpLevelDesc()--升级/激活条件 只有大星术升级和其他的不一样
	local widgets = self._layout.vars
	local nextCfg = self.nextCfg
	local godLvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	local rank = godLvl / i3k_db_martial_soul_cfg.nodeCount
	local tmpStr = i3k_get_string(1721, i3k_db_martial_soul_shen_dou_grade[nextCfg.needGrade], math.modf(rank), nextCfg.needGrade)
	local str = string.format("<c=%s>%s</c>", g_i3k_get_cond_color(rank >= nextCfg.needGrade), tmpStr)
	if self.condition then
		self.condition = rank >= nextCfg.needGrade
	end
	if nextCfg.needStarLevel ~= 0 then
		local activeStars = g_i3k_game_context:GetActiveStars()
		local have = false
		for k,v in pairs(activeStars) do
			if k / 100 >= nextCfg.needStarLevel then
				have = true
				break
			end
		end
		local tmpStr = i3k_get_string(1722, i3k_db_star_soul_gears[nextCfg.needStarLevel].name)
		str = str..string.format("\n<c=%s>%s</c>", g_i3k_get_cond_color(have), tmpStr)
		if self.condition then
			self.condition = have
		end
	end
	local xingShuStr = ""
	if next(nextCfg.needXinShu) then
		for i,v in ipairs(nextCfg.needXinShu) do
			local targetSkillLvl = g_i3k_game_context:GetWeaponSoulGodStarSkillLvl(v.id)
			local isEnough = targetSkillLvl >= v.level
			local tmpStr = i3k_get_string(1724, i3k_db_matrail_soul_shen_dou_xing_shu[v.id][1].name, v.level, targetSkillLvl, v.level)
			xingShuStr = xingShuStr..string.format("\n<c=%s>%s</c>", g_i3k_get_cond_color(isEnough), tmpStr)
			if self.condition then
				self.condition = isEnough
			end
		end
	end
	str = str..xingShuStr
	widgets.desc1:setText(str)
end

function wnd_shen_dou_skill:setPreviewDesc(lvl)--大星术切换其他等级预览
	self.curPreviewLvl = lvl
	local widgets = self._layout.vars
	widgets.lable2:setText(i3k_get_string(1742, lvl))
	widgets.left:setVisible(lvl > self.lvl + 1)
	widgets.right:setVisible(lvl ~= #i3k_db_matrail_soul_shen_dou_xing_shu[self.skillId])
	local shendouLvl = g_i3k_game_context:GetWeaponSoulGodStarCurLvl()
	local rank = shendouLvl / i3k_db_martial_soul_cfg.nodeCount
	local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[self.skillId][lvl]
	local str = i3k_get_string(1723, i3k_db_martial_soul_shen_dou_grade[cfg.needGrade], math.modf(rank), cfg.needGrade)
	widgets.uprequire:setTextColor(g_i3k_get_cond_color(rank >= cfg.needGrade))
	if self.condition and lvl - self.lvl == 1 then--默认会打开比这个高一级的 进行判断条件是否满足
		self.condition = rank >= cfg.needGrade
	end
	widgets.uprequire:setText(str)
	widgets.desc2:setText(cfg.desc)
end

local strMap = {
	[g_SHEN_DOU_SKILL_MARTIAL_ID] = 1704,--武魂
	[g_SHEN_DOU_SKILL_STAR_ID] = 1705,--星耀
	[g_SHEN_DOU_SKILL_GOD_STAR_ID] = 1706,--神斗
}
--小星术 激活 或者 满级 技能描述
function wnd_shen_dou_skill:setSmallSkillActiveOrMaxDesc(widget)
	local str = i3k_get_string(strMap[self.skillId], self.cfg.args1 / 100)
	if self.skillId == g_SHEN_DOU_SKILL_STAR_ID then
		local activeStarCount = g_i3k_game_context:GetActiveStarsCount()
		local addition = i3k_db_martial_soul_cfg.addition[activeStarCount] or 0
		local cfg = i3k_db_matrail_soul_shen_dou_xing_shu[self.skillId][self.lvl] or i3k_db_matrail_soul_shen_dou_xing_shu[self.skillId][1]
		local ratio = cfg.args1 / 10000
		str = str .. '\n' .. i3k_get_string(1707, (1 + addition) * 100 * (1 + ratio))
	end
	widget:setText(str)
end

function wnd_shen_dou_skill:setNeedItem()
	local widgets = self._layout.vars
	self.isMaterialEnough = true
	widgets.consumeScroll:removeAllChildren()
	for i,v in ipairs(self.nextCfg.consume) do
		local ui = require(ITEM_WIGDET)()
		local vars = ui.vars
		vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
		vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
		vars.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		if v.id == g_BASE_ITEM_DIAMOND or v.id == g_BASE_ITEM_COIN then
			vars.item_count:setText(v.count)
		else
			vars.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(v.id) .."/".. v.count)
		end
		vars.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(v.id) >= v.count))
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			self.isMaterialEnough = false
		end
		vars.bt:onClick(self, function()
			g_i3k_ui_mgr:ShowCommonItemInfo(v.id)
		end)
		widgets.consumeScroll:addItem(ui)
	end
end

function wnd_shen_dou_skill:onOkBtnClick(sender)
	if self.condition then
		if self.isMaterialEnough then
			i3k_sbean.god_star_skill_levelup(self.skillId, self.lvl + 1)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1730))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1727))
	end
end

function wnd_shen_dou_skill:onNextPageClick(sender, direction)
	self:setPreviewDesc(self.curPreviewLvl + direction)
end

function wnd_shen_dou_skill:onHelpBtn(sender)
	local activeStarCount = g_i3k_game_context:GetActiveStarsCount()
	local addition = i3k_db_martial_soul_cfg.addition[activeStarCount] or 0
	local ratio = g_i3k_db.i3k_db_get_shen_dou_skill_prop_ratio(g_SHEN_DOU_SKILL_STAR_ID)
	local xingShuName = i3k_db_matrail_soul_shen_dou_xing_shu[g_SHEN_DOU_SKILL_STAR_ID][1].name
	local finalRatio = (1 + ratio) * (1 + addition) * 100
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1714, addition * 100, xingShuName, ratio * 100, addition * 100, ratio * 100, finalRatio, finalRatio))
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_shen_dou_skill.new()
	wnd:create(layout,...)
	return wnd
end
