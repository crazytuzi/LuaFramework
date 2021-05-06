local CLimitSkinPage = class("CLimitSkinPage", CPageBase)

function CLimitSkinPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CLimitSkinPage.OnInitPage(self)
	self.m_ConfirmBtn = self:NewUI(1, CButton)
	self.m_TweenObj = self.m_ConfirmBtn:GetComponent(classtype.TweenScale)
	self:InitContent()
end

function CLimitSkinPage.InitContent(self)
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnOpenShop"))
end

function CLimitSkinPage.OnShowPage(self)
	self.m_TweenObj.enabled = true
end

function CLimitSkinPage.OnOpenShop(self)
	self.m_ParentView:CloseView()
	g_NpcShopCtrl:OpenShop(define.Store.Page.PartnerSkin)
end

return CLimitSkinPage