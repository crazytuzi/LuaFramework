local CActorTexture = class("CActorTexture", CTexture)

function CActorTexture.ctor(self, obj)
	CTexture.ctor(self, obj)
	self.m_ActorCamera = nil
	self.m_DisplayTexture = nil --真正用来显示的Texture
	self.m_LastRelativeSize = 1
	self.m_RelativeSize = 1
	self.m_Color = Color.one
	self:AddUIEvent("drag", callback(self, "OnDrag"))
	self.m_DisplayRenderTexture = nil
	self.m_ModelConfig = nil
	-- self:AddUIEvent("click", callback(self, "OnClick"))
end

function CActorTexture.SetAlpha(self, iAlpha)
	self:SetColor(Color.New(1, 1, 1, iAlpha))
end

function CActorTexture.SetColor(self, c)
	self.m_Color = c
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if oActor then
		oActor:SetMatColor(c)
	end
end

function CActorTexture.GetColor(self)
	return self.m_Color
end

function CActorTexture.OnDrag(self, obj, moveDelta)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	oActor:Rotate(Vector3.New(0, - moveDelta.x * 3, 0))
end

function CActorTexture.OnClick(self, obj)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	local sCur = oActor:GetState()
	local anilist = {"idleWar", "idleCity", "run", "attack1", "attack2"}
	local idx = table.index(anilist, sCur)
	if idx then
		table.remove(anilist, idx)
	end
	local sAniName = anilist[Utils.RandomInt(1, #anilist)]
	
	local function f()
		oActor:CrossFade("idleCity", 0.1)
	end
	oActor:CrossFade(sAniName, 0.1, 0, 1, f)
end

function CActorTexture.PlayAni(self, sAniName, bLoop)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	if bLoop then
		oActor:CrossFadeLoop(sAniName, 0.1, 0, 1, true)
	else
		local function f()
			oActor:CrossFade("idleCity", 0.1)
		end
		oActor:CrossFade(sAniName, 0.1, 0, 1, f)
	end
end

function CActorTexture.SetActorRotation(self, v3)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	oActor:SetRotation(v3)
end

function CActorTexture.ChangeTravelShape(self, iShape, tDesc, cb, iPosition, iQuaternion, iFieldOfView)
	self.m_ModelConfig = ModelTools.GetTravelModelConfig(iShape) or ModelTools.GetModelConfig(iShape)
	self:ChangeShape(iShape, tDesc, cb, iPosition, iQuaternion, iFieldOfView)
end

function CActorTexture.ChangeShape(self, iShape, tDesc, cb, iPosition, iQuaternion, iFieldOfView)
	local dConfig = self.m_ModelConfig or ModelTools.GetModelConfig(iShape)
	self.m_LastRelativeSize = self.m_RelativeSize
	self.m_RelativeSize = dConfig.relative_size
	self.m_UISize = dConfig.ui_size or 1
	if not self.m_ActorCamera then
		self.m_ActorCamera = g_CameraCtrl:GetActorCamra(iShape)
		self.m_ActorCamera:SetOwner(self)
	end
	if iFieldOfView then
		self.m_ActorCamera:SetFieldOfView(iFieldOfView)
	end
	local oCam = g_CameraCtrl:GetUICamera()
	local o = self:GetMainTexture(oCam.m_Camera.aspect, iShape)
	self.m_ActorCamera:SetRenderTexture(o)
	self.m_ActorCamera:SetModelConfig(dConfig)
	local function wrap(oActor)
		if Utils.IsExist(self) then
			oActor:SetMatColor(self.m_Color)
		end
		if cb then 
			cb(oActor)
		end
	end
	self.m_ActorCamera:ChangeShape(iShape, tDesc, wrap, iPosition, iQuaternion)
end

function CActorTexture.Clear(self)
	if self.m_UIWidget.mainTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_UIWidget.mainTexture)
		self:SetMainTexture(nil)
	end
	if self.m_ActorCamera then
		g_CameraCtrl:Recycle(self.m_ActorCamera)
		self.m_ActorCamera = nil
	end

	self.m_ModelConfig = nil
end

function CActorTexture.SetWidth(self, iWidth)
	CTexture.SetWidth(iWidth)
	if self.m_DisplayTexture then
		self.m_DisplayTexture:SetWidth(iWidth*self.m_RelativeSize*self.m_UISize)
	end
end

function CActorTexture.SetHeight(self, iHeight)
	CTexture.SetWidth(iHeight)
	if self.m_DisplayTexture then
		self.m_DisplayTexture:SetWidth(iHeight*self.m_RelativeSize*self.m_UISize)
	end
end

function CActorTexture.GetDisplayTexture(self)
	if not self.m_DisplayTexture then
		local obj = UnityEngine.GameObject.New()
		obj:AddComponent(classtype.UITexture)
		local oTexture = CTexture.New(obj)
		oTexture:SetPivot(self:GetPivot())
		oTexture:SetParent(self.m_Transform)
		oTexture:SetDepth(self:GetDepth())
		oTexture:SetLocalPos(Vector3.zero)
		oTexture:SetName("display")
		oTexture:SetShader(C_api.Utils.FindShader("Unlit/Premultiplied Colored"))
		oTexture:SetLayer(self:GetLayer())
		self.m_DisplayTexture = oTexture
	end
	
	return self.m_DisplayTexture
end

function CActorTexture.GetMainTexture(self, aspect, iShape)
	local oTexture = self:GetDisplayTexture()
	if oTexture:GetMainTexture() and self.m_LastRelativeSize ~= self.m_RelativeSize then
		oTexture:SetMainTexture(nil)
	end
	local factor = UITools.GetPixelSizeAdjustment()
	local w = self:GetWidth() * self.m_RelativeSize * self.m_UISize
	local h = self:GetHeight() * self.m_RelativeSize * self.m_UISize
	if aspect then
		local iTextureAspect = (w/h)
		if iTextureAspect ~= aspect then
			if iTextureAspect < aspect then
				w = h * aspect
			elseif iTextureAspect > aspect then
				h = w / aspect
			end
			w = w * 0.7
			oTexture:SetSize(w, h)
		end
	end
	if not self.m_DisplayRenderTexture then
		local iFactor = 1
		if table.index({3012, 3013, 3014, 3015}, iShape) then
			self.m_DisplayRenderTexture = UnityEngine.RenderTexture.GetTemporary(w*iFactor, h*iFactor, 16, 
				enum.RenderTextureFormat.ARGB1555, enum.RenderTextureReadWrite.Default, 1)
		else
			self.m_DisplayRenderTexture = UnityEngine.RenderTexture.GetTemporary(w*iFactor, h*iFactor, 24, 
				enum.RenderTextureFormat.Default, enum.RenderTextureReadWrite.Default, 2)
		end
	end
	return self.m_DisplayRenderTexture
end

function CActorTexture.CheckDisplayRenderTexture(self, oRenderTexture)
	local oTexture = self:GetDisplayTexture()
	if oTexture then
		oTexture:SetMainTexture(oRenderTexture)
	end
end

function CActorTexture.GetActorTransform(self)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if oActor then
		return oActor.m_Transform
	end
end

function CActorTexture.SetRotate(self, rotate)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	local t = oActor:GetLocalRotation()
	oActor:SetLocalRotation(Quaternion.Euler(0, rotate, 0)) 
end

function CActorTexture.SetRotateXYZ(self, v3)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	local t = oActor:GetLocalRotation()
	oActor:SetLocalRotation(Quaternion.Euler(v3.x, v3.y, v3.z)) 
end

function CActorTexture.OnPlay(self, sAniName, loop)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end
	sAniName = sAniName or "idleCity"
	if loop == nil then
		loop = true
	end
	oActor:CrossFadeLoop(sAniName, 0.1, 0, 1, loop)
end

function CActorTexture.StopPlay(self)
	local oActor = self.m_ActorCamera and self.m_ActorCamera:GetModel()
	if not oActor then
		return
	end	
	oActor:StopCrossFadeLoop()
end

return CActorTexture
