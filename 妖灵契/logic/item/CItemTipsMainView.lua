---------------------------------------------------------------
--物品，道具，装备信息预览主界面


---------------------------------------------------------------
local CItemTipsMainView = class("CItemTipsMainView", CViewBase)


function CItemTipsMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
	self.m_OpenView = nil 
end

function CItemTipsMainView.OnCreateView(self)
	self.m_EquipItemInfoPage = self:NewPage(2, CItemTipsEquipInfoPage)
	self.m_ItemPreviewWindowPage = self:NewPage(3, CItemTipsPreviewWindowPage)
	self.m_PartnerSoulInfoPage = self:NewPage(4, CItemTipsPartnerSoulPage)
	self.m_PartnerSkillInfoPage = self:NewPage(5, CPartnerSkillTipsPage)
	self.m_PreviewItemPage = self:NewPage(6, CPreviewItemPage)
	self.m_AwakeItemInfoPage = self:NewPage(7, CItemTipsAwakeItemPage)
	self.m_ParEquipInfoPage = self:NewPage(8, CItemTipsParEquipPage)
	self.m_ItemInfo = nil
end

function CItemTipsMainView.ShowEquipItemInfo(self, tItem, isLink)
	if not tItem then
		self.m_ItemInfo = tItem
	end	
	self:ShowSubPage(self.m_EquipItemInfoPage, tItem, isLink)
end

function CItemTipsMainView.ShowTipsWindowPage(self, sTitle, tContent)
	self:ShowSubPage(self.m_ItemPreviewWindowPage, sTitle, tContent)
end

function CItemTipsMainView.ShowPartnerSoulInfo(self, tItem, args)
	if not tItem then
		self.m_ItemInfo = tItem
	end	
	self:ShowSubPage(self.m_PartnerSoulInfoPage, tItem, args)
end

function CItemTipsMainView.ShowParEquipInfo(self, tItem, args)
	if not tItem then
		self.m_ItemInfo = tItem
	end	
	self:ShowSubPage(self.m_ParEquipInfoPage, tItem, args)
end

function CItemTipsMainView.ShowPartnerSkillInfo(self, skid, level, isawake)
	self:ShowSubPage(self.m_PartnerSkillInfoPage, skid, level, isawake)
end

function CItemTipsMainView.ShowAwakeItemInfo(self, info, args)
	self:ShowSubPage(self.m_AwakeItemInfoPage, info, args)
end

function CItemTipsMainView.ShowPreviewItemPage(self, tExtend)
	self:ShowSubPage(self.m_PreviewItemPage, tExtend)
end

function CItemTipsMainView.SetOpenView(self, oView )
	self.m_OpenView = oView
end

return CItemTipsMainView