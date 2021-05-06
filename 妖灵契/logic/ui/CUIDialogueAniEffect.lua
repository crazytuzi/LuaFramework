local CUIDialogueAniEffect = class("CUIDialogueAniEffect", CObject)

function CUIDialogueAniEffect.ctor(self, oAttach, path, cb)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/EffectNode.prefab")
	CObject.ctor(self, obj)
	self.m_RefAttach = weakref(oAttach)
	--self.m_Args = {size=size, pos=pos}
	self.m_Callback = cb
	--g_ResCtrl:LoadCloneAsync("Effect/UI/ui_eff_1151/Prefabs/ui_eff_1151_02.prefab", callback(self, "OnEffLoad"), false)
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnEffLoad"), false)
end 

function CUIDialogueAniEffect.OnEffLoad(self, oClone, sPath)
	local oAttach = getrefobj(self.m_RefAttach)
	if oClone and oAttach then
		self.m_Eff = CObject.New(oClone)
		self.m_Eff:SetLayer(oAttach:GetLayer())
		self.m_Eff:SetParent(self.m_Transform)
		local vPos = oAttach:GetPos()
		vPos = self:InverseTransformPoint(vPos)
		-- if self.m_Args.pos then
		-- 	vPos.x = vPos.x + self.m_Args.pos.x
		-- 	vPos.y = vPos.y + self.m_Args.pos.y
		-- end
		self.m_Eff:SetLocalPos(vPos)
		local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
		mPanel.uiEffectDrawCallCount = 1
		local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
		self.m_Eff.m_RenderQComponent = mRenderQ
		mRenderQ.needClip = true
		mRenderQ.attachGameObject = oAttach.m_GameObject
		if self.m_Callback then
			self.m_Callback(self)
			self.m_Callback = nil
		end
	end
end

function CUIDialogueAniEffect.RecaluatePanelDepth(self)
	if self.m_Eff then
		self.m_Eff.m_RenderQComponent:RecaluatePanelDepth()
	end
end

return CUIDialogueAniEffect