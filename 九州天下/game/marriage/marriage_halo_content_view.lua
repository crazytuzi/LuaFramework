MarriageHaloContentView = MarriageHaloContentView or BaseClass(BaseRender)

function MarriageHaloContentView:__init()
	self.select_spirit_index = 1
	self.select_halo_index = 1

	self.spirit_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		self.spirit_list[count] = HaloSpiritCell.New(obj)
		self.spirit_list[count].mother_view = self
		self.spirit_list[count].toggle.group = obj_group.toggle_group
		count = count + 1
	end
	self:InitScroller()

	self.power = self:FindVariable("Power")
	self.item_need = self:FindVariable("ItemNeed")
	self.process_value = self:FindVariable("ProcessValue")
	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.is_halo_active = self:FindVariable("IsHaloActive")
	self.is_spirit_active = self:FindVariable("IsSpiritActive")
	self.is_show_total_attr = self:FindVariable("IsShowTotalAttr")
	self.total_attr = self:FindVariable("TotalAttr")
	self.total_power = self:FindVariable("TotalPower")
	self.process_text = self:FindVariable("ProcessText")
	self.is_wearing = self:FindVariable("IsWearing")
	self.is_show_help = self:FindVariable("IsShowHelp")

	self:ListenEvent("OpenHelp", BindTool.Bind(self.OpenHelp, self))
	self:ListenEvent("TotoalAttrClick", BindTool.Bind(self.TotoalAttrClick, self))
	self:ListenEvent("ActiveClick", BindTool.Bind(self.ActiveClick, self))
	self:ListenEvent("UseClick", BindTool.Bind(self.UseClick, self))
	self:ListenEvent("CloseTotoalAttr", BindTool.Bind(self.CloseTotoalAttr, self))

	self.display = self:FindObj("DisPlay")
	self.model = RoleModel.New()
	self.model:SetDisplay(self.display.ui3d_display)
end

function MarriageHaloContentView:__delete()
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	for k, v in ipairs(self.spirit_list) do
		v:DeleteMe()
	end
	self.spirit_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MarriageHaloContentView:ChangeDisPlay(index)
	self.display.ui3d_display:ResetRotation()
	self.model:SetMainAsset(ResPath.GetHaloModel(index + 4))
end

function MarriageHaloContentView:TotoalAttrClick()
	local attrs = MarriageData.Instance:GetHaloTotalAttr()
	TipsCtrl.Instance:ShowAttrView(attrs)
end

function MarriageHaloContentView:OpenHelp()
	local tips_id = 71 -- 光环帮助
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MarriageHaloContentView:CloseTotoalAttr()
	self.is_show_total_attr:SetValue(false)
end
function MarriageHaloContentView:ActiveClick()
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	if main_vo.lover_uid <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.NotLoverDes)
		return
	end

	--判断道具是否足够
	local id = self.spirit_data[self.select_spirit_index].stuff_id
	local had_num = ItemData.Instance:GetItemNumInBagById(id)
	if had_num <= 0 then
		TipsCtrl.Instance:ShowItemGetWayView(id)
		return
	end

	MarriageCtrl.Instance:SendUpgradeSpirit(1, self.select_halo_index, self.select_spirit_index - 1)
end
function MarriageHaloContentView:UseClick()
	MarriageCtrl.Instance:SendUpgradeSpirit(2, self.select_halo_index)
end

function MarriageHaloContentView:FlushSpirit()
	self.spirit_data = MarriageData.Instance:GetHaloSpiritData(self.select_halo_index)
	for k,v in pairs(self.spirit_list) do
		v:SetData(self.spirit_data[k])
	end
end

function MarriageHaloContentView:InitScroller()
	self.cell_list = {}
	self.scroller = self:FindObj("Scroller")

	self.list_view_delegate = ListViewDelegate()

	PrefabPool.Instance:Load(AssetID("uis/views/marriageview_prefab", "MarryHaloItem"), function (prefab)
		if nil == prefab then
			return
		end

		self.enhanced_cell_type = prefab:GetComponent(typeof(EnhancedUI.EnhancedScroller.EnhancedScrollerCellView))
		PrefabPool.Instance:Free(prefab)

		self.scroller.scroller.Delegate = self.list_view_delegate
		self.list_view_delegate.numberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		self.list_view_delegate.cellViewSizeDel = BindTool.Bind(self.GetCellSize, self)
		self.list_view_delegate.cellViewDel = BindTool.Bind(self.GetCellView, self)
	end)
end

--滚动条数量
function MarriageHaloContentView:GetNumberOfCells()
	return #(MarriageData.Instance:GetHaloScrollerData())
end

--滚动条大小
function MarriageHaloContentView:GetCellSize()
	return 98
end

--滚动条刷新
function MarriageHaloContentView:GetCellView(scroller, data_index, cell_index)
	local cell = scroller:GetCellView(self.enhanced_cell_type)

	data_index = data_index + 1
	local cell_data = MarriageData.Instance:GetHaloScrollerData()

	if nil == self.cell_list[cell] then
		self.cell_list[cell] = HaloScrollerItem.New(cell.gameObject)
		self.cell_list[cell].mother_view = self
		self.cell_list[cell].toggle.group = self.scroller.toggle_group
	end
	cell_data[data_index].data_index = data_index
	self.cell_list[cell]:SetData(cell_data[data_index])
	return cell
end

function MarriageHaloContentView:HaloChange()
	local is_halo_active = MarriageData.Instance:GetHaloIsAvtive(self.select_halo_index)
	self.is_halo_active:SetValue(is_halo_active)
	local is_wearing = MarriageData.Instance:GetHaloIsWearing(self.select_halo_index)
	self.is_wearing:SetValue(is_wearing)
	self.scroller.scroller:ReloadData(0)
	self.select_spirit_index = -11
	local data = MarriageData.Instance:GetHaloSpiritData(self.select_halo_index)
	for k,v in pairs(data) do
		if not v.is_active then
			if v.can_upgrade then
				self.select_spirit_index = k
				break
			end
		end
	end
	if self.select_spirit_index == -11 then
		for k,v in pairs(data) do
			if not v.is_active then
				self.select_spirit_index = k
				break
			end
		end
	end
	self:FlushSpirit()
end

function MarriageHaloContentView:OnSpiritClick(index)
	self.select_spirit_index = index

	local is_halo_active = MarriageData.Instance:GetHaloIsAvtive(self.select_halo_index)
	self.is_halo_active:SetValue(is_halo_active)
	local is_wearing = MarriageData.Instance:GetHaloIsWearing(self.select_halo_index)
	self.is_wearing:SetValue(is_wearing)
	if is_halo_active then
		return
	end
	local is_spirit_active = MarriageData.Instance:GetSpiritIsAvtive(self.select_halo_index, self.select_spirit_index)
	self.is_spirit_active:SetValue(is_spirit_active)
	if is_spirit_active then
		return
	end
	self.power:SetValue(MarriageData.Instance:GetSpiritPower(self.select_halo_index ,index))
	local id = self.spirit_data[index].stuff_id
	local had_num = ItemData.Instance:GetItemNumInBagById(id)
	self.item_need:SetValue(had_num)

	local need_num = self.spirit_data[index].stuff_count
	local used_num = MarriageData.Instance:GetSpiritActiveUseNum(self.select_halo_index, index - 1) or 0

	self.process_value:SetValue(used_num/need_num)

	use_num_text = ToColorStr(used_num, TEXT_COLOR.RED)
	local need_num_text = ToColorStr(need_num, TEXT_COLOR.GREEN)
	self.process_text:SetValue(use_num_text.." / "..need_num_text)

	local data = {}
	data.item_id = id
	self.item_cell:SetData(data)
end

function MarriageHaloContentView:OnScrollerItemClick(halo_type)
	self.select_halo_index = halo_type
	self.select_spirit_index = -10
	local data = MarriageData.Instance:GetHaloSpiritData(self.select_halo_index)
	for k,v in pairs(data) do
		if not v.is_active then
			if v.can_upgrade then
				self.select_spirit_index = k
				break
			end
		end
	end
	if self.select_spirit_index == -10 then
		for k,v in pairs(data) do
			if not v.is_active then
				self.select_spirit_index = k
				break
			end
		end
	end
	if self.select_spirit_index == -10 then
		local is_halo_active = MarriageData.Instance:GetHaloIsAvtive(self.select_halo_index)
		self.is_halo_active:SetValue(is_halo_active)
		local is_wearing = MarriageData.Instance:GetHaloIsWearing(self.select_halo_index)
		self.is_wearing:SetValue(is_wearing)
	end
	self:FlushSpirit()
	self:ChangeDisPlay(halo_type)
end

--精灵格子-------------------------------------
HaloSpiritCell = HaloSpiritCell or BaseClass(BaseCell)
function HaloSpiritCell:__init()
	self.is_active = self:FindVariable("IsActive")
	self.icon = self:FindVariable("Icon")

	self.toggle = self.root_node.toggle
	self.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self))
	self:ListenEvent("SpiritClick", BindTool.Bind(self.SpiritClick,self))
end

function HaloSpiritCell:__delete()
	self.mother_view = nil
end

function HaloSpiritCell:OnFlush()
	if self.mother_view.select_spirit_index == (self.data.icon_index + 1) then
		self.toggle.isOn = true
	else
		self.toggle.isOn = false
	end
	self.is_active:SetValue(self.data.is_active)
	self.icon:SetAsset(ResPath.GetHaloSpirit(self.data.icon_index))
end

function HaloSpiritCell:OnToggleChange(is_on)
	if is_on then
		self.mother_view:OnSpiritClick(self.data.icon_index + 1)
	end
end

function HaloSpiritCell:SpiritClick()
	self.toggle.isOn = true
end

--滚动条格子-------------------------------------
HaloScrollerItem = HaloScrollerItem or BaseClass(BaseCell)
function HaloScrollerItem:__init()
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.is_active = self:FindVariable("IsActive")
	self.is_wearing = self:FindVariable("IsWearing")
	self.toggle = self.root_node.toggle
	self.toggle:AddValueChangedListener(BindTool.Bind(self.OnToggleChange,self))
end

function HaloScrollerItem:__delete()
end

function HaloScrollerItem:OnFlush()
	if self.mother_view.select_halo_index == self.data.halo_type then
		self.toggle.isOn = true
	else
		self.toggle.isOn = false
	end
	self.is_wearing:SetValue(self.data.is_wearing)
	self.name:SetValue(self.data.halo_name)
	self.level:SetValue(self.data.level)
	self.is_active:SetValue(self.data.is_active)
end

function HaloScrollerItem:OnToggleChange(is_on)
	if is_on then
		self.mother_view:OnScrollerItemClick(self.data.halo_type)
	end
end
