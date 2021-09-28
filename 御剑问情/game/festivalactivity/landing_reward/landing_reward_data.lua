LandingRewardData = LandingRewardData or BaseClass()
function LandingRewardData:__init()
	if LandingRewardData.Instance ~= nil then
		ErrorLog("[LandingRewardData] attempt to create singleton twice!")
		return
	end
	LandingRewardData.Instance = self
	-- RemindManager.Instance:Register(RemindName.OnLineDanBi, BindTool.Bind(self.GetRemind, self))
	RemindManager.Instance:Register(RemindName.LoginRewardRemind, BindTool.Bind(self.LoginRewardRedPoint, self))
end

function LandingRewardData:__delete()
	LandingRewardData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.LoginRewardRemind)
end

function LandingRewardData:SetLandingRewardInfo(protocol)
	self.login_fetch_flag = bit:d2b(protocol.login_fetch_flag)
	self.vip_fetch_flag = bit:d2b(protocol.vip_fetch_flag)
	self.total_login_fetch_flag = bit:d2b(protocol.total_login_fetch_flag)
	self.is_today_login = protocol.is_today_login
	self.total_login_days = protocol.total_login_days
	FestivalActivityCtrl.Instance.view:Flush("landingeward")
end

function LandingRewardData:GetLoginFetchFlag()
	return self.login_fetch_flag or {}
end

function LandingRewardData:GetVipFetchFlag()
	return self.vip_fetch_flag or {}
end

function LandingRewardData:GetTotalLoginFetchFlag()
	return self.total_login_fetch_flag or {}
end

function LandingRewardData:GetIsTodayLogin()
	return self.is_today_login
end

function LandingRewardData:GetTotalLoginDays()
	return self.total_login_days
end

function LandingRewardData:LoginRewardRedPoint()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().login_active_gift
	local reward_list = ActivityData.Instance:GetRandActivityConfig(cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD) or {}
	local login_fetch_flag = self:GetLoginFetchFlag()
	local vip_fetch_flag = self:GetVipFetchFlag()
	local total_login_fetch_flag = self:GetTotalLoginFetchFlag()
	local total_login_days = self:GetTotalLoginDays()
	local is_today_login = self:GetIsTodayLogin()
	for k,v in pairs(reward_list) do
		if v and v.gift_type == 0 and is_today_login == 1 then
			if login_fetch_flag[32 - v.seq] == 0 then
				return 1
			end
		elseif v and v.gift_type == 1 and is_today_login ==1 then
			if vip_fetch_flag[32 - v.seq] == 0 and PlayerData.Instance.role_vo.vip_level >= v.condition_param then
				return 1
			end
		elseif v and  v.gift_type == 2 and is_today_login == 1 then
			if total_login_fetch_flag[32 - v.seq] == 0 and total_login_days >= v.condition_param then
				return 1
			end
		end
	end
	return 0
end