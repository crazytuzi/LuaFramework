local CCountDownLabel = class("CCountDownLabel", CLabel)

function CCountDownLabel.ctor(self, obj)
	CLabel.ctor(self, obj)
	self.m_CurrentValue = 0
	self.m_EndValue = 0
	self.m_Space = 1
	self.m_Delay = 1
	self.m_AddValue = 1
	self.m_TimerID = nil
	self.m_TimeUPCallback = nil
	self.m_TickFunc = nil
end

--开始倒计时
--[[
startValue 起始值
endValue   结束值
addValue   增量
space      时间间隔
delay      开始倒数的延迟
]]
function CCountDownLabel.BeginCountDown(self, startValue, endValue, addValue, space, delay)
	self.m_CurrentValue = startValue or self.m_CurrentValue
	self.m_EndValue = endValue or self.m_EndValue
	self.m_Space = space or self.m_Space
	self.m_Delay = delay or self.m_Delay
	if addValue then
		self.m_AddValue = addValue
	else
		self.m_AddValue = self.m_CurrentValue >= self.m_EndValue and -1 or 1
	end
	if self.m_TickFunc then
		self.m_TickFunc(self.m_CurrentValue)
	end
	if self.m_CurrentValue ~= self.m_EndValue then
		if self.m_TimerID ~= nil then
			Utils.DelTimer(self.m_TimerID)
		end
		self.m_TimerID = Utils.AddTimer(callback(self, "CountDown"), self.m_Space, self.m_Delay)
	else
		self:OnTimeUP()
	end
end

function CCountDownLabel.SetTickFunc(self, func)
	self.m_TickFunc = func
end

function CCountDownLabel.CountDown(self)
	self.m_CurrentValue = self.m_CurrentValue + self.m_AddValue
	if self.m_TickFunc then
		self.m_TickFunc(self.m_CurrentValue)
	end
	if (self.m_AddValue > 0 and self.m_CurrentValue > self.m_EndValue) 
		or (self.m_AddValue < 0 and self.m_CurrentValue < self.m_EndValue) then
			self:OnTimeUP()
		return false
	end
	return true
end

--倒计时结束回调
function CCountDownLabel.SetTimeUPCallBack(self, callbackFunc)
	self.m_TimeUPCallback = callbackFunc
end

function CCountDownLabel.OnTimeUP(self)
	self:DelTimer()
	if self.m_TimeUPCallback ~= nil then
		self.m_TimeUPCallback()
	end
end

function CCountDownLabel.DelTimer(self)
	if self.m_TimerID ~= nil then
		Utils.DelTimer(self.m_TimerID)
		self.m_TimerID = nil
	end
end

return CCountDownLabel
