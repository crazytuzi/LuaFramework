WeddingPledgeView = WeddingPledgeView or BaseClass(BaseView)

function WeddingPledgeView:__init()
	self.ui_config = {"uis/views/marriageview","WeddingPledgeView"}

	self:SetMaskBg()
end

function WeddingPledgeView:ReleaseCallBack()
	self.role_name = nil
	self.wedding_pledge = nil
	self.select_pledge = nil
end

function WeddingPledgeView:LoadCallBack()
	self.role_name = self:FindVariable("role_name")
	self.wedding_pledge = self:FindVariable("wedding_pledge")
	self.select_pledge = self:FindObj("select_pledge").dropdown

	self:ListenEvent("Close",BindTool.Bind(self.ClickClose, self, 0))
	self:ListenEvent("OnClick",BindTool.Bind(self.OnClickPledge, self))	
	self:ListenEvent("OnBtnDropdown",BindTool.Bind(self.OnBtnDropdown, self))	
end

function WeddingPledgeView:ClickClose(is_accept)
	local wedding_info = MarriageData.Instance:GetWeddingTargetInfo()
	if wedding_info.target_id ~= 0 then
		MarriageCtrl.Instance:SendMarryRet(wedding_info.wedding_type, is_accept, wedding_info.target_id)
	end
	self:Close()
end

function WeddingPledgeView:OnClickPledge()
	MarriageCtrl.Instance:SendWeedingOperate(MARRY_REQ_TYPE.MARRY_CHOSE_SHICI_REQ, self.select_pledge.value + 1)
	self:Close()
end

function WeddingPledgeView:OnBtnDropdown()
	if self.select_pledge == nil and Language.Marriage.PledgeType[self.select_pledge.value] == "" then return end
	self.wedding_pledge:SetValue(Language.Marriage.PledgeType[self.select_pledge.value])
end