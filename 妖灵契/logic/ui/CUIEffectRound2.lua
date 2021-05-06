local CUIEffectRound2 = class("CUIEffectRound2", CObject)

function CUIEffectRound2.ctor(self, oAttach, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	self.m_EffectList = {}
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1151/Prefabs/ui_eff_1151_01.prefab", callback(self, "OnParticleEffLoad"), false)
	--g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1108/Prefabs/ui_eff_1108.prefab", callback(self, "OnParticleEffLoad"), false)
end

function CUIEffectRound2.OnParticleEffLoad(self, oClone, path)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		local oEff = CObject.New(oClone)
		oEff:SetParent(self.m_Transform)
		oEff:SetPos(oAttach:GetPos())
		if self.m_Args.pos then
			oEff:SetLocalPos(self.m_Args.pos)
		end
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		oEff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
		table.insert(self.m_EffectList, oEff)

		self:DelayClear()
	end 
end

function CUIEffectRound2.DelayClear(self)
	local function cb()
		local oAttach = getrefobj(self.m_RefAttach)
		if oAttach then
			oAttach:DelEffect("round2")
		end
	end
	Utils.AddTimer(cb, 0, 0.9)
end

return CUIEffectRound2