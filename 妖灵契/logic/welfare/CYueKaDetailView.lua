local CYueKaDetailView = class("CYueKaDetailView", CViewBase)

function CYueKaDetailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Welfare/YueKaDetailView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
end

function CYueKaDetailView.OnCreateView(self)
	self.m_DetailLabel = self:NewUI(1, CLabel)
end

function CYueKaDetailView.SetDetail(self, text)
	self.m_DetailLabel:SetText(text)
end

return CYueKaDetailView