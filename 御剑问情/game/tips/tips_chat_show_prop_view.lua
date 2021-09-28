------------------------------------------------------------
--聊天中弹出的道具展示
------------------------------------------------------------
TipsShowProView = TipsShowProView or BaseClass(BaseView)

local MAX_CELL_NUM = 180
local PRO_COLUMN = 5
local PRO_ROW = 4

local SHOW_EQUIP = 1
local SHOW_PROP = 2

function TipsShowProView:__init()
	self.ui_config = {"uis/views/tips/chattips_prefab", "ShowView"}
	self.equip_cells = {}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.equip_group_cell_list = {}

	self.show_state = SHOW_PROP
	self.play_audio = true
end

function TipsShowProView:__delete()
end

function TipsShowProView:ReleaseCallBack()
	self.equip_cells = {}

	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	for k, v in pairs(self.equip_group_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.equip_group_cell_list = {}

	-- 清理变量和对象
	self.show_equip_cell = nil
	self.show_page = nil
	self.list_view = nil
	self.pro_button = nil
end

function TipsShowProView:LoadCallBack()
	self.select_index = -1			-- 记录已选择格子位置

	self:ListenEvent("OnClickProButton",
		BindTool.Bind(self.OnClickProButton, self))
	self:ListenEvent("OnClickEquipButton",
		BindTool.Bind(self.OnClickEquipButton, self))
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))

	self.show_equip_cell = self:FindVariable("IsShowEquip")
	self.show_page = self:FindVariable("IsShowPage")

	self.list_view = self:FindObj("ListView")
	self.pro_button = self:FindObj("ProButton")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	for i = 1, PRO_COLUMN do
		self.equip_cells[i] = self:FindObj("EquipPropObj"..i)
	end
end

function TipsShowProView:GetNumberOfCells()
	return MAX_CELL_NUM / PRO_ROW
end

function TipsShowProView:OpenCallBack()
	self:OnClickProButton()
end

function TipsShowProView:CloseCallBack()
	self.select_index = -1
end

function TipsShowProView:RefreshCell(cell, data_index)
	-- 构造Cell对象
	local group = self.cell_list[cell]
	if group == nil then
		group = ChatShowProViewItem.New(cell.gameObject)
		group.tips_view = self
		group:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cell] = group
	end

	local page = math.floor(data_index / PRO_COLUMN)
	local column = data_index - page * PRO_COLUMN
	local grid_count = PRO_COLUMN * PRO_ROW

	for i = 1, PRO_ROW do
		local index = (i - 1) * PRO_COLUMN  + column + (page * grid_count)
		local data = nil
		data = ItemData.Instance:GetGridData(index)
		data = data or {}
		data.locked = index >= ItemData.Instance:GetMaxKnapsackValidNum()
		if nil == data.index then
			data.index = index
		end
		group:SetData(i, data)

		group:SetInteractable(i, true)
		if not data.item_id or data.item_id == 0 then
			group:SetInteractable(i, false)
		end

		group:ListenClick(i, BindTool.Bind(self.HandleItemOnClick, self, data, group, i))
	end
end

function TipsShowProView:HandleItemOnClick(data, group, group_index)
	if self.select_index ~= data.index then
		self.select_index = data.index
	end
	if data.item_id then
		ChatCtrl.Instance:SetChatViewData(data)
		ChatCtrl.Instance:SetGuildViewData(data)
		self:Close()
	end
end

function TipsShowProView:OnClickProButton()
	self.show_state = SHOW_PROP
	self.list_view:SetActive(true)
	self.show_page:SetValue(true)
	self.show_equip_cell:SetValue(false)
	self:FlushBagView()
	self.current_page = 1
	self.pro_button.toggle.isOn = true;
end

function TipsShowProView:OnClickEquipButton()
	self.show_state = SHOW_EQUIP
	self.list_view:SetActive(false)
	self.show_page:SetValue(false)
	self.show_equip_cell:SetValue(true)
	local temp_equip_list = {}
	for k, v in pairs(EquipData.Instance:GetDataList()) do
		table.insert(temp_equip_list, v)
	end
	for k, v in pairs(self.equip_cells) do
		local group = self.equip_group_cell_list[v]
		if nil == group then
			group = ChatShowProViewItem.New(v)
			group.tips_view = self
			group:SetToggleGroup(self.list_view.toggle_group)
			self.equip_group_cell_list[v] = group
		end
		local page = math.floor((k - 1) / PRO_COLUMN)
		local column = k - page * PRO_COLUMN - 1
		local grid_count = PRO_COLUMN * PRO_ROW

		for i = 1, PRO_ROW do
			local index = (i - 1) * PRO_COLUMN  + column + (page * grid_count)
			local data = nil
			data = temp_equip_list[index + 1]
			data = data or {}

			group:SetInteractable(i, true)
			if not next(data) then
				group:SetInteractable(i, false)
			end

			group:SetData(i, data)
			group:ListenClick(i, BindTool.Bind(self.OnClickEquipItem, self, data, group, i))
		end
	end
end

function TipsShowProView:OnClickEquipItem(data, group, group_index)
	ChatCtrl.Instance:SetChatViewData(data, true)
	ChatCtrl.Instance:SetGuildViewData(data, true)
	self:Close()
end

function TipsShowProView:OnClickCloseButton()
	self:Close()
end

function TipsShowProView:FlushBagView()
	self.list_view.scroller:RefreshActiveCellViews()
end

ChatShowProViewItem = ChatShowProViewItem or BaseClass(BaseRender)

function ChatShowProViewItem:__init()
	self.cells = {}
	for i = 1, PRO_ROW do
		local item_obj = ItemCell.New(self:FindObj("Item" .. i))
		self.cells[i] = item_obj
	end
	-- self.cells = {
	-- 	ItemCell.New(self:FindObj("Item1")),
	-- 	ItemCell.New(self:FindObj("Item2")),
	-- 	ItemCell.New(self:FindObj("Item3")),
	-- 	ItemCell.New(self:FindObj("Item4")),
	-- 	ItemCell.New(self:FindObj("Item5")),
	-- }
end

function ChatShowProViewItem:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
	self.tips_view = nil
end

function ChatShowProViewItem:SetData(i, data)
	self.cells[i]:SetData(data)
	if self.tips_view.show_state == SHOW_PROP then
		if self.cells[i].root_node.toggle.isOn and data.index ~= self.tips_view.select_index then
			self.cells[i].root_node.toggle.isOn = false
		elseif not self.cells[i].root_node.toggle.isOn and data.index == self.tips_view.select_index then
			self.cells[i].root_node.toggle.isOn = true
		end
	end
end

function ChatShowProViewItem:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function ChatShowProViewItem:SetToggleGroup(toggle_group)
	-- self.cells[1]:SetToggleGroup(toggle_group)
	-- self.cells[2]:SetToggleGroup(toggle_group)
	-- self.cells[3]:SetToggleGroup(toggle_group)
	-- self.cells[4]:SetToggleGroup(toggle_group)
	-- self.cells[5]:SetToggleGroup(toggle_group)
	for k,v in pairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function ChatShowProViewItem:SetInteractable(i, value)
	self.cells[i]:SetInteractable(value)
end
