-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------
wnd_shen_bing_bing_hun = i3k_class("wnd_shen_bing_bing_hun",ui.wnd_base)

local BINGHUNT1 = "ui/widgets/shenbingbinghunt1" --预览界面
local BINGHUNT2 = "ui/widgets/shenbingbinghunt2" --升级

local SKILLTYPE_A = 2 --兵魂技能类型
local SKILLTYPE_B = 3
function wnd_shen_bing_bing_hun:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self.scroll = widgets.scroll
end

function wnd_shen_bing_bing_hun:refresh(weaponID,isPreview)
	self.scroll:removeAllChildren()
	local cfg = i3k_db_shen_bing_awake[weaponID]
	local levels = g_i3k_game_context:GetBingHunLevels(weaponID)
	for i, v in ipairs(cfg.showSkills) do
		local layer = require(isPreview and BINGHUNT1 or BINGHUNT2)()
		local widget = layer.vars
		local level = isPreview and 1 or levels[v] or 1 --2 TODO
		local skillCfg = i3k_db_shen_bing_bing_hun_skill[v][level]
		--兵魂技能特殊经验加成
		local desc = ""
		local heroLvl = g_i3k_game_context:GetLevel()
		if skillCfg.skillType and skillCfg.skillType == SKILLTYPE_A then
			local rankCoefficient = i3k_db_exp[heroLvl].artifactSkillExp1
			desc = string.format(skillCfg.desc, rankCoefficient)
		elseif skillCfg.skillType and skillCfg.skillType == SKILLTYPE_B then
			local rankCoefficient = i3k_db_exp[heroLvl].artifactSkillExp2
			desc = string.format(skillCfg.desc, rankCoefficient)
			if not isPreview then
				local maxAddExp = math.ceil(rankCoefficient * (skillCfg.maxProbability/10000))
				local curAddExp = g_i3k_game_context:GetShenbingBinghunSkillExp()
				desc = i3k_get_string(1600, desc, curAddExp, maxAddExp)
			end
		else
			desc = skillCfg.desc
		end
		widget.skill_name:setText(skillCfg.name)
		widget.skill_desc:setText(desc)
		widget.skill_lv:setText(level.."级")
		widget.skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
		if not isPreview then
			local isMax = not i3k_db_shen_bing_bing_hun_skill[v][level+1]
			widget.max:setVisible(isMax)
			widget.sj_btn:setVisible(not isMax)
			widget.sj_btn:onClick(self, self.onBingHunSkillLvUpClick, {weaponID = weaponID, skillID = v})
			widget.des2:setVisible(not isMax)
			if not isMax then
				local nextCfg = i3k_db_shen_bing_bing_hun_skill[v][level+1]
				local shenYaoType = cfg.shenYaoID
				local shenYaoCfg = i3k_db_shen_bing_shen_yao[shenYaoType][1]
				local shenYaoLvl = g_i3k_game_context:GetShenYaoLevel(shenYaoType)
				local maxShenYaoLvl = #i3k_db_shen_bing_shen_yao[shenYaoType]
				widget.des2:setText(string.format("%s%d级可升级(%d/%d)", shenYaoCfg.name, nextCfg.preConditionLvl, shenYaoLvl, nextCfg.preConditionLvl))
				widget.des2:setTextColor(g_i3k_get_cond_color(nextCfg.preConditionLvl <= shenYaoLvl))
			end
		end
		self.scroll:addItem(layer)
	end
end

function wnd_shen_bing_bing_hun:onBingHunSkillLvUpClick(sender,info)
	-- info.weaponID
	-- info.skillID
	g_i3k_ui_mgr:OpenUI(eUIID_ShenBingBingHunShengJi)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShenBingBingHunShengJi,info)
end
---------------------------------------------------------
function wnd_create(layout)
	local wnd = wnd_shen_bing_bing_hun.new()
	wnd:create(layout)
	return wnd
end
