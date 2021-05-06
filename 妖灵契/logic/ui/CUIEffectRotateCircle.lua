local CUIEffectRotateCircle = class("CUIEffectRotateCircle", CObject)

function CUIEffectRotateCircle.ctor(self, oAttach, radius, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos, radius=radius}
	self.m_EffectList = {}
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_03.prefab", callback(self, "OnParticleEffLoad"), false)	
end

function CUIEffectRotateCircle.OnParticleEffLoad(self, oClone, path)
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

		local oBox = CBox.New(oClone)
		if oBox then
			oBox.m_L = oBox:NewUI(1, CBox)
			oBox.m_R = oBox:NewUI(2, CBox)
			if self.m_Args.radius then
				oBox.m_L:SetLocalPos(Vector3.New(-self.m_Args.radius, 0, 0))
				oBox.m_R:SetLocalPos(Vector3.New(self.m_Args.radius, 0, 0))
			end
		end
	end 
end

return CUIEffectRotateCircle