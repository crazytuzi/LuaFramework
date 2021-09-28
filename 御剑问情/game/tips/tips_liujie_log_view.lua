TipsLiuJieLogView = TipsLiuJieLogView or BaseClass(BaseView)

function TipsLiuJieLogView:__init()
	self.ui_config = {"uis/views/kuafuliujie_prefab", "KuaFuLiuJieLogView"}
	self.select_item_id = 0
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
end

function TipsLiuJieLogView:__delete()
end

function TipsLiuJieLogView:LoadCallBack()
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.list_view = self:FindObj("ListView")
	self.show_no_text = self:FindVariable("show_no_text")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCloakNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCloakCell, self)
end


function TipsLiuJieLogView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.show_no_text = nil
	self.list_view = nil
end

function TipsLiuJieLogView:SetData()

end

function TipsLiuJieLogView:GetCloakNumberOfCells()
	local num = KuafuGuildBattleData.Instance:GetKuaFuLiuJieLog()
	if num and num.log_count then
		return num.log_count
	end
	return 0
end

function TipsLiuJieLogView:RefreshCloakCell(cell, cell_index)
	local record_cell = self.cell_list[cell]
	local cfg = KuafuGuildBattleData.Instance:GetKuaFuLiuJieLog()
	if nil ~= cfg and cfg.item_list ~= nil then
		if record_cell == nil then
			record_cell = RecordCellLog.New(cell.gameObject)
			self.cell_list[cell] = record_cell
		end
		record_cell:SetData(cfg.item_list[cell_index + 1])
	end
end

function TipsLiuJieLogView:OnFlush()

end

function TipsLiuJieLogView:OpenCallBack()
	local cfg = KuafuGuildBattleData.Instance:GetKuaFuLiuJieLog()
	if cfg and cfg.log_count and cfg.log_count > 0 then
		self.show_no_text:SetValue(false)
	end
	self.list_view.scroller:ReloadData(0)
end

function TipsLiuJieLogView:OnCloseClick()
	self:Close()
end


RecordCellLog = RecordCellLog or BaseClass(BaseCell)

function RecordCellLog:__init()
	self.info = self:FindVariable("Info")
end

function RecordCellLog:__delete()

end

function RecordCellLog:OnFlush()
	local item_info = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_info then
		return
	end

	local item_name = ToColorStr(item_info.name, ITEM_COLOR[item_info.color])
	local time = os.date("%X", self.data.timestamp)
	self.info:SetValue(string.format(Language.KuafuGuildBattle.KfLiuJieLogTips, self.data.name, time, item_name))
end