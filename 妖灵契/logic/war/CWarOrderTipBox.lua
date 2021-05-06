local CWarOrderTipBox = class("CWarOrderTipBox", CBox)

function CWarOrderTipBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_CancelBtn = self:NewUI(1, CButton)
	self.m_TipLabel = self:NewUI(2, CLabel)
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
end

function CWarOrderTipBox.RefreshTip(self)
	local dInfo = g_WarOrderCtrl:GetOrderInfo()
	local sText = ""
	if dInfo.name == "Attack" then
		sText = "请选择目标\n\r攻击"
	elseif dInfo.name == "Magic" then
		local dMagic = DataTools.GetMagicData(dInfo.orderID)
		sText = "请选择目标\n\r"..dMagic.name
	elseif dInfo.name == "Protect" then
		sText = "请选择目标\n\r保护"
	end
	self.m_TipLabel:SetText(sText)
end

function CWarOrderTipBox.OnCancel(self)
	g_WarOrderCtrl:CancelSelectTarget()
end

return CWarOrderTipBox