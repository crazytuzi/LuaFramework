local CLookAt = class("CLookAt", CActionBase)

function CLookAt.ctor(self, oTarget, iTime, vookAtPos, vLookAtUp)
	CActionBase.ctor(self, oTarget, iTime)
	self.m_LookAtPos = vookAtPos
	self.m_LookAtUp = vLookAtUp
end

function CLookAt.Excute(self, dt)
	local oTarget = self:GetTarget()
	if oTarget then
		oTarget:LookAt(self.m_LookAtPos, self.m_LookAtUp)
		self.m_ElapseTime = self.m_ElapseTime + dt
	else
		self:Stop()
	end
end

return CLookAt