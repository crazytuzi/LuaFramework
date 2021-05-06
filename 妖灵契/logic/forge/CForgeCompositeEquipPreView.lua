-----------------------------------------------------------------------------
--装备的基本属性显示界面


-----------------------------------------------------------------------------

local CForgeCompositeEquipPreView = class("CForgeCompositeEquipPreView", CViewBase)

function CForgeCompositeEquipPreView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeCompositeEquipPreView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	--self.m_OpenEffect = "Scale"
end

function CForgeCompositeEquipPreView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_ItemTipsBox = self:NewUI(2, CItemTipsBox)
	self.m_AttrTable = self:NewUI(3, CTable)
	self.m_ContentCloneBox = self:NewUI(4, CBox)
	self.m_TitleCloneBox = self:NewUI(5, CBox)
	self.m_SpecialCloneBox = self:NewUI(6, CBox)
	self.m_BgSprite	= self:NewUI(7, CSprite)
	self.m_DesLabel = self:NewUI(8, CLabel)
	self.m_CenterSprite = self:NewUI(9, CSprite)
	self:InitContent()
end

function CForgeCompositeEquipPreView.InitContent(self)
	self.m_ContentCloneBox:SetActive(false)
	self.m_TitleCloneBox:SetActive(false)
	self.m_SpecialCloneBox:SetActive(false)
end

function CForgeCompositeEquipPreView.SetContent(self, sid)
	self.m_Item = data.itemdata.EQUIPSTONE[sid]
	self.m_NameLabel:SetText(self.m_Item.name)	
	self.m_ItemTipsBox:SetItemData(sid, 1, nil, {isLocal = true})
	self.m_ItemTipsBox:SetShowTips(false)
	self.m_AttrTable:Clear()

	local str = string.format("[654a33]类型: %s \n[654a33]等级: %s\n[159a80]适用: %s", define.Equip.PosName[self.m_Item.pos], self.m_Item.level, g_ItemCtrl:GetEquipFitInfoBySid(sid))
	self.m_DesLabel:SetText(str)

	local min, max = g_ItemCtrl:GetEquipWaveRange()
	min = min / 100
	max = max / 100
	self:AddTitleBox("[81654d]装备属性")
	local t = {}
	--获取装备的基本属性
	for k,v in pairs (self.m_Item) do
		if define.Attr.String[k] ~= nil and type(v) == "number" and v ~= 0 then
			t[k] = v
		end
	end
	t = g_ItemCtrl:SortAttr(t)
	for k,v in pairs (t) do
		if define.Attr.String[v.key] ~= nil and v.value ~= 0 then
			local sKey = define.Attr.String[v.key] or v.key
			local str = string.format("[654a33]%s+%s~%s", sKey, g_ItemCtrl:AttrStringConvert(v.key, v.value * min) , g_ItemCtrl:AttrStringConvert(v.key, v.value * max))
			self:AddContentBox(str)	
		end
	end
	

	local strSE = "无"
	local oItem = CItem.NewBySid(sid)
	if oItem then
		strSE = oItem:GetEquipSEString()
	end
	if strSE ~= "无" then
		self:AddTitleBox("[81654d]特殊效果")
		self:AddContentSEBox(strSE)	
	end
	
	self:AdjustHeight()
end

function CForgeCompositeEquipPreView.AddContentBox(self, text)
	local tBox = self.m_ContentCloneBox:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel = tBox:NewUI(1, CLabel):SetText(text)
	self.m_AttrTable:AddChild(tBox)
end

function CForgeCompositeEquipPreView.AddContentSEBox(self, text)
	local tBox = self.m_SpecialCloneBox:Clone()
	tBox:SetActive(true)
	tBox.m_ContentLabel = tBox:NewUI(1, CLabel):SetText(text)
	self.m_AttrTable:AddChild(tBox)
end

function CForgeCompositeEquipPreView.AddTitleBox(self, text)
	local tBox = self.m_TitleCloneBox:Clone()
	tBox:SetActive(true)
	tBox.m_TitleLabel = tBox:NewUI(1, CLabel):SetText(text)			
	self.m_AttrTable:AddChild(tBox)
end

function CForgeCompositeEquipPreView.AdjustHeight(self )
	self.m_AttrTable:Reposition()
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_AttrTable.m_Transform)
	self.m_BgSprite:SetHeight( self.m_BgSprite:GetHeight() + bounds.max.y - bounds.min.y)
	self.m_CenterSprite:SetHeight( self.m_CenterSprite:GetHeight() + bounds.max.y - bounds.min.y)
end

return CForgeCompositeEquipPreView