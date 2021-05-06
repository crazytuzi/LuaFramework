local CActionVector = class("CActionVector", CActionBase)

function CActionVector.ctor(self, oTarget, iTime, sKey, vBengin, vEnd)
	CActionBase.ctor(self, oTarget, iTime)
	self.m_Key = sKey
	self.m_BeginVector = vBengin
	self.m_EndVector = vEnd
end

function CActionVector.Excute(self, dt)
	local oTarget = self:GetTarget()
	if oTarget then
		local p = self.m_ElapseTime / self.m_TotalTime
		local v = Vector3.Lerp(self.m_BeginVector, self.m_EndVector, p)
		if type(oTarget[self.m_Key]) == "function" then
			oTarget[self.m_Key](oTarget, v)
		else
			oTarget[self.m_Key] = v
		end
		self.m_ElapseTime = self.m_ElapseTime + dt
	else
		self:Stop()
	end
end

return CActionVector