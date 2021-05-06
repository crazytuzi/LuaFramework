local CDrawSelectView = class("CDrawSelectView", CViewBase)
--wuling武灵
--wuhun武魂
function CDrawSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/DrawSelectView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_DepthType = "Dialog"
end

function CDrawSelectView.OnCreateView(self)
	self.m_SSRBox = self:NewUI(2, CBox)
	self.m_SSRLabel = self.m_SSRBox:NewUI(1, CLabel)
	
	self.m_SRBox = self:NewUI(3, CBox)
	self.m_SRLabel = self.m_SRBox:NewUI(1, CLabel)
	
	self.m_NormalBox = self:NewUI(4, CBox)
	self.m_NormalLabel = self.m_NormalBox:NewUI(1, CLabel)
	self.m_NormalCostLabel = self.m_NormalBox:NewUI(2, CLabel)
	self:InitContent()
end

function CDrawSelectView.InitContent(self)
	self.m_SSRBox:AddUIEvent("click", callback(self, "OnClickSSR"))
	self.m_NormalBox:AddUIEvent("click", callback(self, "OnClickNormal"))
	self.m_SRBox:AddUIEvent("click", callback(self, "OnClickSR"))

	self:UpdateAmount()
end

function CDrawSelectView.UpdateAmount(self)
	self.m_SSRLabel:SetText("×"..tostring(g_ItemCtrl:GetBagItemAmountBySid(10019)))
	self.m_SRLabel:SetText("×"..tostring(g_ItemCtrl:GetBagItemAmountBySid(10018)))
	self.m_NormalLabel:SetText("×"..tostring(g_ItemCtrl:GetBagItemAmountBySid(10021)))
	self.m_NormalCostLabel:SetText(string.format("契约不足可用#w2%d代替", g_PartnerCtrl:GetChoukaCost()))
end

function CDrawSelectView.SetCallBack(self, cb)
	self.m_CallBack = cb
end

function CDrawSelectView.OnClickSSR(self)
	if g_ItemCtrl:GetBagItemAmountBySid(10019) > 0 then
		self.m_CallBack(10019)
		self:OnClose()
	else
		g_NotifyCtrl:FloatMsg("你的一发入魂契约不足")
	end
end

function CDrawSelectView.OnClickSR(self)
	if g_ItemCtrl:GetBagItemAmountBySid(10018) > 0 then
		self.m_CallBack(10018)
		self:OnClose()
	else
		g_NotifyCtrl:FloatMsg("你的欧洲偷渡契约不足")
	end
end

function CDrawSelectView.OnClickNormal(self)
	if g_ItemCtrl:GetBagItemAmountBySid(10021) < 1 and not g_PartnerCtrl:IsChoukaFree() and g_WindowTipCtrl:IsShowTips("draw_whcard_tip") then
		local windowConfirmInfo = {
			msg				= string.format("你的王者契约不足，是否消耗#w2%d进行招募？", g_PartnerCtrl:GetChoukaCost()),
			okCallback		= function()
				self.m_CallBack(0)
				self:OnClose()
			end,
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "draw_whcard_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self.m_CallBack(0)
		self:OnClose()
	end
end

return CDrawSelectView