ConsumeDiscountData = ConsumeDiscountData or BaseClass()

function ConsumeDiscountData:__init()
	if ConsumeDiscountData.Instance ~= nil then
		print_error("[ConsumeDiscountData] attempt to create singleton twice!")
		return
	end
	ConsumeDiscountData.Instance = self

	RemindManager.Instance:Register(RemindName.ConsumeDiscount, BindTool.Bind1(self.CheckReceiveRemind, self))
end

function ConsumeDiscountData:__delete()
	RemindManager.Instance:UnRegister(RemindName.ConsumeDiscount)
	ConsumeDiscountData.Instance = nil
end

function ConsumeDiscountData:CheckReceiveRemind()
	local count = 0
	if IS_ON_CROSSSERVER or not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME) then
		count = 0
	elseif self.continue_consume_t then
		local continue_consume = self:GetRAContinueConsumeCfg()
		if continue_consume and continue_consume[self.continue_consume_t.current_day_index] then
			local need_consume_gold = continue_consume[self.continue_consume_t.current_day_index].need_consume_gold or 0

			if self.continue_consume_t.cur_consume_gold >= need_consume_gold then
				count = count + 1
			end
		end

		if self.continue_consume_t.extra_reward_num ~= 0 then
			count = count + 1
		end
	end
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME, count > 0)
	return count
end

function ConsumeDiscountData:SetRAContinueConsumeInfo(protocol)
	self.continue_consume_t = {}
	self.continue_consume_t.today_consume_gold_total = protocol.today_consume_gold_total
	self.continue_consume_t.cur_consume_gold = protocol.cur_consume_gold
	self.continue_consume_t.continue_days_total = protocol.continue_days_total
	self.continue_consume_t.continue_days = protocol.continue_days
	self.continue_consume_t.current_day_index = protocol.current_day_index
	self.continue_consume_t.extra_reward_num = protocol.extra_reward_num
end

function ConsumeDiscountData:GetRAContinueConsumeInfo()
	return self.continue_consume_t
end

function ConsumeDiscountData:GetRAContinueConsumeRewardNum()
	local consume_info = ServerActivityData.Instance:GetRAContinueConsumeInfo()
	if consume_info then
		local continue_consume = self:GetRAContinueConsumeCfg()
		local need_consume_gold = continue_consume[consume_info.current_day_index].need_consume_gold or 0
		local count = consume_info.cur_consume_gold > need_consume_gold and 1 or 0
		count = count + consume_info.extra_reward_num
		return count
	end
	return 0
end

function ConsumeDiscountData:GetRAContinueConsumeCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().continue_consume
	if cfg == nil then
		return nil
	end
	return ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONTINUE_CONSUME)
end