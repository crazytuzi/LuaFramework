ActivityOnLineData = ActivityOnLineData or BaseClass(BaseEvent)

local ONE_DAY = 24 * 60 * 60

ActivityOnLineData.RemindName_From_Id = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_0] = RemindName.OnLineDanBi,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_1] = RemindName.OnLineDanBi,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_SINGLE_CHARGE_2] = RemindName.OnLineDanBi,

	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_0] = RemindName.OffLineTotalCharge,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_1] = RemindName.OffLineTotalCharge,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_OFFLINE_TOTAL_CHARGE_2] = RemindName.OffLineTotalCharge,

	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_0] = RemindName.RewardGift0,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_1] = RemindName.RewardGift1,
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOGIN_GIFT_2] = RemindName.RewardGift2,
}

function ActivityOnLineData:__init()
	if nil ~= ActivityOnLineData.Instance then
		return
	end
	ActivityOnLineData.Instance = self

	local all_cfg = ConfigManager.Instance:GetAutoConfig("daily_act_cfg_auto")
	self.open_cfg = ListToMap(all_cfg.show_cfg, "act_id")

	self.open_num = 0
	self.open_index_list = {}
	self.open_time_list = {}

	self:InitOpenList()
end

function ActivityOnLineData:__delete()
	ActivityOnLineData.Instance = nil
end

function ActivityOnLineData:InitOpenList()
	for k,v in pairs(ONLINE_ACTIVITY_ID) do
		local temp = {status = 0, act_id = v, time = {}, name = ""}
		table.insert(self.open_index_list, temp)
		self.open_time_list[v] = temp
	end
end

function ActivityOnLineData:SetActivityStatus(protocol) 
	local status = protocol.status
	if status == ACTIVITY_STATUS.OPEN then
		self.open_num = self.open_num + 1
	elseif status == ACTIVITY_STATUS.CLOSE then
		self.open_num = self.open_num - 1
	end

	local time = {start_time = protocol.param_1, end_time = protocol.param_2, next_time = protocol.next_status_switch_time}
	
	for k,v in pairs(self.open_index_list) do
		if v.act_id == protocol.activity_type then
			v.status = status
			v.time = time
			v.name = self.open_cfg[v.act_id].act_name
		end
	end

	self.open_time_list[protocol.activity_type] = time

	table.sort(self.open_index_list, SortTools.KeyUpperSorter("status"))
end

function ActivityOnLineData:GetActivityOpenNum()
	return self.open_num
end

function ActivityOnLineData:GetActivityOpenCfgById(act_id)

end

function ActivityOnLineData:SetActivityName(act_id)
	
end

function ActivityOnLineData:GetOpenTime(act_id)
	local start_time = self.open_time_list[act_id].start_time
	local now_time = TimeCtrl.Instance:GetServerTime()
	local dif = now_time - start_time
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	return open_day - (math.ceil(dif / ONE_DAY) - 1)
end

function ActivityOnLineData:GetRestTime(act_id)
	local time = self.open_time_list[act_id]
	if nil == time then
		return 0
	end

	return time.next_time
end

function ActivityOnLineData:GetActivityOpenListByIndex(index)
	return self.open_index_list[index]
end

function ActivityOnLineData:GetActivityOpenList()
	return self.open_index_list
end

function ActivityOnLineData:GetFirstOpenActivity()
	local data = self.open_index_list[1]
	if nli == data then
		return 0
	end

	return data.act_id
end

--------------DATA新建文件夹放进去-------------