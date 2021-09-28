MainUiActivityPreview = MainUiActivityPreview or BaseClass(BaseView)

function MainUiActivityPreview:__init()
	self.ui_config = {"uis/views/main_prefab", "MainuiActivityPreview"}

end

function MainUiActivityPreview:__delete()

end

function MainUiActivityPreview:LoadCallBack()
	self.item_list = {}
	self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
 	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

 	self:ListenEvent("CloseWindow", BindTool.Bind(self.Close,self))
end

function MainUiActivityPreview:OpenCallBack()
	self:Flush()
end

function MainUiActivityPreview:OnFlush()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end

function MainUiActivityPreview:ReleaseCallBack()
	self.list_view = nil
	
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_list = {}
end

function MainUiActivityPreview:GetNumberOfCells()
	local data_list = ActivityData.Instance:GetTodayActInfoSort()
	return #data_list
end

function MainUiActivityPreview:RefreshCell(cell, data_index, cell_index)
	local data_list = ActivityData.Instance:GetTodayActInfoSort()

	local the_cell = self.item_list[cell]
	if the_cell == nil then
		the_cell = MainUiActivityPreviewItem.New(cell.gameObject)
		self.item_list[cell] = the_cell
	end

	self.item_list[cell]:SetData(data_list[data_index + 1])
end

-----------------------------------------------------------------------------
--
-----------------------------------------------------------------------------

MainUiActivityPreviewItem = MainUiActivityPreviewItem or BaseClass(BaseCell)

function MainUiActivityPreviewItem:__init()
	self.act_name = self:FindVariable("act_name")
	self.act_time = self:FindVariable("act_time")
	self.act_image = self:FindVariable("act_image")
	self.act_title = self:FindVariable("act_title")
	self.showkaiqi = self:FindVariable("showkaiqi")
	self.show_process = self:FindVariable("show_process")
end

function MainUiActivityPreviewItem:__delete()
	self.act_name = nil
	self.act_time = nil
	self.act_image = nil
	self.act_title = nil
	self.show_process = nil
end

function MainUiActivityPreviewItem:OnFlush()
	if nil == self.data then
		return
	end
	time_str = (self.data.act_id ~= ACTIVITY_TYPE.MOSHEN) and self.data.open_time .. "-" .. self.data.end_time or self.data.open_time
	if self.data.state == ActivityData.ActState.OPEN then
		self.showkaiqi:SetValue(false)
		self.show_process:SetValue(true)
	elseif self.data.state == ActivityData.ActState.WAIT then
		self.showkaiqi:SetValue(false)
		self.show_process:SetValue(false)
	else
		time_str = string.format(Language.Common.ToColor, TEXT_COLOR.GRAY, time_str)
		self.showkaiqi:SetValue(true)
		self.show_process:SetValue(false)
	end

	self.act_name:SetValue(self.data.act_name)
	self.act_title:SetAsset(ResPath.GetActivityPreviewTitle(self.data.act_id))
	self.act_image:SetAsset(ResPath.GetActivityPreviewBg(self.data.act_id))

	if time_str ~= "" then
		self.act_time:SetValue(time_str)
	end
end