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

local CELL_COLUMN = 5			--列数
local process_list = {0.06, 0.3, 0.53, 0.76, 1}

function SignInView:__init()
	self.first_open = true
	self.standard_calendar = {}
	self.is_open_server = WelfareData.Instance:GetIsOpenServerSign()
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
	--注释
	self.annotations = self:FindVariable("Annotations")
	--月份
	self.month = self:FindVariable("Month")
	--开服签到
	self.show_open_server_sign = self:FindVariable("ShowOpenServerSign")
	--总签到日Cfg
	self.total_sign_cfg = WelfareData.Instance:GetTotalSignCfg()

	if self.is_open_server then
		self.now_day = TimeCtrl.Instance:GetCurOpenServerDay()
		self.sign_flag_list = WelfareData.Instance:GetSignInfo()
		self.current_month_days = 30
	end
	self.show_open_server_sign:SetValue(self.is_open_server)
	self.item_list = {}
	for i = 1, 5 do
		local item_cell = ItemCell.New(self:FindObj("Item" .. i))
		local total_reward_data = self.total_sign_cfg[i]
		local reward_item_data = total_reward_data.reward_item
		item_cell:SetData(reward_item_data)
		item_cell:ListenClick(BindTool.Bind(self.ClickTotalReward, self, item_cell, i, total_reward_data))
		table.insert(self.item_list, item_cell)
	end

	self.point_list = {}
	for i = 1, 5 do
		self.point_list[i] = self:FindVariable("Point" .. i)
		-- self.point_list[i]:SetValue(false)
	end

    --奖励列表
    self.cell_list = {}
    self.list_view = self:FindObj("ListView")
    local list_simple_delegate = self.list_view.list_simple_delegate
    list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.NumberOfCellsDel, self)
    list_simple_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)

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
	self.first_open = true
end

--一键补签
function SignInView:AutoSign()
	local rec_sign_reward_list = WelfareData.Instance:GetAllRecSign()
	if self.is_open_server then
		rec_sign_reward_list = WelfareData.Instance:GetOpenServerAllRecSign()
	end
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
	return self.is_open_server and 6 or math.ceil(self.current_month_days/CELL_COLUMN)
end

function SignInView:CellRefreshDel(cell, data_index)
	local group_cell = self.cell_list[cell]
	if not group_cell then
		group_cell = SignDayRewardGroupCell.New(cell.gameObject)
		-- group_cell:SetGroup(self.list_view.toggle_group)
		self.cell_list[cell] = group_cell
	end
	for i = 1, CELL_COLUMN do
		local index = data_index * CELL_COLUMN + i
		group_cell:SetIndex(i, index)

		local sign_data = nil
		if index <= self.current_month_days then
			sign_data = WelfareData.Instance:GetSingleSignReward(self.time_table.month, index)
		end
		if sign_data then
			group_cell:SetActive(i, true)
			group_cell:SetData(i, sign_data.reward_item)

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
			
			group_cell:SetIconGrayVisible(i, is_get)
			group_cell:ShowHaseGet(i, is_get)
			-- group_cell:ShowHighLight(i, can_show_highlight)
			group_cell:ShowRepairImage(i, can_repair)
			group_cell:ShowGetEffect(i, show_get_effect)
			--group_cell:SetRedPoint(i,can_repair)
			
			--设置vip显示
			local vip = sign_data.vip
			if vip > 0 then
				group_cell:ShowToLeft(i, false)
				local multiple = sign_data.multiple
				local des = string.format(Language.Welfare.VipMultiple, vip, Language.Common.NumToChs[multiple])
				group_cell:SetTopLeftDes(i, des)
			else
				group_cell:ShowToLeft(i, false)
			end
			group_cell:SetTopLeftDes(i, Language.Welfare.Repair) --特别需求强制改成补签
			group_cell:AddListenClick(i, BindTool.Bind(self.ClickItem, self, index, sign_data, group_cell, i))
		else
			group_cell:SetActive(i, false)
		end
	end
end

function SignInView:ClickTotalReward(cell, index, data)
	if not data or not next(data) then
		return
	end
	local totoal_reward_mark = WelfareData.Instance:GetTotalSignInReardMark()
	local flag = totoal_reward_mark[32 - (index - 1)]
	local total_sign_count = WelfareData.Instance:GetAccmulationSigninDays()
	if self.is_open_server then
		total_sign_count = WelfareData.Instance:GetOpenAllSign()
	end
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

function SignInView:ClickItem(index, data, group_cell, i)
	local now_day = tonumber(self.now_day)
	local cost = data.diamond or data.need_gold
	local function ok_callback()
		local is_enough = PlayerData.GetIsEnoughAllGold(cost)
		if not is_enough then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
		WelfareCtrl.Instance:SendSignIn(SIGN_GET_REWARD_STATUS.ONE_SIGN, index)
	end
	local cell = group_cell:GetCell(i)
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
			TipsCtrl.Instance:ShowCommonAutoView("sign_in_str", des, ok_callback, close_callback)
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
				local item_cell = v:GetItemCellByIndex(index)
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
						item_cell:SetRedPoint(false)
						-- item_cell:ShowGetEffect(false)
						v:SetShowSign(index % 5, false)
						--设置vip显示
						local vip = sign_data.vip
						if vip > 0 then
							item_cell:ShowToLeft(false)
							local multiple = sign_data.multiple
							local des = string.format(Language.Welfare.VipMultiple, vip, Language.Common.NumToChs[multiple])
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
			v:ShowHaseGet(true)
			v:ShowGetEffect(false)
			if self.point_list[k] then
				self.point_list[k]:SetValue(true)
			end
		else
			local total_reward_data = self.total_sign_cfg[k]
			v:SetIconGrayVisible(false)
			v:ShowHighLight(false)
			v:ShowHaseGet(false)
			if total_sign_count >= total_reward_data.total_sign_in then
				v:ShowGetEffect(true)
				if self.point_list[k] then
					self.point_list[k]:SetValue(true)
				end
			else
				v:ShowGetEffect(false)
			end
		end
	end
end

function SignInView:Flush()

	local total_sign_count = WelfareData.Instance:GetAccmulationSigninDays()
	if self.is_open_server then
		self.now_day = TimeCtrl.Instance:GetCurOpenServerDay()
		self.sign_flag_list = WelfareData.Instance:GetSignInfo()
		self.annotations:SetValue(Language.Welfare.OpenSign)
		total_sign_count = WelfareData.Instance:GetOpenAllSign()
	else
		--本月第几天
		self.now_day = TimeCtrl.Instance:GetServerDay()
		--签到改变领取标记
		self.sign_flag_list = WelfareData.Instance:GetSignFlagList()
		--设置月份
		self.month:SetValue(self.time_table.month)
		--设置已签到日
		self.annotations:SetValue(Language.Welfare.CommonSign)
	end

	self:ReFreshItem()
	--总签到
	self.total_sign_days:SetValue(total_sign_count)

	--总签到进度条
	local process_count = 0
	--当前到达领取奖励的天数
	local gift_day = 0
	--下一次领取奖励的天数
	local next_gift_day = nil
	for k, v in ipairs(self.total_sign_cfg) do
		if total_sign_count >= v.total_sign_in then
			process_count = process_count + 1
			gift_day = v.total_sign_in
		else
			next_gift_day = v.total_sign_in
			break
		end
	end

	--领取奖励后多出的天数
	local another_day = total_sign_count - gift_day
	local process = process_list[process_count] or 0
	if process_list[process_count + 1] and next_gift_day then
		--当前礼物到下一礼物进度条所占比例
		local to_next_process = process_list[process_count + 1] - process
		process = process + another_day / (next_gift_day - gift_day) * to_next_process
	end

	if process then
		self.slider_value:SetValue(process)
	end
	self:FlushTotalSignReward()

	local is_sign = WelfareData.Instance:GetIntradaySignInfo(self.now_day)
	if is_sign <= 0 and self.first_open then
		self.list_view.scroller:ReloadData(0)
		self:ChangeSignIndex()
		self.first_open = false
	end
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
	local now_day = tonumber(self.now_day - 1 or 0)
	self.list_view.scroller:JumpToDataIndex(math.floor(now_day / CELL_COLUMN))
end

--每日签到格子
SignDayRewardGroupCell = SignDayRewardGroupCell or BaseClass(BaseRender)
function SignDayRewardGroupCell:__init()
	self.item_cell_list = {}
	self.cell_bg_list = {}
	self.show_sign_list = {}
	local child_count = self.root_node.transform.childCount
	for i = 1, child_count do
		self.show_sign_list[i] = self:FindVariable("show_sign_" .. i)
		self.cell_bg_list[i] = self:FindVariable("cell_bg_" .. i)
		self.cell_bg_list[i]:SetValue(false)
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("base_cell" .. i))
		self.item_cell_list[i]:SetData(nil)
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
	self.cell_bg_list[i]:SetValue(value)
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
	self.item_cell_list[i]:ShowHighLight(false)
end

function SignDayRewardGroupCell:SetInteractable(i, enable)
	self.item_cell_list[i]:SetInteractable(enable)
end

function SignDayRewardGroupCell:ShowHaseGet(i, enable)
	self.item_cell_list[i]:ShowHaseGet(enable)
end

function SignDayRewardGroupCell:ShowActivityEffect(i, enable)
	if self.item_cell_list[i] then
		self.item_cell_list[i]:SetActivityEffect(not enable)
	end
end

function SignDayRewardGroupCell:ShowGetEffect(i, enable)
	-- self.item_cell_list[i]:ShowGetEffect(enable)
	self:SetShowSign(i, enable)
end

function SignDayRewardGroupCell:ShowRepairImage(i, enable)
	self.item_cell_list[i]:ShowRepairImage(enable)
end

function SignDayRewardGroupCell:SetRedPoint(i, enable)
	self.item_cell_list[i]:SetRedPoint(enable)
end

function SignDayRewardGroupCell:SetIndex(i, index)
	self.item_cell_list[i]:SetIndex(index)
end

function SignDayRewardGroupCell:SetShowSign(i, enable)
	if self.show_sign_list[i] then
		self.show_sign_list[i]:SetValue(enable)
		self:ShowActivityEffect(i, enable)
	end
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