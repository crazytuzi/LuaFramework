local socket = require("socket")
local watchdog = {
	beginTime = 0,
	isChecking = false,
	sockets = {},
	timeFunc = socket.gettime,
	beforeCheck = function (self)
		self.isChecking = true
		self.beginTime = self.timeFunc()

		return 
	end,
	afterCheck = function (self, elapsedSeconds)
		local dt = self.timeFunc() - self.beginTime
		local speed = dt/elapsedSeconds

		if type(self.listener) == "function" then
			self.listener(speed)
		end

		self.isChecking = false

		return speed
	end,
	setListener = function (self, cb)
		self.listener = cb

		return 
	end
}
local testThreadNum = 40
watchdog.testSocket = function (self)
	if DEBUG < 1 then
		return 
	end

	for i = 1, testThreadNum, 1 do
		local socket = self.sockets[i]

		if not socket or tolua.isnull(socket) then
			socket = MirTcpClient:newInstance()

			socket.setIsFreeOnTerminate(socket, false)
			socket.setIsLoopConnected(socket, false)
			socket.subscribeOnState(socket, function (state, msg)
				return 
			end)
			socket.addRemoteHost(slot5, "123.123.123.123", 7000)
			socket.setOption(socket, 1, 1)

			self.sockets[i] = socket
		end

		socket.connect(socket)
	end

	return 
end
watchdog.checkSpeedWithSocket = function (self)
	if self.isChecking then
		return 
	end

	self.beforeCheck(self)

	local socket = self.socket

	if not socket or tolua.isnull(socket) then
		socket = MirTcpClient:newInstance()

		socket.setIsFreeOnTerminate(socket, false)
		socket.setIsLoopConnected(socket, false)
		socket.subscribeOnState(socket, function (state, msg)
			if state == TcpClientState.ecsDisconnected then
				self:afterCheck(1)
			end

			return 
		end)

		self.socket = socket
	end

	socket.addRemoteHost(slot1, "123.123.123.123", 7000)
	socket.setOption(socket, 1, 1)
	socket.connect(socket)

	return 
end
watchdog.checkSpeedWithSleep = function (self)
	if self.isChecking then
		return 
	end

	self.beforeCheck(self)
	socket.sleep(0.01)
	self.afterCheck(self, 0.01)

	return 
end

return watchdog
