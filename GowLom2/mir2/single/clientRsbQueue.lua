local socket = require("socket")
local clientRsbQueue = {
	timeStamp = 0,
	initSuccess = false,
	timeFunc = socket.gettime,
	rsbQueue = {},
	sendInterval = {}
}
local timePlus = 0
local protoId2Name = {}
clientRsbQueue.init = function (self)
	self.timeStamp = self.timeFunc()
	self.rsbQueue = {}
	self.sendInterval = {
		[CM_WALK] = 0,
		[CM_RUN] = 0,
		[CM_Spell] = 0,
		[CM_HIT] = 0
	}
	protoId2Name = {
		[CM_WALK] = "CM_WALK",
		[CM_RUN] = "CM_RUN",
		[CM_Spell] = "CM_Spell",
		[CM_HIT] = "CM_HIT",
		[CM_TURN] = "CM_TURN"
	}
	local roleSpeed = def.role.speed

	if roleSpeed then
		self.sendInterval[CM_WALK] = (roleSpeed.normal and math.ceil(roleSpeed.normal*1000)) or 600
		self.sendInterval[CM_RUN] = self.sendInterval[CM_WALK]
		self.sendInterval[CM_Spell] = (roleSpeed.spell and math.ceil(roleSpeed.spell*1000)) or 800
		self.sendInterval[CM_HIT] = (roleSpeed.attack and math.ceil(roleSpeed.attack*1000)) or 900
		self.initSuccess = true
	end

	for k, v in pairs(self.sendInterval) do
		self.sendInterval[k] = v + timePlus
	end

	return 
end
local queueMaxNum = 9
clientRsbQueue.pushRsb = function (self, rsb)
	if not self.initSuccess or DEBUG < 1 then
		self.postRsb(self, rsb)

		return 
	end

	if self.sendInterval[rsb.Cmd] == nil then
		self.postRsb(self, rsb)

		return 
	end

	if queueMaxNum < #self.rsbQueue then
		self.rsbQueue = {}

		p2("net", "clientRsbQueue:pushRsb -- clear rsb queuq")
	end

	local curTime = math.ceil(self.timeFunc()*1000)
	local timeDt = curTime - self.timeStamp
	local rsbReady = {
		rsbData = rsb,
		rsbInterval = self.sendInterval[rsb.Cmd],
		rsbTimeStamp = curTime
	}

	if rsb.Cmd == CM_Spell then
		p2("net", "clientRsbQueue:pushRsb -- rsb: " .. (protoId2Name[rsb.Cmd] or rsb.Cmd))
	end

	if self.sendRsbImmediate(self, rsbReady) then
		return 
	else
		table.insert(self.rsbQueue, rsbReady)
	end

	return 
end
cm_timestamp = 0
clientRsbQueue.update = function (self, dt)
	if not self.initSuccess then
		return 
	end

	if self.rsbQueue[1] == nil then
		return 
	end

	if self.sendRsbImmediate(self, self.rsbQueue[1]) then
		table.remove(self.rsbQueue, 1)
	end

	return 
end
clientRsbQueue.sendRsbImmediate = function (self, rsbReady)
	if rsbReady == nil then
		return 
	end

	local sendSuccess = false
	local curTime = math.ceil(self.timeFunc()*1000)
	local timeDt = curTime - self.timeStamp

	if rsbReady.rsbInterval < timeDt then
		self.postRsb(self, rsbReady.rsbData)

		curTime = math.ceil(self.timeFunc()*1000)
		self.timeStamp = curTime
		cm_timestamp = curTime

		p2("net", "clientRsbQueue:update -- timeDt: " .. timeDt .. " postRsb: " .. (protoId2Name[rsbReady.rsbData.Cmd] or rsbReady.rsbData.Cmd))

		sendSuccess = true
	end

	return sendSuccess
end
local tcpGetInstance = MirTcpClient.getInstance
local _tcpPostRsb = slot5(MirTcpClient).postRsb
clientRsbQueue.postRsb = function (self, rsb)
	_tcpPostRsb(tcpGetInstance(MirTcpClient), rsb)

	return 
end

return clientRsbQueue
