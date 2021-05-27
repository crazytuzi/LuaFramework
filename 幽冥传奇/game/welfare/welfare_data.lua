WelfareData = WelfareData or BaseClass()

WelfareData.DAILY_SIGN_IN_DATA_CHANGE = "daily_sign_in_data_change"
WelfareData.DAILY_SIGN_IN_DATA_AGAIN  = "daily_sign_in_data_again"
WelfareData.ONLINE_REWARD_RESULT = "online_reward_result"
WelfareData.DAILY_SIGN_IN_HAVEREWARD = "daily_sign_in_havereward"
WelfareData.ONLINE_HAVEREWARD = "online_havereward"
WelfareData.FINANCING_INFO_CHANGE = "financing_info_change"
WelfareData.CONSUME_RANK_INFO_CHANGE = "consume_rank_info_change"
WelfareData.RECHARGE_RANK_INFO_CHANGE = "RECHARGE_RANK_INFO_CHANGE"
WelfareData.FINDRES_COUNT = "FINDRES_COUNT"

--累计签到奖励最大索引
SIGN_IN_ADD_REWARD_MAX_INDEX = 5

SIGN_IN_STATUS = 
{
	SIGN_IN = 0, 									--可领取
	ALREADYGET = 1,									--已签到
	BACK = 2,										--可找回
	WAIT = 3,										--即将领取
	AGAIN = 4,										--再领取
	V1 = 5,											--v1双倍
	V2 = 6,											--v2双倍
	V3 = 7,											--v3双倍
	V1_BACK = 8,									--v1双倍_可找回
	V2_BACK = 9,									--v2双倍_可找回
	V3_BACK = 10,									--v3双倍_可找回
}

--累计签到奖励最大索引
SIGN_IN_ADD_REWARD_MAX_INDEX = 5

FINANCING_TYPE_DEF = 
{
	BUY = 1, 										--购买超值理财
	RECEIVE = 2,									--领取超值理财奖励
	INFO = 3,										--获得超值理财信息
}

FINANCING_STATE = 
{
	CANNOT = 1,										--未达成
	GET = 2, 										--可领取
	ALREADYGET = 3,									--已领取
}
WelfareData.AfficheContent = ""
function WelfareData:__init()
	if WelfareData.Instance then
		ErrorLog("[WelfareData]:Attempt to create singleton twice!")
	end
	WelfareData.Instance = self

	self.login_reward_cfg = {}

	self.skip_animation_check_box_status = false

	self.timer = nil
	self.bool_show = nil
	self.remind_num_list = {}
	self.findres_list = {}
	self.sign_in_data = WelfareData.CreateSignInData()
	self.offline_info = {add_offline_time = 0}
	self.online_info = WelfareData.CreateOnlineInfo()
	self.financing_info = {left_num = 0, financing_flag = bit:d2b(0)}
	self.consume_rank_info = {}
	self.consume_rank_list = nil
	self.recharge_rank_info = {}
	self.recharge_rank_list = nil

	self:SetOfflineExpInfo()

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetFinancingRemind, self), RemindName.OpenServiceFinancial)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetConsumeRankRemind, self), RemindName.OpenServiceConsume)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRechargeRankRemind, self), RemindName.OpenServiceRecharge)

	RoleData.Instance:AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.ChangeSignInData, self))
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()
end

function WelfareData:__delete()
	WelfareData.Instance = nil
	
	self.sign_in_data = nil
	self.offline_info = nil
	self.online_info = nil
	self.remind_num_list = nil
end

function WelfareData:SetRemindData(remind_name, val)
	local old_val = self.remind_num_list[remind_name] or 0
	self.remind_num_list[remind_name] = val
	if old_val ~= val and WelfareCtrl.Instance then
		RemindManager.Instance:DoRemind(remind_name)
	end
end

function WelfareData:GetRemindNum(remind_name)
	return self.remind_num_list[remind_name] or 0
end


---------------------------------------
-- 每日签到 begin
---------------------------------------
function WelfareData.CreateSignInData()
	return {
		cur_month = 0,
		cur_day = 0,
		sign_in_times = 0,
		sign_award_mark = bit:d2b(0),
		again_sign_mark = bit:d2b(0),
		add_sign_reward_mark = bit:d2b(0),
		day_datas = {},
	}
end

function WelfareData.CreateSignInCellVo(info)
	return {
		day = 0,
		itemvo = {item_id = info.reward.id, num = info.reward.count, is_bind = info.reward.bind},
		status = SIGN_IN_STATUS.SIGN_IN,
	}
end

function WelfareData.GetSignInConfig()
	return EveryDayCheck
end

function WelfareData:GetSignInData()
	return self.sign_in_data
end

function WelfareData:ChangeSignInData()
	if self.sign_in_data.old_sign_award_mark ~= bit:d2b(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACTOR_SIGNIN)) then
		self:UpdateSignInData()
	end
	-- self:GetOnlineState()
end

function WelfareData:UpdateSignInData()
	local sign_in_mark = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ACTOR_SIGNIN) or 0
	self.sign_in_data.sign_award_mark = bit:d2b(sign_in_mark)

	local server_time = TimeCtrl.Instance:GetServerTime()
	local date_str = os.date("%Y %m %d", server_time)
	local date_t = Split(date_str, " ")
	self.sign_in_data.cur_month = tonumber(date_t[2])
	self.sign_in_data.month_total_day = TimeUtil.GetMonthDay(tonumber(date_t[1]), self.sign_in_data.cur_month)
	self.sign_in_data.cur_day = tonumber(date_t[3])
	self.sign_in_data.day_datas = {}
	local config = WelfareData.GetSignInConfig()
	for i=1, self.sign_in_data.month_total_day do
		if config.rewardList[i] then
			local cellvo = WelfareData.CreateSignInCellVo(config.rewardList[i])
			cellvo.day = i
			self.sign_in_data.day_datas[i] = cellvo
		end
	end
	table.sort(self.sign_in_data.day_datas, SortTools.KeyLowerSorter("day"))
	
	local remain_count = 0
	local sign_in_times = 0
	for i, v in ipairs(self.sign_in_data.day_datas) do
		local reward_mark = self.sign_in_data.sign_award_mark[33 - i]	-- 奖励是否领取

		if v.day < self.sign_in_data.cur_day then
			if 1 == reward_mark then
				sign_in_times = sign_in_times + 1
				v.status = SIGN_IN_STATUS.ALREADYGET
			else
				v.status = SIGN_IN_STATUS.BACK
			end
		elseif v.day == self.sign_in_data.cur_day then
			if 1 == reward_mark then
				sign_in_times = sign_in_times + 1
				if 1 == self.sign_in_data.again_sign_mark then
					v.status = SIGN_IN_STATUS.ALREADYGET
				else
					local have_recharge = ActivityBrilliantData.Instance:GetTodayRecharge() > 0
					-- if have_recharge then
					-- 	remain_count = remain_count + 1
					-- end
					v.status = SIGN_IN_STATUS.AGAIN       -- 再次领取（目前不需要）
					-- v.status = SIGN_IN_STATUS.ALREADYGET
				end
			else
				v.status = SIGN_IN_STATUS.SIGN_IN
				remain_count = remain_count + 1

			end
		else
			v.status = SIGN_IN_STATUS.WAIT
		end

		self.sign_in_data.sign_in_times = sign_in_times
		
		--设置显示V双倍奖励
		-- if v.status ~= SIGN_IN_STATUS.SIGN_IN and v.status ~= SIGN_IN_STATUS.ALREADYGET then
		-- 	if v.status ~= SIGN_IN_STATUS.BACK then
		-- 		if i == 2 then
		-- 			v.status = SIGN_IN_STATUS.V1
		-- 		elseif i == 9 then
		-- 			v.status = SIGN_IN_STATUS.V2
		-- 		elseif i == 16 then
		-- 			v.status = SIGN_IN_STATUS.V3
		-- 		end
		-- 	else
		-- 		if i == 2 then
		-- 			v.status = SIGN_IN_STATUS.V1_BACK
		-- 		elseif i == 9 then
		-- 			v.status = SIGN_IN_STATUS.V2_BACK
		-- 		elseif i == 16 then
		-- 			v.status = SIGN_IN_STATUS.V3_BACK
		-- 		end
		-- 	end
		-- end
	end
	
	--每日签到是否显示可领取奖励标志
	-- if self.sign_in_data.sign_in_times ~= sign_in_times then
	-- 	self:DispatchEvent(WelfareData.DAILY_SIGN_IN_HAVEREWARD,self.sign_in_data.cur_day > sign_in_times)
	-- end
	

	local day_box_remind = false
	for i, v in ipairs(WelfareData.GetAccumulatedDaysAward()) do
		if self.sign_in_data.sign_in_times >= v.days and not self:IsAddSignReward(i) then
			day_box_remind = true
		end
	end
	local remind
	local cur_day_statu= self.sign_in_data.day_datas[self.sign_in_data.cur_day].status
	
	if cur_day_statu == SIGN_IN_STATUS.SIGN_IN  or (cur_day_statu == SIGN_IN_STATUS.AGAIN and OtherData.Instance:GetDayChargeGoldNum()>0) or day_box_remind then
		self:DispatchEvent(WelfareData.DAILY_SIGN_IN_HAVEREWARD,true)
		remind = true
	    --remain_count = remain_count+1
	else
		self:DispatchEvent(WelfareData.DAILY_SIGN_IN_HAVEREWARD,false)
		remind = false
	end

	remain_count = remind and 1 or 0
	self:SetRemindData(RemindName.SignInReward, remain_count)
	if self.sign_in_data.sign_award_mark ~= self.sign_in_data.old_sign_award_mark then
		self:DispatchEvent(WelfareData.DAILY_SIGN_IN_DATA_CHANGE,self.sign_in_data.day_datas,sign_in_times)
	end
	self.sign_in_data.old_sign_award_mark = self.sign_in_data.sign_award_mark

	--return self.sign_in_data.cur_day > sign_in_times
	return remind
end

function WelfareData.GetSignInFindCost()
	return WelfareData.GetSignInConfig().supplementConsume.count
end


-------------------------------------- again
function WelfareData:SetAgainSignOneTimemark(protocol)
	self.sign_in_data.again_sign_mark = protocol.again_sign
	self:DispatchEvent(WelfareData.DAILY_SIGN_IN_DATA_AGAIN,self.sign_in_data.day_datas)
end

function WelfareData:SetAddSignRewardMark(protocol)
	self.sign_in_data.add_sign_reward_mark = bit:d2b(protocol.add_sign_award_mark)
end

function WelfareData:IsAddSignReward(index)
	return self.sign_in_data.add_sign_reward_mark[33 - index] == 1
end

function WelfareData.GetAccumulatedDaysAward()
	return EveryDayCheck.AccumulatedDaysAward
end

---------------------------------------
-- 每日签到 end
---------------------------------------

---------------------------------------
-- 更新公告 begin
---------------------------------------
function WelfareData:GetUpdateAfficheCfg()
	local cfg = ConfigManager.Instance:GetAutoConfig("updatenotice_auto").notice
	for k,v in pairs(cfg) do
		if v.plat_id == AgentAdapter:GetSpid() then
			return v
		end
	end
	return {}
end
---------------------------------------
-- 更新公告 end
---------------------------------------

---------------------------------------
-- 每日在线奖励 begin
---------------------------------------
function WelfareData.CreateOnlineInfo()
	local draw_data = {}
	for i,v in ipairs(WelfareData.GetOnlineAwardCfg()) do
		local data = {
			index = i,
			left_time = 0,
			item_index = 0,
			online = v.online,
			try_change = true,
		}
		draw_data[i] = data
	end

	return {
		online_time = 0,
		set_now_time = 0,
		online_reward_mark = bit:d2b(0),
		draw_data = draw_data,
	}

end

function WelfareData.GetOnlineAwardCfg()
	return OnlineTimeAward
end

function WelfareData:SetOnlineRewardInfo(protocol)
	
	local max_num = #WelfareData.GetOnlineAwardCfg()
	local old_flag = {}
	for i = 1, max_num do
		old_flag[i] = self:IsOnlineRewardReceive(i)
	end
	self.online_info.online_reward_mark = bit:d2b(protocol.online_reward_mark or 0)
	local reward_item_index_list = protocol.reward_item_index_list
	for i = 1, max_num do
		local old_index = self.online_info.draw_data[i].item_index
		local new_index = self:IsOnlineRewardReceive(i) 
			and (reward_item_index_list[i] and reward_item_index_list[i].item_index or 1) or 1
		-- 当抽奖物品id或领取奖品标志发生变化时才允许变化
		if old_index ~= new_index or old_flag[i] ~= self:IsOnlineRewardReceive(i) then
			self.online_info.draw_data[i].item_index = new_index
			self.online_info.draw_data[i].try_change = true
		end
	end

	self.online_info.online_time = protocol.online_time
	self.online_info.set_now_time = Status.NowTime
	self:FlushOnlineTime()
end

function WelfareData:FlushOnlineTime()

	local now_time = Status.NowTime
	self.online_info.online_time = self.online_info.online_time + (now_time - self.online_info.set_now_time)
	self.online_info.set_now_time = now_time
	local remind_num = 0
	local flush_list = {}
	for k,v in pairs(self.online_info.draw_data) do
		local old_val = v.left_time
		v.left_time = v.online - self.online_info.online_time
		if v.left_time < 0 then
			v.left_time = 0
		end
		if v.left_time == 0 and not self:IsOnlineRewardReceive(v.index) then
			remind_num = remind_num + 1
		end
		if old_val ~= v.left_time then
			table.insert(flush_list, k)
		end
	end

	self:SetRemindData(RemindName.OnlineReward, remind_num)
	self:GetOnlineState()
	
	return flush_list
end

function WelfareData:GetOnlineRewardInfo()
	return self.online_info
end

function WelfareData:IsOnlineRewardReceive(index)
	return self.online_info.online_reward_mark[33 - index] == 1
end

function WelfareData:GetRewardResult(protocol)
	self:DispatchEvent(WelfareData.ONLINE_REWARD_RESULT,{draw_index = protocol.draw_index, reward_index = protocol.reward_index})
end

function WelfareData:GetOnlineState()
	local remind
	if self.remind_num_list[RemindName.OnlineReward] > 0 then
		self:DispatchEvent(WelfareData.ONLINE_HAVEREWARD,true)
		remind = true
	else
		self:DispatchEvent(WelfareData.ONLINE_HAVEREWARD,false)
		remind = false
	end
	return remind
end
---------------------------------------
-- 每日在线奖励 end
---------------------------------------

---------------------------------------
-- 离线经验 begin
---------------------------------------
-- 离线配置
function WelfareData.GetOfflineExpCfg()
	return LogOutExp
end

function WelfareData:SetOfflineExpInfo(protocol)
	self.offline_info.add_offline_time = protocol and protocol.add_offline_time or 0
	local online_cfg = WelfareData.GetOfflineExpCfg()
	local list_data = {}
	for i,v in ipairs(online_cfg.vipRate) do
		local offline_hour = math.floor(self.offline_info.add_offline_time / 3600)
		local exp_hour = offline_hour < online_cfg.maxTime and offline_hour or online_cfg.maxTime
		local exp = exp_hour * online_cfg.outexp * v.rate
		list_data[i] = {
			index = i,
			rate = v.rate,
			viplv = v.viplv,
			exp = exp,
		}
	end

	self:SetRemindData(RemindName.OfflineExp, math.floor(self.offline_info.add_offline_time / 3600) >= 1 and 1 or 0)
	self.offline_info.list_data = list_data
end

function WelfareData:GetOfflineExpInfo()
	return self.offline_info
end
---------------------------------------
-- 离线经验 end
---------------------------------------

---------------------------------------
-- 超值理财 begin
---------------------------------------
function WelfareData.GetFinancingCfg()
	return FinancingCfg
end

-- 设置理财信息
function WelfareData:SetFinancingInfo(protocol)
	if protocol then
		self.financing_info.left_num = self.GetFinancingCfg().count - (protocol.buy_num or 0)
		self.financing_info.financing_flag = bit:d2b(protocol.financing_flag or 0)
	end

	local remind_num = 0
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local role_zhuan = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local list = {}
	local first_opt = nil
	for i,v in ipairs(WelfareData.GetFinancingCfg().awards) do
		list[i] = v
		if role_level >= v.need_level and role_zhuan >= v.condition	and not self:IsFinancingReceive(i) then
			list[i].get_type = FINANCING_STATE.GET
			if self:IsBuyFinancing() then
				remind_num = remind_num + 1
			end
			if not first_opt then
				first_opt = i
			end
		elseif self:IsFinancingReceive(i) then
			list[i].get_type = FINANCING_STATE.ALREADYGET
		else
			list[i].get_type = FINANCING_STATE.CANNOT
		end
	end
	self.financing_info.list = list
	self.financing_info.first_opt = first_opt or 0
	self.financing_info.remind_num = remind_num or 0
	self:BoolLinquWan()

	self:DispatchEvent(WelfareData.FINANCING_INFO_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceFinancial)
end

-- 是否已领取对应的理财奖励
function WelfareData:IsFinancingReceive(index)
	return self.financing_info.financing_flag[32 - index] == 1
end

-- 是否已领取全部的理财奖励
function WelfareData:IsGetAllFinancingReceive()
	if WelfareData.GetFinancingCfg() and WelfareData.GetFinancingCfg().awards then
		local is_all_get = true
		for i,v in ipairs(WelfareData.GetFinancingCfg().awards) do
			is_all_get = is_all_get and self:IsFinancingReceive(i)
		end
		return is_all_get
	end
	return false
end

-- 是否已购买理财
function WelfareData:IsBuyFinancing()
	return self.financing_info.financing_flag[32] == 1
end

-- 理财信息
function WelfareData:GetFinancingInfo()
	return self.financing_info
end

-- 获取理财信息项目数据
function WelfareData:GetFinancingItemData()
	local cfg = {}
	local list = {}
	for k,v in pairs(WelfareData.Instance.GetFinancingCfg().awards) do
		cfg[#cfg + 1] = {index = k, circle = v.condition, level = v.need_level, yb = v.yb}
	end

	for k,v in pairs(cfg) do
		if (not WelfareData.Instance:IsFinancingReceive(k)) then
			list[#list + 1] = v
		end
	end
	return list
end

function WelfareData:GetFinancingRemind()
	return self.financing_info.remind_num or 0
end

-- 获取理财剩余时间
function WelfareData.GetFinancingLeftTime()
	-- 理财跨天结束,时间需转成当天开始的时间
	local combind_time = TimeUtil.NowDayTimeStart(OtherData.Instance:GetOpenServerTime())
	local length = WelfareData.Instance.GetFinancingCfg().openDay * 86400
	local left_time = length - (os.time() - combind_time)
	return left_time
end

---------------------------------------
-- 超值理财 end
---------------------------------------

---------------------------------------
-- 资源找回 begin
---------------------------------------
function WelfareData:SetFindResData(protocol)
	local data = {}
	local cfg = FindResourceCfg.taskcfg
	for k, v in pairs(protocol.task_info) do
		if v.task_num > 0 then
			local vo = {
				task_id = v.task_id,
				task_num = v.task_num,
				task_name = cfg[v.task_id].taskname,
				yb_find_num = cfg[v.task_id].ybconsumes[1].count,
				zs_find_num = cfg[v.task_id].zsconsumes[1].count,
			}
			table.insert(data, vo)
		end
	end

	self.findres_list = data

	self:DispatchEvent(WelfareData.FINDRES_COUNT)
	RemindManager.Instance:DoRemindDelayTime(RemindName.FindresView)
end

function WelfareData:FindresShow()
	local num = 0
	for k, v in pairs(self.findres_list) do
		if v.task_num > 0 then
			num = 1
		end
		break
	end

	self:SetRemindData(RemindName.FindresView, num)
	return num
end

function WelfareData:GetFindResList()
	return self.findres_list
end

-- 获取资源找回各个任务的奖励
function WelfareData:GetTaskConfigAward(task_id)
	local item_cfg = {}
	if task_id == 1 then
		local index = DailyTasksData.Instance:GetTaskRewIndex()
		for k, v in pairs(XiangYaoChuMoCfg.reward[index].awards[10]) do
			item_cfg[k] = {type = v.type, item_id = v.id, is_bind = v.bind, num = v.count}
		end
	elseif task_id >= 2 and task_id <= 6 then
		local award = FubenZongGuanCfg.fubens[task_id-1].award
		
		for k, v in pairs(award) do
			item_cfg[k] = {type = v.type, item_id = v.id, is_bind = v.bind, num = v.count}
		end
	elseif task_id == 7 then
		item_cfg = EscortData.Instance:GetAwardsCfg()[#StdActivityCfg[8].tBiaoche]
	elseif task_id == 8 then
		-- local data = TaskData.Instance:GetConfigDataItemData()
		local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
		local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
		local data = {}
		for k, v in pairs(TianShuRenWuConfig.AwardsTb) do
			if v.circle == 0 then
				if level >= v.level then
					data = v.awards
				end
			elseif v.level == 0 then
				if circle >= v.circle then
					data = v.awards
				end
			end
		end
		for k1, v1 in pairs(data) do
			item_cfg[k1] = {item_id = v1.id, is_bind = v1.bind or 0, num = v1.count}
		end

	elseif task_id == 9 then
		local data = DungeonData.Instance:GetListInfo()
		local level = FubenData.Instance:GetCurMaxLevel() + 1
		-- local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	
		for k, v in pairs(data) do
			if level == v.level then
				for k1, v1 in pairs(v.showAwards) do
					item_cfg[k1] = {item_id = v1.id, is_bind = v1.bind or 0, num = v1.count}
				end
			end
		end
	elseif task_id == 10 then
		for k, v in pairs(MiningActConfig.Miner[1].Awards) do
			item_cfg[k] = {item_id = v.id, is_bind = v.bind or 0, num = v.count}
		end
	end

	return item_cfg
end

---------------------------------------
-- 资源找回 end
---------------------------------------

function WelfareData:BoolLinquWan()
	local number_linqu = 0
	if self.financing_info and self.financing_info.list ~=nil then
		for k, v in pairs(self.financing_info.list) do
			local is_receive = self:IsFinancingReceive(k)
			if is_receive == true then
				number_linqu = number_linqu + 1
			end
		end
	end
	if number_linqu == #self.financing_info.list then
		self.bool_show = true
	else
		self.bool_show = false
	end
end

function WelfareData:GetBoolVisible()
	return self.bool_show
end

---------------------------------------
-- 消费排行
---------------------------------------

-- 设置消费排行信息
function WelfareData:SetConsumeRankInfo(protocol)
	self.consume_rank_info.tag = protocol.tag
	self.consume_rank_info.yb_num = protocol.yb_num
	self.consume_rank_info.rank_num = protocol.rank_num
	self.consume_rank_info.rank_list = protocol.rank_list
	self.consume_rank_info.my_rank = protocol.my_rank

	self.consume_rank_list = nil
	self:DispatchEvent(WelfareData.CONSUME_RANK_INFO_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceConsume)
end

-- 获取消费排行信息
function WelfareData:GetConsumeRankInfo()
	return self.consume_rank_info
end

-- 获取消费排行信息
function WelfareData:GetConsumeRankList()
	local list = self.consume_rank_info.rank_list or {}
	return list
end

-- 获取消费排行配置
function WelfareData.GetConsumeRankCfg()
	local _, gear = WelfareData.Instance.GetConsumeRankOpen()
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 性别

	local list = {}
	if nil ~= gear then
		local cfg = OpenSvrConsumRankingCfg.GiftLevels[gear]
		for i,v in ipairs(cfg.rankings) do
			list[i] = {}
			list[i].award = {}
			for k,v in ipairs(v.award) do
				if v.sex == nil or v.sex == sex then
					if v.job == prof or v.job == nil or v.job == 0 then
						list[i].award[k] = ItemData.InitItemDataByCfg(v)
					end
				end
			end
			list[i].condition = v.condition
			list[i].index = i
		end
		if nil ~= cfg.join_award then
			local condition = cfg.join_award.condition
			local join_award = {}
			join_award.award = {}
			for k,v in ipairs(cfg.join_award.award) do
				if v.sex == nil or v.sex == sex then
					if v.job == prof or v.job == nil or v.job == 0 then
						join_award.award[k] = ItemData.InitItemDataByCfg(v)
					end
				end
			end
			join_award.index = "join_award"

			local info = WelfareData.Instance:GetConsumeRankInfo()
			if nil ~= info.yb_num and condition <= info.yb_num and info.tag == 0 then
				table.insert(list, 1, join_award)
			else
				table.insert(list, join_award)
			end
		end
	end

	return list
end

-- 获取消费排行配置剩余时间
function WelfareData.GetConsumeRankLeftTime()
	local combind_time = TimeUtil.NowDayTimeStart(OtherData.Instance:GetOpenServerTime())
	local length = WelfareData.Instance.GetConsumeRankOpen()
	local left_time = length ~= nil and length * 86400 - (os.time() - combind_time) or 0
	return left_time
end

-- 获取开放天数的档位
function WelfareData.GetConsumeRankOpen()
	local cfg = OpenSvrConsumRankingCfg.GiftLevels
	local open_server_day = OtherData.Instance:GetOpenServerDays()
	local open_day
	local gear
	for i,v in ipairs(cfg) do
		if v.openDays[1] <= open_server_day and v.openDays[2] >= open_server_day  then
			open_day = v.openDays[2]
			gear = i
			break
		end
	end
	return open_day, gear
end

function WelfareData:GetConsumeRankRemind()
	local index = 0
	local rank_cfg = OpenSvrConsumRankingCfg.minRankingConsum
	if self.consume_rank_info.yb_num and self.consume_rank_info.yb_num >= rank_cfg then
		index = self.consume_rank_info.tag == 0 and 1 or 0
	end

	return index
end

---------------------------------------
-- 消费排行 end
---------------------------------------

---------------------------------------
-- 充值排行
---------------------------------------
-- 设置充值排行信息
function WelfareData:SetRechargeRankInfo(protocol)
	self.recharge_rank_info.tag = protocol.tag
	self.recharge_rank_info.yb_num = protocol.yb_num
	self.recharge_rank_info.rank_num = protocol.rank_num
	self.recharge_rank_info.rank_list = protocol.rank_list
	self.recharge_rank_info.my_rank = protocol.my_rank

	self:DispatchEvent(WelfareData.RECHARGE_RANK_INFO_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.OpenServiceRecharge)
end

-- 获取充值排行信息
function WelfareData:GetRechargeRankInfo()
	return self.recharge_rank_info
end

-- 获取充值排行信息
function WelfareData:GetRechargeRankList()
	local list = self.recharge_rank_info.rank_list or {}
	return list
end

-- 获取充值排行配置
function WelfareData.GetRechargeRankCfg()
	local _, gear = WelfareData.Instance.GetRechargeRankOpen()
	local prof = math.max(RoleData.Instance:GetRoleBaseProf(), 1) --获取角色基础职业,默认是战士
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) -- 性别

	local list = {}
	if nil ~= gear then
		local cfg = OpenSvrPayRankingCfg.GiftLevels[gear]
		for i,v in ipairs(cfg.rankings) do
			list[i] = {}
			local award = {}
			for k,v in ipairs(v.award) do
				award[#award + 1] = ItemData.InitItemDataByCfg(v)
			end
			list[i].award = award
			list[i].condition = v.condition
			list[i].index = i
		end
		if nil ~= cfg.join_award then
			local condition = cfg.join_award.condition
			local join_award = {}
			local award = {}
			for k,v in ipairs(cfg.join_award.award) do
				award[#award + 1] = ItemData.InitItemDataByCfg(v)
			end
			join_award.award = award
			join_award.index = "join_award"

			local info = WelfareData.Instance:GetRechargeRankInfo()
			if nil ~= info.yb_num and condition <= info.yb_num and info.tag == 0 then
				table.insert(list, 1, join_award)
			else
				table.insert(list, join_award)
			end
		end
	end

	return list
end

-- 获取充值排行配置剩余时间
function WelfareData.GetRechargeRankLeftTime()
	local combind_time = TimeUtil.NowDayTimeStart(OtherData.Instance:GetOpenServerTime())
	local length = WelfareData.Instance.GetRechargeRankOpen()
	local left_time = length ~= nil and length * 86400 - (os.time() - combind_time) or 0
	return left_time
end

-- 获取开放天数的档位
function WelfareData.GetRechargeRankOpen()
	local cfg = OpenSvrPayRankingCfg.GiftLevels
	local open_server_day = OtherData.Instance:GetOpenServerDays()
	local open_day
	local gear
	for i,v in ipairs(cfg) do
		if v.openDays[1] <= open_server_day and v.openDays[2] >= open_server_day  then
			open_day = v.openDays[2]
			gear = i
			break
		end
	end
	return open_day, gear
end

function WelfareData:GetRechargeRankRemind()
	local index = 0
	local rank_cfg = OpenSvrPayRankingCfg.minRankingPay
	if self.recharge_rank_info.yb_num and self.recharge_rank_info.yb_num >= rank_cfg then
		index = self.recharge_rank_info.tag == 0 and 1 or 0
	end

	return index
end

---------------------------------------
-- 充值排行 end
---------------------------------------