GodDropGiftData = GodDropGiftData or BaseClass()

local CLICK_STATE = {
	TOGGLE_60 = 60,
	TOGGLE_300 = 300,
}

function GodDropGiftData:__init()
	if GodDropGiftData.Instance then
		print_error("[GodDropGiftData]:Attempt to create singleton twice!")
	end
	GodDropGiftData.Instance = self
	self.charge_num = 0
	self.fetch_reward_flag = 0
	RemindManager.Instance:Register(RemindName.GodDropGift, BindTool.Bind(self.GetGodDropGiftIconRedPoint, self))
end

function GodDropGiftData:__delete()
	RemindManager.Instance:UnRegister(RemindName.GodDropGift)
	GodDropGiftData.Instance = nil
end

function GodDropGiftData:GetGodDropGiftCfg()
 	if self.god_drop_gift_cfg == nil or next(self.god_drop_gift_cfg) == nil then
 		-- --服务器在不同阶段有不同的奖励配置表
 		self.god_drop_gift_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().god_drop_gift
 		--self.god_drop_gift_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").god_drop_gift
	end
 	return self.god_drop_gift_cfg
 end

 function GodDropGiftData:SetGodDropGiftActivityInfo(protocol)
 	self.charge_num = protocol.chongzhi_num							--当日充值额度
 	self.fetch_reward_flag = protocol.fetch_reward_flag				--领取奖励标记  
 end

function GodDropGiftData:GetGodDropGiftInfo(need_chongzhi)	
	local god_drop_gift = self:GetGodDropGiftCfg()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	for k,v in pairs(god_drop_gift) do
		if v.opengame_day_index == cur_day then
			if v.need_chongzhi == need_chongzhi then
				return v
			end
		end
	end
	return {}
end

function GodDropGiftData:GetGodDropGiftIconRedPoint()
	local can_take_60 = self:GetCanTakeFlag(CLICK_STATE.TOGGLE_60)
	local can_take_300 = self:GetCanTakeFlag(CLICK_STATE.TOGGLE_300)
	if can_take_60 or can_take_300 then return 1 end
	return 0
end

function GodDropGiftData:GetCanTakeFlag(state)
	local is_take_state = self:GetFetchRewardFlag(state) ~= 0 
	local charge_state = self:GetChargeNum() >= state
	local can_take_state = false
	if not is_take_state and charge_state then 
		can_take_state = true
	end
	return can_take_state
end

function GodDropGiftData:GetChargeNum()
	return self.charge_num
end

function GodDropGiftData:GetFetchRewardFlag(state)
	local take_flag = bit:d2b(self.fetch_reward_flag)
	if state == CLICK_STATE.TOGGLE_60 then	
		return take_flag[#take_flag]
	elseif state == CLICK_STATE.TOGGLE_300 then 
		return take_flag[#take_flag - 1]
	end
end



