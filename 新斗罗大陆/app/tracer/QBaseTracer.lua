
local QBaseTracer = class("QBaseTracer")

function QBaseTracer:ctor(type, options)
	self._type = type
end

function QBaseTracer:getType()
	return self._type 
end

function QBaseTracer:beginTrace()
	-- body
end

function QBaseTracer:endTrace()
	-- body
end

return QBaseTracer