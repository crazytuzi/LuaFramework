--TimerMgr.lua
require("base.class")
Timer = interface(nil, "update")

TimerMgr = class();
function TimerMgr:__init()
	self._updateMap = {}
	self._IDCount = 0
end

function TimerMgr:update(timerID)	
	local timer = self._updateMap[timerID]		
	if timer then	
		timer:update()
		if timer._bOneTime_ then
			self:unregTimer(timer)
			timer._bOneTime_ = nil
		end
	else		
		print("TimerMgr:update>> timer is null.",  toString(timerID))
	end
end

function TimerMgr:isRegTimer(timer)
	return timer._timerID_ ~= nil
end

function TimerMgr:regTimer(timer, elapse, period)	
	if instanceof(timer, Timer) then
		period = period or 0
		elapse = elapse or 0
		if elapse == 0 and period == 0 then
			return
		end
		period = period < 0 and 0 or period
		elapse = elapse < 0 and 0 or elapse

		self._IDCount = self._IDCount + 1
		local ID = self._IDCount
		self._updateMap[ID] = timer
		--register timer to engine
		self._engineTimer:regTimer(ID, elapse, period)
		timer._timerID_ = ID
		timer._bOneTime_ = (period == 0)
		return true
	else
		return false
	end
end

function TimerMgr:count()
	return table.size(self._updateMap)
end

function TimerMgr:unregTimer(timer)
	if instanceof(timer, Timer) then
		if timer._timerID_ and self._updateMap[timer._timerID_] then
			self._updateMap[timer._timerID_] = nil			
			self._engineTimer:unregTimer(timer._timerID_)
			timer._timerID_ = nil
			return true
		end
	end
	return false
end

function TimerMgr:pauseTimer(timer)
	if instanceof(timer, Timer) then
		if timer._timerID_ and self._updateMap[timer._timerID_] then
			self._engineTimer:pauseTimer(timer._timerID_)
		end
	else
		return false
	end
end

function TimerMgr:resumeTimer(timer)
	if instanceof(timer, Timer) then
		if timer._timerID_ and self._updateMap[timer._timerID_] then
			self._engineTimer:resumeTimer(timer._timerID_)
		end
	else
		return false
	end
end

--Create the single instance
gTimerMgr = TimerMgr()
function TimerMgr.getInstance()
	return gTimerMgr
end

function TimerMgr.bindEngine(timerEngine)
	gTimerMgr._engineTimer = timerEngine
end
