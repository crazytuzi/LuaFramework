TipsRecordView = TipsRecordView or BaseClass(BaseView)

function TipsRecordView:__init()
	self.ui_config = {"uis/views/tips/recorditemtip_prefab", "RecordItemTip"}
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
end

function TipsRecordView:__delete()
end

function TipsRecordView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.list_view = self:FindObj("ListView")
	self.show_no_text = self:FindVariable("show_no_text")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCloakNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCloakCell, self)
end


function TipsRecordView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.show_no_text = nil
	self.list_view = nil
end

function TipsRecordView:SetData()

end

function TipsRecordView:GetCloakNumberOfCells()
	local num = KuaFuXiuLuoTowerData.Instance:GetXiuLuoTowerLog()
	if num and num.log_count then
		return num.log_count
	end
	return 0
end

function TipsRecordView:RefreshCloakCell(cell, cell_index)
	local record_cell = self.cell_list[cell]
	local cfg = KuaFuXiuLuoTowerData.Instance:GetXiuLuoTowerLog()
	if nil ~= cfg and cfg.item_list ~= nil then
		if record_cell == nil then
			record_cell = RecordCell.New(cell.gameObject)
			self.cell_list[cell] = record_cell
		end
		record_cell:SetData(cfg.item_list[cell_index + 1])
	end
end

function TipsRecordView:OnFlush()

end

function TipsRecordView:OpenCallBack()
	local cfg = KuaFuXiuLuoTowerData.Instance:GetXiuLuoTowerLog()
	if cfg and cfg.log_count and cfg.log_count > 0 then
		self.show_no_text:SetValue(false)
	end
	self.list_view.scroller:ReloadData(0)
end

function TipsRecordView:OnCloseClick()
	self:Close()
end


RecordCell = RecordCell or BaseClass(BaseCell)

function RecordCell:__init()
	self.kill_time = self:FindVariable("kill_time")
	self.info = self:FindVariable("Info")
end

function RecordCell:__delete()

end

function RecordCell:OnFlush()
	local item_info = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_info then
		return
	end

	local log_text = ""
	if self.data.log_type == CROSS_XIULUO_TOWER_DROP_LOG_TYPE.CROSS_XIULUO_TOWER_DROP_LOG_TYPE_MONSTER then
		log_text = Language.Honorhalls.XiuLuoTowerTips1
	elseif self.data.log_type == CROSS_XIULUO_TOWER_DROP_LOG_TYPE.CROSS_XIULUO_TOWER_DROP_LOG_TYPE_GOLD_BOX then
		log_text = Language.Honorhalls.XiuLuoTowerTips2
	end
	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	local time = os.date("%X", self.data.timestamp)
	self.kill_time:SetValue(time)
	self.info:SetValue(string.format(log_text, self.data.name, item_name))
end