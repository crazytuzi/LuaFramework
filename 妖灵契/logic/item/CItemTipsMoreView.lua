---------------------------------------------------------------
--物品 补充功能界面
--功能1：出售
--功能2：批量使用

---------------------------------------------------------------
local CItemTipsMoreView = class("CItemTipsMoreView", CViewBase)


function CItemTipsMoreView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsMoreView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "ClickOut"
end

function CItemTipsMoreView.OnCreateView(self)

	self.m_ItemSellPage = self:NewPage(1, CItemTipsMoreSellPage)
	self.m_ItemBatUsePage = self:NewPage(2, CItemTipsMoreBatUsePage)

	self.m_ItemInfo = nil
end

function CItemTipsMoreView.ShowSellPage(self, tItem)
	if not tItem  then
		self.m_ItemInfo = tItem
	end
	self:ShowSubPage(self.m_ItemSellPage, tItem)
end

function CItemTipsMoreView.ShowBatUsePage(self, tItem)

	if not tItem  then
		self.m_ItemInfo = tItem
	end	

	self:ShowSubPage(self.m_ItemBatUsePage, tItem)
end


return CItemTipsMoreView