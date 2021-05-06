local CUIEffectRect = class("CUIEffectRect", CWidget)

function CUIEffectRect.ctor(self, oAttach)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	local mWidget = obj:GetMissingComponent(classtype.UIWidget)
	CWidget.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1123/Prefabs/ui_eff_1123.prefab", callback(self, "OnEffLoad"))
end


function CUIEffectRect.OnEffLoad(self, oClone, errcode)
	local iDesignSize = 64
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		local w, h = oAttach:GetSize()
		self:SetSize(w, h)
		local iScaleW = w / iDesignSize * 1.05
		local iScaleH = h /iDesignSize * 1.05
		self.m_Eff:SetLocalScale(Vector3.New(iScaleW, iScaleH, 1))
		UITools.NearTarget(oAttach, self, enum.UIAnchor.Side.Center)
		
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end
end

function CUIEffectRect.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectRect