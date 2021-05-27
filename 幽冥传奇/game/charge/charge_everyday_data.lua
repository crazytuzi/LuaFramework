ChargeEveryDayData = ChargeEveryDayData or BaseClass()

function ChargeEveryDayData:__init()
	if ChargeEveryDayData.Instance then
		ErrorLog("[ChargeEveryDayData] Attemp to create a singleton twice !")
	end

	ChargeEveryDayData.Instance = self
	self.plan_num = 0
	self.few_days = 0
	self.cur_level = 0
	self.state =0
end

function ChargeEveryDayData:__delete()
	ChargeEveryDayData.Instance = nil
end

-- 每日充值
-- --------------------------------------

function ChargeEveryDayData:SetChargeEveryDay(protocol)
	self.plan_num = protocol.plan_num
	self.few_days = protocol.few_days
	self.cur_level = protocol.cur_level
	self.state = protocol.state 
end

function ChargeEveryDayData:GetEveryDayRewardCfg()
	local cfg = DailyRechargeCfg
	local data = cfg and cfg[self.plan_num] or {}
	local cur_data = data.Rewards and data.Rewards[self.few_days] or {}
	local cur_reward_data = cur_data[self.cur_level] or {}
	local charge_reward_data = {}
	for i, v in ipairs(cur_reward_data) do
		local id = v.id 
		local count = v.count
		local bind = v.bind
		charge_reward_data[i] = {item_id = id, num = count, is_bind = bind}
	end
	return charge_reward_data
end

function ChargeEveryDayData:GetLevel()
	return self.cur_level
end

function ChargeEveryDayData:GetState()
	return self.state
end

function ChargeEveryDayData:GetNum(level)
	local cfg = DailyRechargeCfg
	local data = cfg and cfg[self.plan_num] or {}
	local gold = data.Gold and data.Gold[level] or 10000
	return gold
end