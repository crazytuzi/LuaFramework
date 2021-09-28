TreasureBusinessmanData = TreasureBusinessmanData or BaseClass()

function TreasureBusinessmanData:__init()
	if TreasureBusinessmanData.Instance then
		error("[TreasureBusinessmanData] Attempt to create singleton twice!")
		return
	end
	TreasureBusinessmanData.Instance = self
	RemindManager.Instance:Register(RemindName.ZhenBaoge2, BindTool.Bind(self.GetZhenBaogeRemind, self))
end

function TreasureBusinessmanData:__delete()
	self:RemoveDelayTime()
	RemindManager.Instance:UnRegister(RemindName.ZhenBaoge2)
	TreasureBusinessmanData.Instance = nil
end

function TreasureBusinessmanData:HasRareItemNotBuy()
	local has_rare_item = false
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().zhenbaoge2
	randact_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	if self.zhenbaoge_item_list ~= nil and randact_cfg ~= nil then
		for i = 0,#(self.zhenbaoge_item_list) do
			if self.zhenbaoge_item_list[i] ~= 0 and randact_cfg[self.zhenbaoge_item_list[i]].cfg_type == 0
				and randact_cfg[self.zhenbaoge_item_list[i]].is_rare == 1 then
				has_rare_item = true
				break
			end
		end
	end
	return has_rare_item
end

function TreasureBusinessmanData:SetRATreasureLoft(protocol)
	self.zhenbaoge_item_list = protocol.zhenbaoge_item_list
	self.zhenbaoge_server_fetch_flag = protocol.zhenbaoge_server_fetch_flag
	self.cur_server_flush_times = protocol.cur_server_flush_times
	self.zhenbaoge_next_flush_timestamp = protocol.zhenbaoge_next_flush_timestamp
end


function TreasureBusinessmanData:GetZhenBaoGeFetchFlagByIndex(index)
	if self.zhenbaoge_server_fetch_flag then
		local flag = bit:d2b(self.zhenbaoge_server_fetch_flag)
		local cur_flag = 0
		for i=1, 32 do
			cur_flag = flag[32 - index]
		end
		return cur_flag
	else
		return 0
	end
end

function TreasureBusinessmanData:GetNextFlushTimeStamp()
	return self.zhenbaoge_next_flush_timestamp or 0
end


--返回活动结束时间 
function TreasureBusinessmanData:GetActEndTime()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
 		return time
	end
	return 0
end

function TreasureBusinessmanData:GetTreasureLoftGridData()
	return self.zhenbaoge_item_list 
end

function TreasureBusinessmanData:GetServerFetchFlagTable()
	return self.zhenbaoge_server_fetch_flag
end

function TreasureBusinessmanData:GetServerFlushTimes()
	return self.cur_server_flush_times 
end


function TreasureBusinessmanData:GetDisplayItemTable()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().zhenbaoge2
	randact_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)

	local display_item_table = {}
	if randact_cfg ~= nil then
		local index = 0
		for k,v in pairs(randact_cfg) do
			if v.show_item == 1 then
				display_item_table[index] = v.reward_item
				index = index + 1
			end
		end
	end
	return display_item_table
end

function TreasureBusinessmanData:GetRewardListData()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().zhenbaoge2
	randact_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN)
	local reward_data = {}
	local index = 0
	if nil ~= randact_cfg then
		for k,v in pairs(randact_cfg) do
			if v.cfg_type == 1 then
				reward_data[index] = v
				index = index + 1
			end
		end
	end
	return reward_data
end

function TreasureBusinessmanData:GetProValueByTimes(times)
	local data = self:GetRewardListData()
	if times <= data[0].can_fetch_times then
		return 0.12 * times / data[0].can_fetch_times
	elseif times <= data[1].can_fetch_times then
		return 0.12 + 0.165 * (times - data[0].can_fetch_times) / (data[1].can_fetch_times -data[0].can_fetch_times)
	elseif times <= data[2].can_fetch_times then
		return 0.285 + 0.165 * (times - data[1].can_fetch_times) / (data[2].can_fetch_times -data[1].can_fetch_times)
	elseif times <= data[3].can_fetch_times then
		return 0.45 + 0.165 * (times - data[2].can_fetch_times) / (data[3].can_fetch_times -data[2].can_fetch_times)
	elseif times <= data[4].can_fetch_times then
		return 0.62 + 0.165 * (times - data[3].can_fetch_times) / (data[4].can_fetch_times -data[3].can_fetch_times)
	elseif times <= data[5].can_fetch_times then
		return  0.785 + 0.165 * (times - data[4].can_fetch_times) / (data[5].can_fetch_times -data[4].can_fetch_times)
	else
		return 0.95 + 0.05 * ((times - data[5].can_fetch_times) / 500)
	end
end

function TreasureBusinessmanData:GetVipRewardCanFetch()
	local data = self:GetRewardListData()
	local cur_num = self:GetServerFlushTimes() or 0
	for i=0,5 do
		local fetch_flag = self:GetZhenBaoGeFetchFlagByIndex(i + 1)
		local can_fetch_times = data[i].can_fetch_times
		local vip_limit = data[i].vip_limit
		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		if 0 == fetch_flag then
			if cur_num >= can_fetch_times and vip_level >= vip_limit then
				return true
			else
				return false
			end
		end
	end
	return false
end

function TreasureBusinessmanData:GetZhenBaogeRemind()
	local nexttime = self:GetNextFlushTimeStamp() - TimeCtrl.Instance:GetServerTime()
	local can_fetch_reward = self:GetVipRewardCanFetch()
	if nexttime <= 0 or can_fetch_reward then
		return 1
	else
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN) and nil == self.remind_timer then
 			self.remind_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateRemind,self), nexttime)
 		end
		return 0
	end
end

function TreasureBusinessmanData:RemoveDelayTime()
	if self.remind_timer then
		GlobalTimerQuest:CancelQuest(self.remind_timer)
		self.remind_timer = nil
	end
end

function TreasureBusinessmanData:FlushHallRedPoindRemind()
	local remind_num = self:GetZhenBaogeRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN,remind_num > 0)
end


function TreasureBusinessmanData:UpdateRemind()
	RemindManager.Instance:Fire(RemindName.ZhenBaoge2)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_BUSINESSMAN,true)
end