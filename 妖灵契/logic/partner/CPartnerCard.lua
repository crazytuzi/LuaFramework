CPartnerCard = class("CPartnerCard", CBox)

function CPartnerCard.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_RareInSpr = self:NewUI(2, CSprite)
	self.m_RareOutSpr = self:NewUI(3, CSprite)
	self.m_PartnerTexture = self:NewUI(4, CTexture)
	self.m_GradeLabel = self:NewUI(5, CLabel)
	self.m_FightSpr = self:NewUI(6, CSprite)
	self.m_AwakeSpr = self:NewUI(7, CSprite)
	self.m_StarGrid = self:NewUI(8, CGrid)
	self.m_StarSpr = self:NewUI(9, CSprite)
	self.m_LockSpr = self:NewUI(10, CSprite)
	self.m_RareTxtSpr = self:NewUI(11, CSprite)
	self.m_SelSpr = self:NewUI(12, CSprite, false)
	self:InitContent()
end

function CPartnerCard.InitContent(self)
	self.m_StarSpr:SetActive(false)
end

function CPartnerCard.SetPartnerID(self, parid)
	self.m_PartnerID = parid
	self:RefreshUI()
end

function CPartnerCard.RefreshUI(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_PartnerID)
	if oPartner then
		self.m_PartnerTexture:SetActive(false)
		self.m_PartnerTexture:LoadCardPhoto(oPartner:GetValue("shape"), function() self.m_PartnerTexture:SetActive(true) end)
		self.m_GradeLabel:SetText(tostring(oPartner:GetValue("grade")))
		self.m_NameLabel:SetText(oPartner:GetValue("name"))
		self:RefreshRare(oPartner:GetValue("rare"))
		self:RefreshStar(oPartner:GetValue("star"))
		if self.m_SelSpr then
			self.m_SelSpr:SetActive(false)
		end
		local iPos = g_PartnerCtrl:GetFightPos(oPartner.m_ID)
		if iPos then
			self.m_FightSpr:SetActive(true)
			if iPos == 1 then
				self.m_FightSpr:SetSpriteName("pic_zhuzhanzuo_xiaotubiao")
			else
				self.m_FightSpr:SetSpriteName("pic_fuzhanzuo_xiaotubiao")
			end
		else
			self.m_FightSpr:SetActive(false)
		end
		self.m_AwakeSpr:SetActive(oPartner:GetValue("awake") == 1)
		self.m_LockSpr:SetActive(oPartner:IsLock())
	end
end

function CPartnerCard.RefreshRare(self, iRare)
	self.m_RareInSpr:SetSpriteName(string.format("pic_card_out%d", iRare))
	self.m_RareOutSpr:SetSpriteName(string.format("pic_card_in%d", iRare))
	self.m_RareTxtSpr:SetSpriteName(string.format("pic_cardrare_%d", iRare))
end

function CPartnerCard.RefreshStar(self, iStar)
	if #self.m_StarGrid:GetChildList() <= 0 then
		self.m_StarGrid:Clear()
		for i = 1, 5 do
			local spr = self.m_StarSpr:Clone()
			spr:SetActive(true)
			self.m_StarGrid:AddChild(spr)
		end
		self.m_StarGrid:Reposition()
	end
	for i, spr in ipairs(self.m_StarGrid:GetChildList()) do
		if iStar >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
end

function CPartnerCard.SetSelect(self, bSelected)
	if self.m_SelSpr then
		self.m_SelSpr:SetActive(bSelected)
	end
end

return CPartnerCard