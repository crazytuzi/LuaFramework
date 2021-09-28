HappyRecordListView = HappyRecordListView or BaseClass(BaseView)
function HappyRecordListView:__init()
	self.ui_config = {"uis/views/happyrecharge_prefab", "RecordTipsView"}
end

function HappyRecordListView:__delete()
	-- body
end

function HappyRecordListView:LoadCallBack()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().charge_niu_egg
	self.rand_cfg = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_HAPPY_RECHARGE)

	self.record_cell_list = {}
	self.record_info_list = HappyRechargeData.Instance:GetHistoryList()

	self:ListenEvent("Close", BindTool.Bind(self.CloseView, self))
	self.list_view = self:FindObj("list_view")
	local list_delegate_right = self.list_view.list_simple_delegate
	list_delegate_right.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate_right.CellRefreshDel = BindTool.Bind(self.RefreshCellRight, self)

end

function HappyRecordListView:ReleaseCallBack()
	self.list_view = nil
	self.record_cell_list = nil
end

function HappyRecordListView:GetNumberOfCells()
	return HappyRechargeData.Instance:GetHistoryCount()
end

function HappyRecordListView:RefreshCellRight(cell, cell_index)
	local contain_cell = self.record_cell_list[cell]
	if contain_cell == nil then
		contain_cell = HappyRecordCell.New(cell.gameObject)
		self.record_cell_list[cell] = contain_cell
	end
	contain_cell:SetConfig(self.rand_cfg)
	contain_cell:SetData(self.record_info_list[cell_index + 1])
end

function HappyRecordListView:OpenCallBack()

end

function HappyRecordListView:CloseCallBack()

end

function HappyRecordListView:OnFlush(param_list)

end

function HappyRecordListView:CloseView()
	self:Close()
end

------------------------------HappyRecordCell------------------------------------
HappyRecordCell = HappyRecordCell or BaseClass(BaseCell)
function HappyRecordCell:__init()
	self.name = self:FindVariable("name")
	self.item_name = self:FindVariable("item_name")
end

function HappyRecordCell:__delete()
	-- body
end

function HappyRecordCell:SetConfig(cfg)
	self.cfg = cfg
end

function HappyRecordCell:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.name:SetValue(ToColorStr(self.data.user_name, TEXT_COLOR.BLACK_1))
		self.item_name:SetValue(ToColorStr(ItemData.Instance:GetItemConfig(self.cfg[self.data.reward_req + 1].reward_item.item_id).name, TEXT_COLOR.BLUE_4))
	end
end