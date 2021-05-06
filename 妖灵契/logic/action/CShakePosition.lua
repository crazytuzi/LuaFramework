local CShakePosition = class("CShakePosition", CActionBase)

function CShakePosition.ctor(self, oTarget, iTime, iDis, iRate)
	CActionBase.ctor(self, oTarget, iTime)
	self.m_SkakeDis = iDis
	self.m_ShakeRate = iRate
	self.m_NextShake = 0
	self.m_OriginPos = oTarget:GetPos()
	self.m_IsLocal = true
	self.m_LateUpdate = true
end

function CShakePosition.Excute(self, dt)
	local oTarget = self:GetTarget()
	if oTarget then
		local fixed = self.m_OriginPos
		if self.m_NextShake >= self.m_ShakeRate then
			self.m_NextShake = 0
			local dis =self.m_SkakeDis
			local newpos = fixed + Vector3.New(0, math.Random(-dis,dis), math.Random(-dis,dis))
			oTarget:SetPos(newpos)
		end
		self.m_NextShake = (self.m_NextShake + dt)
		self.m_ElapseTime = self.m_ElapseTime + dt
		if self.m_ElapseTime >= self.m_TotalTime then --还原
			oTarget:SetPos(self.m_OriginPos)
		end
	else
		self:Stop()
	end
end

return CShakePosition