TipsDiMaiTargetTaskView = TipsDiMaiTargetTaskView or BaseClass(BaseView)

function TipsDiMaiTargetTaskView:__init()
	self.ui_config = {"uis/views/tips/dimaitips", "TargetTaskTips"}
	self.play_audio = true
	self:SetMaskBg(true)
	self.view_layer = UiLayer.Pop
end

function TipsDiMaiTargetTaskView:__delete()
end

function TipsDiMaiTargetTaskView:ReleaseCallBack()
	if self.item_cell_list and next(self.item_cell_list) then
		for _,v in pairs(self.item_cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.item_cell_list = {}
	end	

	self.view_data = nil
	self.scroller = nil
	self.times_remind = nil
end

function TipsDiMaiTargetTaskView:LoadCallBack()
	self.item_cell_list = {}
	self.times_remind = self:FindVariable("ChallengeTimesRemind")

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self.scroller = self:FindObj("Scroller")
	local list_view_delegate = self.scroller.list_simple_delegate
	list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function TipsDiMaiTargetTaskView:OnFlush()
	self.view_data = DiMaiData.Instance:SortRewardList() or {}

	local day_count = DiMaiData.Instance:GetDiMaiChallengeCount()
	if day_count then
		self.times_remind:SetValue(string.format(Language.QiangDiMai.ChallengeTimesRemind, day_count))
	end

	self:FlushScroller()
end

function TipsDiMaiTargetTaskView:OpenCallBack()
	self:Flush()
end

function TipsDiMaiTargetTaskView:OnClickClose()
	self:Close()
end

function TipsDiMaiTargetTaskView:GetNumberOfCells()
	if self.view_data then
		return #self.view_data
	end
	return 0
end

function TipsDiMaiTargetTaskView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local item_cell = self.item_cell_list[cell]
	if item_cell == nil then
		item_cell = TaskItemCell.New(cell.gameObject)
		self.item_cell_list[cell] = item_cell
	end
	item_cell:SetIndex(data_index)
	item_cell:SetData(self.view_data[data_index])
end

function TipsDiMaiTargetTaskView:FlushScroller()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
end


------------------TaskItemCell----------------
TaskItemCell = TaskItemCell or BaseClass(BaseCell)

function TaskItemCell:__init()
	self.show_reward = self:FindVariable("ShowReward")
	self.task_des = self:FindVariable("TaskDes")
	self.show_get = self:FindVariable("ShowGet")
	self:ListenEvent("OnClickReward", BindTool.Bind(self.OnClickReward, self))

	self.item_list = {}
	for i = 0, 2 do
		self.item_list[i] = {}
		self.item_list[i].obj = self:FindObj("Item" .. i)
		self.item_list[i].cell = ItemCell.New()
		self.item_list[i].cell:SetInstanceParent(self.item_list[i].obj)
		self.item_list[i].obj:SetActive(false)
	end
end

function TaskItemCell:__delete()
	if self.item_list and next(self.item_list) then
		for k,v in pairs(self.item_list) do
			v.cell:DeleteMe()
			v = nil
		end
		self.item_list = {}
	end
end

function TaskItemCell:OnFlush()
	if self.data then
		local day_count = DiMaiData.Instance:GetDiMaiChallengeCount()
		self.show_reward:SetValue(day_count and day_count >= self.data.challenge_times)
		self.task_des:SetValue(string.format(Language.QiangDiMai.TargetDes, self.data.challenge_times))
		self.show_get:SetValue(DiMaiData.Instance:IsGetRewardByIndex(self.data.seq))

		for k,v in pairs(self.data.reward_item) do
			self.item_list[k].obj:SetActive(true)
			self.item_list[k].cell:SetData(v)
		end
	end
end 

function TaskItemCell:OnClickReward()
	DiMaiCtrl.Instance:SendReqDimaiOpera(DIMAI_OPERA_TYPE.DIMAI_OPERA_TYPE_FETCH_CHALLENGE_REWARD, self.data.seq, 0)
end