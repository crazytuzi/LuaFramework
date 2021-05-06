local CUIEffectFire = class("CUIEffectFire", CObject)

function CUIEffectFire.ctor(self, oAttach, pos)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	self.m_Args = {pos=pos}
	g_ResCtrl:LoadCloneAsync("Effect/UI/schedule_01/Prefabs/schedule_01_f.prefab", callback(self, "OnEffLoad"), false)	
end 

function CUIEffectFire.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff1 = CObject.New(oClone)
		self.m_Eff1:SetParent(self.m_Transform)
		local vPos = oAttach:GetPos()
		vPos = self:InverseTransformPoint(vPos)
		if self.m_Args.pos then
			vPos.x = vPos.x + self.m_Args.pos.x
			vPos.y = vPos.y + self.m_Args.pos.y
		end
		self.m_Eff1:SetLocalPos(vPos)
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff1.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
	end
end

function CUIEffectFire.RecaluatePanelDepth(self)
	if self.m_Eff1 then
		self.m_Eff1.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIEffectFire