CChipCard = class("CChipCard", CBox)

function CChipCard.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_RareSpr = self:NewUI(1, CSprite)
	self.m_RareInSpr = self:NewUI(2, CSprite)
	self.m_RareOutSpr = self:NewUI(3, CSprite)
	self.m_PartnerTexture = self:NewUI(4, CTexture)
	self.m_NameLabel = self:NewUI(5, CLabel)
	self.m_Slider = self:NewUI(6, CSlider)
	self.m_RareTxtSpr = self:NewUI(7, CSprite)
	self.m_ComposeSprite = self:NewUI(8, CSprite)
	self.m_WenHaoSprite = self:NewUI(9, CSprite)
	--self.m_ComposeSprite:AddUIEvent("click", callback(self, "OnCompose"))
end

function CChipCard.SetChipItem(self, oItem)
	self.m_Item = oItem
	self.m_ChipType = oItem:GetValue("sid")
	self.m_ItemID = oItem.m_ID
	self:RefreshUI(oItem)
end

function CChipCard.OnCompose(self, oSprite)
	netpartner.C2GSComposePartner(self.m_Item:GetValue("sid"), 1)
end

function CChipCard.RefreshUI(self, oItem)
	if oItem then
		self.m_PartnerTexture:LoadCardPhoto(oItem:GetValue("shape"))
		self:RefreshRare(oItem:GetValue("rare"))
		self.m_NameLabel:SetText(oItem:GetValue("name"))
		local amount = oItem:GetValue("amount")
		local compose_amount = oItem:GetValue("compose_amount")
		self.m_Slider:SetValue(amount/compose_amount)
		self.m_Slider:SetSliderText(string.format("%d/%d", amount, compose_amount))
		local bCompose = amount >= compose_amount
		self.m_ComposeSprite:SetActive(bCompose)
		self.m_WenHaoSprite:SetActive(not bCompose)
		local textureColor = Color.black
		if bCompose then
			textureColor = Color.white
		end
		self.m_PartnerTexture:SetColor(textureColor)
	end
end

local Rare2Name = {
	"huise", "lanse", "zise", "jinse",
}

function CChipCard.RefreshRare(self, iRare)
	self.m_RareInSpr:SetSpriteName(string.format("bg_rare2_%d", iRare))
	self.m_RareOutSpr:SetSpriteName(string.format("bg_rare1_%d", iRare))
	self.m_RareSpr:SetSpriteName(string.format("pic_suipian_%s", Rare2Name[iRare]))
	self.m_RareTxtSpr:SetSpriteName(string.format("pic_cardrare_%d", iRare))
end

return CChipCard
