RareDialData = RareDialData or BaseClass()

function RareDialData:__init()
    if RareDialData.Instance then
        print_error("[RareDialData] Attempt to create singleton twice!")
        return
    end
    RareDialData.Instance = self

    self.select_seq = -1
    self.select_id_t = {}
end

function RareDialData:__delete(  )
	self.next_flush_timestamp = nil
    self.free_draw_times = nil
    self.cur_turn_times = nil
    self.cur_turn_times_gold = nil
    self.total_times = nil

    if self.cur_item_info_list then
    	for k,v in pairs(self.cur_item_info_list) do
    		v = nil
    	end
    end
    self.cur_item_info_list = nil

    self.single_item_info = nil

    RareDialData.Instance = nil
end

-------------------获取数据----------------
function RareDialData:GetDrawData()
    return ServerActivityData.Instance:GetCurrentRandActivityConfig().extreme_lucky_draw_consume
end

function RareDialData:GetDrawReturnData()
    return ServerActivityData.Instance:GetCurrentRandActivityConfig().extreme_lucky_return_reward
end

function RareDialData:GetDrawRewardData()
    return ServerActivityData.Instance:GetCurrentRandActivityConfig().extreme_lucky_draw
end

function RareDialData:GetDrawSpend(times)
    local data = self:GetDrawData()
    for k, v in pairs(data) do
        if v.draw_time == times + 1 then
            return v.draw_consume
        end
    end
    return data[#data].draw_consume
end

-- 内部使用 外部请勿调用
function RareDialData:GetDrawDataByOpenDay(open_day)
    local data = self:GetDrawRewardData()
    -- local data_range = GetDataRange(data, "opengame_day")
    local day_range = ActivityData.Instance:GetRandActivityConfig(data,ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR)
    -- print_error(day_range)
    -- local draw_reward_data = {}
    -- for i, v in ipairs(data_range) do
    --     if open_day <= v then
    --         day_range = v
    --         break
    --     end
    -- end
    -- for k, v in pairs(data) do
    --     if v.opengame_day == day_range then
    --         table.insert(draw_reward_data, v)
    --     end
    -- end
    return day_range
end

function RareDialData:GetDrawDataRareByOpenDay(open_day)
    local data = self:GetDrawDataByOpenDay(open_day)
    local rare_data = {}
    for k, v in pairs(data) do
        if v.is_rare == 1 then
            table.insert(rare_data, v)
        end
    end
    return rare_data
end


function RareDialData:GetDrawReturnDataByOpenDay(open_day)
    local data = self:GetDrawReturnData()
    local data_range = ActivityData.Instance:GetRandActivityConfig(data,ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR)
    -- local return_data = {}
    -- local day_range = data[1].opengame_day
    -- for k, v in pairs(data_range) do
    --     if open_day <= v then
    --         day_range = v
    --         break
    --     end
    -- end
    -- for k, v in pairs(data) do
    --     if v.opengame_day == day_range then
    --         table.insert(return_data, v)
    --     end
    -- end
    return data_range
end


function RareDialData:GetDrawDataMaxNumber()
    local data = self:GetDrawData()
    return data[#data].draw_time
end

function RareDialData:GetFlushSpend()
    local data = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
    return data[1].extreme_lucky_flush_consume
end

function RareDialData:SetRAExtremeLuckyAllInfo(protocol)
    local quick_flush_state = RareDialCtrl.Instance:QuickFlushState()
	if self.total_times and self.total_times == protocol.total_times and not quick_flush_state then
		RareDialCtrl.Instance:FlushItem()
	end
    self.next_flush_timestamp = protocol.next_flush_timestamp
    self.free_draw_times = protocol.free_draw_times
    self.cur_turn_times = protocol.lottery_times
    self.cur_turn_times_gold = protocol.lottery_times_gold
    self.total_times = protocol.total_times
    self.return_reward_flag = protocol.return_reward_flag
    ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR,self:IsShowRedPoint())
    self.cur_item_info_list = {}
    for i = 1, GameEnum.RA_EXTREME_LUCKY_REWARD_COUNT do
        self.cur_item_info_list[i] = {}
        self.cur_item_info_list[i].seq = protocol.cur_item_info_list[i].seq
        self.cur_item_info_list[i].invalid = protocol.cur_item_info_list[i].invalid
        self.cur_item_info_list[i].has_fetch = protocol.cur_item_info_list[i].has_fetch
        self.cur_item_info_list[i].weight = protocol.cur_item_info_list[i].weight
    end
end

function RareDialData:SetRewardInfo(protocol)
    self.cur_turn_times = protocol.single_lottery_times
    self.cur_turn_times_gold = protocol.single_lottery_times_gold
    self.total_times = protocol.total_times
    self.free_draw_times = protocol.single_free_draw_times
    self.return_reward_flag = protocol.return_reward_flag
    self.single_item_info = {}
    self.single_item_info.seq = protocol.single_item_info.seq
    self.single_item_info.invalid = protocol.single_item_info.invalid
    self.single_item_info.has_fetch = protocol.single_item_info.has_fetch
    self.single_item_info.weight = protocol.single_item_info.weight
    ActivityData.Instance:SetActivityRedPointState(ACTIVITY_TYPE.RAND_ACTIVITY_SUPER_LUCKY_STAR,self:IsShowRedPoint())
    for k, v in pairs(self.cur_item_info_list) do
        if v.seq == self.single_item_info.seq then
            v.has_fetch = self.single_item_info.has_fetch
        end
    end
end

function RareDialData:GetRewardBySeq(seq)
    local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
    local data = self:GetDrawDataByOpenDay(open_day)
    for k, v in pairs(data) do
        if v.seq == seq then
            return v
        end
    end
end

function RareDialData:GetItemInfoList()
    return self.cur_item_info_list or nil
end

function RareDialData:GetToTalTimes()
    return self.total_times or 0
end

function RareDialData:GetNextTime()
    return self.next_flush_timestamp or 0
end

function RareDialData:GetResultIndex()
    for k, v in pairs(self.cur_item_info_list) do
        if v.seq == self.single_item_info.seq then
            return k
        end
    end
    return 0
end

function RareDialData:GetCurrentTimes()
    return self.cur_turn_times or 0
end

function RareDialData:GetFreeTimes()
    local data = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
    return data[1].extreme_lucky_free_draw_times - ( self.free_draw_times or 0 )
end

function RareDialData:GetGoldTimes()
	return self.cur_turn_times_gold or 0
end

function RareDialData:GetFetchInfo(index)
    local data = bit:d2b(self.return_reward_flag or 0)
    return data[32 - index] or 0
end

function RareDialData:IsShowRedPoint()
    local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
    local return_data = self:GetDrawReturnDataByOpenDay(open_day)
    local has_reward = false
    for k,v in pairs(return_data) do
        if (self:GetToTalTimes() >= v.draw_times) and (self:GetFetchInfo(v.seq) ~= 1) then
            has_reward = true
            break
        end
    end
    return self:GetFreeTimes() > 0 or has_reward
end

function RareDialData:SendSelectId(index)
    self.select_seq = index or -1
end

function RareDialData:IsCanSelectItem()
    local cfg = self:GetItemInfoList()
    local need_money = self:GetFlushSpend()
    local role_info = GameVoManager.Instance:GetMainRoleVo()

    if nil == cfg or nil == need_money then
        return false
    elseif role_info.gold < need_money then
        GlobalTimerQuest:AddDelayTimer(function ()
            TipsCtrl.Instance:ShowLackDiamondView()
        end, 0.5)

        return false
    end

    for k, v in pairs(cfg) do
        if self.select_id_t[v.seq] then
            return false
        end
    end

    return true
end

function RareDialData:GetSelectId()
    return self.select_seq
end


function RareDialData:InsertSelectId(id)
    self.select_id_t[id] = true
end

function RareDialData:RemoveSelectId(id)
    self.select_id_t[id] = nil
end

function RareDialData:GetSelectIdTable()
    return self.select_id_t
end

function RareDialData:IsHasSelectId()
    return nil ~= next(self.select_id_t)
end

function RareDialData:ClearSelectIdTable()
    self.select_id_t = {}
end