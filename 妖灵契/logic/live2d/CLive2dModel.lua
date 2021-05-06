local CLive2dModel = class("CLive2dModel", CObject)

CLive2dModel.Position = 
{
	x = -9999,
	y = 0,
	z = 0,
}

CLive2dModel.Offet = 100

CLive2dModel.Idx = 1

function CLive2dModel.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/Live2dModel.prefab")
	CObject.ctor(self, obj)
	local pos = CLive2dModel.Position
	self:SetPos(Vector3.New(pos.x, pos.y + CLive2dModel.Idx * CLive2dModel.Offet, pos.z))
	CLive2dModel.Idx = CLive2dModel.Idx + 1
	self.m_Handler = self:GetComponent(classtype.Live2dHandler)
	self.m_Camera = CCamera.New(self:Find("Camera").gameObject)
	self.m_TargetPoint = CLive2dTargetPoint.New()
	self.m_Live2dModel = nil
	self.m_MotionMgr = Live2d.MotionQueueManager.New()
	self.m_Timer = Utils.AddTimer(callback(self, "UpdateSelf"), 0, 0)
	self.m_Shape = nil
	self.m_Width = 0
	self.m_Height = 0
	self.m_TargetPos = nil
	self.m_RelativeObjRef = nil
	self.m_DefaultMotion = "idle_1"
	self.m_MotionTemp = {}
	self.m_PhysicsTemp = {}
	self.m_Draging = false
	self.m_EffectPoint = 0
	self.m_RandomMotionList = nil
	self.m_AudioPlayer = nil
	self.m_LastTexture = nil
	self.m_RenderTexture = nil
	self.m_MotionCbDic = {}
	g_AudioCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAudioEvent"))
end


function CLive2dModel.OnAudioEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Audio.Event.LoadDone then
		local oAudioPlayer = oCtrl.m_EventData
		if oAudioPlayer.m_Path and string.find(oAudioPlayer.m_Path, "Live2D") then
			-- local clip = oAudioPlayer.m_AidoSource.clip
			-- self.m_AudioPlayer = oAudioPlayer
			-- self.m_Handler:SetLipsClip(clip)
		end
	end
end

function CLive2dModel.ResetCamera(self)
	self.m_Camera:SetLocalPos(Vector3.New(0, 0.16,-10))
	self.m_Camera:SetOrthographicSize(0.7)
end

function CLive2dModel.SetCamera(self, pos, graphicSize)
	self.m_Camera:SetLocalPos(pos)
	self.m_Camera:SetOrthographicSize(graphicSize)
end

function CLive2dModel.SetDefaultMotion(self, motionName)
	self.m_DefaultMotion = motionName
end

function CLive2dModel.LoadModel(self, iShape)
	self.m_RandomMotionList = nil
	self.m_IsLoadDone = false
	self.m_MotionMgr:stopAllMotions()
	self.m_Modeldata = data.housedata.Live2d_Body[iShape]
	self.m_Shape = iShape
	self:ResetCamera()
	local path = string.format("Live2d/%d/moc_%d.bytes", iShape, iShape)
	self.m_Live2dModel = self.m_Handler:LoadModel(path)
	self.m_Handler:SetLipsClip(nil)
	if self.m_AudioPlayer then
		self.m_AudioPlayer.m_AidoSource:Stop()
	end
	self.m_AudioPlayer = nil
	self.m_Handler:SetLive2dModel(self.m_Live2dModel)
	local sTexturePath = string.format("Live2d/%d/Texture/texture_%d.png", iShape, iShape)
	g_ResCtrl:LoadAsync(sTexturePath, callback(self, "OnTextureLoadDone", iShape, 0))
end

function CLive2dModel.OnTextureLoadDone(self, iShape, iTextureIdx, oTex, path)
	if oTex then
		if self.m_Shape == iShape then
			self.m_IsLoadDone = true
			if self.m_LastTexture then
				g_ResCtrl:DelManagedAsset(self.m_LastTexture, self.m_GameObject)
			end
			g_ResCtrl:AddManageAsset(oTex, self.m_GameObject, path)
			self.m_Live2dModel:setTexture(iTextureIdx, oTex)
			self.m_LastTexture = oTex
			self.m_Physics = self:GetPhysics("physics")
			if self.m_FirstMotion then
				self:PlayMotion(self.m_FirstMotion.motion, self.m_FirstMotion.loop)
				self.m_FirstMotion = nil
			else
				self:PlayMotion(self.m_DefaultMotion)
			end
		else
			--销毁textture
		end
	end
end

function CLive2dModel.GetMotion(self, sMotion)
	if not self.m_Shape then
		return nil 
	end
	if self.m_MotionTemp[self.m_Shape] == nil then
		self.m_MotionTemp[self.m_Shape] = {}
	end
	if self.m_MotionTemp[self.m_Shape][sMotion] == nil then
		local path = string.format("Live2d/%d/Motion/%s_%d.bytes", self.m_Shape, sMotion, self.m_Shape)
		self.m_MotionTemp[self.m_Shape][sMotion] = self.m_Handler:LoadMotion(path)
	end
	return self.m_MotionTemp[self.m_Shape][sMotion]
end

function CLive2dModel.GetPhysics(self, sPhysics)
	if not self.m_Shape or self.m_Shape == 1003 then
		return nil 
	end
	if self.m_PhysicsTemp[self.m_Shape] == nil then
		local path = string.format("Live2d/%d/Physics/%s_%d.bytes", self.m_Shape, sPhysics, self.m_Shape)
		self.m_PhysicsTemp[self.m_Shape] = self.m_Handler:LoadPhysics(path)
	end
	return self.m_PhysicsTemp[self.m_Shape]
end

function CLive2dModel.PlayMotion(self, sMotion, bLoop)
	if sMotion == nil then
		return
	end
	if not self.m_IsLoadDone then
		self.m_FirstMotion = {motion = sMotion, loop = bLoop,}
	end
	if not self.m_Shape then
		return
	end

	-- if self.m_CurMotion and self.m_CurMotion == sMotion and not string.find(self.m_CurMotion, "idle") then
	-- 	return
	-- end

	if not string.find(sMotion, "idle") then
		self.m_TargetPos = nil
	end
	bLoop = bLoop==nil and false or bLoop
	local motion = self:GetMotion(sMotion)
	motion:setFPS(30)
	motion:setLoop(bLoop)
	self.m_MotionMgr:startMotion(motion, false)
	self.m_CurMotion = sMotion
	if self.m_MotionCbDic[sMotion] then
		self.m_MotionCbDic[sMotion]()
	end
end

function CLive2dModel.PlayRandomMotion(self)
	if self.m_RandomMotionList and #self.m_RandomMotionList > 0 then
		local sMotion = self.m_RandomMotionList[Utils.RandomInt(1, #self.m_RandomMotionList)]
		if self.m_CurMotion == sMotion then
			self:PlayMotion(self.m_DefaultMotion)
		else
			self:PlayMotion(sMotion)
		end
	else
		self:PlayMotion(self.m_DefaultMotion)
	end
end

function CLive2dModel.GetRelativeObj(self)
	return getrefobj(self.m_RelativeObjRef)
end

--播放动作前使用,每次播放动作都执行
function CLive2dModel.BindFunc(self, sMotion, cb)
	self.m_MotionCbDic[sMotion] = cb
end

function CLive2dModel.ClearBindFunc(self)
	self.m_MotionCbDic = {}
end

function CLive2dModel.SetRenderTexture(self, renderTexture)
	self.m_RenderTexture = renderTexture
	self.m_Camera:SetTargetTexture(renderTexture)
end

function CLive2dModel.ClearTexture(self)
	if self.m_RenderTexture then
		UnityEngine.RenderTexture.ReleaseTemporary(self.m_RenderTexture)
		self.m_RenderTexture = nil
		self.m_Camera:SetTargetTexture(nil)
	end
end

function CLive2dModel.UpdateSelf(self)
	if Utils.IsNil(self) then
		return false
	end
	if self:GetRelativeObj() == nil then
		self:Destroy()
	end
	if not self.m_Live2dModel then
		return true
	end
	if not self.m_IsLoadDone then
		return true
	end

	if self.m_MotionMgr:isFinished() then
		-- self.m_Timer1 = Utils.AddTimer(callback(self, "PlayMotion", self.m_DefaultMotion, true), 0, 1)
		if self.m_RandomMotionList then
			self:PlayRandomMotion()
		else
			self:PlayMotion(self.m_DefaultMotion)
		end
	end
	self.m_MotionMgr:updateParam(self.m_Live2dModel)

	if self.m_AudioPlayer and self.m_AudioPlayer.m_AidoSource.clip then
		local voiceValue = self.m_Handler:GetSampleValue(self.m_AudioPlayer.m_AidoSource.time / self.m_AudioPlayer.m_AidoSource.clip.length * self.m_AudioPlayer.m_AidoSource.clip.samples)
		self.m_Live2dModel:setParamFloat("PARAM_MOUTH_OPEN_Y", 0.5 + voiceValue * 5)
	end

	if self.m_TargetPos ~= nil then
		if self.m_Draging and self.m_EffectPoint < 1 then
			self.m_EffectPoint = self.m_EffectPoint + 0.2
			if self.m_EffectPoint > 1 then
				self.m_EffectPoint = 1
			end
		end
		if (not self.m_Draging) and self.m_EffectPoint > 0 then
			self.m_EffectPoint = self.m_EffectPoint - 0.05
			if self.m_EffectPoint < 0 then
				self.m_EffectPoint = 0
			end
		end
		self.m_TargetPoint:Set(self.m_TargetPos.x / self.m_Width*2 - 1, self.m_TargetPos.y / self.m_Height * 2 - 1)
		self.m_TargetPoint:Update()
		-- printc(string.format("x: %s, y: %s", self.m_TargetPoint:GetX(), self.m_TargetPoint:GetY()))
		self.m_Live2dModel:setParamFloat("PARAM_ANGLE_X", self.m_TargetPoint:GetX() * 30, self.m_EffectPoint)
		self.m_Live2dModel:setParamFloat("PARAM_ANGLE_Y", self.m_TargetPoint:GetY() * 15, self.m_EffectPoint)
		self.m_Live2dModel:setParamFloat("PARAM_ANGLE_Z", self.m_TargetPoint:GetY() * 15, self.m_EffectPoint)
		self.m_Live2dModel:setParamFloat("PARAM_BODY_ANGLE_X", self.m_TargetPoint:GetX() * 5, self.m_EffectPoint)
		self.m_Live2dModel:setParamFloat("PARAM_EYE_BALL_X", 1 * self.m_TargetPoint:GetX(), self.m_EffectPoint)
		self.m_Live2dModel:setParamFloat("PARAM_EYE_BALL_Y", 1 * self.m_TargetPoint:GetY() - 0.7, self.m_EffectPoint)

	end
	if self.m_Physics ~= nil then
		self.m_Physics:updateParam(self.m_Live2dModel)
	end

	return true
end

function CLive2dModel.EyesOn(self)
	if self.m_CurMotion and not string.find(self.m_CurMotion, "idle") then
		return
	end
	self.m_TargetPos = self:GetModelPos()
end

function CLive2dModel.StartEyesOn(self)
	self.m_Draging = true
	self.m_TargetPoint:Reset()
end

function CLive2dModel.EndEyesOn(self)
	self.m_Draging = false
	self.m_TargetPoint:Reset()
	if self.m_TargetPos ~= nil then
		self.m_TargetPos = {x = self.m_Width / 2, y =self.m_Height / 2}
	end
end

-- function CLive2dModel.ProcessTouchPos(self, v)
-- 	-- g_NotifyCtrl:FloatMsg("点击部位"..tostring(v.name))
-- 	if v.motionName then
-- 		self:PlayMotion(v.motionName)
-- 		if v.sound and #v.sound > 0 then
-- 			local sSound = v.sound[Utils.RandomInt(1, #v.sound)]
-- 			g_AudioCtrl:PlaySound(string.format("Live2D/%d/%s.wav", self.m_Shape, sSound))
-- 		end
-- 	end
-- end

function CLive2dModel.CheckTouchPos(self)
	local vPos = self:GetModelPos()
	local vModelPos = self.m_Handler:TouchToModelPoint(vPos.x, vPos.y)
	-- if self.m_CurMotion ~= nil and string.find(self.m_CurMotion, "idle") then
		for _, v in pairs(self.m_Modeldata) do
			if self:IsAABBContainPoint(self.m_Handler:GetAABBSize(v.key), vModelPos) then
				-- self:ProcessTouchPos(v)
				return v
			end
		end
	-- end
end

function CLive2dModel.GetModelPos(self)
	local oRelativeObj = self:GetRelativeObj()
	if oRelativeObj then
		local vWorldPos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
		local pos = oRelativeObj:InverseTransformPoint(vWorldPos)
		return {x = pos.x + (self.m_Width/2), y = pos.y}
	end
	return nil
end

function CLive2dModel.SetSize(self, w, h)
	self.m_Width = w
	self.m_Height = h
end

function CLive2dModel.SetRelative(self, obj)
	self.m_RelativeObjRef= weakref(obj)
end

function CLive2dModel.SetRandomMotionList(self, sMotionList)
	self.m_RandomMotionList = sMotionList
end


function CLive2dModel.IsAABBContainPoint(self, aabb, point)
	if (point.x < aabb.x) then
		return (false)
	end
	if (point.x > aabb.y) then
		return (false)
	end
	if (point.y < aabb.z) then
		return false
	end
	if (point.y > aabb.w) then
		return false
	end
	return true
end

function CLive2dModel.Destroy(self)
	CLive2dModel.Idx = CLive2dModel.Idx - 1
	self:ClearTexture()
	CObject.Destroy(self)
end

return CLive2dModel