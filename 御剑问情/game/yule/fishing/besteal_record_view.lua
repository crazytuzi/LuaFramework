BeStealRecordView = BeStealRecordView or BaseClass(BaseView)

function BeStealRecordView:__init()
    self.ui_config = {"uis/views/yuleview_prefab", "BeStealRecordView"}
end

function BeStealRecordView:__delete()

end

function BeStealRecordView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	self.list_view = nil
end

function BeStealRecordView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.page_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMaxCellNum, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCellList, self)

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function BeStealRecordView:GetMaxCellNum()
	return #self.list_data
end

function BeStealRecordView:RefreshCellList(data_index, cell)
	data_index = data_index + 1
	local record_cell = self.cell_list[cell]
	if nil == record_cell then
		record_cell = BeStealRecordCell.New(cell.gameObject)
		self.cell_list[cell] = record_cell
	end
	record_cell:SetIndex(data_index)
	record_cell:SetData(self.list_data[data_index])
end


function BeStealRecordView:CloseWindow()
	self:Close()
end

function BeStealRecordView:OpenCallBack()
	FishingData.Instance:SetIsCheckBeSteal(true)
	RemindManager.Instance:Fire(RemindName.Fishing_BeSteal)
	self:Flush()
end

function BeStealRecordView:CloseCallBack()
	
end

function BeStealRecordView:OnFlush()
	local general_info = FishingData.Instance:GetStealGeneralInfo()
	if nil == general_info then
		return
	end

	self.list_data = general_info
	self.list_view.list_view:Reload()
end


---------------BeStealRecordCell----------------------------
BeStealRecordCell = BeStealRecordCell or BaseClass(BaseCell)

function BeStealRecordCell:__init()
	self.time_des = self:FindVariable("TimeDes")
	self.name_des = self:FindVariable("NameDes")
	self.fish_name = self:FindVariable("FishName")
	self.can_revenge = self:FindVariable("CanRevenge")

	self:ListenEvent("Revenge", BindTool.Bind(self.Revenge, self))
end

function BeStealRecordCell:__delete()
end

function BeStealRecordCell:OnFlush()
	if nil == self.data then
		return
	end

	local time_str = os.date(Language.Common.FullTimeStr, self.data.steal_fish_time)
	self.time_des:SetValue(time_str)

	if self.data.is_fuchou == 0 then
		self.can_revenge:SetValue(true)
	else
		self.can_revenge:SetValue(false)
	end

	self.name_des:SetValue(self.data.owner_name)
	local fish_info = FishingData.Instance:GetFishInfoByQuality(self.data.be_steal_quality)
	if nil ~= fish_info then
		local fish_name = ToColorStr(fish_info.fish_name, FISH_NAME_COLOR[self.data.be_steal_quality])
		self.fish_name:SetValue(fish_name)
	end
end

function BeStealRecordCell:Revenge()
	ViewManager.Instance:Close(ViewName.BeStealRecordView)
	FishingData.Instance:SetNowFishPondUid(self.data.owner_uid)
	FishingData.Instance:SetNowFishList(self.data)
	--刷新池塘
	ViewManager.Instance:FlushView(ViewName.YuLeView, "enter_other", {true})
end