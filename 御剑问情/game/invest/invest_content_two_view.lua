InvestContentTwoView = InvestContentTwoView or BaseClass(BaseRender)

function InvestContentTwoView:__init(instance)
	InvestContentTwoView.Instance = self
	self:ListenEvent("reward_click_1", BindTool.Bind(self.OnRewardClick, self))
	self:ListenEvent("reward_click_2", BindTool.Bind(self.OnVIPRewardClick, self))
	self.show_reward = self:FindVariable("show_reward")
	self.show_receive = self:FindVariable("show_receive")
	self.show_vip_reward = self:FindVariable("show_vip_reward")
	self.show_vip_receive = self:FindVariable("show_vip_receive")
	self.day_text = self:FindVariable("day_text")
	self.days_slider = self:FindVariable("days_slider")
	self.reward_red_point_1 = self:FindVariable("reward_red_point_1")
	self.reward_red_point_2 = self:FindVariable("reward_red_point_2")
	self.current_day = 1
	self.show_ball_list = {}
	self.red_point = {}

	for i=1,7 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
		self.show_ball_list[i] = self:FindVariable("show_ball_"..i)
		self.red_point[i] = self:FindVariable("red_point_"..i)
	end
	self.item_list = {}
	for i=1,4 do
		local handler = function()
			local close_call_back = function()
				self:CancelHighLight()
			end
			self.item_list[i]:ShowHighLight(true)
			TipsCtrl.Instance:OpenItem(self.item_list[i]:GetData(), nil, nil, close_call_back)
		end
		self.item_list[i] = ItemCell.New(self:FindObj("item_" .. i))
		self.item_list[i]:ListenClick(handler)
	end
end

function InvestContentTwoView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function InvestContentTwoView:OpenCallBack()
	for i=1,7 do
		self.show_ball_list[i]:SetValue(InvestData.Instance:GetRewardState(i - 1)[1])
		self.red_point[i]:SetValue(false)
	end
	self:FlushSlider()
	self:FlushBtn()
	if nil ~= self.day then
		if self.day == 0 then
			self.day = 1
		end
		self.now_days_toggle = self:FindObj("day_toggle_"..self.day)
		self.now_days_toggle.toggle.isOn = true
	end
end

function InvestContentTwoView:OnRewardClick()
	InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_FETCH, self.current_day - 1)
end

function InvestContentTwoView:OnVIPRewardClick()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if vip_level >= 6 then
		InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_VIP_FETCH, self.current_day - 1)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Answer.VipTip)
	end
end

function InvestContentTwoView:OnToggleClick(day_text,is_click)
	if is_click then
		self.current_day = day_text
		self.day_text:SetValue(day_text)
		local data_list = InvestData.Instance:GetInvestRewardList(day_text - 1)
		for i=1,4 do
			self.item_list[i]:SetData(data_list[i])
		end
		self:FlushBtn()
	end
end

function InvestContentTwoView:CancelHighLight()
	for k,v in pairs(self.item_list) do
		v:ShowHighLight(false)
	end
end

function InvestContentTwoView:FlushBtn()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local state_list = InvestData.Instance:GetRewardState(self.current_day - 1)
	self.show_reward:SetValue(not state_list[1])
	self.show_receive:SetValue(state_list[1])
	-- self.show_vip_reward:SetValue(not state_list[2])
	-- self.show_vip_receive:SetValue(state_list[2])
	local day = 0
	if InvestData.Instance:GetInvestInfo().buy_time ~= nil and InvestData.Instance:GetInvestInfo().buy_time ~= 0 then
		day = math.floor(TimeCtrl.Instance:GetDayIndex(InvestData.Instance:GetInvestInfo().buy_time, TimeCtrl.Instance:GetServerTime()) + 1)
	end

	self.reward_red_point_1:SetValue(not state_list[1] and (day >= self.current_day))
	-- self.reward_red_point_2:SetValue((day >= self.current_day) and (not state_list[2]) and vip_level >= 6)
end

function InvestContentTwoView:FlushSlider()
	if InvestData.Instance:GetSevenDayAwardFlag() then
		-- InvestView.Instance:ShowContent()
		return
	end

	if InvestData.Instance:GetInvestInfo().buy_time == 0 then
		self.days_slider:SetValue(1)
		self.day_text:SetValue(1)
		return
	end
	self.day = math.floor(TimeCtrl.Instance:GetDayIndex(InvestData.Instance:GetInvestInfo().buy_time, TimeCtrl.Instance:GetServerTime()) + 1)
	if self.day > 7 then
		self.day = 7
	end

	local  slider_table = {[0] = 0, [1] = 0.15, [2] = 0.27, [3] = 0.38, [4] = 0.5, [5] = 0.63, [6] = 0.75, [7] = 1}

	-- local slider_value = self.day/INVEST_TOTAL_DAYS
	-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level

	for i = 1, self.day do
		local show_red_point = not InvestData.Instance:GetRewardState(i - 1)[1]    -- or
								-- (not InvestData.Instance:GetRewardState(i - 1)[2] and
								-- 	vip_level >= 6)
		self.red_point[i]:SetValue(show_red_point)
	end

	self.days_slider:SetValue(slider_table[self.day])
end

