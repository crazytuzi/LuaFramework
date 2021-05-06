local CFrdGroupItem = class("CFrdGroupItem", CBox)

function CFrdGroupItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_AmountLabel = self:NewUI(2, CLabel)
	self.m_FlagIcon = self:NewUI(3, CSprite)
	self.m_MsgAmount = self:NewUI(4, CSprite)
	self.m_ExpandSpr = self:NewUI(5, CSprite)
	self:SetMsgAmount(0)
	self.m_ExpandSpr:SetActive(false)
	self.m_FlagIcon.Tween = self.m_FlagIcon:GetComponent(classtype.TweenRotation)
	self.m_IsExpand = false
end

function CFrdGroupItem.SetName(self, sName)
	if sName then
		self.m_NameLabel:SetText(sName)
	end
end

function CFrdGroupItem.SetAmount(self, online, total)
	self.m_AmountLabel:SetText(string.format("%d/%d", online, total))
end

function CFrdGroupItem.SwitchExpand(self)
	self.m_IsExpand = not self.m_IsExpand
	self.m_ExpandSpr:SetActive(self.m_IsExpand)
	self.m_FlagIcon.Tween:Toggle()
end

function CFrdGroupItem.SetMsgAmount(self, amount)
	if amount > 0 then
		self.m_MsgAmount:SetActive(true)
	else
		self.m_MsgAmount:SetActive(false)
	end
end

return CFrdGroupItem