FanFanZhuanData = FanFanZhuanData or BaseClass()

function FanFanZhuanData:__init()
	if FanFanZhuanData.Instance then
		print_error("[FanFanZhuanData] Attemp to create a singleton twice !")
	end
	FanFanZhuanData.Instance = self
	-- 先转成二阶数组

	self.fanfanzhuan_info = {}
	self.return_reward_list = {}
	self.cur_level = 0
	self.treasuer_item_list = {}
	self.draw_times = {}
	self.return_reward_flag = 0
	self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
	RemindManager.Instance:Register(RemindName.RemindFanFanZhuan, self.remind_change)
end

function FanFanZhuanData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RemindFanFanZhuan, self.remind_change)
	FanFanZhuanData.Instance = nil
end

function FanFanZhuanData:SetKingDrawInfoInfo(protocol)
	self.fanfanzhuan_info = protocol.card_list
	self.draw_times = protocol.draw_times
	self.return_reward_flag = protocol.return_reward_flag
end

function FanFanZhuanData:GetKingDrawInfoInfo()
	return self.fanfanzhuan_info
end

function FanFanZhuanData:GetDrawTimesByLevel(level)
	return self.draw_times[level] or 0
end

function FanFanZhuanData:GetRewardFlag()
	return self.return_reward_flag
end

function FanFanZhuanData:GetinfoByLevelAndIndex(level, index)
	if nil == self.fanfanzhuan_info[level] then
		return -1
	end

	return self.fanfanzhuan_info[level][index] or -1
end

function FanFanZhuanData:GetRewardByLevelAndIndex(level, index)
	if nil == self.config then
		self.config = {}
		local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw
		config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
		for k,v in pairs(config) do
			if nil == self.config[v.level] then
				self.config[v.level] = {}
			end
			self.config[v.level][v.seq] = v
		end
	end

	if nil == self.config[level] then
		return {}
	end

	return self.config[level][index] or {}
end

-- 获得要展示的物品
function FanFanZhuanData:GetShowRewardCfgByOpenDay()
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw
	config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
	local show_list = {}
	for k,v in ipairs(config) do
		if v.is_onshow == 1 then
			table.insert(show_list, v.reward_item)
		end
	end

	return show_list
end

function FanFanZhuanData:ClearReturnRewardList()
	self.return_reward_list = {}
end

-- 销毁界面的时候会调用ClearReturnRewardList清除self.return_reward_list表
function FanFanZhuanData:GetReturnRewardByLevel(level)
	local return_reward_list = {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw_return_reward
	config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)

	for i,v in pairs(config) do
		if v.level == level then
			table.insert(return_reward_list, v)
		end
	end

	return return_reward_list
end

function FanFanZhuanData:SetCurLevel(level)
	self.cur_level = level
end

function FanFanZhuanData:GetCurLevel()
	return self.cur_level
end

function FanFanZhuanData:SetTreasureItemList(list)
	self.treasuer_item_list = list
end

function FanFanZhuanData:GetTreasureItemList()
	return self.treasuer_item_list
end

function FanFanZhuanData:GetIsGetReward(level, index)
	local reward_flag_t = bit:d2b(self.return_reward_flag)
	-- 三个级别用一个return_reward_flag， 1~12为高级，13~22为中极，23~32为初级
	local flag_index = level * 10 + index
	local flag_t = {}

	return reward_flag_t[33 - flag_index]
end

function FanFanZhuanData:GetFanFanZhuanRemind()
 	local item_num = 0
 	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw_return_reward
 	config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)

 	for k, v in pairs(config) do
 		local draw_times = self:GetDrawTimesByLevel(v.level)
 		if v.draw_times <= draw_times then
 			local reward_flag = FanFanZhuanData.Instance:GetIsGetReward(v.level, v.seq + 1)
 			if reward_flag == 0 then
				item_num = item_num + 1
			end
 		end
 	end 
 	
	return item_num > 0
end

function FanFanZhuanData:RemindChangeCallBack()
	local show_redpoint = self:GetFanFanZhuanRemind()
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN, show_redpoint)
end

function FanFanZhuanData:GetRewardBoxRemind(box_level)
 	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().king_draw_return_reward
 	config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_FANFANZHUAN)
 	if not config then
 		return false
 	end
 	for k,v in pairs(config) do
 		local draw_times = self:GetDrawTimesByLevel(box_level) --已翻牌数目
 		if v.draw_times <= draw_times then
 			local reward_flag = FanFanZhuanData.Instance:GetIsGetReward(box_level, v.seq + 1)
 			if reward_flag == 0 then 					--如果还没有领取
 				return true
 			end
 		end
 	end
	return false
end