local CUIEffectByPath = class("CUIEffectByPath", CObject)

function CUIEffectByPath.ctor(self, sPath, oAttach, v3LocalPos, v3Scale)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {v3LocalPos=v3LocalPos, v3Scale=v3Scale}
	g_ResCtrl:LoadCloneAsync(sPath, callback(self, "OnEffLoad"), false)
end 

function CUIEffectByPath.OnEffLoad(self, oClone)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetParent(self.m_Transform)
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
		mRenderQ:RecaluatePanelDepth()
		if self.m_Args.v3LocalPos then
			self.m_Eff:SetLocalPos(self.m_Args .v3LocalPos)
		end
		if self.m_Args.v3Scale then
			self.m_Eff:SetLocalScale(self.m_Args.v3Scale)
		end
	else
		if oClone then
			oClone:Destroy()
		end
		self:Destroy()
	end
end

function CUIEffectByPath.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectByPath