ConsumeDiscountView = ConsumeDiscountView or BaseClass(BaseView)
function ConsumeDiscountView:__init()
	self.ui_config = {"uis/views/randomact/consumediscount_prefab","ConsumeDiscountView"}
	self.play_audio = true
	self.rare_list = {}
end

function ConsumeDiscountView:__delete()

end

function ConsumeDiscountView:ReleaseCallBack()
	if nil ~= self.extra_gift then
		self.extra_gift:DeleteMe()
		self.extra_gift = nil
	end

	if nil ~= self.consume_gift then
		self.consume_gift:DeleteMe()
		self.consume_gift = nil
	end

	for k,v in pairs(self.rare_list) do
		v:DeleteMe()
	end
	self.rare_list = {}
	self.show_red_point = nil
	self.show_red_right_point = nil
	self.act_time = nil
	self.total_reach = nil
	self.series_reach = nil
	self.consume = nil
	self.limit_day = nil
	self.limit_gold = nil
	self.consume_pro = nil
	self.pro_txt = nil
	self.rare_day = nil
	self.rare_reward_count = nil
	self.reward_count = nil
end

function ConsumeDiscountView:LoadCallBack()
	self.act_time = self:FindVariable("ActTime")
	self.total_reach = self:FindVariable("TotalReach")
	self.series_reach = self:FindVariable("SeriesReach")
	self.consume = self:FindVariable("Consume")
	self.limit_day = self:FindVariable("LimitDay")
	self.limit_gold = self:FindVariable("LimitGold")
	self.consume_pro = self:FindVariable("ConsumePro")
	self.pro_txt = self:FindVariable("ProTet")
	self.rare_day = self:FindVariable("RareDay")
	self.rare_reward_count = self:FindVariable("RareRewardCount")
	self.reward_count = self:FindVariable("RewardCount")
	self.show_red_point= self:FindVariable("show_red")
	self.show_red_right_point= self:FindVariable("show_right_red_point")

	self.extra_gift = ItemCell.New()
	self.extra_gift:SetInstanceParent(self:FindObj("RareItem"))

	self.consume_gift = ItemCell.New()
	self.consume_gift:SetInstanceParent(self:FindObj("CurItem"))

	local continue_consume = ConsumeDiscountData.Instance:GetRAContinueConsumeCfg()
	if continue_consume ~= nil then
		self.rare_list = {}
		for i=1,6 do
			self.rare_list[i] = ItemCell.New()
			self.rare_list[i]:SetInstanceParent(self:FindObj("RareItemDisplay"))
			if continue_consume[i] then
				self.rare_list[i]:SetData({item_id = continue_consume[i].show_item, is_bind = 0})
			end
			self.rare_list[i].root_node:SetActive(continue_consume[i] ~= nil)
		end

		self.consume_gift:SetData(continue_consume[1].reward_item or {})
	else
		print_log("continue_consume is nil")
	end
	local server_other_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfigOtherCfg()
	self.extra_gift:SetData(server_other_cfg.continue_consume_extra_reward or {})
	self.rare_day:SetValue(server_other_cfg.continue_consume_fetch_extra_reward_need_days or 0)

	self:ListenEvent("Close",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickReward",BindTool.Bind(self.OnClickToGetReward, self, 0))
	self:ListenEvent("OnClickRareReward",BindTool.Bind(self.OnClickToGetReward, self, 1))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickBtnTips, self))
end

function ConsumeDiscountView:OpenCallBack()
	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
		self.consume_discount = nil
	end
	local act_cornucopia_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME) or {}
	if act_cornucopia_info.status == ACTIVITY_STATUS.OPEN then
		local next_time = act_cornucopia_info.next_time or 0
		self:UpdataRollerTime(0, next_time)
		self.consume_discount = CountDown.Instance:AddCountDown(next_time, 1, BindTool.Bind1(self.UpdataRollerTime, self), BindTool.Bind1(self.CompleteRollerTime, self))
	else
		self:CompleteRollerTime()
	end
	local param_t = {
		rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
		opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUME_CONSUME_OPERA_TYPE_QUERY_INFO,
	}
	KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
end

function ConsumeDiscountView:CloseCallBack()
	if self.consume_discount then
		CountDown.Instance:RemoveCountDown(self.consume_discount)
		self.consume_discount = nil
	end
end

function ConsumeDiscountView:OnFlush()
	self:FlushPanel()
end

function ConsumeDiscountView:FlushPanel()
	local consume_info = ConsumeDiscountData.Instance:GetRAContinueConsumeInfo()

	if consume_info then
		local continue_consume = ConsumeDiscountData.Instance:GetRAContinueConsumeCfg()
		if continue_consume ~= nil then
			if nil == continue_consume[consume_info.current_day_index] then return end

			self.consume_gift:SetData(continue_consume[consume_info.current_day_index].reward_item)  --连消奖励
			local need_consume_gold = continue_consume[consume_info.current_day_index].need_consume_gold or 0
			local reach_text = ""
			if consume_info.continue_days <= 5 then
				reach_text = ToColorStr(tostring(consume_info.continue_days), TEXT_COLOR.RED)
			else
				reach_text = ToColorStr(tostring(consume_info.continue_days), TEXT_COLOR.BLUE_4)
			end
			self.limit_day:SetValue(consume_info.current_day_index)
			self.limit_gold:SetValue(need_consume_gold)
			self.consume:SetValue(consume_info.today_consume_gold_total)		--累计消费
			self.series_reach:SetValue(reach_text)								--连续达标天数
			self.total_reach:SetValue(consume_info.continue_days_total) 		--总达标天数

			local percent = consume_info.cur_consume_gold / need_consume_gold * 100
			percent = percent < 100 and percent or 100
			self.consume_pro:SetValue(percent / 100) --消费占比

			local consume_gold = ""
			if consume_info.cur_consume_gold < need_consume_gold then
				consume_gold = ToColorStr(tostring(consume_info.cur_consume_gold), TEXT_COLOR.RED)
			else
				consume_gold = ToColorStr(tostring(consume_info.cur_consume_gold), TEXT_COLOR.BLUE_4)
			end
			self.pro_txt:SetValue(consume_gold .. "/" .. need_consume_gold)

			self.reward_count:SetValue(math.floor(consume_info.cur_consume_gold / need_consume_gold))
			self.rare_reward_count:SetValue(consume_info.extra_reward_num)
			self.show_red_right_point:SetValue(consume_info.extra_reward_num)
			self.show_red_point:SetValue(math.floor(consume_info.cur_consume_gold / need_consume_gold))
		end
	end
end

function ConsumeDiscountView:UpdataRollerTime(elapse_time, next_time)
	local time = next_time - TimeCtrl.Instance:GetServerTime()
	if self.act_time ~= nil then
		if time > 0 then
			local format_time = TimeUtil.Format2TableDHMS(time)
			local str_list = Language.Common.TimeList
			local time_str = ""
			if format_time.day >= 1 then
				time_str = format_time.day .. str_list.d
			end
			if format_time.hour > 0 then
				time_str = time_str .. format_time.hour .. str_list.h
			end

			if format_time.day < 1 then
				time_str = time_str .. format_time.min .. str_list.min
				time_str = time_str .. format_time.s .. str_list.s
			end
			self.act_time:SetValue(time_str)
		end
	end
end

function ConsumeDiscountView:CompleteRollerTime()
	if self.label_time ~= nil then
		self.act_time:SetValue("0")
	end
end

function ConsumeDiscountView:OnClickToGetReward(num)
	if 0 == num then
		local param_t = {
			rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
			opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_REWARD,
		}
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
	elseif 1 == num then
		local param_t = {
			rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME,
			opera_type = RA_CONTINUE_CONSUME_OPERA_TYPE.RA_CONTINUE_CONSUME_OPEAR_TYPE_FETCH_EXTRA_REWARD,
		}
		KaifuActivityCtrl.Instance:SendRandActivityOperaReq(param_t.rand_activity_type, param_t.opera_type)
	end
end

function ConsumeDiscountView:OnClickBtnTips()
	TipsCtrl.Instance:ShowHelpTipView(229)
end