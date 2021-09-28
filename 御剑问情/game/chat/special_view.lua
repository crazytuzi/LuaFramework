SpecialView = SpecialView or BaseClass(BaseRender)

local MAX_NUM = 21
local ROW = 3
local COLUMN = 7

function SpecialView:__init()
	-- 获取组件
	self.item_cell = self:FindObj("ItemCell")
	self.icon_list = self:FindObj("IconList")

	self:CreateIconList()

	-- 获取变量
	self.progress = self:FindVariable("Progress")
	self.lev = self:FindVariable("Lev")
	self.max_lev = self:FindVariable("MaxLev")
	self.capability = self:FindVariable("Capability")

	-- 监听
	self:ListenEvent("ClickAct", BindTool.Bind(self.OnClickAct, self))
end

function SpecialView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.select_index = nil
end

function SpecialView:CreateIconList()
	self.cell_list = {}
	self.cell_data = {}
	local list_delegate = self.icon_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function SpecialView:GetNumberOfCells()
	return MAX_NUM / ROW
end

function SpecialView:RefreshCell(cell, data_index)
	local group = self.cell_list[cell]
	if group == nil then
		group = SpecialIconGroup.New(cell.gameObject)
		group:SetToggleGroup(self.icon_list.toggle_group)
		group.special_view = self
		self.cell_list[cell] = group
	end

	local page = math.floor(data_index / COLUMN)
	local column = data_index - page * COLUMN
	local grid_count = COLUMN * ROW
	for i = 1, ROW do
		local index = (i - 1) * COLUMN  + column + (page * grid_count)

		group:SetData(i, self.cell_data[index + 1])
		group:SetIndex(i, index)
	end
end

function SpecialView:OnClickAct()

end

function SpecialView:FlushSpecialView()
	--if self.select_index then
	--end
end

function SpecialView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function SpecialView:GetSelectIndex()
	return self.select_index or 0
end


SpecialIconGroup = SpecialIconGroup or BaseClass(BaseRender)

function SpecialIconGroup:__init(obj, show_state)
	self.cells = {
		SpecialCell.New(self:FindObj("Icon1")),
		SpecialCell.New(self:FindObj("Icon2")),
		SpecialCell.New(self:FindObj("Icon3")),
	}
	for _, v in ipairs(self.cells) do
		v.group_view = self
	end
end

function SpecialIconGroup:__delete()
	for _, v in ipairs(self.cells) do
		if v then
			v:DeleteMe()
		end
	end
	self.cells = {}
end

function SpecialIconGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function SpecialIconGroup:SetIndex(i, index)
	self.cells[i]:SetIndex(index)
end

function SpecialIconGroup:SetToggleGroup(group)
	for _, v in ipairs(self.cells) do
		v:SetToggleGroup(group)
	end
end

function SpecialIconGroup:SetSelectIndex(index)
	self.special_view:SetSelectIndex(index)
end

function SpecialIconGroup:GetSelectIndex()
	return self.special_view:GetSelectIndex()
end

function SpecialIconGroup:FlushSpecialView()
	self.special_view:FlushSpecialView()
end


--表情
SpecialCell = SpecialCell or BaseClass(BaseRender)

function SpecialCell:__init()
	self.lev = self:FindVariable("Lev")
	self.max_lev = self:FindVariable("MaxLev")

	self:ListenEvent("Click", BindTool.Bind(self.ClickIcon, self))
end

function SpecialCell:__delete()

end

function SpecialCell:SetIndex(index)
	self.index = index
end

function SpecialCell:SetData(data)
	if not data then return end
	self.data = data

	-- 刷新选中特效
	local select_index = self.group_view:GetSelectIndex()
	if self.root_node.toggle.isOn and select_index ~= self.index + 1 then
		self.root_node.toggle.isOn = false
	elseif self.root_node.toggle.isOn == false and select_index == self.index + 1 then
		self.root_node.toggle.isOn = true
	end
end

function SpecialCell:ClickIcon()
	print("点击了===", self.index + 1)
	-- if not self.data then return end
	self.root_node.toggle.isOn = true
	self.group_view:SetSelectIndex(self.index + 1)
	self.group_view:FlushSpecialView()
end

function SpecialCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end