TweenDelay = {}
TweenDelay.__index = TweenDelay

---- delay in second
function TweenDelay.new(delay, callbackfun, callbacktarget)
	local self = {}
	setmetatable(self, TweenDelay)
	self.__index = self
	self.m_pCurrentCount = 0
	self.m_pCallbackFun = callbackfun
	self.m_pCallbackTarget = callbacktarget
	self.m_pDelay = delay * 1000

	return self
end

function TweenDelay:run(delta)
	self.m_pCurrentCount = self.m_pCurrentCount + delta
	if self.m_pCurrentCount > self.m_pDelay then
		self:runEnd()
		self:delete()
	end
end

function TweenDelay:runEnd()
	if self.m_pCallbackFun then
		self.m_pCallbackFun(self.m_pCallbackTarget)
	end
end

function TweenDelay:delete()
	TweenNano.removeDelayCall(self)
end

------////////
return TweenDelay