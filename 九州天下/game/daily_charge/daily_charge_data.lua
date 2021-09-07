CHONG_ZHI_STATE =
{
	NEED_TOTAL_CHONGZHI_10 = 60,
	NEED_TOTAL_CHONGZHI_99 = 300,
}
DailyChargeData = DailyChargeData or BaseClass()

DailyChargeData.hasOpenDailyRecharge = false
DailyChargeData.hasOpenFirstRecharge = false

function DailyChargeData:__init()
	if DailyChargeData.Instance then
		print_error("[DailyChargeData] Attemp to create a singleton twice !")
	end
	DailyChargeData.Instance = self
	self.chongzhi_info = {}
	RemindManager.Instance:Register(RemindName.DailyCharge, BindTool.Bind(self.GetDailyChargeRemind, self))
	RemindManager.Instance:Register(RemindName.FirstCharge, BindTool.Bind(self.GetFirstChargeRemind, self , 1))
	-- RemindManager.Instance:Register(RemindName.DailyLeiJi, BindTool.Bind(self.GetDailyChargeRemind, self))
	RemindManager.Instance:Register(RemindName.SecondCharge, BindTool.Bind2(self.GetFirstChargeRemind, self, 2))
	RemindManager.Instance:Register(RemindName.ThirdCharge, BindTool.Bind2(self.GetFirstChargeRemind, self, 3))
	
	-- self.daily_chongzhi_need = ListToMap(self:GetDailyChongzhiRewardAuto(), "need_total_chongzhi")
	self.reward_cfg = {}
	self.day = -1
	self.push_show_index = 1
	self.is_first = true
	self.chongzhi_num = 0
	self.fetch_flag = {}
end

function DailyChargeData:__delete()
	RemindManager.Instance:UnRegister(RemindName.DailyCharge)
	RemindManager.Instance:UnRegister(RemindName.FirstCharge)
	-- RemindManager.Instance:UnRegister(RemindName.DailyLeiJi)
	RemindManager.Instance:UnRegister(RemindName.SecondCharge)
	RemindManager.Instance:UnRegister(RemindName.ThirdCharge)


	DailyChargeData.Instance = nil
end

function DailyChargeData:OnSCChongZhiInfo(protocol)
	self.chongzhi_info.first_chongzhi_fetch_reward_flag_list = bit:d2b(protocol.first_chongzhi_fetch_reward_flag)	--首充奖励领取标记
	self.chongzhi_info.daily_chongzhi_fetch_reward_flag_list = bit:d2b(protocol.daily_chongzhi_fetch_reward_flag)	--每日首充奖励领取标记
	self.chongzhi_info.daily_chongzhi_complete_days = protocol.daily_chongzhi_complete_days							--每日首充完成天数
	self.chongzhi_info.daily_chongzhi_times_fetch_reward_flag_list = bit:d2b(protocol.daily_chongzhi_times_fetch_reward_flag)--每日首充累计天数奖励标记
	self.chongzhi_info.history_recharge = protocol.history_recharge
	self.chongzhi_info.history_recharge_count = protocol.history_recharge_count
	self.chongzhi_info.today_recharge = protocol.today_recharge
	self.chongzhi_info.reward_flag = protocol.reward_flag
	self.chongzhi_info.reward_flag_list = bit:d2b(protocol.reward_flag)  --每个档位是否充值标记
	self.chongzhi_info.special_first_chongzhi_timestamp = protocol.special_first_chongzhi_timestamp			--特殊首冲开始时间戳
	self.chongzhi_info.is_daily_first_chongzhi_open = protocol.is_daily_first_chongzhi_open					--每日首冲是否开启
	self.chongzhi_info.is_daily_first_chongzhi_fetch_reward = protocol.is_daily_first_chongzhi_fetch_reward	--每日充值奖励是否已经领取
	self.chongzhi_info.daily_total_chongzhi_fetch_reward_flag = protocol.daily_total_chongzhi_fetch_reward_flag	--每日累计充值奖励领取标记
	self.chongzhi_info.daily_total_chongzhi_stage = protocol.daily_total_chongzhi_stage						--累计充值当前阶段
	self.chongzhi_info.daily_first_chongzhi_times = protocol.daily_first_chongzhi_times       				--每日首冲累计次数（满7次有额外奖励）
	self.chongzhi_info.special_first_chongzhi_fetch_reward_flag = protocol.special_first_chongzhi_fetch_reward_flag   	--特殊首冲领取标志
	self.chongzhi_info.zai_chongzhi_fetch_reward_flag = protocol.zai_chongzhi_fetch_reward_flag					--0未充值.1可领取.2已领取
	self.chongzhi_info.daily_total_chongzhi_stage_chongzhi = protocol.daily_total_chongzhi_stage_chongzhi
	self.chongzhi_info.third_chongzhi_reward_flag = protocol.third_chongzhi_reward_flag						--第三次充值状态（0 未充值，1 可领取，2 已领取）
	self.chongzhi_info.diff_weekday_chongzhi_is_open = protocol.diff_weekday_chongzhi_is_open					--每日累充是否开启(星期几相关)
	self.chongzhi_info.diff_weekday_chongzhi_stage_fetch_flag = protocol.diff_weekday_chongzhi_stage_fetch_flag		--每日累充阶级奖励领取标记(星期几相关)
	self.chongzhi_info.diff_wd_chongzhi_value = protocol.diff_wd_chongzhi_value						--每日累充额度(星期几相关)
	self.chongzhi_info.daily_chongzhi_fetch_reward2_flag = bit:d2b(protocol.daily_chongzhi_fetch_reward2_flag)			--每日累计充值奖励2领取标记
	self.chongzhi_info.first_chongzhi_active_reward_flag = bit:d2b(protocol.first_chongzhi_active_reward_flag)			-- 首冲奖励激活标记
	self.leiji_daily_get_flag = protocol.daily_chongzhi_fetch_reward2_flag
	self.chongzhi_info.daily_chongzhi_value = protocol.daily_chongzhi_value												-- 每日首充金额
	MainUICtrl.Instance.view:FlushChargeIcon()
	RemindManager.Instance:Fire(RemindName.FirstCharge)
	RemindManager.Instance:Fire(RemindName.SecondCharge)
	RemindManager.Instance:Fire(RemindName.ThirdCharge)
	RemindManager.Instance:Fire(RemindName.DailyCharge)
	RemindManager.Instance:Fire(RemindName.RemindGroupBuyRedpoint)
	RemindManager.Instance:Fire(RemindName.ThanksFeedBackRedPoint)
	
end

function DailyChargeData:GetFristChargeRewardFlag(index)
	return self.chongzhi_info.reward_flag_list[32 - index]
end

function DailyChargeData:GetDailyChongzhiFetchRewardFlag()
	if self.chongzhi_info.special_first_chongzhi_fetch_reward_flag == 0 then
		return false
	end
	return true
end

function DailyChargeData:GetThreeRechargeOpen(index)
	if IS_AUDIT_VERSION then
		return false
	end

	local fetch_list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag
	if fetch_list == nil then
		return true
	end

	if index <= 0 or index > 3 then
		return false
	end
	if 1 == index then
		return 1 == active_list[33 - index] and 0 == fetch_list[33 - index]
	end

	for i = 1, 3 do
		if i < index and 0 == active_list[33 - i] then
			return false
		end
	end

	return 0 == fetch_list[33 - index]
end

function DailyChargeData:GetIsThreeRecharge()
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag or {}
	return active_list[30] == 1
end

function DailyChargeData:GetWingResId(item_id)
	local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	for k,v in pairs(wing_cfg) do
		if v.item_id == item_id then
			return v.res_id
		end
	end
end

function DailyChargeData:GetMountResId(item_id)
	local mount_cfg = ConfigManager.Instance:GetAutoConfig("mount_auto").special_img
	for k,v in pairs(mount_cfg) do
		if v.item_id == item_id then
			return v.res_id
		end
	end
end

function DailyChargeData:GetISWingByResId(res_id)
	local wing_cfg = ConfigManager.Instance:GetAutoConfig("wing_auto").special_img
	for k,v in pairs(wing_cfg) do
		if v.res_id == res_id then
			return true
		end
	end
	return false
end

function DailyChargeData:SetShowPushIndex(index)
	self.push_show_index = index
end

function DailyChargeData:GetShowPushIndex()
	return self.push_show_index
end

function DailyChargeData:GetDailyChongzhiSeq(seq)
	if nil == self.daily_chongzhi_seq then
		self.daily_chongzhi_seq = ListToMap(self:GetDailyChongzhiTimesRewardAuto(), "seq")
	end
	return self.daily_chongzhi_seq[seq] or {}
end

function DailyChargeData:GetDailyChongzhiDayIndex(day_index)
	if nil == self.daily_chongzhi_day_index then
		self.daily_chongzhi_day_index = ListToMapList(self:GetHuikuiRewardAuto(), "day_index")
	end
	return self.daily_chongzhi_day_index[day_index] or {}
end

function DailyChargeData:GetDailyChongzhiHuiKui(opengame_day, day_index, seq)
	if nil == self.daily_chongzhi_dahuikui then
		self.daily_chongzhi_dahuikui = ListToMap(self:GetChongZhiDaHuiKuiAuto(), "opengame_day", "day_index", "seq")
	end
	return self.daily_chongzhi_dahuikui[opengame_day][day_index][seq] or {}
end

function DailyChargeData:GetMinRecharge()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.reward[0].chongzhi or 60
end

function DailyChargeData:GetRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.reward
end

function DailyChargeData:GetSpecialChongzhiRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.special_chongzhi_reward
end

function DailyChargeData:GetOtherAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.other
end

function DailyChargeData:GetDailyTotalChongzhiRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.daily_total_chongzhi_reward
end

function DailyChargeData:GetDailyTotalChongzhiStageAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.daily_total_chongzhi_stage
end

function DailyChargeData:GetTotalChongzhiWantMoneyAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.total_chongzhi_want_money
end

function DailyChargeData:GetWeekdayTotalChongzhiAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.weekday_total_chongzhi
end

function DailyChargeData:GetTotalChongZhiJiu()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	local need_chongzhi_99 = chongzhi_cfg.daily_chongzhi_reward[2].need_total_chongzhi
	return need_chongzhi_99 or CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99
end

function DailyChargeData:GetTotalChongZhiYi()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	local need_chongzhi_10 = chongzhi_cfg.daily_chongzhi_reward[1].need_total_chongzhi
	return need_chongzhi_10 or CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10
end

function DailyChargeData:GetDailyChongzhiRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	local daily_chongzhi_reward = {}
	local level = PlayerData.Instance.role_vo.level
	for i,v in ipairs(chongzhi_cfg.daily_chongzhi_reward) do
		if level >= v.min_level and level <= v.max_level then
			table.insert(daily_chongzhi_reward, v)
		end
	end
	return daily_chongzhi_reward
end

function DailyChargeData:GetThreechargeNeedRecharge(seq)
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.first_chongzhi_reward[seq].need_danbi_chongzhi
end

function DailyChargeData:GetThreeRechargeAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.first_chongzhi_reward
end

--获得三充相应金额充值配置信息
function DailyChargeData:GetThreeChongZhiReward(need_chongzhi)
	local list = self:GetThreeRechargeAuto()
	local new_list = {}
	for k,v in pairs(list) do
		if need_chongzhi == v.need_danbi_chongzhi then
			return v
		end
	end
	return list[1]
end

function DailyChargeData:GetThreeRechargeFlag(index)
	if self.chongzhi_info then
		local fetch_list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
		local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag or {}
		if fetch_list ~= nil and active_list ~= nil then
			return active_list[32 - index + 1], fetch_list[32 - index + 1]
		end
	end	
end

function DailyChargeData:GetThreeRechargeReward()
	local chongzhi_state = self:GetThreechargeNeedRecharge(self.push_show_index)
	local gifts_info = DailyChargeData.Instance:GetThreeChongZhiReward(chongzhi_state).first_reward_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	local index = 1
	for i=1,8 do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(gifts_cfg["item_"..i.."_id"])
		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		local flag = true
		if nil ~= item_cfg then
			if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				flag = false
			end
		end

		if flag and gifts_cfg["item_"..i.."_id"] ~= 0 then
			item_data_list[index] = {}
			item_data_list[index].item_id = gifts_cfg["item_"..i.."_id"]
			item_data_list[index].num = gifts_cfg["item_"..i.."_num"]
			item_data_list[index].is_bind = gifts_cfg["is_bind_"..i]
			index = index + 1
		end
	end
	return item_data_list
end

function DailyChargeData:GetDailyChongzhiTimesRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.daily_chongzhi_times_reward
end

function DailyChargeData:GetDailyFirstChongzhiTimesRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.daily_fisrt_chongzhi_reward
end

function DailyChargeData:GetDailyLeiJiRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.daily_chongzhi_reward2
end

function DailyChargeData:GetHuikuiRewardAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.chongzhidahuikui
end

function DailyChargeData:GetChongZhiDaHuiKuiAuto()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	return chongzhi_cfg.chongzhidahuikui_2
end


function DailyChargeData:GetChongZhiInfo()
	return self.chongzhi_info
end

function DailyChargeData:GetFirstRewardByWeek()
	local week_num = os.date("%w",os.time())
	local cfg = self:GetDailyFirstChongzhiTimesRewardAuto()
	return cfg[week_num] or cfg[0]
end

--获得相应金额充值配置信息
function DailyChargeData:GetChongZhiReward(need_chongzhi)
	local list = self:GetDailyChongzhiRewardAuto()
	for k,v in pairs(list) do
		if need_chongzhi == v.need_total_chongzhi then
			return v
		end
	end
	return list[1]

 	-- 	local result_cfg = self.daily_chongzhi_need[need_chongzhi]
 	-- 	if result_cfg then
 	-- 		print_error(result_cfg)
	--  	return result_cfg
	--  end
	--  return self.daily_chongzhi_need[1]
end

function DailyChargeData:GetDailyGiftInfoList(chongzhi_state)
	local gifts_info = self:GetChongZhiReward(chongzhi_state).reward_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	for i=1,8 do
		item_data_list[i] = {}
		item_data_list[i].item_id = gifts_cfg["item_"..i.."_id"]
		item_data_list[i].num = gifts_cfg["item_"..i.."_num"]
		item_data_list[i].is_bind = gifts_cfg["is_bind_"..i]
	end
	return item_data_list
end

function DailyChargeData:GetFirstGiftInfoList(chongzhi_state)
	local gifts_info = DailyChargeData.Instance:GetChongZhiReward(chongzhi_state).first_reward_item
	local gifts_cfg = ItemData.Instance:GetItemConfig(gifts_info.item_id)
	local item_data_list = {}
	local index = 1
	for i=1,8 do
		local item_cfg, big_type = ItemData.Instance:GetItemConfig(gifts_cfg["item_"..i.."_id"])
		local gamevo = GameVoManager.Instance:GetMainRoleVo()
		local flag = true
		if nil ~= item_cfg then
			if gamevo.prof ~= item_cfg.limit_prof and item_cfg.limit_prof ~= 5 then
				flag = false
			end
		end

		if flag and gifts_cfg["item_"..i.."_id"] ~= 0 then
			item_data_list[index] = {}
			item_data_list[index].item_id = gifts_cfg["item_"..i.."_id"]
			item_data_list[index].num = gifts_cfg["item_"..i.."_num"]
			item_data_list[index].is_bind = gifts_cfg["is_bind_"..i]
			index = index + 1
		end
	end
	return item_data_list
end

--通过索引获得一列配置
function DailyChargeData:GetChongzhiTimesCfg(seq)
	return self:GetDailyChongzhiSeq(seq)
end

function DailyChargeData:GetDailyChongzhiOpen()
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[32] == 1 and list[31] == 1  then
		return false
	end
	return true
end

function DailyChargeData:GetDailyChargeOpen()
	self.is_first = false
end

function DailyChargeData:GetDailyChargeRemind()
	-- if self.is_first then
	-- 	return 1
	-- end
	return self:GetDailyChongzhiState() and 1 or 0
end

function DailyChargeData:GetDailyChargeIsShow()
	return self:GetDailyChongzhiState() and 1 or 0
end

function DailyChargeData:GetDailyChongzhiState()
	local list = self.fetch_flag
	if list == nil then
		return true
	end
	if self:GetDailyChongzhiTimesCanReward() then
		return true
	end
	 if list[32] == 1 and list[31] == 1 then
		return false
	elseif list[32] == 1 then
		if self.chongzhi_num < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_99 then
			return false
		end
	elseif list[32] == 0 and list[31] == 0 then
		if self.chongzhi_num < CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10  then
			return false
		end
	end
	return true

end

function DailyChargeData:GetDailyChongzhiTimesCanReward()
	local reward_cfg = self:GetDailyChongzhiTimesRewardAuto()
	local list = self.chongzhi_info.daily_chongzhi_times_fetch_reward_flag_list
	local current_days = self.chongzhi_info.daily_chongzhi_complete_days
	if list == nil or current_days == nil then
		return false
	end
	for k,v in pairs(reward_cfg) do
		if list[33 - k] ~= 1 and current_days >= v.complete_days then
			return true
		end
	end
	return false
end

function DailyChargeData:GetFirstChongzhiOpen()
	if IS_AUDIT_VERSION then
		return false
	end
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[32] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetDailyLeiJiGetFlag()
	local list = KaiFuChargeData.Instance:GetDailyLeiJiFlagList() or {}
	local leiji_cfg = self:GetHuikuiRewardList()
	max_seq = #leiji_cfg
	for i = 1, max_seq do
		if list and list[33 - i] == 0 then
			return true
		end
	end
 	return false
end

function DailyChargeData:GetDailyLeiJiRemind()
	return self:GetDailyLeiJiState() and 1 or 0
end

function DailyChargeData:GetDailyLeiJiState()
	local today_recharge = DailyChargeData.Instance:GetChongZhiInfo().today_recharge
	local daily_leiji_reward, max_seq = self:GetDailyLeiJiRewardDay()
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	max_seq = max_seq + 1
	for i = max_seq, 1, -1 do
		if list[33 - i] == 0 and daily_leiji_reward[i].need_chongzhi <= today_recharge then
			return true
		end
	end
	return false
end

function DailyChargeData:GetFirstChargeRemind(index)
	return self:GetFirstChongzhiState(index) and 1 or 0
end

function DailyChargeData:GetDailyLeiJiIndexState(index)
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	if list[33 - index] == 0 then
		return true
	end
	return false
end

function DailyChargeData:GetDailyLeiJiIndexFlag()
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	for i = 32, 1, -1 do
		if list[i] == 0 then
			return 33 - i
		end
	end
end

--根据开服天数或者角色等级获取每日累充奖励配置
function DailyChargeData:GetDailyLeiJiRewardDay()
	local daily_leiji_reward = {}
	local open_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	local cfg = chongzhi_cfg.daily_chongzhi_reward2
	local max_seq = cfg[#cfg].seq
	if open_day <= 7 then
		for k,v in pairs(cfg) do
			if v.open_day == open_day then
				table.insert(daily_leiji_reward, v)
			end
		end
	else
		local level = GameVoManager.Instance:GetMainRoleVo().level
		local flag = false
		for k,v in ipairs(cfg) do
			if v.open_day > 7 then
				if level <= v.max_level and flag == false then
					flag = true
					level = v.max_level
				end
				if level == v.max_level then
					table.insert(daily_leiji_reward, v)
				end
			end
		end
	end
	return daily_leiji_reward, max_seq
end

function DailyChargeData:GetDailyNoReceiveDay()
	local now_receive_list = {}
	local list = self.chongzhi_info.daily_chongzhi_fetch_reward2_flag
	local no_receive_list, _ = self:GetDailyLeiJiRewardDay()
	for k,v in ipairs(no_receive_list) do
		if list[33-k] == 1 then
			no_receive_list[k] = nil
		else
			table.insert(now_receive_list, v)
		end
	end
	local max_seq = #now_receive_list
	return now_receive_list, max_seq
end

function DailyChargeData:GetFirstChongzhiState(index)
	local active_list = self.chongzhi_info.first_chongzhi_active_reward_flag
	local fetch_list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if index == 1 and active_list and active_list[32 - index + 1] == 1 and not fetch_list then
		return true
	end
	if active_list[32 - index + 1] == 1 and fetch_list[32 - index + 1] == 0 then
		return true
	end
	
	return false
end

function DailyChargeData:GetFirstChongzhi10State()
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[32] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetFirstChongzhi99State()
	local list = self.chongzhi_info.first_chongzhi_fetch_reward_flag_list
	if list == nil then
		return true
	end
	if list[31] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetRewardSeq(chongzhi_state)
	local cfg = self:GetDailyChongzhiRewardAuto()
	for k,v in pairs(cfg) do
		if v.need_total_chongzhi == chongzhi_state then
			return v.seq
		end
	end
end

function DailyChargeData:CheckIsFirstRechargeById(id)
	local list = self.chongzhi_info.reward_flag_list
	if list == nil then
		return true
	end
	if list[32-id] == 1 then
		return false
	end
	return true
end

function DailyChargeData:GetHistoryRecharge()
	return self.chongzhi_info.history_recharge or 0
end

function DailyChargeData:GetHuikuiRewardCfg()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local week_day = TimeCtrl.Instance:GetTheDayWeek()  --今天是星期几
	local day_index = 14
	if self.day ~= cur_day then 
		self.day = cur_day
		self.reward_cfg = {}
		local daily_chongzhi_day_index = self:GetDailyChongzhiDayIndex(cur_day - 1)
		local min_day = daily_chongzhi_day_index
		if min_day then
			for k,v in ipairs(min_day) do
				if cur_day <= day_index and v.opengame_day <= day_index then
					table.insert(self.reward_cfg, v)
				end
			end
		end
		local daily_chongzhi_day_index = self:GetDailyChongzhiDayIndex(week_day - 1)
		local max_day = daily_chongzhi_day_index
		if max_day then
			for k,v in ipairs(max_day) do
				if cur_day > day_index and v.opengame_day > day_index then
					table.insert(self.reward_cfg, v)
				end
			end
		end
	end

	return self.reward_cfg
end

function DailyChargeData:GetNextRewardCfg(value)
	local cur_cfg = self:GetHuikuiRewardCfg()
	for i,v in ipairs(cur_cfg) do
		if value < v.need_chongzhi then
			return v
		end
	end
end


function DailyChargeData:GetHuikuiRewardList()
	local spid = GLOBAL_CONFIG.package_info.config.agent_id
	local agent_cfg = ConfigManager.Instance:GetAutoConfig("agent_adapt_auto").shield_accumulate_recharge
	local charge_level = 0
	local shield_charge = 0
	local need_check = false
	for _, v in pairs(agent_cfg) do
		if v.spid == spid then
			shield_charge = v.every_day_total_charge
			need_check = true
			break
		end
	end

	local total_charge = KaiFuChargeData.Instance:GetChongZhiDaHuiKuiNun() or 0
	charge_level = shield_charge
	if total_charge ~= nil then
		charge_level = total_charge > shield_charge and total_charge or shield_charge
	end

	local list = KaiFuChargeData.Instance:GetDailyLeiJiFlagList() or {}
	local cfg = self:GetHuikuiRewardCfg()
	local reward_list = {}
	local index = 0
	for _, v in pairs(cfg) do
		local flag = KaiFuChargeData.Instance:GetChongZhiFlag(v.seq + 1)
		local info = TableCopy(v)
		info.flag = flag or 0
		local is_need_check = need_check and (v.need_chongzhi <= charge_level or v.pre_chongzhi <= total_charge)
		if is_need_check or not need_check then
			index = index + 1
			reward_list[index] = info
		end
	end

	if index > 0 then
		table.sort(reward_list, SortTools.KeyLowerSorter("flag", "need_chongzhi"))
	end

	return reward_list
end
--获取首冲奖励
function DailyChargeData:GetFirstRewardList()
	local cfg = self:GetOtherAuto()[1]
	return cfg.chongzhidahuikui_first_reward
end

function DailyChargeData:GetFirstChargeShowCfg(select_seq)
	local list = self:GetThreeRechargeAuto()
	for k,v in pairs(list) do
		if select_seq == v.seq then
			return v
		end
	end
	return {}
end

function DailyChargeData:OnSCChongzhidahuikui2Info(protocol)
	if protocol then
		self.chongzhi_num = protocol.chongzhi_num
	self.fetch_flag = bit:d2b(protocol.fetch_flag)
	end
end

function DailyChargeData:GetFetchFlagInfo()
	return self.fetch_flag
end

function DailyChargeData:GetDaySevenReward(seq, day_index)
	local daily_chongzhi_reward = {}
	local daily_chongzhi_reward_week = {}
	local chongzhi_cfg = RechargeData.Instance:GetChongzhiCfg()
	for i,v in pairs(chongzhi_cfg.chongzhidahuikui_2) do
		if	v.seq == seq and v.day_index == day_index then
			if v.opengame_day >= 999 then
				table.insert(daily_chongzhi_reward_week, v)
			else
				table.insert(daily_chongzhi_reward, v)
			end
		end
	end
	if TimeCtrl.Instance:GetCurOpenServerDay() > 14  then
		return daily_chongzhi_reward_week
	else 
		return daily_chongzhi_reward
	end	
end

function DailyChargeData:GetDayItemList(seq)
	local daily_chongzhi_reward = DailyChargeData.Instance:GetDaySevenReward(seq, self:GetDayIndex())
	local reward_item
	if daily_chongzhi_reward and next(daily_chongzhi_reward) then
		 reward_item = TableCopy(daily_chongzhi_reward[1])
	end
	return reward_item
end

function DailyChargeData:GetDayIndex()
	local day_index = TimeCtrl.Instance:GetCurOpenServerDay() 
	local week_day = TimeCtrl.Instance:GetTheDayWeek() -- 配置 day_index 0 时  为周日
	day_index =	day_index > 14 and week_day - 1 or day_index -1
	return day_index
end

function DailyChargeData:GetDayRewardSeq(chongzhi_state)
	local seq = chongzhi_state == CHONG_ZHI_STATE.NEED_TOTAL_CHONGZHI_10 and 0 or 1
	return seq
end
