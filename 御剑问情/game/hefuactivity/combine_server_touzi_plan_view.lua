HeFuTouZiView = HeFuTouZiView or BaseClass(BaseRender)

function HeFuTouZiView:__init()
	self.reward_now = self:FindVariable("reward_now")
	self.spend_money = self:FindVariable("spend_money")
	self.show_button_day = self:FindVariable("show_button_day")
	self.button_buy_state = self:FindVariable("button_buy_state")

	for i = 1, 7 do
		self["reward_day_" .. i] = self:FindVariable("reward_day_" .. i)
		self["button_state_" .. i] = self:FindVariable("button_state_" .. i)
		self["button_text_" .. i] = self:FindVariable("button_text_" .. i)

		self:ListenEvent("ClickRewardDay_" .. i,BindTool.Bind(self.ClickReward, self, i))
	end

	for i = 1, 4 do
		self["money_" .. i] = self:FindVariable("money_" .. i)
	end

	self:ListenEvent("ClickBuy",
		BindTool.Bind(self.ClickBuy, self))
end

function HeFuTouZiView:__delete()
	self.reward_now = nil
	self.spend_money = nil
	self.show_button_day = nil
	self.button_buy_state = nil

	for i = 1, 7 do
		self["reward_day_" .. i] = nil
		self["button_state_" .. i] = nil
		self["button_text_" .. i] = nil
	end

	for i = 1, 4 do
		self["money_" .. i] = nil
	end
end

function HeFuTouZiView:OpenCallBack()
	self:Flush()
end

function HeFuTouZiView:ClickBuy()
	local info = HefuActivityData.Instance:GetTouZiInfo()
	if nil == info or nil == next(info) or info.csa_touzijihua_buy_flag == 1 then
		return
	end

	local reward_cfg = HefuActivityData.Instance:GetHeFuTouZiCfg()
	local buy_money = reward_cfg.touzi_jihua_buy_cost or 0

	RechargeCtrl.Instance:Recharge(buy_money / 10)
end

function HeFuTouZiView:ClickReward(index)
	HefuActivityCtrl.Instance:SendCSARoleOperaReq(COMBINE_SERVER_ACTIVITY_SUB_TYPE.CSA_SUB_TYPE_TOUZI, 1 , index - 1)
end

function HeFuTouZiView:OnFlush()
	local info = HefuActivityData.Instance:GetTouZiInfo()
	if nil == info or nil == next(info) then
		return
	end

	local reward_cfg = HefuActivityData.Instance:GetHeFuTouZiCfg()
	local buy_money = reward_cfg.touzi_jihua_buy_cost or 0
	local reward_money_now = reward_cfg.touzi_jihua_buy_reward_gold or 0
	local login_day = info.csa_touzjihua_login_day or 0
	local csa_touzijihua_total_fetch_flag = bit:d2b(info.csa_touzijihua_total_fetch_flag)
	if login_day > 7 then
		login_day = 7
	end

	self.reward_now:SetValue(reward_money_now)
	self.money_1:SetValue(buy_money)
	self.spend_money:SetValue(string.format(Language.Activity.ButtonText10,buy_money / 10))
	self.button_buy_state:SetValue(info.csa_touzijihua_buy_flag == 0)

	if info.csa_touzijihua_buy_flag == 1 then
		self.spend_money:SetValue(Language.Activity.ButtonText2)
		self.button_buy_state:SetValue(false)
		self.show_button_day:SetValue(login_day)

		for i = 1, login_day do
			if csa_touzijihua_total_fetch_flag[32 - i + 1] == 0 then
				self["button_state_" .. i]:SetValue(true)
				self["button_text_" .. i]:SetValue(Language.Activity.ButtonText1)
			elseif csa_touzijihua_total_fetch_flag[32 - i + 1] == 1 then
				self["button_state_" .. i]:SetValue(false)
				self["button_text_" .. i]:SetValue(Language.Activity.ButtonText9)
			end
		end
	else
		self.button_buy_state:SetValue(true)
	end

	for i = 1, 7 do
		local reward = HefuActivityData.Instance:TouZiRewardDay(i) or 0
		self["reward_day_" .. i]:SetValue(reward)
	end

end