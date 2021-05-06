local CWindowEquipEffectTipView = class("CWindowEquipEffectTipView", CViewBase)

function CWindowEquipEffectTipView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowEquipEffectTipView.prefab", cb)
	self.m_DepthType = "Dialog"
	-- self.m_ExtendClose = "ClickOut"
end

function CWindowEquipEffectTipView.OnCreateView(self)
	self.m_NameLabel = self:NewUI(1, CLabel)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_TipWidget = self:NewUI(3, CWidget)

	g_UITouchCtrl:TouchOutDetect(self, function(obj)
		self:CloseView()
	end)
end

function CWindowEquipEffectTipView.SetWindowEffectTipInfo(self, iEffectId)
	local tData = data.skilldata.SPECIAL_EFFC[tonumber(iEffectId)]
	self.m_NameLabel:SetText(tData.name)
	self.m_DescLabel:SetText(tData.desc)
end

return CWindowEquipEffectTipView