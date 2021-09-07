DaSheTianXiaData = DaSheTianXiaData or BaseClass()

function DaSheTianXiaData:__init()
	if DaSheTianXiaData.Instance ~= nil then
		ErrorLog("[DaSheTianXiaData] Attemp to create a singleton twice !")
	end
	DaSheTianXiaData.Instance = self
	self.is_can_play_ani = true
	self.money_tree_free_timestamp = 0
	self.is_shield = false
	RemindManager.Instance:Register(RemindName.DASHE_TIAN_XIA, BindTool.Bind(self.GetZhuanCount, self))
end

function DaSheTianXiaData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DASHE_TIAN_XIA)
	DaSheTianXiaData.Instance = nil
end

function DaSheTianXiaData:GetIsShield()
	return self.is_shield
end

function DaSheTianXiaData:SetIsShield(is_shield)
	self.is_shield = is_shield
end

function DaSheTianXiaData:CanGetRewardBySeq(index)
   local seq_list = self:GetGridLotteryTreeAllRewardData()
   if self.server_total_money_tree_times >= seq_list[index].server_rock_times then
	  return true
   else return false
   end
end

function DaSheTianXiaData:GetRewardBySeq(seq)
	local seq_list = self:GetGridLotteryTreeAllRewardData()
	for k,v in pairs(seq_list) do
		if v.seq == seq then
			local data = {}
			local wdata = {}
			data.item_id = v.item_id
			data.is_bind = v.is_bind
			data.num = v.num
			wdata[1] = data
			return wdata
		end
	end
	return {}
end

function DaSheTianXiaData:GetOtherCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu_5
end

local zzl_cur_day = 0
function DaSheTianXiaData:GetZhuanZhuanLeOtherCfg()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().yaoqianshu_5_other
	local other_cfg = ListToMap(cfg,"opengame_day")
	if (self.zhuanzhuanle_other_cfg == nil or (zzl_cur_day ~= open_day)) and cfg and other_cfg then
		zzl_cur_day = open_day
		local temp = 1
		for k,v in pairs(cfg) do
			if open_day <= v.opengame_day then
				temp = v.opengame_day
				break
			end
		end
		 self.zhuanzhuanle_other_cfg = other_cfg[temp]
	end
	return self.zhuanzhuanle_other_cfg
end

function DaSheTianXiaData:SetZhuanZhuanLeInfo(protocol)
	self.money_tree_info = protocol
end

function DaSheTianXiaData:GetZhuanZhuanLeInfo()
	if self.money_tree_info  then
	   return  self.money_tree_info
	end
	return {}
end

function DaSheTianXiaData:SetMoneyTreeInfo(protocol)
	self.server_total_money_tree_times = protocol.money_tree_total_times
	self.server_total_money_tree_pool_gold = protocol.server_total_pool_gold
	self.money_tree_free_timestamp = protocol.money_tree_free_timestamp
	self.server_reward_has_fetch_reward_flag = bit:d2b(protocol.server_reward_has_fetch_reward_flag)
end

function DaSheTianXiaData:SetMoneyTreeChouResultInfo(protocol)
	self.money_tree_reward_list = protocol.reward_req_list
	self.reward_req_list_count = protocol.reward_req_list_count
end

function DaSheTianXiaData:GetRewardList()
	 return self.money_tree_reward_list or {}
end

function DaSheTianXiaData:GetServerMoneyTreeTimes()
	return self.server_total_money_tree_times or 0
end

function DaSheTianXiaData:GetServerMoneyTreePoolGold()
	return self.server_total_money_tree_pool_gold or 0
end

function DaSheTianXiaData:GetGridLotteryTreeData()
	local act_cfg = self:GetOtherCfg()
	if nil == act_cfg.money_tree then  return end

	local data_list = {}
	local index = 0
	for k,v in pairs(act_cfg.money_tree) do
		if index == 0 then
			local item = {}
			item.item_id = 65534
			item.num = 1
			item.is_bind = 1
			data_list[index] = item
			index = index + 1
		elseif 0 == v.cfg_type and 1 == v.show_item then
			data_list[index] = v.reward_item
			index = index + 1
		end
	end
	return data_list
end

function DaSheTianXiaData:GetZhuanZhuanLeKeyNum()
	local cfg = self:GetZhuanZhuanLeOtherCfg()
	local num = 0
	if cfg and cfg.replace_item then
		num = ItemData.Instance:GetItemNumInBagById(cfg.replace_item)
	end
	return num
end

function DaSheTianXiaData:GetZhuanZhuanLFreeInterval()
	local cfg = self:GetZhuanZhuanLeOtherCfg()
	local free_interval = 99999
	if cfg and cfg.free_interval then
		free_interval = cfg.free_interval
	end
	return free_interval
end

function DaSheTianXiaData:GetZhuanZhuanLFreeTotalTimes()
	local cfg = self:GetZhuanZhuanLeOtherCfg()
	local free_time = 0
	if cfg and cfg.free_time then
		free_time = cfg.free_time
	end
	return free_time
end

function DaSheTianXiaData:GetGridLotteryTreeAllRewardData()
	local act_cfg = self:GetOtherCfg()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	if nil == self.server_reward_has_fetch_reward_flag then return {} end
	local data_list = {}
	local index = 1
	for k,v in pairs(act_cfg) do
		if 1 == v.cfg_type and 1 == v.show_item and open_day <= v.opengame_day then
			local data = {}
			data.seq = v.seq
			data.item_id = v.reward_item.item_id
			data.is_bind = v.reward_item.is_bind
			data.num = v.reward_item.num
			if self.server_reward_has_fetch_reward_flag[32 - index + 1] then
				data.fetch_reward_flag = self.server_reward_has_fetch_reward_flag[32 - index + 1]
			end
			data.server_rock_times = v.server_rock_times
			data.vip_limit = v.vip_limit
			data.opengame_day = v.opengame_day
			data_list[index] = data
			index = index + 1
		end
	end
	return data_list
end

function DaSheTianXiaData:GetGridLotteryTreeRewardData()
	local act_cfg = self:GetOtherCfg()
	if nil == self.money_tree_reward_list or act_cfg == nil then
		return
	end
	local open_time_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local data_list = {}
	local index = 1
	for i, m in pairs(self.money_tree_reward_list) do
		for k,v in pairs(act_cfg) do
			if open_time_day <= v.opengame_day and v.seq == m and v.cfg_type == 0 then
				local data = {}
				data.item_id = v.reward_item.item_id
				data.num = v.reward_item.num
				data.is_bind = v.reward_item.is_bind
				if type(v.prize_pool_percent) == "number" and v.prize_pool_percent > 0 then
					data.item_id = 65534
					data.num = 1
					data.is_bind = 1
				end

				if self.is_use_lottery_tree_item == 1 then
					data.is_bind = 1
				end
				data_list[index] = data
				index = index + 1
				break
			end
		end
	end
	return data_list
end
-- 保持玩家领取累计奖励的seq
function DaSheTianXiaData:SetLinRewardSeq(seq_index)
	self.seq_index = seq_index
end

function DaSheTianXiaData:GetLinRewardSeq()
	return self.seq_index or 0
end

function DaSheTianXiaData:SetFreeTime(day_count)
	self.day_count = day_count
end

function DaSheTianXiaData:GetFreeTime()
	return self.day_count or 0
end

function DaSheTianXiaData:SetAniState(value)
	self.is_can_play_ani = not value
end

function DaSheTianXiaData:GetAniState(value)
	return self.is_can_play_ani
end

function DaSheTianXiaData:GetMianFeiTime()
	-- 下次免费时间
	local time = math.max(TimeCtrl.Instance:GetServerTime() - self.money_tree_free_timestamp, 0)
	time = math.floor(time)
	return time
end

function DaSheTianXiaData:GetRewardInfo()
	local allaTreeTime = self:GetServerMoneyTreeTimes()
	local reward_cfg = self:GetGridLotteryTreeAllRewardData()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	local first_day = reward_cfg[1].opengame_day
	for i = 1, 6 do
		if reward_cfg[i] then
			if allaTreeTime >= reward_cfg[i].server_rock_times then
				if vip_level >= reward_cfg[i].vip_limit then
					if self.server_reward_has_fetch_reward_flag[32 - i + 1] == 0 and reward_cfg[i].opengame_day == first_day then
						return 1
					end
				end
			end
		end
	end
	return 0
end

function DaSheTianXiaData:GetZhuanCount()
	local mianfei = self:GetMianFeiTime()
	local other_cfg =  ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	local lengque_time = other_cfg.money_tree_free_interval
	local free_times = other_cfg.money_tree_free_times
	local used_times = self:GetFreeTime()
	local flag = self:GetRewardInfo()
	if lengque_time <= mianfei and used_times < free_times then
		return 1
	end
	if flag == 1 or (self:GetZhuanZhuanLeKeyNum() > 0) then
		return 1
	end

	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5) and nil == self.remind_timer then
		local uesd_times = self:GetFreeTime()
		local times = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1].money_tree_free_times

		if uesd_times < times then
			self.remind_timer = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpdateRemind,self),lengque_time - mianfei)
		end
	end
	return 0
end

function DaSheTianXiaData:ZhuanZhaunLePoindRemind()
	local remind_num = self:GetZhuanCount()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5,remind_num > 0)
end

--返回活动结束时间
function DaSheTianXiaData:GetActEndTime()
	local act_info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5)
	if act_info then
		local next_time = act_info.next_time
		local time = math.max(next_time - TimeCtrl.Instance:GetServerTime() , 0)
		return time
	end
	return 0
end

function DaSheTianXiaData:UpdateRemind()
	RemindManager.Instance:Fire(RemindName.DASHE_TIAN_XIA)
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MONEY_TREE_5,true)
end
