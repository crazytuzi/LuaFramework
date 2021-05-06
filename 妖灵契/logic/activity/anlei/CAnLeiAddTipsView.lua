---------------------------------------------------------------
--暗雷购买探索点界面


---------------------------------------------------------------


local CAnLeiAddTipsView = class("CAnLeiAddTipsView", CViewBase)

CAnLeiAddTipsView.AddPointPrice = 1				--探索点的价钱

function CAnLeiAddTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/AnLei/AnLeiAddTipsView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CAnLeiAddTipsView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CBox)
	self.m_OkBtn = self:NewUI(2, CButton)
	self.m_CancelBtn = self:NewUI(3, CButton)
	self.m_SubBtn = self:NewUI(4, CButton)
	self.m_AddBtn = self:NewUI(5, CButton)
	self.m_MaxBtn = self:NewUI(6, CButton)
	self.m_CountLabel = self:NewUI(7, CLabel)
	self.m_CountBtn = self:NewUI(8, CButton)
	self.m_TipsLabel = self:NewUI(9, CLabel)

	self:InitContent()
end

function CAnLeiAddTipsView.InitContent(self)
	local point_max = g_AnLeiCtrl:GetCanAddPointCount()
	local coin_max = g_AnLeiCtrl:GetCanBuyPointCountByCoin()
	self.m_PointCount = (coin_max > point_max) and point_max or coin_max
	self:SetCost()
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MaxBtn:AddUIEvent("repeatpress", callback(self, "OnMax"))	
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnAddPoint"))
	self.m_CountBtn:AddUIEvent("click", callback(self, "OnCount"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "OnSub"))
	self.m_SubBtn:AddUIEvent("repeatpress", callback(self, "OnAdd"))

end

function CAnLeiAddTipsView.OnSub(self, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end

	self.m_PointCount = self.m_PointCount + 1
	if self.m_PointCount > g_AnLeiCtrl:GetCanAddPointCount() then
		self.m_PointCount = g_AnLeiCtrl:GetCanAddPointCount()
	end
	self:SetCost()
end

function CAnLeiAddTipsView.OnAdd(self, ...)
	local bPress = select(2, ...)
	if bPress ~= true then
		return
	end 

	self.m_PointCount = self.m_PointCount - 1
	if self.m_PointCount < 1 then
		self.m_PointCount = 1
	end	
	self:SetCost()
end

function CAnLeiAddTipsView.OnAddPoint(self)
	if g_AttrCtrl.goldcoin >= g_AnLeiCtrl:GetBuyAnleiPointPrice(self.m_PointCount) then
		g_AnLeiCtrl:AddAnLeiPoint(self.m_PointCount)
	else
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	end
	self:CloseView()
end

function CAnLeiAddTipsView.OnMax(self)
	self.m_PointCount = g_AnLeiCtrl:GetCanAddPointCount()
	self:SetCost()
end

function CAnLeiAddTipsView.OnCount(self)
	local function syncCallback(self, count)
		self.m_PointCount = count
		self:SetCost()
	end
	g_WindowTipCtrl:SetWindowNumberKeyBorad(
	{num = self.m_PointCount, min = 1, max = g_AnLeiCtrl:GetCanAddPointCount(), syncfunc = syncCallback , obj = self},
	{widget = self.m_Container, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, 0)})
end

function CAnLeiAddTipsView.SetCost(self )
	local price = g_AnLeiCtrl:GetBuyAnleiPointPrice(self.m_PointCount)
	self.m_CountLabel:SetText(string.format("%d", self.m_PointCount))	
	if g_AttrCtrl.goldcoin >= price then
		self.m_TipsLabel:SetText(string.format("[654A33]%d", price))
	else
		self.m_TipsLabel:SetText(string.format("[A03320]%d", price))		
	end
end

return CAnLeiAddTipsView