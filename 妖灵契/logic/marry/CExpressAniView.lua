local CExpressAniView = class("CExpressAniView", CViewBase)

CExpressAniView.AniStatus = {
	MoveLabel = 1,
	MovePanel = 2,
}

function CExpressAniView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressAniView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressAniView.OnCreateView(self)
	self.m_DescLabel = self:NewUI(1, CLabel)
	self.m_TipsLabel = self:NewUI(2, CLabel)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_EndBtn = self:NewUI(4, CBox)
	self.m_Texture = self:NewUI(5, CTexture)
	self.m_Panel = self:NewUI(6, CWidget)
	self.m_DragWidget = self:NewUI(7, CWidget)
	self:InitContent()
end

function CExpressAniView.InitContent(self)
	self.m_ScrollView.m_UIScrollView.momentumAmount = 25
	self.m_LineH = self.m_DescLabel:GetFontSize()
	self.m_PanelStartH = self.m_Panel:GetHeight()
	self.m_ScrollViewH = self.m_ScrollView:GetHeight()
	self.m_PanelTargetH = self.m_PanelStartH + self.m_ScrollViewH + 200
	self.m_TargetH = 0
	self.m_Speed = 1
	self.m_DoubleSpeed = self.m_Speed * 2

	self.m_EndBtn:AddUIEvent("click", callback(self, "OnClickEnd"))
	self.m_DragWidget:AddUIEvent("click", callback(self, "OnClickEnd"))
end

function CExpressAniView.PlayAni(self)
	self:SetContent(g_MarryCtrl.m_ComfirmText)
	self.m_DragWidget:SetEnabled(false)
	
	self.m_IsPlaying = true
	self.m_TipsLabel:SetActive(false)
	self.m_TextH = self.m_DescLabel:GetHeight()

	if self.m_TextH > self.m_ScrollViewH then
		self.m_TargetH = self.m_TextH/2 - self.m_ScrollViewH / 2
	else
		self.m_PanelTargetH = self.m_PanelStartH + self.m_TextH + 200
	end
	-- self.m_StartH = -self.m_ScrollViewH / 2 - self.m_TextH / 2 - self.m_LineH * 2
	self.m_StartH = - self.m_TextH / 2

	self.m_DescLabel:SetLocalPos(Vector3.New(0, self.m_StartH, 0))
	self.m_AniStatus = CExpressAniView.AniStatus.MoveLabel
	self.m_Texture:SetAlpha(0.001)
	self.m_AlphaAction = CActionFloat.New(self.m_Texture, 1, "SetAlpha", 0, 1)
	g_ActionCtrl:AddAction(self.m_AlphaAction, 0)
	Utils.AddTimer(callback(self, "Update"), 0 , 1)
end

function CExpressAniView.ShowPreView(self, sText)
	self:SetContent(sText)
	self.m_Panel:SetHeight(self.m_PanelTargetH)
end

function CExpressAniView.SetContent(self, sText)
	local replaceList = {",", "。", "，", "、"}
	for i,v in ipairs(replaceList) do
		sText = string.replace(sText, v, "")
	end
	self.m_DescLabel:SetText(sText)
end

function CExpressAniView.Update(self)
	if self.m_AniStatus == CExpressAniView.AniStatus.MoveLabel then
		self.m_StartH = self.m_StartH + self.m_Speed
		if self.m_StartH >= self.m_TargetH then
			self.m_DescLabel:SetLocalPos(Vector3.New(0, self.m_TargetH, 0))
			self.m_AniStatus = CExpressAniView.AniStatus.MovePanel
		else
			self.m_DescLabel:SetLocalPos(Vector3.New(0, self.m_StartH, 0))
		end
	elseif self.m_AniStatus == CExpressAniView.AniStatus.MovePanel then
		self.m_PanelStartH = self.m_PanelStartH + self.m_DoubleSpeed
		self.m_Panel:SetHeight(self.m_PanelStartH)
		if self.m_PanelStartH > self.m_PanelTargetH then
			self:OnPlayEnd()
			return false
		end
	end
	return true
end

function CExpressAniView.SetCloseCb(self, cb)
	self.m_CloseCb = cb
end

function CExpressAniView.OnPlayEnd(self)
	self.m_IsPlaying = false
	self.m_TipsLabel:SetActive(true)
	self.m_DragWidget:SetEnabled(true)
end

function CExpressAniView.OnClickEnd(self)
	if self.m_IsPlaying then
		return
	end
	if self.m_CloseCb then
		self.m_CloseCb()
	end
	self:OnClose()
end

return CExpressAniView