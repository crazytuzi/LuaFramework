RechargeContentView = RechargeContentView or BaseClass(BaseRender)

function RechargeContentView:__init(instance)
	RechargeContentView.Instance = self
	self.contain_cell_list = {}
	self:InitListView()
end

function RechargeContentView:__delete()
	for k,v in pairs(self.contain_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.contain_cell_list = {}
end

function RechargeContentView:InitListView()
	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function RechargeContentView:GetNumberOfCells()
	local recharge_id_list = RechargeData.Instance:GetRechargeIdList()
	if #recharge_id_list %4 ~= 0 then
		return math.floor(#recharge_id_list/4) + 1
	else
		return #recharge_id_list/4
	end
end

function RechargeContentView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RechargeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local id_list = RechargeData.Instance:GetRechargeListByIndex(cell_index)
	contain_cell:SetItemId(id_list)
end

function RechargeContentView:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function RechargeContentView:SetRechargeActive(is_active)
	self.root_node:SetActive(is_active)
end
---------------------------------------------------------------
RechargeContain = RechargeContain  or BaseClass(BaseCell)

function RechargeContain:__init()
	self.recharge_contain_list = {}
	for i = 1, 4 do
		self.recharge_contain_list[i] = {}
		self.recharge_contain_list[i].recharge_item = RechargeItem.New(self:FindObj("item_" .. i))
	end
end

function RechargeContain:__delete()
	for i=1,4 do
		self.recharge_contain_list[i].recharge_item:DeleteMe()
		self.recharge_contain_list[i].recharge_item = nil
	end
end

function RechargeContain:SetItemId(item_id_list)
	for i=1,4 do
		self.recharge_contain_list[i].recharge_item:SetItemId(item_id_list[i])
	end
end

function RechargeContain:OnFlushAllCell()
	for i=1,4 do
		self.recharge_contain_list[i].shop_item:OnFlush()
	end
end

----------------------------------------------------------------------------
RechargeItem = RechargeItem or BaseClass(BaseCell)

function RechargeItem:__init()
	self.money_text = self:FindVariable("money")
	self.money_icon = self:FindVariable("money_icon")
	self.gold_text = self:FindVariable("gold_text")
	self.show_return = self:FindVariable("show_return")
	self.extra_gold = self:FindVariable("extra_gold")
	self.gold_icon = self:FindVariable("gold_icon")
	self.is_spec = self:FindVariable("is_spec")
	self.spec_txt = self:FindVariable("SpecTxt")
	self.show_red = self:FindVariable("ShowRed")
	self.spec_txt2 = self:FindVariable("SpecTxt2")
	self.has_spec_recharge = self:FindVariable("HasSpecRecharge")
	self:ListenEvent("rechange_click", BindTool.Bind(self.OnRechargeClick, self))
	self.item_id = 0
end

function RechargeItem:__delete()
end

function RechargeItem:SetItemId(item_id)
	self.item_id = item_id
	self:OnFlush()
end

function RechargeItem:OnFlush()
	self.root_node:SetActive(true)
	if self.item_id == RechargeData.InVaildId then
		self.root_node:SetActive(false)
		return
	end

	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
	local other_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
	local bundle, gold_asset = ResPath.GetYuanBaoIcon(0)
	local bundle1, bind_gold_asset = ResPath.GetYuanBaoIcon(1)
	self:SetIcon(recharge_cfg)
	self.money_text:SetValue(recharge_cfg.money)
	self.gold_text:SetValue(recharge_cfg.gold)
	self.is_spec:SetValue(recharge_cfg.id == RechargeData.SPEC_ID)
	self.has_spec_recharge:SetValue(false)
	self.show_red:SetValue(false)

	if recharge_cfg.id == RechargeData.SPEC_ID then
		local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
		local has_reward_day = RechargeData.Instance:GetChongZhi7DayRewardDay()
		local is_fetch = RechargeData.Instance:GetChongZhi7DayRewardIsFetch()   -- 0未领取  1已领取
		local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
		self.show_red:SetValue(has_buy_7day_rechange and is_fetch == 0)
		if has_buy_7day_rechange then
			self.has_spec_recharge:SetValue(true)
			self.spec_txt:SetValue(string.format(Language.Recharge.DayRechargeTxt[2], math.max(7 - has_reward_day, 0), reward_18yuan_cfg.chongzhi_seven_day_reward_bind_gold))
			self.spec_txt2:SetValue("")
		else
			self.spec_txt:SetValue(Language.Recharge.DayRechargeTxt[1])
			self.spec_txt2:SetValue(Language.Recharge.DayRechargeTxt[3])
		end
	elseif reward_cfg and reward_cfg.extra_bind_gold > 0 then
		self.extra_gold:SetValue(reward_cfg.extra_bind_gold)
		self.gold_icon:SetAsset(bundle1,bind_gold_asset)
	else
		self.extra_gold:SetValue(reward_cfg.extra_gold)
		self.gold_icon:SetAsset(bundle,gold_asset)
	end
	local is_first_chongzhi = DailyChargeData.Instance:CheckIsFirstRechargeById(recharge_cfg.id)
	if IS_AUDIT_VERSION then
		self.show_return:SetValue(false)
	else
		self.show_return:SetValue(is_first_chongzhi)
	end
end

function RechargeItem:SetIcon(cfg)
	local res = ""
	res = cfg.gold_icon
	local bundle, asset = ResPath.GetVipIcon(res)
	local bundle0, asset0 = ResPath.GetVipIcon("Diamond0")
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	if recharge_cfg.id == RechargeData.SPEC_ID then
		self.money_icon:SetAsset(bundle0, asset0)
	else
		self.money_icon:SetAsset(bundle, asset)
	end
end

function RechargeItem:OnRechargeClick()
	local recharge_cfg = RechargeData.Instance:GetRechargeInfo(self.item_id)
	local reward_cfg = RechargeData.Instance:GetChongzhiRewardCfgById(recharge_cfg.id)
	local vip_chongzhi_num = DailyChargeData.Instance:CheckIsFirstRechargeById(self.item_id)
	local reward_18yuan_cfg = RechargeData.Instance:GetChongzhi18YuanRewardCfg()
	if (nil == reward_cfg and recharge_cfg.id ~= RechargeData.SPEC_ID) or not recharge_cfg then return end
	local discretion = ""
	if recharge_cfg.id == RechargeData.SPEC_ID then
		local has_buy_7day_rechange = RechargeData.Instance:HasBuy7DayChongZhi()
		if has_buy_7day_rechange then
			RechargeCtrl.Instance:SendChongZhi7DayFetchReward()
			return
		end
		discretion = string.format(Language.Recharge.RechargeDes, reward_18yuan_cfg.chongzhi_seven_day_reward_bind_gold)
		str_recharge = string.format(Language.Recharge.FirstBing, 18)
	else
		discretion = reward_cfg.discretion
		str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
	end
	-- local str_recharge = string.format(Language.Recharge.FirstGold, recharge_cfg.money, recharge_cfg.gold)
	if vip_chongzhi_num == true then
		chongzhi_show_str = str_recharge .. "\n\n" .. string.format(discretion) .. "\n\n" .. Language.Recharge.WarmPrompt
	else
		chongzhi_show_str = str_recharge .. "\n\n" .. Language.Recharge.WarmPrompt
	end
	TipsCtrl.Instance:ShowCommonTip(BindTool.Bind2(self.SendRecharge, self, recharge_cfg), nil, chongzhi_show_str)
end


function RechargeItem:SendRecharge(recharge_cfg)
	RechargeCtrl.Instance:Recharge(recharge_cfg.money)
end
