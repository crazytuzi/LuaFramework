local CActionColor = class("CActionColor", CActionBase)

function CActionColor.ctor(self, oTarget, iTime, sKey, cBengin, cEnd)
	CActionBase.ctor(self, oTarget, iTime)
	self.m_Key = sKey
	self.m_BeginValue = cBengin
	self.m_EndValue = cEnd
end

function CActionColor.Excute(self, dt)
	local oTarget = self:GetTarget()
	if oTarget then
		local p = self.m_ElapseTime / self.m_TotalTime
		local color = Color.Lerp(self.m_BeginValue, self.m_EndValue, p)
		if type(oTarget[self.m_Key]) == "function" then
			oTarget[self.m_Key](oTarget, color)
		else
			oTarget[self.m_Key] = color
		end
		self.m_ElapseTime = self.m_ElapseTime + dt
	else
		self:Stop()
	end
end

return CActionColor