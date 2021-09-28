GetLoveContractView = GetLoveContractView or BaseClass(BaseView)

OperateType = {
	Wish = "Wish",
	Receive = "Receive"
}

function GetLoveContractView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","GetLoveContract"}
end

function GetLoveContractView:__delete()

end

function GetLoveContractView:LoadCallBack()
	self.give_name = self:FindVariable("GiveName")
	self.message = self:FindVariable("Message")
	self.is_give = self:FindVariable("IsGive")
	self.is_return = self:FindVariable("IsReturn")
	self.is_day_one = self:FindVariable("IsDayOne")
	self.day = self:FindVariable("Day")

	self.love_message = self:FindObj("LoveMessage"):GetComponent("InputField")

	self:ListenEvent("CloseView", BindTool.Bind(self.OnClickCloseView,self))
	self:ListenEvent("ReturnGift", BindTool.Bind(self.OnClickReturnGift,self))
	self:ListenEvent("DrawGift", BindTool.Bind(self.OnClickDrawGift,self))
	self:ListenEvent("Sign", BindTool.Bind(self.OnClickSignContract,self))
end

function GetLoveContractView:ReleaseCallBack()
	self.give_name = nil
	self.message = nil
	self.is_give = nil
	self.is_return = nil
	self.love_message = nil
	self.day = nil
	self.is_day_one = nil
end

function GetLoveContractView:OpenCallBack()
end

function GetLoveContractView:CloseCallBack()
end

function GetLoveContractView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == OperateType.Wish then
			self:FlushDrawFrame()
		elseif k == OperateType.Receive then
			self:FlushReceiveFrame()
		end
	end
end

function GetLoveContractView:OnClickCloseView()
	self:Close()
end

function GetLoveContractView:OnClickReturnGift()
	self:FlushDrawFrame()
end

function GetLoveContractView:OnClickDrawGift()
	ViewManager.Instance:Open(ViewName.Marriage, TabIndex.marriage_honeymoon)
	ViewManager.Instance:Open(ViewName.LoveContract)
	self:Close()
end

function GetLoveContractView:OnClickSignContract()
	local contract_text = self.love_message.text
	if contract_text == "" then
		contract_text = Language.Marriage.LoveContract
	end

	local des = string.format(Language.Marriage.BuyLoveContractTips, MarriageData.Instance:GetQingyuanLoveContractPrice())
	TipsCtrl.Instance:ShowCommonAutoView(nil, des, function ()
		MarriageCtrl.Instance:SendQingyuanBuyLoveContract(contract_text)
	end)
	self:Close()
end

function GetLoveContractView:FlushDrawFrame()
	self.is_give:SetValue(true)
end

function GetLoveContractView:FlushReceiveFrame()
	self.is_give:SetValue(false)

	local can_receive_day_num = MarriageData.Instance:GetQingyuanLoveContractInfo().can_receive_day_num + 1
	local love_contract_info = MarriageData.Instance:GetQingyuanLoveContractInfo()
	self.is_return:SetValue(love_contract_info.self_love_contract_timestamp <= 0)
	if can_receive_day_num == 1 then
		self.is_day_one:SetValue(true)
		self.give_name:SetValue(GameVoManager.Instance:GetMainRoleVo().lover_name)
		self.message:SetValue(love_contract_info.lover_permission)
	else
		self.is_day_one:SetValue(false)
		self.day:SetValue(can_receive_day_num)
	end
end