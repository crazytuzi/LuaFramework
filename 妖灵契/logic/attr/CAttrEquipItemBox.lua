local CAttrEquipItemBox = class("CAttrEquipItemBox", CBox)

CAttrEquipItemBox.AttrColor = {
	[1] = {255/255, 255/255,255/255, 255/255},	--"ffffff", --白 
	[2] = {166/255, 78/255,0/255, 255/255},	-- "a64e00",	--蓝	
	[3] = {00/255, 129/255,171/255, 255/255},	--"0081ab", --紫
	[4] = {197/255, 10/255,219/255, 255/255},	--"c50adb", --橙
	[5] = {29/255, 142/255,0/255, 255/255},	-- "1d8e00", --绿
}

function CAttrEquipItemBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_MainEquipItem = nil;
	self.m_SubEquipItem = nil;

	self.m_MainEquipSprite = self:NewUI(1, CSprite)
	self.m_MainEuqipNameLabel = self:NewUI(2, CLabel)
	self.m_MainEquipGradeLabel = self:NewUI(3, CLabel)
	self.m_MainQualitySprite = self:NewUI(4, CSprite)
	self.m_SubEquiptSprite = self:NewUI(5, CSprite)
	self.m_SubQualitySprite = self:NewUI(6, CSprite)	
	self.m_Effect = self:NewUI(7, CUIEffect, false)

	self:AddUIEvent("click", callback(self, "OnClickMainEuqip"))
	self.m_SubEquiptSprite:AddUIEvent("click", callback(self, "OnClickSubEuqip"))

	self:ResetStatus()
end


function CAttrEquipItemBox.SetMainEquipItem(self, oItem, pos)

	if not oItem then
		return
	end
	self.m_MainEquipItem = oItem

	local shape = oItem:GetValue("icon") or 0
	local name = oItem:GetValue("name")
	local grade = oItem:GetValue("equip_level") or 0
	local quality = oItem:GetValue("itemlevel")

	self.m_MainEquipSprite:SpriteItemShape(shape)	
				 
	if name then  
		--self.m_MainEuqipNameLabel:SetActive(true)
		self.m_MainEuqipNameLabel:SetText(name)
	end 


	if grade then
		self.m_MainEquipGradeLabel:SetText("Lv:"..tostring(grade))
	end

	if quality then 
		--local color = self:GetQualityColor(quality)
		self.m_MainQualitySprite:SetItemSecondQuality(quality)
		if self.m_Effect then
			self.m_Effect:SetActive(quality == 4 or quality == 5)
			self.m_Effect:Above(self.m_MainEquipSprite)
		end
	end 	

	--TODO 副武器
	-- if pos == 1 then

	-- end

end	
function CAttrEquipItemBox.SetSubEquipItem(self, oItem)

	if not oItem then
		return
	end

	self.m_SubEquipItem = oItem

	local shape = oItem:GetValue("icon") or 0
	local quality = oItem:GetValue("itemlevel")

	self.m_SubEquiptSprite:SetActive(true)		 
	self.m_SubEquiptSprite:SpriteItemShape(shape)
	--TEST
		quality = 5
	--TEST

	if quality then 
		local color = self:GetQualityColor(quality)
		self.m_SubQualitySprite:SetActive(true)
		self.m_SubQualitySprite:SetColor(color)
	end 	
end	

function CAttrEquipItemBox.SetQuality(self, tobj, quality)
	if quality then
		self.m_QualitySprite:SetActive(true)
		self.m_QualitySprite:SetItemColorQuality(quality)			
	else
		self.m_QualitySprite:SetActive(false)
	end
end

function CAttrEquipItemBox.ResetStatus( self )
	self.m_MainEuqipNameLabel:SetActive(false)
	self.m_SubEquiptSprite:SetActive(false)
end

function CAttrEquipItemBox.OnClickMainEuqip(self)
 	g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(self.m_MainEquipItem,
	 	{widget=  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
end

function CAttrEquipItemBox.OnClickSubEuqip(self)
	g_WindowTipCtrl:SetWindowItemTipsEquipItemInfo(self.m_SubEquipItem, 
		{widget=  self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0)})
end

function CAttrEquipItemBox.GetQualityColor(self, quality)
	
	if quality > 5 or quality < 1 then
		quality = 1
	end
	local color = Color.New(
			CAttrEquipItemBox.AttrColor[quality][1],
			CAttrEquipItemBox.AttrColor[quality][2],
			CAttrEquipItemBox.AttrColor[quality][3],
			CAttrEquipItemBox.AttrColor[quality][4]
			)
	return color
end

return CAttrEquipItemBox