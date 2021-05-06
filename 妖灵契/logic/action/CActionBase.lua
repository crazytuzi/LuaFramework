local CActionBase = class("CActionBase")

function CActionBase.ctor(self, oTarget, iTime)
	self.m_ID = g_ActionCtrl:GetNewID()
	self.m_TargetRef = weakref(oTarget)
	self.m_IsLocal = false
	self.m_TotalTime = iTime
	self.m_IsLocal = false
	self.m_ElapseTime = 0
	self.m_EndCallback = nil
	self.m_IsStop = false
	self.m_LateUpdate = (oTarget.m_Camera ~= nil)
end

function CActionBase.SetEndCallback(self, cb)
	self.m_EndCallback = cb
end

function CActionBase.SetLocal(self, bLocal)
	self.m_IsLocal = bLocal
end

function CActionBase.GetTarget(self)
	return getrefobj(self.m_TargetRef)
end

function CActionBase.IsStop(self)
	return self.m_IsStop
end

function CActionBase.Stop(self)
	self.m_IsStop = true
end

function CActionBase.Excute(self, dt)
	--overr
end

return CActionBase