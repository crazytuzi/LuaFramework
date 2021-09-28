XianzunkaData = XianzunkaData or BaseClass()
XIANZUNKA_TYPE_MAX = 3
XIANZUNKA_OPERA_REQ_TYPE =
	{
		ALL_INFO = 0,				-- 请求所有信息
		BUY_CARD = 1,				-- 购买仙尊卡 param_1 : 仙尊卡类型
		FETCH_DAILY_REWARD = 2,		-- 拿取每日奖励 param_1 :仙尊卡类型
	}
function XianzunkaData:__init()
	if XianzunkaData.Instance then
		print_error("[XianzunkaData] attempt to create singleton twice!")
		return
	end
	XianzunkaData.Instance = self
	self.forever_active_flag = 0
	self.first_active_reward_flag = 0
	self.daily_reward_fetch_flag = 0
	self.temporary_valid_end_timestamp_list = {}
	RemindManager.Instance:Register(RemindName.Xianzunka, BindTool.Bind(self.GetXianzunkaRemind, self))
	self.xianzunka_addition_cfg = ListToMap(ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_addition_cfg, "card_type")
end

function XianzunkaData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Xianzunka)
	XianzunkaData.Instance = nil
end

function XianzunkaData:GetAdditionCfg(card_type)
	return self.xianzunka_addition_cfg[card_type]
end

function XianzunkaData:SetXianZunKaInfo(protocol)
	self.forever_active_flag = protocol.forever_active_flag
	self.first_active_reward_flag = protocol.first_active_reward_flag
	self.daily_reward_fetch_flag = protocol.daily_reward_fetch_flag
	self.temporary_valid_end_timestamp_list = protocol.temporary_valid_end_timestamp_list
end

function XianzunkaData:GetCardEndTimestamp(card_type)
	return self.temporary_valid_end_timestamp_list[card_type] or 0
end

function XianzunkaData:IsActiveForever(card_type)
	return bit:_and(1, bit:_rshift(self.forever_active_flag, card_type)) ~= 0
end

function XianzunkaData:IsActive(card_type)
	local timestamp = self.temporary_valid_end_timestamp_list[card_type] or 0
	return timestamp > TimeCtrl.Instance:GetServerTime()
end

function XianzunkaData:IsFirstActive(card_type)
	return bit:_and(1, bit:_rshift(self.first_active_reward_flag, card_type)) ~= 0
end

function XianzunkaData:IsDailyReward(card_type)
	return bit:_and(1, bit:_rshift(self.daily_reward_fetch_flag, card_type)) ~= 0
end

function XianzunkaData:GetXianzunkaRemind()
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("xianzunka_auto").xianzunka_base_cfg) do
		if (self:IsActive(v.card_type) or self:IsActiveForever(v.card_type)) and not self:IsDailyReward(v.card_type) then
			return 1
		end
		if self:IsActive(v.card_type) and not self:IsActiveForever(v.card_type) then
			if ItemData.Instance:GetItemNumInBagById(v.active_item_id) > 0 then
				return 1
			end
		end
	end
	return 0
end