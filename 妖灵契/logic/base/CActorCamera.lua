local CActorCamera = class("CActorCamera", CCamera, CGameObjContainer)

function CActorCamera.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/ActorCamera.prefab")
	CCamera.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_PosObj = self:NewUI(1, CObject)
	self.m_Actor = nil
	self.m_RenderTexture = nil
	self.m_ModelConfig = nil
end

function CActorCamera.ChangeShape(self, iShape, tDesc, cb, iPosition, iQuaternion, iFieldOfView)
	if not self.m_Actor then
		self.m_Actor = CActor.New()
		self.m_Actor:SetParent(self.m_PosObj.m_Transform)
	end
	self.m_Actor:SetModelConfig(self.m_ModelConfig)
	self.m_ActorLoadDoneCb = cb
	self.m_Actor:ChangeShape(iShape, tDesc, callback(self, "OnActorChangeDone"))
end

function CActorCamera.SetActorPos(self, vPos)
	self.m_PosObj:SetLocalPos(vPos)
	
end

function CActorCamera.SetActorEulerAngle(self, vAngle)
	self.m_PosObj:SetLocalEulerAngles(vAngle)
end

function CActorCamera.GetShape(self)
	if self.m_Actor then
		return self.m_Actor:GetShape()
	end
end

function CActorCamera.ResetActor(self)
	if self.m_Actor then
		self.m_Actor:CrossFade("idleCity")
		self.m_Actor:SetLocalRotation(Quaternion.Euler(0,0,0))
	end
end

function CActorCamera.CheckOwnerDisplay(self)
	local oOwenr = self:GetOwner()
	if oOwenr then
		self:SetActive(true)
		oOwenr:CheckDisplayRenderTexture(self.m_RenderTexture)
	end
end

function CActorCamera.SetModelConfig(self, dConfig)
	self.m_ModelConfig = dConfig
end

function CActorCamera.OnActorChangeDone(self)
	if self.m_Actor then
		self:CheckOwnerDisplay()
		local dConfig = self.m_ModelConfig or ModelTools.GetModelConfig(self.m_Actor:GetShape())
		local size = 1 / dConfig.relative_size
		self.m_PosObj:SetLocalScale(Vector3.New(size, size, size))
		self.m_PosObj:SetLocalPos(Vector3.New(dConfig.ui_x, dConfig.ui_y, dConfig.ui_z))

		self.m_Actor:SetModelOutline(0.004)
		local layer = self:GetLayer()
		self.m_Actor:SetLayerDeep(layer)

		if self.m_ActorLoadDoneCb then
			self.m_ActorLoadDoneCb(self.m_Actor)
			self.m_ActorLoadDoneCb = nil
		end
	end
end

function CActorCamera.SetRenderTexture(self, renderTexture)
	self.m_RenderTexture = renderTexture
	self:SetTargetTexture(renderTexture)
end

function CActorCamera.GetModel(self)
	return self.m_Actor
end

function CActorCamera.SetOwner(self, o)
	if o then
		self.m_OwnerRef = weakref(o)
	else
		self.m_OwnerRef = nil
	end
end

function CActorCamera.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

function CActorCamera.ClearTexture(self)
	if self.m_RenderTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_RenderTexture)
		self.m_RenderTexture = nil
		self:SetTargetTexture(nil)
	end
end

function CActorCamera.ClearActor(self)
	self.m_ModelConfig = nil
	if self.m_Actor then
		self.m_Actor:Destroy()
		self.m_Actor = nil
	end
	self:ClearTexture()
end

function CActorCamera.Destroy(self)
	self:ClearActor()
	self:ClearTexture()
	CCamera.Destroy(self)
end

return CActorCamera