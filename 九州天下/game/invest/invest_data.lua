TOUZIJIHUA_OPERATE =
{
	NEW_TOUZIJIHUA_OPERATE_BUY = 0,				-- 购买
	NEW_TOUZIJIHUA_OPERATE_FETCH = 1,			-- 领取普通奖励
	NEW_TOUZIJIHUA_OPERATE_FIRST = 2,			-- 获取月卡立返
	NEW_TOUZIJIHUA_OPERATE_VIP_FETCH = 3,		-- 领取vip奖励
}
INVEST_TOTAL_DAYS = 7

InvestData = InvestData or BaseClass()

InvestData.FIRST_LEVEL_REMIND = false		--是否有过第一次提醒(等级投资)
InvestData.FIRST_MONTH_REMIND = true		--是否有过第一次提醒(月卡投资)
InvestData.FIRST_CHONGZHI_REMIND = false    --是否有过第一次提醒(充值)
function InvestData:__init()
	if InvestData.Instance then
		print_error("[InvestData] Attemp to create a singleton twice !")
	end
	InvestData.Instance = self
	self.invest_info = {}
	self.invest_is_opened = false --投资面板是否打开过（本次上线）
	self.plan_cfg = {}
	self.max_level_t = {}
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").plan) do
		self.plan_cfg[v.type] = self.plan_cfg[v.type] or {}
		self.plan_cfg[v.type][v.seq + 1] = v
		if self.max_level_t[v.type] == nil or self.max_level_t[v.type] < v.need_level then
			self.max_level_t[v.type] = v.need_level
		end
	end
	self.nec_plan_cfg = {}
	self.nec_plan_cfg[1] = {
		day_index = -1,
		reward_gold_bind = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1].new_plan_price
	}
	for i,v in ipairs(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan) do
		table.insert(self.nec_plan_cfg, v)
	end
	RemindManager.Instance:Register(RemindName.Invest, BindTool.Bind(self.GetInvestRemind, self))
end

function InvestData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Invest)

	InvestData.Instance = nil
end
function InvestData:SetIsOpenStatus(is_open)
	self.invest_is_opened = is_open
end

function InvestData:GetOtherAuto()
	return ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other
end

function InvestData:CanInvestLevel(plan_type)
	return self.max_level_t[plan_type] == nil or self.max_level_t[plan_type] >= PlayerData.Instance.role_vo.level
end

function InvestData:GetMaxLevel()
	return self.max_level_t[1]
end

function InvestData:GetNewPlanAuto()
	return self.nec_plan_cfg
end

function InvestData:GetPlanAuto(plan_type)
	return self.plan_cfg[plan_type] or {}
end

function InvestData:GetRewardInfo(day_index)
	local cfg = self:GetNewPlanAuto()
	for k,v in pairs(cfg) do
		if v.day_index == day_index then
			return v
		end
	end
end

local a_has_reward, b_has_reward = false, false
local a_can_reward, b_can_reward = false, false
local off_a, off_b = 1000, 1000
function InvestData.SortInvestDataList(a, b)
	off_a = 1000
	off_b = 1000
	if a.need_level ~= nil then
		a_has_reward = InvestData.Instance:GetNormalInvestHasReward(a.type, a.seq)
		b_has_reward = InvestData.Instance:GetNormalInvestHasReward(b.type, b.seq)
	else
		a_has_reward = InvestData.Instance:GetMonthCardHasReward(a.day_index)
		b_has_reward = InvestData.Instance:GetMonthCardHasReward(b.day_index)
	end
	if not a_has_reward and b_has_reward then
		off_a = off_a + 10
	elseif a_has_reward and not b_has_reward then
		off_b = off_b + 10
	else
		if a.need_level ~= nil then
			a_can_reward = InvestData.Instance:GetNormalInvestCanReward(a)
			b_can_reward = InvestData.Instance:GetNormalInvestCanReward(b)
		else
			a_can_reward = InvestData.Instance:GetMonthCardCanReward(a.day_index)
			b_can_reward = InvestData.Instance:GetMonthCardCanReward(b.day_index)
		end
		if a_can_reward and not b_can_reward then
			off_a = off_a + 100
		elseif not a_can_reward and b_can_reward then
			off_b = off_b + 100
		end
	end
	if a.need_level ~= nil then
		if a.need_level < b.need_level then
			off_a = off_a + 1
		elseif a.need_level > b.need_level then
			off_b = off_b + 1
		end
	else
		if a.day_index < b.day_index then
			off_a = off_a + 1
		elseif a.day_index > b.day_index then
			off_b = off_b + 1
		end
	end

	return off_a > off_b
end

function InvestData:SortInvestData()
	for k,v in pairs(self.plan_cfg) do
		table.sort(v, InvestData.SortInvestDataList)
	end
	table.sort(self.nec_plan_cfg, InvestData.SortInvestDataList)
end

--获取投资计划是否有奖励可以领取标记（购买起到当天）
function InvestData:GetInvestAwardFlag()
	local day = 1
	local reward_flag = false
	-- local vip_reward_flag = false
	if nil == self.invest_info.buy_time then
		return false
	end
	if 0 ~= self.invest_info.buy_time then
		day = math.floor(TimeCtrl.Instance:GetDayIndex(self.invest_info.buy_time, TimeCtrl.Instance:GetServerTime()) + 1)
		if day > 7 then
			day = 7
		end
	end
	for i=1 ,day do
		if self.invest_info.reward_flag_list[33 - i] == 0 then
			reward_flag = true
		end
		-- if self.invest_info.vip_reward_flag_list[33 - i] == 0 then
		-- 	vip_reward_flag = true
		-- end
	end
	-- local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level

	if reward_flag then --or (vip_reward_flag and vip_level >= 6) then
		return true
	end
	return false
end

--获取红点标记
function InvestData:GetInvestRedPointStatus()
	return self:GetNormalInvestRemind() + self:GetMonthInvestRemind() > 0--投资过
end

--获取红点标记
function InvestData:GetInvestRemind()
	return self:GetNormalInvestRemind() + self:GetMonthInvestRemind()
end

--7天奖励是否全部领取
function InvestData:GetSevenDayAwardFlag()
	for i = 1, 7 do
		if self.invest_info.reward_flag_list[33 - i] == 0 then
			return false
		end
	end
	return true
end

--vip奖励是否全部领取
function InvestData:GetVipAwardFlag()
	for i = 1, 7 do
		if self.invest_info.vip_reward_flag_list[33 - i] == 0 then
			return false
		end
	end
	return true
end

--判断是否关闭投资计划
function InvestData:IsOpenInvestButton()
	return true
end

function InvestData:OnSCTouZiJiHuaInfo(protocol)
	self.invest_info.touzi_active_flag = protocol.touzi_active_flag							-- 投资计划激活标记 0 未激活，1等级激活，2登陆激活 ，3两个都已经激活
	self.invest_info.plan_level_fetch_flag = protocol.plan_level_fetch_flag 				-- 等级投资已领取标记
	self.invest_info.plan_level_can_fetch_flag = protocol.plan_level_can_fetch_flag 		-- 等级投资可领取标记
	self.invest_info.plan_login_fetch_flag = protocol.plan_login_fetch_flag 				-- 登录投资已领取标记
	self.invest_info.plan_login_can_fetch_flag = protocol.plan_login_can_fetch_flag 		-- 登录投资可领取标记
	self.invest_info.plan_login_buy_timestamp = protocol.plan_login_buy_timestamp			-- 登陆投资购买时间

	self:SortInvestData()
end

function InvestData:GetNormalActivePlan()
	local plan = -1
	for i = 0, 2 do
		if self.invest_info["active_plan_" .. i] == 1 then
			plan = i
		end
	end
	return plan
end

function InvestData:GetInvestInfo()
	return self.invest_info
end

function InvestData:GetInvestPrice()
	return self:GetOtherAuto()[1].new_plan_price
end

function InvestData:GetInvestRewardList(day_index)
	local cfg = self:GetRewardInfo(day_index)
	local new_list = {}
	for i=0,1 do
		new_list[#new_list + 1] = cfg.reward_item[i]
	end
	for i=0,1 do
		new_list[#new_list + 1] = cfg.vip_reward_item[i]
	end
	return new_list
end

function InvestData:GetRewardState(day_text)
	local info = self:GetInvestInfo()
	local new_list = {}
	if info.reward_flag_list[32 - day_text] == 0 then
		new_list[#new_list + 1] = false
	else
		new_list[#new_list + 1] = true
	end
	return new_list
end

function InvestData:GetMonthCardHasReward(day_index)
	if day_index < 0 then
		return self.invest_info.new_plan_first_reward_flag == 1
	end
	return bit:_and(1, bit:_rshift(self.invest_info.reward_gold_bind_flag or 0, day_index)) > 0
end

function InvestData:GetMonthCardAllReward()
	return self.invest_info.new_plan_first_reward_flag == 1 and self.invest_info.reward_gold_bind_flag == 1073741823
end

function InvestData:GetMonthCardCanReward(day_index)
	if self.invest_info.buy_time == nil or self.invest_info.buy_time == 0 then
		return false
	end
	local day = TimeCtrl.Instance:GetDayIndex(self.invest_info.buy_time, TimeCtrl.Instance:GetServerTime())
	return day_index <= math.max(day, 0)
end

function InvestData:GetNormalInvestHasReward(plan_type, seq)
	local flag = self.invest_info["plan_" .. plan_type .. "_reward_flag"] or 0
	return bit:_and(1, bit:_rshift(flag, seq)) > 0
end

function InvestData:GetNormalInvestCanReward(data)
	return data.need_level <= PlayerData.Instance.role_vo.level
end

-- 投资计划可领取标记
function InvestData:GetNormalLevelHasReward(touzi_type,seq)
	local flag = 0
	if touzi_type == TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL then
		flag = self.invest_info.plan_level_can_fetch_flag or 0
	elseif touzi_type == TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN then
		flag = self.invest_info.plan_login_can_fetch_flag or 0
	end
	return bit:_and(1, bit:_rshift(flag, seq))
end

-- 投资计划已领取标记
function InvestData:GetNormalLevelFlag(touzi_type,seq)
	local flag = 0
	if touzi_type == TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL then
		flag = self.invest_info.plan_level_fetch_flag or 0
	elseif touzi_type == TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN then
		flag = self.invest_info.plan_login_fetch_flag or 0
	end
	return bit:_and(1, bit:_rshift(flag, seq))
end

function InvestData:GetChongZhiInvestRemind()
	return InvestData.FIRST_CHONGZHI_REMIND and 0 or 1
end

function InvestData:GetNormalInvestRemind()
	if not OpenFunData.Instance:CheckIsHide("investview") then
		return 0
	end
	local plan_type = self:GetNormalActivePlan()
	local cfg = self.plan_cfg[plan_type]
	if cfg == nil then
		if not self:CanInvestLevel(1) then
			return 0
		end
		return InvestData.FIRST_LEVEL_REMIND and 0 or 1
	end
	local num = 0
	local level = PlayerData.Instance.role_vo.level
	for k,v in pairs(cfg) do
		if v.need_level <= level and not self:GetNormalInvestHasReward(plan_type, v.seq) then
			num = num + 1
		end
	end
	return num
end

function InvestData:GetMonthInvestRemind()
	if self.invest_info.buy_time == nil or self.invest_info.buy_time == 0 or self:GetMonthCardAllReward() and OpenFunData.Instance:CheckIsHide("investview") then
		return InvestData.FIRST_MONTH_REMIND and 0 or 1
	end
	local num = 0
	for k,v in pairs(ConfigManager.Instance:GetAutoConfig("touzijihua_auto").new_plan) do
		if self:GetMonthCardCanReward(v.day_index) and not self:GetMonthCardHasReward(v.day_index) and OpenFunData.Instance:CheckIsHide("investview") then
			num = num + 1
		end
	end
	return num
end

function InvestData:GetActiveHighestPlan()
	return self.invest_info.active_highest_plan or -1
end

function InvestData:GetHasRewardGoldByTypeAndSeq(invest_type, seq)
	local cur_type, cur_seq, cur_gold = 0, 0, 0
	local flag = false
	for i = 0, invest_type do
		local has_reward = self:GetNormalInvestHasReward(i, seq)
		local highest_plan = self:GetActiveHighestPlan()
		if has_reward and highest_plan >= invest_type then
			flag = true
			cur_type = i
			cur_seq = seq
		end
	end

	if flag then
		for k, v in pairs(self.plan_cfg[cur_type]) do
			if v.seq == cur_seq then
				cur_gold = v.reward_gold_bind
			end
		end
	end

	return cur_gold
end