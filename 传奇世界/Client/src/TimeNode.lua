local TimeNode = class("TimeNode", function() return cc.Node:create() end)

function TimeNode:ctor()

end

function TimeNode:startTimer(delay, isLoop, callFunc)
	self.startTime = GetTime()
	self.callFunc = callFunc
	self.lastCallTime = self.lastCallTime or self.startTime

	if isLoop == true then
		self.timerAction = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function() 
			self.callFunc(GetTime()-self.lastCallTime, GetTime()-self.startTime)
			self.lastCallTime = GetTime()
			end)))
	else
		self.timerAction = cc.Sequence:create(cc.DelayTime:create(delay), cc.CallFunc:create(function() 
			self.callFunc(GetTime()-self.lastCallTime, GetTime()-self.startTime) 
			self.lastCallTime = GetTime()
			end))
	end

	self:runAction(self.timerAction)
end

return TimeNode