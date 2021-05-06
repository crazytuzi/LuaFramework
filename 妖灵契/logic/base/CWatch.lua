local CWatch = class("CWatch")

function CWatch.ctor(self)
	self.m_LastStartTickMS = 0
end

function CWatch.Start(self)
	self.m_LastStartTickMS = C_api.Timer.GetTickMS()
end

function CWatch.Stop(self)
	return C_api.Timer.GetTickMS() - self.m_LastStartTickMS
end

return CWatch