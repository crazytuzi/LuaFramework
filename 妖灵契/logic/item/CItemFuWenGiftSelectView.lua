local CItemFuWenGiftSelectView = class("CItemFuWenGiftSelectView", CViewBase)

function CItemFuWenGiftSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemFuWenGiftSelectView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CItemFuWenGiftSelectView.OnCreateView(self)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_ItemGird = self:NewUI(2, CGrid)
	self.m_CloneBox = self:NewUI(3, CBox)
	self.m_OkBtn = self:NewUI(4, CButton)
	self.m_ScrollView = self:NewUI(5, CScrollView)

	self:InitContent()
end

function CItemFuWenGiftSelectView.InitContent(self)
	self.m_CloneBox:SetActive(false)
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
end

function CItemFuWenGiftSelectView.SetItem(self, itemId, id)
	self.m_ItemId = itemId
	self.m_Id = id
	g_ItemCtrl.m_CurUseItemId = id
	if self.m_ItemId then
		self:UpdatePackage()
	end
end

function CItemFuWenGiftSelectView.SelectCoreType(self, iParID)
	self:UpdateCore()
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnSelectCoreType", iParID))
end

function CItemFuWenGiftSelectView.UpdatePackage(self)
	local oItem = CItem.NewBySid(self.m_ItemId)
	local use_reward = oItem:GetValue("use_reward")
	self.m_TitleLabel:SetText(oItem:GetValue("name"))
	local dData = data.partnerequipdata.ParSoulType
	for i,v in ipairs(use_reward) do
		local equiptype = tonumber(v.sid)
		local d = dData[equiptype]
		if d then
			local oBox = self.m_CloneBox:Clone()
			oBox:SetActive(true)
			oBox.m_UnSelectSpr = oBox:NewUI(1, CSprite)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			oBox.m_IconSprite = oBox:NewUI(3, CSprite)
			oBox.m_NameLabel = oBox:NewUI(4, CLabel)
			oBox.m_DescLabel = oBox:NewUI(5, CLabel)
			oBox.m_StarGird = oBox:NewUI(6, CGrid)
			oBox.m_StarSpr = oBox:NewUI(7, CSprite)
			oBox.m_UnSelectSpr:SetActive(true)
			oBox.m_SelectSpr:SetActive(false)
			oBox.m_StarSpr:SetActive(false)

			oBox.m_Sid = v.sid
			oBox.m_IconSprite:SpriteItemShape(d.icon)
			oBox.m_NameLabel:SetText(d.name)
			local typelist = {}
			if d["skill_desc"] then
				table.insert(typelist, d["skill_desc"])
			end
			local typestr = table.concat(typelist, "\n\n")
			oBox.m_DescLabel:SetText(typestr)
			self.m_ItemGird:AddChild(oBox)
			oBox:AddUIEvent("click", callback(self, "OnClickItem"))
		end
	end
	self.m_ItemGird:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CItemFuWenGiftSelectView.UpdateCore(self)
	self.m_TitleLabel:SetText("请选择核心")
	local dData = data.partnerequipdata.ParSoulType
	for i,v in pairs(dData) do
		--local equiptype = tonumber(v.sid)
		local d = v
		if d then
			local oBox = self.m_CloneBox:Clone()
			oBox:SetActive(true)
			oBox.m_UnSelectSpr = oBox:NewUI(1, CSprite)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			oBox.m_IconSprite = oBox:NewUI(3, CSprite)
			oBox.m_NameLabel = oBox:NewUI(4, CLabel)
			oBox.m_DescLabel = oBox:NewUI(5, CLabel)
			oBox.m_StarGird = oBox:NewUI(6, CGrid)
			oBox.m_StarSpr = oBox:NewUI(7, CSprite)
			oBox.m_UnSelectSpr:SetActive(true)
			oBox.m_SelectSpr:SetActive(false)
			oBox.m_StarSpr:SetActive(false)

			oBox.m_Sid = v.id
			oBox.m_IconSprite:SpriteItemShape(d.icon)
			oBox.m_NameLabel:SetText(d.name)
			local typelist = {}
			if d["skill_desc"] then
				table.insert(typelist, d["skill_desc"])
			end
			local typestr = table.concat(typelist, "\n\n")
			oBox.m_DescLabel:SetText(typestr)
			self.m_ItemGird:AddChild(oBox)
			oBox:AddUIEvent("click", callback(self, "OnClickItem"))
		end
	end
	self.m_ItemGird:Reposition()
	self.m_ScrollView:ResetPosition()
end

function CItemFuWenGiftSelectView.OnClickItem(self, oBox)
	if self.m_CurBox then
		self.m_CurBox.m_UnSelectSpr:SetActive(true)
		self.m_CurBox.m_SelectSpr:SetActive(false)
	end
	self.m_CurBox = oBox
	self.m_CurBox.m_UnSelectSpr:SetActive(false)
	self.m_CurBox.m_SelectSpr:SetActive(true)
end

function CItemFuWenGiftSelectView.OnClickOk(self, oBtn)
	if not self.m_CurBox then
		g_NotifyCtrl:FloatMsg("请选择奖励内容")
		return
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSChooseItem"]) then
		netitem.C2GSChooseItem(self.m_Id, {self.m_CurBox.m_Sid}, 1)
	end
	self:CloseView()
end

function CItemFuWenGiftSelectView.OnSelectCoreType(self, iParID)
	if not self.m_CurBox then
		g_NotifyCtrl:FloatMsg("请选择核心类型")
		return
	end
	netpartner.C2GSUsePartnerSoulType(self.m_CurBox.m_Sid, {}, iParID)
	self:CloseView()
end

return CItemFuWenGiftSelectView