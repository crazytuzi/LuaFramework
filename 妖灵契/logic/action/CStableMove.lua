local CStableMove = class("CStableMove", CActionBase)

function CStableMove.ctor(self, oTarget, iTime, vBeginPos, vEndPos)
	CActionBase.ctor(self, oTarget, iTime)
	self.m_BeginPos = vBeginPos
	self.m_EndPos = vEndPos
	self.m_IsLocal = true
	self.m_LateUpdate = true
end

function CStableMove.Excute(self, dt)
	local oTarget = self:GetTarget()
	if oTarget then
		local p = self.m_ElapseTime / self.m_TotalTime 
		local oNewPos = Vector3.Lerp(self.m_BeginPos, self.m_EndPos, p)
		if self.m_IsLocal then
			oTarget:SetLocalPos(oNewPos)
		else
			oTarget:SetPos(oNewPos)
		end
		self.m_ElapseTime = self.m_ElapseTime + Utils.g_FrameTime
	else
		self:Stop()
	end
end

return CStableMove