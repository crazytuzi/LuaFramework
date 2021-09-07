LuckyChessData = LuckyChessData or BaseClass()

function LuckyChessData:__init()
	if LuckyChessData.Instance ~= nil then
		ErrorLog("[LuckyChessData] Attemp to create a singleton twice !")
	end
	LuckyChessData.Instance = self

	self.day_day_up_all_info = {}
	self.day_day_up_all_info.next_free_timestamp = 0
	self.day_day_up_all_info.extra_times = 0
	self.day_day_up_all_info.start_pos = {}
	self.day_day_up_all_info.records_count = 0
	self.day_day_up_all_info.record_list = {}

	self.day_day_up_all_info.reward_flag = 0
	self.day_day_up_all_info.records_count = 0
	self.day_day_up_all_info.target_index = 0

	self.day_day_up_reward_info = {}
	self.day_day_up_reward_info.split_position = 0
	self.day_day_up_reward_info.reward_count = 0
	self.day_day_up_reward_info.reward_info_list = {}

	self.treasure_view_show_list = {}
	self.inside_cfg = {}
	self.outside_cfg = {}
	self.return_reward_cfg = {}
	RemindManager.Instance:Register(RemindName.LuckyChess, BindTool.Bind(self.GetLuckyChessRepoint, self))
end

function LuckyChessData:__delete()
	LuckyChessData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.LuckyChess)
end

function LuckyChessData:SetPromotingPositionAllInfo(protocol)
	self.day_day_up_all_info.next_free_timestamp = protocol.next_free_timestamp
	self.day_day_up_all_info.extra_times = protocol.extra_times
	self.day_day_up_all_info.start_pos = protocol.start_pos
	self.day_day_up_all_info.records_count = protocol.records_count
	self.day_day_up_all_info.record_list = protocol.record_list
	self.day_day_up_all_info.reward_flag = protocol.reward_flag
end

function LuckyChessData:SetPromotingPositionRewardInfo(protocol)
	self.day_day_up_reward_info.split_position = protocol.split_position
	self.day_day_up_reward_info.reward_count = protocol.reward_count
	self.day_day_up_reward_info.reward_info_list = protocol.reward_info_list
end

function LuckyChessData:GetDayDayUpStartData()
	-- local outside_reward = self:GetLuckOutsideReward()
	-- local inside_reward = self:GetLuckInsideReward()
	-- local a = 1
	-- self.day_day_up_all_info.showreward_text = {}
	-- if self.day_day_up_all_info.record_list == nil then return end
	-- for k, v in pairs(self.day_day_up_all_info.record_list) do
	-- 	local reward_data = {}
	-- 	if v.circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE then
	-- 		reward_data = outside_reward
	-- 	else
	-- 		reward_data = inside_reward
	-- 	end
	-- 	local data = reward_data[v.seq]
	-- 	if data.reward_type == 0 then
	-- 		local money = (data.reward_gold_rate+100) /100
	-- 		self.day_day_up_all_info.showreward_text[a] =  string.format(Language.DayDayUp.show_money , v.user_name or "", money or 0)
	-- 		a = a + 1
	-- 	elseif data.reward_type == 1 then
	-- 		local item_name =  ItemData.Instance:GetItemName(data.reward_item.item_id)
	-- 		self.day_day_up_all_info.showreward_text[a] =  string.format(Language.DayDayUp.show_item , v.user_name or "", item_name or "")
	-- 		a = a + 1
	-- 	end
	-- end
	local is_out_side_type = self.day_day_up_all_info.start_pos.circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE
	local config = is_out_side_type and self:GetLuckOutsideReward() or self:GetLuckInsideReward()
	for k,v in pairs(config) do
		if v.seq == self.day_day_up_all_info.start_pos.position then
			self.day_day_up_all_info.target_index = k
			break
		end
	end

	return self.day_day_up_all_info
end

function LuckyChessData:GetDayDayUpShowData()
	if self.day_day_up_reward_info.split_position ~= 0 then
		local is_out_side_type = self.day_day_up_all_info.start_pos.circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE
		local config = is_out_side_type and self:GetLuckOutsideReward() or self:GetLuckInsideReward()
		local index = 0
		for k,v in pairs(config) do
			for i=1,2 do
				if v.seq == self.day_day_up_reward_info.reward_info_list[i].seq then
					self.day_day_up_reward_info.reward_info_list[i].target_index = k
					index = index + 1
				end

				if index >= 2 then
					break
				end
			end
		end
	end
	return self.day_day_up_reward_info
end

function LuckyChessData:SetDayDayUpShowData()
	self.day_day_up_reward_info = {} 
end

function LuckyChessData:GetInitData()
	if nil == self.init_data then
		self.init_data = {}
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
		-- randact_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
		self.init_data.money_one = randact_cfg.other[1].promoting_position_play_once_gold
		self.init_data.money_ten = randact_cfg.other[1].promoting_position_10_times_gold
		self.init_data.time_interval = randact_cfg.other[1].promoting_position_free_play_interval
		self.init_data.times_use_item = randact_cfg.other[1].promoting_position_10_times_use_item
		self.init_data.chongzhimianfei = randact_cfg.other[1].promoting_position_extra_time_per_chongzhi_gold
	end
	return self.init_data
end

function LuckyChessData:ClearTreasureViewShowList()
	self.treasure_view_show_list = {}
end

function LuckyChessData:GetTreasureViewShowList()
	if nil == next(self.treasure_view_show_list) then
		local data_list = self.day_day_up_reward_info.reward_info_list
		local init_data = LuckyChessData.Instance:GetInitData()
		local money = init_data.money_one
		self.treasure_view_show_list = {}
		local index = 1
		for i=1,#data_list do
			local data = data_list[i]
			local config = self:GetConfigByCircleType(data.circle_type, data.seq)
			if config and (config.reward_type == 1 or config.reward_type == 0) then -- 1表示物品
				if config.reward_type == 1 then
					self.treasure_view_show_list[index] = config.reward_item
				else
					local reward_gold = config.reward_gold_rate + money
					self.treasure_view_show_list[index] = {item_id = 65534, num = reward_gold, is_bind = 0}
				end
				
				index = index + 1
			end
		end	
	end

	return self.treasure_view_show_list
end

function LuckyChessData:GetConfigByCircleType(circle_type, seq)
	local cfg = circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE and self:GetLuckOutsideReward() or self:GetLuckInsideReward()
	for k,v in pairs(cfg) do
		if v.seq == seq then
			return v
		end
	end
end

function LuckyChessData:GetDayDayUpShowList()
	local outside_reward = self:GetLuckOutsideReward()
	local inside_reward = self:GetLuckInsideReward()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	-- randact_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
	local base_money = randact_cfg.other[1].promoting_position_play_once_gold
	if base_money == nil then return end
	local show_list = {}
	local money =0
	local a = 0
	 for k, v in ipairs(self.day_day_up_reward_info.reward_info_list) do
	 	local reward_data = {}
		if v.circle_type == RA_PROMOTING_POSITION_CIRCLE_TYPE.RA_PROMOTING_POSITION_CIRCLE_TYPE_OUTSIDE then
			reward_data = outside_reward
		else
			reward_data = inside_reward
		end
		local data = reward_data[v.seq]
		if data.reward_type == 0 then
			money = money + (((data.reward_gold_rate/100) + 1) * base_money)
		elseif data.reward_type == 1 then
			show_list[a] = data.reward_item
			a = a + 1
		end
	end
	return show_list,money
end


function LuckyChessData:GetLuckOutsideReward()
	if nil == next(self.outside_cfg) then
		local outside_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().promoting_position_outside_reward
		-- self.outside_cfg = ActivityData.Instance:GetRandActivityConfig(outside_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
		self.outside_cfg = self:GetLuckyChessConfig(outside_cfg)
		self.outside_cfg[0] = {seq = -1, reward_type = 5}
	end
	return self.outside_cfg
end

function LuckyChessData:GetLuckyChessConfig(cfg)
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local rand_t = {}
	local day = nil

	for k,v in ipairs(cfg) do
		if v and v.opengame_day and (nil == day or v.opengame_day == day) and open_day <= v.opengame_day then
			day = v.opengame_day
			table.insert(rand_t, v)
		end
	end
	return rand_t
end

function LuckyChessData:GetLuckInsideReward()
	if nil == next(self.inside_cfg) then
		local inside_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().promoting_position_inside_reward
		-- self.inside_cfg = ActivityData.Instance:GetRandActivityConfig(inside_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
		self.inside_cfg = self:GetLuckyChessConfig(inside_cfg)
		self.inside_cfg[0] = {seq = -1, reward_type = 5}
	end
	
	return self.inside_cfg
end

function LuckyChessData:GetReturnRewardCfg()
	if next(self.return_reward_cfg) == nil then
		local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().promoting_position_return_reward
		self.return_reward_cfg = ActivityData.Instance:GetRandActivityConfig(randact_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_DAY_DAY_UP)
	end
	
	return self.return_reward_cfg
end

function LuckyChessData:GetIsFree()
	if not self.day_day_up_all_info or not self.day_day_up_all_info.next_free_timestamp then return end
	local free_time = self.day_day_up_all_info.next_free_timestamp
	local server_time = TimeCtrl.Instance:GetServerTime()
	if free_time - server_time <= 0 then
		return true
	end
	return false
end

function LuckyChessData:GetRewardCount()
	return self.day_day_up_all_info.extra_times
end

function LuckyChessData:GetIsGetReward(seq)
	local t = bit:d2b(self.day_day_up_all_info.reward_flag)
	return t[32 - seq] == 1
end

function LuckyChessData:GetLuckyChessRepoint()
	local list_data = self:GetReturnRewardCfg()
	local role_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	local cur_times = self:GetRewardCount()
	for k,v in pairs(list_data) do
		local is_get_reward = self:GetIsGetReward(k-1)
		if cur_times >= v.play_times and role_vip >= v.vip_limit and not is_get_reward then
			return 1
		end
	end
	return 0
end