CupMoonActivityData = CupMoonActivityData or BaseClass()
function CupMoonActivityData:__init()
	if CupMoonActivityData.Instance then
		ErrorLog("[QiXiActivityData] attempt to create singleton twice!")
		return
	end
	CupMoonActivityData.Instance = self
    self.midautumn_cup_info = {}
    RemindManager.Instance:Register(RemindName.MidAutumnCupMoon, BindTool.Bind(self.GetRemind, self))
end

function CupMoonActivityData:__delete()
	CupMoonActivityData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.MidAutumnCupMoon)
end

function CupMoonActivityData:SetMidAutumnCupInfo(protocol)
	self.midautumn_cup_info.total_charge_value = protocol.total_charge_value   
	self.midautumn_cup_info.reward_has_fetch_flag = protocol.reward_has_fetch_flag
end

function CupMoonActivityData:GetMidAutumnCupInfo()
	return self.midautumn_cup_info
end

function CupMoonActivityData:GetOpenActTotalChongZhiReward()
	local info = self:GetMidAutumnCupInfo()
	if info == nil or next(info) == nil then return end

    local fetch_reward_t = bit:d2b(info.reward_has_fetch_flag) or {}
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().rand_total_chongzhi_5
    local list = {}
    for i,v in ipairs(config) do
		local reward_has_fetch_flag = (fetch_reward_t[32 - v.seq] and 1 == fetch_reward_t[32 - v.seq]) and 1 or 0
		local data = TableCopy(v)
		data.reward_has_fetch_flag = reward_has_fetch_flag
		table.insert(list, data)
	 end
	 
	 table.sort(list, SortTools.KeyLowerSorter("reward_has_fetch_flag", "need_chognzhi"))
     return list
end

function CupMoonActivityData:IsTotalChongZhiRemind()
	if not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN_CUP_MOON) then
		return false
	end
	local info = self:GetMidAutumnCupInfo()
	local list = self:GetOpenActTotalChongZhiReward()
	if info == nil or next(info) == nil then return end
	for i,v in ipairs(list) do
		if v.reward_has_fetch_flag == 0 and info.total_charge_value >= v.need_chognzhi then
			return true
		end
	end
	return false
end

function CupMoonActivityData:GetRemind()
	local remind_num = self:IsTotalChongZhiRemind() and 1 or 0
	return remind_num
end

