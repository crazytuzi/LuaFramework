FreeGiftData = FreeGiftData or BaseClass()

ZERO_GIFT_OPERATE_TYPE =
{
	ZERO_GIFT_GET_INFO = 0,
	ZERO_GIFT_BUY = 1,
	ZERO_GIFT_FETCH_REWARD_GOLD = 2,
	ZERO_GIFT_FETCH_REWARD_ITEM = 3,
}

ZERO_GIFT_STATE =
	{
		UN_ACTIVE_STATE = 0,			-- 未达到购买等级，未激活
		ACTIVE_STATE = 1,				-- 达到购买等级，可购买
		HAD_BUY_STATE = 2,				-- 已购买
		HAD_FETCHE_STATE = 3,			-- 已经领取返还元宝
	}

function FreeGiftData:__init()
	if FreeGiftData.Instance then
		print_error("[FreeGiftData] Attemp to create a singleton twice !")
	end
	FreeGiftData.Instance = self
	self.phase_list = {
		[0] = {state = 0, timestamp = 0},
		{state = 0, timestamp = 0},
		{state = 0, timestamp = 0},
		{state = 0, timestamp = 0},
		{state = 0, timestamp = 0},
	}
	local zero_gift_cfg = ConfigManager.Instance:GetAutoConfig("zerogift_auto")
	self.phase_cfg = ListToMap(zero_gift_cfg.phase_cfg, "seq")
	self.model_cfg = zero_gift_cfg.show_cfg
	RemindManager.Instance:Register(RemindName.ZeroGift, BindTool.Bind(self.GetZeroGiftRemind, self))
end

function FreeGiftData:__delete()
	self:RemoveDelayTimeOne()
	self:RemoveDelayTimeTwo()
	self:RemoveDelayTimeThree()
	RemindManager.Instance:UnRegister(RemindName.ZeroGift)
	FreeGiftData.Instance = nil
end

function FreeGiftData:SetXeroGiftInfo(protocol)
	self.phase_list = protocol.phase_list
end

function FreeGiftData:GetXeroGiftInfo(seq)
	return self.phase_list[seq]
end

function FreeGiftData:GetZeroGiftCfg(seq)
	return self.phase_cfg[seq]
end

function FreeGiftData:GetZeroGiftModelCfg(seq, day)
	for k, v in pairs(self.model_cfg) do
		if v.seq == seq and v.index == day then
			return v
		end
	end
end

function FreeGiftData:GetZeroGiftRemindBySeq(seq)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local info = self.phase_list[seq]
	local can_reward = false
	if info and (info.state == ZERO_GIFT_STATE.HAD_BUY_STATE or info.state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) then
		local reward_flag = bit:d2b(info.reward_flag)
		if reward_flag[32] == 0
			or (reward_flag[31] == 0 and server_time - info.timestamp > 86400 * 1)
		  	or (reward_flag[30] == 0 and server_time - info.timestamp > 86400 * 2) then
			can_reward = true
		end
	end

	if info and (info.state == ZERO_GIFT_STATE.HAD_BUY_STATE or info.state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) and can_reward then
		return true
	end
	if info and info.state == ZERO_GIFT_STATE.ACTIVE_STATE and self.phase_cfg[seq] and self.phase_cfg[seq].buy_gold == 0
		and PlayerData.Instance:GetRoleVo().level >= self.phase_cfg[seq].level_limit and info.timestamp > server_time then
		return true
	end
	return false
end

function FreeGiftData:CanShowZeroGift()
	local server_time = TimeCtrl.Instance:GetServerTime()
	for i = 0, 2 do
		if self.phase_list[i] and self.phase_list[i].reward_flag
		 and (self.phase_list[i].state == ZERO_GIFT_STATE.HAD_BUY_STATE or self.phase_list[i].state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) then
			local reward_flag = bit:d2b(self.phase_list[i].reward_flag)
			if reward_flag[32] == 0 or reward_flag[31] == 0 or reward_flag[30] == 0 then
				return true
			end
		end
	end

	for k,v in pairs(self.phase_list) do
		if k < 1 then
			if ((v.state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or v.state == ZERO_GIFT_STATE.ACTIVE_STATE) and v.timestamp > server_time) then
				return true
			end
		end
	end
	return false
end

function FreeGiftData:GetZeroGiftRemind()
	if not OpenFunData.Instance:CheckIsHide("zero_gift") then
		return 0
	end
	local num = 0
	local server_time = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(self.phase_list) do
		if k > 2 then
			break
		end
		if v.state == ZERO_GIFT_STATE.HAD_BUY_STATE or v.state == ZERO_GIFT_STATE.HAD_FETCHE_STATE then
			local reward_flag = bit:d2b(self.phase_list[k].reward_flag)
			if reward_flag[32] == 0
			 or (reward_flag[31] == 0 and server_time - self.phase_list[k].timestamp > 86400 * 1)
			 or (reward_flag[30] == 0 and server_time - self.phase_list[k].timestamp > 86400 * 2) then

			num = num + 1
			end
		end
		if v.state == ZERO_GIFT_STATE.ACTIVE_STATE and self.phase_cfg[k] and self.phase_cfg[k].buy_gold == 0
			and PlayerData.Instance:GetRoleVo().level >= self.phase_cfg[k].level_limit and v.timestamp > server_time then
			num = num + 1
		end
	end
	if num == 0  then
		self:CheckRemind()
	end
	return num
end

function FreeGiftData:CheckRemind()
	local server_time = TimeCtrl.Instance:GetServerTime()
	for k,v in pairs(self.phase_list) do
		if k > 2 then
			break
		end
		if (self.remind_timer1 == nil and self.remind_timer2 == nil and self.remind_timer3 == nil)
		 and (v.state == ZERO_GIFT_STATE.HAD_BUY_STATE or v.state == ZERO_GIFT_STATE.HAD_FETCHE_STATE) then
		 -- and v.timestamp > TimeCtrl.Instance:GetServerTime() then
		 	local reward_flag = bit:d2b(self.phase_list[k].reward_flag)
		 	if reward_flag[32] == 0
			 or (reward_flag[31] == 0 and server_time - self.phase_list[k].timestamp <= 86400 * 1)
			 or (reward_flag[30] == 0 and server_time - self.phase_list[k].timestamp <= 86400 * 2) then

				self.remind_timer1 = GlobalTimerQuest:AddDelayTimer(function()
					self:RemoveDelayTimeOne()
					RemindManager.Instance:Fire(RemindName.ZeroGift)
				end, 1)

				self.remind_timer2 = GlobalTimerQuest:AddDelayTimer(function()
					self:RemoveDelayTimeTwo()
					RemindManager.Instance:Fire(RemindName.ZeroGift)
				end, 86400 * 1 - (server_time - self.phase_list[k].timestamp))

				self.remind_timer3 = GlobalTimerQuest:AddDelayTimer(function()
					self:RemoveDelayTimeThree()
					RemindManager.Instance:Fire(RemindName.ZeroGift)
				end, 86400 * 2 - (server_time - self.phase_list[k].timestamp))
			end
		end
	end
end

function FreeGiftData:RemoveDelayTimeOne()
	if self.remind_timer1 then
		GlobalTimerQuest:CancelQuest(self.remind_timer1)
		self.remind_timer1 = nil
	end
end

function FreeGiftData:RemoveDelayTimeTwo()
	if self.remind_timer2 then
		GlobalTimerQuest:CancelQuest(self.remind_timer2)
		self.remind_timer2 = nil
	end
end
function FreeGiftData:RemoveDelayTimeThree()
	if self.remind_timer3 then
		GlobalTimerQuest:CancelQuest(self.remind_timer3)
		self.remind_timer3 = nil
	end
end

function FreeGiftData:GetAutoIndex()
	for i=0, 2 do
		if self:GetZeroGiftRemindBySeq(i) then
			return i + 1
		end
	end
	for i=0, 2 do
		if self.phase_list[i] and self.phase_list[i].state == ZERO_GIFT_STATE.ACTIVE_STATE then
			return i + 1
		end
	end
	return 1
end