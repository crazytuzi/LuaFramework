-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_skill_preset = i3k_class("wnd_skill_preset", ui.wnd_base)

local sch_path1 = "ui/widgets/jnqht"
local sch_path2 = "ui/widgets/jnqht2"

local l_tag = 1000
local l_num_perItem = 3

local l_topbtn_name = {l_topbtn_name_1 = {i3k_get_string(714),i3k_get_string(715),i3k_get_string(716)},l_topbtn_name_2 = i3k_get_string(717),l_topbtn_name_3 = i3k_get_string(718)}
local skill_grade = {151,152,153,154,155}

local l_coolskill_second = 10
local l_coolspirits_second = 10

local timeCounter = 0

function wnd_skill_preset:ctor()
	self.topNum = 1
	self.typeNum = 1
	self.topBtn = {}
	self.skillIndex = nil
	self.coolTime = nil
end

function wnd_skill_preset:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	for i=1,3 do
		local btnDeatil = widgets[string.format("top_btn%s",i)]
		btnDeatil:setTag(i + l_tag)
		btnDeatil:onClick(self, self.onTopClick)
		table.insert(self.topBtn, btnDeatil)
	end
end

function wnd_skill_preset:refresh(typeNum, skillIndex)
	--self.activity:		int32	
	--self.task2num:		map[int32, int32]	
	--self.rewards:		set[int32]
	self.typeNum = typeNum
	self.skillIndex = skillIndex
	local widgets = self._layout.vars
	for i=1,3 do
		local btnTxt = widgets[string.format("btn%s_txt",i)]
		if i == 1 then 
			if l_topbtn_name.l_topbtn_name_1[typeNum] then 
				btnTxt:setText(l_topbtn_name.l_topbtn_name_1[typeNum])
			else
				self.topBtn[i]:setVisible(false)
				self.topNum = g_CHANGE_PRESKILL
			end 
		else
			btnTxt:setText(l_topbtn_name[string.format("l_topbtn_name_%s",i)])
		end 
	end
	self:updateTopBtnState()
end

function wnd_skill_preset:updateTopBtnState()
	local widgets = self._layout.vars
	for k,v in ipairs(self.topBtn) do
		if k ~= self.topNum then 
			v:stateToNormal()
		else
			v:stateToPressed()
		end 
		local btnTxt = widgets[string.format("btn%s_txt",k)]
		btnTxt:setTextColor("FF693536")
	end
	if self.topNum == g_CHANGE_SKILL then 
		self:updateListSkill()
	elseif self.topNum == g_CHANGE_PRESKILL then
		self:updateListSkillPre()
	else
		self:updateListSpiritsPre()
	end 
	--self:updateList()
end

function wnd_skill_preset:updateListSkill()
	local scr_list = self._layout.vars.scr_list
	scr_list:removeAllChildren(true)

	local suitSkill = {}

	if self.typeNum == g_PRESETTYPE_SKILL then 
		local role_all_skill ,role_all_skill_use= g_i3k_game_context:GetRoleSkills() 
		local passiveSkill = g_i3k_game_context:GetRolePassiveSkills()

		for _,v in pairs(role_all_skill) do
			local suitFlag = true
			for _,j in ipairs(role_all_skill_use) do
				if v.id == j then 
					suitFlag = false
					break
				end 
			end
			if suitFlag and not passiveSkill[v.id] and not g_i3k_game_context:GetIsNotDrag(v.id) then 
				table.insert(suitSkill,v)
			end 
		end
	elseif self.typeNum == g_PRESETTYPE_UNIQUE then
		local uniqueSkillsCfg,useUniqueSkillCfg = g_i3k_game_context:GetRoleUniqueSkills()
		for _,v in pairs(uniqueSkillsCfg) do
			if v.id ~= useUniqueSkillCfg then 
				table.insert(suitSkill, v)
			end 
		end
	elseif self.typeNum == g_PRESETTYPE_DIY then
		local diySkillData,borrowSkillData = g_i3k_game_context:getDiySkillAndBorrowSkill()
		if diySkillData then
			for _,v in ipairs(diySkillData) do
				if (borrowSkillData or v.id ~= g_i3k_game_context:GetCurrentDIYSkillId()) and v.diySkillData and v.name then 
					table.insert(suitSkill, v)
				end 
			end
		end
	end 

	local allList = scr_list:addChildWithCount(sch_path1,l_num_perItem,#suitSkill)

	for k,v in ipairs(allList) do
		local cfg = suitSkill[k]
		local Vars = v.vars
		local state_color, skillName, iconPath, contPath
		if self.typeNum == g_PRESETTYPE_SKILL or self.typeNum == g_PRESETTYPE_UNIQUE then 
			local skill_data = i3k_db_skills[cfg.id]
			state_color = g_i3k_get_color_by_rank(cfg.state + 1)
			skillName = skill_data.name
			iconPath = i3k_db_icons[skill_data.icon].path
			contPath = i3k_db_icons[skill_grade[cfg.state + 1]].path
		elseif self.typeNum == g_PRESETTYPE_DIY then
			local d = cfg.diySkillData
			local grade = d.gradeId <= #skill_grade and d.gradeId or #skill_grade
			state_color = g_i3k_get_color_by_rank(grade)
			skillName = cfg.name
			iconPath = i3k_db_icons[cfg.iconId].path
			contPath = i3k_db_icons[skill_grade[grade]].path
		end 
		
		Vars.skill_name:setText(skillName)
		Vars.skill_name:setTextColor(state_color)
		Vars.skill_icon:setImage(iconPath)
		Vars.skill_iconCont:setImage(contPath)
		Vars.skill_btn:setTag(cfg.id + l_tag)
		Vars.skill_btn:onClick(self,self.onSkillClick)
	end
	self:formateDescTxt()
end

function wnd_skill_preset:updateListSkillPre()
	local scr_list = self._layout.vars.scr_list
	scr_list:removeAllChildren(true)
	local skillPresetData = g_i3k_game_context:getSkillPresetData()
	local allList = scr_list:addChildWithCount(sch_path2,2,#skillPresetData)
	for k,v in ipairs(allList) do
		local node = v.vars
		node.pre_name:setText(skillPresetData[k].skillPresetName)
		node.pre_btn:onClick(self, self.onSkillPreClick, k)
	end
	local skillPreTime = g_i3k_game_context:getSkillPresetTime()
	local timeNow = i3k_game_get_time()
	if timeNow - skillPreTime >= l_coolskill_second then 
		self:formateDescTxt()
	else
		self:formateDescTxt(l_coolskill_second - timeNow + skillPreTime)
	end 
end

function wnd_skill_preset:onSkillPreClick(sender,index)
	if self.coolTime and self.coolTime > 0 then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(719,self.coolTime)) --N秒后可更换预设
	else
		i3k_sbean.change_skill_preset(index,true)
	end 
end

function wnd_skill_preset:updateListSpiritsPre()
	local scr_list = self._layout.vars.scr_list
	scr_list:removeAllChildren(true)
	local spiritsPresetData = g_i3k_game_context:getSpiritsPresetData()
	local allList = scr_list:addChildWithCount(sch_path2,2,#spiritsPresetData)
	for k,v in ipairs(allList) do
		local node = v.vars
		node.pre_name:setText(spiritsPresetData[k].spiritsPresetName)
		node.pre_btn:onClick(self, self.onSpiritsPreClick, k)
	end
	local spiritsPreTime = g_i3k_game_context:getSpiritsPresetTime()
	local timeNow = i3k_game_get_time()
	if timeNow - spiritsPreTime >= l_coolspirits_second then 
		self:formateDescTxt()
	else
		self:formateDescTxt(l_coolspirits_second - timeNow + spiritsPreTime)
	end 
end

function wnd_skill_preset:onSpiritsPreClick(sender,index)
	if self.coolTime and self.coolTime > 0 then 
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(719,self.coolTime)) --N秒后可更换预设
	else
		i3k_sbean.change_spirits_preset(index,true)
	end 
end

function wnd_skill_preset:formateDescTxt(timeNum)
	local Vars = self._layout.vars
	self.coolTime = timeNum
	if not timeNum then 
		Vars.desc_txt:setText(i3k_get_string(720)) --点击更换技能
	else
		Vars.desc_txt:setText(i3k_get_string(719,timeNum)) --N秒后可更换预设
	end 
end

-- 帧事件 --------------------------------
function wnd_skill_preset:onUpdate(dTime)
	-- 计时
	timeCounter = timeCounter + dTime
	if timeCounter > 1 and self.coolTime then
		-- i3k_log("itsm")
		self.coolTime = self.coolTime - 1
		if self.coolTime <= 0 then 
			self.coolTime = nil
		end 
		self:formateDescTxt(self.coolTime)
		timeCounter = 0
	end
end

function wnd_skill_preset:onSkillClick(sender)
	local tag = sender:getTag() - l_tag
	if self.typeNum == g_PRESETTYPE_SKILL then 
		i3k_sbean.goto_skill_select(self.skillIndex, tag, g_CHANGE_SKILL_FAST)
	elseif self.typeNum == g_PRESETTYPE_UNIQUE then 
		i3k_sbean.goto_uniqueskill_select(tag, true)
	else
		i3k_sbean.diyskill_selectuse(tag,g_SKILLPRE_DIY_FRESHTYPE_CHANGE)
	end 
end

function wnd_skill_preset:onTopClick(sender)
	local tag = sender:getTag() - l_tag
	if tag == self.topNum then 
		return
	else
		self.topNum = tag
		self:updateTopBtnState()
	end 
end

function wnd_skill_preset:selectSkillCB()
	g_i3k_ui_mgr:CloseUI(eUIID_SkillPreset)
end

function wnd_create(layout,...)
	local wnd = wnd_skill_preset.new();
		wnd:create(layout,...)
	return wnd;
end
