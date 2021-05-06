local CChatHud = class("CChatHud", CAsyncHud)

function CChatHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/ChatHud.prefab", cb, true)
end

function CChatHud.OnCreateHud(self)
	self.m_FloatTable = self:NewUI(1, CTable)
	self.m_FloatBox = self:NewUI(2, CFloatBox)
	self.m_ArrowSpr = self:NewUI(3, CSprite)
	self.m_FloatBox:SetActive(false)
	self.m_ArrowSpr:SetActive(false)
end

function CChatHud.AddMsg(self, oMsg)
	--self.m_ArrowSpr:SetActive(true)
	local oBox = self.m_FloatBox:Clone()
	oBox:SetActive(true)
	oBox:SetTimer(2, callback(self, "OnTimerUp"))
	oBox:SetMaxWidth(240)
	oBox:SetText(oMsg:GetText())
	oBox:ResizeBg()
	self.m_FloatTable:AddChild(oBox)
	local v3 = oBox:GetLocalPos()
	oBox:SetLocalPos(Vector3.New(v3.x, v3.y-20, v3.z))
	oBox:SetAsFirstSibling()
end

function CChatHud.OnTimerUp(self, oBox)
	self.m_FloatTable:RemoveChild(oBox)
	self.m_FloatTable:Reposition()
	if self.m_FloatTable:GetCount() == 0 then
		self.m_ArrowSpr:SetActive(false)
	end
end

return CChatHud