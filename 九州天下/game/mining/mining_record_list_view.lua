MiningRecordListView = MiningRecordListView or BaseClass(BaseView)

function MiningRecordListView:__init()
	self.ui_config = {"uis/views/mining","MiningRecordView"}
	self.cell_list = {}
	self.view_type = 0
end

function MiningRecordListView:__delete()

end

function MiningRecordListView:ReleaseCallBack()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.scroller = nil
	self.text_title_name = nil
	self.view_type = 0
end

function MiningRecordListView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))

	-- 生成滚动条
	self.scroller_data = {}
	self.scroller = self:FindObj("record_list")
	local scroller_delegate = self.scroller.list_simple_delegate
	--生成数量
	scroller_delegate.NumberOfCellsDel = function()
		return #self.scroller_data or 0
	end
	--刷新函数
	scroller_delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local record_cell = self.cell_list[cell]
		if record_cell == nil then
			record_cell = RecordListItem.New(cell.gameObject)
			record_cell.root_node.toggle.group = self.scroller.toggle_group
			self.cell_list[cell] = record_cell
		end

		record_cell:SetIndex(data_index)
		record_cell:SetVieType(self.view_type)
		record_cell:SetData(self.scroller_data[data_index])
	end

	self.text_title_name = self:FindVariable("text_title_name")
end

function MiningRecordListView:OpenCallBack()
	self:Flush()
end

function MiningRecordListView:CloseWindow()
	self:Close()
end

function MiningRecordListView:CloseCallBack()
	self.select_index = nil
end

function MiningRecordListView:OnFlush()
	self.scroller_data = MiningData.Instance:GetMiningBeenRobListByViewType(self.view_type) or {}
	self.scroller.scroller:ReloadData(0)

	self.text_title_name:SetValue(Language.Mining.RecordListTitleName[self.view_type])
end

function MiningRecordListView:SetViewType(view_type)
	self.view_type = view_type
end

----------------------------------------------------------------------------
--RecordListItem 	
----------------------------------------------------------------------------

RecordListItem = RecordListItem or BaseClass(BaseCell)

function RecordListItem:__init()
	self.view_type = 0

	-- 获取变量
	self.text_name = self:FindVariable("text_name")
	self.text_time = self:FindVariable("text_time")
	self.is_show_btn = self:FindVariable("is_show_btn")

	-- 监听事件
	self:ListenEvent("OnClickBtn", BindTool.Bind(self.OnClickBtn, self))
end

function RecordListItem:__delete()
	self.view_type = 0
	self.data = nil
end

function RecordListItem:OnFlush()
	if not self.data then return end

	local name = ""
	local info_data = nil
	if self.view_type == MINING_VIEW_TYPE.MINE then
		info_data = MiningData.Instance:GetMiningMineCfg(self.data.cur_type)
	elseif self.view_type == MINING_VIEW_TYPE.SEA then
		info_data = MiningData.Instance:GetMiningSeaCfg(self.data.cur_type)
	end

	if info_data ~= nil then
		name = info_data.name 
	end

	self.is_show_btn:SetValue(self.data.has_revenge == 0)

	self.text_name:SetValue(string.format(Language.Mining.RecordRobName, self.data.owner_name, name))
	local time_str = os.date(Language.Common.FullTimeStr, self.data.rob_time)
	self.text_time:SetValue(time_str)
end

function RecordListItem:SetVieType(view_type)
	self.view_type = view_type
end

function RecordListItem:OnClickBtn()
	if not self.data then return end
	MiningController.Instance:OpenMiningTargetView(self.view_type, MINING_TARGET_TYPE.FU_CHOU, self.data)
	
	-- if self.view_type == MINING_VIEW_TYPE.MINE then
	-- 	MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_REVENGE, self.data.real_index)
	-- elseif self.view_type == MINING_VIEW_TYPE.SEA then
	-- 	MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_REVENGE, self.data.real_index)
	-- end
end