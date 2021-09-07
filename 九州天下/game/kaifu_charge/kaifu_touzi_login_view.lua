KaiFuTouZiLoginView = KaiFuTouZiLoginView or BaseClass(BaseRender)

function KaiFuTouZiLoginView:__init()
	self.ui_config = {"uis/views/kaifuchargeview","TouZiLoginContent"}
end

function KaiFuTouZiLoginView:__delete()
	if self.touzi_cell_list then
		for k,v in pairs(self.touzi_cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.touzi_cell_list = {}
	end

	self.touzi_scroller = nil
	self.need_gold = nil

end

function KaiFuTouZiLoginView:LoadCallBack()
	self.need_gold = self:FindVariable("Need_Gold")
	self.is_touzi = self:FindVariable("Is_TouZi")
	self:ListenEvent("BtnBuyTouZi", BindTool.Bind(self.OnBuyTouZi, self))
	self:ListenEvent("OnClickNext", BindTool.Bind(self.OnClickNext, self))
	self:ListenEvent("OnClickBefore", BindTool.Bind(self.OnClickBefore, self))
	self.LeftBtn = self:FindVariable("LeftGoto")
	self.RightBtn = self:FindVariable("RightGoto")
	self.need_gold:SetValue(KaiFuChargeData.Instance:LoginTouZiNeedPrice1() / 10)

	self.touzi_cell_list = {}
	self.touzi_scroller = self:FindObj("List")
	local delegate = self.touzi_scroller.list_simple_delegate
	delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function KaiFuTouZiLoginView:OnBuyTouZi()
	RechargeCtrl.Instance:Recharge(KaiFuChargeData.Instance:LoginTouZiNeedPrice())
end


function KaiFuTouZiLoginView:OnClickNext()
	if self.touzi_scroller.scroll_rect.horizontalNormalizedPosition >= 1 then 
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = 1
	else
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = self.touzi_scroller.scroll_rect.horizontalNormalizedPosition + 0.25
	end
end

function KaiFuTouZiLoginView:OnClickBefore()
	if self.touzi_scroller.scroll_rect.horizontalNormalizedPosition <= 0 then 
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = 0
	else
		self.touzi_scroller.scroll_rect.horizontalNormalizedPosition = self.touzi_scroller.scroll_rect.horizontalNormalizedPosition - 0.25
	end
end

function KaiFuTouZiLoginView:GetNumberOfCells()
	return #KaiFuChargeData.Instance:GetLoginRewardList()
end

function KaiFuTouZiLoginView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local target_cell = self.touzi_cell_list[cell]
	if nil == target_cell then
		target_cell = TouZiLoginInvestmentCell.New(cell.gameObject)
		self.touzi_cell_list[cell] = target_cell
	end
	local data = KaiFuChargeData.Instance:GetLoginRewardList()
	target_cell:SetIndex(data_index)
	target_cell:SetData(data[data_index])
	if self.touzi_scroller.scroll_rect.horizontalNormalizedPosition < 0.05 then 
		self.RightBtn:SetValue(true) 
		self.LeftBtn:SetValue(false)
	elseif self.touzi_scroller.scroll_rect.horizontalNormalizedPosition > 0.74 then
		self.RightBtn:SetValue(false)
		self.LeftBtn:SetValue(true)
	else
		self.RightBtn:SetValue(true)
		self.LeftBtn:SetValue(true)
	end
end

function KaiFuTouZiLoginView:OnFlush()
	local touzi_active = InvestData.Instance:GetInvestInfo().touzi_active_flag or 0
	self.is_touzi:SetValue(touzi_active == TOUZI_ACTIVE_TYPE.TOUZI_LOGIN or touzi_active == TOUZI_ACTIVE_TYPE.TOUZI_ALL)
	
	if self.touzi_scroller.scroller.isActiveAndEnabled then
		self.touzi_scroller.scroller:ReloadData(0)
	end
end

---------------------------------------------------------------
--登陆投资滚动条格子

TouZiLoginInvestmentCell = TouZiLoginInvestmentCell or BaseClass(BaseCell)

function TouZiLoginInvestmentCell:__init()
	self.task_dec = self:FindVariable("Dec")
	self.reward_btn_enble = self:FindVariable("BtnEnble")
	--self.reward_btn_txt = self:FindVariable("RewardBtnTxt")
	self.is_get = self:FindVariable("IsGet")
	self.show_item = self:FindVariable("ShowItem")
	self.show_model = RoleModel.New()
	self.display = self:FindObj("Display")
	self.icon_image = self:FindVariable("Icon")
	self.show_getreward = self:FindVariable("ShowGetRewardRedPoint")
	self.reward = {}
	for i = 1, 3 do
		self.reward[i] = ItemCell.New()
		self.reward[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self:ListenEvent("Reward", BindTool.Bind(self.ClickReward, self))

end

function TouZiLoginInvestmentCell:__delete()
	if self.reward and next(self.reward) then
		for _, v in pairs(self.reward) do
			v:DeleteMe()
			v = nil
		end
		self.reward = {}
	end

	if self.show_model ~= nil then
		self.show_model:DeleteMe()
		self.show_model = nil
	end
end

function TouZiLoginInvestmentCell:ClickReward()
	if self.data == nil then return end
	KaiFuChargeCtrl.Instance:SendTouZiReward(TOUZI_JIHUA_TYPE.TOUZI_JIHUA_TYPE_LOGIN, self.data.seq)
end

function TouZiLoginInvestmentCell:OnFlush()
	if self.data == nil then return end
	for i = 1, 3 do
		if self.data.reward_item[i-1] and next(self.data.reward_item[i-1]) then
			self.reward[i]:SetData(self.data.reward_item[i-1])
			self.reward[i].root_node.transform.parent.parent.gameObject:SetActive(true)
		else
			self.reward[i]:SetData(nil)
			self.reward[i].root_node.transform.parent.parent.gameObject:SetActive(false)
		end
	end

	self.task_dec:SetValue(self.data.seq + 1 .. Language.Common.TimeList.d)
	
	local level_flag = InvestData.Instance:GetNormalLevelFlag(self.data.touzi_type, self.data.seq)
	self.is_get:SetValue(level_flag > 0)
	if level_flag > 0 then
		self.show_getreward:SetValue(false)
		return
	end
	local touzi_info = InvestData.Instance:GetInvestInfo()
	local is_touzi_login = touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_LOGIN or touzi_info.touzi_active_flag == TOUZI_ACTIVE_TYPE.TOUZI_ALL
	local has_reward = InvestData.Instance:GetNormalLevelHasReward(self.data.touzi_type, self.data.seq)
	self.show_getreward:SetValue(is_touzi_login and has_reward > 0)
	self.reward_btn_enble:SetValue(is_touzi_login and has_reward > 0)
	self.show_model:SetDisplay(self.display.ui3d_display)
	local bundle, asset = ResPath.GetModelAsset("item", self.data.show_res_id)
	self.show_model:SetMainAsset(bundle, asset)
	if self.data.show_pic and self.data.show_pic ~= "" then
		self.display:SetActive(false)
		self.icon_image:SetAsset(ResPath.GetKaiFuChargeImage(self.data.show_pic))
	else
		self.icon_image:SetAsset("", "")
		self.display:SetActive(true)
	end
end