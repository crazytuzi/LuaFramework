FestivalActivityData = FestivalActivityData or BaseClass(BaseEvent)

local ACTIVITY_STATUS = {
	CLOSE = 0,
	STANDY = 1,
	OPEN = 2,
}

FestivalActivityData.REMINDE_NAME_LIST = {
	[ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_ITEM_COLLECTION_2] = {remind_name = RemindName.MakeMoonAct},
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT] = {remind_name = RemindName.ExpenseNiceGiftRemind},
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE] = {remind_name = RemindName.ZhongQiuLianXuChongZhi},
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE] = {remind_name = RemindName.VesLeiChongRemind},
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2] = {remind_name = RemindName.ZhongQiuHappyErnieRemind},
	[FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_LANDINGF_REWARD] = {remind_name = RemindName.LoginRewardRemind},
}


--排序
local FESTVAL_ACTIVITY_SORT_INDEX_LIST = {
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LANDINGF_REWARD,
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CHONGZHI_RANK,
		ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_XIAOFEI_RANK,
		FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CRAZY_GIFT,
	}

function FestivalActivityData:__init()
	if nil ~= FestivalActivityData.Instance then
		return
	end

	FestivalActivityData.Instance = self

	local all_cfg = ConfigManager.Instance:GetAutoConfig("randactivityopencfg_auto")
	self.bg_cfg = ConfigManager.Instance:GetAutoConfig("festivalpanel_auto").bg_cfg

	self.chongzhi_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().chongzhi_rank_2
	self.xiaofei_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().consume_gold_rank_2

	self.toggle_list_info = ListToMap(all_cfg.version_open_cfg, "activity_type")

	self.equipment_info = {}

	self.active_open_list = {}
	self.active_open_list_id = {}
	self.active_open_cfg = {}

    self.info_zhongqiu = {}

    self.open_panel = false
	--初始化toggle名字列表
	self:InitRedPointRegister()

	self.chongzhi_num = 0
	self.xiaofei_num = 0
	self.chongzhi_rank = 0
	self.xiaofei_rank = 0

	self.can_fetch_reward_flag = nil
	self.has_fetch_reward_flag = nil
	-- self:SetActivityOpenList({activity_type = 2237, status = 2, param_1 = 0, param_2 = 10000000, next_status_switch_time = 500000})
	-- self:SetActivityOpenList({activity_type = 2238, status = 2, param_1 = 0, param_2 = 10000000, next_status_switch_time = 500000})

	self.force_close_act_t = {}
end

function FestivalActivityData:__delete()
	for k,v in pairs(FestivalActivityData.REMINDE_NAME_LIST) do
		RemindManager.Instance:UnRegister(v.remind_name)
	end

	RemindManager.Instance:UnRegister(RemindName.OpenFestivalPanel)
	FestivalActivityData.Instance = nil
end

function FestivalActivityData:InitRedPointRegister()
	RemindManager.Instance:Register(RemindName.MakeMoonAct, BindTool.Bind(self.IsShowMoonCakeRedPoint, self))
	RemindManager.Instance:Register(RemindName.ExpenseNiceGiftRemind, BindTool.Bind(self.IsShowExpenseNiceGiftRedPoint, self))
	RemindManager.Instance:Register(RemindName.VesLeiChongRemind, BindTool.Bind(self.IsShowVesLeiChongRedPoint, self))
	RemindManager.Instance:Register(RemindName.ZhongQiuLianXuChongZhi, BindTool.Bind(self.IsShowLianXuChongRedPoint, self))
	RemindManager.Instance:Register(RemindName.ZhongQiuHappyErnieRemind, BindTool.Bind(self.IsShowHappyErnieRemindRedPoint, self))
	RemindManager.Instance:Register(RemindName.OpenFestivalPanel, BindTool.Bind(self.OpenPanel, self))
	-- RemindManager.Instance:Register(RemindName.LoginRewardRemind, BindTool.Bind(self.LoginRewardRedPoint, self))
end


function FestivalActivityData:GetActivityOpenNum()
	local open_num = 0

	for k,v in pairs(self.active_open_list) do
		if v.status_type == ACTIVITY_STATUS.OPEN then
			open_num = open_num + 1
		end
	end

	return open_num
end

function FestivalActivityData:GetActivityOpenListByIndex(index)
	return self.active_open_list[index]
end

function FestivalActivityData:GetActivityOpenList()
	return self.active_open_list
end

function FestivalActivityData:GetFirstOpenActivity()
	for k,v in pairs(self.active_open_list) do
		if v.status_type == ACTIVITY_STATUS.OPEN then
			return v.act_id
		end
	end

	return 0
end

function FestivalActivityData:GetBgCfg()
	return self.bg_cfg[1]
end

--设置开启的活动信息
function FestivalActivityData:SetActivityOpenList(protocol)
	local id = protocol.activity_type
	local status = self:GetActivityStatus(id, protocol.status)
	local next_status_switch_time = protocol.next_status_switch_time

	local time = {start_time = protocol.param_1, end_time = protocol.param_2, next_time = next_status_switch_time}
	local client_sort = FestivalActivityData.GetActivitySort(id, status)


	local temp = {act_id = id, status_type = status, time_data = time, client_sort = client_sort}

	self.active_open_list_id[id] = time

	local is_exist = false

	for k,v in pairs(self.active_open_list) do
		if id == v.act_id then
			self.active_open_list[k] = temp
			is_exist = true
			break
		end
	end

	if not is_exist and status == ACTIVITY_STATUS.OPEN then
		table.insert(self.active_open_list, temp)
	end
	table.sort(self.active_open_list, SortTools.KeyUpperSorters("client_sort", "status_type"))
end

--获取排序参数
function FestivalActivityData.GetActivitySort(id, status)
	for i,v in ipairs(FESTVAL_ACTIVITY_SORT_INDEX_LIST) do
		if id == v and status == ACTIVITY_STATUS.OPEN then
			return 1000 - i
		end
	end
	return 0
end

--获取活动状态
function FestivalActivityData:GetActivityStatus(id, status)
	if self.force_close_act_t[id] then
		return ACTIVITY_STATUS.CLOSE
	end
	return status
end

--活动特色关闭
function FestivalActivityData:SetActivityStatusForce(id, is_close)
	self.force_close_act_t[id] =  is_close
	local info = ActivityData.Instance:GetActivityStatuByType(id)
	local status = info and info.status or ACTIVITY_STATUS.CLOSE
	for k,v in pairs(self.active_open_list) do
		if id == v.act_id then
			v.status_type = is_close and ACTIVITY_STATUS.CLOSE or status
			v.client_sort = FestivalActivityData.GetActivitySort(id, v.status_type)
			break
		end
	end
	table.sort(self.active_open_list, SortTools.KeyUpperSorters("client_sort", "status_type"))
end

function FestivalActivityData:GetActivityOpenCfgById(act_id)
	return self.toggle_list_info[act_id]
end

function FestivalActivityData:GetActivityActTimeLeftById(act_id)
	if nil == self.active_open_list_id[act_id] then
		return 0
	end

	local time = self.active_open_list_id[act_id].next_time
	local time_left = time - TimeCtrl.Instance:GetServerTime()
	if time_left < 0 then
		return 0
	end

	return time_left
end

function FestivalActivityData:GetActivityOpenListByActId(act_id)
	local info_list = {}
	if nil == self.active_open_list or nil == next(self.active_open_list) then
		return self.active_open_list
	end

	for k, v in pairs(self.active_open_list) do
		if v.act_id == act_id then
			info_list = v
		end
	end

	return info_list
end

function FestivalActivityData:OpenPanel()
	local num = 1
	if self.open_panel then
		num = 0
	end

	return num
end

function FestivalActivityData:SetIsOpenPanel(value)
	self.open_panel = value
end

function FestivalActivityData:GetActivityIsOpen(act_id)
	for k,v in pairs(self.active_open_list) do
		if v.act_id == act_id and v.status_type == ACTIVITY_STATUS.OPEN then
			return true
		end
	end
	return false
end
----------------------------以上为通用方法-------------------------------
----------------------------以下为每个活动独立操作按模块-------------------

--匠心月饼红点
function FestivalActivityData:IsShowMoonCakeRedPoint()
	local can_get = 0
	can_get = MakeMoonCakeData.Instance:IsShowMakeMoonCakeRedPoint()
	return can_get
end

function FestivalActivityData:GetHolidayCfg()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().special_img_suit_special_id_cfg[1] or {}

	return cfg
end

------------------------------ 变身榜、被变身榜 ------------------------------
function FestivalActivityData:SetSpecialAppearanceInfo(protocol)
	self.special_appearance_role_change_times = protocol.role_change_times
	self.special_appearance_rank_count = protocol.rank_count
	self.special_appearance_rank_list = protocol.rank_list

	if self.special_appearance_rank_count > 10 then
		self.special_appearance_rank_count = 10
	end

	table.sort(self.special_appearance_rank_list, function(a, b)
		return a.change_num > b.change_num
	end)
end

function FestivalActivityData:SetSpecialAppearancePassiveInfo(protocol)
	self.role_change_times = protocol.role_change_times
	self.rank_count = protocol.rank_count
	self.bei_bianshen_rank_list = protocol.rank_list

	if self.rank_count > 10 then
		self.rank_count = 10
	end

	table.sort(self.bei_bianshen_rank_list, function(a, b)
		return a.change_num > b.change_num
	end)
end

function FestivalActivityData:GetSpecialAppearanceRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_RANK)
	return cfg[1].special_appearance_rank_join_reward
end

function FestivalActivityData:GetSpecialAppearancePassiveRankJoinRewardCfg()
	local config = ServerActivityData.Instance:GetCurrentRandActivityConfig().other
	local cfg = ActivityData.Instance:GetRandActivityConfig(config, RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_SPECIAL_APPEARANCE_PASSIVE_RANK)
	return cfg[1].special_appearance_passive_rank_join_reward
end

function FestivalActivityData:GetSpecialAppearanceRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_rank
end

function FestivalActivityData:GetSpecialAppearancePassiveRankCfg()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig().special_appearance_passive_rank
end

function FestivalActivityData:GetSpecialAppearanceRoleChangeTimes()
	return self.special_appearance_role_change_times or 0
end

function FestivalActivityData:GetSpecialAppearancePassiveRoleChangeTimes()
	return self.role_change_times or 0
end

function FestivalActivityData:GetSpecialAppearanceRankCount()
	return self.special_appearance_rank_count or 0
end

function FestivalActivityData:GetSpecialAppearancePassiveRankCount()
	return self.rank_count or 0
end

function FestivalActivityData:GetSpecialAppearanceRankList()
	return self.special_appearance_rank_list or {}
end

function FestivalActivityData:GetSpecialAppearancePassiveRankList()
	return self.bei_bianshen_rank_list or {}
end

function FestivalActivityData:GetMySpecialAppearanceRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == self.special_appearance_rank_list then
		return 0
	end
	for i,v in ipairs(self.special_appearance_rank_list) do
		if main_role_vo.role_id == v.uid then
			return i
		end
	end
	return -1
end

function FestivalActivityData:GetMySpecialAppearancePassiveRank()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == self.bei_bianshen_rank_list then
		return 0
	end
	for i,v in ipairs(self.bei_bianshen_rank_list) do
		if main_role_vo.role_id == v.uid then
			return i
		end
	end
	return -1
end


--------------中秋连续充值----------

function FestivalActivityData:ZhongQiuLianXuChongZhiCfg()
	local temp_table = {}
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	local today = self:ZhongQiuLianXuChongZhiDay()
	if cfg == nil then
		return nil
	end

 	if ServerActivityData.Instance then
 		for k, v in pairs(cfg.versions_continuous_charge) do
 			if v.open_server_day == today then
 				table.insert(temp_table, v)
 			end
 		end
 	end

    return temp_table
end

function FestivalActivityData:ZhongQiuLianXuChongZhiDay()
	local openday = TimeCtrl.Instance:GetCurOpenServerDay()
	local cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig()
	if cfg == nil then
       return 0
	end

	for k, v in pairs(cfg.versions_continuous_charge) do
		if v.open_server_day and openday <= v.open_server_day then
			return v.open_server_day
		end
	end

	return 0
end

function FestivalActivityData:SetChongZhiZhongQiu(protocol)
	self.info_zhongqiu = protocol

	if nil ~= protocol.has_fetch_reward_flag then
		self.has_fetch_reward_flag = bit:d2b(protocol.has_fetch_reward_flag)
	end

	if nil ~= protocol.can_fetch_reward_flag then
		self.can_fetch_reward_flag = bit:d2b(protocol.can_fetch_reward_flag)
	end
end

function FestivalActivityData:GetChongZhiZhongQiu()
	return self.info_zhongqiu
end

function FestivalActivityData:GetHasFetchRewardFlagByIndex(index)
	return self.has_fetch_reward_flag[32 - index] or 0
end

function FestivalActivityData:GetCanFetchRewardFlagByIndex(index)
	return self.can_fetch_reward_flag[32 - index] or 0
end

------------------------------------------------------
------------------消费好礼----------------------------
------------------------------------------------------

function FestivalActivityData:GetRandActivityOtherCfg()
	if not self.other_cfg then
		self.other_cfg = ConfigManager.Instance:GetAutoConfig("randactivityconfig_1_auto").other_default_table
	end
	return self.other_cfg
end

function FestivalActivityData:GetExpenseNiceGiftTotalRwardCfg()
	if not self.expense_nice_gift_grand_total_reward_cfg then
		self.expense_nice_gift_grand_total_reward_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().expense_nice_gift_grand_total_reward
	end

	return self.expense_nice_gift_grand_total_reward_cfg
end

function FestivalActivityData:GetExpenseNiceGiftTotalRwardCfgLength()
	local cfg = self:GetExpenseNiceGiftTotalRwardCfg()

	if cfg then
		if not self.total_reward_cfg_length then
			self.total_reward_cfg_length = #cfg
		end

		return self.total_reward_cfg_length
	end

	return 0
end

function FestivalActivityData:GetTotalRwardCfg()
	local length = self:GetExpenseNiceGiftTotalRwardCfgLength()
	local cfg = self:GetExpenseNiceGiftTotalRwardCfg()
	local list = {}
	local fetch_list = {}
	local num1 = 0
	local num2 = 0

	if not cfg then return nil end

	if not self:GetExpenseNiceGiftInfo() then
		return cfg
	end

	for i = 1, length do
		local flag = self:ExpenseInfoRewardHasFetchFlagByIndex(i)
		if cfg[i] then
			if flag == 0 then
				num1 = num1 + 1
				list[num1] = cfg[i]
			else
				num2 = num2 + 1
				fetch_list[num2] = cfg[i]
			end
		end
	end

	if num2 > 0 then
		for i = 1, num2 do
			list[i + num1] = fetch_list[i]
		end
	end

	self.sorted_total_reward_cfg = list

	return self.sorted_total_reward_cfg
end

function FestivalActivityData:GetSortedTotalRewardCfg()
	return self.sorted_total_reward_cfg
end

function FestivalActivityData:GetExpenseNiceGiftCfg()
	if not self.expense_nice_gift_cfg then
		self.expense_nice_gift_cfg = ServerActivityData.Instance:GetCurrentRandActivityConfig().expense_nice_gift
	end

	return self.expense_nice_gift_cfg
end

function FestivalActivityData:GetExpenseNiceGiftCfgLength()
	if not self.expense_nice_gift_cfg_length then
		local cfg = self:GetExpenseNiceGiftCfg()
		self.expense_nice_gift_cfg_length = #cfg
	end

	return self.expense_nice_gift_cfg_length
end

function FestivalActivityData:GetExpenseNiceGiftPageCount()
	if self.expense_nice_gift_page_count then
		return self.expense_nice_gift_page_count
	end

	local cfg = self:GetExpenseNiceGiftCfg()

	if cfg then
		local count = self:GetExpenseNiceGiftCfgLength()

		if count > 0 then
			local remainder = math.floor((count % 9))
			local divider = math.floor((count / 9))
			num = remainder == 0 and divider or (1 + divider)
			self.expense_nice_gift_page_count = num

			return self.expense_nice_gift_page_count
		end
	end

	return 0
end

function FestivalActivityData:GetExpenseNiceGiftPageCfgByIndex(index)
	if not index or index < 0 then
		return nil
	end

	if not self.expense_nice_gift_page_cfg then
		self.expense_nice_gift_page_cfg = {}
	end

	if self.expense_nice_gift_page_cfg[index] then
		return self.expense_nice_gift_page_cfg[index]
	end

	local num = self:GetExpenseNiceGiftPageCount() or 0
	local cfg = self:GetExpenseNiceGiftCfg()
	local list = {}

	if num > 0 then
		local count = 0
		local max_range = index * 9
		local min_range = (max_range - 8) > 0 and (max_range - 8) or 1

		for i = min_range, max_range do
			if cfg[i] then
				table.insert(list, cfg[i])
				count = count + 1
			end
		end

		if count > 0 then
			self.expense_nice_gift_page_cfg[index] = list
			return self.expense_nice_gift_page_cfg[index]
		end
	end

	return nil
end

function FestivalActivityData:SetExpenseNiceGiftInfo(protocol)
	if not protocol then
		return
	end

	if not self.expense_nice_gift_info then
		self.expense_nice_gift_info = {}
	end

	self.expense_nice_gift_info.grand_total_consume_gold_num = protocol.grand_total_consume_gold_num
	self.expense_nice_gift_info.yao_jiang_num = protocol.yao_jiang_num
	self.expense_nice_gift_info.reward_has_fetch_flag = bit:d2b(protocol.reward_has_fetch_flag)
	self.expense_nice_gift_info.reward_can_fetch_flag = bit:d2b(protocol.reward_can_fetch_flag)
	self.expense_nice_gift_info.yaojiang_total_times = protocol.yaojiang_total_times
end

function FestivalActivityData:GetRemaingLotteryTimes()
	return self.expense_nice_gift_info.yaojiang_total_times or 0
end

function FestivalActivityData:GetExpenseNiceGiftInfo()
	return self.expense_nice_gift_info
end

function FestivalActivityData:ExpenseInfoRewardHasFetchFlagByIndex(index)
	if not index then
		return 0
	end

	local info = self:GetExpenseNiceGiftInfo()

	if info and info.reward_has_fetch_flag then
		return info.reward_has_fetch_flag[32 - index + 1]
	end

	return 0
end

function FestivalActivityData:ExpenseInfoRewardCanFetchFlagByIndex(index)
	if not index then
		return 0
	end

	local info = self:GetExpenseNiceGiftInfo()

	if info and info.reward_can_fetch_flag then
		return info.reward_can_fetch_flag[32 - index + 1]
	end

	return 0
end

function FestivalActivityData:SetExpenseNiceGiftResultInfo(protocol)
	if not protocol then
		return
	end

	if not self.expense_nice_gift_result_info then
		self.expense_nice_gift_result_info = {}
	end

	self.expense_nice_gift_result_info.reward_item_id = protocol.reward_item_id
	self.expense_nice_gift_result_info.reward_item_num = protocol.reward_item_num
end

function FestivalActivityData:GetExpenseNiceGiftResultInfo()
	return self.expense_nice_gift_result_info
end

function FestivalActivityData:IsShowExpenseNiceGiftRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_EXPENSE_NICE_GIFT) then
		return 0
	end

	local flag = 0
	local length = self:GetExpenseNiceGiftTotalRwardCfgLength()
	local info = self:GetExpenseNiceGiftInfo()

	if info and info.yao_jiang_num then
		flag = (info.yao_jiang_num > 0) and 1 or 0
	end

	for i = 1, length do
		local can_fetch = self:ExpenseInfoRewardCanFetchFlagByIndex(i)
		local has_fetch = self:ExpenseInfoRewardHasFetchFlagByIndex(i)
		if can_fetch == 1 and has_fetch == 0 then
			flag = 1
			break
		end
	end

	return flag
end

--累计充值红点
function FestivalActivityData:IsShowVesLeiChongRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_GRAND_TOTAL_CHARGE) then
		return 0
	end

	local cfg = FestivalLeiChongData.Instance:GetVesTotalChargeCfg()
	local charge_value = FestivalLeiChongData.Instance:GetChargeValue()

	for k, v in pairs(cfg) do
		local has_fetch = FestivalLeiChongData.Instance:GetFetchFlag(v.seq)
		if charge_value >= v.need_chognzhi and has_fetch == 0 then
			return 1
		end
	end

	return 0
end

-----连续充值红点
function FestivalActivityData:IsShowLianXuChongRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_VERSIONS_CONTINUE_CHARGE)
		then return 0
	end

    local reward_info = self:GetChongZhiZhongQiu()
    if nil == reward_info or next(reward_info) == nil then
		return 0
	end

    if self:ZhongQiuLianXuChongZhiCfg() == nil then
    	return 0
    end

    for i = 1, #self:ZhongQiuLianXuChongZhiCfg() do
		if self.can_fetch_reward_flag[32 - i] == 1 then
			if self.has_fetch_reward_flag[32 - i] == 0 then  --未领取
                return 1
			end
		end
	end

	return 0
end

-----祈福红点
function FestivalActivityData:IsShowHappyErnieRemindRedPoint()
	if not ActivityData.Instance:GetActivityIsOpen(FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_HUANLE_YAOJIANG2)
		then return 0
	end

	local next_free_tao_timestamp = AutumnHappyErnieData.Instance:GetNextFreeTaoTimestamp()
	local cfg = AutumnHappyErnieData.Instance:GetHappyErnieRewardItemConfig()

	for i = 1, #cfg do
		local is_got = AutumnHappyErnieData.Instance:GetIsFetchFlag(i - 1) --已经领取
		local can_get_times = AutumnHappyErnieData.Instance:GetCanFetchFlagByIndex(i - 1) --获取物品所需次数
		local draw_times = AutumnHappyErnieData.Instance:GetChouTimes()  --已经抽奖次数
		if not is_got and  draw_times >= can_get_times then
			return 1
		end
	end

	if next_free_tao_timestamp == 0 then
        return 0
	else
		local server_time = TimeCtrl.Instance:GetServerTime()
		if server_time - next_free_tao_timestamp >= 0 then
			self:CancelBoxTimer()
			return 1
		else
		    if self.box_remind_timer == nil then
		    	local time_tab = server_time - next_free_tao_timestamp
			    self.box_remind_timer = CountDown.Instance:AddCountDown(time_tab, 1, function ()
        		time_tab = time_tab - 1
        			if time_tab >= 0 then
  	  					RemindManager.Instance:Fire(RemindName.ZhongQiuHappyErnieRemind)
  	  				end
   			    end)
			end
		end
	end

	return 0
end

function FestivalActivityData:CancelBoxTimer()
	if self.box_remind_timer then
		GlobalTimerQuest:CancelQuest(self.box_remind_timer)
		self.box_remind_timer = nil
	end
end


-- 中秋套装获取配置
function FestivalActivityData:GetEquipmentCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("dressing_room_auto").suit_attr or {}

	return cfg
end

function FestivalActivityData:GetEquipmentInfo()
	local cfg = self:GetEquipmentCfg()

	for k, v in pairs(cfg) do
		if v.suit_index == 0 and v.img_count_min == 5 then
			self.equipment_info = v
		end
	end

	return self.equipment_info
end

function FestivalActivityData:SendChongZhiRankInfo(protocol)
	self.chongzhi_num = protocol.chongzhi_num
end

function FestivalActivityData:GetChongZhiRankInfo()
	return self.chongzhi_num
end

function FestivalActivityData:SendXiaoFeiRankInfo(protocol)
	self.xiaofei_num = protocol.consume_gold_num
end

function FestivalActivityData:GetXiaoFeiRankInfo()
	return self.xiaofei_num
end

function FestivalActivityData:SendChongZhiRank(info)
	if nil == info or nil == next(info) then
		return
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k, v in pairs(info) do
		if role_id == v.user_id then
			self.chongzhi_rank = k
		end
	end
end

function FestivalActivityData:GetChongZhiRank()
	return self.chongzhi_rank
end

function FestivalActivityData:SendXiaoFeiRank(info)
	if nil == info or nil == next(info) then
		return
	end

	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	for k, v in pairs(info) do
		if role_id == v.user_id then
			self.xiaofei_rank = k
		end
	end
end

function FestivalActivityData:GetXiaoFeiRank()
	return self.xiaofei_rank
end

function FestivalActivityData:GetChongZhiRewardCfg()
	return ActivityData.Instance:GetRandActivityConfig(self.chongzhi_cfg, FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_CHONGZHI_RANK)
end

function FestivalActivityData:GetXiaoFeiRewardCfg()
	return ActivityData.Instance:GetRandActivityConfig(self.xiaofei_cfg, FESTIVAL_ACTIVITY_ID.RAND_ACTIVITY_TYPE_XIAOFEI_RANK)
end
---------------------后面添加需要新建文件夹，禁止直接在这个data添加-----------------------------
--------------DATA新建文件夹放进去-------------