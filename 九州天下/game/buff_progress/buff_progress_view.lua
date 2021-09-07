BuffProgressView = BuffProgressView or BaseClass(BaseView)
function BuffProgressView:__init()
	self.ui_config = {"uis/views/buffprogress", "BuffProgressView"}
	self.cell_list = {}
end

function BuffProgressView:ReleaseCallBack()
	self.list_view = nil
end

function BuffProgressView:LoadCallBack()
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBuffNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBuffCell, self)
end

function BuffProgressView:OpenCallBack()

end

function BuffProgressView:OnFlush(param_list)
	self.list_view.scroller:ReloadData(0)
end

function BuffProgressView:GetBuffNum()
	return #BuffProgressData.Instance:GetBuffList()
end

function BuffProgressView:RefreshBuffCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.cell_list[cell]
	local data_list = BuffProgressData.Instance:GetBuffList()
	if not item_cell then
		item_cell = BuffItem.New(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	item_cell:SetData(data_list[cell_index])
end

-------------------------------------------------------------------------------------------------------------
BuffItem = BuffItem or BaseClass(BaseCell)
function BuffItem:__init()
	self.progress_bg = self:FindVariable("ProgressBg")
	self.progress = self:FindVariable("Progress")
	self.progress_value = self:FindVariable("ProgressValue")
end

function BuffItem:__delete()
	if self.time_countdown then
		CountDown.Instance:RemoveCountDown(self.time_countdown)
		self.time_countdown = nil
	end
end

function BuffItem:OnFlush()
	if not self.data or not next(self.data) then return end
	self.progress_bg:SetAsset(ResPath.GetBuffProgress("buff_type_" .. self.data.buff_type .. "_bg"))
	self.progress:SetAsset(ResPath.GetBuffProgress("buff_type_" .. self.data.buff_type))
	if self.time_countdown then
		CountDown.Instance:RemoveCountDown(self.time_countdown)
		self.time_countdown = nil
	end
	if not self.time_countdown then
		local totle_time = self.data.time / 1000			-- 服务端下发为毫秒
		self.time_countdown = CountDown.Instance:AddCountDown(totle_time, 0.05,BindTool.Bind(self.FlushProgressTime, self))
	end
end

function BuffItem:FlushProgressTime(elapse_time, total_time)
	local progress = (total_time - elapse_time) / total_time * 100
	self.progress_value:SetValue(progress)
	if elapse_time >= total_time then
		CountDown.Instance:RemoveCountDown(self.time_countdown)
		self.time_countdown = nil
		BuffProgressData.Instance:RemoveBuffInfo(self.data.buff_type)
		BuffProgressCtrl.Instance:Flush()
	end
end