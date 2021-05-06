local CPartnerEquipItem = class("CPartnerEquipItem", CBox)

function CPartnerEquipItem.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Icon = self:NewUI(2, CSprite)
	self.m_StarGrid = self:NewUI(3, CGrid)
	self.m_StarSpr = self:NewUI(4, CSprite)
	self.m_StarSpr:SetActive(false)
	self.m_LevelLabel = self:NewUI(5, CLabel)
	self.m_BorderSpr = self:NewUI(6, CSprite)
	self.m_WearSpr = self:NewUI(7, CSprite, false)
	self.m_LockSpr = self:NewUI(8, CSprite, false)
	self:InitContent()
end

function CPartnerEquipItem.InitContent(self)
	self.m_StarGrid:SetMaxPerLine(6)
	for i = 1, 6 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(false)
		self.m_StarGrid:AddChild(spr)
	end
	self.m_StarGrid:Reposition()
end

function CPartnerEquipItem.SetItem(self, itemid, pos)
	self.m_ItemID = itemid
	local oItem = g_ItemCtrl:GetItem(itemid)
	if oItem then
		self:ShowUI(true)
		self:UpdateIcon(oItem:GetValue("icon"))
		self:UpdateLevel(oItem:GetValue("level"))
		self:UpdateStar(oItem:GetValue("equip_star"))
		self:UpdatePos(oItem:GetValue("pos"), oItem:GetValue("lock"))
		self:UpdateLock(oItem:GetValue("lock"))
		self:UpdateWear(oItem:GetValue("partner_id"), oItem:GetValue("in_plan"))
	else
		self:ShowUI(false)
		if pos then
			self:UpdatePos(pos)
		end
	end
end

function CPartnerEquipItem.SetItemData(self, oItem, pos)
	if oItem then
		self:ShowUI(true)
		self:UpdateIcon(oItem:GetValue("icon"))
		self:UpdateLevel(oItem:GetValue("level"))
		self:UpdateStar(oItem:GetValue("equip_star"))
		self:UpdatePos(oItem:GetValue("pos"))
		self:UpdateLock(oItem:GetValue("lock"))
		self:UpdateWear(oItem:GetValue("partner_id"), oItem:GetValue("in_plan"))
	else
		self:ShowUI(false)
		if pos then
			self:UpdatePos(pos)
		end
	end
end

function CPartnerEquipItem.SetShape(self, shape)
	local d = DataTools.GetItemData(shape)
	self.m_LevelLabel:SetActive(false)
	self.m_Icon:SetActive(true)
	self.m_StarGrid:SetActive(true)
	self:UpdateIcon(d.icon)
	self:UpdateStar(d.equip_star)
	self:UpdatePos(d.pos)
end

function CPartnerEquipItem.ShowUI(self, bshow)
	self.m_LevelLabel:SetActive(bshow)
	self.m_Icon:SetActive(bshow)
	self.m_StarGrid:SetActive(bshow)
end

function CPartnerEquipItem.UpdateIcon(self, shape)
	self.m_Icon:SpriteItemShape(shape)
end

function CPartnerEquipItem.UpdateLevel(self, level)
	self.m_LevelLabel:SetText(string.format("+%d", level))
end

function CPartnerEquipItem.UpdateStar(self, star)
	self.m_StarGrid:SetHideInactive(false)
	for i, spr in ipairs(self.m_StarGrid:GetChildList()) do
		if star >= i then
			spr:SetActive(true)
		else
			spr:SetActive(false)
		end
	end
	self.m_StarGrid:SetHideInactive(true)
	self.m_StarGrid:Reposition()
	local iRare = 1
	if star > 5 then
		iRare = 4
	elseif star > 4 then
		iRare = 3
	elseif star > 2 then
		iRare = 2
	end
	self.m_BorderSpr:SetSpriteName("pic_fuwen_xj"..tonumber(iRare))
end

function CPartnerEquipItem.UpdatePos(self, pos)
	local pos2angle = {90, 180, -90, 0}
	local v = Quaternion.Euler(0, 0, pos2angle[pos] or 0)
	self.m_BorderSpr:SetLocalRotation(v)
end

function CPartnerEquipItem.UpdateLock(self, iLock)
	if self.m_LockSpr then
		self.m_LockSpr:SetActive(iLock == 1)
		self.m_LockSpr:SetDepth(110)
	end
end

function CPartnerEquipItem.UpdateWear(self, iPartnerID, inPlan)
	if self.m_WearSpr then
		if iPartnerID ~= 0 or inPlan ~= 0 then
			self.m_WearSpr:SetActive(true)
		else
			self.m_WearSpr:SetActive(false)
		end
	end
end

return CPartnerEquipItem