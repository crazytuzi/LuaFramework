NewSelectEquipView = NewSelectEquipView or BaseClass(BaseView)

local COLUMN = 4
local ROW = 5
function NewSelectEquipView:__init()
	self.ui_config = {"uis/views/composeview_prefab", "SelectEquipView"}
	self.select_index = 0
	self.item_cell_click_callback = BindTool.Bind(self.ItemCellClick, self)
end

function NewSelectEquipView:__delete()
end

function NewSelectEquipView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil

	self.list_view = nil
	self.toggle_1 = nil
end

function NewSelectEquipView:LoadCallBack()
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.toggle_1 = self:FindObj("Toggle_1")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close, self))
end

function NewSelectEquipView:GetNumberOfCells()
	--写死8页
	return 8
end

function NewSelectEquipView:RefreshCell(cell, data_index)
	local group = self.cell_list[cell]
	if nil == group then
		group = NewSelectEquipItemGroup.New(cell.gameObject)
		group:SetToggleGroup(self.list_view.toggle_group)
		group:SetClickCallBack(self.item_cell_click_callback)
		self.cell_list[cell] = group
	end

	for i = 1, ROW * COLUMN do
		local index = data_index * COLUMN * ROW + i
		group:SetIndex(i, index)
		group:SetToggleIsOn(i, self.select_index == index)
		group:SetData(i, self.list_data[index])
	end
end

function NewSelectEquipView:ItemCellClick(cell)
	if nil == cell then
		return
	end

	local data = cell:GetData()
	if nil == next(data) then
		return
	end

	self.select_index = cell:GetIndex()

	if self.callback then
		self.callback(data)
	end
	self:Close()
end

function NewSelectEquipView:SetData(data)
	self.list_data = data or {}
end

function NewSelectEquipView:SetCallBack(callback)
	self.callback = callback
end

function NewSelectEquipView:OpenCallBack()
	self.select_index = 0
	self.list_view.scroller:ReloadData(0)
	self.toggle_1.toggle.isOn = true
end

function NewSelectEquipView:CloseCallBack()
	self.callback = nil
	self.list_data = {}
end


NewSelectEquipItemGroup = NewSelectEquipItemGroup or BaseClass(BaseRender)
function NewSelectEquipItemGroup:__init()
	self.item_list = {}
	for i = 1, ROW * COLUMN do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:ListenClick(BindTool.Bind(self.OnClick, self, item))
		table.insert(self.item_list, item)
	end
end

function NewSelectEquipItemGroup:__delete()
	for _, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = nil
end

function NewSelectEquipItemGroup:SetClickCallBack(callback)
	self.click_callback = callback
end

function NewSelectEquipItemGroup:OnClick(cell)
	if self.click_callback then
		self.click_callback(cell)
	end
end

function NewSelectEquipItemGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function NewSelectEquipItemGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function NewSelectEquipItemGroup:SetToggleIsOn(i, is_on)
	self.item_list[i]:SetToggle(is_on)
end

function NewSelectEquipItemGroup:SetToggleGroup(group)
	for _, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end