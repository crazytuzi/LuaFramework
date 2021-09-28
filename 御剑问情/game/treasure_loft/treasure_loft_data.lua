TreasureLoftData = TreasureLoftData or BaseClass()

function TreasureLoftData:__init()
	if TreasureLoftData.Instance then
		print_error("[TreasureLoftData] Attemp to create a singleton twice !")
	end
	TreasureLoftData.Instance = self
	RemindManager.Instance:Register(RemindName.ZhenBaoge, BindTool.Bind(self.GetZhenBaogeRemind, self))
end

function TreasureLoftData:__delete()
	self:RemoveDelayTime()
	RemindManager.Instance:UnRegister(RemindName.ZhenBaoge)
	TreasureLoftData.Instance = nil
end

function TreasureLoftData:HasRareItemNotBuy()
	local has_rare_item = false
	local randact_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
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


function TreasureLoftData:SetZhenbaogeInfo(protocol)
	self.zhenbaoge_item_list = protocol.zhenbaoge_item_list
	self.zhenbaoge_server_fetch_flag = protocol.zhenbaoge_server_fetch_flag
	self.cur_server_flush_times = protocol.cur_server_flush_times
	self.zhenbaoge_next_flush_timestamp = protocol.zhenbaoge_next_flush_timestamp
end

function TreasureLoftData:GetZhenBaoGeFetchFlagByIndex(index)
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

function TreasureLoftData:GetNextFlushTimeStamp()
	return self.zhenbaoge_next_flush_timestamp or 0
end

--返回活动结束时间
function TreasureLoftData:GetActEndTime()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
 		return time
	end
	return 0
end

function TreasureLoftData:GetTreasureLoftGridData()
	return self.zhenbaoge_item_list
end

function TreasureLoftData:GetServerFetchFlagTable()
	return self.zhenbaoge_server_fetch_flag
end

function TreasureLoftData:GetServerFlushTimes()
	return self.cur_server_flush_times
end

function TreasureLoftData:GetDisplayItemTable()
	local randact_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
	local display_item_table = {}
	if randact_cfg ~= nil and randact_cfg ~= nil then
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

function TreasureLoftData:GetRewardListData()
	local zhenbaoge_cfg = KaifuActivityData.Instance:GetZhenBaoGeCfg()
	local reward_data = {}
	local index = 0
	if nil ~= zhenbaoge_cfg then
		for k,v in pairs(zhenbaoge_cfg) do
			if v.cfg_type == 1 then
				reward_data[index] = v
				index = index + 1
			end
		end
	end
	return reward_data
end

function TreasureLoftData:GetVipRewardCanFetch()
	local data = self:GetRewardListData()
	local cur_num = TreasureLoftData.Instance:GetServerFlushTimes() or 0
	for i=0,5 do
		if data[i] then
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
	end
	return false
end

function TreasureLoftData:GetZhenBaogeRemind()
	local nexttime = TreasureLoftData.Instance:GetNextFlushTimeStamp() - TimeCtrl.Instance:GetServerTime()
	local can_fetch_reward = self:GetVipRewardCanFetch()
	if nexttime <= 0 or can_fetch_reward then
		return 1
	else
		if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT) and nil == self.remind_timer then
 			self.remind_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateRemind,self), nexttime)
 		end
		return 0
	end
end

function TreasureLoftData:RemoveDelayTime()
	if self.remind_timer then
		GlobalTimerQuest:CancelQuest(self.remind_timer)
		self.remind_timer = nil
	end
end

function TreasureLoftData:FlushHallRedPoindRemind()
	local remind_num = self:GetZhenBaogeRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT,remind_num > 0)
end


function TreasureLoftData:UpdateRemind()
	RemindManager.Instance:Fire(RemindName.ZhenBaoge)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TREASURE_LOFT,true)
end