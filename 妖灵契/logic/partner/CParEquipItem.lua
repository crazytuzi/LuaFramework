local CParEquipItem = class("CParEquipItem", CBox)

function CParEquipItem.ctor(self, obj)
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

function CParEquipItem.InitContent(self)
	self.m_StarGrid:SetMaxPerLine(6)
	for i = 1, 6 do
		local spr = self.m_StarSpr:Clone()
		spr:SetActive(true)
		self.m_StarGrid:AddChild(spr)
	end
	self.m_StarGrid:Reposition()
end

function CParEquipItem.SetItem(self, itemid, pos)
	self.m_ItemID = itemid
	local oItem = g_ItemCtrl:GetItem(itemid)
	if oItem then
		self:ShowUI(true)
		self:UpdateIcon(oItem:GetValue("pos"), oItem:GetValue("stone_level"))
		self:UpdateLevel(oItem:GetValue("level"))
		self:UpdateStar(oItem:GetValue("star"))
		self:UpdatePos(oItem:GetValue("pos"))
		self:UpdateLock(oItem:IsEuqipLock())
		self:UpdateWear(oItem:GetValue("parid"), 0)
	else
		self:ShowUI(false)
		if pos then
			self:UpdatePos(pos)
		end
	end
end

function CParEquipItem.SetItemData(self, oItem, pos)
	if oItem then
		self:ShowUI(true)
		self:UpdateIcon(oItem:GetValue("pos"), oItem:GetValue("stone_level"))
		self:UpdateLevel(oItem:GetValue("level"))
		self:UpdateStar(oItem:GetValue("star"))
		self:UpdatePos(oItem:GetValue("pos"))
		self:UpdateLock(oItem:GetValue("lock"))
		self:UpdateWear(oItem:GetValue("parid"), 0)
	else
		self:ShowUI(false)
		if pos then
			self:UpdatePos(pos)
		end
	end
end

function CParEquipItem.SetShape(self, shape)
	local d = DataTools.GetItemData(shape)
	self.m_LevelLabel:SetActive(false)
	self.m_Icon:SetActive(true)
	self.m_StarGrid:SetActive(true)
	self:UpdateIcon(d.pos, 1)
	self:UpdateStar(d.star)
	self:UpdatePos(d.pos)
end

function CParEquipItem.ShowUI(self, bshow)
	self.m_LevelLabel:SetActive(bshow)
	self.m_Icon:SetActive(bshow)
	self.m_StarGrid:SetActive(bshow)
end

function CParEquipItem.UpdateIcon(self, iPos, iQuality)
	local icon = self:GetIcon(iPos, iQuality)
	self.m_Icon:SpriteItemShape(icon)
end

function CParEquipItem.UpdateLevel(self, level)
	self.m_LevelLabel:SetText(string.format("+%d", level))
end

function CParEquipItem.UpdateStar(self, star)
	for i, spr in ipairs(self.m_StarGrid:GetChildList()) do
		if star >= i then
			spr:SetSpriteName("pic_chouka_dianliang")
		else
			spr:SetSpriteName("pic_chouka_weidianliang")
		end
	end
	--self.m_StarGrid:Reposition()
end

function CParEquipItem.UpdatePos(self, pos)
	
end

function CParEquipItem.GetIcon(cls, iPos, iQuality)
	local a = iQuality
	iQuality = iQuality or 1
	iPos = iPos or 1
	local icon = 6000000 + iPos * 100000 + iQuality * 1000 + 1
	return icon
end

function CParEquipItem.UpdateLock(self, iLock)
	if self.m_LockSpr then
		self.m_LockSpr:SetActive(iLock == 1)
		self.m_LockSpr:SetDepth(110)
	end
end

function CParEquipItem.UpdateWear(self, iPartnerID, inPlan)
	if self.m_WearSpr then
		if iPartnerID ~= 0 or inPlan ~= 0 then
			self.m_WearSpr:SetActive(true)
		else
			self.m_WearSpr:SetActive(false)
		end
	end
end

return CParEquipItem