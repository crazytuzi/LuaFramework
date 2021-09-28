OpenActTouZiPlan = OpenActTouZiPlan or BaseClass(BaseRender)

function OpenActTouZiPlan:__init()
	self.now_page = 0

	for i = 1, 3 do
		self["button_text_" .. i] = self:FindVariable("button_text_" .. i)
		self["gray_button_" .. i] = self:FindVariable("gray_button_" .. i)
		self["money" .. i] = self:FindVariable("money" .. i)
		self["nextmoney" .. i] = self:FindVariable("nextmoney" .. i)
		self["level" .. i] = self:FindVariable("level" .. i)
		self["buttonlevel" .. i] = self:FindVariable("buttonlevel" .. i)
		self["title_text_" .. i] = self:FindVariable("title_text_" .. i)
		self:ListenEvent("ClickCanRechage" .. i,BindTool.Bind(self.OnClickRecharge, self, i))
	end
	self:ListenEvent("LeftPage",BindTool.Bind(self.LeftPage, self))
	self:ListenEvent("RightPage",BindTool.Bind(self.RightPage, self))
	self.show_left_button = self:FindVariable("show_left")
	self.show_right_button = self:FindVariable("show_right")
end

function OpenActTouZiPlan:__delete()
	self.now_page = nil
	self.show_left_button = nil
	self.show_right_button = nil

	for i = 1, 3 do
		self["button_text_" .. i] = nil
		self["gray_button_" .. i] = nil
		self["money" .. i] = nil
		self["nextmoney" .. i] = nil
		self["level" .. i] = nil
		self["buttonlevel" .. i] = nil
		self["title_text_" .. i] = nil
	end
end

function OpenActTouZiPlan:OpenCallBack()
	self.now_page = 0
	self:Flush()
end

function OpenActTouZiPlan:OnFlush()
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local page_num = math.ceil(cfg_num / 3)
	if self.now_page <= 0 then
		self.show_left_button:SetValue(false)
		self.show_right_button:SetValue(true)
	elseif self.now_page == page_num - 1 then
		self.show_left_button:SetValue(true)
		self.show_right_button:SetValue(false)
	else
		self.show_left_button:SetValue(true)
		self.show_right_button:SetValue(true)
	end

	if page_num == 1 then
		self.show_left_button:SetValue(false)
		self.show_right_button:SetValue(false)
	end

	for i = 1, 3 do
		local number = i + self.now_page * 3
		local cfg = KaifuActivityData.Instance:GetNewTouZicfg() or {}
		local reward_seq = cfg[number * 3].seq or 0
		local state = KaifuActivityData.Instance:GetTouZiState(reward_seq + 1)
		local asset, bundle = ResPath.GetTouZiImage(reward_seq + 1)
		local money = 0
		local reward_money = 0
		local level_min = 0
		local level_max = 0
		local level_1 = 0
		local level_2 = 0
		local level_3 = 0
		for k, v in pairs(cfg) do
			if v.seq == reward_seq then
				money = v.gold
				reward_money = v.reward_gold
				level_min = v.active_level_min
				level_max = v.active_level_max
			end
			if v.seq == reward_seq and v.sub_index == 0 then
				level_1 = v.reward_level
			elseif v.seq == reward_seq and v.sub_index == 1 then
				level_2 = v.reward_level
			elseif v.seq == reward_seq and v.sub_index == 2 then
				level_3 = v.reward_level
			end
		end
		self["title_text_" .. i]:SetAsset(asset, bundle)
		self["money" .. i]:SetValue(money)
		self["nextmoney" .. i]:SetValue(reward_money)
		self["level" .. i]:SetValue(string.format(Language.Activity.ButtonText5, level_1, level_2, level_3))

		self["buttonlevel" .. i]:SetValue(string.format(Language.Activity.ButtonText7, level_min, level_max))

-- state: 0 代表可购买， 1 代表已购买可领取， 2 代表已购买不能领取， 3 代表未购买过期, 4代表等级不够不能购买, 5 代表已领完
		if state == 0 or state == 4 then
			self["button_text_" .. i]:SetValue(string.format(Language.Activity.ButtonText4, money / 10))
			self["gray_button_" .. i]:SetValue(false)
		elseif state == 1 then
			self["button_text_" .. i]:SetValue(Language.Activity.ButtonText1)
			self["gray_button_" .. i]:SetValue(false)
		elseif state == 2 then
			self["button_text_" .. i]:SetValue(Language.Activity.ButtonText1)
			self["gray_button_" .. i]:SetValue(true)
		elseif state == 3 then
			self["button_text_" .. i]:SetValue(Language.Activity.ButtonText3)
			self["gray_button_" .. i]:SetValue(true)
		-- elseif state == 4 then
		-- 	self["button_text_" .. i]:SetValue(Language.Activity.ButtonText6)
		-- 	self["gray_button_" .. i]:SetValue(true)
		elseif state == 5 then
			self["button_text_" .. i]:SetValue(Language.Activity.ButtonText8)
			self["gray_button_" .. i]:SetValue(true)
		end
	end
end

function OpenActTouZiPlan:LeftPage()
	if self.now_page > 0 then
		self.now_page = self.now_page - 1
		self:Flush()
	end
end

function OpenActTouZiPlan:RightPage()
	local cfg_num = math.ceil(InvestData.Instance:GetTouZiPlanInfoNum() / 3) or 0
	if self.now_page < cfg_num - 1 then
		self.now_page = self.now_page + 1
		self:Flush()
	end
end

function OpenActTouZiPlan:OnClickRecharge(index)
	local cfg_num = InvestData.Instance:GetTouZiPlanInfoNum() or 0
	local number = index + self.now_page * 3
	local cfg = KaifuActivityData.Instance:GetNewTouZicfg() or {}
	local reward_seq = cfg[number * 3].seq or 0
	if nil == number or number > cfg_num then
		return
	end

	local state = KaifuActivityData.Instance:GetTouZiState(reward_seq + 1)
	local cfg = KaifuActivityData.Instance:GetTouZicfg()
	local money = 0
	for k, v in pairs(cfg) do
		if v.seq == reward_seq then
			money = v.gold
		end
	end

	if state == 0 then
		RechargeCtrl.Instance:Recharge(money / 10)
	elseif state == 1 then
		InvestCtrl.Instance:SendChongzhiFetchReward(NEW_TOUZIJIHUA_OPERATE_TYPE.NEW_TOUZIJIHUA_OPERATE_FOUNDATION_FETCH, reward_seq)
	elseif state == 2 then
		return
	elseif state == 3 then
		return
	elseif state == 4 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Activity.LevelText)
	elseif state == 5 then
		return
	end
end