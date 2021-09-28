LuckyDrawData = LuckyDrawData or BaseClass()

function LuckyDrawData:__init()
	if LuckyDrawData.Instance then
		print_error("[LuckyDrawData] Attemp to create a singleton twice !")
		return
	end
	LuckyDrawData.Instance = self

	self.free_chou_times = 0
	self.reward_history_item_count_list = {}
	self.cur_select_list = {}
	self.add_lots_list = {}
	self.open_day_list = {}
	self.reward_history_list_cur_index = 0
	self.auto_start_flag = false	-- 自动占卜标志
	self.stop_flag = false			-- 停止自动占卜标志
	self.reward_data_list = {}
end

function LuckyDrawData:__delete()
	LuckyDrawData.Instance = nil
end

function LuckyDrawData:SetLuckyDrawInfo(protocol)
	self.free_chou_times = protocol.free_chou_times									-- 今天已用免费卜卦次数
	self.add_lots_list = protocol.add_lots_list										-- 竹签加注,RA_TIANMING_LOT_COUNT = 6
	self.reward_history_item_count_list = protocol.reward_history_item_count_list	-- 获奖历史记录,RA_TIANMING_REWARD_HISTORY_COUNT = 20
	self.reward_history_list_cur_index = protocol.reward_history_list_cur_index		-- 历史列表中最旧下标
end

function LuckyDrawData:SetLuckyDrawResultInfo(protocol)
	self.reward_index = protocol.reward_index
	self.reward_data_list = protocol.item_info_list
end

--占卜十次结果
function LuckyDrawData:GetRewardData()
	return self.reward_data_list
end

function LuckyDrawData:GetJiangChiCfg(seq)
	local jiang_chi_cfg = {}
	if nil == self.tianming_jiangchi_cfg then
		local jiangchi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().tianming_jiangchi
		self.tianming_jiangchi_cfg = ActivityData.Instance:GetRandActivityConfig(jiangchi_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW)
	end
	for k,v in pairs(self.tianming_jiangchi_cfg) do
		if seq and seq == v.seq then
			return v
		end
	end
	return jiang_chi_cfg
end

function LuckyDrawData:GetCanAddLotCfg()
	local can_add_lot_list_cfg = {}
	for k,v in ipairs(self:GetJiangChiList()) do
		if v.can_add_lot == 1 then
			table.insert(can_add_lot_list_cfg, v)
		end
	end
	return can_add_lot_list_cfg
end

function LuckyDrawData:GetItemCountList()
	return self.reward_history_item_count_list
end

function LuckyDrawData:GetConsumeCfg(lot_add_times)
	local tianming_consume_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().tianming_consume
	for k,v in pairs(tianming_consume_cfg) do
		if v.lot_add_times == lot_add_times then
			return v
		end
	end
	return nil
end

function LuckyDrawData:GetAddLotList()
	return self.add_lots_list
end

function LuckyDrawData:GetNeedPayMoney()
	local add_num = 0
	if #self.add_lots_list + 1 == GameEnum.RA_TIANMING_LOT_COUNT then
		for k,v in pairs(self.add_lots_list) do
			add_num = add_num + v
		end
		add_num = add_num - GameEnum.RA_TIANMING_LOT_COUNT
	else
		print("error")
	end
	local need_pay_money = self:GetConsumeCfg(add_num).chou_consume_gold
	return need_pay_money
end

function LuckyDrawData:GetRewardItemCfg()
	local reward_item_list = {}
	for k,v in ipairs(self:GetJiangChiList()) do
		if v.show == 1 then
			table.insert(reward_item_list, v)
		end
	end
	return reward_item_list
end

function LuckyDrawData:GetRewardIndex()
	return self.reward_index or 1
end

function LuckyDrawData:SetRestTime(time)
	self.rest_time = time
end

function LuckyDrawData:GetRestTime()
	return self.rest_time
end

function LuckyDrawData:GetOpenGameDay(open_day)
	local num = 0
	if nil == self.tianming_jiangchi_cfg then
		local jiangchi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().tianming_jiangchi
		self.tianming_jiangchi_cfg = ActivityData.Instance:GetRandActivityConfig(jiangchi_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW)
	end
	for k,v in pairs(self.tianming_jiangchi_cfg) do
		if num ~= v.opengame_day then
			num = v.opengame_day
			table.insert(self.open_day_list, num)
		end
	end
	for k,v in pairs(self.open_day_list) do
		if open_day < v then
			return v
		end
	end
	return self.open_day_list[1]
end

function LuckyDrawData:GetJiangChiList()
	if nil == self.tianming_jiangchi_cfg then
		local jiangchi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().tianming_jiangchi
		self.tianming_jiangchi_cfg = ActivityData.Instance:GetRandActivityConfig(jiangchi_cfg, ACTIVITY_TYPE.RAND_ACTIVITY_LUCKYDRAW)
	end
	local jiangchi_cfg_list = ListToMapList(self.tianming_jiangchi_cfg, "opengame_day")
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local open_game_day = self:GetOpenGameDay(open_day)
	return jiangchi_cfg_list[open_game_day]
end

function LuckyDrawData:SetAutoFlag(flag)
	self.auto_start_flag = flag
end

function LuckyDrawData:GetAutoFlag()
	return self.auto_start_flag
end

function LuckyDrawData:SetStopFlag(flag)
	self.stop_flag = flag
end

function LuckyDrawData:GetStopFlag()
	return self.stop_flag
end

function LuckyDrawData:IsDesired()
	for i,v in pairs(self.cur_select_list) do
		if self.reward_index == v then
			return true
		end
	end
	return false
end

function LuckyDrawData:GetCanAutoList()
	local award_list = self:GetJiangChiList()
	local auto_divination_list = {}
	for i,v in ipairs(award_list) do
		if v.can_auto_roll == 1 then
			table.insert(auto_divination_list, v)
		end
	end

	-- 奖励列表倒置
	local convert_list = {}
	if #auto_divination_list > 0 then
		for i = #auto_divination_list, 1, -1 do
			table.insert(convert_list, auto_divination_list[i])
		end
	end

	return convert_list
end

function LuckyDrawData:SetCurSelectedList(list)
	self.cur_select_list = list
end

function LuckyDrawData:GetCurSelectedList()
	return self.cur_select_list
end

function LuckyDrawData:IsEnoughGold()
	local need_pay_money = self:GetNeedPayMoney()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	return need_pay_money < vo.gold
end