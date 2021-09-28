FRPanel = BaseClass(BaseView)
function FRPanel:__init( ... )
	self.URL = "ui://byk6e4ttsjzg6";
	self.ui = UIPackage.CreateObject("FirstRechargeUI","FRPanel");

	self.btnClose = self.ui:GetChild("btnClose")
	self.btnRecharge = self.ui:GetChild("btnRecharge")
	self.rewardList = self.ui:GetChild("rewardList")
	self.rewCtrl = self.btnRecharge:GetController("rewCtrl")
	self.isInited = true
	self:Config()
end

-- start
function FRPanel:Config()
	self.model = FirstRechargeModel:GetInstance()
	self.giftList = {} -- 奖励列表
	self:AddEvent()
	self:AddBtnClick()
	self:AddHandler()
end

function FRPanel:AddHandler()
	self.handler0 = self.model:AddEventListener(FirstRechargeConst.CanGet, function ( state )
		self:ChangeBtnShow(state)
		self.rewardState = self.model:GetFirstPayRewardState()
	end)
end

function FRPanel:AddEvent()
	local rewardData = self.model:GetReward()
	self:ShowReward(rewardData)
	self.rewardState = self.model:GetFirstPayRewardState()
	self:ChangeBtnShow(self.rewardState)
end

function FRPanel:AddBtnClick()
	self.btnClose.onClick:Add(function ()
		self.model:ClosePopPanel( true )
		self:Close()
	end)

	self.btnRecharge.onClick:Add(function ()
		self:RewardBtnClick(self.rewardState)
	end)
end

function FRPanel:RemoveHandler()
	FirstRechargeModel:GetInstance():RemoveEventListener(self.handler0)
end

function FRPanel:RewardBtnClick( index )
	if index == 0 then
		MallController:GetInstance():OpenMallPanel(0, 2)
	elseif index == 1 then
		FirstRechargeCtrl:GetInstance():C_GetFristPayReward( self.model.rewardId )
		self:ChangeBtnShow(FirstRechargeConst.RewardState.Received)
		self.model:SetFirstPayRewardState( FirstRechargeConst.RewardState.Received )
	end
end

function FRPanel:ChangeBtnShow( index )
	self.rewCtrl.selectedIndex = index
	if index == FirstRechargeConst.RewardState.Received then
		self.btnRecharge.touchable = false
		self.btnRecharge.grayed = true
	end
end

function FRPanel:ShowReward( data )
	for i = 1, #data do
		local iconData = data[i]
		local icon = PkgCell.New(self.rewardList)
		icon:OpenTips(true)
		icon:SetDataByCfg(iconData[1], iconData[2], iconData[3], iconData[4])
		self.giftList[i] = icon
	end
end

-- Combining existing UI generates a class
function FRPanel.Create( ui, ...)
	return FRPanel.New(ui, "#", {...})
end

function FRPanel:Clear()
	self:RemoveHandler()
	if self.giftList then 
		for i,v in ipairs(self.giftList) do
			v:Destroy()
		end
	end
	self.giftList = {}
	self.rewardState = 0
	if self.model and self.model:HasTaskPop() then
		OpenGiftCtrl:GetInstance():Open()
		self.model:SetTaskPop(false)
	end
end

function FRPanel:__delete()
	self:Clear()
	self.model = nil
end