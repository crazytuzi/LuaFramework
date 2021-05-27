OperateActivityData = OperateActivityData or BaseClass()
-- =============限时单笔 begin------
function OperateActivityData:InitTimeLimitOnceCharge()
	self.time_limit_once_charge_data = {}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.TIME_LIMIT_ONCE_CHARGE].config
	if not cfg then return end
	for k, v in ipairs(cfg.Awards) do
		local data = {	
						awards = {}, 
						desc = v.desc,
						money = v.Money,				-- 充值人民币数
						idx = k,
						state = 0,
					}
		data.awards = ItemData.AwardsToItems(v.Rewards)
		table.insert(self.time_limit_once_charge_data, data)
	end
end

function OperateActivityData:GetTimeLimitOnceData()
	return self.time_limit_once_charge_data
end

function OperateActivityData:SetTimeLimitOnceChargeData(data)
	if not self.time_limit_once_charge_data then return end
	if data.state_t then
		for k, v in ipairs(self.time_limit_once_charge_data) do
			local state = data.state_t[v.idx]
			if state then
				v.state = state
			end
		end
	else
		for k, v in ipairs(self.time_limit_once_charge_data) do
			if v.idx == data.idx then
				v.state = data.state
				break
			end
		end
	end
end

function OperateActivityData:ClearTimeLimitOnceChargeData()
	self.time_limit_once_charge_data = nil
end

function OperateActivityData:IsTimeLimitOnceChargeNeedRemind()
	if not self.time_limit_once_charge_data then return false end
	for k, v in ipairs(self.time_limit_once_charge_data) do
		if v.state == 1 then
			return true
		end
	end
	return false
end

-- ==============限时单笔 end------

-- =============限时商品begin------
function OperateActivityData:InitLimitGoodsInfo()
	self.limit_goods_info = {}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS].config
	if not cfg then return end
	local recharge_money_t = cfg.Money
	local recharge_ingot_t = cfg.Gold
	for k, v in ipairs(cfg.Rewards) do
		local data = {	awards = {}, 
						ingot = string.format(Language.Limited.TextTitle, recharge_ingot_t[k]),	-- 元宝
						money = recharge_money_t[k],				-- 充值人民币数
						idx = k,
					}
		data.awards = ItemData.AwardsToItems(v)
		table.insert(self.limit_goods_info, data)
	end	
end

function OperateActivityData:GetLimitGoodsInfo()
	return self.limit_goods_info
end

function OperateActivityData:SetLimitGoodsRestTime(data)
	self.limit_goods_rest_time = data.rest_time
end

function OperateActivityData:GetLimitGoodsRestCount()
	return self.limit_goods_rest_time or 10
end

function OperateActivityData:ClearLimitGoodsData()
	self.limit_goods_info = nil
	self.limit_goods_rest_time = nil
end

function OperateActivityData:IsLimitGoodsNeedRemind()
	return self.limit_goods_rest_time and self.limit_goods_rest_time > 0
end

-- ==============限时商品end------

-- =============限时商品2 begin------
function OperateActivityData:InitLimitGoodsInfoTwo()
	self.limit_goods_info_2 = {}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.TIME_LIMIT_GOODS_2].config
	if not cfg then return end
	local recharge_money_t = cfg.Money
	local recharge_ingot_t = cfg.Gold
	for k, v in ipairs(cfg.Rewards) do
		local data = {	awards = {}, 
						ingot = string.format(Language.Limited.TextTitle, recharge_ingot_t[k]),	-- 元宝
						money = recharge_money_t[k],				-- 充值人民币数
						idx = k,
					}
		data.awards = ItemData.AwardsToItems(v)
		table.insert(self.limit_goods_info_2, data)
	end
end

function OperateActivityData:GetLimitGoodsInfoTwo()
	return self.limit_goods_info_2
end

function OperateActivityData:SetLimitGoodsRestTimeTwo(data)
	self.limit_goods_rest_time_2 = data.rest_time
end

function OperateActivityData:GetLimitGoodsRestCountTwo()
	return self.limit_goods_rest_time_2 or 10
end

function OperateActivityData:ClearLimitGoodsDataTwo()
	self.limit_goods_info_2 = nil
	self.limit_goods_rest_time_2 = nil
end

function OperateActivityData:IsLimitGoodsNeedRemindTwo()
	return self.limit_goods_rest_time_2 and self.limit_goods_rest_time_2 > 0
end

-- ==============限时商品2 end------

-- =============重复充值begin------
function OperateActivityData:SetRepeatChargeBaseData()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.REPEAT_CHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.REPEAT_CHARGE].config
	if not cfg then return end
	self.repeat_charge_data = {}
	self.repeat_charge_data.gold = cfg.Gold
	self.repeat_charge_data.limitCnt = cfg.LimitCount
	self.repeat_charge_data.awards = ItemData.AwardsToItems(cfg.Rewards)

end

function OperateActivityData:GetRepeatChargeBaseData()
	return self.repeat_charge_data
end

function OperateActivityData:SetRepeatChargeRestTime(data)
	self.repeat_charge_rest_time = data.rest_time
end

function OperateActivityData:GetRepeatChargeRestCount()
	return self.repeat_charge_rest_time or 10
end

function OperateActivityData:GetRepeatChargeEndUnixTime()
	return self.operate_acts_configs[OPERATE_ACTIVITY_ID.REPEAT_CHARGE].end_time
end

function OperateActivityData:ClearRepeatChargeData()
	self.repeat_charge_data = nil
	self.repeat_charge_rest_time = nil
end

function OperateActivityData:IsRepeatChargeNeedRemind()
	return self.repeat_charge_rest_time > 0
end

-- ==============重复充值end------

--==================消费积分begind====================
function OperateActivityData:InitSpendScoreShopData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.SPEND_SCORE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.SPEND_SCORE].config
	if not cfg or not next(cfg) or not data or not next(data) then return end
	self.spend_score_shop_data = {}
	self.own_spend_score = data.value
	local awar_info = data.awar_info or {}
	local items_list = cfg.itemList or {}
	for i, v in ipairs(awar_info) do
		if items_list[v.idx] and v.rest_cnt > 0 then
			local data = items_list[v.idx]
			local temp = {idx = v.idx, limitNum = data.limitNum, cost = data.needScore, awards_t = {}, rest_cnt = v.rest_cnt,}
			temp.awards_t = ItemData.AwardsToItems(data.award)
			table.insert(self.spend_score_shop_data, temp)
		end
	end
end

function OperateActivityData:GetSpendScoreShopData()
	return self.spend_score_shop_data
end

function OperateActivityData:UpdateSpendScoreData(data)
	self.own_spend_score = data.value
	local idx = data.idx
	local rest_cnt = data.rest_cnt 
	for k, v in pairs(self.spend_score_shop_data) do
		if v.idx == idx then
			if rest_cnt <= 0 then
				table.remove(self.spend_score_shop_data, k)
				GlobalEventSystem:Fire(OperateActivityEventType.SPEND_SCORE_DEL_ITEM)
			else
				v.rest_cnt = rest_cnt
				GlobalEventSystem:Fire(OperateActivityEventType.SPEND_SCORE_UPDATE_ITEM, v)
			end
			break
		end
	end
end

-- 获取拥有消费积分
function OperateActivityData:GetOwnSpendScoreVal()
	return self.own_spend_score or 0
end

function OperateActivityData:IsSpendScoreNeedRemind()
	if not self.spend_score_shop_data or not next(self.spend_score_shop_data) then return false end

	for k, v in pairs(self.spend_score_shop_data) do
		if v.cost <= self.own_spend_score then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearSpendScoreData()
	self.spend_score_shop_data = nil
	self.own_spend_score = nil
end

--==================消费积分end====================

--==================新重复充值begind====================
function OperateActivityData:InitNewRepeatChargeData()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.NEW_REPEAT_CHARGE].config
	if not cfg or not next(cfg) then return end
	self.new_repeat_charge_data = {own_cnt = 0, used_cnt = 0, need_money = cfg.needRechargeGold, max_cnt = cfg.maxRechargeCount,}
	self.new_repeat_charge_awards_show = {}
	for i, v in ipairs(cfg.Rewards) do
		local temp = {idx = i, awards_t = {},}
		temp.awards_t = ItemData.AwardsToItems(v)
		table.insert(self.new_repeat_charge_awards_show, temp)
		
	end
end

function OperateActivityData:GetNewRepeatChargeData()
	return self.new_repeat_charge_data or {own_cnt = 0, used_cnt = 0,need_money = 100, max_cnt = 10,}
end

function OperateActivityData:GetNewRepeatChargeAwards()
	return self.new_repeat_charge_awards_show
end

function OperateActivityData:UpdateNewRepeatChargeData(data)
	self.new_repeat_charge_data.own_cnt = data.own_cnt
	self.new_repeat_charge_data.used_cnt = data.used_cnt
end

function OperateActivityData:IsNewRepeatChargeNeedRemind()
	if self.new_repeat_charge_data then
		return self.new_repeat_charge_data.used_cnt < self.new_repeat_charge_data.own_cnt
	end
	return false
end
--==================新重复充值end====================

-- ==============累计充值begin-----
function OperateActivityData:InitRechargeData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE].config
	if not cfg then return end
	self.recharge_data = {}
	self.recharge_money = data.count
	local state_t = data.state_t
	local awards_cfg = cfg and cfg.Rewards or {}
	local award_data = {}
	local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	for k, v in ipairs(awards_cfg) do
		local t = {
					state = state_t[k],
					money = cfg and cfg.Gold and cfg.Gold[k],
					awards = {},
				}
		t.awards = ItemData.AwardsToItems(v)
		table.insert(award_data, t)
	end
	self.recharge_data = award_data
end

function OperateActivityData:UpdateRechargeData(data)
	if self.recharge_data[data.idx] then
		self.recharge_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetRechargeData()
	return self.recharge_data
end

function OperateActivityData:GetRechargeMoney()
	return self.recharge_money or 0
end

function OperateActivityData:IsRechargeNeedRemind()
	if not self.recharge_data then return false end
	for k, v in pairs(self.recharge_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearRechargeData()
	self.recharge_data = nil
	self.recharge_money = nil
end

-- ==============累计充值end-----


-- ==============每日累计充值begin-----
function OperateActivityData:InitDailyRechargeData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_CHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_CHARGE].config
	if not cfg then return end
	self.daily_recharge_data = {}
	self.daily_recharge_money = data.count
	local state_t = data.state_t
	local awards_cfg = cfg and cfg.Rewards or {}
	local award_data = {}
	for k, v in ipairs(awards_cfg) do
		local t = {
					state = state_t[k],
					money = cfg and cfg.Gold and cfg.Gold[k],
					awards = {},
				}
		t.awards = ItemData.AwardsToItems(v)
		table.insert(award_data, t)
	end
	self.daily_recharge_data = award_data
end

function OperateActivityData:UpdateDailyRechargeData(data)
	if self.daily_recharge_data[data.idx] then
		self.daily_recharge_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetDailyRechargeData()
	return self.daily_recharge_data
end

function OperateActivityData:GetDailyRechargeMoney()
	return self.daily_recharge_money or 0
end

function OperateActivityData:IsDailyRechargeNeedRemind()
	if not self.daily_recharge_data then return false end
	for k, v in pairs(self.daily_recharge_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearDailyRechargeData()
	self.daily_recharge_data = nil
	self.daily_recharge_money = nil
end

-- ==============每日累计充值end-----


--===============累计消费begin-----
function OperateActivityData:InitConsumeData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND].config
	if not cfg then return end
	self.consume_data = {}
	self.spend_money = data.count
	local state_t = data.state_t
	local awards_cfg = cfg and cfg.Rewards or {}
	local cur_data = {}
	for k, v in ipairs(awards_cfg) do
		local t = {
					state = state_t[k],
					money = cfg and cfg.Gold and cfg.Gold[k],
					awards = {},
				}
		t.awards = ItemData.AwardsToItems(v)
		table.insert(cur_data, t)
	end
	self.consume_data = cur_data
end

function OperateActivityData:UpdateConsumeData(data)
	if self.consume_data[data.idx] then
		self.consume_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetConsumeData()
	return self.consume_data
end

function OperateActivityData:GetConsumeMoney()
	return self.spend_money or 0
end

function OperateActivityData:IsConsumeNeedRemind()
	if not self.consume_data then return false end
	for k, v in pairs(self.consume_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearConsumeData()
	self.consume_data = nil
	self.spend_money = nil
end

--==========累计消费end-----

--===============每日累计消费begin-----
function OperateActivityData:InitDailyConsumeData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_SPEND] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAILY_SPEND].config
	if not cfg then return end
	self.daily_consume_data = {}
	self.daily_spend_money = data.count
	local state_t = data.state_t
	local awards_cfg = cfg and cfg.Rewards or {}
	local cur_data = {}
	for k, v in ipairs(awards_cfg) do
		local t = {
					state = state_t[k],
					money = cfg and cfg.Gold and cfg.Gold[k],
					awards = {},
				}
		t.awards = ItemData.AwardsToItems(v)
		table.insert(cur_data, t)
	end
	self.daily_consume_data = cur_data
end

function OperateActivityData:UpdateDailyConsumeData(data)
	if self.daily_consume_data[data.idx] then
		self.daily_consume_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetDailyConsumeData()
	return self.daily_consume_data
end

function OperateActivityData:GetDailyConsumeMoney()
	return self.daily_spend_money or 0
end

function OperateActivityData:IsDailyConsumeNeedRemind()
	if not self.daily_consume_data then return false end
	for k, v in pairs(self.daily_consume_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearDailyConsumeData()
	self.daily_consume_data = nil
	self.daily_spend_money = nil
end

--==========每日累计消费end-----

--====================连续累充begin=====================
function OperateActivityData:SetContinousAddupChargeData(data)
	if nil == self.conti_addup_charge_data then
		self.conti_addup_charge_data = {}
		self.conti_addup_charge_data.extr_state = data.extr_state
		self.conti_addup_charge_data.day = data.day
		local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE].config
		if cfg then
			self.conti_addup_charge_data.awar_info = {}
			self.conti_addup_charge_data.total_day = #cfg.Awards
			self.conti_addup_charge_data.extr_awards = ItemData.AwardsToItems(cfg.exAwards)
			for k, v in ipairs(cfg.Awards) do
				local info = {
					idx = k,
					need_num = v.dailyRechargeNum,
					money = data.awar_info[k] and data.awar_info[k].money,
					state = data.awar_info[k] and data.awar_info[k].state or DAILY_CHARGE_FETCH_ST.CNNOT,
					awards = ItemData.AwardsToItems(v.awards),
				}
				if info.state == DAILY_CHARGE_FETCH_ST.CNNOT then
					info.client_rank = 1
				elseif info.state == DAILY_CHARGE_FETCH_ST.FETCHED then
					info.client_rank = 0
				else
					info.client_rank = 2
				end
				table.insert(self.conti_addup_charge_data.awar_info, info)
			end
		end
	else
		self.conti_addup_charge_data.extr_state = data.extr_state
		self.conti_addup_charge_data.day = data.day
		for k, v in pairs(self.conti_addup_charge_data.awar_info) do
			v.money = data.awar_info[k] and data.awar_info[k].money
			v.state = data.awar_info[k] and data.awar_info[k].state
			if v.state == DAILY_CHARGE_FETCH_ST.CNNOT then
				v.client_rank = 1
			elseif v.state == DAILY_CHARGE_FETCH_ST.FETCHED then
				v.client_rank = 0
			else
				v.client_rank = 2
			end
		end
	end
end

function OperateActivityData:GetContinousAddupChargeData()
	return self.conti_addup_charge_data
end

function OperateActivityData:GetContinousAddupLessDay()
	local less_day = 1
	if self.conti_addup_charge_data then
		less_day = self.conti_addup_charge_data.total_day
		for k, v in pairs(self.conti_addup_charge_data.awar_info) do
			if v.state ~= DAILY_CHARGE_FETCH_ST.CNNOT then
				less_day = less_day - 1
			end
		end
	end
	return less_day
end

function OperateActivityData:IsContinousAddupCharNeedRemind()
	if not self.conti_addup_charge_data or not self.conti_addup_charge_data.awar_info then return false end
	if self.conti_addup_charge_data.extr_state == DAILY_CHARGE_FETCH_ST.CAN then
		return true
	end
	for k, v in pairs(self.conti_addup_charge_data.awar_info) do
		if v.state == DAILY_CHARGE_FETCH_ST.CAN then
			return true
		end
	end
	return false
end


function OperateActivityData:ClearContinousAddupChargeData()
	self.conti_addup_charge_data = nil
end

--====================连续累充end=====================

--====================新连续累充begin=====================
function OperateActivityData:InitNewContinousAddupChargeData()
	self.new_conti_addup_charge_per_remind_t = {}
	self.new_conti_addup_charge_data = {}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_ADDUP_CHARGE_NEW].config
	if cfg then
		self.new_conti_addup_charge_data.money = 0
		self.new_conti_addup_charge_data.plan_num = #cfg.Rewards
		for i,v1 in ipairs(cfg.Rewards) do
			self.new_conti_addup_charge_data[i] = {awar_info = {}, total_day = #v1.Awards, day = 0, gold = v1.Gold,}
			for k, v in ipairs(v1.Awards) do
				local info = {
					idx = k,
					plan = i,
					state = DAILY_CHARGE_FETCH_ST.CNNOT,
					awards = ItemData.AwardsToItems(v),
					client_rank = 1
				}
				table.insert(self.new_conti_addup_charge_data[i].awar_info, info)
			end
		end
		
	end
end

function OperateActivityData:GetNewContiAddupNameTab()
	local nameTab = {}
	if self.new_conti_addup_charge_data then
		for i = 1, self.new_conti_addup_charge_data.plan_num do
			local data = self.new_conti_addup_charge_data[i]
			nameTab[i] = string.format(Language.OperateActivity.NewContiAddupChargeTxts[1], data.gold/10)
		end
	else
		return {{},{}}
	end
	return nameTab
end

function OperateActivityData:SetNewContinousAddupChargeData(data)
	self.new_conti_addup_charge_data.money = data.money
	for i,v1 in ipairs(data.info_list) do
		self.new_conti_addup_charge_data[i].day = v1.day
		for k, v in ipairs(v1.state_t) do
			local info = self.new_conti_addup_charge_data[i].awar_info[k]
			if info then
				info.state = v
				if v == DAILY_CHARGE_FETCH_ST.CNNOT then
					info.client_rank = 1
				elseif v == DAILY_CHARGE_FETCH_ST.FETCHED then
					info.client_rank = 0
				else
					info.client_rank = 2
				end
			end
		end
	end			
end

function OperateActivityData:UpdateNewContinousAddupCharge(data)
	local info = data.info
	local cur_info = self.new_conti_addup_charge_data[info.idx1] and self.new_conti_addup_charge_data[info.idx1].awar_info[info.idx2]
	if cur_info then
		cur_info.state = info.state
		if info.state == DAILY_CHARGE_FETCH_ST.CNNOT then
			cur_info.client_rank = 1
		elseif info.state == DAILY_CHARGE_FETCH_ST.FETCHED then
			cur_info.client_rank = 0
		else
			cur_info.client_rank = 2
		end
	end
end

function OperateActivityData:GetNewContinousAddupChargeData()
	return self.new_conti_addup_charge_data
end

function OperateActivityData:GetNewContinousAddupChargeAwards(index)
	return self.new_conti_addup_charge_data[index]
end

function OperateActivityData:GetNewContinousAddupLessDay()
	local less_day = 1
	if self.new_conti_addup_charge_data then
		less_day = self.new_conti_addup_charge_data.total_day
		for k, v in pairs(self.new_conti_addup_charge_data.awar_info) do
			if v.state ~= DAILY_CHARGE_FETCH_ST.CNNOT then
				less_day = less_day - 1
			end
		end
	end
	return less_day
end

function OperateActivityData:IsNewContinousAddupCharNeedRemind()
	self.new_conti_addup_charge_per_remind_t = {}
	if not self.new_conti_addup_charge_data then return false end	
	local remind = false
	for i = 1,self.new_conti_addup_charge_data.plan_num do	
		self.new_conti_addup_charge_per_remind_t[i] = 0
		local data = self.new_conti_addup_charge_data[i]
		for k, v in ipairs(data.awar_info) do
			if v.state == DAILY_CHARGE_FETCH_ST.CAN then
				self.new_conti_addup_charge_per_remind_t[i] = 1
				remind = true
				break
			end
		end
	end
	return remind
end

function OperateActivityData:GetNewContiAddupAllPlanRemindNum()
	return self.new_conti_addup_charge_per_remind_t
end

function OperateActivityData:ClearNewContinousAddupChargeData()
	self.new_conti_addup_charge_data = nil
end

--====================新连续累充end=====================

-----------------------------------------
-- 连续登录奖励 begin
-----------------------------------------
function OperateActivityData:GetContinuousLoginRewardData(index, type)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN].config
	if not cfg or not cfg.Awards[index] then return end
	local award_cfg = type == 1 and cfg.Awards[index].awards or cfg.Awards[index].exAwards
	if not award_cfg then return end
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local data = {}
	for k,v in pairs(award_cfg) do
		if (v.sex == nil or v.sex == sex) 
			and (v.job == nil or v.job == prof) then
			data[#data + 1] = {item_id = v.id, num = v.count, is_bind = v.bind, sp_effect_id = v.effectId}
		end
	end

	return data
end

function OperateActivityData:InitContinuousLoginBaseInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.CONTINUOUS_LOGIN].config
	self.continuous_login_base_info = {}
	-- self.continuous_first_makeup_cost = 0
	-- self.continuous_per_time_add_cost = 0
	-- self.continuous_makeup_flag = 0
	-- self.continuous_makeup_cnt = 0
	if not cfg then return end
	-- self.continuous_first_makeup_cost = cfg.firstSignCostNum
	-- self.continuous_per_time_add_cost = cfg.everySignCostAdd
	for i = 1, #cfg.Awards do
		local award_cfg = cfg.Awards[i]
		local tmp = {
			day = i,
			get_lv = 0,
			icon = award_cfg.icon,
			big_show = award_cfg.big_show,
			state_1 = SEVEN_DAYS_LOGIN_FETCH_STATE.CANNOT,
			state_2 = SEVEN_DAYS_LOGIN_FETCH_STATE.CANNOT,
			need_makeup = false,				-- 需要补签
			vip_cond = award_cfg.exVipCond,
		}
		self.continuous_login_base_info[i] = tmp
	end
end

function OperateActivityData:GetContinuousLoginBaseInfo()
	return self.continuous_login_base_info
end

function OperateActivityData:GetContinuousLoginTimes()
	return self.continuous_login_times or 1
end

function OperateActivityData:SetContinuousLoginGetGiftData(data)
	if self.continuous_login_base_info == nil then return end
	self.continuous_login_times = data.login_days > 0 and data.login_days or 1
	-- self.continuous_makeup_flag = data.makeup_flag or 0
	-- self.continuous_makeup_cnt = data.makeup_cnt or 0
	for k, v in ipairs(data.state_t) do
		if self.continuous_login_base_info[k] then
			self.continuous_login_base_info[k].state_1 = v.state_1
			self.continuous_login_base_info[k].state_2 = v.state_2
		end
	end
	-- self:SetContinuousLoginNeedMakeup()
end

function OperateActivityData:UpdateContinuousLoginData(data)
	if self.continuous_login_base_info == nil then return end
	if self.continuous_login_base_info[data.idx] then
		self.continuous_login_base_info[data.idx]["state_" .. data.type] = data.state
	end
end

function OperateActivityData:SetContinuousLoginNeedMakeup()
	if self.continuous_makeup_flag ~= 1 then return end
	for k, v in ipairs(self.continuous_login_base_info) do
		if k > self.continuous_login_times and v.state_1 == SEVEN_DAYS_LOGIN_FETCH_STATE.CANNOT then
			v.need_makeup = true
		else
			v.need_makeup = false
		end
	end
end

function OperateActivityData:GetContinuousMakeupCost()
	if self.continuous_makeup_flag ~= 1 then return 0 end
	if nil == self.continuous_makeup_cnt then self.continuous_makeup_cnt = 0 end
	return self.continuous_makeup_cnt * self.continuous_per_time_add_cost + self.continuous_first_makeup_cost
end

function OperateActivityData:IsContinuousLoginGetGiftNeedRemind()
	if not self.continuous_login_base_info then return false end
	local vip_lv = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	for k, v in pairs(self.continuous_login_base_info) do
		if v.state_1 == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN or (vip_lv >= v.vip_cond and v.state_2 == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN) then
			return true
		end
	end
	
	return false
end

function OperateActivityData:ClearContinuousLoginGetGiftData()
	self.continuous_login_base_info = nil
	-- self.continuous_makeup_cnt = 0
	-- self.continuous_makeup_flag = 0
end

-----------------------------------------
-- 连续登录奖励 end
-----------------------------------------

-----------------------------------------
-- 新春19天登录奖励 begin
-----------------------------------------
function OperateActivityData:GetLoginRewardData(index)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT].config
	if not cfg then return end
	local award_cfg = cfg.Awards[index] and cfg.Awards[index].awards
	if not award_cfg then return end
	local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	local data = {}
	for k,v in pairs(award_cfg) do
		if (v.sex == nil or v.sex == sex) 
			and (v.job == nil or v.job == prof) then
			data[#data + 1] = {item_id = v.id, num = v.count, is_bind = v.bind, sp_effect_id = v.effectId}
		end
	end

	return data
end

function OperateActivityData:InitAddupLoginBaseInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_LOGIN_GET_GIFT].config
	self.addup_login_base_info = {}
	self.first_makeup_cost = 0
	self.spring_per_time_add_cost = 0
	self.makeup_flag = 0
	self.makeup_cnt = 0
	if not cfg then return end
	self.first_makeup_cost = cfg.firstSignCostNum
	self.spring_per_time_add_cost = cfg.everySignCostAdd
	for i = 1, #cfg.Awards do
		local award_cfg = cfg.Awards[i]
		local tmp = {
			day = i,
			get_lv = 0,
			icon = award_cfg.icon,
			big_show = award_cfg.big_show,
			state = SEVEN_DAYS_LOGIN_FETCH_STATE.CANNOT,
			need_makeup = false,				-- 需要补签
		}
		self.addup_login_base_info[i] = tmp
	end
end

function OperateActivityData:GetAddupLoginBaseInfo()
	return self.addup_login_base_info
end

function OperateActivityData:GetAddLoginTimes()
	return self.add_login_times or 1
end

function OperateActivityData:SetAddUpLoginGetGiftData(data)
	if self.addup_login_base_info == nil then return end
	self.add_login_times = data.login_days > 0 and data.login_days or 1
	self.makeup_flag = data.makeup_flag
	self.makeup_cnt = data.makeup_cnt
	for k, v in ipairs(data.state_t) do
		if self.addup_login_base_info[k] then
			self.addup_login_base_info[k].state = v
		end
	end
	self:SetAddupLoginNeedMakeup()
	-- self:SetSevenDaysLoginRemindData()
end

function OperateActivityData:SetAddupLoginNeedMakeup()
	if self.makeup_flag ~= 1 then return end
	for k, v in ipairs(self.addup_login_base_info) do
		if k > self.add_login_times and v.state == SEVEN_DAYS_LOGIN_FETCH_STATE.CANNOT then
			v.need_makeup = true
		else
			v.need_makeup = false
		end
	end
end

function OperateActivityData:GetMakeupCost()
	if self.makeup_flag ~= 1 then return 0 end
	if nil == self.makeup_cnt then self.makeup_cnt = 0 end
	return self.makeup_cnt * self.spring_per_time_add_cost + self.first_makeup_cost
end

function OperateActivityData:IsAddupLoginGetGiftNeedRemind()
	if not self.addup_login_base_info then return false end
	for k, v in pairs(self.addup_login_base_info) do
		if v.state == SEVEN_DAYS_LOGIN_FETCH_STATE.CAN or v.need_makeup then
			return true
		end
	end
	
	return false
end

function OperateActivityData:ClearAddupLoginGetGiftData()
	self.addup_login_base_info = nil
	self.makeup_cnt = 0
	self.makeup_flag = 0
end

function OperateActivityData:IsSevenDaysLoginShow()
	for k, v in pairs(self.addup_login_base_info) do
		if v.state ~= SEVEN_DAYS_LOGIN_FETCH_STATE.FETCHED then
			return true
		end
	end

	return false
end

-----------------------------------------
-- 新春19天登录奖励 end
-----------------------------------------

--====================旺旺红包begin=====================
function OperateActivityData:GetProsperyRedEnveAwards()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.PROSPERY_RED_EVEV] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.PROSPERY_RED_EVEV].config
	local awards_data = nil
	if cfg and cfg.Awards then
		awards_data = {}
		for k, v in ipairs(cfg.Awards) do
			local info = {}
			info.desc = v.desc
			info.awards = ItemData.AwardsToItems(v.awards)
			table.insert(awards_data, info)
		end
	end
	return awards_data
end
--====================旺旺红包end=====================

--====================累充返利begin======================
function OperateActivityData:GetAddupRechargePaybackCfg()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK].config
	if not cfg then return end
	return cfg.Awards
end

function OperateActivityData:SetAddupRechargePaybackData(data)
	self.addup_recharge_money = data.my_money
end

function OperateActivityData:GetAddupRechargePaybackMoney()
	return self.addup_recharge_money or 0
end

function OperateActivityData:GetAddupRechargePaybackCnt()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK].config
	if self.addup_recharge_money and cfg then
		cfg = cfg.Awards
		local data = cfg[#cfg]
		if self.addup_recharge_money < data.rechargeLimitNum then
			return 0
		end
		for _, v in ipairs(cfg) do
			if self.addup_recharge_money >= v.rechargeLimitNum then
				return self.addup_recharge_money * v.awardFactor
			end
		end
	end
	return 0
end

function OperateActivityData:IsAddupChargePaybackNeedRemind()
	return self:CheckActIsOpen(OPERATE_ACTIVITY_ID.ADDUP_CHARGE_PAYBACK)
end

--=========================累充返利end============================

--====================累消返利begin======================
function OperateActivityData:GetAddupSpendPaybackCfg()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK].config
	if not cfg then return end
	return cfg.Awards
end

function OperateActivityData:SetAddupSpendPaybackData(data)
	self.addup_spend_money = data.my_money
end

function OperateActivityData:GetAddupSpendPaybackMoney()
	return self.addup_spend_money or 0
end

function OperateActivityData:GetAddupSpendPaybackCnt()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK].config
	if self.addup_spend_money and cfg then
		cfg = cfg.Awards
		local data = cfg[#cfg]
		if self.addup_spend_money < data.rechargeLimitNum then
			return 0
		end
		for _, v in ipairs(cfg) do
			if self.addup_spend_money >= v.rechargeLimitNum then
				return self.addup_spend_money * v.awardFactor
			end
		end
	end
	return 0
end

function OperateActivityData:IsAddupSpendPaybackNeedRemind()
	return self:CheckActIsOpen(OPERATE_ACTIVITY_ID.ADDUP_SPEND_PAYBACK)
end

--=========================累消返利end============================

-- =================拼单抢购begin-------
function OperateActivityData:InitPinDanQiangGouCfgData()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.PINGDAN_QIANGGOU].config
	if not cfg then return end
	self.pindan_cfg = {}
	local total_cfg = cfg.giftBagList and cfg.giftBagList or {}
	for k, v in pairs(total_cfg) do
		local data = {
						gift_type = v.giftBagType,
						gift_name = v.giftBagName,
						price = v.giftBagNeedGoldNum,
						awards = {},
						percent_back = v.precentBack,	
					}
		data.awards = ItemData.AwardsToItems(v.Awards)
		table.insert(self.pindan_cfg, data)
	end
end

function OperateActivityData:SetPinDanQiangGouData(data)
	if not self.pindan_cfg or not next(self.pindan_cfg) then return end
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local main_role_name = main_role_vo and main_role_vo.name or ""
	local role_id = main_role_vo and main_role_vo[OBJ_ATTR.ENTITY_ID] or -1
	self.cur_din_dan_list = {}
	local cur_din_dan = data.cur_din_dan_list
	self.my_din_dan_list = data.my_join_din_dan_list
	for k, v in ipairs(self.pindan_cfg) do
		local tmp = {gift_type = v.gift_type}
		local cur_data = cur_din_dan[v.gift_type]
		tmp.dindan_id = cur_data and cur_data.dindan_id or -1
		tmp.info_list = cur_data and cur_data.info_list
		tmp.beginner = cur_data and cur_data.beginner or ""
		tmp.role_id = cur_data and cur_data.role_id or 0
		tmp.is_self_in = false
		if cur_data then
			for _, v_2 in pairs(cur_data.info_list) do
				if v_2.role_id == role_id then
					tmp.is_self_in = true
					break
				end
			end
		end
		self.cur_din_dan_list[k] = tmp
	end

end

function OperateActivityData:UpdatePinDanQiangGouData(data)
	if self.cur_din_dan_list == nil then return end
	-- PrintTable(data)
	if data.is_finish == 0 then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local main_role_name = main_role_vo and main_role_vo.name or ""
		local role_id = main_role_vo and main_role_vo[OBJ_ATTR.ENTITY_ID] or -1
		for k, v in pairs(self.cur_din_dan_list) do
			if v.gift_type == data.gift_type then
				v.dindan_id = data.dindan_id
				v.info_list = data.info_list
				v.beginner = data.beginner or ""
				if data.dindan_id == 0 then
					v.is_self_in = false
					break
				end
				for _, v_2 in pairs(data.info_list) do
					if v_2.role_id == role_id then
						v.is_self_in = true
						break
					end
				end
				break
			end
		end
	else
		local tmp = {
						dindan_id = data.dindan_id, gift_type = data.gift_type, 
						info_list = data.info_list, beginner = data.beginner 
					}
		self.my_din_dan_list = self.my_din_dan_list or {}
		table.insert(self.my_din_dan_list, tmp)

		for k, v in pairs(self.cur_din_dan_list) do
			if v.gift_type == data.gift_type then
				v.dindan_id = -1
				v.info_list = nil
				v.is_self_in = false
				v.beginner = ""
			end
		end
	end
end

function OperateActivityData:ClearPinDanQiangGouData()
	self.pindan_cfg = nil
	self.cur_din_dan_list = nil
	self.my_din_dan_list = nil
end

function OperateActivityData:GetPinDanQiangGouOneGiftCfg(gift_type)
	return self.pindan_cfg[gift_type]
end

function OperateActivityData:GetCurPinDanList()
	return self.cur_din_dan_list
end

function OperateActivityData:GetMyPinDanList()
	return self.my_din_dan_list
end

function OperateActivityData:IsPinDanQiangGouNeedRemind()
	if not self.cur_din_dan_list then return false end
	for k, v in pairs(self.cur_din_dan_list) do
		if not v.is_self_in then
			return true
		end
	end
	return false
end

-- =================拼单抢购end-------

--====================神秘商店begin======================
function OperateActivityData:GetSecretShopCfg()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.SECRET_SHOP] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.SECRET_SHOP].config
	if not cfg then return end
	return cfg
end

function OperateActivityData:SetSecretShopData(data)
	self.secret_shop_refr_cd = data.refr_cd + Status.NowTime
	self.secret_shop_hand_refr_cnt = data.hand_refr_cnt
	local cfg = self:GetSecretShopCfg()
	if not cfg then return end
	self.secret_shop_items = {}
	local idx = 0
	self.secret_shop_refr_cost = cfg.refreshConsume and cfg.refreshConsume[1].count or 0
	local item_list = cfg.ItemList
	for k, v in pairs(data.items_info) do
		local tmp = {
						cfg_data = item_list[k],
						index = k,
						buy_num = v,
					}
		self.secret_shop_items[idx] = tmp
		idx = idx + 1
	end
end

function OperateActivityData:GetSecretShopItemsData()
	return self.secret_shop_items
end

function OperateActivityData:GetSecretShopRefrCD()
	return self.secret_shop_refr_cd or Status.NowTime
end

function OperateActivityData:GetSecretShopRefrCost()
	return self.secret_shop_refr_cost or 0
end

function OperateActivityData:IsSecretShopNeedRemind()
	return true
end

function OperateActivityData:ClearSecretShopData()

end

--=========================神秘商店end============================

--==================超值限购begind====================
function OperateActivityData:InitDiscountLimitShopData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DISCOUNT_LIMIT_BUY].config
	if not cfg or not next(cfg) or not data or not next(data) then return end
	self.discount_limit_shop_data = {}
	-- self.own_spend_score = data.value
	local awar_info = data.awar_info or {}
	local items_list = cfg.itemList or {}
	for i, v in ipairs(awar_info) do
		if items_list[v.idx] and v.rest_cnt > 0 then
			local data = items_list[v.idx]
			local temp = {idx = v.idx, limitNum = data.limitNum, now_price = data.needGoldNum, 
				old_price = data.preNeedGoldNum, awards_t = {}, rest_cnt = v.rest_cnt,}
			temp.awards_t = ItemData.AwardsToItems(data.award)
			table.insert(self.discount_limit_shop_data, temp)
		end
	end
end

function OperateActivityData:GetDiscountLimitShopData()
	return self.discount_limit_shop_data
end

function OperateActivityData:UpdateDiscountLimitData(data)
	-- self.own_spend_score = data.value
	local idx = data.idx
	local rest_cnt = data.rest_cnt 
	for k, v in pairs(self.discount_limit_shop_data) do
		if v.idx == idx then
			if rest_cnt <= 0 then
				table.remove(self.discount_limit_shop_data, k)
				GlobalEventSystem:Fire(OperateActivityEventType.DISCOUNT_LIMIT_DEL_ITEM)
			else
				v.rest_cnt = rest_cnt
				GlobalEventSystem:Fire(OperateActivityEventType.DISCOUNT_LIMIT_UPDATE_ITEM, v)
			end
			break
		end
	end
end

-- -- 获取拥有超值限购
-- function OperateActivityData:GetOwnSpendScoreVal()
-- 	return self.own_spend_score or 0
-- end

function OperateActivityData:IsDiscountLimitNeedRemind()
	if not self.discount_limit_shop_data or not next(self.discount_limit_shop_data) then return false end
	local own_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	for k, v in pairs(self.discount_limit_shop_data) do
		if v.now_price <= own_money then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearDiscountLimitData()
	self.discount_limit_shop_data = nil
	-- self.own_spend_score = nil
end

--==================超值限购end====================


--==================宝物折扣begind====================
function OperateActivityData:InitDiscountTreasureData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE].config
	if not cfg or not next(cfg) or not data or not next(data) then return end
	self.discount_treasure_data = {}
	-- self.own_spend_score = data.value
	local awar_info = data.awar_info or {}
	local items_list = cfg.itemList or {}
	for i, v in ipairs(awar_info) do
		if items_list[v.idx] and v.rest_cnt > 0 then
			local data = items_list[v.idx]
			local temp = {idx = v.idx, limitNum = data.limitNum, need_money = data.needGoldNum, awards = {}, 
				rest_cnt = v.rest_cnt, desc = data.describe,}
			temp.awards = ItemData.AwardsToItems(data.award)
			table.insert(self.discount_treasure_data, temp)
		end
	end
end

function OperateActivityData:GetDiscountTreasureData()
	return self.discount_treasure_data
end

function OperateActivityData:UpdateDiscountTreasureData(data)
	-- self.own_spend_score = data.value
	local idx = data.idx
	local rest_cnt = data.rest_cnt 
	for k, v in pairs(self.discount_treasure_data) do
		if v.idx == idx then
			if rest_cnt > 0 then
				v.rest_cnt = rest_cnt
			else
				table.remove(self.discount_treasure_data, k)
			end
			break
		end
	end
end

-- -- 获取拥有宝物折扣
-- function OperateActivityData:GetOwnSpendScoreVal()
-- 	return self.own_spend_score or 0
-- end

function OperateActivityData:IsDiscountTreasureNeedRemind()
	if not self.discount_treasure_data or not next(self.discount_treasure_data) then return false end
	local own_money = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	for k, v in pairs(self.discount_treasure_data) do
		if v.need_money <= own_money then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearDiscountTreasureData()
	self.discount_treasure_data = nil
	-- self.own_spend_score = nil
end

--==================宝物折扣end====================

-- ==============天数充值begin-----
function OperateActivityData:InitDayNumRechargeData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE].config
	if not cfg then return end
	self.day_num_recharge_data = {}
	self.recharge_complete_day_num = data.day_num
	self.day_recharge_num = data.count
	local state_t = data.state_t
	local awards_cfg = cfg and cfg.Rewards or {}
	local award_data = {}
	for k, v in ipairs(awards_cfg) do
		local t = {
					state = state_t[k],
					day_cond = cfg and cfg.Days and cfg.Days[k],
					awards = {},
				}
		t.awards = ItemData.AwardsToItems(v)
		table.insert(award_data, t)
	end
	self.day_num_recharge_data = award_data
end

function OperateActivityData:UpdateDayNumRechargeData(data)
	if self.day_num_recharge_data[data.idx] then
		self.day_num_recharge_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetDayNumRechargeData()
	return self.day_num_recharge_data
end

function OperateActivityData:GetRechargeDayNum()
	return self.recharge_complete_day_num
end

function OperateActivityData:GetDayRechargeNum()
	return self.day_recharge_num or 0
end

function OperateActivityData:IsDayNumRechargeNeedRemind()
	for k, v in pairs(self.day_num_recharge_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearDayNumChargeData()
	self.day_num_recharge_data = nil
	self.recharge_complete_day_num = nil
end

-- ==============天数充值end-----

-- ==============天数消费begin-----
function OperateActivityData:InitDayNumSpendData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAY_NUM_SPEND] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.DAY_NUM_SPEND].config
	if not cfg then return end
	self.day_num_spend_data = {}
	self.spend_complete_day_num = data.day_num
	self.day_spend_num = data.count
	local state_t = data.state_t
	local awards_cfg = cfg and cfg.Rewards or {}
	local award_data = {}
	for k, v in ipairs(awards_cfg) do
		local t = {
					state = state_t[k],
					day_cond = cfg and cfg.Days and cfg.Days[k],
					awards = {},
				}
		t.awards = ItemData.AwardsToItems(v)
		table.insert(award_data, t)
	end
	self.day_num_spend_data = award_data
end

function OperateActivityData:UpdateDayNumSpendData(data)
	if self.day_num_spend_data[data.idx] then
		self.day_num_spend_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetDayNumSpendData()
	return self.day_num_spend_data
end

function OperateActivityData:GetSpendDayNum()
	return self.spend_complete_day_num
end

function OperateActivityData:GetDaySpendNum()
	return self.day_spend_num or 0
end

function OperateActivityData:IsDayNumSpendNeedRemind()
	for k, v in pairs(self.day_num_spend_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearDayNumSpendData()
	self.day_num_spend_data = nil
	self.spend_complete_day_num = nil
end

-- ==============天数消费end-----

--=====================超级团购活动begin=====================
function OperateActivityData:SetSuperGroupPurchaseData(data)
	self:InitSuperGroupPurchaseData(data)
end


function OperateActivityData:InitSuperGroupPurchaseData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE].config
	if not cfg then return end
	self.super_group_chose_items = {}							-- 当天被选中团购物品数据
	self.super_group_standard_award_data = self.super_group_standard_award_data or {}
	self.super_all_server_buy_time = data.all_server_buy_time
	if self.choice_item_num == nil or self.choice_item_num ~= cfg.choiceItemNum then
		self.choice_item_num = cfg.choiceItemNum
	end
	local item_list = cfg.itemList
	if item_list then
		for k, v in pairs(data.chosen_items_data) do
			local chose_item_cfg = item_list[k]
			if chose_item_cfg then
				local chose_item = {
				item = {
							item_id = chose_item_cfg.id,
							num = chose_item_cfg.count,
							is_bind = chose_item_cfg.bind or 0,
						},
				buy_limit = chose_item_cfg.buyLimit,
				now_price = chose_item_cfg.nowPrice,
				old_price = chose_item_cfg.oldPrice,
				idx = k,
				rest_buy_time = v.rest_buy_time,
			}
				table.insert(self.super_group_chose_items, #self.super_group_chose_items, chose_item)
			end
		end
	end

	if not next(self.super_group_standard_award_data) then
		for k, v in ipairs(data.awar_info) do
			if cfg.Rewards[v.idx] then
				local awar_cfg = cfg.Rewards[v.idx]
				local temp_data = {state = v.state, buyCnt = awar_cfg.buyCount, awards_t = {}, idx = v.idx,}
				temp_data.awards_t = ItemData.AwardsToItems(awar_cfg.Awards)
				self.super_group_standard_award_data[v.idx] = temp_data
			end
		end
	else
		for k, v in pairs(self.super_group_standard_award_data) do
			if data.awar_info[k] and v.idx == data.awar_info[k].idx then
				local awar_info = data.awar_info[k]
				v.state = awar_info.state
			end
		end
	end

end

-- function OperateActivityData:UpdateGroupPurchaseData(data)
-- 		local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.GROUP_PURCHASE].config
-- 		if not cfg then return end
-- 	self.super_all_server_buy_time = data.all_server_buy_time
-- 	if data.item_idx ~= self.super_group_chose_items.idx then

-- 		local chose_item_cfg = cfg.itemList[data.item_idx]
-- 		if chose_item_cfg then
-- 			self.super_group_chose_items.item_id = chose_item_cfg.id
-- 			self.super_group_chose_items.num = chose_item_cfg.count
-- 			self.super_group_chose_items.is_bind = 0
-- 			self.super_group_chose_items.buy_limit = chose_item_cfg.buyLimit
-- 			self.super_group_chose_items.now_price = chose_item_cfg.nowPrice
-- 			self.super_group_chose_items.old_price = chose_item_cfg.oldPrice
-- 			self.super_group_chose_items.idx = data.item_idx
-- 		end
-- 	end

-- 	for k, v in pairs(self.super_group_standard_award_data) do
-- 		if data.awar_info[k] and v.idx == data.awar_info[k].idx then
-- 			local awar_info = data.awar_info[k]
-- 			v.state = awar_info.state
-- 		end
-- 	end
-- end

function OperateActivityData:GetSuperGroupChoiceItemNum()
	return self.choice_item_num or 5
end

function OperateActivityData:GetSuperGroupPurchaseStandardData()
	return self.super_group_standard_award_data
end

-- function OperateActivityData:GetSuperGroupPurchaseRestBuyTime()
-- 	return self.group_rest_buy_time or 0
-- end

function OperateActivityData:GetSuperGroupPurchaseAllBuyTime()
	return self.super_all_server_buy_time or 0
end

function OperateActivityData:GetSuperGroupPurchaseChosenItems()
	return self.super_group_chose_items or {}
end

-- function OperateActivityData:GetChosenItemIdx()
-- 	return self.super_group_chose_items.idx or 0
-- end

function OperateActivityData:IsSuperGroupPurchaseNeedRemind()
	if not self.super_group_standard_award_data or not next(self.super_group_standard_award_data) then
		return false
	end

	for k, v in pairs(self.super_group_standard_award_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearGroupPurchaseData()
	self.super_group_chose_items = nil
	self.super_group_standard_award_data = nil
	self.super_all_server_buy_time = nil
end

--=====================超级团购活动end=====================

--=====================团购活动begin=====================
function OperateActivityData:SetGroupPurchaseData(data)
	if not self.group_chose_item or not self.group_standard_award_data then
		self:InitGroupPurchaseData(data)
	else
		self:UpdateGroupPurchaseData(data)
	end
end


function OperateActivityData:InitGroupPurchaseData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.GROUP_PURCHASE].config
	if not cfg then return end
	self.group_chose_item = {}							-- 当天被选中团购物品数据
	self.group_standard_award_data = {}
	self.group_rest_buy_time = data.rest_buy_time
	self.all_server_buy_time = data.all_server_buy_time
	local chose_item_cfg = cfg.itemList[data.item_idx]
	if chose_item_cfg then
		self.group_chose_item.item_id = chose_item_cfg.id
		self.group_chose_item.num = chose_item_cfg.count
		self.group_chose_item.is_bind = 0
		self.group_chose_item.buy_limit = chose_item_cfg.buyLimit
		self.group_chose_item.now_price = chose_item_cfg.nowPrice
		self.group_chose_item.old_price = chose_item_cfg.oldPrice
		self.group_chose_item.idx = data.item_idx
	end
	for k, v in ipairs(data.awar_info) do
		if cfg.Rewards[v.idx] then
			local awar_cfg = cfg.Rewards[v.idx]
			local temp_data = {state = v.state, buyCnt = awar_cfg.buyCount, awards_t = {}, idx = v.idx,}
			temp_data.awards_t = ItemData.AwardsToItems(awar_cfg.Awards)
			self.group_standard_award_data[v.idx] = temp_data
		end
	end

end

function OperateActivityData:UpdateGroupPurchaseData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.GROUP_PURCHASE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.GROUP_PURCHASE].config
	if not cfg then return end
	self.group_rest_buy_time = data.rest_buy_time
	self.all_server_buy_time = data.all_server_buy_time
	if data.item_idx ~= self.group_chose_item.idx then
		local chose_item_cfg = cfg.itemList[data.item_idx]
		if chose_item_cfg then
			self.group_chose_item.item_id = chose_item_cfg.id
			self.group_chose_item.num = chose_item_cfg.count
			self.group_chose_item.is_bind = 0
			self.group_chose_item.buy_limit = chose_item_cfg.buyLimit
			self.group_chose_item.now_price = chose_item_cfg.nowPrice
			self.group_chose_item.old_price = chose_item_cfg.oldPrice
			self.group_chose_item.idx = data.item_idx
		end
	end

	for k, v in pairs(self.group_standard_award_data) do
		if data.awar_info[k] and v.idx == data.awar_info[k].idx then
			local awar_info = data.awar_info[k]
			v.state = awar_info.state
		end
	end
end

function OperateActivityData:GetGroupPurchaseStandardData()
	return self.group_standard_award_data
end

function OperateActivityData:GetGroupPurchaseRestBuyTime()
	return self.group_rest_buy_time or 0
end

function OperateActivityData:GetGroupPurchaseAllBuyTime()
	return self.all_server_buy_time or 0
end

function OperateActivityData:GetGroupPurchaseChosenItem()
	return self.group_chose_item or {}
end

function OperateActivityData:GetChosenItemIdx()
	return self.group_chose_item.idx or 0
end

function OperateActivityData:IsGroupPurchaseNeedRemind()
	if not self.group_standard_award_data or not next(self.group_standard_award_data) then
		return false
	end

	for k, v in pairs(self.group_standard_award_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearGroupPurchaseData()
	self.group_chose_item = nil
	self.group_standard_award_data = nil
	self.group_rest_buy_time = nil
	self.all_server_buy_time = nil
end

--=====================团购活动end=====================


-------------------------许愿井begin----------------------------------------
function OperateActivityData:SetWishWellData(data)
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.WISH_WELL] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.WISH_WELL].config
	if not cfg then return end
	self.wish_well_already_get_cnt = data.already_get_cnt
	self.wish_well_rest_cnt = data.rest_wish_cnt
	self.wish_well_next_add_rest_time = data.add_cnt_rest_time
	self.wish_well_record_list = self.wish_well_record_list or {}
	for k, v in ipairs(data.record_list) do
		table.insert(self.wish_well_record_list, 1, v)
	end

	if not self.wish_well_record_max_cnt then
		self.wish_well_record_max_cnt = 50
		self.max_wish_cnt = 10
		self.wish_well_record_max_cnt = cfg.saveCount
		self.max_wish_cnt = cfg.maxCount
	end

	-- 超出最大数量限制，从后面删除多出的
	local recor_list_len = #self.wish_well_record_list
	if recor_list_len > self.wish_well_record_max_cnt then
		local no_need_cnt = recor_list_len - self.wish_well_record_max_cnt
		self:DelListOverFloodCnt(self.wish_well_record_list, no_need_cnt)
	end

end

function OperateActivityData:GetWishWellRestWishCnt()
	return self.wish_well_rest_cnt or 0
end

function OperateActivityData:GetWishWellAlreadyGetCnt()
	return self.wish_well_already_get_cnt or 0
end

function OperateActivityData:GetWishWellRecordData()
	return self.wish_well_record_list
end

function OperateActivityData:GetWishWellAddCntRestTime()
	if self.wish_well_next_add_rest_time and self.wish_well_next_add_rest_time > 0 then
		self.wish_well_next_add_rest_time = self.wish_well_next_add_rest_time - 1
	end

	return self.wish_well_next_add_rest_time

end

function OperateActivityData:IsGetAllWishCnt()
	return self.wish_well_already_get_cnt >= self.max_wish_cnt
end

function OperateActivityData:IsWishWellNeedRemind()
	return self.wish_well_rest_cnt > 0
end

function OperateActivityData:ClearWishWellData()
	self.wish_well_record_list = nil
	self.wish_well_next_add_rest_time = nil
	self.wish_well_rest_cnt = nil
	self.wish_well_record_max_cnt = nil
	self.wish_well_already_get_cnt = nil
	self.max_wish_cnt = 10
end

-------------------------许愿井end----------------------------------------

-- ==============累计登陆begin-----
function OperateActivityData:InitAddupLoginData(data)
	self.addup_login_data = {}
	self.addup_login_day_num = data.login_day
	local state_t = data.state_t
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_LOGIN] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.ADDUP_LOGIN].config
	if cfg then
		local awards_cfg = cfg and cfg.Awards or {}
		local award_data = {}
		for k, v in ipairs(awards_cfg) do
			local t = {
						idx = k,
						desc = v.desc,
						state = state_t[k],
						cond = v.cond,
						awards = {},
					}
			t.awards = ItemData.AwardsToItems(v.awards)
			table.insert(self.addup_login_data, t)
		end
	end
end

function OperateActivityData:UpdateAddupLoginData(data)
	if self.addup_login_data[data.idx] then
		self.addup_login_data[data.idx].state = data.state
	end
end

function OperateActivityData:GetAddupLoginData()
	return self.addup_login_data
end

function OperateActivityData:GetAddupLoginDayNum()
	return self.addup_login_day_num or 1
end

function OperateActivityData:IsAddupLoginNeedRemind()
	for k, v in pairs(self.addup_login_data) do
		if v.state == 1 then
			return true
		end
	end

	return false
end

function OperateActivityData:ClearAddupLoginData()
	self.addup_login_data = nil
	self.addup_login_day_num = nil
end

-- ==============累计登陆end-----

-- ---------------------------幸运购begin-------------------------------
function OperateActivityData:InitLuckyBuyCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.LUCKY_BUY] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.LUCKY_BUY].config
	if cfg then
		self.lucky_buy_opened_day = 1 				-- 幸运购开放天数
		self.lucky_buy_all_cnt = 0 					-- 全服购买数量
		self.lucky_buy_my_cnt = 0 					-- 自己购买数量
		self.lucky_buy_cur_group_award = nil 		-- 当前团体奖励物品
		self.lucky_buy_cur_daily_awards = nil 		-- 当前每日购奖励
		self.lucky_buy_cur_cost = 0
		self.lucky_buy_cfg = {}
		self.lucky_buy_cfg.buy_cost_t = cfg.buyCost 		-- 消耗元宝库(根据天数取)
 		self.lucky_buy_cfg.open_award_time = cfg.AwardTime 	-- 开奖时间
 		self.lucky_buy_cfg.group_awards = ItemData.AwardsToItems(cfg.dailySpecialItems)	-- 团体奖励库(根据天数取)
		self.lucky_buy_cfg.daily_awards_pool = {} 				-- 每日奖励库(根据天数取)
		for k, v in ipairs(cfg.dailyItems) do
			local awards = ItemData.AwardsToItems(v)
			table.insert(self.lucky_buy_cfg.daily_awards_pool, awards)
		end
	end
end

function OperateActivityData:SetLuckyBuyData(data)
	if self.lucky_buy_cfg == nil then return end
	self.lucky_buy_opened_day = data.act_opened_day
	self.lucky_buy_all_cnt = data.all_buy_cnt
	self.lucky_buy_my_cnt = data.my_buy_cnt
	if data.awar_list then
		self.award_list = data.awar_list
	end
	local len = #self.lucky_buy_cfg.group_awards
	self.lucky_buy_cur_group_award = self.lucky_buy_cfg.group_awards[data.act_opened_day] or self.lucky_buy_cfg.group_awards[len]
	len = #self.lucky_buy_cfg.daily_awards_pool
	self.lucky_buy_cur_daily_awards = self.lucky_buy_cfg.daily_awards_pool[data.act_opened_day] or self.lucky_buy_cfg.daily_awards_pool[len]
	len = #self.lucky_buy_cfg.buy_cost_t
	self.lucky_buy_cur_cost = self.lucky_buy_cfg.buy_cost_t[data.act_opened_day] or self.lucky_buy_cfg.buy_cost_t[len]
end

function OperateActivityData:GetLuckyBuyCnt()
	return self.lucky_buy_all_cnt, self.lucky_buy_my_cnt, self.lucky_buy_cur_cost
end

function OperateActivityData:GetLuckyBuyAwardList()
	return self.award_list or {}
end

function OperateActivityData:GetAwardsData()
	return self.lucky_buy_cur_group_award, self.lucky_buy_cur_daily_awards
end

function OperateActivityData:GetLuckyBuyAwarOpenTime()
	return self.lucky_buy_cfg and self.lucky_buy_cfg.open_award_time or 0
end

function OperateActivityData:ClearLuckyBuyData()
	self.lucky_buy_cfg = nil
	self.lucky_buy_opened_day = 1 				-- 幸运购开放天数
	self.lucky_buy_all_cnt = 0 					-- 全服购买数量
	self.lucky_buy_my_cnt = 0 					-- 自己购买数量
	self.lucky_buy_cur_group_award = nil 					-- 当前团体奖励物品
	self.lucky_buy_cur_daily_awards = nil 					-- 当前每日购奖励

end
-- ---------------------------幸运购end---------------------------------

--------------------------------摇钱树begin---------------------------------------
OperateActivityData.PrayMoneyBuyType = {
	OneTime = 1,
	TenTime = 2,
}
function OperateActivityData:InitPrayMoneyTreeCfgInfo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE].config
	if cfg then
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		self.pray_tree_cfg_info = {}
		self.pray_tree_cfg_info.cost_type = cfg.ExchangeMoneyType
		self.pray_tree_cfg_info.exchange = cfg.Exchange
		self.pray_tree_cfg_info.show_item_list = {}			-- 展示物品
		self.pray_tree_cfg_info.yb_pool_info = {}			-- 元宝奖励池展示信息
		self.pray_tree_cfg_info.get_awrds_info = {}			-- 获奖物品信息
		self.pray_tree_cfg_info.extra_awars_info = {}		-- 额外奖励信息
		for k, v in ipairs(cfg.Show) do
			local temp = {item_id = v.id, num = v.count, is_bind = 0,}
			table.insert(self.pray_tree_cfg_info.show_item_list, temp)
		end

		for k, v in ipairs(cfg.Rewards) do
			local temp = {state = PRAY_MONEY_TREE_FETCH_STATE.CNNOT,awards = {},}
			temp.buy_cnt = v.buyCount
			temp.vip_lv = v.vipLevel	--所需vip等级
			temp.icon = v.icon
			temp.tips = v.Tips
			for k2, v2 in ipairs(v.Awards) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.id)
				if item_cfg then
					temp.tips = temp.tips  .. "\n" .. "{wordcolor;" .. string.sub(string.format("%06x", item_cfg.color), 1, 6)
					 .. ";" .. item_cfg.name .. "}" .. "X" .. v2.count
				end
				if (nil == v2.job and nil == v2.sex) or (v2.job and v2.sex and v2.job == job and v2.sex == sex) or
				(v2.job and v2.sex == nil and v2.job == job) or (v2.job == nil and v2.sex and v2.sex == sex) then

					local a_temp = {item_id = v2.id, num = v2.count, is_bind = v2.bind,}
					table.insert(temp.awards, a_temp)
				end
			end

			self.pray_tree_cfg_info.yb_pool_info[k] = temp
		end
	end
end

function OperateActivityData:GetPrayMoneyTreeCfgInfo()
	return self.pray_tree_cfg_info or {}
end

-- 获取全服购买数、奖金池元宝数
function OperateActivityData:GetPrayMoneyAllSerData()
	return self.all_server_buy_time or 0, self.awar_pool_yb_cnt or 0
end

function OperateActivityData:SetPrayMoneyTreeData(data)
	if not self.pray_tree_cfg_info then return end
	self.all_server_buy_time = data.all_server_buy_time
	self.awar_pool_yb_cnt = data.awar_pool_yb_cnt
	for _, v in pairs(data.awar_pool_state_t) do
		if self.pray_tree_cfg_info.yb_pool_info[v.idx] then
			self.pray_tree_cfg_info.yb_pool_info[v.idx].state = v.state
		end
	end
end

function OperateActivityData:UpdatePrayMoneyTreeData(data)
	if data.oper_type == 1 then
		self.all_server_buy_time = data.all_server_buy_time
		self.awar_pool_yb_cnt = data.awar_pool_yb_cnt
		for _, v in pairs(data.awar_pool_state_t) do
			if self.pray_tree_cfg_info.yb_pool_info[v.idx] then
				self.pray_tree_cfg_info.yb_pool_info[v.idx].state = v.state
			end
		end
		self.pray_tree_cfg_info.get_awrds_info = data.buy_result_info
		self.pray_tree_cfg_info.extra_awars_info = data.extr_awar_info
	else
		if self.pray_tree_cfg_info.yb_pool_info[data.cur_awar_idx] then  
			self.pray_tree_cfg_info.yb_pool_info[data.cur_awar_idx].state = data.state
		end
	end
end

function OperateActivityData:GetPrayMoneyGetAwardsInfo()
	return self.pray_tree_cfg_info.get_awrds_info or {}, self.pray_tree_cfg_info.extra_awars_info or {}
end

function OperateActivityData:EmptyGetAwardsInfo()
	self.pray_tree_cfg_info.get_awrds_info = {}
	self.pray_tree_cfg_info.extra_awars_info = {}
end

function OperateActivityData:GetPrayMoneyExtraAwardsInfo()
	return self.pray_tree_cfg_info.extra_awars_info or {}
end

function OperateActivityData:IsPrayMoneyTreeRemind()
	if not self.pray_tree_cfg_info then return false end
	local is_remind = false
	for k, v in pairs(self.pray_tree_cfg_info.yb_pool_info) do
		if v.state == PRAY_MONEY_TREE_FETCH_STATE.CAN then
			is_remind = true
			break
		end
	end
	if not is_remind then
		local own_yb = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		local cost_1, cost_2 = self.pray_tree_cfg_info.exchange[1].ExchangeCost, self.pray_tree_cfg_info.exchange[2].ExchangeCost
		is_remind = own_yb >= cost_1
	end
	return is_remind
end

function OperateActivityData:ClearPrayMoneyTreeData()
	self.pray_tree_cfg_info = nil
	self.all_server_buy_time = 0
	self.awar_pool_yb_cnt = 0
end

--------------------------------摇钱树end---------------------------------------


--------------------------------摇钱树2 begin---------------------------------------

function OperateActivityData:InitPrayMoneyTreeCfgInfoTwo()
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.PRAY_MONEY_TREE_2].config
	if cfg then
		local job = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
		self.pray_tree_cfg_info_2 = {}
		self.pray_tree_cfg_info_2.cost_type = cfg.ExchangeMoneyType
		self.pray_tree_cfg_info_2.exchange = cfg.Exchange
		self.pray_tree_cfg_info_2.show_item_list = {}			-- 展示物品
		self.pray_tree_cfg_info_2.yb_pool_info = {}			-- 元宝奖励池展示信息
		self.pray_tree_cfg_info_2.get_awrds_info = {}			-- 获奖物品信息
		-- self.pray_tree_cfg_info_2.extra_awars_info = {}		-- 额外奖励信息
		for k, v in ipairs(cfg.Show) do
			local temp = {item_id = v.id, num = v.count, is_bind = 0,}
			table.insert(self.pray_tree_cfg_info_2.show_item_list, temp)
		end

		for k, v in ipairs(cfg.Rewards) do
			local temp = {state = PRAY_MONEY_TREE_FETCH_STATE.CNNOT,awards = {},}
			temp.buy_cnt = v.needScore
			temp.vip_lv = v.vipLevel	--所需vip等级
			temp.icon = v.icon
			temp.tips = v.Tips
			for k2, v2 in ipairs(v.Awards) do
				local item_cfg = ItemData.Instance:GetItemConfig(v2.id)
				if item_cfg then
					temp.tips = temp.tips  .. "\n" .. "{wordcolor;" .. string.sub(string.format("%06x", item_cfg.color), 1, 6)
					 .. ";" .. item_cfg.name .. "}" .. "X" .. v2.count
				end
				if (nil == v2.job and nil == v2.sex) or (v2.job and v2.sex and v2.job == job and v2.sex == sex) or
					(v2.job and v2.sex == nil and v2.job == job) or (v2.job == nil and v2.sex and v2.sex == sex) then
 
					local a_temp = {item_id = v2.id, num = v2.count, is_bind = v2.bind,}
					table.insert(temp.awards, a_temp)
				end
			end

			self.pray_tree_cfg_info_2.yb_pool_info[k] = temp
		end
	end
end

function OperateActivityData:GetPrayMoneyTreeCfgInfoTwo()
	return self.pray_tree_cfg_info_2 or {}
end

-- 获取全服购买数、奖金池元宝数
function OperateActivityData:GetPrayMoneyTreeTwoMyScore()
	return self.pray_tree_2_score or 0
end

function OperateActivityData:SetPrayMoneyTreeDataTwo(data)
	if not self.pray_tree_cfg_info_2 then return end
	-- self.all_server_buy_time = data.all_server_buy_time
	self.pray_tree_2_score = data.my_score
	for _, v in pairs(data.awar_pool_state_t) do
		if self.pray_tree_cfg_info_2.yb_pool_info[v.idx] then
			self.pray_tree_cfg_info_2.yb_pool_info[v.idx].state = v.state
		end
	end
end

function OperateActivityData:UpdatePrayMoneyTreeDataTwo(data)
	self.pray_tree_2_score = data.my_score
	for _, v in pairs(data.awar_pool_state_t) do
		if self.pray_tree_cfg_info_2.yb_pool_info[v.idx] then
			self.pray_tree_cfg_info_2.yb_pool_info[v.idx].state = v.state
		end
	end
	if data.oper_type == 1 then
		-- self.all_server_buy_time = data.all_server_buy_time
		self.pray_tree_cfg_info_2.get_awrds_info = data.buy_result_info
		-- self.pray_tree_cfg_info_2.extra_awars_info = data.extr_awar_info
	else
		-- if self.pray_tree_cfg_info_2.yb_pool_info[data.cur_awar_idx] then  
		-- 	self.pray_tree_cfg_info_2.yb_pool_info[data.cur_awar_idx].state = data.state
		-- end
	end
end

function OperateActivityData:GetPrayMoneyGetAwardsInfoTwo()
	return self.pray_tree_cfg_info_2.get_awrds_info or {}
end

function OperateActivityData:EmptyGetAwardsInfoTwo()
	self.pray_tree_cfg_info_2.get_awrds_info = {}
end

-- function OperateActivityData:GetPrayMoneyExtraAwardsInfo()
-- 	return self.pray_tree_cfg_info_2.extra_awars_info or {}
-- end

function OperateActivityData:IsPrayMoneyTreeRemindTwo()
	if not self.pray_tree_cfg_info_2 then return false end
	local is_remind = false
	for k, v in pairs(self.pray_tree_cfg_info_2.yb_pool_info) do
		if v.state == PRAY_MONEY_TREE_FETCH_STATE.CAN then
			is_remind = true
			break
		end
	end
	if not is_remind then
		local own_yb = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
		local cost_1, cost_2 = self.pray_tree_cfg_info_2.exchange[1].ExchangeCost, self.pray_tree_cfg_info_2.exchange[2].ExchangeCost
		is_remind = own_yb >= cost_1
	end
	return is_remind
end

function OperateActivityData:ClearPrayMoneyTreeData()
	self.pray_tree_cfg_info_2 = nil
	-- self.all_server_buy_time = 0
	self.pray_tree_2_score = 0
end

--------------------------------摇钱树2 end---------------------------------------

-- =============消费积分兑换返利券 begin------
function OperateActivityData:InitSpendscoreExchage()
	self.spendscore_exchange_item_data = {}
	self.spendscore_exchange_awards_info = {}
	self.own_exchange_spendscore_num = 0
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.SPENDSCORE_EXCHANGE_PAYBACK].config
	if not cfg then return end
	self.spendscore_exchange_item_data = cfg.itemList
	self.spendscore_exchange_awards_info = cfg.Awards
	for k, v in ipairs(cfg.Awards) do
		local data = self.spendscore_exchange_item_data[k]
		if data then
			data.restNum = data.limitNum
			data.needRechargeGold = v.needRechargeGold
			data.backRate = 30
			for k2, v2 in ipairs(v.precentBack) do
				if data.rateId == v2.rateId then
					data.backRate = v2.backRate
				end
				v2.restNum = 0
			end
			data.titleTxt = string.format(Language.OperateActivity.SpendscoreExchangePaybackTxts[3], data.needRechargeGold / 10, data.backRate.."%")
		end
	end
end

function OperateActivityData:SetSpendscoreExchageData(data)
	self.own_exchange_spendscore_num = data.spendscore
	if not self.spendscore_exchange_item_data then return end
	for i,v in ipairs(data.item_info) do
		local localdata = self.spendscore_exchange_item_data[i]
		if localdata then
			localdata.restNum = v
		end
	end
	for i,v in ipairs(self.spendscore_exchange_awards_info) do
		for i2,v2 in ipairs(v.precentBack) do
			v2.restNum = (data.payback_info[i] and data.payback_info[i][i2]) and data.payback_info[i][i2] or 0
		end
	end
end

function OperateActivityData:GetSpendscoreExchangeItemData()
	return self.spendscore_exchange_item_data
end

function OperateActivityData:GetOwnExchangeSpendscoreNum()
	return self.own_exchange_spendscore_num
end

function OperateActivityData:GetSpendscoreExchangeAwardsInfo()
	local awards_info = {}
	if self.spendscore_exchange_awards_info then
		for k, v in ipairs(self.spendscore_exchange_awards_info) do
			for k2, v2 in ipairs(v.precentBack) do
				local temp = {
					titleTxt = string.format(Language.OperateActivity.SpendscoreExchangePaybackTxts[1], v.needRechargeGold/10, v2.backRate.."%"),
					restNum = v2.restNum,
				}
				table.insert(awards_info, temp)
			end
		end
	end
	return awards_info
end

function OperateActivityData:ClearSpendscoreExchageData()
	self.spendscore_exchange_item_data = nil
	self.spendscore_exchange_awards_info = nil
end

function OperateActivityData:IsSpnedscoreExchangeNeedRemind()
	if self.spendscore_exchange_item_data then
		for k,v in pairs(self.spendscore_exchange_item_data) do
			if v.restNum > 0 and self.own_exchange_spendscore_num >= v.needScore then
				return true
			end
		end
	end
	return false
end

-- ==============消费积分兑换返利券 end------

-- =============新充值排行 begin------
function OperateActivityData:InitNewChargeRank()
	self.new_charge_rank_data = {my_rank = 0, cur_money = 0, my_fetch_state = 0}
	self.new_charge_rank_awards = {spec_des = "", special_awards = {}, rank_awards = {},}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK].config
	if not cfg then return end
	for k, v in ipairs(cfg.Awards) do
		local temp_cfg = {
							desc = v.desc,
							icon = v.icon,
							cond = v.cond,
							act_id = OPERATE_ACTIVITY_ID.NEW_CHARGE_RANK,
							awards = {},
						}
		temp_cfg.awards = ItemData.AwardsToItems(v.awards)
		table.insert(self.new_charge_rank_awards.rank_awards, temp_cfg)
	end

	self.new_charge_rank_awards.spec_des = cfg.exAward.desc
	self.new_charge_rank_awards.special_awards = ItemData.AwardsToItems(cfg.exAward.awards)
end

function OperateActivityData:GetNewChargeRankData()
	return self.new_charge_rank_data
end

function OperateActivityData:GetNewChargeRankAwards()
	return self.new_charge_rank_awards
end

function OperateActivityData:SetNewChargeRankData(data)
	if not self.new_charge_rank_data then return end
	self.new_charge_rank_data.my_rank = data.my_rank
	self.new_charge_rank_data.cur_money = data.cur_money
	self.new_charge_rank_data.my_fetch_state = data.my_fetch_state
end

function OperateActivityData:ClearNewChargeRankData()
	self.new_charge_rank_data = nil
	self.new_charge_rank_awards = nil
end

function OperateActivityData:IsNewChargeRankNeedRemind()
	if not self.new_charge_rank_data then return false end
	return self.new_charge_rank_data.my_fetch_state == 1
end

-- ==============新充值排行 end------

-- =============新消费排行 begin------
function OperateActivityData:InitNewSpendRank()
	self.new_spend_rank_data = {my_rank = 0, cur_money = 0, my_fetch_state = 0}
	self.new_spend_rank_awards = {spec_des = "", special_awards = {}, rank_awards = {},}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.NEW_SPEND_RANK].config
	if not cfg then return end
	for k, v in ipairs(cfg.Awards) do
		local temp_cfg = {
							desc = v.desc,
							icon = v.icon,
							cond = v.cond,
							act_id = OPERATE_ACTIVITY_ID.NEW_SPEND_RANK,
							awards = {},
						}
		temp_cfg.awards = ItemData.AwardsToItems(v.awards)
		table.insert(self.new_spend_rank_awards.rank_awards, temp_cfg)
	end

	self.new_spend_rank_awards.spec_des = cfg.exAward.desc
	self.new_spend_rank_awards.special_awards = ItemData.AwardsToItems(cfg.exAward.awards)
	
end

function OperateActivityData:GetNewSpendRankData()
	return self.new_spend_rank_data
end

function OperateActivityData:GetNewSpendRankAwards()
	return self.new_spend_rank_awards
end

function OperateActivityData:SetNewSpendRankData(data)
	if not self.new_spend_rank_data then return end
	self.new_spend_rank_data.my_rank = data.my_rank
	self.new_spend_rank_data.cur_money = data.cur_money
	self.new_spend_rank_data.my_fetch_state = data.my_fetch_state
end

function OperateActivityData:ClearNewSpendRankData()
	self.new_spend_rank_data = nil
	self.new_spend_rank_awards = nil
end

function OperateActivityData:IsNewSpendRankNeedRemind()
	if not self.new_spend_rank_data then return false end
	return self.new_spend_rank_data.my_fetch_state == 1
end

-- ==============新消费排行 end------

-- =============怪物来袭 begin------
function OperateActivityData:GetBossAtkIncomeData()
	local boss_atk_income_data = {}
	local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.BOSS_ATK_INCOME] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.BOSS_ATK_INCOME].config
	if not cfg then return end
	local boss_list_cfg = cfg.BossList
	for k, v in ipairs(boss_list_cfg) do
		local temp_cfg = {
							desc = v.desc,
							mob_time_list = v.mob_time_list,
							name = BossData.GetMosterCfg(v.boss[1].monsterId) and BossData.GetMosterCfg(v.boss[1].monsterId).name or "",
							awards = {},
						}
		temp_cfg.awards = ItemData.AwardsToItems(v.awards)
		table.insert(boss_atk_income_data, temp_cfg)
	end

	return boss_atk_income_data
end

function OperateActivityData:GetBossAtkIncomeRefreshTime(time_list)
	if not time_list then return "" end
	local time, time_str = nil, ""
	local now_time = ActivityData.GetNowShortTime()
	for k, v in ipairs(time_list) do
		if now_time < v then
			time = v
			break
		end
	end

	if not time then
		local _, remain_time = self:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.BOSS_ATK_INCOME)
		local is_last_day = remain_time <= 24 * 3600
		if not is_last_day then
			time_str = Language.OperateActivity.BossAtkIncomeRefrTime[1] .. 
				string.format(Language.OperateActivity.BossAtkIncomeRefrTime[3], TimeUtil.FormatSecond2Str(time_list[1], 2))
		else
			time_str = Language.OperateActivity.BossAtkIncomeRefrTime[1] .. Language.OperateActivity.BossAtkIncomeRefrTime[4]
		end
	else
		time_str = Language.OperateActivity.BossAtkIncomeRefrTime[1] .. 
			string.format(Language.OperateActivity.BossAtkIncomeRefrTime[2], TimeUtil.FormatSecond2Str(time, 2))
	end

	return time_str

end

function OperateActivityData:ClearBossAtkIncome()

end
--======================怪物来袭end=======================

--==========================世界杯BOSS begin==============================
function OperateActivityData:SetWorldCupBossData(data)
	self.world_cup_boss_scene_info = {}
	local scene_config = ConfigManager.Instance:GetSceneConfig(data.scene_id)
	self.world_cup_boss_scene_info.pos_x = data.pos_x
	self.world_cup_boss_scene_info.pos_y = data.pos_y
	if scene_config then
		self.world_cup_boss_scene_info.name = scene_config.name
	end
	if not self.world_cup_boss_items then
		self.world_cup_boss_items = {}
		local cfg = self.operate_acts_configs[OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS] and self.operate_acts_configs[OPERATE_ACTIVITY_ID.WORLD_CUP_BOSS].config
		if not cfg then return end
		for k, v in pairs(cfg.itemList) do
			local item_info = data.items_info[k]
			local award = ItemData.AwardsToItems(v.awards)
			local tmp = {
							idx = k,
							consume = v.consumes[1],
							award = award[1],
							rest_cnt = item_info or 3,
						}
			self.world_cup_boss_items[k] = tmp
		end
	else
		for k, v in pairs(self.world_cup_boss_items) do
			local item_info = data.items_info[v.idx]
			if items_info then
				v.rest_cnt = item_info
			end
		end
	end
end

function OperateActivityData:UpdateWorldCupBossData(data)
	if self.world_cup_boss_items[data.idx] then
		self.world_cup_boss_items[data.idx].rest_cnt = data.rest_cnt
	end
end


function OperateActivityData:GetWorldCupBossData()
	return self.world_cup_boss_items
end

function OperateActivityData:GetWorldCupBossRefrSceneInfo()
	return self.world_cup_boss_scene_info
end

function OperateActivityData:IsWorldCupBossNeedRemind()
	if not self.world_cup_boss_items then return false end
	for k, v in pairs(self.world_cup_boss_items) do
		if v.rest_cnt > 0 then
			return true
		end
	end
	return false
end

--==========================世界杯BOSS end==============================