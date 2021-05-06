local CWindowInstructionView = class("CWindowInstructionView", CViewBase)

function CWindowInstructionView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowInstructionView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CWindowInstructionView.OnCreateView(self)
	self.m_TipWidget = self:NewUI(1, CWidget)
	self.m_tipsTitle = self:NewUI(2, CLabel)
	self.m_tipsDesc = self:NewUI(3, CLabel)
	self.m_ScrollView = self:NewUI(4, CScrollView)
	self.m_tipBG = self:NewUI(5, CSprite)

	self.m_TipWidget:AddUIEvent("click", callback(self, "OnClose"))
end

function CWindowInstructionView.SetWindowInstructionInfo(self, content)
	local Content = content or {title = "",desc = ""}
	self.m_tipsTitle:SetText(Content.title)
	self.m_tipsDesc:SetText(Content.desc)

	local Height = UITools.CalculateRelativeWidgetBounds(self.m_tipsDesc.m_Transform).size.y
	if Height >= define.Instruction.View.MaxHeight then
		self.m_tipBG:SetHeight(define.Instruction.View.MaxHeight)
		self.m_TipWidget:SetLocalPos(Vector3(0,0,0))

		self.m_tipsDesc:SetParent(self.m_ScrollView.m_Transform)
		self.m_ScrollView:ResetPosition()
	else
		self.m_tipBG:SetHeight(Height + define.Instruction.View.MinHeight)
		local ViewDefine = define.Instruction.View
		local YPos = -(ViewDefine.YLength) + (ViewDefine.YLength/ViewDefine.Pixel) *(Height + ViewDefine.MinHeight - ViewDefine.MinPixel)
		self.m_TipWidget:SetLocalPos(Vector3(0,YPos,0))

		self.m_tipsDesc:SetParent(self.m_TipWidget.m_Transform)
	end
end
return CWindowInstructionView