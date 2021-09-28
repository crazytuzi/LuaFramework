local ServerTime = {
	localStartTime = 0,
	curTime = 0,
	precision = 1,
	serverStartTime = 0,
	localStartTime = os.time(),
	serverStartTime = ServerTime.localStartTime,
	getTime = function (self)
		local curLocalTime = os.time()
		local deltaTime = curLocalTime - self.localStartTime
		local nowTime = self.serverStartTime + deltaTime

		return nowTime
	end,
	setTime = function (self, curTime)
		self.localStartTime = os.time()
		self.serverStartTime = curTime

		return 
	end,
	syncTime = function (self)
		self.curTime = self.curTime + self.precision

		return 
	end,
	startSync = function (self)
		if self.serverTimeSchedule then
			scheduler.unscheduleGlobal(self.serverTimeSchedule)

			self.serverTimeSchedule = nil
		end

		self.serverTimeSchedule = scheduler.scheduleGlobal(handler(self, self.syncTime), self.precision)

		return 
	end
}

return ServerTime
