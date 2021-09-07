DayActivityName = DayActivityName or BaseClass(BaseView)

function DayActivityName:__init()
	self.ui_config = {"uis/views/main", "DayActivityNameView"}
	self:SetMaskBg(true)
end

function DayActivityName:LoadCallBack()
	self.activity_cell_list = {}	
	self:ListenEvent("OnClickClose", BindTool.Bind(self.Close, self))
	self.activity_list = self:FindObj("ActivityList")
	local activity_list_delegate = self.activity_list.list_simple_delegate
	activity_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetListNumberOfCells, self)
	activity_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListView, self)

	self.activity_data = MainUIData.Instance:GetActivityList()
end

function DayActivityName:ReleaseCallBack()
	if self.activity_cell_list and next(self.activity_cell_list) then
		for _,v in pairs(self.activity_cell_list) do
			v:DeleteMe()
		end
	end	
	self.activity_cell_list = {}

	self.activity_list = nil
end

function DayActivityName:GetListNumberOfCells()
	return #self.activity_data
end

function DayActivityName:RefreshListView(cell, data_index)
	data_index = data_index + 1
	local open_cell = self.activity_cell_list[cell]
	if open_cell == nil then
		open_cell = ActivityNameItem.New(cell.gameObject, self)
		self.activity_cell_list[cell] = open_cell
	end
	open_cell:SetIndex(data_index)
	open_cell:SetData(self.activity_data[data_index])
end

-----------------------------------------------------------------
ActivityNameItem = ActivityNameItem or BaseClass(BaseCell)
function ActivityNameItem:__init(instance)
	self.activity_name = self:FindVariable("ActivityName")
	self.activity_time = self:FindVariable("OpenActivityTime")
end

function ActivityNameItem:__delete()
	
end 

function ActivityNameItem:OnFlush()
	if nil == self.data or nil == next(self.data) then return end
	local activity_info = ActivityData.Instance:GetActivityForecast(self.data.activity_type)
	if nil == activity_info or nil == next(activity_info) then return end

	if activity_info then
		if self.data.is_close == 0 then
			self.activity_name:SetValue(activity_info.act_name)
		else
			self.activity_name:SetValue(ToColorStr(activity_info.act_name, TEXT_COLOR.GRAY))
		end
	end
	if self.data.is_close == 0 then
		local begin_time = os.date("%H:%M", self.data.act_begin_time)
		local end_time = os.date("%H:%M", self.data.act_end_time)
		self.activity_time:SetValue(string.format(Language.Activity.ParticalTime, begin_time .. "-" .. end_time))
	else
		self.activity_time:SetValue(ToColorStr(Language.Activity.HasFinish, TEXT_COLOR.GRAY))
	end
end