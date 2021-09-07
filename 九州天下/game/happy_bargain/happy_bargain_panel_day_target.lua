HappyBargainPanelDayTarget = HappyBargainPanelDayTarget or BaseClass(BaseRender)
function HappyBargainPanelDayTarget:__init()
	self.contain_cell_list = {}
	self.reward_list = {}
end

function HappyBargainPanelDayTarget:__delete()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if self.contain_cell_list then
		for k, v in pairs(self.contain_cell_list) do
			v:DeleteMe()
		end
		self.contain_cell_list = {}
	end

end

function HappyBargainPanelDayTarget:LoadCallBack()
	KaifuActivityCtrl.SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TARGET, RA_CONSUME_AIM_OPERA_TYPE.RA_CONSUME_AIM_OPERA_TYPE_ALL_INFO)

	self.reward_list = HappyBargainData.Instance:SortDayTargetGetCfg()

	self.list_view = self:FindObj("ListView")
	self.rest_time = self:FindVariable("rest_time")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	local rest_time = HappyBargainData.Instance:GetActEndTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TARGET)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)
end

function HappyBargainPanelDayTarget:GetNumberOfCells()
	return #self.reward_list
end

function HappyBargainPanelDayTarget:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]

	if contain_cell == nil then
		contain_cell = DayTargetCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1

	local data = {self.reward_list[cell_index]}
	contain_cell:SetData(data)
end

function HappyBargainPanelDayTarget:SetTime(remaining_second)
 	local time_tab = TimeUtil.Format2TableDHMS(remaining_second)
  	local str = ""
 	if time_tab.day > 0 then
   		remaining_second = remaining_second - 24 * 60 * 60 * time_tab.day
   	end
	str = TimeUtil.FormatSecond(remaining_second)

	if self.rest_time then
		self.rest_time:SetValue(str)
	end
end

function HappyBargainPanelDayTarget:OnFlush()
	self.reward_list = HappyBargainData.Instance:SortDayTargetGetCfg()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

------------------------------DayTargetCell-------------------------------------
DayTargetCell = DayTargetCell or BaseClass(BaseCell)
function DayTargetCell:__init()
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self.item_state_list = {}
	self.tips = self:FindVariable("tips")
	self.active_button = self:FindVariable("active_button")
	self.button_text = self:FindVariable("button_text")
	self.show_remind = self:FindVariable("show_remind")
	self.process = 0
	self.flag = 0
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		self.item_state_list[i] = self:FindVariable("is_show_"..i)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self.item_cell_obj_list[i])
	end

	self:ListenEvent("OnClickButton", BindTool.Bind(self.OnClickButton, self))

end

function DayTargetCell:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_obj_list = nil

	self.tips = nil
	self.active_button = nil
	self.button_text = nil
	self.show_remind = nil
	self.process = 0
	self.flag = 0
end

function DayTargetCell:OnFlush()
	-- self.process = self.data[2]
	-- self.flag = self.data[3]
	local is_day_target_get, process_temp = HappyBargainData.Instance:IsDayTargetGetProcess(self.data[1].seq, self.data[1].task_conditions)
	self.flag = self.data[1].fetch_reward_flag
	self.process = process_temp
	local btn_status = false
	local btn_str = Language.HappyBargain.DayTarget.Goto
	local remind_status = false

	local gifts = ItemData.Instance:GetGiftItemList(self.data[1].reward_item[0].item_id)
	for k, v in pairs(self.item_cell_list) do
		if gifts[k] ~= nil and next(gifts[k]) ~= nil then
			self.item_cell_list[k]:SetData(gifts[k])
		else
			self.item_state_list[k]:SetValue(false)
		end
	end

	local need_process = self.data[1].task_conditions
	local process = string.format(Language.HappyBargain.DayTarget.Process, self.process, need_process)
	local mission = self.data[1].task_account .. process
	-- if self.process >= need_process and self.flag == 0 then
	if is_day_target_get and self.flag == 0 then
		btn_str = Language.HappyBargain.DayTarget.Receive
		btn_status = true
		remind_status = true
	elseif self.flag == 1 then
		btn_str = Language.HappyBargain.DayTarget.Finish
		btn_status = false
		remind_status = false
	else
		btn_status = true
		remind_status = false
	end

	self.tips:SetValue(mission)
	self.button_text:SetValue(btn_str)
	self.active_button:SetValue(btn_status)
	self.show_remind:SetValue(remind_status)
end

function DayTargetCell:OnClickButton()
	if self.process >= self.data[1].task_conditions then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_TARGET, RA_CONSUME_AIM_OPERA_TYPE.RA_CONSUME_AIM_OPERA_TYPE_FETCH_REWARD, self.data[1].seq)
	elseif self.process < self.data[1].task_conditions then
		local goto_view = Split(self.data[1].open_panel, "#")
		if #goto_view == 1 then
			ViewManager.Instance:Open(goto_view[1])
		elseif #goto_view == 2 then
			ViewManager.Instance:Close(ViewName.HappyBargainView)
			ViewManager.Instance:Open(ViewName[goto_view[1]], TabIndex[goto_view[2]])
		end
	end
end