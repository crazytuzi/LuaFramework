local CItemAdviceView = class("CItemAdviceView", CViewBase)

function CItemAdviceView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemAdviceView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CItemAdviceView.OnCreateView(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_RareSpr = self:NewUI(4, CSprite)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CItemAdviceView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
end

function CItemAdviceView.UpdateItem(self, itemid)
	self.m_ID = itemid
	local itemobj = DataTools.GetItemData(itemid)
	self.m_NameLabel:SetText(itemobj["name"])
	self.m_Icon:SpriteItemShape(itemobj["icon"])
	self.m_RareSpr:SetItemQuality(itemobj["quality"])
end

return CItemAdviceView