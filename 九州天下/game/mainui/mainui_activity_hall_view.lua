MainuiActivityHallView = MainuiActivityHallView or BaseClass(BaseView)
local PAGE_COUNT = 8
local ACTIVITY_ID_HALL = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SUPER_CARGE_FEEDBACK] = true,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_4] = true,
	[ACTIVITY_TYPE.RAND_LOTTERY_TREE] = true,
}

function MainuiActivityHallView:__init()
	self.ui_config = {"uis/views/main", "MainuiActivityHall"}
	-- self.view_layer = UiLayer.Pop
	self.list_cell = {}
	self.data_list = {}
	self:SetMaskBg()
end

function MainuiActivityHallView:__delete()

end

function MainuiActivityHallView:ReleaseCallBack()
	for k,v in pairs(self.list_cell) do
		if nil ~= v then
			v:DeleteMe()
		end
	end
	self.list_cell = {}
	self.data_list = {}

	self.list_view = nil
	self.data_count = nil
	if self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function MainuiActivityHallView:LoadCallBack()

	self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.data_count = self:FindVariable("DataCount")

	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Bind(self.remind_change, RemindName.ACTIVITY_JUAN_ZHOU)
end

function MainuiActivityHallView:RemindChangeCallBack(remind_name, num)
	self:FlushRankActivityRed()
end
function MainuiActivityHallView:GetNumberOfCells()
	local count = math.ceil(#self.data_list / PAGE_COUNT)
	if self.data_count then
		self.data_count:SetValue(count)
		self.list_view.list_page_scroll:SetPageCount(count)
	end
	return count
end

function MainuiActivityHallView:RefreshCell(cell, data_index)
	-- 构造Cell对象.
	local item = self.list_cell[cell]
	if nil == item then
		item = MainuiActivityHallGroup.New(cell)
		self.list_cell[cell] = item
	end

	local data = {}
	for i = 1, PAGE_COUNT do
		if self.data_list[data_index * PAGE_COUNT + i] then
			table.insert(data, self.data_list[data_index * PAGE_COUNT + i])
		else
			break
		end
	end
	item:SetData(data)

end

function MainuiActivityHallView:CloseWindow()
	self:Close()
end

function MainuiActivityHallView:CloseCallBack()

end

function MainuiActivityHallView:OpenCallBack()
	self:Flush()
    MainuiActivityHallData.Instance:FlushActRedPoint()
end

function MainuiActivityHallView:OnFlush()
	self.data_list = ActivityData.Instance:GetActivityHallDatalist()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MainuiActivityHallView:FlushRankActivityRed()
	if self.list_view and self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

----------------------------------------------------------------------------
--MainuiActivityHallGroup 		列表滚动条格子
----------------------------------------------------------------------------

MainuiActivityHallGroup = MainuiActivityHallGroup or BaseClass(BaseCell)

function MainuiActivityHallGroup:__init()
	self.cell_list = {}
	self.data = {}
	for i = 1, PAGE_COUNT do
		PrefabPool.Instance:Load(AssetID("uis/views/main_prefab", "MainuiActivityHallIcon"), function (prefab)
			if nil == prefab or nil == self.root_node then
				return
			end
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			obj_transform:SetParent(self.root_node.transform, false)
			local item = MainuiActivityHallCell.New(obj)
			table.insert(self.cell_list, item)
			PrefabPool.Instance:Free(prefab)
			if #self.cell_list == PAGE_COUNT then
				self:SetData(self.data)
			end
		end)
	end
end

function MainuiActivityHallGroup:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function MainuiActivityHallGroup:SetData(data)
	self.data = data
	if #self.cell_list < PAGE_COUNT then return end
	for k,v in pairs(self.cell_list) do
		v:SetData(data[k])
		v:SetActive(data[k] ~= nil)
	end
end


----------------------------------------------------------------------------
--MainuiActivityHallCell 		列表滚动条格子
----------------------------------------------------------------------------

MainuiActivityHallCell = MainuiActivityHallCell or BaseClass(BaseCell)

function MainuiActivityHallCell:__init()
	self.res = self:FindVariable("Res")
	self.red = self:FindVariable("Red")
	self.eff = self:FindVariable("ShowEffect")
	self.show = self:FindVariable("Show")
	self.act_times = self:FindVariable("ActTimes")
	self:ListenEvent("Click",BindTool.Bind(self.OnButtonClick, self))
end

function MainuiActivityHallCell:__delete()
	if self.act_next_timer then
		GlobalTimerQuest:CancelQuest(self.act_next_timer)
		self.act_next_timer = nil
	end
end

function MainuiActivityHallCell:OnFlush()
	if not self.data or not next(self.data) then return end
	local act_cfg = ActivityData.Instance:GetActivityConfig(self.data.type)
	if act_cfg then
		self.res:SetAsset(ResPath.GetMainUIButton(act_cfg.icon))
	end
	self:FlushRedPointInCell()
	self:SetHuoDongActTime(self.data.type)
end

function MainuiActivityHallCell:SetActive(value)
	self.show:SetValue(value)
end

-- 红点刷新
function MainuiActivityHallCell:FlushRedPointInCell()
	local act_red = ActivityData.Instance:GetActivityRedPointState(self.data.type)
	local act_num = ActivityData.Instance:GetActivityRedPointNum()
	self.red:SetValue(act_red)
	-- local show = MainuiActivityHallData.Instance:GetShowOnceEff(self.data.type)
	-- local bendi_day = UnityEngine.PlayerPrefs.GetInt("activity_hall_day" .. self.data.type)
	-- local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	-- if cur_day ~= bendi_day then
	-- 	self.eff:SetValue(true)
	-- else
	-- 	self.eff:SetValue(false)
	-- end

	if act_num == 0 then
		-- 开启活动时，卷轴里面的活动默认显示红点
		self.red:SetValue(true)
		-- self.eff:SetValue(true)
	end
end

function MainuiActivityHallCell:OnButtonClick()
	local act_cfg = ActivityData.Instance:GetActivityConfig(self.data.type)
	if act_cfg then
		-- 开服活动处理
		if act_cfg.open_name == ViewName.KaifuActivityView then
			ViewManager.Instance:Open(act_cfg.open_name, act_cfg.act_id + 100000)
		else
			local flag = string.find(act_cfg.open_name, "#")
			if flag then
				local tab = Split(act_cfg.open_name, "#")
				ViewManager.Instance:Open(tab[1], TabIndex[tab[2]])
			else
				ViewManager.Instance:Open(act_cfg.open_name)
			end
		end
		
		MainuiActivityHallData.Instance:SetShowOnceEff(self.data.type,false)
		-- self.eff:SetValue(false)

		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		if cur_day > -1 then
			UnityEngine.PlayerPrefs.SetInt("activity_hall_day" .. self.data.type, cur_day)
		end
	end
end

-- 活动倒计时
function MainuiActivityHallCell:SetHuoDongActTime(act_type)
	self:FlushNextTime(act_type)
	if nil == self.act_next_timer then
		self.act_next_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self,act_type), 1)
	end
end

function MainuiActivityHallCell:FlushNextTime(act_type)
	if not self.data or not next(self.data) then return end
	act_type = self.data.type
	if ACTIVITY_ID_HALL[self.data.type] then -- 当天倒计时
		if self.act_times then
			self.act_times:SetValue(self:GetDayTime())
		end
		return
	end
	local act_time = self:GetActEndTime(act_type)
	if act_time >= (24 * 3600 * 10) then
		-- 00天00时
		self.act_times:SetValue(TimeUtil.FormatSecond2DHMS(act_time,2))
	elseif act_time > (24 * 3600) then
		local hour_time = act_time - math.floor(act_time / (24 * 3600)) * (24 * 3600)
		if hour_time >= (10 * 3600) then
			self.act_times:SetValue(TimeUtil.FormatSecond2DHMS(act_time,3))
		else
			self.act_times:SetValue(TimeUtil.FormatSecond2DHMS(act_time,4))
		end
	elseif act_time > 3600 then
		if act_time >= (10 * 3600) then
			self.act_times:SetValue(TimeUtil.FormatSecond2DHMS(act_time,3))
		else
			self.act_times:SetValue(TimeUtil.FormatSecond2DHMS(act_time,4))
		end
	else
		self.act_times:SetValue(TimeUtil.FormatSecond(act_time, 2))
	end
	if act_time <= 0 then
		if self.act_next_timer then
			GlobalTimerQuest:CancelQuest(self.act_next_timer)
			self.act_next_timer = nil
		end
	end
end

function MainuiActivityHallCell:GetDayTime()
	local server_time = TimeCtrl.Instance:GetServerTime()
	local end_time = TimeUtil.NowDayTimeEnd(server_time)
	local time = end_time - server_time
	local str = TimeUtil.FormatSecond(time)
	return str
end

--返回活动结束时间
function MainuiActivityHallCell:GetActEndTime(act_type)
	local act_info = ActivityData.Instance:GetActivityStatuByType(act_type)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
		if act_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_2 then
			IncreaseCapabilityData.Instance:SetRestTime(time)
		end
		if act_type == RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SINGLE_CHARGE_3 then
			IncreaseSuperiorData.Instance:SetRestTime(time)
		end
		if act_type == ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW then
			LuckyDrawData.Instance:SetRestTime(time)
		end
		-- return time
	end

	local end_time = ActivityData.Instance:GetActivityResidueTime(act_type)
	return end_time
end
