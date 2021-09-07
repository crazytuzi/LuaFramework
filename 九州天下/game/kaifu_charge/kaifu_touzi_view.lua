KaiFuTouZiView = KaiFuTouZiView or BaseClass(BaseRender)

function KaiFuTouZiView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","TouZiContent"}
end


function KaiFuTouZiView:__delete()
	if self.touzi_cell_list and next(self.touzi_cell_list) then
		for k,v in pairs(self.touzi_cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.touzi_cell_list = {}
	end

	self.role_gold = nil
	self.touzi_scroller = nil
	self.need_gold = nil
end

function KaiFuTouZiView:LoadCallBack()
	self.role_gold = self:FindVariable("Gold")
	self.need_gold = self:FindVariable("Need_Gold")
	self.is_touzi = self:FindVariable("Is_TouZi")
	self.LeftBtn = self:FindVariable("LeftBtn")
	self.RightBtn = self:FindVariable("RightBtn")

	self:ListenEvent("BtnBuyTouZi", BindTool.Bind(self.OnBuyTouZi, self))
	self:ListenEvent("OnClickNext", BindTool.Bind(self.OnClickNext, self))
	self:ListenEvent("OnClickBefore", BindTool.Bind(self.OnClickBefore, self))

	self.role_gold:SetValue(CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold))
	self.need_gold:SetValue(KaiFuChargeData.Instance:LevelTouZiNeedPrice())
	self.touzi_cell_list = {}
	self.touzi_scroller = self:FindObj("List")
	local delegate = self.touzi_scroller.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function KaiFuTouZiView:OnBuyTouZi()
	local charge_list = DailyChargeData.Instance:GetChongZhiInfo()
	local limit_charge = KaiFuChargeData.Instance:LevelTouziLimit()
	local buy_price = KaiFuChargeData.Instance:LevelTouZiNeedPrice()
	local str = string.format(Language.Common.InvestTips, buy_price)
	local func = function ()
		KaiFuChargeCtrl.Instance:SendTouZiActive(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL)
	end
	if charge_list ~= nil and next(charge_list) then
		if charge_list.history_recharge < limit_charge then
			str = string.format(Language.Common.LimitTips, limit_charge)
			func = function ()
				ViewManager.Instance:Open(ViewName.RechargeView)
			end
		end 
	end
	TipsCtrl.Instance:ShowCommonTip(func, nil, str)
end

function KaiFuTouZiView:OnClickNext()
	if self.touzi_scroller.scroll_rect.horizontalNormalizedPosition >= 1 then 
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = 1
		-- self.RightBtn:SetValue(false)
	else
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = self.touzi_scroller.scroll_rect.horizontalNormalizedPosition + 0.25
	end
	-- self.LeftBtn:SetValue(true)
end

function KaiFuTouZiView:OnClickBefore()
	if self.touzi_scroller.scroll_rect.horizontalNormalizedPosition <= 0 then 
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = 0
		-- self.LeftBtn:SetValue(false)
	else
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = self.touzi_scroller.scroll_rect.horizontalNormalizedPosition - 0.25
	end
	-- self.RightBtn:SetValue(true)
end

function KaiFuTouZiView:GetNumberOfCells()
	return #KaiFuChargeData.Instance:GetLevelRewardListSort()
end

function KaiFuTouZiView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.touzi_cell_list[cell]
	if nil == target_cell then
		target_cell = TouZiLevelInvestmentCell.New(cell.gameObject)
		self.touzi_cell_list[cell] = target_cell
	end
	local data = KaiFuChargeData.Instance:GetLevelRewardListSort()
	target_cell:SetIndex(data_index)
	target_cell:SetData(data[data_index])

	if self.touzi_scroller.scroll_rect.horizontalNormalizedPosition <= 0.05 then 
		self.RightBtn:SetValue(true) 
		self.LeftBtn:SetValue(false)
	elseif self.touzi_scroller.scroll_rect.horizontalNormalizedPosition >= 0.9 then
		self.RightBtn:SetValue(false)
		self.LeftBtn:SetValue(true)
	else
		self.RightBtn:SetValue(true)
		self.LeftBtn:SetValue(true)
	end
end

function KaiFuTouZiView:OnFlush()
	local touzi_active = InvestData.Instance:GetInvestInfo().touzi_active_flag or 0
	self.is_touzi:SetValue(touzi_active == TOUZI_ACTIVE_TYPE.TOUZI_LEVEL or touzi_active == TOUZI_ACTIVE_TYPE.TOUZI_ALL)

	if self.touzi_scroller.scroller.isActiveAndEnabled then
		self.touzi_scroller.scroller:ReloadData(0)
	end	
	self.role_gold:SetValue(CommonDataManager.ConverMoney(GameVoManager.Instance:GetMainRoleVo().gold))
end



---------------------------------------------------------------
--等级投资滚动条格子

TouZiLevelInvestmentCell = TouZiLevelInvestmentCell or BaseClass(BaseCell)

function TouZiLevelInvestmentCell:__init()
	self.task_des = self:FindVariable("Dec")
	self.reward_btn_enble = self:FindVariable("BtnEnble")
	--self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.is_get = self:FindVariable("IsGet")
	self.show_item = self:FindVariable("ShowItem")
	self.show_getreward = self:FindVariable("ShowGetRewardRedPoint")
	self.reward = {}
	for i = 1, 3 do
		self.reward[i] = ItemCell.New()
		self.reward[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self:ListenEvent("Reward", BindTool.Bind(self.ClickReward, self))
end

function TouZiLevelInvestmentCell:__delete()
	if self.reward and next(self.reward) then
		for _, v in pairs(self.reward) do
			v:DeleteMe()
			v = nil
		end
		self.reward = {}
	end
end

function TouZiLevelInvestmentCell:ClickReward()
	if self.data == nil then return end
	KaiFuChargeCtrl.Instance:SendTouZiReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LEVEL, self.data.seq)
end

function TouZiLevelInvestmentCell:OnFlush()
	if self.data == nil then return end
	for i = 1, 3 do
		if self.data.reward_item[i-1] and next(self.data.reward_item[i-1]) then
			local gift_reward_list = ItemData.Instance:GetGiftItemListByProf(self.data.reward_item[i-1].item_id)
			if gift_reward_list and next(gift_reward_list) then
				self.reward[i]:SetGiftItemId(self.data.reward_item[i-1].item_id)
				self.reward[i]:SetData(gift_reward_list[1])
				self.reward[i].root_node.transform.parent.parent.gameObject:SetActive(true)
			else
				self.reward[i]:SetData(self.data.reward_item[i-1])
				self.reward[i].root_node.transform.parent.parent.gameObject:SetActive(true)
			end
		else
			self.reward[i]:SetData(nil)
			self.reward[i].root_node.transform.parent.parent.gameObject:SetActive(false)
		end
	end

	self.task_des:SetValue(self.data.need_level .. Language.Common.Ji)
	
	local level_flag = InvestData.Instance:GetNormalLevelFlag(self.data.touzi_type, self.data.seq)
	self.is_get:SetValue(level_flag > 0)
	if level_flag > 0 then
		local bundle, asset = ResPath.GetLevelTouziType("open_" .. math.ceil((self.data.seq + 1) / 3))
		if self.show_item then
			self.show_item:SetAsset(bundle, asset)
		end
		self.show_getreward:SetValue(false)
	else
		local bundle, asset = ResPath.GetLevelTouziType("close_" .. math.ceil((self.data.seq + 1) / 3))
		if self.show_item then
			self.show_item:SetAsset(bundle, asset)
		end
	end

	if level_flag > 0 then return end

	local touzi_info = InvestData.Instance:GetInvestInfo()
	local is_touzi_level = touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_LEVEL or touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_ALL
	local role_level = PlayerData.Instance.role_vo.level
	local has_reward = InvestData.Instance:GetNormalLevelHasReward(self.data.touzi_type, self.data.seq)
	self.reward_btn_enble:SetValue(is_touzi_level and has_reward > 0 and role_level >= self.data.need_level)
	self.show_getreward:SetValue(is_touzi_level and has_reward > 0 and role_level >= self.data.need_level)
end