local CFloatTipHud = class("CFloatTipHud", CAsyncHud)

function CFloatTipHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/FloatTipHud.prefab", cb, true)
end

function CFloatTipHud.OnCreateHud(self)
	self.m_FloatTable = self:NewUI(1, CTable)
	self.m_FloatBox = self:NewUI(2, CFloatBox)
	self.m_FloatBox:SetActive(false)
end

function CFloatTipHud.AddTipText(self, sTip)
	local oBox = self.m_FloatBox:Clone()
	oBox:SetActive(true)
	oBox:SetTimer(2, callback(self, "OnTimerUp"))
	oBox:SetText(sTip)
	oBox:ResizeBg()
	self.m_FloatTable:AddChild(oBox)
	local v3 = oBox:GetLocalPos()
	oBox:SetLocalPos(Vector3.New(v3.x, v3.y-20, v3.z))
	oBox:SetAsFirstSibling()
end

function CFloatTipHud.OnTimerUp(self, oBox)
	self.m_FloatTable:RemoveChild(oBox)
	self.m_FloatTable:Reposition()
end

return CFloatTipHud