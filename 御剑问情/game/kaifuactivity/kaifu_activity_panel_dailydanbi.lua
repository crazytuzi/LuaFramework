OpenActDailyDanBi =  OpenActDailyDanBi or BaseClass(BaseRender)

function OpenActDailyDanBi:__init()
	self.contain_cell_list = {}
end

function OpenActDailyDanBi:__delete()
	self.list_view = nil
	self.rest_time = nil
	self.contain_cell_list = nil
end

function OpenActDailyDanBi:OpenCallBack()
    self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DANBI_CHONGZHI)
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))

	self:ListenEvent("ClickQianWangChongZhi", BindTool.Bind(self.ClickQianWangChongZhi, self))
	self.reward_list = KaifuActivityData.Instance:GetOpenActDailyDanBiReward()
end

function OpenActDailyDanBi:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function OpenActDailyDanBi:ClickQianWangChongZhi()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function OpenActDailyDanBi:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetOpenActDailyDanBiReward()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
end

function OpenActDailyDanBi:FlushTotalConsume()
	self:Flush()
end

function OpenActDailyDanBi:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	-- local time_tab = TimeUtil.Format2TableDHMS(rest_time)
	-- local temp = {}
	-- for k,v in pairs(time_tab) do
	-- 	if k ~= "day" then
	-- 		if v < 10 then
	-- 			v = tostring('0'..v)
	-- 		end
	-- 	end
	-- 	temp[k] = v
	-- end
	-- local str = string.format(Language.Activity.ChongZhiRankRestTime, temp.day, temp.hour, temp.min, temp.s)
	-- str = TimeUtil.FormatSecond(rest_time, 6)
	local time_str = ""
	local day_second = 24 * 60 * 60         -- 一天有多少秒
	local left_day = math.floor(rest_time / day_second)
	if left_day > 0 then
		time_str = TimeUtil.FormatSecond(rest_time, 7)
	elseif rest_time < day_second then
		if math.floor(rest_time / 3600) > 0 then
			time_str = TimeUtil.FormatSecond(rest_time, 1)
		else
			time_str = TimeUtil.FormatSecond(rest_time, 2)
		end
	end
	self.rest_time:SetValue(time_str)
end

function OpenActDailyDanBi:GetNumberOfCells()
	return #self.reward_list
end

function OpenActDailyDanBi:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = OpenActDailyDanBiCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------OpenActDailyTotalConsumeCell---------------------------------
OpenActDailyDanBiCell = OpenActDailyDanBiCell or BaseClass(BaseCell)

function OpenActDailyDanBiCell:__init()
	self.data = {}
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.daily_danbi_tip = self:FindVariable("cur_value")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.item_cell_obj_list = {}
	self.item_cell_list = {}
	self:ListenEvent("OnClickGet", BindTool.Bind(self.OnClickGet, self))
	for i = 1, 4 do
		self.item_cell_obj_list[i] = self:FindObj("item_"..i)
		local item_cell = ItemCell.New()
		self.item_cell_list[i] = item_cell
		item_cell:SetInstanceParent(self.item_cell_obj_list[i])
	end
end

function OpenActDailyDanBiCell:__delete()
	self.show_text = nil
	self.show_interactable = nil
	self.daily_danbi_tip = nil
	self.can_lingqu = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function OpenActDailyDanBiCell:SetData(data)
	self.data = data
end

function OpenActDailyDanBiCell:OnFlush()
	local info = KaifuActivityData.Instance:GetDailyDanBiInfo()
	self.daily_danbi_tip:SetValue(string.format(Language.Activity.DanBiChongZhiTips, self.data.need_chongzhi_num))
	local reward_list = ServerActivityData.Instance:GetCurrentRandActivityRewardCfg(self.data.reward_item, true)

	for i = 1, 4 do
		if reward_list[i] then
			self.item_cell_list[i]:SetData(reward_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local fetch_reward_flag = self.data.fetch_reward_flag == 1
	local str = fetch_reward_flag and Language.Common.YiLingQu or (1 == self.data.can_fetch_reward_flag and Language.Common.LingQu or Language.Common.WEIDACHENG)
	self.show_text:SetValue(str)
	self.show_interactable:SetValue(not fetch_reward_flag and 1 == self.data.can_fetch_reward_flag)
	self.can_lingqu:SetValue(not fetch_reward_flag and 1 == self.data.can_fetch_reward_flag)
end

function OpenActDailyDanBiCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(ACTIVITY_TYPE.RAND_DAY_DANBI_CHONGZHI, RA_SINGLE_CHONGZHI_OPERA_TYPE.RA_SINGLE_CHONGZHI_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end