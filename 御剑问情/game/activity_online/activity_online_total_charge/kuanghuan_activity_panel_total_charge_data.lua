KuanHuanActivityTotalChargeData = KuanHuanActivityTotalChargeData or BaseClass(BaseEvent)

function KuanHuanActivityTotalChargeData:__init()
	if nil ~= KuanHuanActivityTotalChargeData.Instance then
		return
	end

	local time = bit:d2b(0)
	self.is_open = false

	self.single_info = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0] = {},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1] = {},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2] = {},
	}

	self.cfg_list = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0] = {cfg = {}},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1] = {cfg = {}},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2] = {cfg = {}},
	}	

	for k,v in pairs(self.single_info) do
		local temp = {charge_max_value = 0, reward_times = time, reward_type = 0, cfg = {}}
		self.single_info[k] = temp
	end

	self:InitTotalChargeOne()
	self:InitTotalChargeTwo()
	self:InitTotalChargeThree()

	KuanHuanActivityTotalChargeData.Instance = self

	RemindManager.Instance:Register(RemindName.OffLineTotalCharge, BindTool.Bind(self.GetRemind, self))
end

function KuanHuanActivityTotalChargeData:__delete()
	KuanHuanActivityTotalChargeData.Instance = nil

	RemindManager.Instance:UnRegister(RemindName.OffLineTotalCharge)
end

function KuanHuanActivityTotalChargeData:InitTotalChargeOne()
	self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_total_charge_0
	local cfg = self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0].cfg

	local data = self.single_info[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0]
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
	data.reward_type = (cfg[1].reward_type == 0)
end

function KuanHuanActivityTotalChargeData:InitTotalChargeTwo()
	self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_total_charge_1
	local cfg = self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1].cfg

	local data = self.single_info[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1]
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
	data.reward_type = (cfg[1].reward_type == 0)
end

function KuanHuanActivityTotalChargeData:InitTotalChargeThree()
	self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_total_charge_2
	local cfg = self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2].cfg

	local data = self.single_info[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2]
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
	data.reward_type = (cfg[1].reward_type == 0)
end

function KuanHuanActivityTotalChargeData:SetTotalChargeInfo(protocol)
	local id = protocol.act_id
	if self.single_info[id] then
		self.single_info[id].charge_max_value = protocol.charge_max_value
		self.single_info[id].reward_flag = bit:d2b(protocol.reward_flag)
	end
end


function KuanHuanActivityTotalChargeData:GetSingleCfgInfo(act_id)
	local data = self.single_info[act_id]

	if nil == data then
		return nil
	end

	local day = ActivityOnLineData.Instance:GetOpenTime(act_id)
	local cur_day = self:GetCurOpenDay(act_id, day)

	for k,v in pairs(data.cfg) do
		if cur_day == k then
			return v
		end
	end

	return nil
end

function KuanHuanActivityTotalChargeData:GetSingleRewardFlag(act_id, index)
	local cfg = self.single_info[act_id]
	if nil == cfg then
		return 0
	end

	local times = cfg.reward_flag
	if nil == times then
		return 0
	end

	return times[32 - index]
end

function KuanHuanActivityTotalChargeData:GetRewardType(act_id)
	if nil == self.single_info[act_id] then
		return false
	end

	return self.single_info[act_id].reward_type
end

function KuanHuanActivityTotalChargeData:GetChargeValue(act_id)
	if nil == self.single_info[act_id] then
		return false
	end

	return self.single_info[act_id].charge_max_value
end

function KuanHuanActivityTotalChargeData:SetIsOpen(is_open)
	self.is_open = is_open
end

function KuanHuanActivityTotalChargeData:GetRemind()
	if self.is_open then
		return 0
	end

	return 1
end

function KuanHuanActivityTotalChargeData:GetCurOpenDay(act_id, day)
	local data = self.cfg_list[act_id]

	if nil == data then
		return 999
	end

	for k,v in pairs(data.cfg) do
		if day <= v.opengame_day then
			return v.opengame_day
		end
	end

	return 999
end