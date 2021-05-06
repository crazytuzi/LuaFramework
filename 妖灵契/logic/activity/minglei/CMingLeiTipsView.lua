---------------------------------------------------------------
--明雷Tips画面

---------------------------------------------------------------

local CMingLeiTipsView = class("CMingLeiTipsView", CViewBase)

function CMingLeiTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/MingLei/MingLeiTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CMingLeiTipsView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_OkBtn = self:NewUI(2, CButton)
	self.m_CancelBtn = self:NewUI(3, CButton)
	self.m_SubBtn = self:NewUI(4, CButton)
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_MaxBtn = self:NewUI(6, CButton)
	self.m_CountLabel = self:NewUI(7, CLabel)
	self.m_CountBtn = self:NewUI(8, CButton)
	self.m_TipsLabel = self:NewUI(9, CLabel)

	self.m_BuyTime = 1
	self.m_LeftTime = 1
	self.m_MaxTime = 1
	self.m_PerCost = 999

	self:InitContent()
end

function CMingLeiTipsView.InitContent(self)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MaxBtn:AddUIEvent("repeatpress", callback(self, "OnMax"))	
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnOk"))
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnCount"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnSub"))
	self.m_SubBtn:AddUIEvent("repeatpress", callback(self, "OnAdd"))
end

function CMingLeiTipsView.SetContent(self, leftTime, perCost, maxTime)
	self.m_LeftTime = leftTime 
	self.m_PerCost = perCost 
	self.m_MaxTime = maxTime
	self:SetCost()
end

function CMingLeiTipsView.OnSub(self, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end

	self.m_BuyTime =self.m_BuyTime + 1
	if self.m_BuyTime > self.m_LeftTime then
		self.m_BuyTime = self.m_LeftTime
	end
	self:SetCost()
end

function CMingLeiTipsView.OnAdd(self, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end 

	self.m_BuyTime = self.m_BuyTime - 1
	if self.m_BuyTime < 1 then
		self.m_BuyTime = 1
	end	
	self:SetCost()
end

function CMingLeiTipsView.OnOk(self)
	g_ActivityCtrl:CtrlC2GSBuyMingleiTimes(self.m_BuyTime)
	self:CloseView()
end

function CMingLeiTipsView.OnMax(self)
	self.m_BuyTime = self.m_LeftTime
	self:SetCost()
end

function CMingLeiTipsView.OnCount(self)
	local function syncCallback(self, count)
		self.m_BuyTime = count
		self:SetCost()
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_BuyTime, min = 1, max = self.m_LeftTime, syncfunc = syncCallback , obj = self},
	{widget = self.m_Container, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, 35)})
end

function CMingLeiTipsView.SetCost(self )
	self.m_CountLabel:SetText(string.format("%d", self.m_BuyTime))
	self.m_TipsLabel:SetText(string.format("消耗水晶:%d", self.m_BuyTime * self.m_PerCost))
	if g_AttrCtrl.goldcoin >= self.m_BuyTime * self.m_PerCost then
		self.m_TipsLabel:SetColor(Color.New( 126/255, 72/255, 0/255, 255/255))
	else
		self.m_TipsLabel:SetColor(Color.New( 176/255, 16/255, 16/255, 255/255))
	end
end

return CMingLeiTipsView