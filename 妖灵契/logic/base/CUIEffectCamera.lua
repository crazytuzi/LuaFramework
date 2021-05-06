local CUIEffectCamera = class("CUIEffectCamera", CCamera, CGameObjContainer)

function CUIEffectCamera.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/UIEffectCamera.prefab")
	CCamera.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_SprNode = self:NewUI(1, CSprite)
	self.m_RenderTexture = nil
	self.m_OwnerRef = nil
end

function CUIEffectCamera.LoadEffect(self, sType, cb)
	self.m_ActorLoadDoneCb = cb
	sType = "Finger"
	if self.m_SprNode then
		self.m_SprNode:ClearEffect()
		self.m_SprNode:AddEffect(sType)
	end
	if self.m_ActorLoadDoneCb then
		self.m_ActorLoadDoneCb()
	end
end

function CUIEffectCamera.SetRenderTexture(self, renderTexture)
	self.m_RenderTexture = renderTexture
	self:SetTargetTexture(renderTexture)
end

function CUIEffectCamera.ClearTexture(self)
	if self.m_RenderTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_RenderTexture)
		self.m_RenderTexture = nil
		self:SetTargetTexture(nil)
	end
end

function CUIEffectCamera.SetOwner(self, o)
	self.m_OwnerRef = weakref(o)
end

function CUIEffectCamera.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

function CUIEffectCamera.Destroy(self)
	self:ClearTexture()
	CCamera.Destroy(self)
end

return CUIEffectCamera