local CUIEffectBorderMove = class("CUIEffectBorderMove", CObject)

function CUIEffectBorderMove.ctor(self, oAttach, size, pos, idx)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	self.m_EffectList = {}
	if idx == 2 then
		g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_02.prefab", callback(self, "OnParticleEffLoad"), false)	
	elseif idx == 4 then
		g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_04.prefab", callback(self, "OnParticleEffLoad"), false)
	elseif idx == 5 then
		g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_05.prefab", callback(self, "OnParticleEffLoad"), false)		
	elseif idx == 6 then
		g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_06.prefab", callback(self, "OnParticleEffLoad"), false)
	elseif idx == 7 then
		g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_07.prefab", callback(self, "OnParticleEffLoad"), false)				
	else
		g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1152/Prefabs/ui_eff_1152_01.prefab", callback(self, "OnParticleEffLoad"), false)	
	end	
end

function CUIEffectBorderMove.OnParticleEffLoad(self, oClone, path)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		local oEff = CObject.New(oClone)
		oEff:SetParent(self.m_Transform)
		oEff:SetPos(oAttach:GetPos())
		oEff.m_BordMove = oEff:GetComponent(classtype.BorderMove)
		if self.m_Args.size then
			local s = self.m_Args.size
			oEff.m_BordMove.borderWMin = s.x
			oEff.m_BordMove.borderWMax = s.y
			oEff.m_BordMove.borderHMin = s.z
			oEff.m_BordMove.borderHMax = s.w 
		end
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		oEff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
		table.insert(self.m_EffectList, oEff)
	end 
end

return CUIEffectBorderMove