-- 登陆奖励
LoginRewardData = LoginRewardData or BaseClass()

LoginRewardData.CHANGE_VIEW_DATA = "change_view_data"
LoginRewardData.LOGIN_REWARD_CAN_GET = "login_reward_can_get"

function LoginRewardData:__init()
	if LoginRewardData.Instance then
		ErrorLog("[LoginRewardData]:Attempt to create singleton twice!")
	end
	LoginRewardData.Instance = self

	self.is_receive_all = false
	self.add_login_times = 0
	self.login_reward_flag = {}

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.LoginRewardCanReceive)
	GameCondMgr.Instance:ResgisterCheckFunc(GameCondType.LoginReward, BindTool.Bind(self.CondLoginReward, self))
end

function LoginRewardData:__delete()
	LoginRewardData.Instance = nil
end

function LoginRewardData:SetAddLoginTimes(days)
	self.add_login_times = days or 0
end

function LoginRewardData:GetAddLoginTimes()
	return self.add_login_times
end

function LoginRewardData:SetLoginRewardFlag(flag)
	self.login_reward_flag = flag
	self:CheckLoginReward()
	self:DispatchEvent(LoginRewardData.CHANGE_VIEW_DATA)

	RemindManager.Instance:DoRemind(RemindName.LoginRewardCanReceive)
end

function LoginRewardData:CheckLoginReward()
	local remind_num = 0
	local is_receive_all = true
	for k,v in pairs(self.login_reward_flag) do
		if v ~= 2 then
			is_receive_all = false
		end
		if v == 1 then
			remind_num = remind_num + 1	
		end
	end
	
	self:SetIsReceiveAll(is_receive_all)
	return remind_num
end 

function LoginRewardData:SetIsReceiveAll(bool)
	self.is_receive_all = bool
	if self.is_receive_all then
		local view_def = ViewDef.LoginReward
		ViewManager.Instance:CloseViewByDef(view_def)
		GameCondMgr.Instance:Check(view_def.v_open_cond)
	end
	GameCondMgr.Instance:CheckCondType(GameCondType.OutOfPrint)
end

function LoginRewardData:CondLoginReward()
	return 	not self.is_receive_all
end

function LoginRewardData:GetLoginRewardFlag(index)
	return self.login_reward_flag[index] or 0
end

function LoginRewardData:GetLoginRewardCanGetIndex()
	local num = #SevenDayAwardCfg
	for i=1,num do
		if self:GetLoginRewardFlag(i) == 1 then
			return i
		end
	end
end

function LoginRewardData:GetLoginRewardData(index)
	local award_cfg = SevenDayAwardCfg[index] and SevenDayAwardCfg[index].award
	-- local headtitle_id = SevenDayAwardCfg[index] and SevenDayAwardCfg[index].headtitleItemId
	if not award_cfg then return end

	local data = {}
	-- if headtitle_id then data[1] = {item_id = headtitle_id, num = 1, is_bind = 0, effectId = 920} end

	for k,v in pairs(award_cfg) do
		data[#data + 1] = ItemData.InitItemDataByCfg(v)
	end

	return data
end

function LoginRewardData:SetHaveRewardCanGetFlag(flag)
	local curShowIndex = self:GetLoginRewardCanGetIndex()
	if falg == nil then 
		self:DispatchEvent(LoginRewardData.LOGIN_REWARD_CAN_GET, curShowIndex and true or false)
	end
	return curShowIndex and true or false
end

function LoginRewardData.GetRemindIndex()
	local reward_index =  LoginRewardData.Instance:GetLoginRewardCanGetIndex()
	return reward_index and 1 or 0
end