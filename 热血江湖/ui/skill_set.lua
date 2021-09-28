-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_skill_set = i3k_class("wnd_skill_set", ui.wnd_base)

local sch_path1 = "ui/widgets/jnsdt"
local sch_path2 = "ui/widgets/jnqht2"

local l_tag = 1000

local skill_grade = {151,152,153,154,155}

local l_num_preSkill = 4

function wnd_skill_set:ctor()
	self.rightNum = 1
	self.preData = {}
	self.diySkillType = 0
	self.preSkills = {}
	self.preDiySkillID = 0
	self.preUniqueSkillID = 0
end

function wnd_skill_set:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)

	self.preList = widgets.preList
	self.preList:setBounceEnabled(false)
	widgets.save_btn:onClick(self,self.onSaveClick)
	widgets.replace_btn:onClick(self,self.onReplaceClick)
	widgets.delete_btn:onClick(self,self.onDeleteClick)
	widgets.use_btn:onClick(self,self.onUseClick)
end

function wnd_skill_set:refresh(rightNum)
	if rightNum then 
		self.rightNum = rightNum
	end 
	local widgets = self._layout.vars
	self.preData = g_i3k_game_context:getSkillPresetData()
	local preFlag = true

	widgets.numLable:setText(string.format("%s/%s",#self.preData,l_num_preSkill))

	self:updateListPre()
	self:updateRightListState()
end

function wnd_skill_set:updateListPre()

	self.preList:removeAllChildren(true)
	for i=1,#self.preData + 1 do
		local node = require(sch_path1)()

		local nameStr 
		if self.preData[i] then 
			nameStr = self.preData[i].skillPresetName
		else
			nameStr = i3k_get_string(713) --当前设置
		end 

		node.vars.pre_name:setText(nameStr)

		node.vars.pre_btn:setTag(i + l_tag)
		node.vars.pre_btn:onClick(self, self.onItemClick)
		self.preList:addItem(node)
	end
end

function wnd_skill_set:onItemClick(sender)
	local tag = sender:getTag() - l_tag
	if tag == self.rightNum then 
		return
	else
		self.rightNum = tag
		self:updateRightListState()
	end 
end

function wnd_skill_set:updateRightListState()
	for k,v in ipairs(self.preList:getAllChildren()) do
		if k ~= self.rightNum then 
			v.vars.pre_btn:stateToNormal()
		else
			v.vars.pre_btn:stateToPressed()
		end 
	end
	self:updateListSkill(self.rightNum)
end

function wnd_skill_set:updateListSkill(index, noUI)
	-- local scr_list = self._layout.vars.scr_list
	-- scr_list:removeAllChildren(true)
	self.diySkillType = 0
	self.preSkills = {}
	self.preDiySkillID = 0
	self.preUniqueSkillID = 0

	local widgets = self._layout.vars
	local defaultFlag = index > #self.preData
	
	if not noUI then 	
		if defaultFlag then 
			widgets.save_btn:setVisible(true)
			widgets.replace_btn:setVisible(false) 
			widgets.delete_btn:setVisible(false) 
			widgets.use_btn:setVisible(false) 
		else
			widgets.save_btn:setVisible(false)
			widgets.replace_btn:setVisible(true) 
			widgets.delete_btn:setVisible(true) 
			widgets.use_btn:setVisible(true) 
		end 
	end 

	local role_all_skill,role_all_skill_use = g_i3k_game_context:GetRoleSkills()
	local uniqueSkillsCfg,useUniqueSkillID = g_i3k_game_context:GetRoleUniqueSkills()
	local diySkillData,borrowSkillData = g_i3k_game_context:getDiySkillAndBorrowSkill()

	local preTab = self.preData[index]
	
	for i=1,6 do
		local skillID,cfg
		if i < 5 then 
			if defaultFlag then 
				skillID = role_all_skill_use[i]
			else
				skillID = preTab.skillPreset[i]
			end 
			cfg = role_all_skill[skillID]
		elseif i == 5 then 
			if defaultFlag then 
				skillID = useUniqueSkillID
			else
				skillID = preTab.uniqueSkill
			end 
			cfg = uniqueSkillsCfg[skillID]
		else
			if defaultFlag then 
				self.preDiySkillID = g_i3k_game_context:GetCurrentDIYSkillId() 
				if self.preDiySkillID == 0 then 
					self.preDiySkillID = 0
					self.diySkillType = 0
				else
					if borrowSkillData then
						self.preDiySkillID = 0 
						self.diySkillType = g_DIY_TYPE_BORROW
						cfg = borrowSkillData
					else
						self.diySkillType = g_DIY_TYPE_SELF
						cfg = diySkillData[self.preDiySkillID]
					end 
				end 
			else
				self.preDiySkillID = preTab.diySkill
				if self.preDiySkillID ~= 0 and diySkillData then 
					cfg = diySkillData[preTab.diySkill]
					self.diySkillType = g_DIY_TYPE_SELF
				else
					self.diySkillType = 0
				end 
			end 
		end 
	
		if cfg then
			widgets[string.format("skill%s_bot",i)]:setVisible(true) 

	 		if i < 6 then 
		 		if i == 5 then 
		 			self.preUniqueSkillID = cfg.id
		 		else
		 			table.insert(self.preSkills,cfg.id)
		 		end 
		 		local skill_data = i3k_db_skills[cfg.id]
		 		state_color = g_i3k_get_color_by_rank(cfg.state + 1)
		 		skillName = skill_data.name
		 		iconPath = i3k_db_icons[skill_data.icon].path
		 		contPath = i3k_db_icons[skill_grade[cfg.state + 1]].path
		 	else
				local grade = (cfg.diySkillData.gradeId <= #skill_grade) and cfg.diySkillData.gradeId or #skill_grade
				state_color = g_i3k_get_color_by_rank(grade)
				skillName = cfg.name
				iconPath = i3k_db_icons[cfg.iconId].path
				contPath = i3k_db_icons[skill_grade[grade]].path
		 	end 
		 	if not noUI then 
		 		widgets[string.format("skill%s_bot",i)]:setVisible(true)
		 		widgets[string.format("skill%s_name",i)]:setText(skillName)
	 			widgets[string.format("skill%s_name",i)]:setTextColor(state_color)
	 			widgets[string.format("skill%s_icon",i)]:setImage(iconPath)
	 			widgets[string.format("skill%s_cont",i)]:setImage(contPath)
		 	end 
		else
			if not noUI then 
				widgets[string.format("skill%s_bot",i)]:setVisible(false)
			end 
		end  
	end
end

function wnd_skill_set:onReplaceClick(sender)
	local callback = function(isOk)
		if isOk then
			self:updateListSkill(#self.preData + 1,true)
			self:sendSaveBean()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(979), callback)
end

function wnd_skill_set:onSaveClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_PreName)
	g_i3k_ui_mgr:RefreshUI(eUIID_PreName, g_PRE_NAME_SKILL)
end

function wnd_skill_set:onUseClick(sender)
	 i3k_sbean.change_skill_preset(self.rightNum)
end

function wnd_skill_set:onDeleteClick(sender)
	local data = i3k_sbean.delete_skill_preset_req.new()
	--self._pname_ = "delete_skill_preset_req"
	--self.index:		int32	
	data.index = self.rightNum 
	i3k_game_send_str_cmd(data,i3k_sbean.delete_skill_preset_res.getName())
end

function wnd_skill_set:sendSaveBean(name)
	-- body
	--self.index:		int32	
	--self.name:		string	
	--self.skills:		vector[int32]	
	--self.diyskill:		int32	
	--self.uniqueSkill:		int32	
	local data = i3k_sbean.save_skill_preset_req.new()
	data.index = self.rightNum
	data.name = name and name or self.preData[self.rightNum].skillPresetName
	data.skills = self.preSkills
	data.uniqueSkill = self.preUniqueSkillID
	data.diyskill = (self.diySkillType == g_DIY_TYPE_SELF) and self.preDiySkillID or 0
	data.diySkillType = self.diySkillType
	i3k_game_send_str_cmd(data,i3k_sbean.save_skill_preset_res.getName())
end

function wnd_create(layout,...)
	local wnd = wnd_skill_set.new();
		wnd:create(layout,...)
	return wnd;
end
