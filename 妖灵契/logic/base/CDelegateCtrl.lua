local CDelegateCtrl = class("CDelegateCtrl")
--和c#交互的lua函数

function CDelegateCtrl.ctor(self)
	self.m_Delgates = setmetatable({}, {__mode="kv"})
	self.m_StrongRef = {}
end

function CDelegateCtrl.Clear(self)
	self.m_Delgates = {}
	self.m_StrongRef = {}
end

function CDelegateCtrl.NewDelegate(self, func)
	local oDelegate = CDelegate.New(func)
	self.m_Delgates[oDelegate:GetID()] = oDelegate
	return oDelegate
end

function CDelegateCtrl.AddStrongRef(self, oDelegate)
	self.m_StrongRef[oDelegate:GetID()] = oDelegate
end

function CDelegateCtrl.CallDelegate(self, id, ...)
	local oDelegate = self.m_Delgates[id]
	if oDelegate then
		if oDelegate.m_CallOnce then
			self.m_StrongRef[id] = nil
			self.m_Delgates[id] = nil
		end
		return oDelegate:Call(...)
	end
end

return CDelegateCtrl