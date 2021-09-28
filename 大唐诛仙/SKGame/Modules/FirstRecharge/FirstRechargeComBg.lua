FirstRechargeComBg = BaseClass(BaseView)
function FirstRechargeComBg:__init( ... )
	self.URL = "ui://byk6e4ttrmqhb";

	self.ui = UIPackage.CreateObject("FirstRechargeUI","FirstRechargeComBg");

	self.tabCtrl = self.ui:GetController("tabCtrl")
	self.btnShouchong = self.ui:GetChild("btnShouchong")
	self.redTipSC = self.ui:GetChild("redTipSC")
	self.btnKaifu = self.ui:GetChild("btnKaifu")
	self.redTipKF = self.ui:GetChild("redTipKF")
	self.container = self.ui:GetChild("container")

	self:Config()
end

-- start
function FirstRechargeComBg:Config()
	self:InitData()
	self:InitTabs()
	self:AddCtrlHandler()
	self:AddEventHandler()
end

function FirstRechargeComBg:InitData()
	-- GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.FirstRecharge, show = false, isClose = false})
	-- GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.OpenGift, show = false, isClose = false})

	local tab = MainUIModel:GetInstance():GetMainUIVoListById(FunctionConst.FunEnum.firstRecharge)
	if tab and tab:GetState() == MainUIConst.MainUIItemState.Open then
		self:RefreshTab()
	end
end

function FirstRechargeComBg:RefreshTab()
	local firstState = FirstRechargeModel:GetInstance():IsGetFirstPayRewardState()
	local openState = OpenGiftModel:GetInstance():IsGetRewardState() 
	local isOpenGift = OpenGiftModel:GetInstance():IsOpenActivity()
	if firstState then
		self.defualtTabId = FirstRechargeConst.TabType.OpenGift
		self.tabCtrl.selectedIndex = 1
		self:SetTabbarTips( FirstRechargeConst.TabType.FirstRecharge, false )
		self.btnShouchong.visible = false
	elseif openState or not isOpenGift then
		self.defualtTabId = FirstRechargeConst.TabType.FirstRecharge
		self.tabCtrl.selectedIndex = 0
		self:SetTabbarTips( FirstRechargeConst.TabType.OpenGift, false )
		self.btnKaifu.visible = false
	else
		self.defualtTabId = FirstRechargeConst.TabType.FirstRecharge
		self:SetTabbarTips( FirstRechargeConst.TabType.FirstRecharge, FirstRechargeModel:GetInstance().redTips )
		self:SetTabbarTips( FirstRechargeConst.TabType.OpenGift, OpenGiftModel:GetInstance():GetRedTips() )
	end
	self.selectedTabId = FirstRechargeConst.TabType.None
end

function FirstRechargeComBg:AddCtrlHandler()
	self.tabCtrl.onChanged:Add(function ()
		self:InitTabs(self.tabCtrl.selectedIndex+1)
	end)
end

function FirstRechargeComBg:AddEventHandler()
	self.handler0 = FirstRechargeModel:GetInstance():AddEventListener(FirstRechargeConst.ClosePanel, function ()
		self:ClosePanel()
	end)

	self.handler1 = OpenGiftModel:GetInstance():AddEventListener(OpenGiftConst.ClosePanel, function ()
		self:ClosePanel()
	end)
end

function FirstRechargeComBg:RemoveHandler()
	FirstRechargeModel:GetInstance():RemoveEventListener(self.handler0)
	OpenGiftModel:GetInstance():RemoveEventListener(self.handler1)
end

function FirstRechargeComBg:ChangeCtrlTitleColor(idx)
	local curName = self.tabCtrl:GetPageName(idx-1) or "btnShouchong"
	local oldName = self.tabCtrl.previousPage or "btnKaifu"
	self[curName]:GetChild("title").color = newColorByString("e5e5e5")
	self[oldName]:GetChild("title").color = newColorByString("2e3341")
end

function FirstRechargeComBg:InitTabs(tabIdx)
	self.selectedTabId = tabIdx or self.defualtTabId
	self.selectedPanel = nil
	local cur = nil
	if self.selectedTabId == FirstRechargeConst.TabType.FirstRecharge then
		if not self.rechargePanel then
			self.rechargePanel = FRPanel.New()
			self.rechargePanel:SetXY(311, 57)
			self.container:AddChild(self.rechargePanel.ui)
		end
		cur = self.rechargePanel
	elseif self.selectedTabId == FirstRechargeConst.TabType.OpenGift then
		if not self.openGiftPanel then
			self.openGiftPanel = OpenGiftPanel.New()
			self.openGiftPanel:SetXY(305, 37)
			self.container:AddChild(self.openGiftPanel.ui)
		end
		cur = self.openGiftPanel
	end

	if self.selectPanel ~= cur then
		if self.selectPanel then
			self.selectPanel:SetVisible(false)
		end
		self.selectPanel = cur
		if cur then
			cur:SetVisible(true)
		end
	end

	self:ChangeCtrlTitleColor(self.selectedTabId)
	self:SetTabbarTips(self.selectedTabId, false)
end

function FirstRechargeComBg:SetTabbarTips( id, bool )
	if id then
		if id == FirstRechargeConst.TabType.FirstRecharge then
			self.redTipSC.visible = bool == true
		elseif id == FirstRechargeConst.TabType.OpenGift then
			self.redTipKF.visible = bool == true
		end
	end

	if not self.redTipSC.visible and not self.redTipKF.visible then
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.firstRecharge , state = false})
	end
end

-- Combining existing UI generates a class
function FirstRechargeComBg.Create( ui, ...)
	return FirstRechargeComBg.New(ui, "#", {...})
end

function FirstRechargeComBg:Clear()
	self.defualtTabId = 1
	self.selectedTabId = 0
	self.selectedPanel = nil

	if self.rechargePanel then
		self.rechargePanel:Destroy()
	end
	self.rechargePanel = nil

	if self.openGiftPanel then
		self.openGiftPanel:Destroy()
	end
	self.openGiftPanel = nil
	self:RemoveHandler()
end

function FirstRechargeComBg:ClosePanel()
	self:Clear()
	self:Close()
end

function FirstRechargeComBg:__delete()
	self:Clear()
end