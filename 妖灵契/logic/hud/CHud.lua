local CHud = class("CHud", CObject)
CHud.g_BatchCall = true

function CHud.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_HudHandler = self:GetMissingComponent(classtype.HudHandler)
	self.m_BatchCallID = self.m_HudHandler:GetInstanceID()
	self:SetUICamera(g_CameraCtrl:GetUICamera().m_Camera)
	self.m_OwnerRef = nil
end

function CHud.PushBatchCall(self, funcName, ...)
	local iEnum = enum.BatchCall.FuncType[funcName]
	if CHud.g_BatchCall and iEnum then
		g_BatchCallCtrl:PushCallData(enum.BatchCall.ObjType.HudHandler, 
		self.m_BatchCallID, iEnum, ...)
	else
		local c = string.sub(funcName, 1, 1)
		if string.upper(c) == c then
			self.m_HudHandler[funcName](self.m_HudHandler, ...)
		else
			self.m_HudHandler[funcName] = select(1, ...)
		end
	end
end

function CHud.SetTarget(self, transform)
	-- self.m_HudHandler.target = transform
	self:PushBatchCall("target", transform)
end

function CHud.SetGameCamera(self, oCam)
	-- self.m_HudHandler.gameCamera = oCam

	self:PushBatchCall("gameCamera", oCam)
end

function CHud.SetUICamera(self, oCam)
	-- self.m_HudHandler.uiCamera = oCam
	self:PushBatchCall("uiCamera", oCam)
end

function CHud.SetAutoUpdate(self, b)
	-- self.m_HudHandler.isAutoUpdate = b
	self:PushBatchCall("isAutoUpdate", b)
end

function CHud.SetWalkEventHandler(self, obj)
	-- self.m_HudHandler.walkerEventHandler = obj
	self:PushBatchCall("walkerEventHandler", obj)
end

function CHud.ResetHud(self)
	-- self.m_HudHandler:ResetHud()
	self:PushBatchCall("ResetHud")
end

--回收
function CHud.Recycle(self)
	
end

--重复使用
function CHud.Reuse(self, oOwner)

end

function CHud.SetOwner(self, oOwner)
	if oOwner then
		self.m_OwnerRef = weakref(oOwner)
		self:Reuse(oOwner)
	else
		self.m_OwnerRef = nil
	end
end

function CHud.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

return CHud