-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_biography_skills = i3k_class("wnd_biography_skills", ui.wnd_base)

local skill_grade = {151,152,153,154,155}
local MAX_STATE = 4
local tag_area = {
[1] = i3k_get_string(935),
[2] = i3k_get_string(936),
[3] = i3k_get_string(937),
[4] = i3k_get_string(938),
[5] = i3k_get_string(939),
[6] = i3k_get_string(940),
[7] = i3k_get_string(941),
}
local STATE = {
[1] = i3k_get_string(942),
[2] = i3k_get_string(943),
[3] = i3k_get_string(944),
[4] = i3k_get_string(945),
[5] = i3k_get_string(946),
}

function wnd_biography_skills:ctor()
	self._allSkills = {}
	self._equipSkills = {}
	self._curCareer = 1
	self._stateLv = 1
	self._skillLevel = 1
	self._equipIndex = 0
	self._scrollIndex = 1
	self._skillId = 0
	self._movePosition = {}
end

function wnd_biography_skills:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.qigong_btn:onClick(self, self.onQigong)
	self._layout.vars.help_btn:onClick(self, self.onShowHelp)
	for k = 1, 4 do
		self._layout.vars["skillBtn"..k]:onClick(self, self.onChooseEquipSkill, k)
	end
end

function wnd_biography_skills:refresh()
	self._layout.vars.qigong_btn:stateToNormal()
	self._layout.vars.skill_btn:stateToPressed()
	self._curCareer = g_i3k_game_context:getCurBiographyCareerId()
	local allSkills = g_i3k_game_context:getBiographyCareerSkills()
	self._allSkills = allSkills[self._curCareer]
	self._equipSkills = g_i3k_game_context:getBiographyCareerEquipSkills()
	self._stateLv = i3k_db_wzClassLand[self._curCareer].skillState
	self._skillLevel = i3k_db_wzClassLand[self._curCareer].skillLevel
	self:updateSkillScroll()
	self:updateEquipSkills()
	self._skillId = self._allSkills[self._scrollIndex]
	self:updateChooseSkillInfo()
	self:updateOutCareerModel()
	local qigong = g_i3k_game_context:getBiographyCareerQigong()
	if qigong and qigong[self._curCareer] and next(qigong[self._curCareer]) then
		self._layout.vars.qigong_btn:show()
	else
		self._layout.vars.qigong_btn:hide()
	end
end

function wnd_biography_skills:updateOutCareerModel()
	local careerData = g_i3k_game_context:getBiographyCareerInfo()
	local gender = g_i3k_game_context:GetRoleGender()
	local fashionId = i3k_db_generals[self._curCareer].fashion[gender]
	local fashionCfg = i3k_db_general_fashion[fashionId]
	local equips = {}
	if careerData and careerData[self._curCareer] and careerData[self._curCareer].taskId ~= 0 then
		local taskCfg = i3k_db_wzClassLand_task[self._curCareer][careerData[self._curCareer].taskId]
		equips = {[eEquipWeapon] = i3k_db_wzClassLand_prop[taskCfg.changeClassID].weapon, [eEquipClothes] = i3k_db_wzClassLand_prop[taskCfg.changeClassID].chest}
	end
	local modelTable = {}
	modelTable.node = self._layout.vars.hero3d
	modelTable.id = self._curCareer
	modelTable.bwType = g_i3k_game_context:GetTransformBWtype()
	modelTable.gender = gender
	modelTable.face = fashionCfg.faceSkin[1]
	modelTable.hair = fashionCfg.hairSkin[1]
	modelTable.equips = equips
	modelTable.fashions = {}
	modelTable.isshow = nil
	modelTable.equipparts = nil
	modelTable.armor = nil
	modelTable.weaponSoulShow = nil
	modelTable.isEffectFashion = nil
	modelTable.soaringDisplay = nil
	self:createModelWithCfg(modelTable)
end

function wnd_biography_skills:updateSkillScroll()
	self._layout.vars.skillScroll:removeAllChildren()
	for k, v in ipairs(self._allSkills) do
		local node = require("ui/widgets/jnjm2t")()
		node.vars.borderIcon:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[self._stateLv + 1]))
		node.vars.skill_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[v].icon))
		if table.indexof(self._equipSkills, v) then
			node.vars.is_equip:show()
		else
			node.vars.is_equip:hide()
		end
		local passiveSkill = g_i3k_game_context:GetRolePassiveSkills()
		local is_passive = passiveSkill[v] ~= nil or g_i3k_game_context:GetIsNotDrag(v)
		node.vars.is_passive:setVisible(is_passive)
		node.vars.lock:hide()
		node.vars.redPoint:hide()
		if self._scrollIndex == k then
			node.vars.skill_move:stateToPressed()
		else
			node.vars.skill_move:stateToNormal()
		end
		node.vars.skill_move:onTouchEvent(self, self.onSkillMove, {index = k, is_passive = is_passive})
		self._layout.vars.skillScroll:addItem(node)
	end
end

function wnd_biography_skills:updateEquipSkills()
	for k, v in ipairs(self._equipSkills) do
		if v == 0 then
			self._layout.vars["skill_lock"..k]:show()
		else
			self._layout.vars["skillBG"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(skill_grade[self._stateLv + 1]))
			self._layout.vars["skill_img"..k]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[v].icon))
			self._layout.vars["skill_lock"..k]:hide()
		end
	end
end

function wnd_biography_skills:updateChooseSkillInfo()
	self._layout.vars.skill_state_btn:disableWithChildren()
	if self._stateLv == MAX_STATE then --境界按钮
		self._layout.vars.skill_state_btn_lab:setText(i3k_get_string(949))
	else
		self._layout.vars.skill_state_btn_lab:setText(i3k_get_string(950))
	end
	
	local skillCfg = i3k_db_skills[self._skillId]
	local skillData = i3k_db_skill_datas[self._skillId]
	self._layout.vars.skill_name:setText(skillCfg.name)
	self._layout.vars.skill_lvl:setText(i3k_get_string(947, self._skillLevel))
	self._layout.vars.skill_lvl:setTextColor(g_i3k_get_green_color())
	self._layout.vars.skill_transfer:setVisible(g_i3k_db.i3k_db_get_skill_info(self._skillId) ~= "")
	self._layout.vars.skill_transfer:setText(g_i3k_db.i3k_db_get_skill_info(self._skillId))
	self._layout.vars.skill_scope:setText(i3k_get_string(952, tag_area[skillCfg.scope.type]))
	self._layout.vars.skill_time:setVisible(not g_i3k_game_context:GetIsNotDrag(self._skillId))
	self._layout.vars.skill_time:setText(i3k_get_string(953, skillData[self._skillLevel].cool / 1000))
	self._layout.vars.skill_state:setText(i3k_get_string(954, STATE[self._stateLv + 1]))
	self._layout.vars.skill_state:setTextColor(g_i3k_get_color_by_rank(self._stateLv + 1))
	self._layout.vars.verseTxt:setText(skillCfg.verse)
	local newSkillCfg = skillData[self._skillLevel]
	local commonDesc = skillCfg.common_desc
	local tmp_str = string.format(commonDesc, newSkillCfg.spArgs1, newSkillCfg.spArgs2, newSkillCfg.spArgs3, newSkillCfg.spArgs4, newSkillCfg.spArgs5)
	self._layout.vars.skill_desc:setText(tmp_str)---效果描述now_lv longyin显示龙印
	
	local addDesc = {}
	local passiveSkill, xinfaIDs = g_i3k_game_context:GetRolePassiveSkills()
	if passiveSkill[self._skillId] ~= nil and xinfaIDs[self._skillId] then
		table.insert(addDesc, i3k_get_string(955, i3k_db_xinfa[xinfaIDs[self._skillId]].name))
	elseif g_i3k_game_context:GetIsNotDrag(self._skillId) then
		local desc = g_i3k_db.i3k_db_get_skill_type(self._skillId) == eSE_PASSIVE and i3k_get_string(1024) or i3k_get_string(1025)
		table.insert(addDesc, desc)
	end
	table.insert(addDesc, i3k_get_string(956, i3k_db_skills[self._skillId].stateDesc[self._stateLv + 1]))
	for k = 1, 3 do
		if addDesc[k] then
			self._layout.vars["state_desc"..k]:show()
			self._layout.vars["state_desc"..k]:setText(addDesc[k])
		else
			self._layout.vars["state_desc"..k]:hide()
		end
	end
end

function wnd_biography_skills:onSkillMove(sender, eventType, data)
	local touchPos = g_i3k_ui_mgr:GetMousePos()
	local parent = self._layout.vars.move_btn:getParent()
	if parent then
		self._movePosition = parent:convertToNodeSpace(cc.p(touchPos.x, touchPos.y))
	end
	--self._layout.vars.move_btn:hide()
	if eventType == ccui.TouchEventType.began then
		if self._equipIndex ~= 0 then
			self._layout.vars["skillBtn"..self._equipIndex]:stateToNormal()
			self._equipIndex = 0
		end
		if self._scrollIndex ~= data.index then
			local children = self._layout.vars.skillScroll:getAllChildren()
			if self._scrollIndex ~= 0 then
				children[self._scrollIndex].vars.skill_move:stateToNormal()
			end
			self._scrollIndex = data.index
			self._skillId = self._allSkills[self._scrollIndex]
			children[self._scrollIndex].vars.skill_move:stateToPressed()
		end
		self:updateChooseSkillInfo()
		if not data.is_passive then
			local iconId = i3k_db_skills[self._skillId].icon
			local icon = i3k_db_icons[iconId]
			self._layout.vars.move_btn:setImage(icon.path, icon.path)
			self._layout.vars.move_btn:show()
			self._layout.vars.move_btn:setPosition(self._movePosition)
		end
	elseif eventType == ccui.TouchEventType.moved then
		if not data.is_passive then
			self._layout.vars.move_btn:show()
			self._layout.vars.move_btn:setPosition(self._movePosition)
		end
	else
		if not data.is_passive then
			self:selectSkill(touchPos)
		end
	end
end

function wnd_biography_skills:selectSkill(touchPos)
	local parent = self._layout.vars.move_btn:getParent()
	local touch = parent:convertToNodeSpace(touchPos)
	for i = 1, 4 do
		local pos = self._layout.vars["skill_img"..i]:getParent():convertToWorldSpace(self._layout.vars["skill_img"..i]:getPosition())
		pos = parent:convertToNodeSpace(pos)
		local distance = math.sqrt((touch.x - pos.x) * (touch.x - pos.x) + (touch.y - pos.y) * (touch.y - pos.y))
		local radius = self._layout.vars["skillBG"..i]:getPosition()
		if distance <= radius.x then
			local isMutex, s2 = g_i3k_db.i3k_db_check_skill_mutex(self._skillId, i)
			if isMutex then
				local s1Name = i3k_db_skills[self._skillId].name
				local s2Name = i3k_db_skills[s2].name
				g_i3k_ui_mgr:PopupTipMessage("["..s1Name.."]与["..s2Name.."]技能互斥，无法装备")
				self._layout.vars.move_btn:hide()
				return false
			end
			i3k_sbean.biography_class_skill_select({[i] = self._skillId})
			self._layout.vars["skill_img"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_skills[self._skillId].icon))
			self._layout.vars["skillBG"..i]:setImage(i3k_db_icons[skill_grade[self._stateLv + 1]].path)
			self._layout.vars.move_btn:hide()
			return true
		end
	end
	self._layout.vars.move_btn:hide()
end

function wnd_biography_skills:onChooseEquipSkill(sender, index)
	if self._equipIndex ~= index then
		if self._scrollIndex ~= 0 then
			local children = self._layout.vars.skillScroll:getAllChildren()
			children[self._scrollIndex].vars.skill_move:stateToNormal()
			self._scrollIndex = 0
		end
		if self._equipIndex ~= 0 then
			self._layout.vars["skillBtn"..self._equipIndex]:stateToNormal()
		end
		self._equipIndex = index
		self._skillId = self._equipSkills[self._equipIndex]
		self._layout.vars["skillBtn"..index]:stateToPressed()
		self:updateChooseSkillInfo()
	end
end

function wnd_biography_skills:changeSkillSuccess()
	self._equipSkills = g_i3k_game_context:getBiographyCareerEquipSkills()
	local children = self._layout.vars.skillScroll:getAllChildren()
	for k, v in ipairs(children) do
		if table.indexof(self._equipSkills, self._allSkills[k]) then
			v.vars.is_equip:show()
		else
			v.vars.is_equip:hide()
		end
	end
	self:updateEquipSkills()
	--self:updateChooseSkillInfo()
end

function wnd_biography_skills:onQigong(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BiographyQigong)
	g_i3k_ui_mgr:RefreshUI(eUIID_BiographyQigong)
	g_i3k_ui_mgr:CloseUI(eUIID_BiographySkills)
end

function wnd_biography_skills:onShowHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(18532))
end

function wnd_create(layout)
	local wnd = wnd_biography_skills.new()
	wnd:create(layout)
	return wnd
end
