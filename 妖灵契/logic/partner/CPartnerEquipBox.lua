local CPartnerEquipBox = class("CPartnerEquipBox", CBox)

function CPartnerEquipBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PosBox = self:NewUI(1, CBox)
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

function CPartnerEquipBox.InitContent(self)
	self.m_PosSprList = {}
	for i = 1, 6 do
		self.m_PosSprList[i] = self.m_PosBox:NewUI((i+4)%6 + 1, CSprite)
	end
	self.m_StarGrid:SetMaxPerLine(6)
	self.m_StarGrid:Clear()
	self.m_StarSpr:SetParent(self.m_Transform)
	local depth = self.m_StarSpr:GetDepth()
	for i = 1, 6 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(false)
		spr:SetDepth(depth+6-i)
		self.m_StarGrid:AddChild(spr)
	end
	self.m_StarGrid:Reposition()
end

function CPartnerEquipBox.SetItem(self, itemid, pos)
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

function CPartnerEquipBox.SetItemData(self, oItem, pos)
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

function CPartnerEquipBox.SetShape(self, shape)
	local d = DataTools.GetItemData(shape)
	self.m_LevelLabel:SetActive(false)
	self.m_Icon:SetActive(true)
	self.m_StarGrid:SetActive(true)
	self:UpdateIcon(d.icon)
	self:UpdateStar(d.equip_star)
	self:UpdatePos(d.pos)
end

function CPartnerEquipBox.ShowUI(self, bshow)
	self.m_LevelLabel:SetActive(bshow)
	self.m_Icon:SetActive(bshow)
	self.m_StarGrid:SetActive(bshow)
end

function CPartnerEquipBox.UpdateIcon(self, shape)
	self.m_Icon:SpriteItemShape(shape)
end

function CPartnerEquipBox.UpdateLevel(self, level)
	self.m_LevelLabel:SetText(string.format("+%d", level))
end

function CPartnerEquipBox.UpdateStar(self, star)
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
	for i = 1, 6 do
		self.m_PosSprList[i]:SetSpriteName("pic_fuwen_weizhi"..tonumber(iRare))
	end
	self.m_BorderSpr:SetSpriteName("pic_fuwen_xinji"..tonumber(iRare))
	
end

function CPartnerEquipBox.UpdatePos(self, pos)
	for i = 1, 6 do
		self.m_PosSprList[i]:SetActive(false)
	end
	self.m_PosSprList[pos]:SetActive(true)
end

function CPartnerEquipBox.UpdateLock(self, iLock)
	if self.m_LockSpr then
		self.m_LockSpr:SetActive(iLock == 1)
		self.m_LockSpr:SetDepth(110)
	end
end

function CPartnerEquipBox.UpdateWear(self, iPartnerID, inPlan)
	if self.m_WearSpr then
		if iPartnerID ~= 0 or inPlan ~= 0 then
			self.m_WearSpr:SetActive(true)
		else
			self.m_WearSpr:SetActive(false)
		end
	end
end

return CPartnerEquipBox