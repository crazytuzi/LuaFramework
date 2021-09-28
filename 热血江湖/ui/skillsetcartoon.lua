-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_skillSetCartoon = i3k_class("wnd_skillSetCartoon", ui.wnd_base)

local INITSKILLSINDEX = 2 --初始技能开始显示索引
local LAYER_JNJMT = "ui/widgets/jnjmydt"
local SKILLGRADEICON = 151
local EQUIPSKILLNUM = 4 --右侧显示技能个数， 以及初始左侧第4个技能开始不显示已装备对号，左侧技能为初始技能234，已转12
local MODELID = 2158
local POPID = 50072
local ARENATYPE = 
{
	[1] = i3k_get_string(935),
	[2] = i3k_get_string(936),
	[3] = i3k_get_string(937),
	[4] = i3k_get_string(938),
	[5] = i3k_get_string(939),
	[6] = i3k_get_string(940),
	[7] = i3k_get_string(941),
}

local STATE = 
{
	[1] = i3k_get_string(942),
	[2] = i3k_get_string(943),
	[3] = i3k_get_string(944),
	[4] = i3k_get_string(945),
	[5] = i3k_get_string(946),
}

function wnd_skillSetCartoon:ctor()
	self._refreshWidget = {}
	self._playing = false
end

function wnd_skillSetCartoon:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.gotoSkill:onClick(self,self.onGotoSkillBt)
	widgets.again:onClick(self,self.onAgainBt)
end

function wnd_skillSetCartoon:refresh(isOpenUnique)
	self:initSkills()
	self:updateModel()
	self:onAgainBt()
end

function wnd_skillSetCartoon:initSkills()
	local widgets = self._layout.vars
	local role_id = g_i3k_game_context:GetRoleType()
	local skills = i3k_db_generals[role_id].skills
	local temSkills = {}
	local temWidSkill2 = nil
	local temWidSkill3 = nil
	
	for i, v in ipairs(skills) do
		if i >= INITSKILLSINDEX then
			table.insert(temSkills, v)
		end
	end
	
	local tranSkillCfg = i3k_db_zhuanzhi[role_id][1][0]
	
	table.insert(temSkills, tranSkillCfg.skill1)
	table.insert(temSkills, tranSkillCfg.skill2)
	
	widgets.skillScroll:removeAllChildren()
	
	for i, v in ipairs(temSkills) do
		local _layer = require(LAYER_JNJMT)()
		local wid = _layer.vars
		local _skill_data = i3k_db_skills[v]
		local icon = i3k_db_icons[_skill_data.icon]
		wid.skill_icon:setImage(icon.path)
		wid.borderIcon:setImage(i3k_db_icons[SKILLGRADEICON].path)
		wid.is_equip:setVisible(i < EQUIPSKILLNUM) --初始状态的附加1，2技能为无装备状态			
		widgets.skillScroll:addItem(_layer)
		
		if i == 1 then
			temWidSkill2 = wid.is_equip
		elseif i == 2 then
			temWidSkill3 = wid.is_equip
		elseif i == 4 then
			table.insert(self._refreshWidget, {orign = {after = wid.is_equip, before = temWidSkill2}, skillId = v})
		elseif i == 5 then
			table.insert(self._refreshWidget, {orign = {after = wid.is_equip, before = temWidSkill3}, skillId = v})
		end
	end
	
	--右侧
	widgets.unique_pos:setVisible(false)
	local rightSkills = {}
	
	for i = 1, EQUIPSKILLNUM do
		rightSkills[i] = {}
		rightSkills[i].bg = widgets["skillBG" .. i]
		rightSkills[i].img = widgets["skill_img" .. i]
	end
	
	self._refreshWidget[1].target = rightSkills[2].img
	self._refreshWidget[2].target = rightSkills[3].img
	
	for i, v in ipairs(skills) do
		local _skill_data = i3k_db_skills[v]
		local icon = i3k_db_icons[_skill_data.icon]
		rightSkills[i].bg:setImage(i3k_db_icons[SKILLGRADEICON].path) 
		rightSkills[i].img:setImage(icon.path) 
	end
end

function wnd_skillSetCartoon:updateModel()
	local widgets = self._layout.vars
	g_i3k_game_context:ResetTestFashionData()
	ui_set_hero_model(widgets.hero3d, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
	local mcfg = i3k_db_models[MODELID];
	--widgets.model:setLocalZOrder(99)
	widgets.model:setSprite(mcfg.path);
	widgets.model:setSprSize(mcfg.uiscale);
	widgets.model:playAction("stand")
	widgets.name:setText(i3k_get_string(POPID))
end

function wnd_skillSetCartoon:initSkillDes(skillId)
	local widgets = self._layout.vars
	local _skill_data = i3k_db_skills[skillId]
	local _skill_data1 = i3k_db_skill_datas[skillId]
	local newSkillCfg = _skill_data1[1]
	widgets.skill_lvl:setText(i3k_get_string(947, 1))--只显示1
	widgets.skill_lvl:setTextColor(g_i3k_get_green_color())
	widgets.skill_transfer:setVisible(g_i3k_db.i3k_db_get_skill_info(skillId) ~= "")
	widgets.skill_transfer:setText(g_i3k_db.i3k_db_get_skill_info(skillId))
	widgets.qigong_desc:setVisible(false)
	widgets.jade_desc:setVisible(false)
	widgets.state_desc:setVisible(true)
	widgets.state_desc:setText(i3k_get_string(956, _skill_data.stateDesc[1]))
	widgets.skill_name:setText(_skill_data.name)
	widgets.skill_scope:setText(i3k_get_string(952, ARENATYPE[_skill_data.scope.type]))
	widgets.skill_time:setVisible(not g_i3k_game_context:GetIsNotDrag(skillId))
	widgets.skill_time:setText(i3k_get_string(953, newSkillCfg.cool / 1000))
	widgets.skill_state:setText(i3k_get_string(954, STATE[1]))
	widgets.skill_state:setTextColor(g_i3k_get_color_by_rank(1))
	widgets.verseTxt:setText(_skill_data.verse)
	local tmp_str = string.format(_skill_data.common_desc, newSkillCfg.spArgs1, newSkillCfg.spArgs2, newSkillCfg.spArgs3, newSkillCfg.spArgs4, newSkillCfg.spArgs5)
	widgets.skill_desc:setText(tmp_str)
end

function wnd_skillSetCartoon:onGotoSkillBt()
	g_i3k_logic:OpenSkillLyUI()
end

function wnd_skillSetCartoon:onAgainBt()
	if self._playing then
		return
	end
	
	self._playing = true
	local widgets = self._layout.vars
	--self._cor = g_i3k_coroutine_mgr:StartCoroutine(function ()
		--g_i3k_coroutine_mgr.WaitForSeconds(CARTOONINTERVAL)
	--end)
	local info1 = self._refreshWidget[1]
	local info2 = self._refreshWidget[2]
	local path1 = i3k_db_icons[i3k_db_skills[info1.skillId].icon].path
	local path2 = i3k_db_icons[i3k_db_skills[info2.skillId].icon].path
	widgets.cartoon:setImage(path1)
	self:initSkillDes(info1.skillId)
	--self._layout.anis.nuo1.stop()
	self._layout.anis.c_zy1.play(function()
		info1.orign.after:setVisible(true)
		info1.orign.before:setVisible(false)
		info1.target:setImage(path1)
		self:initSkillDes(info2.skillId)
		widgets.cartoon:setImage(path2)
		self._layout.anis.c_zy2.play(function()
			info2.orign.after:setVisible(true)
			info2.orign.before:setVisible(false)
			info2.target:setImage(path2)
			self._playing = false
		end)
	end
	)
end

function wnd_create(layout)
	local wnd = wnd_skillSetCartoon.new()
	wnd:create(layout)
	return wnd
end
