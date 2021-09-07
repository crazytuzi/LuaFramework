PHONE_TYPE = {
	ANDROID = 0,
	IPHONE = 1,
	WINDOW = 2
}

RechargeData = RechargeData or BaseClass()

RechargeData.SPEC_ID = -1
RechargeData.InVaildId = -99
function RechargeData:__init()
	if RechargeData.Instance then
		print_error("[RechargeData] Attemp to create a singleton twice !")
	end
	RechargeData.Instance = self
	if UnityEngine.Application.platform == UnityEngine.RuntimePlatform.Android then
		self.platform = PHONE_TYPE.ANDROID
	elseif UnityEngine.Application.platform == UnityEngine.RuntimePlatform.IPhonePlayer then
		self.platform = PHONE_TYPE.IPHONE
	elseif UnityEngine.Application.platform == UnityEngine.RuntimePlatform.OSXEditor or UnityEngine.Application.platform == UnityEngine.RuntimePlatform.WindowsEditor  then
		self.platform = PHONE_TYPE.IPHONE
	end
	self.chongzhi_7day_reward_fetch_day = 0
	self.chongzhi_7day_reward_timestamp = 0
	self.chongzhi_7day_reward_is_fetch  = 0
	self.rand_act_zhuanfu_type = 1
	RemindManager.Instance:Register(RemindName.Recharge, BindTool.Bind(self.GetRechargeRemind, self))
end

function RechargeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Recharge)
	RechargeData.Instance = nil
end

function RechargeData:SetChongZhi7DayFetchReward(protocol)
	self.chongzhi_7day_reward_fetch_day = protocol.chongzhi_7day_reward_fetch_day
	self.chongzhi_7day_reward_timestamp = protocol.chongzhi_7day_reward_timestamp
	self.chongzhi_7day_reward_is_fetch  = protocol.chongzhi_7day_reward_is_fetch
end

-- 充值18元档 七天返利达成时间
function RechargeData:GetChongZhi7DayRewardDay()
	return self.chongzhi_7day_reward_fetch_day
end

-- 充值18元档 今天是否已领取
function RechargeData:GetChongZhi7DayRewardIsFetch()
	return self.chongzhi_7day_reward_is_fetch
end

function RechargeData:DayRechangeCanReward()
	return self.chongzhi_7day_reward_timestamp > 0 and self.chongzhi_7day_reward_fetch_day < 7 and self.chongzhi_7day_reward_is_fetch == 0
end

-- Mainui_view 充值红点专用
function RechargeData:MainuiViewDayRechangeCanReward()
	if self:DayRechangeCanReward() == true then
		return 1
	else
		return 0
	end
end

-- 充值18元档 是否购买
function RechargeData:HasBuy7DayChongZhi()
	return self.chongzhi_7day_reward_timestamp > 0
end

function RechargeData:SetServerSystemInfo(protocol)
	self.rand_act_zhuanfu_type = protocol.param1
end

function RechargeData:GetRandActZhuanfuType()
	return self.rand_act_zhuanfu_type
end

--获取安卓充值配置
function RechargeData:GetAnroidRechargeCfg()
	local rand_act_zhuanfu_type = self:GetRandActZhuanfuType()
	if rand_act_zhuanfu_type == 1 then
		return ConfigManager.Instance:GetAutoConfig("recharge_auto")
	else
		return ConfigManager.Instance:GetAutoConfig("recharge" .. rand_act_zhuanfu_type .. "_auto")
	end	
end

--获取苹果充值配置
function RechargeData:GetIPhoneRechargeCfg()
	return ConfigManager.Instance:GetAutoConfig("rechargeappstore_auto").recharge_list
end

function RechargeData:GetChongzhiCfg()
	local rand_act_zhuanfu_type = self:GetRandActZhuanfuType()
	if rand_act_zhuanfu_type == 1 then
		return ConfigManager.Instance:GetAutoConfig("chongzhireward_auto")
	else
		return ConfigManager.Instance:GetAutoConfig("chongzhireward" .. rand_act_zhuanfu_type .. "_auto")
	end
end

--获取充值奖励配置
function RechargeData:GetChongzhiRewardCfg()
	local cfg = self:GetChongzhiCfg()
	return cfg.reward
end

--获取某个充值奖励配置
function RechargeData:GetChongzhiRewardCfgById(recharge_id)
	local cfg = self:GetChongzhiRewardCfg()
	local data = self:GetRechargeInfo(recharge_id)
	if nil == data then return end
	for k,v in pairs(cfg) do
		if v.chongzhi == data.gold then
			return v
		end
	end
	return nil
end
--获取某个充值奖励配置(同上)
function RechargeData:NewGetChongzhiRewardCfgById(chongzhi_gold)
	local cfg = self:GetChongzhiRewardCfg()
	for k,v in pairs(cfg) do
		if v.chongzhi == chongzhi_gold then
			return v
		end
	end
	return nil
end

--获取18元档次充值奖励配置
function RechargeData:GetChongzhi18YuanRewardCfg()
	local cfg = self:GetChongzhiCfg()
	return cfg.other[1]
end

--获得需要加载的id
function RechargeData:GetRechargeIdList()
	if self.recharge_data_list == nil then
		local rechange_cfg = {}
		self.recharge_data_list = {}
		if self.platform== PHONE_TYPE.ANDROID then
			rechange_cfg = self:GetAnroidRechargeCfg().recharge_list
		elseif self.platform == PHONE_TYPE.IPHONE then
			--rechange_cfg = self:GetIPhoneRechargeCfg()
			local is_enforce_cfg = GLOBAL_CONFIG.param_list.is_enforce_cfg
			local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
			local pos_first_word = string.find(agent_id, "i")
			-- 强制用1安卓的配置(用于ios越狱)
			-- 字母i开头的渠道id都是ios正版（剑南说的）
			if is_enforce_cfg == 1 or pos_first_word ~= 1 then
				rechange_cfg = self:GetAnroidRechargeCfg().recharge_list
			else
				rechange_cfg = self:GetIPhoneRechargeCfg()
			end
		end


		local check_agent_id = ChannelAgent.GetChannelID()
		local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_list		
		for k,v in pairs(rechange_cfg) do
			local is_show = v.show_ui == 1
			if v.id == RechargeData.SPEC_ID and IS_AUDIT_VERSION then
				is_show = false
			end

			if agent_cfg ~= nil then
				for k1, v1 in pairs(agent_cfg) do
					if v1 ~= nil and check_agent_id ~= nil and v1.spid == check_agent_id then
						if v.money >= v1.shield then
							is_show = false
							break
						end
					end
				end
			end

			if is_show then
				self.recharge_data_list[#self.recharge_data_list + 1] = v.id
			end
		end
		function sortfun(a, b)
			return a < b
		end
		table.sort(self.recharge_data_list, sortfun)
	end
	return self.recharge_data_list
end

--获取充值ID对应一列信息
function RechargeData:GetRechargeInfo(rechange_id)
	if self.platform == PHONE_TYPE.ANDROID then
		rechange_cfg = self:GetAnroidRechargeCfg().recharge_list
	elseif self.platform == PHONE_TYPE.IPHONE then
		--rechange_cfg = self:GetIPhoneRechargeCfg()
		local is_enforce_cfg = GLOBAL_CONFIG.param_list.is_enforce_cfg
		local agent_id = GLOBAL_CONFIG.package_info.config.agent_id
		local pos_first_word = string.find(agent_id, "i")
		-- 强制用1安卓的配置(用于ios越狱)
		-- 字母i开头的渠道id都是ios正版（剑南说的）
		if is_enforce_cfg == 1 or pos_first_word ~= 1 then
			rechange_cfg = self:GetAnroidRechargeCfg().recharge_list
		else
			rechange_cfg = self:GetIPhoneRechargeCfg()
		end
	end
	
	for k,v in pairs(rechange_cfg) do
		if v.id == rechange_id then
			return v
		end
	end
end

-- 获取18元档次配置
function RechargeData:GetRecharge18Info(rechange_id)
	for k,v in pairs(self:GetChongzhi18YuanRewardCfg()) do
		if v.id == rechange_id then
			return v
		end
	end
end

--通过索引获得需要加载该索引的集合
function RechargeData:GetRechargeListByIndex(cell_index)
	local all_id_list = TableCopy(self:GetRechargeIdList())
	local recharge_id_list = {}
	if cell_index == 1 then
		for i=1,4 do
			if all_id_list[i] ~= nil then
				recharge_id_list[#recharge_id_list + 1] = all_id_list[i]
			else
				recharge_id_list[#recharge_id_list + 1] = RechargeData.InVaildId
			end
		end
		return recharge_id_list
	end
	for i=1,4 do
		if all_id_list[(cell_index - 1)*4 + i] == nil then
			all_id_list[(cell_index - 1)*4 + i] = RechargeData.InVaildId
		end
		recharge_id_list[#recharge_id_list + 1] = all_id_list[(cell_index - 1)*4 + i]
	end
	return recharge_id_list
end

function RechargeData:GetRechargeRemind()
	return self:DayRechangeCanReward() and 1 or 0
end

-- 是否 都首充完
function RechargeData:IsFirstRecharge()
	local id_list = {}
	local flag_id
	local reward_flag
	for i=1,4 do
		id_list = RechargeData.Instance:GetRechargeListByIndex(i)
		for i=1,4 do
			if id_list[i] then
				if id_list[i] ~= RechargeData.InVaildId then
					reward_flag = DailyChargeData.Instance:GetFristChargeRewardFlag(id_list[i])
					if reward_flag ~= 1 then
						return false
					end
				end
			end
		end
	end
	return true
end


