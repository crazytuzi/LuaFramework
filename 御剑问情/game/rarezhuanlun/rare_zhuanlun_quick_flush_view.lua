ZhuanLunQucikFlushView = ZhuanLunQucikFlushView or BaseClass(BaseView)

function ZhuanLunQucikFlushView:__init(  )
	self.full_screen = false-- 是否是全屏界面
    self.ui_config = {"uis/views/zhenxizhuanlun_prefab", "ZhuanLunFlushView"}
    self.play_audio = true
end

function ZhuanLunQucikFlushView:__delete()

end

function ZhuanLunQucikFlushView:LoadCallBack()
	self.list_view = self:FindObj("listview")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.rush_item = {}

	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	self:ListenEvent("ClickStart",BindTool.Bind(self.ClickStart,self))
end

function ZhuanLunQucikFlushView:ReleaseCallBack()

	for k,v in pairs(self.rush_item) do
		v:DeleteMe()
	end
	self.rush_item = {}
	self.list_view = nil
end

function ZhuanLunQucikFlushView:CloseWindow()
	RareDialData.Instance:ClearSelectIdTable()

	self:Close()
end

function ZhuanLunQucikFlushView:OpenCallBack()
	for k, v in pairs(self.rush_item) do
		v:SetHighLight(false)
	end
end

function ZhuanLunQucikFlushView:CloseCallBack()

end

function ZhuanLunQucikFlushView:GetNumberOfCells()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local rare_data = RareDialData.Instance:GetDrawDataRareByOpenDay(open_day) or {}
	local num = #rare_data or 0

	return math.ceil(#rare_data / 2)
end

function ZhuanLunQucikFlushView:RefreshCell(cell, cell_index)
	local record_cell = self.rush_item[cell]
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local rare_data = RareDialData.Instance:GetDrawDataRareByOpenDay(open_day) or {}
	if record_cell == nil then
		record_cell = ZhuanLunQucikFlushInfo.New(cell.gameObject)
		self.rush_item[cell] = record_cell
	end

	for i = 1, 2 do
		record_cell:SetData(rare_data[cell_index * 2 + i], i)
	end
end

function ZhuanLunQucikFlushView:ClickStart()
	local state = RareDialData.Instance:IsHasSelectId()
	local need_money = RareDialData.Instance:GetFlushSpend() or 20
    local role_info = GameVoManager.Instance:GetMainRoleVo()

	if state and role_info.gold >= need_money then
		RareDialCtrl.Instance:ShowQuickFlush(true)
		RareDialCtrl.Instance:QuickFlush(true)
		self:Close()
	
	elseif state and role_info.gold < need_money then
		TipsCtrl.Instance:ShowLackDiamondView()

	elseif not state then
		SysMsgCtrl.Instance:ErrorRemind(Language.RareZhuanLun.QuickFlsuh)
	end
end


ZhuanLunQucikFlushInfo = ZhuanLunQucikFlushInfo or BaseClass(BaseRender)

function ZhuanLunQucikFlushInfo:__init(  )
	self.cell_list = {}
	for i = 1, 2 do
		self["item" .. i] = self:FindObj("Item" .. i)
		local cell = ZhuanLunQucikFlushItem.New(self["item" .. i])
		table.insert(self.cell_list, cell)
	end
end

function ZhuanLunQucikFlushInfo:__delete()
	for k, v in ipairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for i = 1, 2 do
		self["item" .. i] = nil
	end

end

function ZhuanLunQucikFlushInfo:SetToggleGroup(group, i)
	self["item" .. i].toggle.group = group
end

function ZhuanLunQucikFlushInfo:SetHighLight(value)
	for i = 1, 2 do
		self.cell_list[i]:SetHighLight(value)
	end
end

function ZhuanLunQucikFlushInfo:SetData(data, i)
	if nil ~= data then
		self.cell_list[i]:SetData(data)
	else
		self["item" .. i]:SetActive(false)
	end
end


ZhuanLunQucikFlushItem = ZhuanLunQucikFlushItem or BaseClass(BaseRender)

function ZhuanLunQucikFlushItem:__init(  )
	self.text = self:FindVariable("text")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowHighLight(false)

	self:ListenEvent("OnToggle",BindTool.Bind(self.OnClick,self))

	self.item_id = 0
	self.item_seq = -1
end

function ZhuanLunQucikFlushItem:__delete()
	self.item_cell:DeleteMe()
end

function ZhuanLunQucikFlushItem:SetData(data)
	self.item_id = data.reward_item.item_id
	self.item_seq = data.seq
	local item_info = ItemData.Instance:GetItemConfig(self.item_id)
	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	self.text:SetValue(item_name)
	self.item_cell:SetData(data.reward_item)
end

function ZhuanLunQucikFlushItem:OnClick()
	if self.root_node.toggle.isOn then
		RareDialData.Instance:InsertSelectId(self.item_seq)
	else
		RareDialData.Instance:RemoveSelectId(self.item_seq)
	end
end

function ZhuanLunQucikFlushItem:SetHighLight(state)
	self.root_node.toggle.isOn = state
end