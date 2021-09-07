MoonLightLandingData = MoonLightLandingData or BaseClass()

MOONLIGHTLANDING_REWARD_FLAG = {
	NOT_RECEIVED = 0,
	ALREADY_RECEIVED = 1, 
}

function MoonLightLandingData:__init()
	if MoonLightLandingData.Instance ~= nil then
		ErrorLog("[MoonLightLandingData] Attemp to create a singleton twice !")
	end
	MoonLightLandingData.Instance = self
	self.cur_logindday = 0
	self.daily_reward = 0
	self.login_reward_flag = 0
	self.personal_panic_buy_cfg = 0
	RemindManager.Instance:Register(RemindName.MoonLightLanding, BindTool.Bind(self.GetRemind, self))
end

function MoonLightLandingData:__delete()
	RemindManager.Instance:UnRegister(RemindName.MoonLightLanding)
	MoonLightLandingData.Instance = nil
	self.cur_logindday = nil
	self.daily_reward = nil
	self.login_reward_flag = nil
	self.personal_panic_buy_cfg = nil
end

--接收协议
function MoonLightLandingData:SetMoonLightLanding(protocol)
	self.cur_logindday = protocol.cur_logindday					--连续登陆天数
	self.daily_reward = protocol.daily_reward					--每日奖励领取标记
	self.login_reward_flag = protocol.login_reward_flag			--累计登陆奖励领取标记

end

function MoonLightLandingData:GetCurLogindDay()
	return self.cur_logindday or 0
end

function MoonLightLandingData:GetDailyRewardIsReceive()
	return self.daily_reward or 0
end

function MoonLightLandingData:GetMoonLightActivityCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().ljdl	
end

function MoonLightLandingData:GetMoonLightDaliyCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].ljdl_daily_reward
end

function MoonLightLandingData:SortLjReward()
	local reward_cfg = TableCopy(self:GetMoonLightActivityCfg())
	if reward_cfg and next(reward_cfg) then 
		for k,v in pairs(reward_cfg) do
			local has_reward = self:GetLoginReward(v.continue_login_days) or 0
			v.reward_flag = has_reward
		end
		SortTools.SortAsc(reward_cfg, "reward_flag", "continue_login_days")
		return reward_cfg
	end
	return nil
end

function MoonLightLandingData:GetLoginReward(index)
	if self.login_reward_flag and index then
		return  bit:_and(1, bit:_rshift(self.login_reward_flag, index)) or 0
	end

	return 0
end

function MoonLightLandingData:GetRemind()
	local curlogday = self:GetCurLogindDay()
	local reward_list = self:SortLjReward()

	if curlogday == 0 then return 0 end

	if reward_list and next(reward_list) then
		if self:GetDailyRewardIsReceive() == 0 then 
			return 1
		else
			for k,v in ipairs(reward_list) do
				if curlogday >= v.continue_login_days and v.reward_flag == MOONLIGHTLANDING_REWARD_FLAG.NOT_RECEIVED then
					return 1
				end
			end		
		end
	end

	return 0
end



