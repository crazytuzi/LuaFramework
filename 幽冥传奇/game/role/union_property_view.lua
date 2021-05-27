UnionPropertyView = UnionPropertyView or BaseClass(XuiBaseView)

function UnionPropertyView:__init()
	-- self.texture_path_list[1] = 'res/xui/role.png'
	self.config_tab = {
		{"itemtip_ui_cfg", 19, {0}},
	}
	self:SetIsAnyClickClose(true)
	self.item_list = {}
	self.item_list_1 = {}
end

function UnionPropertyView:__delete()	
end

function UnionPropertyView:ReleaseCallBack()
	if self.item_list ~= nil then
		for k,v in pairs(self.item_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.item_list = {}
	end
	if self.item_list_1 ~= nil then
		for k,v in pairs(self.item_list_1) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.item_list_1 = {}
	end
end

function UnionPropertyView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		
	end
end

function UnionPropertyView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function UnionPropertyView:ShowIndexCallBack(index)
	self:Flush(index)
end

function UnionPropertyView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function UnionPropertyView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "shouhun" then
			local cur_index = BossData.Instance:GetBoolActivityShouHunInfuse()
			local data = UnionPropertyData.Instance:GetRuleUnionConfigByType(UnionPropertyType.SHOUHUN)
			self:FlushContent(cur_index, data, UnionPropertyType.SHOUHUN)
		elseif k == "fumo" then
			local cur_index = EquipmentData.Instance:GetBoolGongMingActive()
			local data = UnionPropertyData.Instance:GetRuleUnionConfigByType(UnionPropertyType.FUMO)
			self:FlushContent(cur_index, data, UnionPropertyType.FUMO)
		elseif k == "wing" then
			local cur_index = RoleData.Instance:GetCanActiveUnionProperty()
			-- print("4444",cur_index)
			local data = UnionPropertyData.Instance:GetRuleUnionConfigByType(UnionPropertyType.JIMAI)
			self:FlushContent(cur_index, data, UnionPropertyType.JIMAI)
		elseif k == "Compose" then
			local cur_index = ComposeData.Instance:GetCanActiveUnionProperty()
			local data = UnionPropertyData.Instance:GetRuleUnionConfigByType(UnionPropertyType.COMPOSE)
			self:FlushContent(cur_index, data, UnionPropertyType.COMPOSE)
		end 
	end
end

function UnionPropertyView:FlushContent(cur_index, data, cur_type)
	local cur_txt = ""
	if cur_index == 0 then
		cur_index = #data
		cur_txt = Language.Role.Not_Active
	else
		cur_txt = Language.Role.Had_Active
	end	
	local cur_data = data[cur_index]
	RichTextUtil.ParseRichText(self.node_t_list.txt_bool_activity_1.node, cur_txt)
	XUI.RichTextSetCenter(self.node_t_list.txt_bool_activity_1.node)
	local propety_data = UnionPropertyData.Instance:GetProperty(cur_data.param1, cur_data.param2)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local attr = RoleData.Instance:GetGodZhuEquipAttr(propety_data, prof)
	local attr_content = RoleData.FormatAttrContent(attr)
	RichTextUtil.ParseRichText(self.node_t_list.rich_property.node, attr_content)
	-- XUI.RichTextSetCenter(self.node_t_list.rich_property.node)
	local cur_rule_data = {}
	if UnionPropertyType.COMPOSE ~= 2 then
		cur_rule_data = {{rule = cur_data.rule1, cond = cur_data.cond1}, {rule = cur_data.rule2, cond = cur_data.cond2}}
	else
		cur_rule_data = {
			{rule = cur_data.rule1, cond = cur_data.cond1},
			{rule = cur_data.rule2, cond = cur_data.cond2},
			{rule = cur_data.rule3, cond = cur_data.cond3},
			{rule = cur_data.rule4, cond = cur_data.cond4},
			{rule = cur_data.rule5, cond = cur_data.cond5},
		}
	end
	-- if #self.item_list == 0 then
	self:ParseCurRender(cur_rule_data)
	local next_rule_data = {}
	local next_index = cur_index - 1
	if next_index ~= 0 then
		self.node_t_list.layout_next_level.node:setVisible(true)
		RichTextUtil.ParseRichText(self.node_t_list.txt_bool_activity_2.node, Language.Role.Next_level, 20, COLOR3B.RED)
		XUI.RichTextSetCenter(self.node_t_list.txt_bool_activity_2.node)
		local next_data = data[next_index]
		local propety_data = UnionPropertyData.Instance:GetProperty(next_data.param1, next_data.param2)
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local attr = RoleData.Instance:GetGodZhuEquipAttr(propety_data, prof)
		local attr_content = RoleData.FormatAttrContent(attr)
		RichTextUtil.ParseRichText(self.node_t_list.rich_next_property.node, attr_content)
		--XUI.RichTextSetCenter(self.node_t_list.rich_next_property.node)
		
		if UnionPropertyType.COMPOSE ~= 2 then
			next_rule_data = {{rule = next_data.rule1, cond = next_data.cond1}, {rule = next_data.rule2, cond = next_data.cond2}}
		else
			next_rule_data = {
				{rule = next_data.rule1, cond = next_data.cond1},
				{rule = next_data.rule2, cond = next_data.cond2},
				{rule = next_data.rule3, cond = next_data.cond3},
				{rule = next_data.rule4, cond = next_data.cond4},
				{rule = next_data.rule5, cond = next_data.cond5},
			}
		end
		self:ParseNextRender(next_rule_data)
	else
		self.node_t_list.layout_next_level.node:setVisible(false)
	end
	self:ParsePosition(cur_rule_data, next_rule_data, next_index)
end

function UnionPropertyView:ParsePosition(cur_data, next_data,next_index)
	local w, h = 470, 0
	local pos_y = 0
	local pos_y1 = 0
	local w_h = 0
	if next_index == 0 then
		local size = self.node_t_list.layout_cur_level.node:getContentSize()
		local item_h_1 = #cur_data * 20 - 20
		h = size.height + 20 + item_h_1
		w_h = HandleRenderUnit:GetHeight()/2  - 30
		pos_y1 = HandleRenderUnit:GetHeight()/2 - item_h_1 + 15
	else
		local size_1 = self.node_t_list.layout_cur_level.node:getContentSize()
		local size_2 = self.node_t_list.layout_next_level.node:getContentSize()
		local item_h_1 = #cur_data * 20 
		local item_h_2 =  #next_data *20  
		h = size_1.height + size_2.height + item_h_1 + item_h_2
		pos_y = 200
		pos_y1 = pos_y + size_1.height + 10 + size_2.height/2
		w_h = h
	end
	self.node_t_list.layout_cur_level.node:setPositionY(pos_y1)
	self.node_t_list.layout_next_level.node:setPositionY(pos_y)
	-- self.node_t_list.img_bg_1.node:setContentWH(w, h)
	-- self.node_t_list.img9_itemtips_bg.node:setContentWH(w,h-10)
	-- self.node_t_list.btn_close_window.node:setPositionY(w_h)
end

function UnionPropertyView:ParseCurRender(cur_data)
	if #self.item_list ~= 0 then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
			v:GetView():removeFromParent()
		end
		self.item_list = {}
	end
	
	if #self.item_list == 0 then
		for i = 1, #cur_data do
			local cell = self:CreateRender(self.node_t_list.layout_render.node, i)
			cell:SetIndex(i)
			self.item_list[i] = cell
		end
	end
	for i, v in ipairs(cur_data) do
		if self.item_list[i] ~= nil then
			self.item_list[i]:SetData(v)
		end
	end
end

function UnionPropertyView:ParseNextRender(next_data)
	if #self.item_list_1 ~= 0 then
		for k,v in pairs(self.item_list_1) do
			v:DeleteMe()
			v:GetView():removeFromParent()
		end
		self.item_list_1 = {}
	end
	
	if #self.item_list_1 == 0 then 
		for i = 1, #next_data do
			local cell = self:CreateRender(self.node_t_list.layout_next_render.node, i)
			cell:SetIndex(i)
			self.item_list_1[i] = cell
		end
	end
	for i, v in ipairs(next_data) do
		if self.item_list_1[i] ~= nil then
			self.item_list_1[i]:SetData(v)
		end
	end
end

function UnionPropertyView:CreateRender(node, index)
	local cell = UnionPropertyItem.New()
	local render_ph = nil 
	render_ph = self.ph_list.ph_item
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPositionY(-(index-1) *30 + 50)
	node:addChild(cell:GetView(), 200)
	return cell
end

UnionPropertyItem = UnionPropertyItem or BaseClass(BaseRender)
function UnionPropertyItem:__init()
	
end

function UnionPropertyItem:__delete()
	self.text_node = nil 
end

function UnionPropertyItem:CreateChild()
	BaseRender.CreateChild(self)
	
end

function UnionPropertyItem:OnFlush()
	if self.data == nil then return end
	if self.text_node == nil then
		local ph = self.ph_list.ph_next_1
		self.text_node = RichTextUtil.CreateLinkText("", 20, COLOR3B.GREEN, nil, true)
		self.view:addChild(self.text_node, 999)
		self.text_node:setPosition(ph.x+25, ph.y+10)
		self.text_node:setString(Language.Common.GoImmediately)
		XUI.AddClickEventListener(self.text_node, BindTool.Bind1(self.OpenCanShowView, self), true)
	end
	
	if self.data.rule == nil or self.data.cond == nil then  return self.text_node:setVisible(false) end
	local cur_param1, cur_param2, cur_data_type, num = UnionPropertyData.Instance:GetHadAndCosumeByRuleAndCondtion(self.data.rule, self.data.cond)
	local txt = "" 
	local color = "00ff00"
	if self.data.rule == RuleCondition.Level then
		local lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		if cur_param1 == 0 then
			if lv >= cur_param2 then
				txt = cur_param2 .. "/" .. cur_param2
			else
				color = "ff0000"
				txt = lv .. "/" .. cur_param2
			end
		else
			if circle >= cur_param1 then
				txt = cur_param1 .. "/" .. cur_param1
			else
				color = "ff0000"
				txt = circle .. "/" .. cur_param1
			end
		end
	else
		if num >= cur_param1 then
			txt = cur_param1 .. "/" .. cur_param1
		else
			color = "ff0000"
			txt = num .. "/" .. cur_param1
		end 

	end
	self.text_node:setVisible(true)
	if num >= cur_param1 then
		self.text_node:setVisible(false)
	end
	if cur_param2 ~= nil then
		if self.data.rule == RuleCondition.Level then
			RichTextUtil.ParseRichText(self.node_tree.txt_name.node, string.format(Language.Role.Rule_Name[self.data.rule], cur_param1, color, txt))
		else
			RichTextUtil.ParseRichText(self.node_tree.txt_name.node, string.format(Language.Role.Rule_Name[self.data.rule], cur_param1, cur_param2, color, txt))
		end
	else
		if self.data.rule == RuleCondition.JinMai then
			local step, star = RoleData.GetMeridianStepStar(cur_param1)
			RichTextUtil.ParseRichText(self.node_tree.txt_name.node, string.format(Language.Role.Rule_Name[self.data.rule], step, star, color, txt))
		elseif self.data.rule == RuleCondition.Compose_Equip then
			local step, star = ComposeData.Instance:GetStepStar(cur_param1)
			RichTextUtil.ParseRichText(self.node_tree.txt_name.node, string.format(Language.Role.Rule_Name[self.data.rule][cur_data_type], step, star, color, txt))
		else 
			RichTextUtil.ParseRichText(self.node_tree.txt_name.node, string.format(Language.Role.Rule_Name[self.data.rule], cur_param1, color, txt))
		end
	end
end

function UnionPropertyItem:OpenCanShowView()
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = {}
	if self.data.rule ~= RuleCondition.Compose_Equip then
		data = UnionTiaoZhuanCfg[self.data.rule]
	else
		local cur_param1, cur_param2, cur_data_type, num = UnionPropertyData.Instance:GetHadAndCosumeByRuleAndCondtion(self.data.rule, self.data.cond)
		data = UnionTiaoZhuanCfg[self.data.rule][cur_data_type]
	end 
	RoleCtrl.Instance:OpenView(data.view_name, data.index)
	ViewManager.Instance:Close(ViewName.UnionProperty)
end