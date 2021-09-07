GoldMemberData = GoldMemberData or BaseClass()

function GoldMemberData:__init()
	if GoldMemberData.Instance then
		print_error("[GoldMemberData] Attemp to create a singleton twice !")
	end
	GoldMemberData.Instance = self
	self.gold_vip_info = {}
	self.goldvip_cfg = ConfigManager.Instance:GetAutoConfig("goldvip_auto")
	self.is_show_repdt = true
	self.shop_repdt = true

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
	self.gold_vip_info.gold_vip_active_timestamp = protocol.gold_vip_active_timestamp				-- 激活时间戳
	self.gold_vip_info.day_score = protocol.day_score												-- 每日积分每日积分
	self.gold_vip_info.shop_active_grade_flag = protocol.shop_active_grade_flag						-- 商店激活档次标记
	self.gold_vip_info.can_fetch_return_reward = protocol.can_fetch_return_reward					-- 能否领取返还奖励
	self.gold_vip_info.is_not_first_fetch_return_reward = protocol.is_not_first_fetch_return_reward	-- 是否不是第一次领取返还奖励
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
		local temp_time = math.ceil(TimeCtrl.Instance:GetServerTime() - self.gold_vip_info.gold_vip_active_timestamp)
		return self:GetActivitionTime() - (temp_time/ (60 * 60 * 24))
	end
	return 0
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
	return self.shop_repdt -- 点过一次不在显示
	-- local temp_data = self:GetShopInfo()
	-- if temp_data and next(temp_data) ~= nil then
	-- 	for i,v in ipairs(temp_data) do
	-- 		local buy_count = self:GetShopIndexCount(i) or 0
	-- 		if self:CheckIFOpenSeal(i - 1) and self:GetDayScore() >= v.consume_val and buy_count < v.limit_times then
	-- 			return true
	-- 		end
	-- 	end
	-- end

	-- -- if ClickOnceRemindList[RemindName.GoldMember] and ClickOnceRemindList[RemindName.GoldMember] == 1 then
	-- -- 	return true
	-- -- end
	-- return false
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
		if self.gold_vip_info.shop_active_grade_flag + 1 >= index then
			return true
		end
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

-- 打开一次后设为false
function GoldMemberData:SetIsShowRepdt()
	self.is_show_repdt = false
end

-- 打开一次后设为false
function GoldMemberData:SetIsShowShopRepdt()
	self.shop_repdt = false
end

function GoldMemberData:GetMemberRepdtIsShow()
	if self.gold_vip_info.can_fetch_return_reward == 1 then
		return true
	end

	if self.is_show_repdt == true or self.shop_repdt == true then
		return true
	end

	-- if self:GetVIPSurplusTime() <= 0 then
	-- 	return true
	-- end
	if self:CheckScoreIsOk() then
		return true
	end
	return false
end

function GoldMemberData:GetRemind()
	GoldMemberCtrl.Instance:OnFlushRemind()
	if not OpenFunData.Instance:CheckIsHide("gold_member") then
		return 0
	end
	return self:GetMemberRepdtIsShow() and 1 or 0
end