local CAttrLinkView = class("CAttrLinkView", CViewBase)

function CAttrLinkView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Attr/AttrLinkView.prefab", cb)
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CAttrLinkView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CTabGrid)
	self.m_Container = self:NewUI(3, CBox)
	self.m_AttrMainPage = self:NewPage(4, CAttrLinkPage)
	self:InitContent()
end

function CAttrLinkView.InitContent(self)
	--UITools.ResizeToRootSize(self.m_Container)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:ShowAttrPage()
end

function CAttrLinkView.ShowAttrPage(self)
	self:ShowSubPage(self.m_AttrMainPage)
end

function CAttrLinkView.RefreshData(self, data)
	self.m_AttrMainPage:RefreshData(data)
end

return CAttrLinkView
