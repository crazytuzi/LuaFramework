---------------------------------------------------------------
--打造界面主界面


---------------------------------------------------------------

local CForgeCompositeSelectView = class("CForgeCompositeSelectView", CViewBase)


function CForgeCompositeSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeCompositeSelectView.prefab", cb)
	--界面设置
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CForgeCompositeSelectView.OnCreateView(self)
	self.m_EquipGrid = self:NewUI(1, CGrid)
	self.m_EquipCloneBox = self:NewUI(2, CBox)

	self.m_EquipList = {}
	self.m_EquipBoxList = {}
	self:InitContent()
end

function CForgeCompositeSelectView.InitContent(self)	
	self.m_EquipCloneBox:SetActive(false)
end

function CForgeCompositeSelectView.SetData(self, pos, level)
	self:RefreshAll(pos, level)
end

function CForgeCompositeSelectView.RefreshAll(self, pos, level)
	local cpd = g_ItemCtrl:GetCompositeDataByPosAndLevel(pos, level)
	if not cpd then
		return
	end
	self.m_EquipList = g_ItemCtrl:GetCompositeUpgradeBySid(pos, cpd.upgrade_weapon)
	if not next(self.m_EquipList) then
		return
	end
	for i = 1, #self.m_EquipList do
		local oBox = self.m_EquipBoxList[i]
		if not oBox then
			oBox = self.m_EquipCloneBox:Clone()
			oBox.m_IconSpr = oBox:NewUI(1, CSprite)
			oBox.m_QualitySpr = oBox:NewUI(2, CSprite)
			oBox.m_NameLabel = oBox:NewUI(3, CLabel)
			oBox.m_LvLabel = oBox:NewUI(4, CLabel)
			oBox.m_SelNameLabel = oBox:NewUI(5, CLabel)
			oBox.m_SelLvLabel = oBox:NewUI(6, CLabel)			
			oBox.m_SelectSpr = oBox:NewUI(7, CSprite)
			self.m_EquipGrid:AddChild(oBox)
			table.insert(self.m_EquipBoxList, oBox)
		end
		oBox:SetActive(true)
		local oItem = self.m_EquipList[i]
		oBox.m_IconSpr:SpriteItemShape(oItem:GetValue("icon"))
		oBox.m_QualitySpr:SetItemQuality(oItem:GetValue("itemlevel"))
		oBox.m_NameLabel:SetText(oItem:GetValue("name"))
		local level = oItem:GetValue("equip_level") or oItem:GetValue("level") --身上的装备则是equip_level 
		oBox.m_LvLabel:SetText(string.format("Lv.%d", level))
		oBox.m_SelNameLabel:SetText(oItem:GetValue("name"))
		oBox.m_SelLvLabel:SetText(string.format("Lv.%d", level))		
		oBox.m_SelectSpr:SetActive(false)
		oBox:AddUIEvent("click", callback(self, "OnClickEquipBox", i))
		oBox:AddUIEvent("longpress", callback(self, "OnLongPressEquipBox", i))
	end
	if #self.m_EquipList < #self.m_EquipBoxList then
		for i = #self.m_EquipList + 1, #self.m_EquipBoxList do
			local oBox = self.m_EquipBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
end

function CForgeCompositeSelectView.OnClickEquipBox(self, idx)
	local oItem = self.m_EquipList[idx]
	if oItem then
		local oView = CForgeMainView:GetView()
		if oView then
			oView.m_CompositePage:SelectUpgradeItem(oItem)
		end
	end
	self:CloseView()
end

function CForgeCompositeSelectView.OnLongPressEquipBox(self, idx)
	local oItem = self.m_EquipList[idx]
	if oItem then
		g_WindowTipCtrl:SetWindowItemTipsEquipItemSell(oItem,
		{widget = self, side = enum.UIAnchor.Side.Right,offset = Vector2.New(0, 0), showCenterMaskWidget = true})
	end
end

return CForgeCompositeSelectView