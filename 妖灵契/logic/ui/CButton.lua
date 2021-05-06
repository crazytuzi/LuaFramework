local CButton = class("CButton", CSprite)

function CButton.ctor(self, obj, bScale)
	CSprite.ctor(self, obj)
	self.m_ChildLabel = nil
	self.m_UIButton = self:GetComponent(classtype.UIButton)
	if self.m_UIButton then
		self.m_UIButton.hover = Color.white
		self.m_UIButton.pressed = Color.white
	end
	if bScale ~= false then
		self:InitButtonScale()
	end
end

function CButton.SetGrey(self, bGrey)
	if bGrey then
		self.m_UIButton.tweenTarget = nil
	end
	CSprite.SetGrey(self, bGrey)
end

function CButton.InitButtonScale(self)
	if self.m_UIButton then
		self.m_ButtonScale = self.m_GameObject:GetMissingComponent(classtype.UIButtonScale)
		self.m_ButtonScale.hover = Vector3.New(1, 1, 1)
		self.m_ButtonScale.pressed = Vector3.New(0.9, 0.9, 0.9)
	end
end

function CButton.SetSpriteName(self, sSpriteName)
	if self.m_UIButton then
		self.m_UIButton.normalSprite = sSpriteName
	end
	CSprite.SetSpriteName(self, sSpriteName)
end

function CButton.SetEnabled(self, b)
	if self.m_UIButton then
		self.m_UIButton.isEnabled = b
	end
end

function CButton.IsLabelInChild(self)
	if not self.m_ChildLabel then
		local mLabel = self:GetComponentInChildren(classtype.UILabel)
		if mLabel then
			self.m_ChildLabel = CLabel.New(mLabel.gameObject)
		end
	end
	return self.m_ChildLabel ~= nil
end

function CButton.SetText(self, sText, bChild)
	sText = sText or ""
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetText(sText)
	end
	if bChild then
		local sublist = self.m_GameObject:GetComponentsInChildren(classtype.UILabel)
		for i = 1, sublist.Length do
			sublist[i-1].text = sText
		end
	end
end

function CButton.GetText(self)
	if self:IsLabelInChild() then
		return self.m_ChildLabel:GetText()
	end
end

function CButton.GetTextColor(self)
	if self:IsLabelInChild() then
		return self.m_ChildLabel:GetColor()
	end
end

function CButton.SetTextColor(self, color)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetColor(color)
	end
end

function CButton.SetEffectColor(self, color)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetEffectColor(color)
	end
end

function CButton.SetLabelLocalPos(self, pos)
	if self:IsLabelInChild() then
		self.m_ChildLabel:SetLocalPos(pos)
	end
end

function CButton.AddHelpTipClick(self, sKey)
	self:AddUIEvent("click", function()
		CHelpView:ShowView(function (oView)
			oView:ShowHelp(sKey)
		end)
	end)
end

function CButton.AddHelpStringClick(self, str)
	self:AddUIEvent("click", function()
		CHelpView:ShowView(function (oView)
			oView:ShowString(str)
		end)
	end)
end

return CButton