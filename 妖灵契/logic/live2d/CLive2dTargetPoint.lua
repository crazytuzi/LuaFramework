local CLive2dTargetPoint = class("CLive2dTargetPoint")
CLive2dTargetPoint.FRAME_RATE = 30
-- CLive2dTargetPoint.TIME_TO_MAX_SPEED = 0.05
-- CLive2dTargetPoint.FACE_PARAM_MAX_V = 10
CLive2dTargetPoint.TIME_TO_MAX_SPEED = 0.1
CLive2dTargetPoint.FACE_PARAM_MAX_V = 2
CLive2dTargetPoint.MAX_V = CLive2dTargetPoint.FACE_PARAM_MAX_V / CLive2dTargetPoint.FRAME_RATE
CLive2dTargetPoint.FRAME_TO_MAX_SPEED = CLive2dTargetPoint.TIME_TO_MAX_SPEED * CLive2dTargetPoint.FRAME_RATE

function CLive2dTargetPoint.ctor(self)
	self.m_FaceTargetX = 0
	self.m_FaceTargetY = 0
	self.m_FaceX = 0
	self.m_FaceY = 0
	self.m_FaceVX = 0
	self.m_FaceVY = 0
	self.m_LastTimeSec = 0
end

function CLive2dTargetPoint.Set(self, x, y)
	self.m_FaceTargetX = x
	self.m_FaceTargetY = y
end

function CLive2dTargetPoint.GetX(self)
	return self.m_FaceX
end

function CLive2dTargetPoint.GetY(self)
	return self.m_FaceY
end

function CLive2dTargetPoint.Reset(self)
	self.m_LastTimeSec = 0
end

function CLive2dTargetPoint.Update(self)
	if self.m_LastTimeSec == 0 then
		self.m_LastTimeSec = g_TimeCtrl:GetTimeMS()
		return
	end
	local curTimeSec = g_TimeCtrl:GetTimeMS()
	--时间间隔
	local deltaTimeWeight = (curTimeSec - self.m_LastTimeSec) * self.FRAME_RATE / 1000
	--记录最后一次更新的时间
	self.m_LastTimeSec = curTimeSec
	--时间间隔*最大速度/到达最大速度所需要的祯
	local iMaxA = deltaTimeWeight * self.MAX_V / self.FRAME_TO_MAX_SPEED
	--位移差值
	local dx = self.m_FaceTargetX - self.m_FaceX
	local dy = self.m_FaceTargetY - self.m_FaceY

	if (dx == 0 and dy == 0) then
		return
	end
	--距离的平方
	local d = Mathf.Sqrt(dx * dx + dy * dy)
	
	local vx = self.MAX_V * dx / d
	local vy = self.MAX_V * dy / d
	local ax = vx - self.m_FaceVX
	local ay = vy - self.m_FaceVY
	local a = Mathf.Sqrt(ax * ax + ay * ay)

	if (a < -iMaxA) or (a > iMaxA) then
		ax = ax * iMaxA / a
		ay = ay * iMaxA / a
		a = iMaxA
	end
	self.m_FaceVX = self.m_FaceVX + ax
	self.m_FaceVY = self.m_FaceVY + ay
	--            2  6           2               3
	--      sqrt(a  t  + 16 a h t  - 8 a h) - a t
	-- v = --------------------------------------
	--                    2
	--                 4 t  - 2
	--(t=1)
	local max_v = 0.5 * (Mathf.Sqrt(iMaxA * iMaxA + 16 * iMaxA * d - 8 * iMaxA * d) - iMaxA)
	local cur_v = Mathf.Sqrt(self.m_FaceVX * self.m_FaceVX + self.m_FaceVY * self.m_FaceVY)
	if (cur_v > max_v) then
		self.m_FaceVX = self.m_FaceVX * max_v / cur_v
		self.m_FaceVY = self.m_FaceVY * max_v / cur_v
	end
	self.m_FaceX = self.m_FaceX + self.m_FaceVX
	self.m_FaceY = self.m_FaceY + self.m_FaceVY
end

return CLive2dTargetPoint