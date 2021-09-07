TreasureBowlView = TreasureBowlView or BaseClass(BaseView)

function TreasureBowlView:__init()
	self.ui_config = {"uis/views/treasurebowlview","TreasureBowlView"}
end

function TreasureBowlView:ReleaseCallBack()
	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
	end

	for k,v in pairs(self.reward_list) do
		v:DeleteMe()
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
end

function TreasureBowlView:Timer()
	time_list = Language.Common.TimeList
	--发奖励剩余时间
	self.reward_left_sec = self.reward_left_sec - 1
	local h,m,s = WelfareData.Instance:TimeFormat(self.reward_left_sec)
	self.send_reward_time:SetValue(h..time_list.h..m..time_list.min)
	--活动剩余时间
	self.activity_left_sec = self.activity_left_sec - 1
	local day,hour = WelfareData.Instance:TimeFormatWithDay(self.activity_left_sec)
	self.left_time:SetValue(day..time_list.d..hour..time_list.h)
end

function TreasureBowlView:LoadCallBack()
	self.left_time = self:FindVariable("LeftTiem")
	self.reward_diamond = self:FindVariable("RewardDiamond")
	self.send_reward_time = self:FindVariable("SendRewardTime")
	self.total_jubao_value = self:FindVariable("TotalJuBaoValue")
	self.person_jubao_value = self:FindVariable("PersonJuBaoValue")
	self.diamond_percent = self:FindVariable("DiamondPercent")
	-- self.show_help_plane = self:FindVariable("ShowHelpPlane")
	self.process_value = self:FindVariable("ProcessValue")
	self.chongzhi_present = self:FindVariable("ChongZhiPresent")


	-- self.show_help_plane:SetValue(false)

	self:ListenEvent("Close", BindTool.Bind(self.OnClosen, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.SetHelpPlaneVisibel, self))
	self:ListenEvent("CloseHelp", BindTool.Bind(self.SetHelpPlaneVisibel, self, false))
	self:ListenEvent("UseMoneyClick", BindTool.Bind(self.UseMoneyClick, self))

	self.reward_list = {}
	local obj_group = self:FindObj("ObjGroup")
	local child_number = obj_group.transform.childCount
	local count = 1
	for i = 0, child_number - 1 do
		local obj = obj_group.transform:GetChild(i).gameObject
		if string.find(obj.name, "RewardBox") ~= nil then
			self.reward_list[count] = TreasureBowlRewardBox.New(obj)
			count = count + 1
		end
	end

	local box_data = TreasureBowlData.Instance:GetTotalJuBaoRewardInfo()
	for i=1,#self.reward_list do
		self.reward_list[i]:SetData(box_data[i])
	end

	self:InitScroller()
	self:Flush()

	local time_table = TimeCtrl.Instance:GetServerTimeFormat()
	--本日0点开始已经过了多少秒
	local today_pass_time = time_table.hour * 3600 + time_table.min * 60 + time_table.sec
	--本日结束还剩多少秒
	self.reward_left_sec = 86400 - today_pass_time
	--活动结束还剩多少秒
	local left_days_sec = TreasureBowlData.Instance:GetActivityLeftDays() * 86400
	self.activity_left_sec = self.reward_left_sec + left_days_sec
	self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.Timer, self), 1)
end

function TreasureBowlView:OnClosen()
	self:Close()
end

function TreasureBowlView:SetHelpPlaneVisibel(is_show)
	TipsCtrl.Instance:ShowHelpTipView(Language.TreasureBowl.Tips)
	-- if is_show ~= nil then
	-- 	self.show_help_plane:SetValue(is_show)
	-- else
	-- 	self.show_help_plane:SetValue(not self.show_help_plane:GetBoolean())
	-- end
end
function TreasureBowlView:UseMoneyClick()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function TreasureBowlView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(2154, 0, 0, 0)
end

function TreasureBowlView:InitScroller()
	self.cell_list = {}
	self.scroller_data = TreasureBowlData.Instance:GetTaskScrollerData()

	self.scroller = self:FindObj("Scroller")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] = TreasureBowlScrollerCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = self.scroller_data[data_index]
		cell_data.data_index = data_index
		target_cell:SetData(cell_data)
	end
end

function TreasureBowlView:Flush()
	if not self:IsLoaded() then
		return
	end
	local data = TreasureBowlData.Instance:GetTreasureBowlInfo()
	if data == nil then
		return
	end
	local diamond_percent = TreasureBowlData.Instance:GetDiamondPercent()
	local max_total_jubao_value =  TreasureBowlData.Instance:GetMaxTotalJuBaoValue()
	local my_rechange = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	local fanli = TreasureBowlData.Instance:GetChongzhiFanli()

	local the_reward_diamond = my_rechange *(fanli/100 + diamond_percent/100)
	self.process_value:SetValue(data.total_cornucopia_value/max_total_jubao_value)
	-- print(ToColorStr(data.total_cornucopia_value, TEXT_COLOR.RED))
	self.total_jubao_value:SetValue(""..data.total_cornucopia_value)
	self.person_jubao_value:SetValue(my_rechange.."")

	self.diamond_percent:SetValue(diamond_percent.."%")
	self.reward_diamond:SetValue(math.ceil(the_reward_diamond))
	self.chongzhi_present:SetValue(fanli.."")
	for k,v in pairs(self.reward_list) do
		v:OnFlush()
	end
end

function TreasureBowlView:OnSeverInfoChange()
	if not self:IsLoaded() then
		return
	end
	self:Flush()
	self.scroller.scroller:RefreshActiveCellViews()
end

---------------------------------------------------------------
--滚动条格子

TreasureBowlScrollerCell = TreasureBowlScrollerCell or BaseClass(BaseCell)

function TreasureBowlScrollerCell:__init()
	self.root_node.list_cell.refreshCell = BindTool.Bind(self.OnFlush, self)
	self.is_done = self:FindVariable("IsDone")
	self.task_icon = self:FindVariable("TaskIcon")
	self.task_name = self:FindVariable("TaskName")
	self.process_value = self:FindVariable("ProcessValue")
	self.percent_value = self:FindVariable("PercentValue")
	self:ListenEvent("Click", BindTool.Bind(self.OnItemClick, self))
end

function TreasureBowlScrollerCell:__delete()

end

function TreasureBowlScrollerCell:OnFlush()
	self.is_done:SetValue((self.data.process_value>=self.data.task_value))
	self.task_icon:SetAsset("uis/views/baoju",self.data.icon_id)
	self.task_name:SetValue(self.data.description)
	local text = ""
	if self.data.process_value>=self.data.task_value - 1 then
		text = self.data.process_value
	else
		text = ToColorStr(self.data.process_value, TEXT_COLOR.RED)
	end
	if self.data.data_index == 1 then
		self.process_value:SetValue(text.." / "..self.data.task_value - 1)
	else
		self.process_value:SetValue(text.." / "..self.data.task_value)
	end

	self.percent_value:SetValue(self.data.add_percent.."%")
end

function TreasureBowlScrollerCell:OnItemClick()
	if self.data.data_index == TREASURE_BOWL_ITEM_TYPE.DAILY_TASK then
		local count = TaskData.Instance:GetTaskTotalCount(TASK_TYPE.RI) - YunbiaoData.Instance:GetHusongRemainTimes()
		local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
		if count == 0 or task_id == 0 then
			TipsCtrl.Instance:ShowSystemMsg("日常任务已做完")
			return
		end
		if task_id > 0 then
			TaskCtrl.Instance:DoTask(task_id)
			TreasureBowlCtrl.Instance:CloseView()
		end
	elseif self.data.data_index == TREASURE_BOWL_ITEM_TYPE.GUILD_TASK then
		local guild_task = TaskData.Instance:GetNextGuildTaskConfig()
		if guild_task then
			local task_cfg = TaskData.Instance:GetTaskConfig(guild_task.task_id)
			local level = GameVoManager.Instance:GetMainRoleVo().level
			if task_cfg.min_level > level or task_cfg.max_level < level then
				TipsCtrl.Instance:ShowSystemMsg("等级还未达到")
				return
			else
				TaskCtrl.Instance:DoTask(guild_task.task_id)
				TreasureBowlCtrl.Instance:CloseView()
			end
		else
			TipsCtrl.Instance:ShowSystemMsg("目前无公会任务")
		end
	elseif self.data.data_index == TREASURE_BOWL_ITEM_TYPE.HUSONG then
		GuajiCtrl.Instance:MoveToNpc(400, nil, 103)
		TreasureBowlCtrl.Instance:CloseView()
	else
		local view_list = TreasureBowlData.Instance:GetOpenViewName(self.data.data_index)
		ViewManager.Instance:Open(view_list.view_name, view_list.tab_index)
		TreasureBowlCtrl.Instance:CloseView()
	end
end
---------------------------------------------------------------
--奖励箱子格子
TreasureBowlRewardBox = TreasureBowlRewardBox or BaseClass(BaseCell)

function TreasureBowlRewardBox:__init()
	self.have_got = self:FindVariable("HaveGot")
	self.need_jubao_value = self:FindVariable("NeedJuBaoValue")
	self.can_get = self:FindVariable("CanGet")
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function TreasureBowlRewardBox:__delete()

end

function TreasureBowlRewardBox:OnFlush()
	if self.data == nil then
		return
	end
	self.have_got:SetValue(self.data.have_got)
	self.need_jubao_value:SetValue(self.data.cornucopia_value)
	self.can_get:SetValue(self.data.can_get)
end

function TreasureBowlRewardBox:OnClick()
	if self.data.can_get and not self.data.have_got then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_CORNUCOPIA, 1, self.data.seq)
	end
end