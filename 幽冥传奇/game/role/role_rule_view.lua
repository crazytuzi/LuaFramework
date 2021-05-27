RoleRuleView = RoleRuleView or BaseClass(XuiBaseView)

function RoleRuleView:__init()
	self.texture_path_list[1] = 'res/xui/role.png'
	self.config_tab = {
		{"role_ui_cfg", 12, {0}, false},
	}
	self:SetIsAnyClickClose(true)
end

function RoleRuleView:__delete()	
end

function RoleRuleView:ReleaseCallBack()

end

function RoleRuleView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.pos_x, self.pos_y = self.node_t_list.layout_next_tip.node:getPosition()
		self.pos_x1, self.pos_y2 = self.node_t_list.layout_current_tip.node:getPosition()
		self.pos_x3, self.pos_y3 = self.node_t_list.btn_close_window.node:getPosition()
		self.size = self.node_t_list.layout_current_tip.node:getContentSize()
		self.size_1 = self.node_t_list.layout_current_tip.layout_txt_jiacheng.node:getContentSize()
		self.size_2 = self.node_t_list.layout_current_tip.layout_jc_type.node:getContentSize()
		self.size_3 = self.node_t_list.layout_current_tip.layout_cur_name_txt.node:getContentSize()
		self.size_4 = self.node_t_list.layout_current_tip.layout_cur_rich_txt.node:getContentSize()
		for i = 1, 10 do
			self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..i].node:setString(Language.Role.EquipName[i])
			self.node_t_list.layout_next_tip.layout_next_txt["txt_"..(i+10)].node:setString(Language.Role.EquipName[i])
		end
		for i = 1, 5 do
			self.node_t_list.layout_current_tip.layout_cur_name_txt["txt_"..i].node:setString(Language.Role.GodEquipName[i+20])
			self.node_t_list.layout_next_tip.layout_next_name_txt["txt_"..i].node:setString(Language.Role.GodEquipName[i+20])
		end
	end
end

function RoleRuleView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RoleRuleView:ShowIndexCallBack(index)
	self:Flush(index)
end

function RoleRuleView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function RoleRuleView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.tiptype == 1 then
				self:UpdateQiangHuaAdditionTip(v.level, v.qianghua_level)
			elseif v.tiptype == 2 then
				self:UpdateGemAdditionTip(v.level, v.next_level, v.min_num, v.max_num, v.next_num, v.gem_tab)
			elseif v.tiptype == 3 then
				self:UpdateSuitAddtionTip(v.level, v.min_count, v.max_count, v.next_count, v.tab, v.tab_1)
			elseif v.tiptype == 4 then
				self:UpdateBloodMixingAdditionTip(v.level, v.blood_mixing_level)
			elseif v.tiptype == 5 then
				self:UpdatePeerlessSuitAddtionTip(v.level, v.min_count, v.max_count, v.next_count, v.tab, v.tab_1)
			elseif v.tiptype == 6 then
				self:UpdateMoldingSoulAdditionTip(v.level, v.molding_soul_level)
			elseif v.tiptype == 7 then
				self:UpdateApotheosisAdditionTip(v.level, v.god_level)
			elseif v.tiptype == 0 then
				self:UpdateStringDataAddtionTip(v.addtion_string_data)
			end
			if v.tiptype ~= nil and v.tiptype ~= 0 then
				self.node_t_list.layout_current_tip.layout_jc_type.txt_tip_type.node:setString(Language.Role.TipName[v.tiptype])
			end
		end
	end
end

function RoleRuleView:ChangeScalePosition()
	self.node_t_list.layout_next_tip.node:setVisible(false)
	self.node_t_list.layout_next_tip.layout_next_richtxt.node:setVisible(false)
	self.node_t_list.layout_next_tip.layout_next_txt.node:setVisible(false)
end

function RoleRuleView:ChangeNormalPosition()
	self.node_t_list.layout_next_tip.node:setVisible(true)
	self.node_t_list.layout_next_tip.layout_next_richtxt.node:setVisible(true)
	self.node_t_list.layout_next_tip.layout_next_txt.node:setVisible(true)
end

function RoleRuleView:GetCurrentDesc(tip_config, index) 
	local current_Attrs = tip_config.attrs
	local current_property = RoleData.Instance.FormatAttrContent(current_Attrs)
	RichTextUtil.ParseRichText(self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node, current_property, 22, COLOR3B.OLIVE)
	self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:refreshView()
	local size = self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:getInnerContainerSize()
	self.node_t_list.layout_current_tip.layout_txt_jiacheng.node:setVisible(index == 2 or index == 5)
	self.node_t_list.layout_current_tip.layout_cur_name_txt.node:setVisible(index == 3)
	local all_h = nil 
	local pos_y1 = nil 
	if index == 1 or index == 4 or index == 6 or index == 7 then
		all_h = self.size_2.height + size.height + 27
		pos_y1 = self.size.height - self.size_2.height - self.size_4.height / 2
	elseif index == 2 then
		all_h = self.size_1.height + size.height + self.size_2.height + 37
		pos_y1 =  self.size.height - self.size_1.height - self.size_2.height - self.size_4.height / 2 - 10
	elseif index == 3 then 
		all_h = self.size_3.height + size.height + self.size_2.height + 37
		pos_y1 = self.size.height - self.size_3.height - self.size_2.height - self.size_4.height / 2 - 10
	elseif index == 5 then 
		all_h = self.size_1.height + size.height + self.size_2.height + 37
		pos_y1 =  self.size.height - self.size_1.height - self.size_2.height - self.size_4.height / 2 - 10
	end
	self.root_node:setContentWH(376, all_h)
	self.node_t_list.img9_bg.node:setContentWH(376, all_h)
	self.node_t_list.img9_bg.node:setPositionY(all_h / 2)
	self.node_t_list.layout_current_tip.layout_cur_rich_txt.node:setPositionY(pos_y1)
	self.node_t_list.layout_current_tip.node:setPosition(self.pos_x, all_h - self.size.height / 2 - 10)
	self.node_t_list.btn_close_window.node:setPositionY(all_h - 25)
	self.node_t_list.layout_rule_bg.node:setVisible(true)

end

function RoleRuleView:GetNormalDesc(tip_config, tip_next_config, index)
	self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:refreshView()
	local current_Attrs = tip_config.attrs
	local current_property = RoleData.Instance.FormatAttrContent(current_Attrs)
	RichTextUtil.ParseRichText(self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node, current_property, 22, COLOR3B.OLIVE)
	if tip_next_config == nil then return end
	local next_Attrs = tip_next_config.attrs
	local next_property = RoleData.Instance.FormatAttrContent(next_Attrs)
	RichTextUtil.ParseRichText(self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node, next_property, 22, COLOR3B.OLIVE)
	self.node_t_list.layout_current_tip.layout_txt_jiacheng.node:setVisible(index == 2 or index == 5)
	self.node_t_list.layout_current_tip.layout_cur_name_txt.node:setVisible(index == 3)
	self.node_t_list.layout_next_tip.layout_next_txt.node:setVisible(index == 2 or index == 5)
	self.node_t_list.layout_next_tip.layout_next_name_txt.node:setVisible(index == 3)
	self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:refreshView()
	self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node:refreshView()
	local size = self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:getInnerContainerSize()
	local size_2 = self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node:getInnerContainerSize()
	local all_h = nil 
	local all_h_1 = nil 
	local pos_y1 = nil 

	if index == 1 or index == 4 or index == 6 or index == 7 then
		all_h_1 = self.size_2.height + size.height + 27
		all_h = self.size_2.height*2 + size.height + size_2.height + 47
		pos_y1 = self.size.height - self.size_2.height - self.size_4.height / 2
	elseif index == 2 then
		all_h_1 = self.size_1.height + size.height + self.size_2.height + 37
		all_h = self.size_2.height*2 + size.height + size_2.height + self.size_1.height*2 + 67 	
		pos_y1 =  self.size.height - self.size_1.height - self.size_2.height - self.size_4.height / 2 - 10
	elseif index == 3 then 
		all_h_1 = self.size_3.height + size.height + self.size_2.height + 37
		all_h = self.size_2.height*2 + size.height + size_2.height + self.size_3.height*2 + 67
		pos_y1 = self.size.height - self.size_3.height - self.size_2.height - self.size_4.height / 2 - 10
	elseif index == 5 then 
		all_h_1 = self.size_1.height + size.height + self.size_2.height + 37
		all_h = self.size_2.height*2 + size.height + size_2.height + self.size_1.height*2 + 67 	
		pos_y1 =  self.size.height - self.size_1.height - self.size_2.height - self.size_4.height / 2 - 10
	elseif index == 0 then 
		all_h_1 = self.size_1.height + size.height + self.size_2.height + 37
		all_h = self.size_2.height*2 + size.height + size_2.height + self.size_1.height*2 + 67 	
		pos_y1 =  self.size.height - self.size_1.height - self.size_2.height - self.size_4.height / 2 - 10
	end
	self.root_node:setContentWH(376, all_h)
	self.node_t_list.img9_bg.node:setContentWH(376, all_h)
	self.node_t_list.img9_bg.node:setPositionY(all_h / 2)
	self.node_t_list.btn_close_window.node:setPositionY(all_h - 25)
	self.node_t_list.layout_current_tip.layout_cur_rich_txt.node:setPositionY(pos_y1)
	self.node_t_list.layout_current_tip.node:setPosition(self.pos_x, all_h - self.size.height / 2 - 10)
	self.node_t_list.layout_next_tip.layout_next_richtxt.node:setPositionY(pos_y1)
	self.node_t_list.layout_next_tip.node:setPosition(self.pos_x, all_h - all_h_1 - self.size.height / 2)
	self.node_t_list.layout_rule_bg.node:setVisible(true)
end

function RoleRuleView:GetConfig(index, level)
	tip_last_config = RoleRuleData.GetConfigData(index, level - 1)
	tip_config = RoleRuleData.GetConfigData(index, level)
	tip_next_config = RoleRuleData.GetConfigData(index, level + 1)

	return tip_last_config, tip_config, tip_next_config
end

function RoleRuleView:UpdateQiangHuaAdditionTip(level, qianghua_level)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(1, level)
	if tip_last_config == nil or tip_next_config == nil then
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..qianghua_level.."/"..tip_config.level..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config,1)
	else
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..tip_config.level.."/"..tip_config.level..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."("..qianghua_level.."/"..tip_next_config.level..")")
		self:ChangeNormalPosition()
		self:GetNormalDesc(tip_config, tip_next_config,1)
	end
end

function RoleRuleView:UpdateBloodMixingAdditionTip(level, blood_mixing_level)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(4, level)
	if tip_last_config == nil or tip_next_config == nil then
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..blood_mixing_level.."/"..tip_config.level..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config, 4)
	else
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..tip_config.level.."/"..tip_config.level..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."("..blood_mixing_level.."/"..tip_next_config.level..")")
		self:ChangeNormalPosition()
		self:GetNormalDesc(tip_config, tip_next_config, 4)
	end
end

function RoleRuleView:UpdateMoldingSoulAdditionTip(level, molding_soul_level)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(6, level)
	if tip_last_config == nil or tip_next_config == nil then
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..molding_soul_level.."/"..tip_config.count..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config, 6)
	else
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..tip_config.count.."/"..tip_config.count..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."("..molding_soul_level.."/"..tip_next_config.count..")")
		self:ChangeNormalPosition()
		self:GetNormalDesc(tip_config, tip_next_config, 6)
	end
end

function RoleRuleView:UpdateApotheosisAdditionTip(level, god_level)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(7, level)
	if tip_last_config == nil or tip_next_config == nil then
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..god_level.."/"..tip_config.count..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config, 7)
	else
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..tip_config.count.."/"..tip_config.count..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."("..god_level.."/"..tip_next_config.count..")")
		self:ChangeNormalPosition()
		self:GetNormalDesc(tip_config, tip_next_config, 7)
	end
end

function RoleRuleView:UpdateGemAdditionTip(level, next_level, min_num, max_num, next_num, gem_tab)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(2, level)
	if tip_last_config == nil or tip_next_config == nil then
		local num = 0
		if level == 0 then
			 num = min_num
		elseif tip_next_config == nil then
			 num = max_num
		end
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..num.."/"..tip_config.count..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config, 2)
		if gem_tab == nil then return end
		for i = 1, 10 do
			self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..i].node:setColor(COLOR3B.GRAY)
			for k, v in pairs(gem_tab) do
				if v > 0 then
					self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..k].node:setColor(COLOR3B.GREEN)
				end
			end
		end
	else
		local num = next_num
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."(".. 10 .."/"..tip_config.count..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."(".. num .."/"..tip_next_config.count..")")
		self:ChangeNormalPosition(2)
		self:GetNormalDesc(tip_config, tip_next_config,2)
		if gem_tab == nil then return end
		for i = 1, 10 do
			self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..i].node:setColor(COLOR3B.GREEN)
			self.node_t_list.layout_next_tip.layout_next_txt["txt_"..(i+10)].node:setColor(COLOR3B.GRAY)
			for k, v in pairs(gem_tab) do
				if v > 0 then
					self.node_t_list.layout_next_tip.layout_next_txt["txt_"..(k+10)].node:setColor(COLOR3B.GREEN)
				end
			end		
		end
	end
end

function RoleRuleView:UpdateSuitAddtionTip(level, min_count, max_count, next_count, index_t, index_next_t)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(3, level)
	if tip_last_config == nil or tip_next_config == nil then
		local count = 0
		if level == 0 then
			count = min_count
		elseif level >= #LunHuiSuitAttrCfg then
			count = max_count
		end
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..count.."/"..(#tip_config.items)..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config,3)
		local color = COLOR3B.GRAY
		if index_t ~= nil then
			for i = 1, 5 do
				self.node_t_list.layout_current_tip.layout_cur_name_txt["txt_"..i].node:setColor(index_t[i] > 0 and COLOR3B.GREEN or COLOR3B.GRAY)
				-- for k, v in pairs(index_t) do
				-- 	if v > 0 then
				-- 		color = COLOR3B.GREEN
				-- 	end
				-- 	self.node_t_list.layout_current_tip.layout_cur_name_txt["txt_"..k].node:setColor(color)	
				-- end
			end
		end
	else
		local count = next_count
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."(".."5".."/"..(#tip_next_config.items)..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."("..count.."/"..(#tip_next_config.items)..")")
		self:ChangeNormalPosition()
		self:GetNormalDesc(tip_config, tip_next_config, 3)
		for i = 1, 5 do
			self.node_t_list.layout_current_tip.layout_cur_name_txt["txt_"..i].node:setColor(COLOR3B.GREEN)
		end
		if index_next_t == nil then return end
		for i = 1, 5 do
			self.node_t_list.layout_next_tip.layout_next_name_txt["txt_"..i].node:setColor(COLOR3B.GRAY)
			for k, v in pairs(index_next_t) do
				if k == i then
					if v > 0 then
						self.node_t_list.layout_next_tip.layout_next_name_txt["txt_"..k].node:setColor(COLOR3B.GREEN)	
					end	
				end	
			end
		end
	end
end

function RoleRuleView:UpdatePeerlessSuitAddtionTip(level, min_count, max_count, next_count, index_t, index_next_t)
	local tip_last_config, tip_config, tip_next_config = self:GetConfig(5, level)
	if tip_last_config == nil or tip_next_config == nil then
		local count = 0
		if level == 0 then
			count = min_count
		elseif level >= #RoleRuleData.Instance:GetPeerlessSuitPlusConfig() then
			count = max_count
		end
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."("..count.."/"..(#tip_config.items)..")")
		self:ChangeScalePosition()
		self:GetCurrentDesc(tip_config, 5)
		local color = COLOR3B.GRAY
		if index_t ~= nil then
			for i = 1, 10 do
				self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..i].node:setColor(COLOR3B.GRAY)
				for k, v in pairs(index_t) do
					if v > 0 then
						color = COLOR3B.GREEN
					end
					self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..k].node:setColor(color)		
				end
			end
		end
	else
		local count = next_count
		self.node_t_list.layout_current_tip.layout_jc_type.txt_title_name.node:setString(tip_config.name.."  ".."(".."10".."/"..(#tip_next_config.items)..")")
		self.node_t_list.layout_next_tip.layout_jc_next_type.txt_next_title_name.node:setString(tip_next_config.name.."  ".."("..count.."/"..(#tip_next_config.items)..")")
		self:ChangeNormalPosition()
		self:GetNormalDesc(tip_config, tip_next_config, 5)
		for i = 1, 10 do
			self.node_t_list.layout_current_tip.layout_txt_jiacheng["txt_"..i].node:setColor(COLOR3B.GREEN)
		end
		if index_next_t == nil then return end
		for i = 1, 10 do
			self.node_t_list.layout_next_tip.layout_next_txt["txt_"..(i+10)].node:setColor(COLOR3B.GRAY)
			for k, v in pairs(index_next_t) do
				if k == i then
					if v > 0 then
						self.node_t_list.layout_next_tip.layout_next_txt["txt_"..(k+10)].node:setColor(COLOR3B.GREEN)	
					end	
				end	
			end
		end
	end
end

--传入已排列好的字符串（富文本）列表，生成提示，适配大小
function RoleRuleView:UpdateStringDataAddtionTip(addtion_string_data)
	local title_text = addtion_string_data[1]		--标题部分，不支持多行
	local tip_text = addtion_string_data[2]			--当前加成
	local tip_next_text = addtion_string_data[3]	--下级加成，为空则不显示

	self.node_t_list.layout_current_tip.layout_txt_jiacheng.node:setVisible(false)
	self.node_t_list.layout_current_tip.layout_cur_name_txt.node:setVisible(false)

	--设置位置及背景框大小
	if tip_next_text == nil then
		self:ChangeScalePosition()
		RichTextUtil.ParseRichText(self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node, tip_text, 22, COLOR3B.OLIVE)
		self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:refreshView()
		local size = self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:getInnerContainerSize()
		local size_2 = self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node:getInnerContainerSize()
		local all_h = nil 
		local all_h_1 = nil 
		local pos_y1 = nil 

		all_h = size.height + 80
		pos_y1 = self.size.height - self.size_2.height - self.size_4.height / 2

		self.root_node:setContentWH(376, all_h)
		self.node_t_list.img9_bg.node:setContentWH(376, all_h)
		self.node_t_list.img9_bg.node:setPositionY(all_h / 2)
		self.node_t_list.btn_close_window.node:setPositionY(all_h - 25)
		self.node_t_list.layout_current_tip.layout_cur_rich_txt.node:setPositionY(pos_y1)
		self.node_t_list.layout_current_tip.node:setPosition(self.pos_x, all_h - self.size.height / 2 - 10)
		self.node_t_list.layout_rule_bg.node:setVisible(true)
	else
		self:ChangeNormalPosition()
		self.node_t_list.layout_next_tip.layout_next_txt.node:setVisible(false)
		self.node_t_list.layout_next_tip.layout_next_name_txt.node:setVisible(false)
		self.node_t_list.layout_next_tip.layout_jc_next_type.node:setVisible(false)

		RichTextUtil.ParseRichText(self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node, tip_text, 22, COLOR3B.OLIVE)
		self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:refreshView()

		RichTextUtil.ParseRichText(self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node, tip_next_text, 22, COLOR3B.OLIVE)
		self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node:refreshView()

		local size = self.node_t_list.layout_current_tip.layout_cur_rich_txt.rich_cur_attr.node:getInnerContainerSize()
		local size_2 = self.node_t_list.layout_next_tip.layout_next_richtxt.rich_next_cur_attr.node:getInnerContainerSize()
		local all_h = nil 
		local all_h_1 = nil 
		local pos_y1 = nil 

		all_h_1 = size.height + self.size_2.height + 37
		all_h =  self.size_2.height*2 + size.height + size_2.height 	
		pos_y1 =  self.size.height - self.size_2.height - self.size_4.height / 2 - 10

		self.root_node:setContentWH(376, all_h)
		self.node_t_list.img9_bg.node:setContentWH(376, all_h)
		self.node_t_list.img9_bg.node:setPositionY(all_h / 2)
		self.node_t_list.btn_close_window.node:setPositionY(all_h - 25)
		self.node_t_list.layout_current_tip.layout_cur_rich_txt.node:setPositionY(pos_y1 + 30)
		self.node_t_list.layout_current_tip.node:setPosition(self.pos_x, all_h - self.size.height / 2 - 10)
		self.node_t_list.layout_next_tip.layout_next_richtxt.node:setPositionY(pos_y1 + 80)
		self.node_t_list.layout_next_tip.node:setPosition(self.pos_x, all_h - all_h_1 - self.size.height / 2)

		self.node_t_list.layout_rule_bg.node:setVisible(true)
	end

	self.node_t_list.layout_current_tip.layout_jc_type.txt_tip_type.node:setString(title_text)
	self.node_t_list.layout_current_tip.layout_jc_type.node:setColor(COLOR3B.RED)
end