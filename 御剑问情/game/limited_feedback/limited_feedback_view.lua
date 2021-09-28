LimitedFeedbackView = LimitedFeedbackView or BaseClass(BaseView)

local CHONGZHI_COUNT = {60,500,1500}

function LimitedFeedbackView:__init()
	self.ui_config = {"uis/views/limitedfeedback_prefab", "LimitedFeedbackView"}
	self.play_audio = true
	self.list_view_group = {}
end

function LimitedFeedbackView:__delete()

end

function LimitedFeedbackView:ReleaseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	for k,v in pairs(self.list_view_group) do
		v:DeleteMe()
	end
	self.list_view_group = {}


	--清理对象和变量
	self.list_view = nil
	self.act_time = nil
	self.cur_day_chongzhi = nil

end

function LimitedFeedbackView:LoadCallBack()
	self.act_time = self:FindVariable("ActTime")
	self.cur_day_chongzhi = self:FindVariable("CurDay_ChongZhi_Text")
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow,self))
	LimitedFeedbackData.Instance:GetLimitCfgByChongzhi()
	self:InitListView()
end

function LimitedFeedbackView:OpenCallBack()
	self:Flush()
end

function LimitedFeedbackView:InitListView()
	self.list_view = self:FindObj("ListView")
	--self.list_view_group_data = LimitedFeedbackData.Instance:GetLimitDataItemCount()
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return LimitedFeedbackData.Instance:GetLimitDataGroupCount()
	end

	list_delegate.CellRefreshDel = function (cellobj,index)
		local cell = self.list_view_group[cellobj]
		if cell == nil then
			cell = FeedbackListGroup.New(cellobj.gameObject)
			self.list_view_group[cellobj] = cell
		end
		cell:SetIndex(index+1)
		cell:SetData(LimitedFeedbackData.Instance:GetLimitDataItemByChongzhi(LimitedFeedbackData.Instance:GetChongZhiCount()[index+1]))
		cell:SetGroupCallBack(BindTool.Bind(self.OnFeedbackDayItemClick,self))
	end

end

function LimitedFeedbackView:OnFlush()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
	self.cur_day_chongzhi:SetValue(LimitedFeedbackData.Instance:GetCurDayChongZhi())
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
end

function LimitedFeedbackView:CloseWindow()
	self:Close()
end

function LimitedFeedbackView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	local time_type = 1
	if time > 3600 * 24 then
		time_type = 6
	elseif time > 3600 then
		time_type = 1
	else
		time_type = 2
	end

	self.act_time:SetValue(TimeUtil.FormatSecond(time, time_type))
end

function LimitedFeedbackView:OnFeedbackDayItemClick(cell)
	--print_log(">>>>>>>>>>>>>>>>>>",cell.index,cell.data.seq)
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LIMITTIME_REBATE,RA_LIMIT_TIME_REBATE_OPERA_TYPE.RA_LIMIT_TIME_REBATE_OPERA_TYPE_FETCH_REWARD,cell.data.seq,0)
	self:Flush()
end

-------------------------滚动Group父类格子-----------------------
FeedbackListGroup = FeedbackListGroup or BaseClass(BaseCell)

function FeedbackListGroup:__init()
	self.title_num = self:FindVariable("Title_Num")
	self.cell_list_view = self:FindObj("CellListView")

	self.list_group_data = {}
	self.list_group_cell = {}
	self.item_cell_count = 0
end

function FeedbackListGroup:__delete()
	for k,v in pairs(self.list_group_cell) do
		v:DeleteMe()
	end
	self.list_group_cell = {}

	--清理对象和变量
	self.list_group_data = {}
	self.list_view = nil
end

function FeedbackListGroup:SetData(data)
	self.list_group_data = data
	self:InitCellListView()
	self:Flush()
end

function FeedbackListGroup:SetGroupCallBack(callback)
	if callback ~= nil then
		self.callback = callback
	end
end

function FeedbackListGroup:InitCellListView()
	if #self.list_group_data <= self.item_cell_count then
		return
	end
	self.item_cell_count = #self.list_group_data
	PrefabPool.Instance:Load(AssetID("uis/views/limitedfeedback_prefab", "FeedbackDayItem"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, #self.list_group_data do
            local obj = GameObject.Instantiate(prefab)
            obj.transform:SetParent(self.cell_list_view.transform, false)
            cell = FeedbackDayItem.New(obj)
            self.list_group_cell[i] = cell

            cell:SetIndex((self.index - 1) * #self.list_group_data + i - 1)
			cell:SetData(self.list_group_data[i])
			cell:SetItemCallBack(self.callback)
        end

        PrefabPool.Instance:Free(prefab)
        self.is_load = true
        self:Flush()
    end)
end

function FeedbackListGroup:OnFlush()
	if self.list_group_data and self.list_group_data[1] then
		self.title_num:SetValue(self.list_group_data[1].chongzhi_count)
		for k,v in ipairs(self.list_group_cell) do
			v:SetIndex((self.index - 1) * #self.list_group_data + k - 1)
			v:SetData(self.list_group_data[k])
			v:SetItemCallBack(self.callback)
		end
	end
end

----------------------限时反馈天数格子-------------------------
FeedbackDayItem = FeedbackDayItem or BaseClass(BaseCell)

function FeedbackDayItem:__init()
	self.day_num = self:FindVariable("Day_Num")
	self.show_effect = self:FindVariable("Show_Effect")
	self.is_get = self:FindVariable("Is_Get")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell:ShowHighLight(false)
end

function FeedbackDayItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
	end

end

function FeedbackDayItem:SetItemCallBack(callback)
	if callback ~= nil then
		self.callback = callback
	end
end

function FeedbackDayItem:OnFlush()
	-- print_error("HelloWorld....")
	self.day_num:SetValue(self.data.chongzhi_day)
	self.item_cell:SetData(self.data.reward)

	local cur_day_chongzhi = LimitedFeedbackData.Instance:GetCurDayChongzhiByDay(self.data.chongzhi_count,self.data.chongzhi_day)
	local chongzhi_day = LimitedFeedbackData.Instance:GetChongZhiDay(self.data.chongzhi_count)
	local flag = LimitedFeedbackData.Instance:GetRewardFlagByIndex(self.index)

	if cur_day_chongzhi >= self.data.chongzhi_count and chongzhi_day >= self.data.chongzhi_day and flag ~= 1 then
		self.item_cell:ShowGetEffect(true)
		-- self.show_effect:SetValue(true)
		self.item_cell:ListenClick(BindTool.Bind(self.OnClick,self))
	else
		self.item_cell:ShowGetEffect(false)
		-- self.show_effect:SetValue(false)
		self.item_cell:ListenClick(nil)
	end

	self.is_get:SetValue(flag == 1)

end

function FeedbackDayItem:OnClick()
	if nil ~= self.callback then
		self.callback(self)
	end
end