local CCamera = class("CCamera", CObject)

function CCamera.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_Camera = obj:GetComponent(classtype.Camera)
	self.m_AttachCameraHandler = self:GetComponent(classtype.AttachCameraHandler)
	self.m_RenderCam = nil
end

function CCamera.SetRenderCam(self, oCam)
	self.m_RenderCam = oCam
end

function CCamera.GetRenderCam(self)
	return self.m_RenderCam or self
end

function CCamera.NewAttachCamera(self, eventmask, depth)
	if self.m_AttachCameraHandler then
		return self.m_AttachCameraHandler:NewAttachCamera(eventmask, depth)
	end
end

function CCamera.GetDepth(self)
	return self.m_Camera.depth
end

function CCamera.SetDepth(self, iDepth)
	self.m_Camera.depth = iDepth
end

function CCamera.SetRect(self, rect)
	self.m_Camera.rect = rect
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetRect(rect)
	end
end

function CCamera.SetEnabled(self, b)
	self.m_Camera.enabled = b
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetEnabled(b)
	end
end

function CCamera.GetEnabled(self)
	return self.m_Camera.enabled
end


function CCamera.SetFieldOfView(self, i)
	self.m_Camera.fieldOfView = i
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetFieldOfView(i)
	end
end

function CCamera.GetFieldOfView(self)
	return self.m_Camera.fieldOfView
end

function CCamera.SetBackgroudColor(self, color)
	if self.m_AttachCameraHandler then
		self.m_AttachCameraHandler:SetBackgroudColor(color)
	else
		self.m_Camera.backgroundColor = color
	end
end

function CCamera.GetBackgroundColor(self)
	if self.m_AttachCameraHandler then
		return  self.m_AttachCameraHandler:GetBackgroundColor()
	else
		return self.m_Camera.backgroundColor
	end
	
end

function CCamera.WorldToScreenPoint(self, v3)
	return self.m_Camera:WorldToScreenPoint(v3)
end

function CCamera.ViewportToWorldPoint(self, v3)
	return self.m_Camera:ViewportToWorldPoint(v3)
end

function CCamera.ScreenToWorldPoint(self, v3)
	return self.m_Camera:ScreenToWorldPoint(v3)
end

function CCamera.WorldToViewportPoint(self, v3)
	return self.m_Camera:WorldToViewportPoint(v3)
end

function CCamera.SetTargetTexture(self, rt)
	self.m_Camera.targetTexture = rt
end

function CCamera.CopyFrom(self, camreraobj)
	self.m_Camera:CopyFrom(camreraobj)
end

function CCamera.Render(self)
	self.m_Camera:Render()
end

function CCamera.SetOrthographicSize(self, vsize)
	self.m_Camera.orthographicSize = vsize
end

function CCamera.GetOrthographicSize(self)
	return self.m_Camera.orthographicSize
end

function CCamera.GetAspect(self)
	return self.m_Camera.aspect 
end

function CCamera.GetCullingMask(self)
	return self.m_Camera.cullingMask
end

function CCamera.SetCullingMask(self, x)
	self.m_Camera.cullingMask = x
end

function CCamera.OpenCullingMask(self, layer)
	local x = MathBit.orOp(self.m_Camera.cullingMask, MathBit.lShiftOp(1, layer)) 
	self.m_Camera.cullingMask = x
end

function CCamera.CloseCullingMask(self, layer)
	local x = MathBit.andOp(self.m_Camera.cullingMask, MathBit.notOp(MathBit.lShiftOp(1, layer)))
	self.m_Camera.cullingMask = x
end

function CCamera.Push(self, objPos, targetQuaternion, cb, iDistance, iTime)
	local tweenTime = iTime or 1.5
	local endDistance = iDistance or 0
	local dic = objPos - self:GetPos()
	local targetPos = objPos - dic.normalized * endDistance
	local tweenMove = DOTween.DOMove(self.m_Transform, targetPos, tweenTime)
	self.m_IsPushing = true
	DOTween.SetEase(tweenMove, enum.DOTween.Ease.OutSine)
	DOTween.OnComplete(tweenMove, function ()
		self.m_IsPushing = false
		if cb then
			cb()
		end
	end)
	self.m_BaseQuaternion = self:GetRotation()
	self.m_TargetQuaternion = targetQuaternion
	local tweenRotate = CActionFloat.New(self, tweenTime, "SetQuaternion", 0, 1)
	g_ActionCtrl:AddAction(tweenRotate, 0)
	-- local tweenRotate = DOTween.DORotateQuaternion(self.m_Transform, targetQuaternion, tweenTime)
	-- DOTween.SetEase(tweenRotate, enum.DOTween.Ease.OutSine)
end

function CCamera.SetQuaternion(self, iValue)
	self:SetRotation(Quaternion.Lerp(self.m_BaseQuaternion, self.m_TargetQuaternion, 1 - (1 - iValue) * (1 - iValue)))
end

function CCamera.IsPushing(self)
	return self.m_IsPushing
end

return CCamera