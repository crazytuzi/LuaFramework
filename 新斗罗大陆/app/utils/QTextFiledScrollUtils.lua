--
-- Author: Your Name
-- Date: 2014-10-29 17:45:48
--
local QTextFiledScrollUtils = class("QTextFiledScrollUtils")

function QTextFiledScrollUtils:ctor()

end

function QTextFiledScrollUtils:addUpdate(startNum, endNum, callback, time, endCallback)
	time = time or 1
	self:stopUpdate()
	if startNum ~= endNum then
		self._callback = callback
		self._endCallback = endCallback
		self._startNum = tonumber(startNum)
		self._endNum = tonumber(endNum)
		self._perValue = (endNum - startNum) / (time * 60)
		-- if self._perValue > 0 then 
		-- 	if self._perValue < 1 then
		-- 		self._perValue = 1
		-- 	else
		-- 		self._perValue = math.ceil(self._perValue)
		-- 	end
		-- else
		-- 	if self._perValue > -1 then
		-- 		self._perValue = -1
		-- 	else
		-- 		self._perValue = math.floor(self._perValue)
		-- 	end
		-- end
		self._handler = scheduler.scheduleGlobal(handler(self,self.onframe), 0)
	else
		if callback then
			callback(startNum)
		end
	end
end

function QTextFiledScrollUtils:onframe()
	self._startNum = self._startNum + self._perValue
	if (self._perValue > 0 and self._startNum > self._endNum) or (self._perValue < 0 and self._startNum < self._endNum) then
		self._startNum = self._endNum
	end

	if self._callback then
		self._callback(self._startNum)
	end
	
	if self._startNum == self._endNum then
		self:stopUpdate()
		if self._endCallback then
			self._endCallback()
		end
	end
end

function QTextFiledScrollUtils:stopUpdate()
	if self._handler ~= nil then
		scheduler.unscheduleGlobal(self._handler)
		self._handler = nil
	end
end

return QTextFiledScrollUtils