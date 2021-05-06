local CTravelPartnerConfirmView = class("CTravelPartnerConfirmView", CViewBase)

function CTravelPartnerConfirmView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Travel/TravelPartnerConfirmView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CTravelPartnerConfirmView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_InfoLabel = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_CancelBtn = self:NewUI(4, CButton)
	self.m_OKBtn = self:NewUI(5, CButton)
	self.m_PartnerBox = self:NewUI(6, CBox)

	self.m_OkCallback = nil
	self:InitPartnerBox()
	self:InitContent()
end

function CTravelPartnerConfirmView.InitPartnerBox(self)
	self.m_PartnerBox.m_BoderSpr = self.m_PartnerBox:NewUI(1, CSprite)
	self.m_PartnerBox.m_Icon = self.m_PartnerBox:NewUI(2, CSprite)
	self.m_PartnerBox.m_StarGrid = self.m_PartnerBox:NewUI(3, CGrid)
	self.m_PartnerBox.m_StarSpr = self.m_PartnerBox:NewUI(4, CSprite)
	self.m_PartnerBox.m_AwakeSpr = self.m_PartnerBox:NewUI(5, CSprite)
	self.m_PartnerBox.m_GradeLabel = self.m_PartnerBox:NewUI(6, CLabel)
	self.m_PartnerBox.m_StarSpr:SetActive(false)
	for i = 1, 5 do
		local oSpr = self.m_PartnerBox.m_StarSpr:Clone()
		oSpr:SetActive(true)
		self.m_PartnerBox.m_StarGrid:AddChild(oSpr)
	end
	self.m_PartnerBox.m_StarGrid:Reposition()
end

function CTravelPartnerConfirmView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OKBtn:AddUIEvent("click", callback(self, "OnOKBtn"))
end

function CTravelPartnerConfirmView.RefreshView(self, parid, title, msg, okcb)
	self.m_OkCallback = okcb
	self.m_TitleLabel:SetText(title)
	self.m_InfoLabel:SetText(msg)
	self:RefreshPartnerBox(parid)
end

function CTravelPartnerConfirmView.RefreshPartnerBox(self, parid)
	local oBox = self.m_PartnerBox
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	local icon = oPartner:GetIcon()
	oBox.m_Icon:SpriteAvatar(icon)

	local star = oPartner:GetValue("star")
	for i, oSpr in ipairs(oBox.m_StarGrid:GetChildList()) do
		if star >= i then
			oSpr:SetSpriteName("pic_chouka_dianliang")
		else
			oSpr:SetSpriteName("pic_chouka_weidianliang")
		end
	end

	local rare = oPartner:GetValue("rare")
	local sSprite = self.m_PartnerBox.m_BoderSpr:GetSpriteName()
	if string.startswith(sSprite, "bg_haoyoukuang_") then
		local filename = define.Partner.CardColor[rare] or "hui"
		self.m_PartnerBox.m_BoderSpr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
	elseif string.startswith(sSprite, "bg_huobankuang_") then
		self.m_PartnerBox.m_BoderSpr:SetSpriteName(string.format("bg_huobankuang_da%d", rare))
	end

	local awake = oPartner:GetValue("awake")
	oBox.m_AwakeSpr:SetActive(awake == 1)

	local grade = oPartner:GetValue("grade")
	oBox.m_GradeLabel:SetText(string.format("%d", grade))
end

function CTravelPartnerConfirmView.OnOKBtn(self)
	if self.m_OkCallback then
		self.m_OkCallback()
	end
	self.m_OkCallback = nil
	self:OnClose()
end

return CTravelPartnerConfirmView