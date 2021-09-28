GoldMemberData = GoldMemberData or BaseClass()

function GoldMemberData:__init()
	if GoldMemberData.Instance then
		print_error("[GoldMemberData] Attemp to create a singleton twice !")
	end
	GoldMemberData.Instance = self
	self.gold_vip_info = {}
	self.goldvip_cfg = ConfigManager.Instance:GetAutoConfig("goldvip_auto")
	self.is_show_repdt = true

	self.gold_vip_active_zero_timestamp = 0

	RemindManager.Instance:Register(RemindName.GoldMember, BindTool.Bind(self.GetRemind, self))
end

function GoldMemberData:__delete()
	GoldMemberData.Instance = nil
	RemindManager.Instance:UnRegister(RemindName.GoldMember)
end

function GoldMemberData:GetGoldCfg()
	 local active_cfg = ConfigManager.Instance:GetAutoConfig("goldvip_auto").goldvip_active
	 return active_cfg
end

function GoldMemberData:SetGuldMeMberInfo(protocol)
	self.gold_vip_info.gold_vip_shop_counts_list = protocol.gold_vip_shop_counts_list
	self.gold_vip_info.gold_vip_active_timestamp = protocol.gold_vip_active_timestamp								-- 激活时间戳
	self.gold_vip_info.day_score = protocol.day_score																-- 每日积分每日积分
	self.gold_vip_info.shop_active_grade_flag = protocol.shop_active_grade_flag										-- 商店激活档次标记
	self.gold_vip_info.can_fetch_return_reward = protocol.can_fetch_return_reward									-- 能否领取返还奖励
	self.gold_vip_info.is_not_first_fetch_return_reward = protocol.is_not_first_fetch_return_reward					-- 是否不是第一次领取返还奖励

	self.gold_vip_active_zero_timestamp = TimeUtil.NowDayTimeStart(self.gold_vip_info.gold_vip_active_timestamp)	-- 激活时间戳（零点）
end

function GoldMemberData:GetGoldVipInfo()
	return self.gold_vip_info
end

--单次激活持续时间
function GoldMemberData:GetActivitionTime()
	local activity_auto = ConfigManager.Instance:GetAutoConfig("goldvip_auto").goldvip_active

	return activity_auto[1].continue_days or 0
end

-- 获取黄金会员的有效天数
function GoldMemberData:GetGoldMemberValidDay()
	if self.gold_vip_info and next(self.gold_vip_info) ~= nil then
		local temp_time = math.ceil(TimeCtrl.Instance:GetServerTime() - self.gold_vip_active_zero_timestamp)
		local temp_day_tbl = TimeUtil.Format2TableDHM(temp_time)
		return self:GetActivitionTime() - temp_day_tbl.day
	end
	return 0
end

--判断是否已领取黄金会员奖励
function GoldMemberData:IsGetReward()
	if nil == next(self.gold_vip_info) then
		return false
	end

	local valid_day = self:GetGoldMemberValidDay()					--距离可领取时间
	if self.gold_vip_info.gold_vip_active_timestamp > 0 and valid_day <= 0 and self.gold_vip_info.can_fetch_return_reward == 0 then
		return true
	end

	return false
end

-- 激活等级限制
function GoldMemberData:GetActivitionLevel()
	local activity_auto = ConfigManager.Instance:GetAutoConfig("goldvip_auto").goldvip_active
	return activity_auto[1].need_level or 0
end


-- 获取VIP时间戳
function GoldMemberData:GetVIPSurplusTime()
	if self.gold_vip_info and next(self.gold_vip_info) ~= nil then
		return self.gold_vip_info.gold_vip_active_timestamp
	end
	return 0
end

-- 获取每日领取标记
function GoldMemberData:GetDailyRewardMark()
	if self.gold_vip_info and next(self.gold_vip_info) ~= nil then
		if self.gold_vip_info.fetch_reward_flag > 0 then
			return true
		end
	end
	return false
end

-- 获取商店信息
function GoldMemberData:GetShopInfo()
	local vip_shop_auto = ConfigManager.Instance:GetAutoConfig("goldvip_auto").goldvip_shop

	return vip_shop_auto or {}
end

--获取每日积分
function GoldMemberData:GetDayScore()
	if self.gold_vip_info and next(self.gold_vip_info) ~= nil then
		return self.gold_vip_info.day_score
	end
	return 0
end

-- 积分是否可用
function GoldMemberData:CheckScoreIsOk()
	local temp_data = self:GetShopInfo()
	if temp_data and next(temp_data) ~= nil then
		for i,v in ipairs(temp_data) do
			local buy_count = self:GetShopIndexCount(i) or 0
			local cur_score, next_score = self:GetExchangeScoreBySeq(v.seq, buy_count)
			local price_multile = cur_score and cur_score.price_multile or 1
			if self:CheckIFOpenSeal(i - 1) and self:GetDayScore() >= price_multile * v.consume_val and buy_count < v.limit_times and self.gold_vip_info.gold_vip_active_timestamp > 0 then
				return true
			end
		end
	end
	return false
end

--判断是否有奖励领取
function GoldMemberData:ChekIfReward()
	if self:GetVIPSurplusTime() > 0 then
		if self:GetDailyRewardMark() == false or self:CheckScoreIsOk() then
			return true
		end
	end
	return false
end

--判断是否开启封印
function GoldMemberData:CheckIFOpenSeal(index)
	if index == 0 then
		return true
	end
	if self.gold_vip_info and next(self.gold_vip_info) ~= nil then
		return true
	end
	return false
end

--获取商店兑换次数
function GoldMemberData:GetShopIndexCount(index)
	if self.gold_vip_info and next(self.gold_vip_info) ~= nil then
		return self.gold_vip_info.gold_vip_shop_counts_list[index]
	end
	return nil
end

function GoldMemberData:GetExchangeScoreBySeq(seq, exchange_integral)
	local cur_score = nil
	local next_score = nil
	local cfg = ConfigManager.Instance:GetAutoConfig("goldvip_auto").multiple_cfg
	local grade_index = 0

	for i,v in ipairs(cfg) do
		if seq == v.shop_seq and exchange_integral < v.times_max then
			grade_index = i
			cur_score = v
			break
		end
	end
	if cfg[grade_index + 1] and cfg[grade_index + 1].shop_seq == seq then
		next_score = cfg[grade_index + 1]
	end
	return cur_score, next_score
end

-- 打开一次后设为false
function GoldMemberData:SetIsShowRepdt()
	RemindManager.Instance:SetTodayDoFlag(RemindName.GoldMember)
end

function GoldMemberData:GetMemberRepdtIsShow()
	if self.gold_vip_info.can_fetch_return_reward == 1 then
		return true
	end
	if not RemindManager.Instance:RemindToday(RemindName.GoldMember) and self:GetVIPSurplusTime() <= 0 then
		return true
	end
	return false
end

function GoldMemberData:GetRemind()
	return self:GetMemberRepdtIsShow() and 1 or 0
end