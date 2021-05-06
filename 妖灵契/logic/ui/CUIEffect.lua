local CUIEffect = class("CUIEffect", CObject)

function CUIEffect.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_Panel = self:GetMissingComponent(classtype.UIPanel)
	self.m_Panel.uiEffectDrawCallCount = 1
	self.m_RenderQ = self:GetMissingComponent(classtype.UIEffectRenderQueue)
	self.m_RenderQ.needClip = true
	self:UpdateRenderQ()
end

function CUIEffect.UpdateRenderQ(self, renderQ)
	self.m_RenderQ.attachGameObject = self.m_GameObject
	if self.m_RenderQ then
		local iRenderQ = self.m_RenderQ.renderQ or 0
		if renderQ then
			iRenderQ = renderQ
		end
		self.m_RenderQ:UpdateRenderQ(iRenderQ)
	end
end

function CUIEffect.Above(self, oAttach)
	self.m_RenderQ.attachGameObject = oAttach.m_GameObject
	self.m_RenderQ:RecaluatePanelDepth()
end

return CUIEffect