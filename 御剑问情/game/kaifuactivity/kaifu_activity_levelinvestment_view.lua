OpenActLevelInvestment = OpenActLevelInvestment or BaseClass(BaseRender)

function OpenActLevelInvestment:__init(instance)
	self:ListenEvent("ClickInvestment", BindTool.Bind(self.OnClickInvestment,self))
	self:ListenEvent("ClickLevelInvestTip", BindTool.Bind(self.OnClickLevelInvestTip,self))
	self.cost_list = {}
	for i = 1, 3 do
		self.cost_list[i] = self:FindObj("ChangeCost" .. i)
		self.cost_list[i].toggle:AddValueChangedListener(BindTool.Bind(self.ChangeInvestment,self, i))
		self["cost_" .. i] = self:FindVariable("cost_" .. i)
	end

	self.has_gold = self:FindVariable("HasGold")
	self.has_bind_gold = self:FindVariable("HasBindGold")
	self.dec1 = self:FindVariable("Dec1")
	self.dec2 = self:FindVariable("Dec2")
	self.can_invest = self:FindVariable("CanInvest")
	self.toggle_invest = self:FindVariable("ToggleInvest")
	self.select_gold = self:FindObj("SelectGold").dropdown
	local options = self.select_gold.options
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	options[0].text = other_cfg.plan_0_price
	options[1].text = other_cfg.plan_1_price
	options[2].text = other_cfg.plan_2_price
	self.cost_1:SetValue(other_cfg.plan_0_price)
	self.cost_2:SetValue(other_cfg.plan_1_price)
	self.cost_3:SetValue(other_cfg.plan_2_price)
	self.invest_limit = self:FindVariable("Invest_Limit")
	local level_text = PlayerData.GetLevelString(InvestData.Instance:GetMaxLevel())
	self.invest_limit:SetValue(level_text)
	self.is_show = false
	self.plan_type = 0
	self:InitScroller()
	local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
	local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	if cur_day > -1 then
		UnityEngine.PlayerPrefs.SetInt(main_role_id .. "LevelInvest", cur_day)
		RemindManager.Instance:Fire(RemindName.KaiFu)
	end
end

function OpenActLevelInvestment:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	self.cost_list = {}
	for i = 1, 3 do
		self["cost_" .. i] = nil
	end
	self.has_gold = nil
	self.has_bind_gold = nil
	self.dec1 = nil
	self.dec2 = nil
	self.can_invest = nil
	self.select_gold = nil
	self.invest_limit = nil
	self.scroller = nil
	self.is_show = false
	self.toggle_invest = nil
end

function OpenActLevelInvestment:InitScroller()
	self.cell_list = {}
	self.scroller = self:FindObj("List")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #InvestData.Instance:GetPlanAuto(self.plan_type)
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  LevelInvestCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local data = InvestData.Instance:GetPlanAuto(self.plan_type)
		local cell_data = data[data_index]
		target_cell:SetInfo(self.plan_type, cell_data.seq)
		target_cell:SetData(cell_data)
	end
end

function OpenActLevelInvestment:ChangeInvestment(index, isOn)
	if isOn and self.is_show then
		self.plan_type = index - 1
		self:Flush()
	end
end

function OpenActLevelInvestment:OpenCallBack()
	local cur_plan = InvestData.Instance:GetNormalActivePlan()
	if cur_plan < 0 then
		self.select_gold.value = 2
	else
		self.select_gold.value = cur_plan
	end
	self.plan_type = self.select_gold.value
	self.is_show = true
	self:Flush()
	self:InitToggle(self.plan_type + 1)
end

function OpenActLevelInvestment:InitToggle(num)
	local index = num or 1
	for k, v in pairs(self.cost_list) do
		v.toggle.isOn = (k == index)
	end
end

function OpenActLevelInvestment:OnClickInvestment()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	local invest_price = other_cfg["plan_" .. self.plan_type .. "_price"] or 0
	local extrace_price = other_cfg["plan_" .. highest_plan .. "_price"] or 0
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
	local func = function ()
		if role_gold >= invest_price or (highest_plan > -1 and role_gold >= invest_price - extrace_price) then
			InvestCtrl.Instance:SendTouzijihuaActive(self.plan_type)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	local desc = ""
	if highest_plan < 0 then
		desc = string.format(Language.Common.InvestTips, invest_price)
	else
		desc = string.format(Language.Common.ExtraceInvestTips, invest_price - extrace_price)
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, desc)
end

function OpenActLevelInvestment:OnClickLevelInvestTip()
	TipsCtrl.Instance:ShowHelpTipView(156)
end

function OpenActLevelInvestment:OnFlush()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	local gold = CommonDataManager.ConverMoney(PlayerData.Instance.role_vo.gold)
	local bind_gold = CommonDataManager.ConverMoney(PlayerData.Instance.role_vo.bind_gold)
	self.has_gold:SetValue(gold)
	self.has_bind_gold:SetValue(bind_gold)

	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	self.can_invest:SetValue(highest_plan < self.plan_type and InvestData.Instance:CanInvestLevel(self.plan_type))
	self.toggle_invest:SetValue(highest_plan < self.plan_type
		and (InvestData.Instance:CanInvestLevel(0) or InvestData.Instance:CanInvestLevel(1) or InvestData.Instance:CanInvestLevel(2)))

	local cur_plan = InvestData.Instance:GetActiveHighestPlan()
	self.dec1:SetValue(cur_plan < 0 and Language.Investment.CurPlan[1] or string.format(Language.Investment.CurPlan[2], other_cfg["plan_" .. cur_plan .. "_price"] or 0))
	self.dec2:SetValue(string.format(Language.Investment.CurPlanCost, other_cfg["plan_" .. self.plan_type .. "_price"] or 0))
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------------------------------------------------
--滚动条格子

LevelInvestCell = LevelInvestCell or BaseClass(BaseCell)

function LevelInvestCell:__init()
	self.task_dec = self:FindVariable("Dec")
	self.reward_btn_enble = self:FindVariable("BtnEnble")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.cost = self:FindVariable("Cost")
	self.gold = self:FindVariable("Gold")
	self.has_get_gold = self:FindVariable("has_get_gold")

	self:ListenEvent("Reward",
		BindTool.Bind(self.ClickReward, self))
	self.plan_gold = 0
	self.now_index = 0

end

function LevelInvestCell:__delete()
	self.task_dec = nil
	self.reward_btn_enble = nil
	self.reward_btn_txt = nil
	self.cost = nil
	self.gold = nil
	self.has_get_gold = nil
end

function LevelInvestCell:ClickReward()
	if self.data == nil then return end
	InvestCtrl.Instance:SendFetchTouZiJiHuaReward(self.data.type, self.data.seq)
end

function LevelInvestCell:SetInfo(plan_type, data_index)
	self.plan_gold = plan_type or 0
	self.now_index = data_index or 0
end

function LevelInvestCell:OnFlush()
	local other_cfg = ConfigManager.Instance:GetAutoConfig("touzijihua_auto").other[1]
	local plan_cost = other_cfg["plan_" .. self.data.type .. "_price"] or 0
	local is_bind = (self.data.reward_gold == nil) or (self.data.reward_gold == 0)
	local str = is_bind and Language.Investment.NormalPlanRewardDec or Language.Investment.NormalPlanRewardDec2
	local gold_cost = is_bind and self.data.reward_gold_bind or self.data.reward_gold or 0
	local dec = self.data.seq == 0 and str[1]
	or string.format(str[2], PlayerData.GetLevelString(self.data.need_level))
	self.task_dec:SetValue(dec)

	local has_reward = InvestData.Instance:GetNormalInvestHasReward(self.data.type, self.data.seq)
	local gold = InvestData.Instance:GetHasRewardGoldByTypeAndSeq(self.data.type, self.data.seq)

	local highest_plan = InvestData.Instance:GetActiveHighestPlan()
	local cur_plan = InvestData.Instance:GetNormalActivePlan()
	local level = PlayerData.Instance.role_vo.level
	self.reward_btn_enble:SetValue(highest_plan == self.data.type and self.data.need_level <= level and not has_reward)
	self.cost:SetValue(gold_cost - gold == 0 and gold_cost or gold_cost - gold)
	self.reward_btn_txt:SetValue(has_reward and Language.Common.YiLingQu or Language.Common.LingQu)
	local get_all_gold = InvestData.Instance:GetAllGold(self.plan_gold, self.now_index)
	self.has_get_gold:SetValue(get_all_gold)

	local gold_img = is_bind and "bind_diamon" or "diamon"
	if self.gold then
		self.gold:SetAsset(ResPath.GetImages(gold_img))
	end
end