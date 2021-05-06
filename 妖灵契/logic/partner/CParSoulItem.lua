local CParSoulItem = class("CParSoulItem", CBox)

function CParSoulItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_BorderSpr = self:NewUI(2, CSprite)
	self.m_LevelLabel = self:NewUI(3, CLabel)
	self.m_AttrSpr = self:NewUI(4, CSprite)
	
	self.m_LockSpr = self:NewUI(5, CSprite, false)
	self.m_WearSpr = self:NewUI(6, CSprite, false)
	self.m_EffectObj = self:NewUI(7, CUIEffect, false)
	self:InitContent()
end

function CParSoulItem.InitContent(self)
	if self.m_EffectObj then
		--table.print(self.m_EffectObj)
		self.m_EffectObj:Above(self.m_Icon)
		self.m_EffectObj:SetActive(false)
	end
end

function CParSoulItem.SetItem(self, itemid, pos)
	self.m_ItemID = itemid
	local oItem = g_ItemCtrl:GetItem(itemid)
	if oItem then
		self:ShowUI(true)
		self:UpdateIcon(oItem:GetValue("icon"))
		self:UpdateLevel(oItem:GetValue("level"))
		self:UpdateQuality(oItem:GetValue("soul_quality"))
		self:UpdateAttrType(oItem:GetValue("attr_type"))
		self:UpdateLock(oItem:GetValue("lock"))
		self:UpdateWear(oItem:GetValue("parid"), 0)
	end
end

function CParSoulItem.SetItemData(self, oItem, pos)
	if oItem then
		self:ShowUI(true)
		self:UpdateIcon(oItem:GetValue("icon"))
		self:UpdateLevel(oItem:GetValue("level"))
		self:UpdateQuality(oItem:GetValue("soul_quality"))
		self:UpdateAttrType(oItem:GetValue("attr_type"))
		self:UpdateLock(oItem:GetValue("lock"))
		self:UpdateWear(oItem:GetValue("parid"), 0)
	else
		self:ShowUI(false)
	end
end

function CParSoulItem.SetShape(self, shape)
	local d = DataTools.GetItemData(shape)
	self.m_LevelLabel:SetActive(false)
	self.m_Icon:SetActive(true)
	self:UpdateIcon(d.icon)
	self:UpdateAttrType(d.attr_type)
end

function CParSoulItem.ShowUI(self, bshow)

end

function CParSoulItem.UpdateIcon(self, shape)
	self.m_Icon:SpriteItemShape(shape)
end

function CParSoulItem.UpdateLevel(self, level)
	self.m_LevelLabel:SetText(string.format("lv.%d", level))
end


function CParSoulItem.UpdateAttrType(self, iAttrType)
	self.m_AttrSpr:SetSpriteName("pic_parattr_"..tostring(iAttrType))
end

function CParSoulItem.UpdateQuality(self, iQuality)
	self.m_BorderSpr:SetSpriteName("pic_yuling_"..tostring(iQuality))
	if self.m_EffectObj then
		self.m_EffectObj:SetActive(iQuality == 5)
	end
end

function CParSoulItem.UpdateLock(self, iLock)
	if self.m_LockSpr then
		self.m_LockSpr:SetActive(iLock == 1)
		self.m_LockSpr:SetDepth(110)
	end
end

function CParSoulItem.UpdateWear(self, iPartnerID)
	if self.m_WearSpr then
		if iPartnerID ~= 0 then
			self.m_WearSpr:SetActive(true)
		else
			self.m_WearSpr:SetActive(false)
		end
	end
end

return CParSoulItem