-- 开服限时每日充值Data

LimitDailyChargeData = LimitDailyChargeData or BaseClass()
LimitDailyChargeData.ChargeMaxLev = #OpenServerDailyRechargeCfg.Gold		--每日充值最大档次
function LimitDailyChargeData:__init()
	if LimitDailyChargeData.Instance then
		ErrorLog("[LimitDailyChargeData] Attemp to create a singleton twice !")
	end

	LimitDailyChargeData.Instance = self
	self.day = 1
	self.TempGet = 0
	self.charge_num = 0
end

function LimitDailyChargeData:__delete()
	LimitDailyChargeData.Instance = nil
end

-- 每日充值
-- --------------------------------------

function LimitDailyChargeData:SetChargeEveryDay(protocol)
	self.day = protocol.day
	self.TempGet = protocol.TempGet
	self.charge_num = protocol.charge_num 
end

function LimitDailyChargeData:GetEveryDayCellRewardCfg(index)
	local cfg = OpenServerDailyRechargeCfg.Rewards
	local data = cfg and cfg[self.day] or cfg[#cfg]
	local cur_reward_cfg = data and data[index] or {}
	local charge_reward_data = {}
	for i, v in ipairs(cur_reward_cfg) do
		charge_reward_data[i] = {item_id = v.id, num = v.count, is_bind = v.bind}
	end
	return charge_reward_data
end

function LimitDailyChargeData:GetTempData()
	return self.TempGet
end

function LimitDailyChargeData:GetToDayNum()
	return self.day
end

-- 是否首冲了
function LimitDailyChargeData:IsFirstCharged()
	if ChargeFirstData.Instance then
		local first_charge_flag = ChargeFirstData.Instance:GetFirstChargeInformation() or 0
		return first_charge_flag == 2
	end

	return false
end

-- 是否已领取了所有档次的奖励
function LimitDailyChargeData:GetDailyChargeIsAllGet()
	local flag = true
	if self.TempGet and  "table" == type(self.TempGet) then
		for i,v in ipairs(self.TempGet) do
			if v.state == 0 or v.state == 1 then
				flag =  false
				return flag
			end
		end
	end
	return flag
end

function LimitDailyChargeData:GetCanLinQu()
	local flag = 0
	for i,v in ipairs(self.TempGet) do
		if v.state == 1 then
			flag =  1
			return flag
		end
	end
	return flag
end

-- 是否在限定开放天数之内
function LimitDailyChargeData:IsInOpenTime()
	if OtherData.Instance:GetCombindDays() <= 0 then
		local opendays = OpenServerDailyRechargeCfg.NotCondOpenDays
		if #opendays <= 0 then		--没有开服天数限制
			return true
		elseif #opendays > 0 and OtherData.Instance:GetOpenServerDays() > opendays[#opendays] then
			return true
		end
	else
		local combine = OpenServerDailyRechargeCfg.NotCondCombineDays
		if #combine > 0 and OtherData.Instance:GetCombindDays() > combine[#combine] then
			return true
		end
	end
	return false
end

function LimitDailyChargeData:GetEveryDayChargeIconOpen()
	local bool = false
	bool = self:IsFirstCharged() and not self:GetDailyChargeIsAllGet()
	return bool
end
