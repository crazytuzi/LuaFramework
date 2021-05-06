local CDelegate = class("CDelegate")

function CDelegate.ctor(self, func)
	self.m_ID = Utils.GetUniqueID()
	self.m_Functions = {func}
	self.m_CallOnce = false
end

function CDelegate.SetCallOnce(self, b)
	self.m_CallOnce = b
end

function CDelegate.GetID(self)
	return self.m_ID
end

function CDelegate.Call(self, ...)
	local ret
	for i, func in ipairs(self.m_Functions) do
		local sucess, newRet = xxpcall(func, ...)
		if sucess and ret == nil then
			ret = newRet
		end
	end
	return ret
end

function CDelegate.AddFunction(self, func)
	table.insert(self.m_Functions, func)
end

function CDelegate.GetFunctions(self)
	return self.m_Functions
end

return CDelegate