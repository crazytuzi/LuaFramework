EquipmentItemView = EquipmentItemView or BaseClass(XuiBaseView)

function EquipmentItemView:__init()
	self.is_any_click_close = true
	self.config_tab = {{"equipment_ui_cfg", 10, {0}}}
	self.selcetec_index = 1
	self:SetRootNodeOffPos({x = 115, y = -120})
end

function EquipmentItemView:__delete()
	if nil ~= self.bag_grid then
		self.bag_grid:DeleteMe()
		self.bag_grid = nil
	end

	if nil ~= self.quick_alert then
		self.quick_alert:DeleteMe()
		self.quick_alert = nil
	end
end

function EquipmentItemView:LoadCallBack()
	self:InitEquipItem()
	self:RegisterButtonEvent()
end

function EquipmentItemView:OnFlush(param_t)
	self:FlushButtonState()
	self:SetTabSelect(self.selcetec_index)
end

function EquipmentItemView:FlushButtonState()
	if self.equip_tip ~= nil then
		if EquipTip.FROM_FULING_TO_MAIN == self.equip_tip or 
		   EquipTip.FROM_FULING_SHIFT_TO_MATE == self.equip_tip then
			self.node_t_list.btn_quick.node:setVisible(false)
			self.node_t_list.btn_equip_item.node:setVisible(true)
			self.node_t_list.btn_bag_item.node:setVisible(true)
		elseif EquipTip.FROM_FULING_SHIFT_TO_MAIN == self.equip_tip then
			self.node_t_list.btn_quick.node:setVisible(false)
			self.node_t_list.btn_equip_item.node:setVisible(false)
			self.node_t_list.btn_bag_item.node:setVisible(true)
		elseif EquipTip.FROM_FULING_TO_MATE == self.equip_tip then
			self.node_t_list.btn_quick.node:setVisible(true)
			self.node_t_list.btn_equip_item.node:setVisible(false)
			self.node_t_list.btn_bag_item.node:setVisible(true)
		end
	end
end

function EquipmentItemView:RegisterButtonEvent()
	XUI.AddClickEventListener(self.node_t_list.btn_bag_item.node, BindTool.Bind(self.SetTabSelect, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_equip_item.node, BindTool.Bind(self.SetTabSelect, self, 2))
	XUI.AddClickEventListener(self.node_t_list.btn_quick.node, BindTool.Bind(self.OnClickQuickFuling, self))
end

function EquipmentItemView:InitEquipItem()
	local bag_cells = 84
	--创建格子
	self.bag_grid = BaseGrid.New()
	local grid_node = self.bag_grid:CreateCells({w = 580, h = 330 , cell_count = bag_cells, col = 7, row = 4, is_show_tips = false})
	self.node_t_list.layout_fuling_item.node:addChild(grid_node,1000, 1000)  				--将网格实体添加显示	
	grid_node:setPosition(10, 35)

	self.bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))

	self.bag_radio = RadioButton.New()
	local radio_btns = {}
	for i = 0, 2 do
		 radio_btns[i + 1] = self.node_t_list["toggle_radio" .. i].node
	end
	self.bag_radio:SetToggleList(radio_btns)
	self.bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
	self.bag_grid:SetRadioBtn(self.bag_radio)

	ItemData.Instance:NotifyDataChangeCallBack(BindTool.Bind1(self.OnItemDataListChange, self),true)
end

function EquipmentItemView:OnItemDataListChange(change_type, item_id, item_index, series)
	self:Flush({item_datalist_change = true})
end

function EquipmentItemView:BagRadioHandler(index)
	if nil ~= self.bag_grid then
		self.bag_grid:ChangeToPage(index)
	end
end

function EquipmentItemView:ShowIndexCallBack(index)
	-- 选择主装备时默认选中身上装备
	if EquipTip.FROM_FULING_TO_MAIN == self.equip_tip then
		self.selcetec_index = 2
	end
	self:Flush()
end

function EquipmentItemView:SetTabSelect(index)
	if 1 == index and false == self.node_t_list.btn_bag_item.node:isVisible() then
		index = 2
	end
	if 2 == index and false == self.node_t_list.btn_equip_item.node:isVisible() then
		index = 1
	end

	local need_circles = SpiritSlotStrongCfg.lessCircleconsume
	if self.equip_tip then
		if EquipTip.FROM_FULING_TO_MAIN == self.equip_tip or
		   EquipTip.FROM_FULING_SHIFT_TO_MATE == self.equip_tip or
		   EquipTip.FROM_FULING_SHIFT_TO_MAIN == self.equip_tip then
		   need_circles = SpiritSlotStrongCfg.lessCircleLvlUp
		end
	end
	local item_data = BagData.Instance:GetBagEquipList()
	if index == 2 then
		item_data = EquipData.Instance:GetDataList()
	end
	local data = {}
	local excluse_series = self.excluse_data and self.excluse_data.series or -999
	local get_item_level = ItemData.GetItemLevel
	local get_eq_all_exp = EquipmentData.GetEqFulingAllExp
	local is_shift_eq_tip = EquipTip.FROM_FULING_SHIFT_TO_MAIN == self.equip_tip
	for k,v in pairs(item_data) do
		local limit_level, zhuan = get_item_level(v.item_id)
		if zhuan >= need_circles and v.series ~= excluse_series then
			if false == is_shift_eq_tip or 0 < get_eq_all_exp(v) then
				table.insert(data, v)
			end
		end
	end
	table.sort(data, SortTools.KeyUpperSorter("zhuan_level"))
	data[0] = table.remove(data, 1)
	self.bag_grid:SetDataList(data)
	self.selcetec_index = index
end

function EquipmentItemView:SelectCellCallBack(cell)
	if nil == cell then
		return
	end
	local cell_data = cell:GetData()
	if nil == cell_data then
		return
	end
	local item_data = ItemData.Instance:GetItemConfig(cell_data.item_id)
	if nil == item_data then
		return
	end
	TipCtrl.Instance:OpenItem(cell_data, self.equip_tip, {selcetec_index = self.selcetec_index})
end

function EquipmentItemView:SetPosition(x, y)
	if nil ~= self.root_node then
		self.root_node:setPosition(x, y)
	end
end

function EquipmentItemView:SetEquipTip(tip) 
	self.equip_tip = tip
end

function EquipmentItemView:SetExcluseData(excluse_data)
	self.excluse_data = excluse_data
end

function EquipmentItemView:DeleteOneItem(data)
	if nil == data then return end
	local data_list = self.bag_grid:GetDataList()
	for k, v in pairs(data_list) do
		if data.series == v.series then
			data_list[k] = nil
			break
		end
	end
	self.bag_grid:SetDataList(data_list)
end

function EquipmentItemView:AddOneItem(data)
	local data_list = self.bag_grid:GetDataList()
	for k, v in pairs(data_list) do
		if v == nil then
			v = data
			data = nil
			break
		end
	end
	if nil ~= data then
		table.insert(data_list, data)
	end
	self.bag_grid:SetDataList(data_list)
end

function EquipmentItemView:OnClickQuickFuling()
	local main_eq_data = ViewManager.Instance:GetView(ViewName.Equipment):GetCurSelectFulingMainEquipData()
	if nil == main_eq_data then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.FulingNoMainEquip)
		return
	end
	local page_mate_eq_list = {}
	local page_index = self.bag_grid:GetCurPageIndex()
	local data_list = self.bag_grid:GetDataList()
	local page_count = self.bag_grid:GetPageCellCount()
	for i = 1, page_count do
		local data_index = i + (page_index - 1) * page_count - 1
		page_mate_eq_list[#page_mate_eq_list + 1] = data_list[data_index]
	end

	local equip_data = EquipData.Instance:GetEquipBySeries(main_eq_data.series)
	local is_in_bag = nil ~= equip_data and 0 or 1
	if #page_mate_eq_list < 1 then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.NoEquipToFuling)
		return
	end

	local main_eq_data_cfg = ItemData.Instance:GetItemConfig(main_eq_data.item_id)
	if main_eq_data_cfg then
		self.quick_alert = self.quick_alert or Alert.New()
		self.quick_alert:SetLableString(string.format(Language.Equipment.PageAllEquipToFuling, #page_mate_eq_list, string.format("%06x", main_eq_data_cfg.color), main_eq_data_cfg.name))
		self.quick_alert:SetOkFunc(function()
			for k, v in pairs(page_mate_eq_list) do
				EquipmentCtrl.SentEquipFulingReq(is_in_bag, main_eq_data.series, v.series)
			end
		end)
		self.quick_alert:SetShowCheckBox(false)
		self.quick_alert:Open()
	end
end
