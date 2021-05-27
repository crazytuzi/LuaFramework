-- 投资计划Data
InvestPlanData = InvestPlanData or BaseClass()

-- 投资计划领取状态
InvestPlanFetchState = {
	Not_Fetch = 0,		-- 未领取
	Fetched = 1,		-- 今日已领取
}

function InvestPlanData:__init()
	if InvestPlanData.Instance then
		ErrorLog("[InvestPlanData] Attemp to create a singleton twice !")
	end
	
	InvestPlanData.Instance = self
	self:InitAwardData()
	self.invest_plan_data = {rest_day = 0, fetch_state = 0}
end

function InvestPlanData:__delete()
	self.award_cfg = nil
	InvestPlanData.Instance = nil
end

function InvestPlanData:InitAwardData()
	self.award_data = {}
	for k, v in pairs(InvestPlanCfg.Awards) do
		local temp = {item_id = v.id, num = v.count, is_bind = v.bind}
		table.insert(self.award_data, temp)
	end
end

function InvestPlanData:GetAwardData()
	return self.award_data
end

function InvestPlanData:SetInvestPlanData(protocol)
	self.invest_plan_data.rest_day = protocol.rest_day
	self.invest_plan_data.fetch_state = protocol.fetch_state
end

function InvestPlanData:GetInvestPlanData()
	return self.invest_plan_data
end

function InvestPlanData.GetInvestNeedMoney()
	return InvestPlanCfg.MoneyNum or 0
end

function InvestPlanData.GetInvestNeedIngot()
	return InvestPlanCfg.Consumes and InvestPlanCfg.Consumes[1].count or 0
end

function InvestPlanData:GetRemindNum()
	local role_circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local role_lv = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if role_circle < InvestPlanCfg.OpenLevel[1] or role_lv < InvestPlanCfg.OpenLevel[2] then return 0 end

	local remind_num = 0
	local remind_num = self.invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch and 1 or 0
	if self.invest_plan_data.rest_day <= 0 then
		remind_num = 2			-- 展示光圈特效
	elseif self.invest_plan_data.fetch_state == InvestPlanFetchState.Not_Fetch then
		remind_num = 1			-- 红点提醒
	end
	return remind_num
end