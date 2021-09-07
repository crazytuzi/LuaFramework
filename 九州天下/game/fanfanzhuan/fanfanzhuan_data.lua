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
	RemindManager.Instance:Register(RemindName.RemindFanFanZhuan, BindTool.Bind(self.GetFanFanZhuanRemind, self))
end

function FanFanZhuanData:__delete()
	RemindManager.Instance:UnRegister(RemindName.RemindFanFanZhuan)
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
		config = ActivityData.Instance:GetRandActivityConfig(config, ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD)
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
	local show_list = {}
	local day_flag = -1
	for k,v in ipairs(config) do
		if open_day <= v.opengame_day and v.is_onshow == 1 then
			if day_flag ~= -1 and v.opengame_day ~= day_flag then
				break
			end
			table.insert(show_list, v.reward_item)

			day_flag = v.opengame_day
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
	local day_flag = -1
	for i,v in pairs(config) do
		if v.level == level and open_day <= v.opengame_day then
			if day_flag ~= -1 and v.opengame_day ~= day_flag then
				break
			end
			table.insert(return_reward_list, v)

			day_flag = v.opengame_day
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
	-- 三个级别用一个return_reward_flag， 1~10为初级，11~20为中极，21~30为高级
	local flag_index = level * 10 + index
	local flag_t = {}

	return reward_flag_t[33 - flag_index]
end

function FanFanZhuanData:ForRemind()
	local randact_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local item_num = ItemData.Instance:GetItemNumInBagById(randact_cfg.other[1].king_draw_gaoji_consume_item)
	if item_num > 0 then
		return true
	end
	for i=0,2 do
		for y=0,1 do
			if self:GetFanFanZhuanRemOne(y, i) then
				return true
			end
		end
	end
	return false
end

function FanFanZhuanData:GetFanFanZhuanRemOne(page_index, cur_level)
	local return_reward_list = self:GetReturnRewardByLevel(cur_level)
	
	if return_reward_list == nil then
		return false
	end
	local draw_times = self:GetDrawTimesByLevel(cur_level)
	local reward_flag
	for i=0,2 do
		local index = (page_index * 3) + (i + 1)
		local data = return_reward_list[index]
		if nil == data then return false end
		if draw_times >= data.draw_times then
			reward_flag = FanFanZhuanData.Instance:GetIsGetReward(cur_level, index)
			if reward_flag ~= 1 then
				return true
			end
		end
	end
	return false
end

function FanFanZhuanData:GetFanFanZhuanRemind()
	local remind_num = self:ForRemind() and 1 or 0
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_PLEASE_DRAW_CARD, remind_num > 0)
	return remind_num
end
