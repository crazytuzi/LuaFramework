local CHouseTouchCtrl = class("CHouseTouchCtrl")

function CHouseTouchCtrl.ctor(self)
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("House")
	self.m_RightAngle = nil
	self.m_LeftAngle = nil
	self.m_StartAngle = nil
	self.m_IsSwip = false
end

function CHouseTouchCtrl.SetRightAngle(self, iAngle)
	self.m_RightAngle = iAngle
end

function CHouseTouchCtrl.SetLeftAngle(self, iAngle)
	self.m_LeftAngle = iAngle
end

function CHouseTouchCtrl.OnTouchUp(self, touchPos)
	if not g_HouseCtrl:IsInHouse() then
		return
	end
	if self.m_IsSwip then
		self.m_IsSwip = false
		return
	end
	local obj = self:GetTouchObject(touchPos.x, touchPos.y)
	if obj and obj.OnTouch then
		obj:OnTouch()
	end
end

function CHouseTouchCtrl.GetTouchObject(self, x, y)
	local lTouch = C_api.EasyTouchHandler.SelectMultiple(g_CameraCtrl:GetHouseCamera().m_Camera, x, y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local iCnt = #lTouch / 2
	for i=1, iCnt do
		local go, point = lTouch[i*2-1], lTouch[i*2]
		local oHouse = g_HouseCtrl:GetCurHouse()
		if oHouse then
			local obj = oHouse:GetObjectByInstanceID(go:GetInstanceID())
			if obj then
				return obj
			end
		end
	end
end

function CHouseTouchCtrl.LockTouch(self, bLock)
	self.m_IsLock = bLock
end

function CHouseTouchCtrl.OnSwipe(self, swipePos)
	if not g_HouseCtrl:IsInHouse() then
		return
	end
	if self.m_IsLock then
		return
	end
	if (swipePos.x > 0 and not self.m_LeftAngle) or
	((swipePos.x < 0 and not self.m_RightAngle)) then
		return
	end
	local oCam = g_CameraCtrl:GetHouseCamera()
	if not self.m_IsSwip then
		self.m_IsSwip = true
		self.m_Angle = oCam:GetEulerAngles()
		--记录总移动角度
		self.m_MovedPos = 0
		--计算左右可转动的最大角度
		if self.m_LeftAngle == nil then
			self.m_TempLeft = 0
		else
			while self.m_LeftAngle > self.m_Angle.y do
				self.m_LeftAngle = self.m_LeftAngle - 360
			end
			if self.m_Angle.y - self.m_LeftAngle > 300 then
				self.m_TempLeft = self.m_Angle.y - self.m_LeftAngle - 360
			else
				self.m_TempLeft = self.m_Angle.y - self.m_LeftAngle
			end
		end
		if self.m_RightAngle == nil then
			self.m_TempRight = 0
		else
			while self.m_RightAngle < self.m_Angle.y do
				self.m_RightAngle = self.m_RightAngle + 360
			end
			
			if self.m_RightAngle - self.m_Angle.y > 300 then
				self.m_TempRight = self.m_Angle.y - self.m_RightAngle + 360
			else
				self.m_TempRight = self.m_Angle.y - self.m_RightAngle
			end
		end
	end
	self.m_MovedPos = self.m_MovedPos + swipePos.x/7
	if self.m_MovedPos > 0 and self.m_MovedPos > self.m_TempLeft then
		self.m_MovedPos = self.m_TempLeft
	elseif self.m_MovedPos < 0 and self.m_MovedPos < self.m_TempRight then
		self.m_MovedPos = self.m_TempRight
	end
	local angle = self.m_Angle.y - self.m_MovedPos
	oCam:SetLocalEulerAngles(Vector3.New(self.m_Angle.x, angle, self.m_Angle.z))

end

return CHouseTouchCtrl