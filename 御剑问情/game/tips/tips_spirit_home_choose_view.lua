TipsSpiritHomeChooseView = TipsSpiritHomeChooseView or BaseClass(BaseView)

local PAGE_CELL = 2

function TipsSpiritHomeChooseView:__init()
	self.ui_config = {"uis/views/tips/spirithometip_prefab","SpiritHomeTipView"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false

	self.select_index = nil
	self.select_cell = nil
	self.last_select = nil
	self.cell_list = {}
	self.now_page = 0
	self.max_page = 0
	--self.now_page = 0
end

function TipsSpiritHomeChooseView:__delete()
end

function TipsSpiritHomeChooseView:ReleaseCallBack()
	self.select_index = nil
	self.last_select = nil
	self.select_cell = nil
	self.now_page = 0
	self.max_page = 0

	for k,v in pairs(self.cell_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	self.list_view = nil
	self.page_str = nil
end

function TipsSpiritHomeChooseView:LoadCallBack()
	self.list_view = self:FindObj("ListView")
	if self.list_view ~= nil then
		local list_delegate = self.list_view.page_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
		self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	end

	self.page_str = self:FindVariable("PageStr")
	self:ListenEvent("Close", BindTool.Bind(self.OnClickView, self))
end

-- function TipsSpiritHomeChooseView:OpenCallBack()
-- end

function TipsSpiritHomeChooseView:CloseCallBack()
end

function TipsSpiritHomeChooseView:OnClickView()
	self:Close()
end

function TipsSpiritHomeChooseView:GetNumberOfCells()
	return 4
end

function TipsSpiritHomeChooseView:OpenCallBack()
	--self:SetPageData()

	if self.list_view ~= nil and self.list_view.list_view.isActiveAndEnabled then
		self.list_view.list_page_scroll2:SetPageCount(2)
		self.max_page = 2
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

-- function TipsSpiritHomeChooseView:SetPageData()
-- 	--self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
-- 	self.list_view.list_page_scroll2:SetPageCount(4)
-- end

function TipsSpiritHomeChooseView:OnValueChanged()
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page and self.page_str ~= nil then
		self.page_str:SetValue(now_page .. "/" .. self.max_page)
		self.now_page = now_page
	end
end

function TipsSpiritHomeChooseView:RefreshCell(data_index, cell)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = SpiritHomeTipGroup.New(cell)
		self.cell_list[cell] = group_cell
		--group_cell:SetToggleGroup(self.list_view.toggle_group)
	end
	local data = {
		{spirit_name = "小坑爹" .. data_index,},
		{spirit_name = "小坑爹" .. data_index,},
		{spirit_name = "小坑爹" .. data_index,},
		{spirit_name = "小坑爹" .. data_index,},
	}

	if data_index == 1 then
		data.is_select = true
	end	

	-- for i = 1, PAGE_CELL do
	--group_cell:SetToggleChangeCallBack(i, BindTool.Bind(self.OnSelectCallBack, self))
		group_cell:SetIndex(data_index)
		group_cell:SetData(data)
		group_cell:ResetSelect(self.select_index, self.select_cell)
	--end
end
function TipsSpiritHomeChooseView:OnSelectCallBack()
end

function TipsSpiritHomeChooseView:SetSelectIndex(index, cell_index)
	if index then
		if self.select_index == nil then
			self.select_index = index
			self.select_cell = cell_index
		else
			local need_flush = self.select_index ~= index
			self.select_index = index
			self.select_cell = cell_index		
			if need_flush then
				--self.list_view.list_view:Reload()
				for k,v in pairs(self.cell_list) do
					if v ~= nil then
						if v:GetIndex() ~= self.select_index then
							v:ResetSelect(nil, nil)
						else
							v:ResetSelect(self.select_index, self.select_cell)
						end
					end
				end
			end
		end
		--self:FlushSelect()
	end
end

function TipsSpiritHomeChooseView:GetSelectIndex()
	return self.select_index
end

function TipsSpiritHomeChooseView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if "all" == k then
			self:FlushList()
		end
	end
end


-----------------------------------------------------------------------------
SpiritHomeTipGroup = SpiritHomeTipGroup or BaseClass(BaseRender)

function SpiritHomeTipGroup:__init()
	self.is_select = false

	self.item_group = {}
	for i = 1, 4 do
		self.item_group[i] = {}
		self.item_group[i].obj = self:FindObj("Item" .. i)
		self.item_group[i].cell = SpiritHomeTipCell.New(self.item_group[i].obj)
		self.item_group[i].show = self:FindVariable("ShowItem" .. i)
		--self.item_group[i].cell:SetToggleChangeCallBack(call_back)
	end

	for i = 1, 4 do
		self:ListenEvent("ClickItem" .. i, BindTool.Bind2(self.OnClickItem, self, i))
	end
end

function SpiritHomeTipGroup:__delete()
	self.is_select = false

	if self.item_group ~= nil then
		for k,v in pairs(self.item_group) do
			if v ~= nil and v.cell ~= nil then
				v.cell:DeleteMe()
				v.obj = nil
				v.show = nil
			end
		end

		self.item_group = {}
	end
end

function SpiritHomeTipGroup:OnClickItem(index)
	self:ResetSelect(self.index, index)
	self.is_select = not self.is_select
	if self.index ~= nil then
		TipsCtrl.Instance:SetSpiritHomeChooseSelect(self.index, index)
	end
end

function SpiritHomeTipGroup:SetIndex(index)
	self.index = index
end

function SpiritHomeTipGroup:GetIndex()
	return self.index
end

function SpiritHomeTipGroup:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomeTipGroup:FlushAll(data)
end

function SpiritHomeTipGroup:OnFlush()
	if self.data == nil then return end
	if self.item_group ~= nil then
		for k,v in pairs(self.item_group) do
			if v ~= nil and v.cell ~= nil then
				local is_show = false
				if self.data[k] ~= nil and next(self.data[k]) ~= nil then
					v.cell:SetData(self.data[k])
					is_show = true
				end
			end
		end
	end
end

-- function SpiritHomeTipGroup:SetToggleGroup(toggle_group)
-- 	--self.root_node.toggle.group = toggle_group
-- end

-- function SpiritHomeTipGroup:SetSelctState(state)
-- 	self.root_node.toggle.isOn = state
-- 	self.is_select = state
-- 	if not self.is_select then
-- 		self:ShowSelect(nil, true)
-- 	end
-- end

-- function SpiritHomeTipGroup:SetToggleChangeCallBack(i, call_back)
-- 	self.item_group[i]:SetToggleChangeCallBack(call_back)
-- end

function SpiritHomeTipGroup:ResetSelect(value, cell_index)
	-- if self.is_select and self.index == value then
	-- 	return
	-- end
	-- self.is_select = self.index == value


	if self.item_group ~= nil then
		for k,v in pairs(self.item_group) do
			if v ~= nil and v.cell ~= nil then
				if value == nil or cell_index == nil then
					v.cell:ResetSelect(false)
				else
					v.cell:ResetSelect(self.index == value and k == cell_index)
				end
			end
		end
	end
end

-----------------------------------------------------------------------------
SpiritHomeTipCell = SpiritHomeTipCell or BaseClass(BaseRender)

function SpiritHomeTipCell:__init()
	self.is_select = false
	self.name = self:FindVariable("Name")

	local item = self:FindObj("Item")
	self.item_cell = ItemCell.New(self.item)

	self.is_select = false
end

function SpiritHomeTipCell:__delete()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.is_select = false
	self.name = nil
end

function SpiritHomeTipCell:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomeTipCell:Flush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.name ~= nil then
		self.name:SetValue(self.data.spirit_name or "")
	end

	--self.select_toggle.isOn = self.data.is_select
	--self.root_node.toggle.isOn = self.is_select
end

function SpiritHomeTipCell:ChangeSelect(is_select)
	-- self.root_node.toggle.isOn = is_select
	-- self.is_select = is_select
end

function SpiritHomeTipCell:OnRootNodeToggleChange(is_on)
	--self.data.is_select = is_on
	--self.select_toggle.isOn = is_on
	self.is_select = is_on
	if nil ~= self.call_back then
		self.call_back()
	end
end

function SpiritHomeTipCell:ResetSelect(value)
	--self.is_select = value
	self.root_node.toggle.isOn = value
end