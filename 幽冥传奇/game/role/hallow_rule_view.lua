HallowRuleView = HallowRuleView or BaseClass(XuiBaseView)

function HallowRuleView:__init()
	self.texture_path_list[1] = 'res/xui/role.png'
	self.config_tab = {
		{"role_ui_cfg", 13, {0}},
	}
	self:SetIsAnyClickClose(true)
	self.suit_level_t = {}	
	self.index_t = {}
end

function HallowRuleView:__delete()
end

function HallowRuleView:ReleaseCallBack()

end

function HallowRuleView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		local ph = self.ph_list.ph_cell
		local path_1 = XUI.CreateImageView(ph.x+35, ph.y+35, ResPath.GetCommon("cell_100"), true)	
		local path_2 = XUI.CreateImageView(ph.x+35, ph.y+35, ResPath.GetItem(4018), true)	
		self.node_t_list.layout_cur_rule.layout_skill_hallow.node:addChild(path_1, 10)
		self.node_t_list.layout_cur_rule.layout_skill_hallow.node:addChild(path_2, 20)
	end
end

function HallowRuleView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HallowRuleView:ShowIndexCallBack(index)
	self:Flush(index)
end

function HallowRuleView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function HallowRuleView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:Update(v.level, v.cur_data, v.next_data, v.num, v.id)
			local level = nil
			if v.level == 0 then
				level = 1
			else
				level = v.level
			end
			local txt = string.format(Language.Role.Skill_level, level)
			self.node_t_list.layout_cur_rule.layout_skill_hallow.txt_skill_name.node:setString(txt)
		end
	end
end

function HallowRuleView:Update(level, index_t, index_next_t, count, id)
	if level == nil then return end
	if level <= 0  or level >= 2 then
		self.node_t_list.layout_next_rule.node:setVisible(false)
		self:ChangePos(level, id)
		local n = nil 
		if level == 0 then
			n = 1
		else
			n = level 
		end
		local txt = string.format(Language.Role.God_Count, n, count or 0)
		self.node_t_list.layout_cur_rule.layout_skill_hallow.txt_cur_rule_name.node:setString(txt)
		for i = 1, 2 do
			self.node_t_list.layout_cur_rule.layout_skill_hallow.layout_equip_name["txt_"..i].node:setColor(COLOR3B.GRAY)
			for k, v in pairs(index_t) do
				if v > 0 then
					self.node_t_list.layout_cur_rule.layout_skill_hallow.layout_equip_name["txt_"..k].node:setColor(COLOR3B.GREEN)
				end
			end
		end
	else
		self:ChangePosNormal(level, id)
		local txt = string.format(Language.Role.God_Count, level, 2)
		self.node_t_list.layout_cur_rule.layout_skill_hallow.txt_cur_rule_name.node:setString(txt)
		for i = 1, 2 do
			self.node_t_list.layout_cur_rule.layout_skill_hallow.layout_equip_name["txt_"..i].node:setColor(COLOR3B.GREEN)
		end
		local txt_2 = string.format(Language.Role.God_Count, (level+1), count)
		for i = 1, 2 do
			self.node_t_list.layout_next_rule.layout_next_hallow_skill.layout_next_name_equip["txt_"..i].node:setColor(COLOR3B.GRAY)
			for k, v in pairs(index_next_t) do
				if v > 0 then
					self.node_t_list.layout_next_rule.layout_next_hallow_skill.layout_next_name_equip["txt_"..k].node:setColor(COLOR3B.GREEN)
				end
			end
		end
		self.node_t_list.layout_next_rule.layout_next_hallow_skill.txt_next_rule_name.node:setString(txt_2)
		self.node_t_list.layout_next_rule.node:setVisible(true)
	end
end

function HallowRuleView:ChangePos(level, id)
	local config = nil
	if level == 0 then
		config = SkillData.GetSkillLvCfg(id, 1)
	else
		config = SkillData.GetSkillLvCfg(id, level)
	end
	if config ~= nil then
		desc = config.desc
	end
	RichTextUtil.ParseRichText(self.node_t_list.layout_cur_rule.rich_cur_attr.node, desc, 22, COLOR3B.OLIVE)
	self.node_t_list.layout_cur_rule.rich_cur_attr.node:refreshView()
	local size = self.node_t_list.layout_cur_rule.rich_cur_attr.node:getInnerContainerSize()
	local size_2 = self.node_t_list.layout_cur_rule.layout_skill_hallow.node:getContentSize()
	local w = size.height + size_2.height + 30
	local pos_y = size_2.height/2 - 10
	local pos_y2 = -15
	local pos_y3 = size.height + size_2.height + 135
	self.node_t_list.img9_hallow_skill_bg.node:setContentWH(358, w)
	self.node_t_list.layout_cur_rule.rich_cur_attr.node:setPositionY(pos_y2)
	self.node_t_list.layout_cur_rule.layout_skill_hallow.node:setPositionY(pos_y)
	self.node_t_list.btn_close_window.node:setPositionY(pos_y3)
end

function HallowRuleView:ChangePosNormal(level, id)
	local config = SkillData.GetSkillLvCfg(id, level)
	local desc = config.desc
	RichTextUtil.ParseRichText(self.node_t_list.layout_cur_rule.rich_cur_attr.node, desc, 22, COLOR3B.OLIVE)
	local config = SkillData.GetSkillLvCfg(id, level+1)
	local next_desc = config.desc
	RichTextUtil.ParseRichText(self.node_t_list.layout_next_rule.rich_next_cur_attr.node, next_desc, 22, COLOR3B.OLIVE)
	self.node_t_list.layout_cur_rule.rich_cur_attr.node:refreshView()
	local size = self.node_t_list.layout_cur_rule.rich_cur_attr.node:getInnerContainerSize()
	local size_2 = self.node_t_list.layout_cur_rule.layout_skill_hallow.node:getContentSize()
	self.node_t_list.layout_next_rule.rich_next_cur_attr.node:refreshView()
	local size_3 = self.node_t_list.layout_next_rule.rich_next_cur_attr.node:getInnerContainerSize()
	local size_4 = self.node_t_list.layout_next_rule.layout_next_hallow_skill.node:getContentSize()

	local w = size.height + size_2.height + 15 + size_3.height + size_4.height +25
	self.node_t_list.img9_hallow_skill_bg.node:setContentWH(358, w)
	local pos_y = size_3.height + size_4.height/2 - 10
	local pos_y1 = size_3.height + size_4.height -5
	local pos_y2 = size.height  
	local pos_y3 = size_2.height
	self.node_t_list.layout_next_rule.rich_next_cur_attr.node:setPositionY(pos_y)
	self.node_t_list.layout_next_rule.layout_next_hallow_skill.node:setPositionY(pos_y1)
	self.node_t_list.layout_cur_rule.rich_cur_attr.node:setPositionY(pos_y2)
	self.node_t_list.layout_cur_rule.layout_skill_hallow.node:setPositionY(pos_y3)
	self.node_t_list.btn_close_window.node:setPositionY((w+15))
end