-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_wujue = i3k_class("wnd_wujue", ui.wnd_base)

-- 武诀（吐纳系统）
-- [eUIID_Wujue]	= {name = "wujue", layout = "wujue", order = eUIO_TOP_MOST,},
-------------------------------------------------------
local SKILL_COUNT = 8

function wnd_wujue:ctor()

end

function wnd_wujue:configure()
	self.wujueItems = {}
	for k, v in pairs(i3k_db_new_item) do
		if v.type == UseItemWuJueExp then
			table.insert(self.wujueItems, k)
		end
	end
	local widgets = self._layout.vars
	widgets.xinfa_btn:onClick(self, self.onXinfaBtn)
	widgets.skill_btn:onClick(self, self.onSkillBtn)
	widgets.meridian_btn:onClick(self, self.onMeridianBtn)
	widgets.tipBtn:onClick(self, self.onTipBtn)
	widgets.OK:onClick(self, self.onOKBtn)
	widgets.help:onClick(self, self.onHelpBtn)
	widgets.close:onClick(self, self.onCloseUI)
	widgets.getExpBtn:onClick(self, self.onGetExpBtn)
	widgets.wujue:stateToPressed()
	self:setSkillButtons()
end

function wnd_wujue:refresh()
	local data = g_i3k_game_context:getWujueData()
	local level = data.level
	local exp = data.exp
	local dayExp = data.dayExp
	local rank = data.rank
	self.skills = data.skills
	local widgets = self._layout.vars
	local activity = g_i3k_game_context:GetScheduleInfo().activity
	local breakCfg = i3k_db_wujue_break[rank]
	local nextBreakCfg = i3k_db_wujue_break[rank + 1]
	local levelCfg = i3k_db_wujue_level[level]
	local nextLevelCfg = i3k_db_wujue_level[level + 1]
	widgets.level:setText(level)
	widgets.barText:setText(string.format("%s/%s",exp,nextLevelCfg.needExp))
	widgets.bar:setPercent(exp / nextLevelCfg.needExp * 100)
	widgets.OKText:setText(i3k_get_string(17692, breakCfg.name))
	widgets.activity:setText(activity)
	widgets.transformExp:setText(dayExp)
	widgets.des:setText(i3k_get_string(17693))
	widgets.des2:setText(i3k_get_string(17703))
	widgets.tipLabel:setVisible(level == breakCfg.levelTop and exp >= nextLevelCfg.needExp and rank < #i3k_db_wujue_break)
	widgets.nextProp:setVisible(not(level == breakCfg.levelTop and rank == #i3k_db_wujue_break))
	widgets.maxRankImg:setVisible(not g_i3k_db.i3k_db_wujue_can_get_exp())
	widgets.getExpBtn:setVisible(g_i3k_db.i3k_db_wujue_can_get_exp())
	self:updateSkills()
	self:setProps(level)
	self:setRedPoint()
end

function wnd_wujue:setAddExpRedPoint()--道具加武诀经验红点
	local widgets = self._layout.vars
	local data = g_i3k_game_context:getWujueData()
	if g_i3k_db.i3k_db_wujue_can_get_exp() and g_i3k_game_context:isHaveWujueAddExpProp(self.wujueItems) then
		widgets.red_point_exp:setVisible(true)
	else
		widgets.red_point_exp:setVisible(false)
	end
end

function wnd_wujue:setTupoRedPoint()--突破红点
	local widgets = self._layout.vars
	widgets.red_point_tp:setVisible(g_i3k_game_context:isShowWujueTupoRedPoint())
end

function wnd_wujue:setSkillRedPoint(skillID)--各技能红点
	local widgets = self._layout.vars
	local skillUIId = g_i3k_db.i3k_db_get_wujue_skill_ui_id(skillID)
	widgets["arrow" .. skillUIId]:setVisible(g_i3k_game_context:isShowWujueSkillRedPoint(skillID))
end

function wnd_wujue:setSoulSkillRedPoint(soulId)
	local widgets = self._layout.vars
	widgets["qh_red"..soulId]:setVisible(g_i3k_game_context:isShowWujueSoulRedPoint(soulId))
end
function wnd_wujue:setRedPoint()
	local widgets = self._layout.vars
	widgets.red_point_2:setVisible(g_i3k_game_context:isShowSkillRedPoint() or g_i3k_game_context:isShowUniqueSkillRedPoint())
	widgets.red_point_1:setVisible(g_i3k_game_context:isShowXinfaRedPoint())
	widgets.red_point_3:setVisible(g_i3k_game_context:GetIsMeridianRed())
	widgets.red_point_4:setVisible(g_i3k_game_context:isShowWujueRedPoint())
	self:setTupoRedPoint()
	local wujueData = g_i3k_game_context:getWujueData()
	for k,v in ipairs(i3k_db_wujue_skill) do
		self:setSkillRedPoint(k)
	end
	for k,v in ipairs(i3k_db_wujue.soulCfg) do
		self:setSoulSkillRedPoint(k)
	end
	self:setAddExpRedPoint()
end

function wnd_wujue:setSkillButtons()
	local widgets = self._layout.vars
	for i = 1, SKILL_COUNT do
		local uiID = g_i3k_db.i3k_db_get_wujue_skill_ui_id(i)
		widgets["skill"..uiID]:onClick(self, self.onSkillInfoBtn, i)-- 其中1,5 两个按钮为主技能
	end
end

-- 更新技能
function wnd_wujue:updateSkills()
	local widgets = self._layout.vars
	for i = 1, SKILL_COUNT do
		local skillLevel = self.skills[i] or 0
		local showLevel = skillLevel == 0 and 1 or skillLevel
		local skillCfg = i3k_db_wujue_skill[i][showLevel]
		local uiID = g_i3k_db.i3k_db_get_wujue_skill_ui_id(i)
		if widgets["line"..uiID] then
			widgets["line"..uiID]:setImage(g_i3k_db.i3k_db_get_icon_path(skillLevel > 0 and 7881 or 7882))
		end
		widgets["levelBoard"..uiID]:setVisible(skillLevel > 0)
		widgets["level"..uiID]:setVisible(skillLevel > 0)
		widgets["level"..uiID]:setText(skillLevel)
		widgets["skillCover"..uiID]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.coverImg))
		widgets["icon"..uiID]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.icon))
	end
	for i,v in ipairs(i3k_db_wujue.soulCfg) do
		widgets["qh_icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(v.soulIcon))
		local lvl = g_i3k_game_context:getWujueSoulLvl(i)
		local cfg = i3k_db_wujue_soul[i][lvl]
		if cfg then
			widgets["qh_lvl_bg"..i]:show()
			widgets["qh_lvl"..i]:setText(cfg.rank)
		else
			widgets["qh_lvl"..i]:setText("")
			widgets["qh_lvl_bg"..i]:hide()
		end
		widgets["qh_btn"..i]:onClick(self, self.onWujueSoulBtnClick, i)
	end
end

function wnd_wujue:setProps(level)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local curProp = g_i3k_db.i3k_db_get_wujue_level_prop(level)
	local nextProp = g_i3k_db.i3k_db_get_wujue_level_prop(level + 1)
	local rank = g_i3k_game_context:getWujueRank()
	for i, v in ipairs(curProp) do
		local prop = i3k_db_prop_id[v.id] --属性的相关信息
		local diff = nextProp and nextProp[i].value - v.value or 0
		if diff > 0 or not nextProp then
			local ui = require("ui/widgets/wujuet")()
			ui.vars.btn:onClick()
			ui.vars.from:setText(v.value)
			if rank == #i3k_db_wujue_break and level == i3k_db_wujue_break[rank].levelTop then
				ui.vars.to:hide()
				ui.vars.arrow:hide()
			else
				ui.vars.to:setText(diff)
			end
			ui.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(prop.icon))
			ui.vars.name:setText(prop.desc)
			scroll:addItem(ui)
		end
	end
end


function wnd_wujue:onTipBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_WujueRules)
	g_i3k_ui_mgr:RefreshUI(eUIID_WujueRules)
end

function wnd_wujue:onOKBtn(sender)
	if g_i3k_game_context:getWujueRank() >= #i3k_db_wujue_break then
		g_i3k_ui_mgr:OpenUI(eUIID_WujueBreakFull)
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueBreakFull)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_WujueBreak)
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueBreak)
	end
end

function wnd_wujue:onSkillInfoBtn(sender, skillID)
	if self.skills[skillID] == 0 or not self.skills[skillID] then
		g_i3k_ui_mgr:OpenUI(eUIID_WujueSkillActive)
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueSkillActive, skillID)
	elseif self.skills[skillID] == #i3k_db_wujue_skill[skillID] then
		g_i3k_ui_mgr:OpenUI(eUIID_WujueSkillFull)
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueSkillFull, skillID)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_WujueSkillUpLevel)
		g_i3k_ui_mgr:RefreshUI(eUIID_WujueSkillUpLevel, skillID)
	end
end

function wnd_wujue:onWujueSoulBtnClick(sender, soulId)
	g_i3k_ui_mgr:OpenUI(eUIID_WujueSoulSkill)
	g_i3k_ui_mgr:RefreshUI(eUIID_WujueSoulSkill, soulId)
end
function wnd_wujue:onXinfaBtn(sender)
	local openLvl = i3k_db_common.functionOpen.xinfaOpenLvl
	if g_i3k_game_context:GetLevel() < openLvl or g_i3k_game_context:GetTransformLvl() < 2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(712,openLvl)) --"功系统将于%s级并二转后开启
		return
	end
	self:onCloseUI()
	g_i3k_logic:OpenXinfaUI()
end

function wnd_wujue:onSkillBtn(sender)
	self:onCloseUI()
	g_i3k_logic:OpenSkillLyUI()
end

function wnd_wujue:onMeridianBtn(sender)
	g_i3k_logic:OpenMeridian(eUIID_Wujue)
end


function wnd_wujue:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(17708))
end

function wnd_wujue:onGetExpBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_WujueUseItems)
	g_i3k_ui_mgr:RefreshUI(eUIID_WujueUseItems)
end

function wnd_create(layout, ...)
	local wnd = wnd_wujue.new()
	wnd:create(layout, ...)
	return wnd;
end
