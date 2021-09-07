FreeGiftData = FreeGiftData or BaseClass()

ZERO_GIFT_OPERATE_TYPE =
{
	ZERO_GIFT_GET_INFO = 0,
	ZERO_GIFT_BUY = 1,
	ZERO_GIFT_FETCH_REWARD_GOLD = 2,
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
	RemindManager.Instance:Register(RemindName.ZeroGift, BindTool.Bind(self.GetZeroGiftRemind, self))
end

function FreeGiftData:__delete()
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

function FreeGiftData:GetZeroGiftRemindBySeq(seq)
	local info = self.phase_list[seq]
	local server_time = TimeCtrl.Instance:GetServerTime()
	if info and info.state == ZERO_GIFT_STATE.HAD_BUY_STATE and info.timestamp <= server_time then
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
	for k,v in pairs(self.phase_list) do
		if k < 3 then
			if ((v.state == ZERO_GIFT_STATE.UN_ACTIVE_STATE or v.state == ZERO_GIFT_STATE.ACTIVE_STATE) and v.timestamp > server_time)
			or v.state == ZERO_GIFT_STATE.HAD_BUY_STATE then
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
		if v.state == ZERO_GIFT_STATE.HAD_BUY_STATE and v.timestamp <= server_time then
			num = num + 1
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
	for k,v in pairs(self.phase_list) do
		if self.remind_timer == nil and v.state == ZERO_GIFT_STATE.HAD_BUY_STATE and v.timestamp > TimeCtrl.Instance:GetServerTime() then
			self.remind_timer = GlobalTimerQuest:AddDelayTimer(function()
				self.remind_timer = nil
				RemindManager.Instance:Fire(RemindName.ZeroGift)
			end, v.timestamp - TimeCtrl.Instance:GetServerTime())
		end
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