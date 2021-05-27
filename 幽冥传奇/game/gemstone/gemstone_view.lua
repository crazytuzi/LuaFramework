GemStoneView = GemStoneView or BaseClass()

function GemStoneView:__init()

end

function GemStoneView:__delete()
	self:RemoveEvent()

	self.view = nil
end

function GemStoneView:InitPage(view)
	self.view = view
	self.equipment_slot_index = 1
	self.layout_index =1 
	self.gem_index = 1
	self.decpmpose_level =1
	--合成
	self.cur_tree_index = 1
	self.cur_child_index = 1
	self.select_index = 1
	self.select_child = nil

	self.index = 1
	self:InitEvent()
end

function GemStoneView:RemoveEvent()
	if self.tabbar_layout then
		self.tabbar_layout:DeleteMe()
		self.tabbar_layout = nil
	end

	if self.tabbar_gem then
		self.tabbar_gem:DeleteMe()
		self.tabbar_gem = nil 
	end

	if self.gem_grid then
		self.gem_grid:DeleteMe()
		self.gem_grid = nil
	end

	if self.equip_cell ~= nil then
		for i,v in ipairs(self.equip_cell) do
			v:DeleteMe()
		end
		self.equip_cell = {}
	end

	if self.gem_cell then
		for i,v in ipairs(self.gem_cell) do
			v:DeleteMe()
		end
		self.gem_cell = {}
	end

	if self.choice_list then
		self.choice_list:DeleteMe()
		self.choice_list = nil 
	end

	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end

	if self.gem_info then
		GlobalEventSystem:UnBind(self.gem_info)
		self.gem_info = nil
	end
	--熔炼
	if self.show_reward_cells then
		for k,v in pairs(self.show_reward_cells) do
			v:DeleteMe()
		end
		self.show_reward_cells = {}
	end
	if self.gem_tree_item_list then
		self.gem_tree_item_list:DeleteMe()
		self.gem_tree_item_list = nil 
	end

	if self.child_item_list then
		self.child_item_list:DeleteMe()
		self.child_item_list = nil 
	end
	if self.resoures_cell then
		self.resoures_cell:DeleteMe()
		self.resoures_cell = nil
	end
	if self.target_cell then
		self.target_cell:DeleteMe()
		self.target_cell = nil
	end
	if self.record_gem_list then
		self.record_gem_list:DeleteMe()
		self.record_gem_list = nil 
	end
	if self.get_reward_cell then
		self.get_reward_cell:DeleteMe()
		self.get_reward_cell = nil
	end

	if self.play_effect then
		self.play_effect:setStop()
		self.play_effect = nil
	end	
	self.layout_touch = nil 
end

function GemStoneView:InitEvent()
	self:CreateTabbar()
	self:CreateClassTabbar()
	self:CreateGemGrid()
	self:CreateEquipCells()
	self:CreateGemCells()
	self:CreateChoisList()
	self.view.node_t_list.layout_choice_list.node:setVisible(false)
	XUI.AddClickEventListener(self.view.node_t_list.layout_gem_inlay.btn_select.node, BindTool.Bind1(self.BtnSelct, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_gem_inlay.btn_decompose.node, BindTool.Bind1(self.OnDecomposeDiamond, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_gem_inlay.btn_quick_buy.node, BindTool.Bind1(self.OpenBagView, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_gem_inlay.btn_inlay_tip.node, BindTool.Bind1(self.OpenInlayTip, self), true)

	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)           -- 监听物品数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)

	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback, self)           -- 监听物品数据变化
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)

	self.gem_info = GlobalEventSystem:Bind(SoulStoneEventType.GET_MY_SOUL_STONE_INFO, BindTool.Bind(self.FlushInfo, self))

	--熔炼
	self:CreateSmeltCell()
	XUI.AddClickEventListener(self.view.node_t_list.layout_btn_smelt.node, BindTool.Bind1(self.BtnSmelt, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_smelt.btn_select_choice.node, BindTool.Bind1(self.BtnSelct, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_smelt.btn_one_key.node, BindTool.Bind1(self.OnDecomposeDiamond, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_smelt.btn_smelt_ques.node, BindTool.Bind1(self.OpenSmeltView, self), true)
	self:CreateRecordList()

	self.gem_record_info = GlobalEventSystem:Bind(SoulStoneEventType.SMELT_INFO_SUCCESS, BindTool.Bind(self.FlushSmeltData, self))
	--合成
	self:CreateCoupondTreeList()
	self:CreateCoupndChildList()
	self:CreateGemShowCell()
	XUI.AddClickEventListener(self.view.node_t_list.layout_gem_cmpond.layout_btn_gem_coupond.node, BindTool.Bind1(self.Coupond, self), true)
end

function GemStoneView:OpenInlayTip()
	DescTip.Instance:SetContent(Language.Equipment.InlayGemContent, Language.Equipment.InlayGemTitle)
end

function GemStoneView:OpenSmeltView()
	DescTip.Instance:SetContent(Language.Equipment.SmeltContent, Language.Equipment.SmeltTitle)
end

function GemStoneView:OpenBagView()
	ViewManager.Instance:Open(ViewName.Shop, 5)
end

function GemStoneView:FlushInfo()
	if self.view == nil then return end
	self:FlushEquipCell()
	self:FlushDiamondCell()
	self:FlushData()
	self:FlushBtn()
	self:FlushText()
end

function GemStoneView:BtnSelct()
	self.view.node_t_list.layout_choice_list.node:setVisible(true)
	self:UpdateLayoutTouch()
end

function GemStoneView:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL then
		self:FlushValue()
	end
end

function GemStoneView:FlushValue()
	local num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_DIAMOND_CRYSTAL)
	self.view.node_t_list.txt_had_soul_value.node:setString(num)
end

function GemStoneView:ItemDataChangeCallback(change_type, item_id, item_index, series)
	local config = ItemData.Instance:GetItemConfig(item_id)
	if config and config.dura then
		if self.layout_index == 1 then
			self:FlushData()
		elseif self.layout_index == 2 then
			self:FlushCoupondInfo()
			self:FlushRightView()
		end
	end
end

function GemStoneView:CreateChoisList()
	if self.choice_list == nil then
		local ph = self.view.ph_list.ph_choice_list
		self.choice_list = ListView.New()
		self.choice_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ChoiceGemItemRender, nil, nil, self.view.ph_list.ph_choice_cell)
		self.choice_list:GetView():setAnchorPoint(0, 0)
		self.choice_list:SetItemsInterval(3)
		self.choice_list:SetMargin(2)
		self.choice_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_choice_list.node:addChild(self.choice_list:GetView(), 100)
		self.choice_list:SetSelectCallBack(BindTool.Bind(self.OnSelectChoiceItemHandler, self))
		self.choice_list:SetDataList(Language.Equipment.DecomposeNameList)
	end
end

function GemStoneView:UpdateLayoutTouch()
	if nil == self.layout_touch then
		local layout_touch = XLayout:create(HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight())
		self.view.node_t_list.layout_choice_list.node:addChild(layout_touch,-1)
		XUI.AddClickEventListener(layout_touch, function()
			self.view.node_t_list.layout_choice_list.node:setVisible(false)
		end)
		self.layout_touch = layout_touch
	end

	local pos = self.view.node_t_list.layout_choice_list.node:convertToNodeSpace(cc.p(0, 0))
	self.layout_touch:setPosition(pos.x, pos.y)
end

function GemStoneView:OnSelectChoiceItemHandler(item, index)
	if item == nil or item:GetData() == nil then return end
	self.decpmpose_level = item:GetIndex()
	if self.layout_index == 1 then
		self:FlushBtn()
	else
		self:FlushSelectChoiceBtn()
	end
	self.view.node_t_list.layout_choice_list.node:setVisible(false)
end

function GemStoneView:FlushBtn()
	local txt = string.format(Language.Equipment.DecomposeLevel, self.decpmpose_level)
	self.view.node_t_list.btn_select.node:setTitleText(txt)
end
--一键分解
function GemStoneView:OnDecomposeDiamond()
	EquipmentCtrl.Instance:OneKeyDecompse(self.decpmpose_level)
end

function GemStoneView:UpdateData(data)
	self:BoolShowLayout()
	self:FlushLayoutIndex()
	self:FlushValue()
	self:FlushTabbarPoint()
	if self.equip_cell[self.index] then
		self.equip_cell[self.index]:SetSelect(true)
	end
end

function GemStoneView:CreateGemGrid()
	if self.gem_grid == nil then
		self.gem_grid = BaseGrid.New()
		local ph_baggrid = self.view.ph_list.ph_stone_grid
		local grid_node = self.gem_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = 20, col=5, row=4})
		grid_node:setAnchorPoint(0.5, 0.5)
		self.view.node_t_list.layout_grid_bag.node:addChild(grid_node)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.gem_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
		self.gem_grid:SetIsShowTips(false)
	end
end

function GemStoneView:SelectCellCallBack(cell)
	if cell == nil or cell:GetData() == nil then return end
	local cell_data = cell:GetData()

	TipsCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_GEM_BAG, {equip_pos = self.equipment_slot_index - 1})
end


function GemStoneView:CreateTabbar()
	if self.tabbar_layout == nil then
		self.tabbar_layout = Tabbar.New()
		self.tabbar_layout:CreateWithNameList(self.view.node_t_list["layout_gemstone2"].layout_btn.node, 10, 0,
			BindTool.Bind1(self.SelectTabCallback, self), 
			Language.Role.TabGroup4, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_layout:SetSpaceInterval(5)
	end
end

function GemStoneView:SelectTabCallback(index)
	self.layout_index = index
	self:BoolShowLayout()
	self:FlushLayoutIndex()
end

function GemStoneView:BoolShowLayout()
	self.view.node_t_list.layout_gem_inlay.node:setVisible(self.layout_index == 1)
	self.view.node_t_list.layout_gem_cmpond.node:setVisible(self.layout_index == 2)
	self.view.node_t_list.layout_smelt.node:setVisible(self.layout_index == 3)
end

function GemStoneView:SetSlectBtn(index)
	if self.tabbar_layout == nil then return end
	self.tabbar_layout:SelectIndex(index)
end

function GemStoneView:CreateClassTabbar()
	if self.tabbar_gem == nil then
		self.tabbar_gem = Tabbar.New()
		self.tabbar_gem:CreateWithNameList(self.view.node_t_list["layout_gemstone2"].layout_gem_inlay.node, 585, 498,
			BindTool.Bind1(self.SelectTabGemCallback, self), 
			Language.Role.TabGroup5, false, ResPath.GetCommon("toggle_121_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_gem:SetSpaceInterval(14)
	end
end

function GemStoneView:SelectTabGemCallback(index)
	self.gem_index = index
	self:FlushData()
end

function GemStoneView:FlushEquipCell()
	local data = EquipmentData.Instance:GetDiamondData()
	for i, v in ipairs(data) do
		if self.equip_cell[i] ~= nil then
			self.equip_cell[i]:SetData(v)
		end
	end
end

function GemStoneView:FlushDiamondCell()
	local cur_data = EquipmentData.Instance:GetDiamondDataByEquipSlots(self.equipment_slot_index)
	local bool_wear = cur_data.bool_wear or {}
	local equip_slots_pos = cur_data.equipment_slots_pos 
	local bool_activate = cur_data.bool_activate 
	local stone_data = {}
	
	for k, v in pairs(bool_wear) do
		local stone_level = cur_data.diamond_level[k]
		local item_id = cur_data.item_id[k]
		stone_data[k] = {id = item_id, num = 1, is_bind = 0, index = k, level = stone_level, bool_open = v, pos = equip_slots_pos, diamond_pos = k, activate = bool_activate}
	end
	for i, v in ipairs(self.gem_cell) do
		v:SetData(stone_data[i])
	end
end


function GemStoneView:FlushText()
	local data = EquipmentData.Instance:GetDiamondDataByEquipSlots(self.equipment_slot_index)
	local prof =RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local bool_wear = data.bool_wear or {}
	local equip_data =  EquipData.Instance:GetGridData(data.equipment_slots_pos) or {}
	local equip_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	local equip_circle = 0
	if equip_cfg ~= nil then
		for i, v in ipairs(equip_cfg.conds) do
			if v.cond == ItemData.UseCondition.ucMinCircle then
				equip_circle = v.value
			end
		end
	else
		equip_circle = 0
	end
	local txt = {}
	local txt_shuxing = {}
	local color = {}
	local  n = 0
	for k, v in pairs(bool_wear) do
		if v > 0 then
			n = n + 1
			local level = data.diamond_level[k]
			local count = EquipmentData.GetSoulStoneCfg(level + 1) 
			txt[k] = string.format(Language.Equipment.Name_4[k], level)
			
			if level == 0 then --可提升
				txt_shuxing[k] = Language.Equipment.Can_Up
			else
				local consume_circle = GemStoneData.Instance:GetNeedEquipCircle(level, k) or 0
				if equip_circle >= consume_circle then
					local cfg = ItemData.Instance:GetItemConfig(data.item_id[k])
					local attr_cfg = cfg and cfg.staitcAttrs or {}
					local attr_t = RoleData.Instance:GetGodZhuEquipAttr(attr_cfg, prof)
					attr_t = CommonDataManager.DelAttrByProf(prof, attr_cfg)
					local text = RoleData.FormatAttrContent(attr_t)
					txt_shuxing[k] = text
					color[k] = Str2C3b("ff00ff")
				else
					txt_shuxing[k] = Language.Equipment.NoShengXiao
					color[k] = COLOR3B.GRAY
				end
			end
		elseif v <= 0 then
			txt[k] = Language.Equipment.Name_activate[k]
			color[k] = COLOR3B.GRAY
			txt_shuxing[k] = Language.Equipment.No_JiHuo
		end
	end
	for i,v in ipairs(color) do
		self.view.node_t_list["txt_name_"..i].node:setColor(v)
		self.view.node_t_list["txt_value_"..i].node:setColor(v)
	end

	for i,v in ipairs(txt) do
		self.view.node_t_list["txt_name_"..i].node:setString(v)
	end
	for k,v in ipairs(txt_shuxing) do
		if self.view.node_t_list["txt_value_"..k] ~= nil then
			self.view.node_t_list["txt_value_"..k].node:setString(v)
		end
	end
end



--装备格子
function GemStoneView:CreateEquipCells()
	self.equip_cell = {}
	for i = 1, 10 do
		local ph = self.view.ph_list["ph_cell_"..i]
		local cell = self:CreateCellRender(i, ph, cur_data)
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
		table.insert(self.equip_cell, cell)
	end
end

function GemStoneView:CreateCellRender(i, ph, cur_data)
	local cell = EquipCellRender.New()
	local render_ph = self.view.ph_list.ph_gem_item 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	self.view.node_t_list["layout_gem_inlay"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end


function GemStoneView:OnClickEquipCell(cell)
	self.select_data  = cell:GetData()
	self.equipment_slot_index = cell:GetIndex()
	if self.select_data.bool_activate == 1 then
		if not cell or self.index == cell:GetIndex() then
			return
		end
		cell:SetSelect(true)
		if self.index and self.equip_cell[self.index] then
			self.equip_cell[self.index]:SetSelect(false)
		end
		self.index = cell:GetIndex()
		self:FlushDiamondCell()
		self:FlushText()
		-- self:UpdateLeftData()
		--ViewManager.Instance:Close(ViewName.EquipmentSoulStoneTip)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.DescTip)
	end
end


function GemStoneView:FlushData()
	local data = GemStoneData.Instance:GetDiamondByType(self.gem_index)
	self.gem_grid:SetDataList(data)
	-- local n = 0 
	-- for k,v in pairs(data) do
	-- 	n = n + 1
	-- end
	-- self.view.node_t_list.txt_bag_num.node:setString(n .. "/".. 20)

end

function GemStoneView:CreateGemCells()
	self.gem_cell = {}
	for i = 1, 5 do
		local ph = self.view.ph_list["ph_gem_"..i]
		local cell = self:CreateRender(i, ph, cur_data)
		cell:SetIndex(i)

		cell:AddClickEventListener(BindTool.Bind1(self.OnClickGemStoneCell, self), true)
		table.insert(self.gem_cell, cell)
	end
end

function GemStoneView:CreateRender(i, ph, cur_data)
	local cell = GemStoneCellRender.New()
	local render_ph = self.view.ph_list.ph_item_1 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	cell:GetView():setAnchorPoint(0.5, 0.5)
	self.view.node_t_list["layout_gem_inlay"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end


function GemStoneView:OnClickGemStoneCell(cell)
	if cell == nil or cell:GetData() == nil then return end
	local data = cell:GetData()
	if data.bool_open > 0 then
		local cur_data = {item_id = data.bool_open, num = 1, is_bind = 0}
		TipsCtrl.Instance:OpenItem(cur_data, EquipTip.FROME_EQUIP_STONE)
	else
		local index = cell:GetIndex()
		self.tabbar_gem:SelectIndex(index)
	end

end

function GemStoneView:FlushTabbarPoint()
	if self.tabbar_layout == nil then return end
	self.tabbar_layout:SetRemindByIndex(1, RemindManager.Instance:GetRemind(RemindName.EquipmentHunZhu) > 0)
	self.tabbar_layout:SetRemindByIndex(2, RemindManager.Instance:GetRemind(RemindName.GemCouond) > 0)
end

--==============
function GemStoneView:FlushLayoutIndex()
	if self.layout_index  == 1 then
		self:FlushInfo()
	elseif self.layout_index == 3 then
		self:FlushSmeltData()
	elseif self.layout_index == 2 then
		self:FlushCoupondInfo()
		self.gem_tree_item_list:SelectIndex(1)
		self.child_item_list:SelectIndex(1)
	end
end


--============

--  熔炼
function GemStoneView:CreateSmeltCell()
	self.show_reward_cells = {}
	for i = 1,5 do
		local ph = self.view.ph_list["ph_reward_cell_" .. i]

		if ph then
			local cell = BaseCell.New()
			cell:SetPosition(ph.x, ph.y)
			cell:SetIndex(i)
			cell:SetAnchorPoint(0, 0)
			self.view.node_t_list.layout_smelt.node:addChild(cell:GetView(), 200)
			RenderUnit.CreateEffect(7, cell:GetView(), 201, nil, nil)
			table.insert(self.show_reward_cells, cell)
		end
	end

	local ph = self.view.ph_list.ph_get_reward
	if self.get_reward_cell == nil then
		self.get_reward_cell = BaseCell.New()
		self.get_reward_cell:SetPosition(ph.x, ph.y)
		self.get_reward_cell:SetIndex(i)
		self.get_reward_cell:SetAnchorPoint(0, 0)
		self.view.node_t_list.layout_smelt.node:addChild(self.get_reward_cell:GetView(), 100)
	end
	self.get_reward_cell:GetView():setVisible(false)
end

function GemStoneView:FlushConsume()
	local consume_t = GemStoneData.Instance:GetConsume()
	local txt = string.format(Language.Equipment.Consume_num, consume_t.count)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_consume_gem.node, txt)
	XUI.RichTextSetCenter(self.view.node_t_list.rich_consume_gem.node)
end

function GemStoneView:FlushSelectChoiceBtn()
	local txt = string.format(Language.Equipment.DecomposeLevel, self.decpmpose_level)
	self.view.node_t_list.btn_select_choice.node:setTitleText(txt)
end

function GemStoneView:CreateRecordList()
	if self.record_gem_list == nil then
		local ph = self.view.ph_list.ph_list
		self.record_gem_list = ListView.New()
		self.record_gem_list:Create(ph.x, ph.y, ph.w, ph.h, nil, RecordGemRender, nil, nil, self.view.ph_list.ph_item)
		self.record_gem_list:GetView():setAnchorPoint(0, 0)
		self.record_gem_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_smelt.node:addChild(self.record_gem_list:GetView(), 100)
	end
end

function GemStoneView:FlushRecord()
	 local data = EquipmentData.Instance:GetInFoList()
	 self.record_gem_list:SetDataList(data)
end

function GemStoneView:FlushSmeltData(item_id)
	if self.view ~= nil then
		self:FlushShowReward()
		self:FlushConsume()
		self:FlushSelectChoiceBtn()
		self:FlushRecord()
		if item_id  and item_id ~= 0 then
			self.get_reward_cell:GetView():setVisible(true)
			self.get_reward_cell:SetData({item_id = item_id,num = 1, is_bind = 0})
			local ph = self.view.ph_list.ph_get_reward
			self:SetPlayEffect(986, ph.x + 40 , ph.y + 20)
		end
	end
end

function GemStoneView:FlushShowReward()
	local data = GemStoneData.Instance:GetShowReWard()
	for k, v in pairs(self.show_reward_cells) do
		v:SetData(data[k])
	end
end

function GemStoneView:BtnSmelt()
	EquipmentCtrl.Instance:SmeltDiamondReq(1)
end

function GemStoneView:SetPlayEffect(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.view.node_t_list.layout_smelt.node:addChild(self.play_effect,200)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end
--=====================合成=================-----------
function GemStoneView:CreateCoupondTreeList()
	if self.gem_tree_item_list == nil  then
		local ph = self.view.ph_list.ph_tree_list
		self.gem_tree_item_list = ListView.New()
		self.gem_tree_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, GemTreeListItem, nil, nil, self.view.ph_list.ph_tree_item)
		self.view.node_t_list["layout_gem_cmpond"].node:addChild(self.gem_tree_item_list:GetView(), 888)
		self.gem_tree_item_list:SetMargin(10)
		self.gem_tree_item_list:SetItemsInterval(10)
		self.gem_tree_item_list:SelectIndex(1)
		self.gem_tree_item_list:GetView():setAnchorPoint(0, 0)
		self.gem_tree_item_list:SetJumpDirection(ListView.Top)
		self.gem_tree_item_list:SetSelectCallBack(BindTool.Bind1(self.SelectTreeListCallBack, self))
	end
end

function GemStoneView:SelectTreeListCallBack(item)
	if item == nil or item:GetData() == nil then return end
	self.select_index = index
	self.select_data = item:GetData()
	self.cur_tree_index = self.select_data.current_item_index
	self:FlushChildList()
	self.child_item_list:SelectIndex(1)
	self:FlushRightView()
end

function GemStoneView:CreateCoupndChildList()
	if self.child_item_list == nil then
		local ph = self.view.ph_list.ph_child_list
		self.child_item_list = ListView.New()
		self.child_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, GemChildListItem, nil, nil, self.view.ph_list.ph_child_item)
		self.view.node_t_list["layout_gem_cmpond"].node:addChild(self.child_item_list:GetView(), 99)
		self.child_item_list:SetMargin(10)
		self.child_item_list:SetItemsInterval(10)
		self.child_item_list:SelectIndex(1)
		self.child_item_list:GetView():setAnchorPoint(0, 0)
		self.child_item_list:SetJumpDirection(ListView.Top)
		self.child_item_list:SetSelectCallBack(BindTool.Bind1(self.SelectChildListCallBack, self))
	end
end

function GemStoneView:SelectChildListCallBack(item)
	if item == nil or item:GetData() == nil then return end
	self.select_child = item:GetData()
	self.cur_child_index = self.select_child.current_item_index
	self:FlushRightView()
end

function GemStoneView:CreateGemShowCell()
	if self.resoures_cell == nil then
		local ph = self.view.ph_list.ph_cell_resoures
		self.resoures_cell = BaseCell.New()
		self.resoures_cell:SetPosition(ph.x, ph.y)
		self.resoures_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list["layout_gem_cmpond"].node:addChild(self.resoures_cell:GetView(), 100)
	end
	if self.target_cell == nil then
		local ph = self.view.ph_list.ph_cell_target
		self.target_cell = BaseCell.New()
		self.target_cell:SetPosition(ph.x, ph.y)
		self.target_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list["layout_gem_cmpond"].node:addChild(self.target_cell:GetView(), 100)
	end
end

function GemStoneView:FlushTreeList()
	local data = GemStoneData.Instance:GetCoumpondTreeList()
	self.gem_tree_item_list:SetDataList(data)
end

function GemStoneView:FlushChildList()
	local data = GemStoneData.Instance:GetCoumpondChildList(self.cur_tree_index)
	self.child_item_list:SetDataList(data)
end

function GemStoneView:FlushCoupondInfo()
	self:FlushTreeList()
	self:FlushChildList()
	self:FlushRightView()
end

function GemStoneView:FlushRightView()
	local child_data =  GemStoneData.Instance:GetCoumpondChildList(self.cur_tree_index)
	local cur_data = self.select_child or child_data[1]
	if cur_data ~= nil then
		local consume = cur_data.consume
		local award = cur_data.item
		self.resoures_cell:SetData(consume)
		self.target_cell:SetData(award)
		local consume_config = ItemData.Instance:GetItemConfig(consume.item_id)
		local item_config = ItemData.Instance:GetItemConfig(award.item_id)
		local item_num = ItemData.Instance:GetItemNumInBagById(consume.item_id, nil)
		local color = nil
		if item_num < cur_data.consume_num then
			color = "ff0000"
		end
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_had_gem.node, string.format(Language.Equipment.Bag_had,GuideColorCfg[consume_config.bgquality],consume_config.name, color or GuideColorCfg[consume_config.bgquality], item_num))
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_consume_gem.node, string.format(Language.Equipment.Consume_Coupnd,GuideColorCfg[consume_config.bgquality], consume_config.name,cur_data.consume_num))
		XUI.RichTextSetCenter(self.view.node_t_list.txt_had_gem.node)
		XUI.RichTextSetCenter(self.view.node_t_list.txt_consume_gem.node)

		local txt = string.format(Language.Equipment.BaoShiName, GuideColorCfg[consume_config.bgquality], consume_config.name)
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_target_name.node, txt)
		XUI.RichTextSetCenter(self.view.node_t_list.txt_target_name.node)
		
		local txt_1 = string.format(Language.Equipment.BaoShiName, GuideColorCfg[item_config.bgquality]or"ffffff", item_config.name)
		RichTextUtil.ParseRichText(self.view.node_t_list.txt_resoures_name.node, txt_1)
		XUI.RichTextSetCenter(self.view.node_t_list.txt_resoures_name.node)
	end
end

function GemStoneView:Coupond()
	local child_data =  GemStoneData.Instance:GetCoumpondChildList(self.cur_tree_index)
	local cur_data = self.select_child or child_data[1]
	if cur_data ~= nil then
		local consume = cur_data.consume
		local consume_config = ItemData.Instance:GetItemConfig(consume.item_id)
		local item_num = ItemData.Instance:GetItemNumInBagById(consume.item_id, nil)
		if item_num >= cur_data.consume_num then
			EquipmentCtrl.Instance:SendComposeEquipGemReq(5, self.cur_tree_index, self.cur_child_index, self.select_child.item.item_id, 0, {})
		else
			local config = ItemData.Instance:GetItemConfig(consume.item_id)
			local sub_num = cur_data.consume_num - item_num
			local txt = string.format(Language.Equipment.SuB_Desc, GuideColorCfg[config.bgquality]or"ffffff", config.name, sub_num)
			SysMsgCtrl.Instance:FloatingTopRightText(txt)
		end
	end
end

--=====================-----------------------
EquipCellRender = EquipCellRender or BaseClass(BaseRender)
function EquipCellRender:__init()
	--self.cache_select = true
end

function EquipCellRender:__delete()

end

function EquipCellRender:CreateChild()
	BaseRender.CreateChild(self)

end

function EquipCellRender:OnFlush()
	if self.data == nil then return end
	local path = nil 
	if self.data.bool_activate == 1 then
		path = ResPath.GetEquipment("eq_bg_".. self.data.equipment_slots_pos)
	else
		if self.data.equipment_slots_pos < 4 then
			path = ResPath.GetEquipBg("equip_ta_".. self.data.equipment_slots_pos)
		elseif self.data.equipment_slots_pos >= 4 then
			path = ResPath.GetEquipBg("equip_ta_"..(self.data.equipment_slots_pos))
		end
	end
	self.node_tree.cell_equip_bg.node:loadTexture(path)
	if self.data.bool_activate == 1 then
		local n = 0 
		for k, v in pairs(self.data.diamond_level) do
			n = n + v
		end
		self.node_tree.txt_need_level.node:setString("")
		self.node_tree.txt_level.node:setString(n)
		self.node_tree.img_txet_bg.node:setVisible(false)
	else
		local cfg = EquipmentData.GetActivateLevel((self.data.equipment_slots_pos+1))
		local need_level = cfg.level
		local need_circle = cfg.circle
		local txt = string.format(Language.Equipment.Need_Level,need_circle)
		self.node_tree.txt_need_level.node:setString(txt)
		self.node_tree.txt_level.node:setString("")
		self.node_tree.img_txet_bg.node:setVisible(true)
	end
	local bool = EquipmentData.Instance:GetCanUpSingleData((self.data.equipment_slots_pos+1))
	self.node_tree.img_canwear_flag.node:setVisible(bool>0)
	XUI.EnableOutline(self.node_tree.txt_level.node)
	XUI.EnableOutline(self.node_tree.txt_need_level.node)
	self.node_tree.txt_need_level.node:setLocalZOrder(998)
	self.node_tree.txt_level.node:setLocalZOrder(999)
end

GemStoneCellRender = GemStoneCellRender or BaseClass(BaseRender)
function GemStoneCellRender:__init()
	--self.cache_select = true
end

function GemStoneCellRender:__delete()

end

function GemStoneCellRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.layout_had_wear.btn_dis.node, BindTool.Bind1(self.OnTakeOffDiamond, self), true)
	XUI.AddClickEventListener(self.node_tree.layout_had_wear.btn_up.node, BindTool.Bind1(self.OnUpDiamondView, self), true)
end

function GemStoneCellRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.layout_had_wear.node:setVisible(self.data.bool_open > 0)
	self.node_tree.txt_name_gem.node:setString(self.data.bool_open <=0  and Language.Equipment.Name_2[self.index] or "")

	self.node_tree.img_bg.node:setVisible(self.data.bool_open <= 0)
	local config = ItemData.Instance:GetItemConfig(self.data.id)
	if config ~= nil then
		local icon = config.icon
		self.node_tree.layout_had_wear.cell_bg_icon.node:loadTexture(ResPath.GetItem(icon))
	end
	-- local bool = EquipmentData.Instance:GetCanUpSingleData(self.data.pos)
	
	local consume_t, next_Id = GemStoneData.Instance:GetSoulStoneCfg(self.data.diamond_pos, self.data.level)
	local equip_data = EquipData.Instance:GetGridData(self.data.pos)
	local bool = true
	local bool_point = false
	if consume_t == nil then
		bool = false
		bool_point = false
	else
		if equip_data ~= nil then
			local equip_circle = 0
			local equip_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
			for i, v in ipairs(equip_cfg.conds) do
				if v.cond == ItemData.UseCondition.ucMinCircle then
					equip_circle = v.value
				end
			end
			local consume_circle = GemStoneData.Instance:GetNeedEquipCircle(self.data.level, self.data.diamond_pos)
			if equip_circle > consume_circle then
				local id = consume_t.id 
				local consume_num = consume_t.count
				local num = ItemData.Instance:GetItemNumInBagById(id, nil)
				if num >= consume_num then
					bool_point = true
				end
			else
				bool_point = false
			end
		else
			bool_point = false
		end
		bool = true
	end
	self.node_tree.layout_had_wear.img_up_flag.node:setVisible(bool_point)
	self.node_tree.layout_had_wear.btn_up.node:setVisible(bool)
end

function GemStoneCellRender:OnTakeOffDiamond()
	EquipmentCtrl.Instance:SendEquipUnloadGemReq(0, self.data.pos, self.data.diamond_pos, 0)
end

function GemStoneCellRender:OnUpDiamondView()
	GemStoneCtrl.Instance:OpenUpView(self.data.pos, self.data.diamond_pos)
end

ChoiceGemItemRender = ChoiceGemItemRender or BaseClass(BaseRender)
function ChoiceGemItemRender:__init()
	
end

function ChoiceGemItemRender:__delete()
	-- body
end

function ChoiceGemItemRender:CreateChild()
	BaseRender.CreateChild(self)
end

function ChoiceGemItemRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_choice_name.node:setString(self.data)
end

GemTreeListItem = GemTreeListItem or BaseClass(BaseRender)
function GemTreeListItem:__init()
	
end

function GemTreeListItem:__delete()
	-- body
end

function GemTreeListItem:CreateChild()
	BaseRender.CreateChild(self)
end

function GemTreeListItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_equip_name_2.node:setString(self.data.name or "")
	self.node_tree.txt_equip_name_2.node:setColor(COLOR3B.OLIVE)
	local bool_show_flag = GemStoneData.Instance:GetSingleCanCompond(self.data.current_item_index)
	self.node_tree.img_flag.node:setVisible(bool_show_flag > 0)
	if self.cache_select and self.is_select then
		self.cache_select = false
		self:CreateSelectEffect()
	end	

end


function GemTreeListItem:CreateSelectEffect()
	if nil == self.node_tree.img_bg_normal then
		self.cache_select = true
		return
	end
	local size =self.node_tree.img_bg_normal.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width,size.height,ResPath.GetCommon("btn_106_select"), true , cc.rect(15,19,9,6))
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end
	self.node_tree.img_bg_normal.node:addChild(self.select_effect, 999)
end


GemChildListItem = GemChildListItem or BaseClass(BaseRender)
function GemChildListItem:__init()
	
end

function GemChildListItem:__delete()
	-- body
end

function GemChildListItem:CreateChild()
	BaseRender.CreateChild(self)
end

function GemChildListItem:OnFlush()
	if self.data == nil then return end
	local itme_config = ItemData.Instance:GetItemConfig(self.data.item.item_id)
	if itme_config ~= nil then
		local txt_1 = string.format(Language.Equipment.BaoShiName, GuideColorCfg[itme_config.bgquality]or"ffffff", itme_config.name)
		RichTextUtil.ParseRichText(self.node_tree.txt_equip_name_3.node, txt_1)
		XUI.RichTextSetCenter(self.node_tree.txt_equip_name_3.node)
	end
	local consume_id = self.data.consume.item_id
	local num = ItemData.Instance:GetItemNumInBagById(consume_id, nil)
	local consume_count = self.data.consume_num or 0
	local bool  = false
	if num >= consume_count then
		bool = true
	end
	self.node_tree.img_flag_up.node:setVisible(bool)
	--local 
end

RecordGemRender = RecordGemRender or BaseClass(BaseRender)
function RecordGemRender:__init()
	
end

function RecordGemRender:__delete()
	-- body
end

function RecordGemRender:CreateChild()
	BaseRender.CreateChild(self)
end

function RecordGemRender:OnFlush()
	if self.data == nil then return end
	
	RichTextUtil.ParseRichText(self.node_tree.rich_gem_text.node, self.data)
end

