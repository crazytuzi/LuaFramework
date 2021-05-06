local CAsyncHud = class("CAsyncHud", CHud, CGameObjContainer)

function CAsyncHud.ctor(self, path, cb, bPrior)
	g_ResCtrl:LoadCloneAsync(path, callback(self, "OnHudLoadDone"), bPrior)
	self.m_Path = path
	self.m_Callback = cb
end

function CAsyncHud.OnHudLoadDone(self, oClone, path)
	CHud.ctor(self, oClone)
	CGameObjContainer.ctor(self, oClone)
	self:OnCreateHud()
	if self.m_Callback then
		self.m_Callback(self)
		self.m_Callback = nil
	end
end

function CAsyncHud.OnCreateHud(self)
	-- override
end

return CAsyncHud