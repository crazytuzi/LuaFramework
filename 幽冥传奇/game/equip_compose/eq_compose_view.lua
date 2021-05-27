EqComposeView = EqComposeView or BaseClass(XuiBaseView)

local compose_timer = 666
function EqComposeView:__init()
	self:SetModal(true)
	self.def_index = TabIndex.eqcompose_equip
	
	self.texture_path_list[1] = 'res/xui/equip_compose.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"equipcompose_ui_cfg", 1, {0}},
		{"equipcompose_ui_cfg", 2, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	self.cur_select_index = 1
end

function EqComposeView:ReleaseCallBack()
	if self.tabbar ~= nil then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
	if self.tree_list then
		self.tree_list:DeleteMe()
		self.tree_list = nil
	end
	if self.child_list then
		self.child_list:DeleteMe()
		self.child_list = nil
	end
	self.play_eff = nil
end

function EqComposeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:InitTabbar()
		self:CreateTreeList()
		self:CreateChildList()
		self.node_t_list.img_hook.node:setVisible(false)
		self.node_t_list.layout_autocompose_hook.node:setVisible(false)
		XUI.AddClickEventListener(self.node_t_list.btn_nohint_checkbox.node, BindTool.Bind(self.OnClickAutoCompose, self))
		XUI.AddClickEventListener(self.node_t_list.btn_explain1.node, BindTool.Bind(self.OnClickTips, self))
		self.tabbar:SetToggleVisible(TabIndex.eqcompose_pet, true)
	end
end

function EqComposeView:InitTabbar()
	if nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.layout_common_bg.node, 20, 555,
		BindTool.Bind(self.SelectTabCallback, self), Language.EqCompose.TabGroup,
		false, ResPath.GetCommon("toggle_104"), 20)
		self.tabbar:SetSpaceInterval(15)
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:GetView():setLocalZOrder(100)
	end

	local compose_type_data = EqComposeData.Instance:GetComposeTypeDataList(TabIndex.eqcompose_dp_equip)
	self.tabbar:SetToggleVisible(TabIndex.eqcompose_dp_equip, #compose_type_data > 0)
	
	self:UpdateTabbarRemind()
end

function EqComposeView:CreateTreeList(index)
	if nil == self.tree_list then
		local ph = self.ph_list.ph_tree_list
		self.tree_list = ListView.New()
		self.tree_list:Create(ph.x, ph.y, ph.w, ph.h, nil, EqComposeTreeItem, nil, nil, self.ph_list.ph_tree_item)
		self.tree_list:SetMargin(10)
		self.tree_list:SetItemsInterval(10)
		self.tree_list:SetJumpDirection(ListView.Top)
		self.tree_list:SetSelectCallBack(BindTool.Bind(self.SelectTreeListCallBack, self))
		self.node_t_list.layout_compose.node:addChild(self.tree_list:GetView(), 100)
	end
end

function EqComposeView:CreateChildList()
	if self.child_list == nil then
		local ph = self.ph_list.ph_child_list
		self.child_list = ListView.New()
		self.child_list:Create(ph.x, ph.y, ph.w, ph.h, nil, EqComposeChildItem, nil, nil, self.ph_list.ph_child_item)
		self.child_list:SetItemsInterval(10)
		self.child_list:SetMargin(2)
		self.child_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_compose.node:addChild(self.child_list:GetView(), 10)
	end
end

function EqComposeView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function EqComposeView:ShowIndexCallBack(index)
	self.tabbar:ChangeToIndex(index)
	self:Flush(index)
end

function EqComposeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新相应界面
function EqComposeView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all" then
			local compose_type_data = EqComposeData.Instance:GetComposeTypeDataList(self.show_index)
			self.tree_list:SetDataList(compose_type_data)
			self.tree_list:SelectIndex(1)
		elseif k == "remind_change" then
			self:UpdateTabbarRemind()
			self:UpdateTreeListRemind()
		elseif k == "compose_succ" then
			self:SetShowPlayEff(903)
		elseif k == "itemdata_chage" then
			self:FlushChildList()
		end
	end
end

function EqComposeView:UpdateTabbarRemind()
	local remind_list = EqComposeData.Instance:GetTabbarRemindList()
	for k, v in pairs(remind_list) do
		self.tabbar:SetRemindByIndex(k, v > 0)
	end
end

function EqComposeView:UpdateTreeListRemind()
	local item_render_list = self.tree_list:GetAllItems()
	for k, v in pairs(item_render_list) do
		v:Flush()
	end
end

function EqComposeView:FlushChildList()
	local select_item = self.tree_list:GetItemAt(self.cur_select_index)
	if nil ~= select_item then
		local compose_item_data = EqComposeData.Instance:GetComposeItemDataList(self.show_index, select_item:GetData().tree_index)
		self.child_list:SetDataList(compose_item_data)
	end
end

function EqComposeView:SelectTabCallback(index)
	self:ChangeToIndex(index)
end

function EqComposeView:SelectTreeListCallBack(select_item, index)
	self.cur_select_index = index
	self:FlushChildList()
end

function EqComposeView:OnClickAutoCompose()
	local vis = self.node_t_list.img_hook.node:isVisible()
	self.node_t_list.img_hook.node:setVisible(not vis)
	EqComposeData.Instance:SetIsOneKeyCompose(not vis)
end

function EqComposeView:OnClickTips()
	DescTip.Instance:SetContent(Language.EqCompose.Content, Language.EqCompose.Title)
end

--展示特效
function EqComposeView:SetShowPlayEff(eff_id)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.root_node:addChild(self.play_eff, 99)
	end
	self.play_eff:setPosition(600, 350)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

----------------------------------------------------------------------------------------------------
--装备合成大类型randar
----------------------------------------------------------------------------------------------------
EqComposeTreeItem = EqComposeTreeItem or BaseClass(BaseRender)
function EqComposeTreeItem:__init()
	
end

function EqComposeTreeItem:__delete()
	
end

function EqComposeTreeItem:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_eq_bg_1.node:setLocalZOrder(100)
	self.node_tree.lbl_remind_num.node:setLocalZOrder(101)
	self.node_tree.img_title.node:setLocalZOrder(20)
	
	local size = self.view:getContentSize()
	self.node_tree.img_title.node:setPosition(size.width / 2, size.height / 2)
end

function EqComposeTreeItem:OnFlush()
	if self.data == nil then return end
	
	local remind_num = EqComposeData.Instance:GetRemindNum(self.data.tab_index, self.data.tree_index)
	self.node_tree.img_eq_bg_1.node:setVisible(remind_num > 0)
	self.node_tree.lbl_remind_num.node:setVisible(remind_num > 0)
	self.node_tree.lbl_remind_num.node:setString(remind_num)
	if self.data.title then
		self.node_tree.img_title.node:setVisible(true)
		self.node_tree.img_title.node:loadTexture(ResPath.GetEqCompose(self.data.title))
	else
		self.node_tree.img_title.node:setVisible(false)
	end
end

-- 创建选中特效
function EqComposeTreeItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetCommon("btn_102_select"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	
	self.view:addChild(self.select_effect, 10)
end

----------------------------------------------------------------------------------------------------
--装备合成子类型randar
----------------------------------------------------------------------------------------------------
EqComposeChildItem = EqComposeChildItem or BaseClass(BaseRender)
function EqComposeChildItem:__init()
	self.render_style = 1
end

function EqComposeChildItem:__delete()
	if self.cell1 then
		self.cell1:DeleteMe()
		self.cell1 = nil
	end
	
	if self.cell2 then
		self.cell2:DeleteMe()
		self.cell2 = nil
	end
	
	if self.cell3 then
		self.cell3:DeleteMe()
		self.cell3 = nil
	end
	
	if self.compose_num then
		self.compose_num:DeleteMe()
		self.compose_num = nil
	end
	
	if self.compose_num2 then
		self.compose_num2:DeleteMe()
		self.compose_num2 = nil
	end

	if self.alert then
		self.alert:DeleteMe()
		self.alert = nil
	end
	
	self.img_btn_effect = nil
end

function EqComposeChildItem:CreateChild()
	BaseRender.CreateChild(self)
	
	self.alert = Alert.New()

	local ph = self.ph_list.ph_cell1
	self.cell1 = BaseCell.New()
	self.cell1:SetPosition(ph.x, ph.y)
	self.cell1:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.cell1:GetView(), 30)
	self.cell1:GetView().ph_node_index = "ph_cell1"
	
	ph = self.ph_list.ph_cell2
	self.cell2 = BaseCell.New()
	self.cell2:SetPosition(ph.x, ph.y)
	self.cell2:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.cell2:GetView(), 30)
	self.cell2:GetView().ph_node_index = "ph_cell2"

	ph = self.ph_list.ph_cell3
	self.cell3 = BaseCell.New()
	self.cell3:SetPosition(ph.x, ph.y)
	self.cell3:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.cell3:GetView(), 30)
	self.cell3:GetView().ph_node_index = "ph_cell3"
	
	self.compose_num = NumberBar.New()
	self.compose_num:SetRootPath(ResPath.GetEqCompose("compose_"))
	self.compose_num:SetPosition(180, 17)
	self.view:addChild(self.compose_num:GetView(), 300)
	self.compose_num:GetView().ph_node_index = "ph_compose_num"

	self.compose_num2 = NumberBar.New()
	self.compose_num2:SetRootPath(ResPath.GetEqCompose("compose_"))
	self.compose_num2:SetPosition(180, 17)
	self.view:addChild(self.compose_num2:GetView(), 300)
	self.compose_num2:GetView().ph_node_index = "ph_compose_num2"
	
	local x, y = self.node_tree.btn_compose.node:getPosition()
	local size = self.node_tree.btn_compose.node:getContentSize()
	self.layout_compose = XUI.CreateLayout(x, y, size.width, size.height)
	self.img_btn_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width + 2, size.height + 2, ResPath.GetCommon("img9_120"), true)
	self.view:removeChild(self.node_tree.btn_compose.node)
	self.node_tree.btn_compose.node:setPosition(size.width / 2, size.height / 2)
	self.node_tree.btn_compose.node:setTouchEnabled(false)
	self.layout_compose:addChild(self.node_tree.btn_compose.node)
	self.layout_compose:addChild(self.img_btn_effect)
	self.view:addChild(self.layout_compose, 100)
	XUI.AddClickEventListener(self.layout_compose, BindTool.Bind(self.ClickComposeHander, self), true)

	-- self.cell1:SetVisible(false)
	-- self.cell2:SetVisible(false)
	-- self.cell3:SetVisible(false)
	-- self.compose_num:SetVisible(false)

	-- self.layout_compose:setVisible(false)
	-- self.node_tree.rich_1.node:setVisible(false)
	-- self.node_tree.rich_2.node:setVisible(false)
	-- self.node_tree.img_x.node:setVisible(false)
	-- self.node_tree.img_add.node:setVisible(false)
	-- self.node_tree.img_equal.node:setVisible(false)

	self.layout_compose.ph_node_index = "btn_compose"
	self.node_tree.rich_1.node.ph_node_index = "rich_1"
	self.node_tree.rich_2.node.ph_node_index = "rich_2"
	self.node_tree.img_x.node.ph_node_index = "img_x"
	self.node_tree.img_add.node.ph_node_index = "img_add"
	self.node_tree.img_equal.node.ph_node_index = "img_equal"
	self.node_tree.img_x2.node.ph_node_index = "img_x2"
end

function EqComposeChildItem:SetUiConfig(ui_config, need_create)
	EqComposeChildItem.super.SetUiConfig(self, ui_config, need_create)

	-- 生成样式配置
	self.style_ui_config = {}
	local style_ui_name_map = {
		["ph_style1"] = 1,
		["ph_style2"] = 2,
		["ph_style3"] = 3,
	}
	for _, v in pairs(ui_config) do
		if type(v) == "table" then
			if style_ui_name_map[v.n] then
				local ui_cfg = {}
				self.style_ui_config[style_ui_name_map[v.n]] = ui_cfg
				for __, ph_node in pairs(v) do
					if type(ph_node) == "table" then
						ui_cfg[ph_node.n] = ph_node
					end
				end
			end
		end
	end
end
function EqComposeChildItem:OnFlush()
end

function EqComposeChildItem:OnFlush()
	if self.data == nil then return end
	
	self.render_style = 1
	if #self.data.consumes > 1 and self.data.type_index == 1 then
		self.render_style = 2
	elseif self.data.tab_index == TabIndex.eqcompose_dp_equip then
		self.render_style = 3
	end

	-- 根据样式配置设置所有指定的节点 pos, vis
	local ph
	local style_ui_config = self.style_ui_config[self.render_style]
	for k, v in pairs(self.view:getChildren()) do
		if v.ph_node_index then
			if style_ui_config[v.ph_node_index] then 
				ph = style_ui_config[v.ph_node_index]
				v:setVisible(true)
				v:setPosition(ph.x, ph.y)
			else
				v:setVisible(false)
			end
		end
	end

	if self.render_style == 1 then
		self.cell1:SetData({item_id = self.data.consume.item_id, num = 1, is_bind = self.data.consume.bind})
		self.cell2:SetData({item_id = self.data.award.item_id, num = self.data.award.count, is_bind = self.data.award.bind})
		self.compose_num:SetNumber(self.data.consume.count)
		local color = "00ff00"
		if self.data.can_consume_num > 0 then
			self.layout_compose:setTouchEnabled(true)
			XUI.SetButtonEnabled(self.node_tree.btn_compose.node, true)
			self.img_btn_effect:setVisible(true)
		else
			self.layout_compose:setTouchEnabled(false)
			XUI.SetButtonEnabled(self.node_tree.btn_compose.node, false)
			self.img_btn_effect:setVisible(false)
			color = "ff0000"
		end
		local num_in_bag = BagData.Instance:GetItemNumInBagById(self.data.consumes[1].item_id)
		RichTextUtil.ParseRichText(self.node_tree.rich_1.node, string.format(Language.EqCompose.HasCount, color, num_in_bag), 18)
		self.node_tree.btn_compose.node:setTitleText(EqComposeData.Instance:GetComposeBtnTxt(self.data.tab_index))

	elseif self.render_style == 2 then
		local num_in_bag1 = BagData.Instance:GetItemNumInBagById(self.data.consumes[1].item_id)
		local num_in_bag2 = BagData.Instance:GetItemNumInBagById(self.data.consumes[2].item_id)

		self.cell1:SetData({item_id = self.data.consumes[1].item_id, num = 1, is_bind = self.data.consumes[1].is_bind})
		self.cell2:SetData({item_id = self.data.consumes[2].item_id, num = num_in_bag2, is_bind = self.data.consumes[2].is_bind})
		self.cell3:SetData({item_id = self.data.award.item_id, num = self.data.award.count, is_bind = self.data.award.bind})

		if self.data.can_consume_num > 0 then
			self.layout_compose:setTouchEnabled(true)
			XUI.SetButtonEnabled(self.node_tree.btn_compose.node, true)
			self.img_btn_effect:setVisible(true)
		else
			self.layout_compose:setTouchEnabled(false)
			XUI.SetButtonEnabled(self.node_tree.btn_compose.node, false)
			self.img_btn_effect:setVisible(false)
		end
		RichTextUtil.ParseRichText(self.node_tree.rich_1.node,
			string.format(Language.EqCompose.ConsumeItemStr1, self.data.consumes[1].num <= num_in_bag1 and COLORSTR.GREEN or COLORSTR.RED, self.data.consumes[1].num, num_in_bag1), 18)
		RichTextUtil.ParseRichText(self.node_tree.rich_2.node,
			string.format(Language.EqCompose.ConsumeItemStr2, self.data.consumes[2].num <= num_in_bag2 and COLORSTR.GREEN or COLORSTR.RED, self.data.consumes[2].num), 18)
		self.node_tree.btn_compose.node:setTitleText(EqComposeData.Instance:GetComposeBtnTxt(self.data.tab_index))
	elseif self.render_style == 3 then
		self.cell1:SetData({item_id = self.data.consume.item_id, num = 1, is_bind = self.data.consume.bind})
		self.cell2:SetData({item_id = self.data.award.item_id, num = self.data.award.count, is_bind = self.data.award.bind})
		self.compose_num:SetNumber(self.data.consume.count)
		self.compose_num2:SetNumber(self.data.award.count)
		local color = "00ff00"
		if self.data.can_consume_num > 0 then
			self.layout_compose:setTouchEnabled(true)
			XUI.SetButtonEnabled(self.node_tree.btn_compose.node, true)
			self.img_btn_effect:setVisible(true)
		else
			self.layout_compose:setTouchEnabled(false)
			XUI.SetButtonEnabled(self.node_tree.btn_compose.node, false)
			self.img_btn_effect:setVisible(false)
			color = "ff0000"
		end
		local num_in_bag = BagData.Instance:GetItemNumInBagById(self.data.consumes[1].item_id)
		RichTextUtil.ParseRichText(self.node_tree.rich_1.node, string.format(Language.EqCompose.HasCount, color, num_in_bag), 18)
		self.node_tree.btn_compose.node:setTitleText(EqComposeData.Instance:GetComposeBtnTxt(self.data.tab_index))
	end
end

-- 创建选中特效
function EqComposeChildItem:CreateSelectEffect()
end

function EqComposeChildItem:ClickComposeHander()
	if self.data.tab_index == TabIndex.eqcompose_stone or
	self.data.tab_index == TabIndex.eqcompose_god or
	self.data.tab_index == TabIndex.eqcompose_cp_extant or
	self.data.tab_index == TabIndex.eqcompose_pet or
	self.data.tab_index == TabIndex.eqcompose_equip then
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		if self.data.type_index == 12 and self.data.item_index == 2 then
			self.alert:SetLableString(Language.EqCompose.ComposeConfirm[1])
			self.alert:SetOkFunc(function()
				EqComposeCtrl.SendComposeEquipGem(self.data.type_index, self.data.item_index, self.data.award_index, prof, self.data.award.item_id, EqComposeData.Instance:GetIsOneKeyCompose() and 1 or 0)
			end)
			self.alert:Open()
		elseif self.data.type_index == 1 and self.render_style == 2 then
			local consume1 = ItemData.Instance:GetItemConfig(self.data.consumes[1].item_id)
			local consume2 = ItemData.Instance:GetItemConfig(self.data.consumes[2].item_id)
			local award = ItemData.Instance:GetItemConfig(self.data.award.item_id)

			if consume1 and consume2 and award then
				local str = string.format(Language.EqCompose.ComposeConfirmStr1,
					string.format("%06x", consume1.color), consume1.name, self.data.consumes[1].num,
					string.format("%06x", award.color), award.name, self.data.award.count,
					string.format("%06x", consume2.color), consume2.name, self.data.consumes[2].num
				)
				self.alert:SetLableString(str)
				self.alert:SetOkFunc(function()
					EqComposeCtrl.SendComposeEquipGem(self.data.type_index, self.data.item_index, self.data.award_index, prof, self.data.award.item_id, EqComposeData.Instance:GetIsOneKeyCompose() and 1 or 0)
				end)
				self.alert:Open()
			end
		else
			EqComposeCtrl.SendComposeEquipGem(self.data.type_index, self.data.item_index, self.data.award_index, prof, self.data.award.item_id, EqComposeData.Instance:GetIsOneKeyCompose() and 1 or 0)
		end
	elseif self.data.tab_index == TabIndex.eqcompose_dp_equip then
		local consume1 = ItemData.Instance:GetItemConfig(self.data.consumes[1].item_id)
		local award = ItemData.Instance:GetItemConfig(self.data.award.item_id)

		if consume1 and award then
			local str = string.format(Language.EqCompose.ComposeConfirmStr2,
				string.format("%06x", consume1.color), consume1.name, self.data.consumes[1].num,
				string.format("%06x", award.color), award.name, self.data.award.count
			)
			self.alert:SetLableString(str)
			self.alert:SetOkFunc(function()
				DecomposeCtrl.Instance:SendEquipDecompose(self.data.type_index, self.data.item_index, self.data.award_index, self.data.consume.item_id)
			end)
			self.alert:Open()
		end
	elseif self.data.tab_index == TabIndex.eqcompose_dp_extant then
		DecomposeCtrl.Instance:SendEquipDecompose(self.data.type_index, self.data.item_index, self.data.award_index, self.data.consume.item_id)
	end
end
