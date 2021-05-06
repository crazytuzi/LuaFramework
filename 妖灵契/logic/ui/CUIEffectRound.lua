local CUIEffectRound = class("CUIEffectRound", CObject)

function CUIEffectRound.ctor(self, oAttach, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	self.m_EffectList = {}
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1108/Prefabs/ui_eff_1108.prefab", callback(self, "OnParticleEffLoad"), false)
end

function CUIEffectRound.OnParticleEffLoad(self, oClone, path)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		local oEff = CObject.New(oClone)
		oEff:SetParent(self.m_Transform)
		oEff:SetPos(oAttach:GetPos())
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		oEff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
		table.insert(self.m_EffectList, oEff)
	end
end

function CUIEffectRound.ClickEffect(self)
	local oAttach = getrefobj(self.m_RefAttach)
	if oAttach then
		local oEff = CEffect.New("Effect/UI/ui_eff_1109/Prefabs/ui_eff_1109.prefab", self:GetLayer())
		oEff:SetAttachUI(oAttach)
		oEff:SetPos(g_CameraCtrl:GetNGUICamera().lastWorldPosition)
		Utils.AddTimer(callback(oEff, "Destroy"), 2, 2)
		g_EffectCtrl:AddEffect(oEff)
	end
end

return CUIEffectRound