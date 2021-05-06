local CWarFailView = class("", CViewBase)

function CWarFailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarFailView.prefab", cb)

	self.m_ExtendClose = "Black"
end

function CWarFailView.OnCreateView(self)

	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CWarFailView.CloseView(self)
	g_WarCtrl:SetInResult(false)
	CViewBase.CloseView(self)
end

function CWarFailView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	CViewBase.Destroy(self)
end

return CWarFailView