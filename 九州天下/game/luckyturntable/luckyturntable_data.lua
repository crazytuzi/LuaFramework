LuckyTurntableData = LuckyTurntableData or BaseClass()

function LuckyTurntableData:__init()
	if LuckyTurntableData.Instance ~= nil then
		ErrorLog("[LuckyTurntableData] Attemp to create a singleton twice !")
	end
	LuckyTurntableData.Instance = self
	self.is_can_play_ani = true
	self.totoal_charge = 0
	self.last_chance = 0
	self.reward_index = -1
	RemindManager.Instance:Register(RemindName.LuckyTurntable, BindTool.Bind(self.GetRemind, self))
end

function LuckyTurntableData:__delete()
	RemindManager.Instance:UnRegister(RemindName.LuckyTurntable)
	LuckyTurntableData.Instance = nil
	self.totoal_charge = 0
	self.last_chance = 0
	self.reward_index = -1
end

--接收协议
function LuckyTurntableData:SetLuckyTurntable(protocol)
	self.totoal_charge = protocol.totoal_charge
	self.last_chance = protocol.last_chance
	self.reward_index = protocol.reward_index
end

--获取逻辑配置表
function LuckyTurntableData:GetLuckyTurntableCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().one_yuan_draw_times_cfg
end

--获取奖励配置表
function LuckyTurntableData:GetLuckyTurntableRewardList()
	local act_status = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_TURNTABLE)
	local server_time = TimeCtrl.Instance:GetServerTime()
	local check_day = nil
	local reward_list = {}
	local reward_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().one_yuan_draw_reward_cfg

	for _,v in ipairs(reward_cfg) do
		if v ~= nil then
			if check_day == nil or check_day < v.opengame_day_index then
				check_day = v.opengame_day_index
			end
		end
	end

	if check_day == nil then
		check_day = 7
	end

	local now_day = math.ceil(check_day - (act_status.end_time - server_time) / 3600 / 24)

	for _,v in ipairs(reward_cfg) do
		if now_day == v.opengame_day_index then
			table.insert(reward_list, v)
		end
	end

	return reward_list
end

function LuckyTurntableData:GetActEndTime()
	local act_status = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LUCKY_TURNTABLE) or 0
	local server_time = TimeCtrl.Instance:GetServerTime() or 0
	local act_last_time = act_status.end_time - server_time
	return act_last_time
end

--返回奖励索引
function LuckyTurntableData:GetRewardIndex()
	return self.reward_index
end

--返回抽奖次数
function LuckyTurntableData:GetChance()
	return self.last_chance
end

--返回仍需充值
function LuckyTurntableData:GetNeedCharge()
	if self.totoal_charge ~= nil then
		for _,v in pairs(self:GetLuckyTurntableCfg()) do
			if self.totoal_charge < v.need_total_chongzhi then
				return v.need_total_chongzhi - self.totoal_charge
			end
		end
	end
	return 0
end

--累计充值
function LuckyTurntableData:GetTotalCharge()
	return self.totoal_charge
end

--返回奖励
function LuckyTurntableData:GetReward()
	if nil ~= self.reward_index and self.reward_index > -1 then
		local reward_item = {[1] = self:GetLuckyTurntableRewardList()[self.reward_index + 1].reward_item}
		return reward_item
	end
	return self:GetLuckyTurntableRewardList()[1].reward_item
end

--返回红点
function LuckyTurntableData:GetRemind()
	if nil == self.last_chance then
		return 0
	end
	return self.last_chance > 0 and 1 or 0
end

--动画Get、Set
function LuckyTurntableData:SetAniState(value)
	self.is_can_play_ani = not value
end

function LuckyTurntableData:GetAniState()
	return self.is_can_play_ani
end
