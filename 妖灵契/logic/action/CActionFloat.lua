local CActionFloat = class("CActionFloat", CActionBase)

function CActionFloat.ctor(self, oTarget, iTime, sKey, iBengin, iEnd)
	CActionBase.ctor(self, oTarget, iTime)
	self.m_Key = sKey
	self.m_BeginValue = iBengin
	self.m_EndValue = iEnd
end

function CActionFloat.Excute(self, dt)
	local oTarget = self:GetTarget()
	if oTarget then
		local p = self.m_ElapseTime / self.m_TotalTime
		local iValue = Mathf.Lerp(self.m_BeginValue, self.m_EndValue, p)
		if type(oTarget[self.m_Key]) == "number" then
			oTarget[self.m_Key] = iValue
		elseif type(oTarget[self.m_Key]) == "function" then
			oTarget[self.m_Key](oTarget, iValue)
		end
		self.m_ElapseTime = self.m_ElapseTime + dt
	else
		self:Stop()
	end
end

return CActionFloat