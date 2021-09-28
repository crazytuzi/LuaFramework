KuanHuanActivityPanelDanBiChongZhiData = KuanHuanActivityPanelDanBiChongZhiData or BaseClass(BaseEvent)

function KuanHuanActivityPanelDanBiChongZhiData:__init()
	if nil ~= KuanHuanActivityPanelDanBiChongZhiData.Instance then
		return
	end

	KuanHuanActivityPanelDanBiChongZhiData.Instance = self
	local time = bit:d2b(0)
	
	self.single_info = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = {},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1] = {},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2] = {},
	}

	self.cfg_list = {
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = {cfg = {}},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1] = {cfg = {}},
		[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2] = {cfg = {}},
	}

	self.is_open = false

	for k,v in pairs(self.single_info) do
		local temp = {charge_max_value = 0, reward_times = time, reward_type = 0, cfg = {}}
		self.single_info[k] = temp
	end

	self:InitSingleChargeOne()
	self:InitSingleChargeTwo()
	self:InitSingleChargeThree()

	RemindManager.Instance:Register(RemindName.OnLineDanBi, BindTool.Bind(self.GetRemind, self))
end

function KuanHuanActivityPanelDanBiChongZhiData:__delete()
	KuanHuanActivityPanelDanBiChongZhiData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.OnLineDanBi)
end

function KuanHuanActivityPanelDanBiChongZhiData:InitSingleChargeOne()
	self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_single_charge_0
	local cfg = self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0].cfg
	
	local data = self.single_info[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0]
	data.reward_type = (cfg[1].reward_type == 0)
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
end

function KuanHuanActivityPanelDanBiChongZhiData:InitSingleChargeTwo()
	self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_single_charge_1
	local cfg = self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1].cfg
	local data = self.single_info[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1]
	data.reward_type = (cfg[1].reward_type == 0)
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
end

function KuanHuanActivityPanelDanBiChongZhiData:InitSingleChargeThree()
	self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2].cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().offline_single_charge_2
	local cfg = self.cfg_list[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2].cfg
	local data = self.single_info[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2]
	data.reward_type = (cfg[1].reward_type == 0)
	data.cfg = ListToMap(cfg, "opengame_day", "seq")
end

function KuanHuanActivityPanelDanBiChongZhiData:GetSingleCfgInfo(act_id)
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

function KuanHuanActivityPanelDanBiChongZhiData:GetSingleRewardTime(act_id, index)
	local data = self.single_info[act_id]
	if nil == data then
		return 0
	end

	local times = data.reward_times
	if nil == times then
		return 0
	end

	local cfg = self:GetSingleCfgInfo(act_id)

	if nil == cfg or nil == cfg[index] then
		return 0
	end

	local cfg_time = cfg[index].reward_limit

	return cfg_time - times[index + 1]
end

function KuanHuanActivityPanelDanBiChongZhiData:SetSingleInfo(protocol)
	self.single_info[protocol.act_id].charge_max_value = protocol.charge_max_value
	self.single_info[protocol.act_id].reward_times = protocol.reward_times
end

function KuanHuanActivityPanelDanBiChongZhiData:GetSingleInfoById(act_id)
	return self.single_info[act_id]
end

function KuanHuanActivityPanelDanBiChongZhiData:GetRewardType(act_id)
	local cfg = self.single_info[act_id]
	if nil == cfg then
		return false
	end
	
	return cfg.reward_type
end

function KuanHuanActivityPanelDanBiChongZhiData:SetIsOpen(is_open)
	self.is_open = is_open
end

function KuanHuanActivityPanelDanBiChongZhiData:GetCurOpenDay(act_id, day)
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

function KuanHuanActivityPanelDanBiChongZhiData:GetRemind()
	if self.is_open then
		return 0
	end

	return 1
end

