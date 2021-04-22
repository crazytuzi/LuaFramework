local QAlarmClock = class("alarmClock")


function QAlarmClock:ctor(  )
	-- body
	scheduler.scheduleUpdateGlobal(handler(self, self._onFrame))
	self._clock = {}
end

function QAlarmClock:clean(  )
	-- body
	self._clock = {}
end

function QAlarmClock:createNewAlarmClock(tag, time, handle)
	-- body
	-- if self._clock[tag] then
	-- 	-- printInfo(string.format("warning createNewAlarmClock  has tag %s", tag))
	-- end
	if not time or time < 0 then return end
	
	local temp = {}
	temp.time = time
	temp.handle = handle
	self._clock[tag] = temp
end

function QAlarmClock:deleteAlarmClock(tag)
	-- body
	self._clock[tag] = nil
end


function QAlarmClock:pause(  )
	-- body
	self._pause = true
end

function QAlarmClock:resume(  )
	-- body
	self._pause = nil
end

function QAlarmClock:_onFrame( )
	-- body
	if self._pause then
		return
	end
	
	local curTime = q.serverTime()
	for k, v in pairs(self._clock) do
		if curTime >= v.time then
			v.handle()
			self._clock[k] = nil
		end
	end
end

return QAlarmClock


