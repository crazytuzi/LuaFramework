SignInView = SignInView or BaseClass(BaseRender)

--平年 不能被4整除是平年
local DaysPerMonth = {
	[1] = 31,
	[2] = 28,
	[3] = 31,
	[4] = 30,
	[5] = 31,
	[6] = 30,
	[7] = 31,
	[8] = 31,
	[9] = 30,
	[10] = 31,
	[11] = 30,
	[12] = 31,
}

local CELL_COLUMN = 7			--列数
local process_list = {0.075, 0.305, 0.535, 0.767, 1}

function SignInView:__init()
	self.standard_calendar = {}
	--本月第几天
	self.now_day = TimeCtrl.Instance:GetServerDay()
	--签到领取标记
	self.sign_flag_list = WelfareData.Instance:GetSignFlagList()

	self.time_table = TimeCtrl.Instance:GetServerTimeFormat()
	--本月有多少天
	self.current_month_days = self:GetDaysByMonth(self.time_table.month, self.time_table.year)
	self.total_sign_max_day = WelfareData.Instance:GetMaxTotalSignDay()
	--上个月有多少天
	local last_month_days = self:GetDaysByMonth(self.time_table.month - 1, self.time_table.year)
	--本月第一天是星期几
	local week_index = self:CalculateFirstDay(self.time_table.year,self.time_table.month,1)
	--签到奖励进度条
	self.slider_value = self:FindVariable("SliderValue")
	--累计签到日数
	self.total_sign_days = self:FindVariable("TotalSignDays")
	--月份
	self.month = self:FindVariable("Month")
	--总签到日Cfg
	self.total_sign_cfg = WelfareData.Instance:GetTotalSignCfg()

	self.item_list = {}
	for i = 1, 5 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		local total_reward_data = self.total_sign_cfg[i]
		local reward_item_data = total_reward_data.reward_item
		item_cell:SetData(reward_item_data)
		item_cell:ListenClick(BindTool.Bind(self.ClickTotalReward, self, item_cell, i, total_reward_data))
		table.insert(self.item_list, item_cell)
	end

	for i = 1, 5 do
		self["has_get_" .. i] = self:FindVariable("has_get_" .. i)
	end
    --奖励列表
    self.cell_list = {}
    self.list_view = self:FindObj("ListView")
    local page_simple_delegate = self.list_view.page_simple_delegate
    page_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    page_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

    self:ListenEvent("AutoSign", BindTool.Bind(self.AutoSign, self))

	self:Flush()
end

function SignInView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

--一键补签
function SignInView:AutoSign()
	local rec_sign_reward_list = WelfareData.Instance:GetAllRecSign()
	if not next(rec_sign_reward_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Welfare.NotRecSignDay)
		return
	end

	local all_cost = 0
	for k, v in ipairs(rec_sign_reward_list) do
		if v.diamond then
			all_cost = all_cost + v.diamond
		end
	end
	local function ok_callback()
		local is_enough = PlayerData.GetIsEnoughAllGold(all_cost)
		if not is_enough then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		WelfareCtrl.Instance:SendSignIn(SIGN_GET_REWARD_STATUS.ONE_SIGN, nil, 1)
	end
	local des = string.format(Language.Welfare.CostToSignAll, all_cost)
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

function SignInView:NumberOfCellsDel()
	return self.current_month_days
end

function SignInView:CellRefreshDel(data_index, cell)
	local item_cell = self.cell_list[cell]
	if not item_cell then
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(cell.gameObject)
		self.cell_list[cell] = item_cell
	end
	local index = data_index + 1
	item_cell:SetIndex(index)
	local sign_data = nil
	if index <= self.current_month_days then
		sign_data = WelfareData.Instance:GetSingleSignReward(self.time_table.month, index)
	end
	if sign_data then
		item_cell:SetActive(true)
		item_cell:SetData(sign_data.reward_item)

		--置灰已领取的item
		local flag = self.sign_flag_list[32 - index]
		local is_gray = false
		local is_get = false
		local can_repair = false		--是否可补签
		local now_day = tonumber(self.now_day)
		local can_show_highlight = true
		local show_get_effect = false
		if now_day > index then
			if flag == 1 then
				is_get = true
			else
				is_gray = true
				can_repair = true
				can_show_highlight = false
			end
		elseif now_day == index then
			if flag == 1 then
				is_get = true
			else
				show_get_effect = true
				can_show_highlight = false
			end
		end

		item_cell:SetIconGrayVisible(is_gray)
		item_cell:ShowHaseGet(is_get)
		item_cell:ShowHighLight(can_show_highlight)
		item_cell:ShowRepairImage(can_repair)
		item_cell:ShowGetEffect(show_get_effect)

		--设置vip显示
		local vip = sign_data.vip
		if vip > 0 then
			item_cell:ShowToLeft(true)
			local multiple = sign_data.multiple
			local des = string.format(Language.Welfare.VipMultiple, vip, Language.Common.NumToChsForWelfare[multiple])
			item_cell:SetTopLeftDes(des)
		else
			item_cell:ShowToLeft(false)
		end
		item_cell:ListenClick(BindTool.Bind(self.ClickItem, self, index, sign_data, item_cell))
	else
		item_cell:SetActive(false)
	end
end

function SignInView:ClickTotalReward(cell, index, data)
	if not data or not next(data) then
		return
	end
	local totoal_reward_mark = WelfareData.Instance:GetTotalSignInReardMark()
	local flag = totoal_reward_mark[32 - (index - 1)]
	local total_sign_count = WelfareData.Instance:GetAccmulationSigninDays()
	local function close_callback()
		if cell then
			cell:SetHighLight(false)
		end
	end
	if flag == 1 or total_sign_count < data.total_sign_in then
		TipsCtrl.Instance:OpenItem(data.reward_item, nil, nil, close_callback)
	else
		WelfareCtrl.Instance:SendSignIn(SIGN_GET_REWARD_STATUS.TOTAL_SIGN, data.seq)
	end
end

function SignInView:ClickItem(index, data, cell)
	local now_day = tonumber(self.now_day)
	local cost = data.diamond
	local function ok_callback()
		local is_enough = PlayerData.GetIsEnoughAllGold(cost)
		if not is_enough then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		WelfareCtrl.Instance:SendSignIn(SIGN_GET_REWARD_STATUS.ONE_SIGN, index)
	end
	if not cell then
		return
	end
	local function close_callback()
		if cell then
			cell:SetHighLight(false)
		end
	end
	local flag = self.sign_flag_list[32 - index]
	if index < now_day then
		if flag == 0 then
			local des = string.format(Language.Welfare.CostToSign, cost)
			TipsCtrl.Instance:ShowCommonAutoView("sign_in_str", des, ok_callback)
		else
			TipsCtrl.Instance:OpenItem(data.reward_item, nil, nil, close_callback)
		end
	elseif index > now_day then
		TipsCtrl.Instance:OpenItem(data.reward_item, nil, nil, close_callback)
	else
		if flag == 0 then
			WelfareCtrl.Instance:SendSignIn(SIGN_GET_REWARD_STATUS.ONE_SIGN, index)
		else
			TipsCtrl.Instance:OpenItem(data.reward_item, nil, nil, close_callback)
		end
	end
end

--刷新变化的item
function SignInView:ReFreshItem()
	local sign_change_flag_list = WelfareData.Instance:GetChangeSignFlagList()
	local max_num = #sign_change_flag_list
	local is_flush = false
	for i = max_num, 1, -1 do
		if sign_change_flag_list[i] == 1 then
			local index = max_num - i
			for _, v in pairs(self.cell_list) do
				local item_cell = nil
				if v:GetIndex() == index then
					item_cell = v
				end
				if item_cell then
					local sign_data = WelfareData.Instance:GetSingleSignReward(self.time_table.month, index)
					if sign_data then
						item_cell:SetActive(true)
						item_cell:SetData(sign_data.reward_item)
						item_cell:SetIconGrayVisible(true)
						item_cell:SetHighLight(false)
						item_cell:ShowHighLight(true)
						item_cell:ShowHaseGet(true)
						item_cell:ShowRepairImage(false)
						item_cell:ShowGetEffect(false)
						--设置vip显示
						local vip = sign_data.vip
						if vip > 0 then
							item_cell:ShowToLeft(true)
							local multiple = sign_data.multiple
							local des = string.format(Language.Welfare.VipMultiple, vip, Language.Common.NumToChsForWelfare[multiple])
							item_cell:SetTopLeftDes(des)
						else
							item_cell:ShowToLeft(false)
						end
						break
					end
				end
			end
		end
	end
end

--刷新累计奖励
function SignInView:FlushTotalSignReward()
	--总签到奖励领取情况
	local totoal_reward_mark = WelfareData.Instance:GetTotalSignInReardMark()
	local total_sign_count = WelfareData.Instance:GetAccmulationSigninDays()
	for k, v in ipairs(self.item_list) do
		local flag = totoal_reward_mark[32 - (k - 1)]
		if flag == 1 then
			v:SetIconGrayVisible(true)
			v:SetHighLight(false)
			v:ShowHighLight(true)
			-- v:ShowHaseGet(true)
			v:ShowGetEffect(false)
			self["has_get_" .. k]:SetValue(true)
		else
			local total_reward_data = self.total_sign_cfg[k]
			v:SetIconGrayVisible(false)
			v:ShowHighLight(false)
			-- v:ShowHaseGet(false)
			self["has_get_" .. k]:SetValue(false)
			if total_sign_count >= total_reward_data.total_sign_in then
				v:ShowGetEffect(true)
			else
				v:ShowGetEffect(false)
			end
		end
	end
end

function SignInView:OnFlush()
	self:ReFreshItem()
	--本月第几天
	self.now_day = TimeCtrl.Instance:GetServerDay()
	--签到改变领取标记
	self.sign_flag_list = WelfareData.Instance:GetSignFlagList()
	--设置月份
	self.month:SetValue(self.time_table.month)
	--设置已签到日
	local total_sign_count = WelfareData.Instance:GetAccmulationSigninDays()
	--总签到
	self.total_sign_days:SetValue(total_sign_count)
	--总签到进度条
	local process_count = 0
	for k, v in ipairs(self.total_sign_cfg) do
		if total_sign_count >= v.total_sign_in then
			process_count = process_count + 1
		else
			break
		end
	end
	local process = process_list[process_count] or 0
	if process then
		self.slider_value:SetValue(process)
	end
	self:FlushTotalSignReward()
end

--计算某一天是星期几
function SignInView:CalculateFirstDay(y, m, d)
	local s = io.read()
	t = os.time({
	["year"] = y,
	["month"] = m,
	["day"] = d
	})
	return os.date("*t",t).wday
end

--计算某一个月有多少天
function SignInView:GetDaysByMonth(month, year)
	if month < 0 then
		month = 12
	elseif month > 12 then
		month = 1
	end

	local days = 0
	if month == 2 and year%4 == 0 then
		--闰年2月的情况下
		days = 29
	else
		days = DaysPerMonth[month]
	end
	return days
end

function SignInView:ChangeSignIndex()
	local now_day = tonumber(self.now_day or 0)
	local can_get_day = now_day
	GlobalTimerQuest:AddDelayTimer(function()
		local function callback()
			if can_get_day <= CELL_COLUMN*2 then
				self.list_view.list_view:JumpToIndex(can_get_day - 1)
			else
				self.list_view.list_view:JumpToIndex(CELL_COLUMN*2 - 1, 54)
			end
		end
		self.list_view.list_view:Reload(callback)
	end, 0)
end

--每日签到格子
SignDayRewardGroupCell = SignDayRewardGroupCell or BaseClass(BaseRender)
function SignDayRewardGroupCell:__init()
	self.item_cell_list = {}
	local child_count = self.root_node.transform.childCount
	for i = 0, child_count - 1 do
		local child = self.root_node.transform:GetChild(i).gameObject
		if child then
			local item_cell = ItemCell.New()
			item_cell:SetInstanceParent(child)
			item_cell:SetData(nil)
			table.insert(self.item_cell_list, item_cell)
		end
	end
end

function SignDayRewardGroupCell:__delete()
	for k, v in ipairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function SignDayRewardGroupCell:SetData(i, data)
	self.item_cell_list[i]:SetData(data)
end

function SignDayRewardGroupCell:SetActive(i, value)
	self.item_cell_list[i]:SetActive(value)
end

function SignDayRewardGroupCell:SetGroup(group)
	for k, v in ipairs(self.item_cell_list) do
		v:SetToggleGroup(group)
	end
end

function SignDayRewardGroupCell:AddListenClick(i, callback)
	self.item_cell_list[i]:ListenClick(callback)
end

function SignDayRewardGroupCell:ShowToLeft(i, enable)
	self.item_cell_list[i]:ShowToLeft(enable)
end

function SignDayRewardGroupCell:SetTopLeftDes(i, des)
	self.item_cell_list[i]:SetTopLeftDes(des)
end

function SignDayRewardGroupCell:SetIconGrayVisible(i, enable)
	self.item_cell_list[i]:SetIconGrayVisible(enable)
end

function SignDayRewardGroupCell:ShowHighLight(i, enable)
	self.item_cell_list[i]:ShowHighLight(enable)
end

function SignDayRewardGroupCell:SetInteractable(i, enable)
	self.item_cell_list[i]:SetInteractable(enable)
end

function SignDayRewardGroupCell:ShowHaseGet(i, enable)
	self.item_cell_list[i]:ShowHaseGet(enable)
end

function SignDayRewardGroupCell:ShowGetEffect(i, enable)
	self.item_cell_list[i]:ShowGetEffect(enable)
end

function SignDayRewardGroupCell:ShowRepairImage(i, enable)
	self.item_cell_list[i]:ShowRepairImage(enable)
end

function SignDayRewardGroupCell:SetIndex(i, index)
	self.item_cell_list[i]:SetIndex(index)
end

function SignDayRewardGroupCell:GetCell(i)
	return self.item_cell_list[i]
end

function SignDayRewardGroupCell:GetItemCellByIndex(index)
	local item_cell = nil
	for k, v in ipairs(self.item_cell_list) do
		if v:GetIndex() == index then
			item_cell = v
			break
		end
	end
	return item_cell
end