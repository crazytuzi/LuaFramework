ForgeComposeView = ForgeComposeView or BaseClass(BaseRender)
ForgeComposeView.INDEX1 = 0
ForgeComposeView.INDEX2 = -1
function ForgeComposeView:__init()
	self.has_select = self:FindVariable("has_select")
	self.need_flush_accord = true
	self.cur_data = {}
	self.cur_grade = 0
	self.list_index = 1
	self.purpose_equip_id = 0
	self.leftBarList = {}
	self.item_list = {}
	self.item_cell_list = {}
	self.red_point_list = {}
	self.select_solt = ForgeComposeView.INDEX2
	self.stuff_data_list = {}
	self.selcet_bag_list = {}
	self.scroller_data = {}
	self.index_select_list = {}

	self.compose_effect = self:FindObj("ComposeEffect")
	self.show_compose_effect = self:FindVariable("show_compose_effect")
	self.show_compose_effect:SetValue(false)

	self.effect_obj = nil
	self.is_load_effect = false

	self:InitRedEquipList()
	self:InitOneEquipView()
	self:InitLeftAccordion()
	self:InitScollList()
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

end

function ForgeComposeView:__delete()
	self.select_solt = ForgeComposeView.INDEX2
	self.need_flush_accord = true
	for i = 1, 3 do
		self.stuff_data_list[i] = {}
	end
	for k,v in pairs(self.stuff_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end

	if self.effect_obj then
		GameObject.Destroy(self.effect_obj)
		self.effect_obj = nil
	end
	self.is_load_effect = nil
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function ForgeComposeView:OnItemDataChange(item_id, index, reason, put_reason, old_num, new_num)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and item_cfg.color == 6 and new_num > old_num and put_reason == PUT_REASON_TYPE.PUT_REASON_COLOR_EQUIPMENT_COMPOSE then
		self:AfterComposeResult()
	end
end

function ForgeComposeView:InitLeftAccordion()
	for i = 1, 1 do
		self.leftBarList[i] = {}
		self.leftBarList[i].select_btn = self:FindObj("select_btn_" .. i)
		self.leftBarList[i].list = self:FindObj("list_" .. i)
	end
	for i = 1, 1 do
		self:LoadCell(i)
	end
end

function ForgeComposeView:LoadCell(index)
	local compose_item_list = ForgeData.Instance:GetColorComposeCfg()
	PrefabPool.Instance:Load(AssetID("uis/views/forgeview_prefab", "ItemType"), function (prefab)
		if nil == prefab then
			return
		end
		for i=1, #compose_item_list do
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.leftBarList[index].list.transform, false)
			obj:GetComponent("Toggle").group = self.leftBarList[index].list.toggle_group
			local item_cell = ForgeComposeItem.New(obj)
			item_cell:InitCell(compose_item_list[i], self)
			self.item_list[#self.item_list + 1] = obj_transform
			self.item_cell_list[#self.item_cell_list + 1] = item_cell
			if ForgeComposeView.INDEX1 > 0 then
				if index == 1 and i == ForgeComposeView.INDEX1 then
					if item_cell:IsOn() then
						ForgeComposeView.INDEX1 = 0
					else
						self.cur_data = compose_item_list[i]
						item_cell:SetHighLight()
					end
				end
			elseif index == 1 and i == 1 then
				item_cell:OnItemClick(true)
				item_cell:SetHighLight()
			end
		end
		self:FlushRedPoint()
		PrefabPool.Instance:Free(prefab)
	end)
	self.delaytime = GlobalTimerQuest:AddDelayTimer(function()
	self.leftBarList[self.list_index].select_btn.accordion_element.isOn = true
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	self.delaytime = nil
	end, 0.1)
end

function ForgeComposeView:InitOneEquipView()
	self.stuff_list = {}
	for i= 1, 4 do
		self.stuff_list[i] = StuffCell.New(self:FindObj("stuff_cell_" .. i))
		self.stuff_list[i]:SetParentView(self)
		if i < 4 then
			self.stuff_data_list[i] = {}
			self.stuff_list[i]:SetData()
		end
	end
	self.icon_equip = self:FindVariable("icon_compose_equip")
	self.equip_grade = self:FindVariable("grade_compose_equip")
	self.succ_rate_txt = self:FindVariable("succ_rate")
	self.stuff_num = self:FindVariable("stuff_num")
	self.is_show_lock = self:FindVariable("IsShowLock")
	self.is_show_bind_lock = self:FindVariable("is_show_bind_lock")
	self:ListenEvent("OnClickCompose",BindTool.Bind(self.OnClickCompose, self))
	self:ListenEvent("OnClickOneKeyAdd",BindTool.Bind(self.OnClickOneKeyAdd, self))
	self:ListenEvent("CloseEquipBagList",BindTool.Bind(self.CloseEquipBagList, self))
	self:ListenEvent("OpenEquipDetail",BindTool.Bind(self.OpenEquipDetail, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
end

function ForgeComposeView:InitRedEquipList()
	self.pink_equip_remind = self:FindVariable("pink_equip_remind")
	self.name_list = {}
	self.red_equip_list = {}
	self.red_point_list = {}
	self.icon_list = {}
	for i = 1, 8 do
		self.name_list[i] = self:FindVariable("equip_name_" .. i)
		self.red_equip_list[i] = self:FindObj("red_equip_" .. i)
		self.red_point_list[i] = self:FindVariable("red_point_" .. i)
		self.icon_list[i] = self:FindVariable("icon_" .. i)
		self:ListenEvent("OnClickRed" .. i ,BindTool.Bind(self.OnClickRedEquip, self, i))
	end
end

function ForgeComposeView:InitScollList()
	self.is_show_equip_list = self:FindVariable("IsShowEquipList")
	self.is_show_equip_list:SetValue(false)

	self:ListenEvent("OnClickAddStuff",BindTool.Bind(self.OnClickAddStuff, self))

	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = ListViewDelegate()
	PrefabPool.Instance:Load(AssetID("uis/views/forgeview_prefab", "BagEquipItem"), function (prefab)
		if nil == prefab then
			print(ToColorStr("prefab为空", TEXT_COLOR.RED))
			return
		end
		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		self.scroller.scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)

		PrefabPool.Instance:Free(prefab)
	end)
end

function ForgeComposeView:OnClickAddStuff()
	if next(self.index_select_list) then
		for k,v in pairs(self.index_select_list) do
			for k1,v1 in pairs(self.scroller_data) do
				if v == v1.index then
					for i = 1, 3 do
						if not next(self.stuff_data_list[i]) then
							self.stuff_data_list[i] = v1
							break
						end
					end
				end
			end
		end
	end
	self:CloseEquipBagList()
	self:FlushRightView()
end

--滚动条格子数量
function ForgeComposeView:GetNumberOfCells()
	return #self.scroller_data
end

--滚动条格子大小
function ForgeComposeView:GetCellSize()
	return 110
end

--滚动条刷新
function ForgeComposeView:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)

	data_index = data_index + 1
	local scroller_cell = self.cell_list[cell]
	if nil == scroller_cell then
		self.cell_list[cell] = ComposeScrollerCell.New(cell.gameObject)
		scroller_cell = self.cell_list[cell]
		scroller_cell.mother_view = self
	end
	self.scroller_data[data_index].data_index = data_index
	scroller_cell:SetData(self.scroller_data[data_index])
	return cell
end

function ForgeComposeView:OnClickRedEquip(index)
	self.select_solt = index
	self:FlushRightView()
end

function ForgeComposeView:FlushBtn()
	for i = 1, 1 do
		self.leftBarList[i].select_btn.accordion_element:Refresh()
	end
end

function ForgeComposeView:FlushRightView()
	if self.need_flush_accord then
		self:FlushBtn()
		self.need_flush_accord = false
	end

	if ForgeComposeView.INDEX1 > 0 then
		local item = self.item_cell_list[ForgeComposeView.INDEX1]
		if item then
			if not item:IsOn() then
				self.cur_data = item.data
				item:SetHighLight()
			else
				ForgeComposeView.INDEX1 = 0
			end
		end
	end

	if self.select_solt == -1 then
		self.has_select:SetValue(false)
		self:FlushEquipList()
	else
		self.has_select:SetValue(true)
		self:FlushOneEquipCompose()
	end
	self:FlushRedPoint()
end

function ForgeComposeView:FlushRedPoint()
	-- self.pink_equip_remind:SetValue(RemindManager.Instance:GetRemind(RemindName.ForgeCompose) > 0)
	for k,v in pairs(self.item_cell_list) do
		v:Flush()
	end
end

function ForgeComposeView:FlushOneEquipCompose()
	-- self.show_compose_effect:SetValue(false)
	local select_data = self.cur_data[self.select_solt]
	if select_data == nil then return end
	 self.purpose_equip_id = select_data.cfg.compose_equipment_id
	 local p_icon_id = select_data.item_cfg.icon_id
	self.icon_equip:SetAsset(ResPath.GetItemIcon(p_icon_id))
	self.equip_grade:SetValue(self.cur_data.order)
	for i = 1 , 3 do
		self.stuff_list[i]:SetData(self.stuff_data_list[i])
	end
end

function ForgeComposeView:FlushEquipList()
	for i = 1, #self.cur_data do
		if self.name_list[i] then
			local slot_type =self.cur_data[i].sub_type
			self.name_list[i]:SetValue(Language.EquipNameByType[slot_type])
			local res_id = self.cur_data[i].item_cfg.icon_id
			self.icon_list[i]:SetAsset(ResPath.GetItemIcon(res_id))
			self.red_equip_list[i]:SetActive(true)
			self.scroller_data = ForgeData.Instance:GetBagComposeStuff(self.cur_data[i])

			self.red_point_list[i]:SetValue(ForgeData.Instance:GetOneForgeComposeRemind(self.cur_data.index, i))
		end
	end
	if #self.cur_data == 8 then return end
	for i = #self.cur_data + 1, 8 do
		self.red_equip_list[i]:SetActive(false)
	end
end

function ForgeComposeView:AfterComposeResult()
	for i = 1, 3 do
		self.stuff_data_list[i]  = {}
	end

	self.show_compose_effect:SetValue(true)

	TipsCtrl.Instance:OpenEffectView("effects2/prefab/ui_x/ui_chenggongtongyong_prefab", "UI_ChengGongTongYong", 1.5)
	self:FlushRightView()
end


function ForgeComposeView:OnClickCompose()
	local need_stuff_cfg = ForgeData.Instance:GetComposeNeedStuff(self.cur_data[self.select_solt])
	local req_equip_list = {}
	for k,v in pairs(self.stuff_data_list) do
		if next(v) then
			table.insert(req_equip_list, v.index)
		end
	end
	if #req_equip_list < 3 or not next(req_equip_list)then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.MinStuff)
		return
	end
	ForgeCtrl.Instance:SendColorEquipmentComposeReq(self.purpose_equip_id, req_equip_list)
end

function ForgeComposeView:OnClickOneKeyAdd()
	self.scroller_data = ForgeData.Instance:GetBagComposeStuff(self.cur_data[self.select_solt])
	if next(self.scroller_data) then
		for i=#self.scroller_data,1,-1 do
			for k,v in pairs(self.stuff_data_list) do
				if self.scroller_data[i] and next(v) and self.scroller_data[i].index == v.index then
					table.remove(self.scroller_data, i)
				end
			end
		end
	end

	if next(self.scroller_data) then
		local cell_index = 1
		for k,v in pairs(self.stuff_data_list) do
			if not next(v) and nil ~= self.scroller_data[cell_index] then
				self.stuff_data_list[k] = self.scroller_data[cell_index]
				cell_index = cell_index + 1
			end
		end
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.NoStuff)
	end
	self:FlushRightView()
end

function ForgeComposeView:CloseEquipBagList()
	self.is_show_equip_list:SetValue(false)
	self.index_select_list = {}
end

function ForgeComposeView:OpenEquipDetail()
	TipsCtrl.Instance:OpenItem({item_id = self.purpose_equip_id, param = EquipData.GetPinkEquipParam()})
end

function ForgeComposeView:OnClickHelp()
	local tips_id = 243
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ForgeComposeView:ClearPurposeEquip()
	self.select_solt = ForgeComposeView.INDEX2
	ForgeComposeView.INDEX2 = -1
	for i = 1, 3 do
		self.stuff_data_list[i] = {}
	end
end

function ForgeComposeView:SetCurData(data)
	self.cur_data = data
end

function ForgeComposeView:GetCurData()
	return self.cur_data
end

function ForgeComposeView:GetCurGrade()
	return self.cur_grade
end

function ForgeComposeView:ClickTakeOffEquip(bag_index)
	for k,v in pairs(self.stuff_data_list) do
		if v.index == bag_index then
			self.stuff_data_list[k] = {}
		end
	end
	self:FlushRightView()
end

function ForgeComposeView:OpenBagEquipList()
	self.scroller_data = ForgeData.Instance:GetBagComposeStuff(self.cur_data[self.select_solt])
	if next(self.scroller_data) then
		for i=#self.scroller_data,1,-1 do
			for k,v in pairs(self.stuff_data_list) do
				if self.scroller_data[i] and next(v) and self.scroller_data[i].index == v.index then
					table.remove(self.scroller_data, i)
				end
			end
		end
	end
	if next(self.scroller_data) then
		self.is_show_equip_list:SetValue(true)
		self.scroller.scroller:ReloadData(0)
	else
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.NoStuff)

	end
end

function ForgeComposeView:SetSelcetEquipStuff(state, list_cell_index)
	if state then
		self.index_select_list[#self.index_select_list + 1] = list_cell_index
	else
		for k,v in pairs(self.index_select_list) do
			if v == list_cell_index then
				table.remove(self.index_select_list, k)
			end
		end
	end
end

function ForgeComposeView:GetSelectList()
	return self.index_select_list
end

function ForgeComposeView:GetStuffDataLength()
	local length = 0
	for k,v in pairs(self.stuff_data_list) do
		if next(v)  then
			length = length + 1
		end
	end
	return length
end
---------------------------------------------------------------------------------
--- ForgeComposeItem
---------------------------------------------------------------------------------

ForgeComposeItem = ForgeComposeItem or BaseClass(BaseCell)
function ForgeComposeItem:__init(instance)
	self.star = 0
	self.grade = 0
	self.mother_view = nil
	self.name = self:FindVariable("Name")
	self.is_remind = self:FindVariable("IsRemind")
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
end

function ForgeComposeItem:__delete()
	self.mother_view = nil
end

function ForgeComposeItem:InitCell(data, mother_view)
	self.mother_view = mother_view
	self.data = data
	local des = string.format(Language.Forge.GradePinkEquip, CommonDataManager.GetDaXie(self.data.order))
	self.name:SetValue(des)
	self:SetHighLight()
end

function ForgeComposeItem:OnFlush()
	self.is_remind:SetValue(ForgeData.Instance:GetOneForgeComposeRemind(self.data.index))
end

function ForgeComposeItem:IsOn()
	return self.root_node.toggle.isOn
end

function ForgeComposeItem:SetHighLight()
	if self.mother_view ~= nil then
		local cur_data = self.mother_view:GetCurData()
		if cur_data.order == self.data.order then
			self.root_node.toggle.isOn = true
		else
			self.root_node.toggle.isOn = false
		end
	end
end

function ForgeComposeItem:OnItemClick(is_click)
	if is_click and self.mother_view then
		self.mother_view:SetCurData(self.data)
		self.mother_view:ClearPurposeEquip()
		self.mother_view:FlushRightView()
	end
end

---------------------------------------------------------------------------------
--- StuffCell
---------------------------------------------------------------------------------
StuffCell = StuffCell or BaseClass(BaseCell)
function StuffCell:__init()
	self.mother_view = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickTakeOffEquip, self))

	--可镶嵌加号按钮
	self.btn_plus = self:FindObj("PlusButton")
	self.btn_plus.button:AddClickListener(BindTool.Bind(self.PlusClick, self))
end

function StuffCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.mother_view = nil
end

function StuffCell:ShowEmpty()
	self.item_cell:SetData()
	self.btn_plus:SetActive(true)
end

function StuffCell:OnFlush()
	if self.data == nil or (not next(self.data)) or self.data.item_id == nil then
		self:ShowEmpty()
		return
	end
	self.btn_plus:SetActive(false)
	self.item_cell:SetData(self.data)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickTakeOffEquip, self))
end

function StuffCell:PlusClick()
	if self.mother_view then
		self.mother_view:OpenBagEquipList()
	end
end

function StuffCell:ClickTakeOffEquip()
	if nil ~= self.mother_view then
		self.mother_view:ClickTakeOffEquip(self.data.index)
	end
	self.data = nil
end

function StuffCell:SetParentView(view)
	self.mother_view = view
end

-----------------------------------------
--可用宝石滚动条格子
ComposeScrollerCell = ComposeScrollerCell or BaseClass(BaseCell)

function ComposeScrollerCell:__init()
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ListenClick(function()end)
	self.equip_name = self:FindVariable("Name")
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClick, self))

end

function ComposeScrollerCell:__delete()
	self.item_cell:DeleteMe()
	self.mother_view = nil
end

function ComposeScrollerCell:OnFlush()
	if nil == self.data then return end

	self.item_cell:SetData(self.data)

	self.equip_name:SetValue(ItemData.Instance:GetItemName(self.data.item_id))
	local select_list = self.mother_view:GetSelectList()
	self.root_node.toggle.isOn = false
	if not next(select_list) then return end
	for k,v in pairs(select_list) do
		if self.data.index == v then
			self.root_node.toggle.isOn = false
			self.root_node.toggle.isOn = true
		end
	end
end

function ComposeScrollerCell:OnClick(state)
	if self.mother_view then
		if state then
			local select_list = self.mother_view:GetSelectList()
			local has_select_length = self.mother_view:GetStuffDataLength()
			if (#select_list + has_select_length) >= 3 then
				SysMsgCtrl.Instance:ErrorRemind(Language.Forge.MaxStuff)
				self:Flush()
				return
			end
		end
		self.mother_view:SetSelcetEquipStuff(state, self.data.index)
	end
end