MonthCardInvestmentView = MonthCardInvestmentView or BaseClass(BaseRender)

function MonthCardInvestmentView:__init(instance)
	self:ListenEvent("ClickInvestment", BindTool.Bind(self.OnClickInvestment,self))
	self:ListenEvent("ClickMonthCardInvest", BindTool.Bind(self.OnClickMonthCardInvest,self))

	self.has_gold = self:FindVariable("HasGold")
	self.has_bind_gold = self:FindVariable("HasBindGold")
	self.can_invest = self:FindVariable("CanInvest")
	self:InitScroller()
end


function MonthCardInvestmentView:__delete()
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function MonthCardInvestmentView:InitScroller()
	self.cell_list = {}
	local data = InvestData.Instance:GetNewPlanAuto()
	self.scroller = self:FindObj("List")
	local delegate = self.scroller.list_simple_delegate
	-- 生成数量
	delegate.NumberOfCellsDel = function()
		return #data
	end
	-- 格子刷新
	delegate.CellRefreshDel = function(cell, data_index, cell_index)
		data_index = data_index + 1

		local target_cell = self.cell_list[cell]

		if nil == target_cell then
			self.cell_list[cell] =  MonthCardInvestmentCell.New(cell.gameObject)
			target_cell = self.cell_list[cell]
			target_cell.mother_view = self
		end
		local cell_data = data[data_index]
		target_cell:SetData(cell_data)
	end
end

function MonthCardInvestmentView:OnClickInvestment()
	local invest_price = InvestData.Instance:GetInvestPrice()
	local role_gold = GameVoManager.Instance:GetMainRoleVo().gold
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local func = function ()
		if role_gold >= invest_price then
			InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_BUY, 0)
		else
			TipsCtrl.Instance:ShowLackDiamondView()
		end
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, string.format(Language.Common.InvestTips, invest_price))
end

function MonthCardInvestmentView:OnClickMonthCardInvest()
	TipsCtrl.Instance:ShowHelpTipView(157)
end

function MonthCardInvestmentView:OnFlush()
	self.has_gold:SetValue(CommonDataManager.ConverMoney(PlayerData.Instance.role_vo.gold))
	self.has_bind_gold:SetValue(CommonDataManager.ConverMoney(PlayerData.Instance.role_vo.bind_gold))
	local invest_info = InvestData.Instance:GetInvestInfo()
	self.can_invest:SetValue(invest_info.buy_time == nil or invest_info.buy_time <= 0 or InvestData.Instance:GetMonthCardAllReward())
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

---------------------------------------------------------------
--滚动条格子

MonthCardInvestmentCell = MonthCardInvestmentCell or BaseClass(BaseCell)

function MonthCardInvestmentCell:__init()
	self.task_dec = self:FindVariable("Dec")
	self.reward_btn_enble = self:FindVariable("BtnEnble")
	self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.cost = self:FindVariable("Cost")

	self.reward = ItemCell.New()
	self.reward:SetInstanceParent(self:FindObj("Item1"))

	self:ListenEvent("Reward",
		BindTool.Bind(self.ClickReward, self))

end

function MonthCardInvestmentCell:__delete()
	self.reward:DeleteMe()
end

function MonthCardInvestmentCell:ClickReward()
	if self.data == nil then return end
	if self.data.day_index < 0 then
		InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_FIRST, 0)
	else
		InvestCtrl.Instance:SendChongzhiFetchReward(TOUZIJIHUA_OPERATE.NEW_TOUZIJIHUA_OPERATE_FETCH, self.data.day_index)
	end
end

function MonthCardInvestmentCell:OnFlush()
	self.task_dec:SetValue(self.data.day_index < 0 and Language.Investment.MonthCardRewardDec[1] or string.format(Language.Investment.MonthCardRewardDec[2], self.data.day_index + 1))
	local has_reward = InvestData.Instance:GetMonthCardHasReward(self.data.day_index)
	local can_reward = InvestData.Instance:GetMonthCardCanReward(self.data.day_index)
	self.reward_btn_enble:SetValue(can_reward and not has_reward)
	self.cost:SetValue(self.data.reward_gold_bind)
	self.reward_btn_txt:SetValue(has_reward and Language.Common.YiLingQu or Language.Common.LingQu)
	self.reward:SetData({item_id = 65533})
end