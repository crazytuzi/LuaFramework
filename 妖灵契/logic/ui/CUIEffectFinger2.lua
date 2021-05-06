local CUIEffectFinger2 = class("CUIEffectFinger2", CObject)

function CUIEffectFinger2.ctor(self, oAttach, size, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {size=size, pos=pos}
	self.m_EffectList = {}
	g_ResCtrl:LoadCloneAsync("UI/UIEffect/finger2.prefab", callback(self, "OnUIEffLoad"))
	g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1108/Prefabs/ui_eff_1108.prefab", callback(self, "OnParticleEffLoad"), false)
end

function CUIEffectFinger2.OnUIEffLoad(self, oClone, path)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		local oEff = CWidget.New(oClone)
		local iSize
		if self.m_Args.size then
			iSize = self.m_Args.size
			oEff:SetSize(iSize, iSize)
		end
		oEff:SetParent(self.m_Transform)
		local pos 
		if self.m_Args.pos then
			pos = self.m_Args.pos
		else
			pos = Vector3.New(0, 0)
		end
		UITools.NearTarget(oAttach, oEff, enum.UIAnchor.Side.Bottom, pos)
		local depth = UITools.CalculateNextDepth(oAttach.m_GameObject)
		oEff:SetDepth(depth)
		oEff:TopChildDepth()
		table.insert(self.m_EffectList, oEff)
	end
end

function CUIEffectFinger2.OnParticleEffLoad(self, oClone, path)
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

function CUIEffectFinger2.ClickEffect(self)
	local oAttach = getrefobj(self.m_RefAttach)
	if oAttach then
		local oEff = CEffect.New("Effect/UI/ui_eff_1109/Prefabs/ui_eff_1109.prefab", self:GetLayer())
		oEff:SetAttachUI(oAttach)
		oEff:SetPos(g_CameraCtrl:GetNGUICamera().lastWorldPosition)
		Utils.AddTimer(callback(oEff, "Destroy"), 2, 2)
		g_EffectCtrl:AddEffect(oEff)
	end
end

return CUIEffectFinger2