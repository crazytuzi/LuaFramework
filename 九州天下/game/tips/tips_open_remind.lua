TipsOpenRemindView = TipsOpenRemindView or BaseClass(BaseView)
function TipsOpenRemindView:__init()
	self.ui_config = {"uis/views/tips/remindtips", "RemindTips"}
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
	self.play_audio = true
	self.task_cell_list = {}
	self.task_data = {}
end

function TipsOpenRemindView:__delete()

end

function TipsOpenRemindView:LoadCallBack()
	self.list_view = self:FindObj("TaskList")
	local task_view_delegate = self.list_view.list_simple_delegate
	--生成数量
	task_view_delegate.NumberOfCellsDel = function()
		return #self.task_data or 0
	end
	--刷新函数
	task_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshTaskListView, self)

	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	local red_point_list = RemindGroud[RemindName.WenXinRemind]
	for k, _ in pairs(red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:ListenEvent("close_click", BindTool.Bind(self.Close, self))
end

function TipsOpenRemindView:ReleaseCallBack()
	if self.task_cell_list then	
		for k,v in pairs(self.task_cell_list) do
			v:DeleteMe()
		end
		self.task_cell_list = {}
	end
	self.task_data = {}

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.list_view = nil
end

function TipsOpenRemindView:OpenCallBack()
	self:Flush()
end

function TipsOpenRemindView:RefreshTaskListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local task_cell = self.task_cell_list[cell]
	if task_cell == nil then
		task_cell = RemindTipsItems.New(cell.gameObject)
		self.task_cell_list[cell] = task_cell
	end

	task_cell:SetIndex(data_index)
	task_cell:SetData(self.task_data[data_index])
end

function TipsOpenRemindView:RemindChangeCallBack(key, value)
	TipsRemindData.Instance:CheckRemindTips()
	self:Flush()
end

function TipsOpenRemindView:OnFlush()
	self.task_data = TipsRemindData.Instance:GetRemindList()
	self.list_view.scroller:ReloadData(0)
end

RemindTipsItems = RemindTipsItems or BaseClass(BaseCell)
function RemindTipsItems:__init(instance)
	self:ListenEvent("OnGoToBtn", BindTool.Bind(self.OnGoToBtnHandle, self))

	self.text = self:FindVariable("Text")
end

function RemindTipsItems:__delete()

end

function RemindTipsItems:OnFlush()
	if nil == self.data then return end
	local data = RemindCfg[self.data]
	local btn_text = data.btn_name
	self.text:SetValue(btn_text)
end	

--前往完成
function RemindTipsItems:OnGoToBtnHandle()
	if nil == self.data then return end
	local data = RemindCfg[self.data]
	local view_name = data.view_name
	local tab_index = data.tab_index
	ViewManager.Instance:Open(view_name, tab_index)
	ViewManager.Instance:Close(ViewName.TipsOpenRemindView)
end
