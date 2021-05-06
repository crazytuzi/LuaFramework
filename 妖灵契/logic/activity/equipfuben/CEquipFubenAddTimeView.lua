local CEquipFubenAddTimeView = class("CEquipFubenAddTimeView", CViewBase)

function CEquipFubenAddTimeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/equipfuben/EquipFubenAddTimeView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_Max = 20
	self.m_Min = 1
	self.m_CurTime = 1
	self.m_Cost = 0
	self.m_FubenId = 1
end

function CEquipFubenAddTimeView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_BuyBtn = self:NewUI(2, CButton)
	self.m_AddBtn = self:NewUI(3, CButton)
	self.m_SubBtn = self:NewUI(4, CButton)
	self.m_CountLabel = self:NewUI(5, CLabel)
	self.m_TipsLabel = self:NewUI(6, CLabel)
	self.m_PriceLabel = self:NewUI(7, CLabel)
	self.m_CloseBtn = self:NewUI(8, CButton)
	self.m_CountBtn = self:NewUI(9, CButton)
	self:InitContent()
end

function CEquipFubenAddTimeView.InitContent(self)
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Add"))
	self.m_SubBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "Sub"))
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnCount"))
end

function CEquipFubenAddTimeView.SetData(self, fubenId, cur, min, max)
	self.m_Max = max
	self.m_Min = min
	self.m_CurTime = cur
	self.m_FubenId = fubenId
	self:UpdateText()
end

function CEquipFubenAddTimeView.OnRePeatPress(self,tType, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end 

	if tType == "Add" then
		self.m_CurTime = self.m_CurTime + 1
		if self.m_CurTime > self.m_Max then
			self.m_CurTime = self.m_Max
		end
	else
		self.m_CurTime = self.m_CurTime - 1
		if self.m_CurTime < self.m_Min then
			self.m_CurTime = self.m_Min
		end
	end
	self:UpdateText()
end

function CEquipFubenAddTimeView.OnCount(self)
	local function syncCallback(self, count)
		self.m_CurTime = count
		self:UpdateText()
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_CurTime, min = 1, max = self.m_Max, syncfunc = syncCallback , obj = self},
	{widget = self.m_Container, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, 35)})
end

function CEquipFubenAddTimeView.OnBuy(self)
	if self.m_Cost > g_AttrCtrl.goldcoin then		
		g_WindowTipCtrl:ShowNoGoldTips(2)
		self:OnClose()
	else
		g_EquipFubenCtrl:CtrlC2GSBuyEquipPlayCnt(self.m_CurTime, self.m_Cost ,self.m_FubenId)
		self:CloseView()
	end
end

function CEquipFubenAddTimeView.UpdateText(self)
	self.m_Cost = g_EquipFubenCtrl:GetBuyPrice(self.m_FubenId, self.m_CurTime)
	self.m_PriceLabel:SetText(string.format("%d", self.m_Cost))
	self.m_CountLabel:SetText(string.format("%d", self.m_CurTime))
	self.m_TipsLabel:SetText(string.format("每天购买价格随购买次数增加，还能购买%d次\n埋骨之地副本之间共享次数", self.m_Max))
	if self.m_Cost > g_AttrCtrl.goldcoin then
		self.m_BuyBtn:SetGrey(true)		
	else
		self.m_BuyBtn:SetGrey(false)		
	end
end

return CEquipFubenAddTimeView