SpiritHomeRevengeView = SpiritHomeRevengeView or BaseClass(BaseView)

function SpiritHomeRevengeView:__init()
	self.ui_config = {"uis/views/spiritview_prefab","SpiritHomeRevengeView"}
	self.view_layer = UiLayer.Pop
	self.str = ""
	self.early_close_state = false

	self.select_index = nil
	self.cell_list = {}
	self.data_list = {}
end

function SpiritHomeRevengeView:__delete()
end

function SpiritHomeRevengeView:ReleaseCallBack()
	self.select_index = nil

	for k,v in pairs(self.cell_list) do
		if v ~= nil then
			v:DeleteMe()
		end
	end
	self.cell_list = {}
	self.data_list = {}

	self.list_view = nil
end

function SpiritHomeRevengeView:LoadCallBack()
	self.list_view = self:FindObj("ListView")
	if self.list_view ~= nil then
		local list_delegate = self.list_view.list_simple_delegate
		list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
		list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	end

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickClose, self))
end

function SpiritHomeRevengeView:OpenCallBack()
	self.data_list = SpiritData.Instance:GetSpiritHomeRecordList()
	if self.list_view ~= nil then
		self.list_view.scroller:ReloadData(0)
	end
end

function SpiritHomeRevengeView:CloseCallBack()
end

function SpiritHomeRevengeView:OnClickClose()
	self:Close()
end

function SpiritHomeRevengeView:GetNumberOfCells()
	local num = #self.data_list
	return num
end

function SpiritHomeRevengeView:RefreshCell(cell, data_index)
	local group_cell = self.cell_list[cell]
	if group_cell == nil then
		group_cell = SpiritHomeRevengeRender.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	group_cell:SetIndex(data_index)
	group_cell:SetData(self.data_list[data_index + 1] or {})
end

function SpiritHomeRevengeView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function SpiritHomeRevengeView:GetSelectIndex()
	return self.select_index
end

function SpiritHomeRevengeView:FlushList()
	if self.list_view ~= nil then
		if self.select_index == 1 then
			self.list_view.scroller:ReloadData(0)
		else
			self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
		end
	end
end

function SpiritHomeRevengeView:Flush()
	self.data_list = SpiritData.Instance:GetSpiritHomeRecordList()
	if self.list_view ~= nil then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end


-----------------------------------------------------------------------------
SpiritHomeRevengeRender = SpiritHomeRevengeRender or BaseClass(BaseRender)

function SpiritHomeRevengeRender:__init()
	self.is_select = false

	self.content = self:FindVariable("RevengeStr")
	self.timer = self:FindVariable("Timer")
	self:ListenEvent("EventRevenge", BindTool.Bind(self.OnClickRevenge, self))
end

function SpiritHomeRevengeRender:__delete()
	self.is_select = false

	self.content = nil
	self.timer = nil
end

function SpiritHomeRevengeRender:SetIndex(index)
	self.index = index
end

function SpiritHomeRevengeRender:GetIndex()
	return self.index
end

function SpiritHomeRevengeRender:OnClickRevenge()
	if self.data == nil or self.data.role_id == nil then
		return
	end

	SpiritCtrl:SendJingLingHomeOperReq(JING_LING_HOME_OPER_TYPE.JING_LING_HOME_OPER_TYPE_GET_INFO, self.data.role_id)
	SpiritCtrl.Instance:CloseSpiritHomeRevengeView()
end

function SpiritHomeRevengeRender:SetData(data)
	self.data = data
	self:Flush()
end

function SpiritHomeRevengeRender:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	if self.content ~= nil and self.data.name ~= nil and self.data.rob_time ~= nil and self.timer ~= nil then
		local timer_str = ""
		local now_time = TimeCtrl.Instance:GetServerTime()
		local timer = TimeUtil.Format2TableDHMS(now_time - self.data.rob_time)
		local timer1 = TimeUtil.Format2TableDHMS(self.data.rob_time)
		local timer2 = TimeUtil.Format2TableDHMS(now_time)
		if timer.day > 0 then
			timer_str = string.format(Language.JingLing.RevengeDayStr1, timer.day)
		else
			timer_str = string.format(Language.JingLing.RevengeDayStr2, timer1.hour, timer1.min, timer1.s)
		end

		self.timer:SetValue(timer_str)
		self.content:SetValue(string.format(Language.JingLing.SpiritRevengeStr, self.data.name))
	end
end

function SpiritHomeRevengeRender:SetToggleGroup(toggle_group)
	--self.root_node.toggle.group = toggle_group
end

function SpiritHomeRevengeRender:SetSelctState(state)
	-- self.root_node.toggle.isOn = state
	-- self.is_select = state
end