PuzzleData = PuzzleData or BaseClass()

function PuzzleData:__init()
	if PuzzleData.Instance ~= nil then
		print_error("[PuzzleData] attempt to create singleton twice!")
		return
	end
	PuzzleData.Instance = self

	self.info = {}
	self.info.next_refresh_time = 0
	self.info.fanfan_cur_free_times = 0
	self.info.fanfan_cur_word_seq = 0
	self.ra_fanfan_leichou_times = 0
	self.word_list = {}
	self.fast_filp_stat = false 									-- 快速寻字按钮状态
	self.select_word_list = {}										-- 快速寻字-寻字列表
	self.filp_state = false 										-- true 发送一键寻字 false 收到寻字结果

	self.exchange_info = {}
	RemindManager.Instance:Register(RemindName.PuzzleView, BindTool.Bind1(self.CheckRemind, self))
end

function PuzzleData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PuzzleView)
	PuzzleData.Instance = nil
end

-- 更新实时信息
function PuzzleData:UpdateInfoData(protocol)
	self.info.next_refresh_time = protocol.next_refresh_time			-- 下一次重置时间
	self.info.card_type_list = protocol.card_type_list					-- 卡牌类型列表，物品为seq值，隐藏卡和字组卡是枚举值
	self.info.word_active_info_list = protocol.word_active_info_list	-- 字组激活信息列表
	self.info.hidden_word_info = protocol.hidden_word_info				-- 隐藏字信息
	self.info.fanfan_cur_free_times = protocol.fanfan_cur_free_times	-- 当前免费次数
	self.info.fanfan_cur_word_seq = protocol.fanfan_cur_word_seq		-- 当前刷到的字组索引
	self.ra_fanfan_leichou_times = protocol.ra_fanfan_leichou_times or 0 	-- 累翻次数
	self.is_fanfan_giveout = protocol.is_fanfan_giveout 				-- 领取标记

	-- 可兑换次数
	for i=0, self:GetWrodInfoCount() - 1 do
		self.exchange_info[i] = self.info.word_active_info_list[i].active_count
	end
end

-- 更新实时兑换信息
function PuzzleData:UpdateExchangeData(protocol)
	self.exchange_info[protocol.index] = protocol.active_count
end

-- 获取格子信息
function PuzzleData:GetFlipCell(index)
	if self.info.card_type_list == nil or self.info.card_type_list[index] == nil then
		print_warning(string.format("[PuzzleData:GetFlipCell] attempt to read \"info.card_type_list\" faild! index = %s", index))
		return 0, {}
	end

	local var = self.info.card_type_list[index]
	local seq_type = math.floor(var / 100)
	local seq = var % 100

	local item_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().fanfan_item_info
	item_info = ActivityData.Instance:GetRandActivityConfig(item_info, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
	local word_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().fanfan_word_info
	word_info = ActivityData.Instance:GetRandActivityConfig(word_info, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
	if seq_type == 0 then
		return 0, {}
	elseif seq_type == 1 then
		if item_info == nil or item_info[seq + 1] == nil then
			print_warning(string.format("[PuzzleData:GetFlipCell] attempt to read \"item_info\" faild! index = ", seq))
			return 0, {}
		end

		return seq_type, item_info[seq + 1].reward_item
	elseif seq_type == 2 then
		if word_info == nil or word_info[seq + 1] == nil then
			print_warning(string.format("[PuzzleData:GetFlipCell] attempt to read \"word_info\" faild! index = ", seq))
			return 0, {}
		end

		if self.info.hidden_word_info == nil then
			print_warning(string.format("[PuzzleData:GetFlipCell] attempt to read \"info.hidden_word_info\" faild! index = ", seq))
			return 0, {}
		end

		for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
			local word_index = self.info.hidden_word_info.hidden_letter_pos_list[i] - 100
			if word_index == index then
				return seq_type, (self.info.hidden_word_info.hidden_word_seq - RA_FANFAN_CARD_TYPE.RA_FANFAN_CARD_TYPE_WORD_BEGIN) * 4 + i
			end
		end

		return 0, {}
	end
end

-- 获取下次重置时间
function PuzzleData:GetNextResetTime()
	if self.info.next_refresh_time == nil then return 0 end

	return self.info.next_refresh_time
end

-- 获取当前字组数量
function PuzzleData:GetWrodInfoCount()
	local word_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().fanfan_word_info
	word_info = ActivityData.Instance:GetRandActivityConfig(word_info, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
	if word_info == nil then return 0 end

	return #word_info
end

-- 获取当前字组索引
function PuzzleData:GetCurWrodGroupIndex()
	if self.info.hidden_word_info == nil then return 0 end

	return self.info.hidden_word_info.hidden_word_seq - RA_FANFAN_CARD_TYPE.RA_FANFAN_CARD_TYPE_WORD_BEGIN
end

-- 获取当前字组翻转状态信息
function PuzzleData:GetFlipWordInfo()
	local info = {}
	if self.info.hidden_word_info == nil or self.info.hidden_word_info.hidden_letter_pos_list == nil then
		for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
			info[i] = -1
		end
		return info
	end

	for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
		info[i] = self.info.hidden_word_info.hidden_letter_pos_list[i] - 100
	end
	return info
end

-- 获取字组可兑换奖励次数
function PuzzleData:GetWrodExchangeNum(seq)
	if self.exchange_info == nil or self.exchange_info[seq] == nil then return 0 end

	return self.exchange_info[seq]
end

-- 获取字组信息
function PuzzleData:GetWrodInfo(seq)
	local word_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().fanfan_word_info
	word_info = ActivityData.Instance:GetRandActivityConfig(word_info, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
	if word_info == nil then return nil end

	return word_info[seq + 1]
end

-- 获取字组激活状态信息
function PuzzleData:GetWrodActiveInfo(seq)
	if self.info.word_active_info_list == nil or self.info.word_active_info_list[seq] == nil then
		local info = {}
		for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
			info[i] = false
		end
		return info
	end

	local info = self.info.word_active_info_list[seq]
	local word_status = {}
	for i=0, GameEnum.RA_FANFAN_LETTER_COUNT_PER_WORD - 1 do
		word_status[i] = bit:d2b(info.active_flag)[32 - i] ~= 0
	end
	return word_status
end

-- 获取翻转费用
function PuzzleData:GetFlipConsume()
	local condition_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	if condition_info == nil then return 0 end

	return condition_info.fanfan_once_need_gold
end

-- 获取重置费用
function PuzzleData:GetResetConsume()
	local condition_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	if condition_info == nil then return 0 end

	return condition_info.fanfan_refresh_need_gold
end

-- 获取免费翻转次数
function PuzzleData:GetCurFreeFlipTimes()
	if self.info == nil then return 0 end

	return self.info.fanfan_cur_free_times
end

-- 获取免费翻转次数总数
function PuzzleData:GetAllFreeFlipTimes()
	local condition_info = ServerActivityData.Instance:GetCurrentRandActivityConfig().other[1]
	if condition_info == nil then return 0 end

	return condition_info.fanfan_free_fan_times_per_day
end

-- 获取活动结束时间
function PuzzleData:GetActivityEndTime()
	local info = ActivityData.Instance:GetActivityStatuByType(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
	if info == nil then return 0 end

	return info.next_time
end

function PuzzleData:CanFanZhuan()
	for i=0, GameEnum.RA_FANFAN_CARD_COUNT - 1 do
		local seq_type, info = self:GetFlipCell(i)
		if seq_type > 0 then return false end
	end
	return true
end

function PuzzleData:GetBaoDiListCfg()
	local act_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local fanfan_reward = ActivityData.Instance:GetRandActivityConfig(act_cfg.fanfan_reward, ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN)
	return fanfan_reward
end

function PuzzleData:GetBaodiTotal()
	return self.ra_fanfan_leichou_times
end

function PuzzleData:IsGiveoutReward(index)
	if nil == self.is_fanfan_giveout or nil == index then return end

	if 0 ~= (bit:_and(self.is_fanfan_giveout, bit:_lshift(1, index))) then
		return true
	end

	return false
end

function PuzzleData:CheckRemind()
	if IS_ON_CROSSSERVER or not ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN) then
		return 0
	end
	local count = self:GetCurFreeFlipTimes()
	if not count or count < 0 then
		count = 0
	end

	--可兑换
	for i=0, PuzzleData.Instance:GetWrodInfoCount() - 1 do
		count = count + PuzzleData.Instance:GetWrodExchangeNum(i)
	end

	--累翻奖励
	for k,v in pairs(PuzzleData.Instance:GetBaoDiListCfg()) do
		local is_giveout_reward = PuzzleData.Instance:IsGiveoutReward(v.index)
		if not is_giveout_reward and self.ra_fanfan_leichou_times >= v.choujiang_times then
			count = count + 1
		end
	end
	ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_FANFAN, count > 0)
	return count
end

function PuzzleData:SetWordList(list)
	self.word_list = list
end

function PuzzleData:GetWordList()
	return self.word_list or nil
end

function PuzzleData:SetFastFilpState(state)
	self.fast_filp_stat = state
end

function  PuzzleData:GetFastFilpState()
	return self.fast_filp_stat
end

function PuzzleData:SetFilpState(state)
	self.filp_state = state
end

function PuzzleData:GetFilpState()
	return self.filp_state
end

function PuzzleData:GetIsFilp()
	if self.info.hidden_word_info == nil or self.info.hidden_word_info.hidden_letter_pos_list == nil then
		return false
	end
	for k,v in pairs(self.info.hidden_word_info.hidden_letter_pos_list) do
		if v > 0 then
			return true
		end
	end
	return false
end

function PuzzleData:GoldIsEnough()
	local has_gold = PlayerData.Instance:GetRoleVo().gold or 0
	local reset_need_gold = self:GetResetConsume()
	local flip_need_gold = self:GetFlipConsume()
	local need_gold = reset_need_gold + flip_need_gold
	if has_gold < need_gold then
		return false
	end
	return true
end

function PuzzleData:SetSelectWordList(list)
	self.select_word_list = list or {}
end

function PuzzleData:GetSelectWordList()
	return self.select_word_list
end