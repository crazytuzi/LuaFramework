--[[--
	定时器队列:

	--By: yun.bo
	--2013/7/8
]]

local instanceOf = instanceOf

local TFTimerQueue = class('TFTimerQueue', function(...)
	local queue = TFArray:new()
	return queue
end)
function TFTimerQueue:ctor()
end

--[[--
	以给定参数初始化数组
	@param obj: TFArray 或 其他值
	@return obj
]]	
function TFTimerQueue:assign(obj)
	self:clear()
	if instanceOf(obj) == 'TFTimerQueue' then
		for v in obj:iterator() do
			self.m_list[self.tail] = v
			self.tail = self.tail + 1
		end	
	else
		self.m_list[self.tail] = obj
		self.tail = self.tail + 1
	end
	return obj
end

function TFTimerQueue:getTimerAt(nIndex)
	return self:getObjectAt(nIndex)
end

function TFTimerQueue:removeTimerAt(nIndex)
	self:removeObjectAt(nIndex);
end

return TFTimerQueue