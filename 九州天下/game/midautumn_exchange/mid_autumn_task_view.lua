MidAutumnTaskView = MidAutumnTaskView or BaseClass(BaseView)

function MidAutumnTaskView:__init()
	self.ui_config = {"uis/views/midautumn", "MidAutumnTaskView"}
	self.play_audio = true
	self:SetMaskBg()
	self.contain_cell_list = {}
	self.reward_list = {}
	self.activedegree_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()[1]
end

function MidAutumnTaskView:LoadCallBack()
	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))
	self:ListenEvent("OnBtnTips", BindTool.Bind(self.OnBtnTipsHandler, self))
	self.rest_time = self:FindVariable("ActTime")

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	
	self.current_active = MidAutumnTaskData.Instance:GetCurrentActive()
	self.activity_count = self:FindVariable("activity_count")
	self.activity_count:SetValue(self.current_active)

	self:ListenEvent("ClickGetActivity", BindTool.Bind(self.ClickGetActivity, self))
	self.reward_list = MidAutumnTaskData.Instance:GetDayActiveDegreeInfoList()

	self:InitScroller()
end

function MidAutumnTaskView:__delete()
	self.reward_list = {}

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	self.cell_list = {}
end

function MidAutumnTaskView:OnBtnTipsHandler()
	TipsCtrl.Instance:ShowHelpTipView(263)
end

function MidAutumnTaskView:ClickReChange()
	ViewManager.Instance:Open(ViewName.RechargeView)
end

function MidAutumnTaskView:ReleaseCallBack()
	for k, v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end
	self.contain_cell_list = {}
	self.rest_time = nil
	self.activity_count = nil
	self.list_view = nil
	self.current_active = nil
	self.LeftScroll = nil

end

function MidAutumnTaskView:SetTime(remaining_second)
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

function MidAutumnTaskView:InitScroller()
	self.cell_list = {}
	self.scroller_data = ZhiBaoData.Instance:GetActiveDegreeScrollerData()
	self.LeftScroll = self:FindObj("LeftScroll")
	local delegate = self.LeftScroll.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #self.scroller_data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1
		if nil == self.cell_list[cell] then
			self.cell_list[cell] = MidAutDegreeItem.New(cell.gameObject)
			self.cell_list[cell]:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		end
		self.cell_list[cell]:SetIndex(data_index)
		self.cell_list[cell]:SetSelect(self.cur_select_index)
		self.cell_list[cell]:SetData(self.scroller_data[data_index])
	end
end

function MidAutumnTaskView:GetNumberOfCells()
	return #self.reward_list
end

function MidAutumnTaskView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data then return end
	self.cur_select_index = cell.index
	self.activedegree_data = cell.data
	self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
end

function MidAutumnTaskView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = MidAutumnTaskCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end	
	cell_index = cell_index + 1
	contain_cell:SetCurrentActive(self.current_active)
	contain_cell:SetData(self.reward_list[cell_index])
end

function MidAutumnTaskView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_REWARD_TASK, 
			RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_QUERY_INFO)
	local rest_time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_REWARD_TASK)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	self:SetTime(rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
            self:SetTime(rest_time)
        end)
	self:Flush()
end

function MidAutumnTaskView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function MidAutumnTaskView:SetCurTyoe(cur_type)
	self.cur_type = cur_type
end

function MidAutumnTaskView:OnFlush(param_t)
	self.reward_list = MidAutumnTaskData.Instance:GetDayActiveDegreeInfoList()
	self.current_active = MidAutumnTaskData.Instance:GetCurrentActive()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.activity_count:SetValue(self.current_active)
end

function MidAutumnTaskView:ClickGetActivity()
	ViewManager.Instance:Open(ViewName.BaoJu)
	ViewManager.Instance:Close(ViewName.ActivityMidAutumnView)
	self:Close()
end

----------------------------MidAutumnTaskCell---------------------------------
MidAutumnTaskCell = MidAutumnTaskCell or BaseClass(BaseCell)

function MidAutumnTaskCell:__init()
	self.item_cell_obj = self:FindObj("item_1")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item_cell_obj)
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	self.tips = self:FindVariable("tips")
	self.is_take = self:FindVariable("is_take")
	self.is_able_get = self:FindVariable("is_able_get")
end

function MidAutumnTaskCell:__delete()
	self.item_cell_obj = nil
	self.item_cell = nil
	self.tips = nil
	self.is_take = nil
	self.is_able_get = nil
end

function MidAutumnTaskCell:SetCurrentActive(current_active)
	self.current_active = current_active
end

function MidAutumnTaskCell:OnFlush()
	self.item_cell:SetData(self.data.reward_item)
	local color = "ffffff"
	if self.data.need_active > self.current_active then
		color = "ffffff"
	end
	--是否能领取
	local str = string.format(Language.Activity.DayActiveRewardTips, self.data.need_active, color, self.current_active, self.data.need_active)
	self.tips:SetValue(str)
	self.is_able_get:SetValue(self.current_active >= self.data.need_active)
	if self.data.fetch_reward_flag == 1 then
		self.is_take:SetValue(true)
	else
		self.is_take:SetValue(false)
	end
end

function MidAutumnTaskCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_REWARD_TASK,
		RA_DAY_ACTIVE_DEGREE_OPERA_TYPE.RA_DAY_ACTIVE_DEGREE_OPERA_TYPE_FETCH_REWARD, 
		self.data.seq)
end


----------------------------------------------------------------------------
--MidAutDegreeItem 		活跃滚动条格子
----------------------------------------------------------------------------
MidAutDegreeItem = MidAutDegreeItem or BaseClass(BaseCell)
function MidAutDegreeItem:__init(instance)
	self.exp = self:FindVariable("Exp")
	self.item_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.times = self:FindVariable("Times")
	self:ListenEvent("GoClick", BindTool.Bind(self.OnClick, self))
	self.have_go_to = self:FindVariable("HaveGoTo")
	self.is_grey = self:FindVariable("is_grey")
	self.is_show_time = self:FindVariable("is_show_time")
	self.time = self:FindVariable("time")
	self.show_arrow = self:FindVariable("show_arrow")
	self.show_select = self:FindVariable("ShowSelect")
	self.show_red = self:FindVariable("ShowRed")

	--引导用按钮
	self.btn_go = self:FindObj("BtnGo")
	
	self.active_degree_item = self:FindObj("ActiveDegreeItem")
end

function MidAutDegreeItem:__delete()

end

function MidAutDegreeItem:OnFlush()
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	self.exp:SetValue(self.data.once_add_degree)
	self.item_name:SetValue(self.data.act_name)
	self.icon:SetAsset(ResPath.GetMidAutImage(self.data.pic_id))
	self.times:SetValue(degree..' / '..self.data.max_times)
	self.show_red:SetValue(degree < self.data.max_times)
	if self.data.type == 0 then
		if degree >= self.data.max_times then
			self.is_show_time:SetValue(false)
		else
			self.is_show_time:SetValue(true)
		end
	else
		self.is_show_time:SetValue(false)
	end

	if degree >= self.data.max_times then
		self.is_grey:SetValue(true)
	else
		self.is_grey:SetValue(false)
	end

	if self.data.goto_panel ~= nil and self.data.goto_panel ~= "" then
		self.have_go_to:SetValue(false)
	else
		self.have_go_to:SetValue(false)
	end
end

function MidAutDegreeItem:SetSelect(index)
	self.show_select:SetValue(index == self.index)
end

--引导用
function MidAutDegreeItem:GetDailyName()
	local data = self.data or {}
	return data.act_name
end

function MidAutDegreeItem:GetGotoPanel()
	local data = self.data or {}
	return data.goto_panel
end

function MidAutDegreeItem:ShowArrow(is_show)
	local degree = ZhiBaoData.Instance:GetActiveDegreeListBySeq(self.data.show_seq) or 0
	local is_show = is_show and degree < self.data.max_times and self.data.act_name ~= "在线小时"
	self.show_arrow:SetValue(false)
end

function MidAutDegreeItem:GetHeight()
	return self.root_node.rect.rect.height
end

function MidAutDegreeItem:GetActiveDegreeItem()
	return self.active_degree_item
end

function MidAutDegreeItem:OnClick()
	if nil == self.data then return end
	
	if self.data.goto_panel ~= "" then
		if self.data.goto_panel == "GuildTask" then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.GUILD)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotGuildTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.ActivityMidAutumnView)
			ViewManager.Instance:Close(ViewName.MidAutumnTaskView)
			return
		elseif self.data.goto_panel == "DailyTask"then
			local task_id = TaskData.Instance:GetRandomTaskIdByType(TASK_TYPE.RI)
			print("task_id:  "..task_id)
			if task_id == nil or task_id == 0 then
				TipsCtrl.Instance:ShowSystemMsg(Language.BaoJu.NotDailyTask)
				return
			end
			TaskCtrl.Instance:DoTask(task_id)
			ViewManager.Instance:Close(ViewName.ActivityMidAutumnView)
			ViewManager.Instance:Close(ViewName.MidAutumnTaskView)
			return
		elseif self.data.goto_panel == "HuSong"then
			ViewManager.Instance:Close(ViewName.ActivityMidAutumnView)
			ViewManager.Instance:Close(ViewName.MidAutumnTaskView)
			YunbiaoCtrl.Instance:MoveToHuShongReceiveNpc()
			return
		end
		ViewManager.Instance:Close(ViewName.BaoJu)
		local t = Split(self.data.goto_panel, "#")
		local view_name = t[1]
		local tab_index = t[2]
		if view_name == "FuBen" then
			FuBenCtrl.Instance:SendGetPhaseFBInfoReq()
			FuBenCtrl.Instance:SendGetExpFBInfoReq()
			FuBenCtrl.Instance:SendGetStoryFBGetInfo()
			FuBenCtrl.Instance:SendGetVipFBGetInfo()
			FuBenCtrl.Instance:SendGetTowerFBGetInfo()
		elseif view_name == "Activity" then
			ActivityCtrl.Instance:ShowDetailView(ACTIVITY_TYPE[tab_index])
			return
		end
		ViewManager.Instance:Open(view_name, TabIndex[tab_index])
	end
end
