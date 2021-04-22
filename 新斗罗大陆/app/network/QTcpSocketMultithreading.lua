-- @Author: ghost
-- @Date:   2018-07-13 17:27:25
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-07-18 11:25:10

local QTcpSocketMultithreading = class("QTcpSocketMultithreading")
local QLogFile = import("..utils.QLogFile")

require("pack")

QTcpSocketMultithreading.CHECK_CONNECTED_INTERVAL = 0.1
QTcpSocketMultithreading.CHECK_RECEIVE_INTERVAL = 0.1
QTcpSocketMultithreading.RECONNECT_COUNT = 3
QTcpSocketMultithreading.RECONNECT_INTERVAL = 2

QTcpSocketMultithreading.State_Close = "Close"
QTcpSocketMultithreading.State_Connected = "Connected"
QTcpSocketMultithreading.State_Connecting = "Connecting"

QTcpSocketMultithreading.PackageTitleSize = 4
QTcpSocketMultithreading.sendPackageTitleSize = 4
QTcpSocketMultithreading.skipDecrypt = false

QTcpSocketMultithreading.EVENT_START_CONNECT = "EVENT_START_CONNECT"
QTcpSocketMultithreading.EVENT_CONNECT_SUCCESS = "EVENT_CONNECT_SUCCESS"
QTcpSocketMultithreading.EVENT_CONNECT_FAILED = "EVENT_CONNECT_FAILED"
QTcpSocketMultithreading.EVENT_CONNECT_CLOSE = "EVENT_CONNECT_CLOSE"
QTcpSocketMultithreading.EVENT_RECEIVE_PACKAGE = "EVENT_RECEIVE_PACKAGE"

local netMsgHandler = MsgProcessHandler:getInstance()
-- 存储连接的socket的全局表
local socketArr = {}

local onEvent = function(event, connIndex, ...)
    local strConn = tostring(connIndex)
    local socket = socketArr[strConn]

    if socket then
        socket:onSocketEvent(event, ...)
    end
end

netMsgHandler:registerScriptHandler(onEvent)


function QTcpSocketMultithreading:ctor(host, port)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	QLogFile:debug("QTcpSocketMultithreading: init host ip " .. tostring(host))
	self._host = host
	self._port = port

	self._state = QTcpSocketMultithreading.State_Close
    self._connIndex = 0           	--scoket连接数
	self._connectCount = 0			--scoket重连次数
	self._isConnected = false
	socketArr = {}
	self._resendRequests = {}      

    socketArr[tostring(self._connIndex)] = self
end

function QTcpSocketMultithreading:_createTcpObject()
	self._netMsgHandler = netMsgHandler
end

function QTcpSocketMultithreading:_removeTcpObject()
	
	if self._state ~= QTcpSocketMultithreading.State_Close then
        self:_close()
    end

	self._connectCount = 0
    socketArr[tostring(self._connIndex)] = nil
end

function QTcpSocketMultithreading:getState()
	return self._state
end

function QTcpSocketMultithreading:getHost()
	return self._host
end

function QTcpSocketMultithreading:setHost(host)
	if host ~= nil then
		self._host = host
	end
end

function QTcpSocketMultithreading:getPort()
	return self._port
end

function QTcpSocketMultithreading:setPort(port)
	if port ~= nil then
		self._port = port
	end
end

function QTcpSocketMultithreading:connect()
	if self._state ~= QTcpSocketMultithreading.State_Close then
		return
	end

	QLogFile:debug(function ( ... )
		return string.format("QTcpSocketMultithreading: TCP socket %s starts connecting to %s:%s", self._connIndex, tostring(self._host), tostring(self._port))
	end)

	if self._netMsgHandler == nil then
		self:_createTcpObject()
    	self._netMsgHandler:connectToServer(self._connIndex, self._host, self._port)
    else
    	-- self._netMsgHandler:reconnectToServer(self._connIndex)
    	self._netMsgHandler:connectToServer(self._connIndex, self._host, self._port)
    end

	self._state = QTcpSocketMultithreading.State_Connecting

	if self._connectCount == 0 then
		self:dispatchEvent({name = QTcpSocketMultithreading.EVENT_START_CONNECT})
	end

	if self._connectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._connectScheduler)
		self._connectScheduler = nil
	end

	if self:_checkConnect() == false then
		self._connectScheduler = scheduler.scheduleGlobal(handler(self, self._onCheckConnectUpdate), self.CHECK_CONNECTED_INTERVAL)
	end
end

function QTcpSocketMultithreading:disConnect()
	QLogFile:debug("QTcpSocketMultithreading: TCP socket starts to disconnect, state " .. tostring(self._state))

	if self._state == QTcpSocketMultithreading.State_Connected or self._state == QTcpSocketMultithreading.State_Connecting then
		self:_close(true)
	end
end

-- send data 
function QTcpSocketMultithreading:send(data)
	if data == nil or string.len(data) == 0 then
		if DEBUG > 0 then
			assert(false, "QTcpSocketMultithreading:send invaild data")
		end
		return
	end

	if self._state ~= QTcpSocketMultithreading.State_Connected then
		if DEBUG > 0 then
			printInfo("QTcpSocketMultithreading:send current state is " .. self._state .. " can not send data!")
		end
		return
	end

	if self._isConnected == false then
		if DEBUG > 0 then
			printInfo("QTcpSocketMultithreading:send current socket can not send data!")
		end
		return
	end

	if DEBUG > 0 then
		printInfo("QTcpSocketMultithreading:send send package size:" .. tostring(string.len(data)))
	end
	
	if ENCRYPT > 0 then
		data = crypto.encryptXXTEA(data, NETWORK_KEY)
	end
	data = string.pack(">b", ENCRYPT) .. data
	local sendData = string.pack(((QTcpSocketMultithreading.sendPackageTitleSize == 2) and ">H" or ">I"), string.len(data)) .. data

    self._netMsgHandler:sendMessage(self._connIndex, 0, sendData, string.len(sendData))

	return true
end

--[[
	add requets to resend list front
--]]
function QTcpSocketMultithreading:addRequestToResend(data, name)
	table.insert(self._resendRequests, 1, {name = name, sendData = sendData})

	self:send(data)
end

function QTcpSocketMultithreading:getResendRequest()
	return self._resendRequests
end

function QTcpSocketMultithreading:_checkConnect()
    return self._isConnected
end

function QTcpSocketMultithreading:_onCheckConnectUpdate(dt)
	if self._checkConnectDuration == nil then
		self._checkConnectDuration = dt
	else
		self._checkConnectDuration = self._checkConnectDuration + dt
	end

	if self._isConnected == true then
		self._checkConnectDuration = nil
		if self._connectScheduler ~= nil then
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
		end
		self._connectCount = 0
	elseif self._checkConnectDuration > QTcpSocketMultithreading.RECONNECT_INTERVAL then
		self._checkConnectDuration = nil
		if self._connectScheduler ~= nil then
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
		end
		self:_close()

		self._connectCount = self._connectCount + 1
		if self._connectCount >= QTcpSocketMultithreading.RECONNECT_COUNT then
			self._connectCount = 0
			self:dispatchEvent({name = QTcpSocketMultithreading.EVENT_CONNECT_FAILED})
		else
			self:connect()
		end
	end
end

function QTcpSocketMultithreading:_doConnect()
	if self._tcp == nil then
		return false
	end

	if self._host == nil then
		return false
	end

	if DEBUG > 0 then
		printInfo("QTcpSocketMultithreading want to connect " .. self._host .. ":" .. tostring(self._port))
	end

    self._netMsgHandler:reconnectToServer(self._connIndex)
end

function QTcpSocketMultithreading:_onUpdate()
	if self._state ~= QTcpSocketMultithreading.State_Connected then
		return
	end
end

function QTcpSocketMultithreading:_resendData()
	if self._state ~= QTcpSocketMultithreading.State_Connected then
		return false
	end

	if #self._resendRequests == 0 then
		return false
	end

	if self:_checkIfSocketCanSend() == false then
		return false
	end

	return true
end

function QTcpSocketMultithreading:checkIfSocketIsConnected()
	-- if self._tcp == nil then
	-- 	return false
	-- end

	return self._isConnected
end

function QTcpSocketMultithreading:_checkIfSocketCanSend()
	return self:checkIfSocketIsConnected()
end

function QTcpSocketMultithreading:_checkIfSocketCanReceive()
	return self:checkIfSocketIsConnected()
end

function QTcpSocketMultithreading:_readPackageSize()
	return true
end

function QTcpSocketMultithreading:_readPackageData(data)
	if data == nil then
		return false
	end

	if DEBUG > 0 then
		if device.platform == "ios" or device.platform == "android" then
			-- CCMessageBox("receive data time cost:" .. tostring(endTime - beginTime), "Debug Info")
		else
			printInfo("receive data time cost:" .. tostring(endTime - beginTime))
		end
	end
	

	local receiveData = data
	if errorCode ~= nil then
		receiveData = partial
		if DEBUG > 0 then
			assert(data == nil, "receive with error:" .. errorCode .. ", but receive data is still have value")
		end
	end

	if receiveData ~= nil and string.len(receiveData) > 0 then
		if self._binary == nil or self._binary == "" then
			self._binary = receiveData
		else
			self._binary = self._binary .. receiveData
		end

		if string.len(self._binary) == self._binarySize then
			self._readPackageState = QTcpSocket.ReadPackageSize
		elseif string.len(self._binary) > self._binarySize then
			assert(false, "QTcpSocket:_readPackageData data size is:" .. tostring(string.len(self._binary)) .. " larger than " .. tostring(self._binarySize))
		end
	end

	if errorCode ~= nil then
		self:_onReceiveError(errorCode)
		return false
	end

	return true
end

function QTcpSocketMultithreading:_onReceiveError(errorCode)
	QLogFile:info("QTcpSocketMultithreading: Received an error, errorCode " .. tostring(errorCode))
	QLogFile:debug(debug.traceback())

	if errorCode == "closed" then
		self:_close()
	elseif errorCode == "timeout" then
		if DEBUG > 0 then
			printInfo("QTcpSocketMultithreading:_onReceiveError with error:" .. errorCode)
		end
	else
		if DEBUG > 0 then
			printInfo("QTcpSocketMultithreading:_onReceiveError with error:" .. errorCode)
		end
	end
end

function QTcpSocketMultithreading:_close(isManually) 

	self._netMsgHandler:removeConnect(self._connIndex)
    self._isConnected = false
	self._state = QTcpSocketMultithreading.State_Close

	if DEBUG > 0 then
		printInfo("QTcpSocketMultithreading close socket. Is closed manually? " .. tostring(isManually))
		printInfo(debug.traceback("", 2))
	end
	
	self:dispatchEvent({name = QTcpSocketMultithreading.EVENT_CONNECT_CLOSE, manually = isManually})
end

function QTcpSocketMultithreading:onSocketEvent(event, ...)
    if event == "netmsg" then
        self:_onReceiveNetMsg(...)
    elseif event == "connect_success" then
        self:_onConnectSuccess()
    elseif event == "connect_fail" then -- 连接失败回调
    	self:_close()
    elseif event == "connect_broken" then -- 连接断开回调
    	self:_close()
    elseif event == "exception" then -- 网络异常回调
    	self:_close()
    end

end

function QTcpSocketMultithreading:_onReceiveNetMsg(msgBuf, msgLen, msgId)
	local binary = string.sub(msgBuf, 5)
	local n, value = string.unpack(binary, ">b")
	binary = string.sub(binary, 2)
	if value > 0 and not QTcpSocketMultithreading.skipDecrypt then
		binary = crypto.decryptXXTEA(binary, NETWORK_KEY)
	end

	self._resendRequests = {}
	self:dispatchEvent({name = QTcpSocketMultithreading.EVENT_RECEIVE_PACKAGE, package = binary})
end

function QTcpSocketMultithreading:_onConnectSuccess()
	if self._connectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._connectScheduler)
		self._connectScheduler = nil
	end

    self._isConnected = true
    self._state = QTcpSocketMultithreading.State_Connected
    self:dispatchEvent({name = QTcpSocketMultithreading.EVENT_CONNECT_SUCCESS})
end

return QTcpSocketMultithreading
