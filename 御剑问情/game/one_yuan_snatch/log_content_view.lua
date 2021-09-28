SnatchLogView = SnatchLogView or BaseClass(BaseRender)

function SnatchLogView:__init()
	self.cell_list = {}
	self.down_cell_list = {}

	self.top_list_view = self:FindObj("TopListView")
	self.down_list_view = self:FindObj("DownListView")

	local top_scroller_delegate = self.top_list_view.list_simple_delegate
	top_scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.TopGetNumberOfCells, self)
	top_scroller_delegate.CellRefreshDel = BindTool.Bind(self.TopRefreshCell, self)

	local down_scroller_delegate = self.down_list_view.list_simple_delegate
	down_scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.DownGetNumberOfCells, self)
	down_scroller_delegate.CellRefreshDel = BindTool.Bind(self.DownRefreshCell, self)

end

function SnatchLogView:__delete()
	for k, v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = nil

	for k, v in pairs(self.down_cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.down_cell_list = nil
end

function SnatchLogView:CloseCallBack()
	-- body
end

function SnatchLogView:OpenCallBack()
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_BUY_RECORD )
	OneYuanSnatchCtrl.Instance:SendOperate(RA_CLOUDPURCHASE_OPERA_TYPE.RA_CLOUDPURCHASE_OPERA_TYPE_SERVER_RECORD_INFO )

	self:Flush()
end

function SnatchLogView:OnFlush()
	if self.top_list_view and self.top_list_view.scroller then
		self.top_list_view.scroller:ReloadData(0)
	end

	if self.down_list_view and self.down_list_view.scroller then
		self.down_list_view.scroller:ReloadData(0)
	end
end

function SnatchLogView:TopGetNumberOfCells()
	local cfg = OneYuanSnatchData.Instance:GetSCCloudPurchaseBuyRecordInfo()
	if cfg then
		return cfg.record_count or 0
	end
	return 0
end

function  SnatchLogView:TopRefreshCell(cell, data_index)
	local num = self:TopGetNumberOfCells()
	data_index = data_index + 1
	local cfg = OneYuanSnatchData.Instance:GetSCCloudPurchaseBuyRecordInfoByIndex(num - data_index + 1)
	local the_cell = self.cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = SnatchLogCell.New(cell.gameObject)
			self.cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell.view_type = "top"
		the_cell:SetData(cfg)
	end
end

function SnatchLogView:DownGetNumberOfCells()
	local cfg = OneYuanSnatchData.Instance:GetSCCloudPurchaseServerRecord()
	if cfg and cfg.count then
		return cfg.count
	end
	return 0 
end

function  SnatchLogView:DownRefreshCell(cell, data_index)
	local num = self:DownGetNumberOfCells()
	data_index = data_index + 1
	local cfg = OneYuanSnatchData.Instance:GetSCCloudPurchaseServerRecordByIndex(num - data_index + 1)
	local the_cell = self.down_cell_list[cell]

	if cfg then
		if the_cell == nil then
			the_cell = SnatchLogCell.New(cell.gameObject)
			self.down_cell_list[cell] = the_cell
		end
		the_cell:SetIndex(data_index)
		the_cell.view_type = "down"
		the_cell:SetData(cfg)
	end
end


-------------------记录条-------------------------
SnatchLogCell = SnatchLogCell or BaseClass(BaseCell)

function SnatchLogCell:__init()
	self.info = self:FindVariable("Info")
end

function SnatchLogCell:__delete()

end

function SnatchLogCell:OnFlush()
	if not self.data then return end

	local text = ""
	local item_name = ""


	if self.view_type == "top" then
		local cfg = OneYuanSnatchData.Instance:GetItemIdCfg(self.data.item_id or 0)
		local buy_count = self.data.buy_count or 0
		local time = os.date("%X", self.data.buy_timestamp or 0)

		if cfg then
			item_name = cfg.name or ""
		end
		
		text = string.format(Language.OneYuanSnatch.buglogText, time, buy_count, item_name)
	elseif self.view_type == "down" then
		local cfg = OneYuanSnatchData.Instance:GetItemIdCfg(self.data.reward_item_id or 0)
		local user_name = self.data.user_name or ""
		
		if cfg then
			item_name = cfg.name or ""
		end

		text = string.format(Language.OneYuanSnatch.rewardlogText, user_name, item_name)
	end

	self.info:SetValue(text)
end

