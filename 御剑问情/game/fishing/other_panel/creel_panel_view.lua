-- 鱼篓面板
CreelPanelView = CreelPanelView or BaseClass(BaseRender)

function CreelPanelView:__init()

	self.myfish_num = {}
	
	for i = 1, 7 do
		self.myfish_num[i] = self:FindVariable("Fish_" .. i)
	end

	self.time_text = self:FindVariable("TimeText")

	----------------------------------------------------
	-- 列表生成滚动条
	self.fishing_creel_cell_list = {}
	self.creel_listview_data = {}
	self.creel_list = self:FindObj("CreelListView")
	local creel_list_delegate = self.creel_list.list_simple_delegate

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnBtnClose, self))
	--生成数量
	creel_list_delegate.NumberOfCellsDel = function()
		return #self.creel_listview_data or 0
	end
	--刷新函数
	creel_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFishingCreelListView, self)
	----------------------------------------------------

	----------------------------------------------------
	-- 列表生成日志滚动条
	self.fishing_creel_log_cell_list = {}
	self.creel_log_listview_data = {}
	self.creel_log_list = self:FindObj("CreelLogListView")
	local creel_log_list_delegate = self.creel_log_list.list_simple_delegate
	--生成数量
	creel_log_list_delegate.NumberOfCellsDel = function()
		return #self.creel_log_listview_data or 0
	end
	--刷新函数
	creel_log_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshFishingCreelLogListView, self)

	self:Flush()
	self:ShowIndexCallBack()
end

function CreelPanelView:__delete()

	if self.fishing_creel_cell_list then
		for k,v in pairs(self.fishing_creel_cell_list) do
			v:DeleteMe()
		end
	end
	self.fishing_creel_cell_list = {}

	if self.fishing_creel_log_cell_list then
		for k,v in pairs(self.fishing_creel_log_cell_list) do
			v:DeleteMe()
		end
	end
	self.myfish_num = {}
	self.fishing_creel_log_cell_list = {}

	if self.count_down ~= nil then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function CreelPanelView:LoadCallBack(instance)

	----------------------------------------------------

end

function CreelPanelView:OnBtnClose()
     FishingCtrl.Instance:OnOpenCreelHandler()
end

function CreelPanelView:OnFlush(param_list)

	--设置我的鱼篓
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT - 1 do
		if self.myfish_num[i] then
			self.myfish_num[i]:SetValue(CrossFishingData.Instance:GetFishingUserInfo().fish_num_list[i + 1])
		end
	end

	-- 设置list数据
	local combination_cfg = TableCopy(CrossFishingData.Instance:GetFishingCombinationCfg())
	table.insert(combination_cfg, 1, combination_cfg[0])
	combination_cfg[0] = nil
	self.creel_listview_data = combination_cfg
	if self.creel_list.scroller.isActiveAndEnabled then
		self.creel_list.scroller:ReloadData(0)
	end

	-- 设置日志list数据
	local fishing_user_info = CrossFishingData.Instance:GetFishingUserInfo()
	if fishing_user_info.news_list then
		self.creel_log_listview_data = fishing_user_info.news_list
		if self.creel_log_list.scroller.isActiveAndEnabled then
			self.creel_log_list.scroller:ReloadData(0)
		end
	end

end

function CreelPanelView:ShowIndexCallBack()
	local activity_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.KF_FISHING)
	if activity_info then
		local diff_time = activity_info.next_time - TimeCtrl.Instance:GetServerTime()
		self:SetActTime(diff_time)
	end
end

-- 活动倒计时
function CreelPanelView:SetActTime(diff_time)
	if self.count_down == nil then
		function diff_time_func(elapse_time, total_time)
			local left_time = math.floor(diff_time - elapse_time + 0.5)
			if left_time <= 0 then
				if self.count_down ~= nil then
					CountDown.Instance:RemoveCountDown(self.count_down)

					self.count_down = nil
				end
				return
			end
			self.time_text:SetValue(TimeUtil.FormatSecond2Str(left_time))
		end

		diff_time_func(0, diff_time)
		self.count_down = CountDown.Instance:AddCountDown(diff_time, 0.5, diff_time_func)
	end
end


-- 列表listview
function CreelPanelView:RefreshFishingCreelListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local creel_cell = self.fishing_creel_cell_list[cell]
	if creel_cell == nil then
		creel_cell = FishingCreelPanelItemRender.New(cell.gameObject)
		-- creel_cell:SetToggleGroup(self.creel_list.toggle_group)
		-- creel_cell:SetClickCallBack(BindTool.Bind1(self.ClickCampAuctionHandler, self))
		self.fishing_creel_cell_list[cell] = creel_cell
	end
	creel_cell:SetIndex(data_index)
	creel_cell:SetData(self.creel_listview_data[data_index])
end

-- 日志列表listview
function CreelPanelView:RefreshFishingCreelLogListView(cell, data_index, cell_index)
	data_index = data_index + 1

	local creel_log_cell = self.fishing_creel_log_cell_list[cell]
	if creel_log_cell == nil then
		creel_log_cell = FishingCreelLogItemRender.New(cell.gameObject)
		self.fishing_creel_log_cell_list[cell] = creel_log_cell
	end
	creel_log_cell:SetIndex(data_index)
	creel_log_cell:SetData(self.creel_log_listview_data[data_index])
end

----------------------------------------------------------------------------
--FishingCreelPanelItemRender	鱼篓itemder
----------------------------------------------------------------------------
FishingCreelPanelItemRender = FishingCreelPanelItemRender or BaseClass(BaseCell)
function FishingCreelPanelItemRender:__init()
	self.lbl_fish_num = {}

	self.fish = CrossFishingData.Instance:GetFishingFishCfg()
	for i = 1, #self.fish do
		self.lbl_fish_num[i] = self:FindVariable("FishNum_" .. i)
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.show_redpoint = self:FindVariable("Show_RedPoint")

	self:ListenEvent("OnBtnExchange", BindTool.Bind(self.OnBtnExchangeHandler, self))
	self:ListenEvent("OnTime", BindTool.Bind(self.OnTimeHandler,self))


	self.myfishing_num = {}	
	for i = 1, 7 do
		self.myfishing_num[i] = self:FindVariable("Fishing_" .. i)
	end
end

function FishingCreelPanelItemRender:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.fish = nil
	self.myfishing_num = {}
end

function FishingCreelPanelItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	for i = 1, #self.fish do
		if self.lbl_fish_num[i] then
			self.lbl_fish_num[i]:SetValue(self.data["fish_type_" .. i])
		end
	end

	if self.item_cell then
		self.item_cell:SetData(self.data.reward_item)
	end

	local can_reward = true
	for i = 1, GameEnum.FISHING_FISH_TYPE_MAX_COUNT - 1 do
		if self.myfishing_num[i] then
			local myfishing_num = CrossFishingData.Instance:GetFishingUserInfo().fish_num_list[i + 1]
			
			if self.data["fish_type_" .. i] and myfishing_num >= self.data["fish_type_" .. i]  then
				self.myfishing_num[i]:SetValue(ToColorStr(myfishing_num, TEXT_COLOR.GREEN))
			else
				if nil ~= self.data["fish_type_" .. i] then
					can_reward = false
				end
				self.myfishing_num[i]:SetValue(ToColorStr(myfishing_num, TEXT_COLOR.RED))
			end
		end
	end

	self.show_redpoint:SetValue(can_reward)
end

function FishingCreelPanelItemRender:OnBtnExchangeHandler()
	if not self.data or not next(self.data) then return end
	FishingCtrl.Instance:SendFishingExchange(self.data.index)
end

function  FishingCreelPanelItemRender:OnTimeHandler()
	CrossFishingData.Instance:SetCreelViewtime(1)
end


----------------------------------------------------------------------------
--FishingCreelLogItemRender	鱼篓日志itemder
----------------------------------------------------------------------------
FishingCreelLogItemRender = FishingCreelLogItemRender or BaseClass(BaseCell)
function FishingCreelLogItemRender:__init()
	self.lbl_log_text = self:FindVariable("LogText")
end

function FishingCreelLogItemRender:__delete()
end

function FishingCreelLogItemRender:OnFlush()
	if not self.data or not next(self.data) then return end
	
	if self.lbl_log_text then
		local str = ""
		local fish_cfg = CrossFishingData.Instance:GetFishingFishCfgByType(self.data.fish_type)
		if fish_cfg then
			if self.data.news_type == FISHING_NEWS_TYPE.FISHING_NEWS_TYPE_STEAL then
				str = string.format(Language.Fishing.LabelFishingSteal, self.data.user_name, fish_cfg.name)
			elseif self.data.news_type == FISHING_NEWS_TYPE.FISHING_NEWS_TYPE_BE_STEAL then
				str = string.format(Language.Fishing.LabelFishingBeSteal, self.data.user_name, fish_cfg.name)
			end
		end
		self.lbl_log_text:SetValue(str)
	end
end
