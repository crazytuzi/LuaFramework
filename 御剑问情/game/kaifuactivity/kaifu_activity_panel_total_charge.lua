TotalCharge =  TotalCharge or BaseClass(BaseRender)

function TotalCharge:__init()
	self.contain_cell_list = {}
end

function TotalCharge:__delete()
	self.list_view = nil
	self.rest_time = nil
	self.contain_cell_list = nil
	self.chongzhi_count = nil
end

function TotalCharge:OpenCallBack()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE,
		RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_QUERY_INFO)

    self.list_view = self:FindObj("ListView")

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.rest_time = self:FindVariable("rest_time")
	self.chongzhi_count = self:FindVariable("xiaofei_count")

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
	end
	local rest_time, next_time = ActivityData.Instance:GetActivityResidueTime(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE)
	self:SetTime(0, rest_time)
	self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, BindTool.Bind(self.SetTime, self))

	self:ListenEvent("ClickReChange", BindTool.Bind(self.ClickReChange, self))

	self.reward_list = KaifuActivityData.Instance:GetOpenActTotalChargeRewardCfg()
end

function TotalCharge:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end
end

function TotalCharge:ClickReChange()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function TotalCharge:OnFlush()
	self.reward_list = KaifuActivityData.Instance:GetOpenActTotalChargeRewardCfg()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end

	local info = KaifuActivityData.Instance:GetTotalChargeInfo()
	if self.chongzhi_count then
		self.chongzhi_count:SetValue(info.total_charge_value or 0)
	end
end

-- function TotalCharge:FlushTotalConsume()
-- 	self:Flush()
-- end

function TotalCharge:SetTime(elapse_time, total_time)
	local rest_time = math.floor(total_time - elapse_time)
	-- local left_day = math.floor(rest_time / 86400)
	-- if left_day > 0 then
	-- 	time_str = TimeUtil.FormatSecond(rest_time, 8)
	-- else
	-- 	time_str = TimeUtil.FormatSecond(rest_time)
	-- end
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

function TotalCharge:GetNumberOfCells()
	return #self.reward_list
end

function TotalCharge:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = TotalChargeCell.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end

	cell_index = cell_index + 1
	contain_cell:SetData(self.reward_list[cell_index])
	contain_cell:Flush()
end

----------------------------TotalChargeCell---------------------------------
TotalChargeCell = TotalChargeCell or BaseClass(BaseCell)

function TotalChargeCell:__init()
	self.total_value = self:FindVariable("total_value")
	self.cur_value = self:FindVariable("cur_value")
	self.show_interactable = self:FindVariable("show_interactable")
	self.show_text = self:FindVariable("show_text")
	self.can_lingqu = self:FindVariable("can_lingqu")
	self.color = self:FindVariable("color")
	-- self.color_2 = self:FindVariable("color_2")
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

function TotalChargeCell:__delete()
	self.total_value = nil
	self.cur_value = nil
	self.show_text = nil
	self.show_interactable = nil
	self.can_lingqu = nil
	self.color = nil
	-- self.color_2 = nil
	self.item_cell_obj_list = {}
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

-- function TotalChargeCell:SetData(data)
-- 	self.data = data
-- end

function TotalChargeCell:OnFlush()
	if self.data == nil then return end

	local info = KaifuActivityData.Instance:GetTotalChargeInfo()

	self.total_value:SetValue(self.data.need_chognzhi)
	local cur_value = info.total_charge_value or 0
	local color = cur_value >= self.data.need_chognzhi and TEXT_COLOR.BLUE_SPECIAL or COLOR.RED
	self.color:SetValue(color)
	self.cur_value:SetValue(cur_value)
	-- self.color_2:SetValue(COLOR.GREEN)


	local item_list = ItemData.Instance:GetGiftItemList(self.data.reward_item[0].item_id)

	for i = 1, 4 do
		if item_list[i] then
			self.item_cell_list[i]:SetData(item_list[i])
			self.item_cell_obj_list[i]:SetActive(true)
		else
			self.item_cell_obj_list[i]:SetActive(false)
		end
	end

	local fetch_reward_flag = self.data.fetch_reward_flag == 1
	local str = fetch_reward_flag and Language.Common.YiLingQu or (cur_value >= self.data.need_chognzhi and Language.Common.LingQu or Language.Common.WEIDACHENG)
	self.show_text:SetValue(str)
	self.show_interactable:SetValue(not fetch_reward_flag and cur_value >= self.data.need_chognzhi)
	self.can_lingqu:SetValue(not fetch_reward_flag and cur_value >= self.data.need_chognzhi)


end

function TotalChargeCell:OnClickGet()
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TOTAL_CHARGE, RA_NEW_TOTAL_CHARGE_OPERA_TYPE.RA_NEW_TOTAL_CHARGE_OPERA_TYPE_FETCH_REWARD, self.data.seq)
end