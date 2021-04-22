
local QTcpSocket = class("QTcpSocket")
local QLogFile = import("..utils.QLogFile")

require("pack")
local socket = require("socket")

QTcpSocket.CHECK_CONNECTED_INTERVAL = 0.1
QTcpSocket.CHECK_RECEIVE_INTERVAL = 0.1
QTcpSocket.RECONNECT_COUNT = 3
QTcpSocket.RECONNECT_INTERVAL = 2

QTcpSocket.State_Close = "Close"
QTcpSocket.State_Connected = "Connected"
QTcpSocket.State_Connecting = "Connecting"

QTcpSocket.ReadPackageSize = 1
QTcpSocket.ReadPackageData = 2
QTcpSocket.PackageTitleSize = 4
QTcpSocket.sendPackageTitleSize = 4
QTcpSocket.skipDecrypt = false

QTcpSocket.EVENT_START_CONNECT = "QTCPSOCKET_EVENT_START_CONNECT"
QTcpSocket.EVENT_CONNECT_SUCCESS = "QTCPSOCKET_EVENT_CONNECT_SUCCESS"
QTcpSocket.EVENT_CONNECT_FAILED = "QTCPSOCKET_EVENT_CONNECT_FAILED"
QTcpSocket.EVENT_CONNECT_CLOSE = "QTCPSOCKET_EVENT_CONNECT_CLOSE"
QTcpSocket.EVENT_RECEIVE_PACKAGE = "QTCPSOCKET_EVENT_RECEIVE_PACKAGE"

function QTcpSocket:ctor(host, port)
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

	QLogFile:debug("QTcpSocket: init host ip " .. tostring(host))
	self._host = host
	self._port = port

	self._state = QTcpSocket.State_Close
	self._connectCount = 0

	--send
	self._resendRequests = {}
	self._needReceivePackageCount = 0

	-- receive
	self._binary = ""
	self._binaryTitle = ""
	self._binarySize = -1
	self._readPackageState = QTcpSocket.ReadPackageSize
end

function QTcpSocket:_createTcpObject()
	if self._tcp ~= nil then
		self:_removeTcpObject()
	end

	--[[
		socket.tcp()

		Creates and returns a TCP master object. 
		A master object can be transformed into a server object with the method listen (after a call to bind) or into a client object with the method connect. 
		The only other method supported by a master object is the close method.
		In case of success, a new master object is returned. In case of error, nil is returned, followed by an error message.
	--]]
	self._tcp = socket.tcp()

	--[[
		Note: Starting with LuaSocket 2.0, the settimeout method affects the behavior of connect, 
		causing it to return with an error in case of a timeout. 
		If that happens, you can still call socket.select with the socket in the sendt table. 
		The socket will be writable when the connection is established.
	--]]
	self._tcp:settimeout(1)
end

function QTcpSocket:_removeTcpObject()
	if self._tcp == nil then
		return
	end

	self._tcp = nil
end

function QTcpSocket:getState()
	return self._state
end

function QTcpSocket:getHost()
	return self._host
end

function QTcpSocket:setHost(host)
	if host ~= nil then
		self._host = host
	end
end

function QTcpSocket:getPort()
	return self._port
end

function QTcpSocket:setPort(port)
	if port ~= nil then
		self._port = port
	end
end

function QTcpSocket:connect()
	if self._state ~= QTcpSocket.State_Close then
		return
	end

	QLogFile:debug(function ( ... )
		return string.format("QTcpSocket: TCP socket starts connecting to %s:%s", tostring(self._host), tostring(self._port))
	end)

	self:_createTcpObject()
	self._state = QTcpSocket.State_Connecting

	-- delay one frame to connet server
	scheduler.performWithDelayGlobal(function()
		if self._connectCount == 0 then
			self:dispatchEvent({name = QTcpSocket.EVENT_START_CONNECT})
		end
		if self._connectScheduler ~= nil then
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
		end
		if self:_checkConnect() == false then
			self._connectScheduler = scheduler.scheduleGlobal(handler(self, self._onCheckConnectUpdate), QTcpSocket.CHECK_CONNECTED_INTERVAL)
		end
	end, 0)

end

function QTcpSocket:disConnect()
	QLogFile:debug("QTcpSocket: TCP socket starts to disconnect, state " .. tostring(self._state))
	if self._updateScheduler ~= nil then
		scheduler.unscheduleGlobal(self._updateScheduler)
		self._updateScheduler = nil
	end

	if self._state == QTcpSocket.State_Connected then
		--[[
			Mode tells which way of the connection should be shut down and can take the value:
			"both": disallow further sends and receives on the object. This is the default mode;
			"send": disallow further sends on the object;
			"receive": disallow further receives on the object.
		--]]
		self._tcp:shutdown("both")
		self:_close(true)
	elseif self._state == QTcpSocket.State_Connecting then
		if self._connectScheduler ~= nil then
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
		end
		self:_close(true)
	end
end

-- send data 
function QTcpSocket:send(data)
	if data == nil or string.len(data) == 0 then
		if DEBUG > 0 then
			assert(false, "QTcpSocket:send invaild data")
		end
		return false
	end

	if self._state ~= QTcpSocket.State_Connected then
		if DEBUG > 0 then
			printInfo("QTcpSocket:send current state is " .. self._state .. " can not send data!")
		end
		return false
	end

	if self:_checkIfSocketCanSend() == false then
		if DEBUG > 0 then
			printInfo("QTcpSocket:send current socket can not send data!")
		end
		return false
	end

	if DEBUG > 0 then
		printInfo("QTcpSocket:send send package size:" .. tostring(string.len(data)))
	end
	
	if ENCRYPT > 0 then
		data = crypto.encryptXXTEA(data, NETWORK_KEY)
	end
	data = string.pack(">b", ENCRYPT) .. data
	local sendData = string.pack(((QTcpSocket.sendPackageTitleSize == 2) and ">H" or ">I"), string.len(data)) .. data

	--[[
		client:send(data, i, j)
		Sends data through client object.
		Data is the string to be sent. The optional arguments i and j work exactly like the standard string.sub Lua function to allow the selection of a substring to be sent.
		If successful, the method returns the index of the last byte within [i, j] that has been sent. 
		Notice that, if i is 1 or absent, this is effectively the total number of bytes sent. 
		In case of error, the method returns nil, followed by an error message, followed by the index of the last byte within [i, j] that has been sent. You might want to try again from the byte following that. 
		The error message can be 'closed' in case the connection was closed before the transmission was completed or the string 'timeout' in case there was a timeout during the operation.
		Note: Output is not buffered. For small strings, it is always better to concatenate them in Lua (with the '..' operator) and send the result in one call instead of calling the method several times.
	--]]

	local result, errorCode = self._tcp:send(sendData)
	assert(result == nil or errorCode == nil, " send data result: "..tostring(result).." errorCode: "..tostring(errorCode))
	if errorCode ~= nil then
		table.insert(self._resendRequests, {sendData = sendData})
		self:_onReceiveError(errorCode)
		return false
	end

	self._needReceivePackageCount = self._needReceivePackageCount + 1

	return true
end

--[[
	add requets to resend list front
--]]
function QTcpSocket:addRequestToResend(data, name)
	if data == nil or string.len(data) == 0 then
		if DEBUG > 0 then
			assert(false, "QTcpSocket:send invaild data")
		end
		return
	end

	if DEBUG > 0 then
		printInfo("QTcpSocket:add send package size:" .. tostring(string.len(data)))
	end

	if ENCRYPT > 0 then
		data = crypto.encryptXXTEA(data, NETWORK_KEY)
	end
	data = string.pack(">b", ENCRYPT) .. data
	local sendData = string.pack(((QTcpSocket.sendPackageTitleSize == 2) and ">H" or ">I"), string.len(data)) .. data
	table.insert(self._resendRequests, 1, {name = name, sendData = sendData})
end

function QTcpSocket:getResendRequest()
	return self._resendRequests
end

function QTcpSocket:_checkConnect()
	if self:_doConnect() == true then
		if self._updateScheduler == nil then
			self._updateScheduler = scheduler.scheduleGlobal(handler(self, self._onUpdate), QTcpSocket.CHECK_RECEIVE_INTERVAL)
		end
		QLogFile:debug("QTcpSocket: TCP socket is connected in QTcpSocket:_checkConnect()")
		self:dispatchEvent({name = QTcpSocket.EVENT_CONNECT_SUCCESS})
		return true
	else
		return false
	end
end

function QTcpSocket:_onCheckConnectUpdate(dt)
	if self._checkConnectDuration == nil then
		self._checkConnectDuration = dt
	else
		self._checkConnectDuration = self._checkConnectDuration + dt
	end

	if self:checkIfSocketIsConnected() == true then
		self._checkConnectDuration = nil
		if self._connectScheduler ~= nil then
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
		end
		self._connectCount = 0

		if self._updateScheduler == nil then
			self._updateScheduler = scheduler.scheduleGlobal(handler(self, self._onUpdate), QTcpSocket.CHECK_RECEIVE_INTERVAL)
		end
		QLogFile:debug("QTcpSocket: TCP socket is connected in QTcpSocket:_onCheckConnectUpdate()")
		self:dispatchEvent({name = QTcpSocket.EVENT_CONNECT_SUCCESS})

	elseif self._checkConnectDuration > QTcpSocket.RECONNECT_INTERVAL then
		self._checkConnectDuration = nil
		if self._connectScheduler ~= nil then
			scheduler.unscheduleGlobal(self._connectScheduler)
			self._connectScheduler = nil
		end
		self:_close()

		self._connectCount = self._connectCount + 1
		if self._connectCount >= QTcpSocket.RECONNECT_COUNT then
			self._connectCount = 0
			self:dispatchEvent({name = QTcpSocket.EVENT_CONNECT_FAILED})
		else
			self:connect()
		end
	end
end

function QTcpSocket:_doConnect()
	if self._tcp == nil then
		return false
	end

	if self._host == nil then
		return false
	end

	if DEBUG > 0 then
		printInfo("QTcpSocket want to connect " .. self._host .. ":" .. tostring(self._port))
	end

	--[[
		master:connect(address, port)

		Attempts to connect a master object to a remote host, transforming it into a client object. 
		Client objects support methods send, receive, getsockname, getpeername, settimeout, and close.
		Address can be an IP address or a host name. Port must be an integer number in the range [1..64K).
		In case of error, the method returns nil followed by a string describing the error. In case of success, the method returns 1.
		Note: The function socket.connect is available and is a shortcut for the creation of client sockets.
		Note: Starting with LuaSocket 2.0, the settimeout method affects the behavior of connect, causing it to return with an error in case of a timeout. 
		If that happens, you can still call socket.select with the socket in the sendt table. The socket will be writable when the connection is established.
	--]]
	local isSuccess, errorCode = self._tcp:connect(self._host, self._port)
	if isSuccess == 1 or errorCode == "already connected" then
		if DEBUG > 0 then
			printInfo("QTcpSocket connect success with error:" .. tostring(errorCode))
		end

		self._state = QTcpSocket.State_Connected

		--[[
			client:setoption(option [, value])
			server:setoption(option [, value])

			Sets options for the TCP object. Options are only needed by low-level or time-critical applications. 
			You should only modify an option if you are sure you need it.

			Option is a string with the option name, and value depends on the option being set:
			'keepalive': Setting this option to true enables the periodic transmission of messages on a connected socket. 
						Should the connected party fail to respond to these messages, the connection is considered broken and processes using the socket are notified;
			'linger': Controls the action taken when unsent data are queued on a socket and a close is performed. 
						The value is a table with a boolean entry 'on' and a numeric entry for the time interval 'timeout' in seconds. 
						If the 'on' field is set to true, the system will block the process on the close attempt until it is able to transmit the data or until 'timeout' has passed. 
						If 'on' is false and a close is issued, the system will process the close in a manner that allows the process to continue as quickly as possible. 
						I do not advise you to set this to anything other than zero;
			'reuseaddr': Setting this option indicates that the rules used in validating addresses supplied in a call to bind should allow reuse of local addresses;
			'tcp-nodelay': Setting this option to true disables the Nagle's algorithm for the connection.
			The method returns 1 in case of success, or nil otherwise.
		--]]
		self._tcp:setoption("keepalive", true)
		self._tcp:setoption("tcp-nodelay", true)

		QLogFile:info("QTcpSocket: Network connection is established")	
		return true
	else
		self:_onReceiveError(errorCode)
		return false
	end
end

function QTcpSocket:_onUpdate()
	if self._state ~= QTcpSocket.State_Connected then
		return
	end

	while #self._resendRequests > 0 do
		local success = self:_resendData()
		if success == false then
			break
		end
	end

	if #self._resendRequests == 0 then

		while true do
			local success = false

			if self:_checkIfSocketCanReceive() == true then
				if self._readPackageState == QTcpSocket.ReadPackageSize then
					success = self:_readPackageSize()
				elseif self._readPackageState == QTcpSocket.ReadPackageData then
					success = self:_readPackageData(self._binarySize - string.len(self._binary))
				else
					if DEBUG > 0 then
						assert(false, "QTcpSocket:_onUpdate invalid receive state:" .. tostring(self._readPackageState))
					end
				end
			end

			if self._binarySize == string.len(self._binary) then
				local n, value = string.unpack(self._binary, ">b")
				self._binary = string.sub(self._binary, 2)
				if value > 0 and not QTcpSocket.skipDecrypt then
					self._binary = crypto.decryptXXTEA(self._binary, NETWORK_KEY)
				end

				local binary = self._binary
				self._binary = ""
				self._binaryTitle = ""
				self._binarySize = -1

				if self._needReceivePackageCount > 0 then
					self._needReceivePackageCount = self._needReceivePackageCount - 1
				end

				self:dispatchEvent({name = QTcpSocket.EVENT_RECEIVE_PACKAGE, package = binary})
			end

			if success == false then
				break
			end

			if self._needReceivePackageCount == 0 then
				break
			end

		end
	end

end

function QTcpSocket:_resendData()
	if self._state ~= QTcpSocket.State_Connected then
		return false
	end

	if #self._resendRequests == 0 then
		return false
	end

	if self:_checkIfSocketCanSend() == false then
		return false
	end

	local request = self._resendRequests[1]

	local result, errorCode = self._tcp:send(request.sendData)
	if errorCode ~= nil then
		-- self:_onReceiveError(errorCode)
		self:_close(true)
		return false
	end

	table.remove(self._resendRequests, 1)

	self._needReceivePackageCount = self._needReceivePackageCount + 1

	return true
end

--[[
	socket.select(recvt, sendt [, timeout])

	Waits for a number of sockets to change status.
	Recvt is an array with the sockets to test for characters available for reading. 
	Sockets in the sendt array are watched to see if it is OK to immediately write on them. 
	Timeout is the maximum amount of time (in seconds) to wait for a change in status. 
	A nil, negative or omitted timeout value allows the function to block indefinitely. 
	Recvt and sendt can also be empty tables or nil. Non-socket values (or values with non-numeric indices) in the arrays will be silently ignored.
	The function returns a list with the sockets ready for reading, a list with the sockets ready for writing and an error message. 
	The error message is "timeout" if a timeout condition was met and nil otherwise. 
	The returned tables are doubly keyed both by integers and also by the sockets themselves, to simplify the test if a specific socket has changed status.
	Important note: a known bug in WinSock causes select to fail on non-blocking TCP sockets. 
	The function may return a socket as writable even though the socket is not ready for sending.
	Another important note: calling select with a server socket in the receive parameter before a call to accept does not guarantee accept will return immediately. 
	Use the settimeout method or accept might block forever.
	Yet another note: If you close a socket and pass it to select, it will be ignored.
--]]

-- function QTcpSocket:checkIfSocketIsConnected()
-- 	if self._tcp == nil then
-- 		return false
-- 	end

-- 	-- if self._state == QTcpSocket.State_Connected then
-- 	-- 	return true
-- 	-- end

-- 	local recvt, sendt, errorCode = socket.select({self._tcp}, {self._tcp}, 0)
	
-- 	if errorCode ~= nil then
-- 		self:_onReceiveError(errorCode)
-- 		return false
-- 	end

-- 	if sendt[1] == self._tcp then
-- 		self._state = QTcpSocket.State_Connected

-- 		self._tcp:setoption("keepalive", true)
-- 		self._tcp:setoption("tcp-nodelay", true)

-- 		return true
-- 	end

-- 	return false
-- end

function QTcpSocket:checkIfSocketIsConnected()
	if self._tcp == nil then
		return false
	end

	local recvt, sendt, errorCode = socket.select(nil, {self._tcp}, 0)
	
	if errorCode ~= nil then
		self:_onReceiveError(errorCode)
	else
		if sendt[1] == self._tcp then
			-- Lua socket master/client object will be switched which will cause receive function error
			-- https://books.google.co.jp/books?id=Br8l4Z_XUgoC&pg=PA511&lpg=PA511&dq=luasocket+%27receive%27+on+bad+self&source=bl&ots=DhGme2NyqF&sig=6r0ma1L59MV1a6mY4viX8Wsy_0o&hl=zh-CN&sa=X&redir_esc=y#v=onepage&q=luasocket%20'receive'%20on%20bad%20self&f=false
			local connectivity = false
			local i, err = pcall(function ( ... )
				local data, errorCode2, partial = self._tcp:receive(0)
				if errorCode2 == nil or errorCode2 == "timeout" then
					self._state = QTcpSocket.State_Connected

					self._tcp:setoption("keepalive", true)
					self._tcp:setoption("tcp-nodelay", true)

					QLogFile:debug("QTcpSocket: check network connection is connective")
					connectivity = true
				end
			end)

			if i == true then
				if connectivity then return true end
			else
				QLogFile:debug("QTcpSocket: failed to check connection's connectivity due to receive object error")
				return false
			end
		end	
	end


	QLogFile:debug("QTcpSocket: check network connection is not connective")
	return false
end

function QTcpSocket:_checkIfSocketCanSend()
	if self._tcp == nil then
		return false
	end

	if self._state ~= QTcpSocket.State_Connected then
		return false
	end

	local recvt, sendt, errorCode = socket.select(nil, {self._tcp}, 0)
	
	if errorCode ~= nil then
		self:_onReceiveError(errorCode)
		return false
	end

	if sendt[1] == self._tcp then
		return true
	end

	return false
end

function QTcpSocket:_checkIfSocketCanReceive()
	if self._tcp == nil then
		return false
	end

	if self._state ~= QTcpSocket.State_Connected then
		return false
	end

	local recvt, sendt, errorCode = socket.select({self._tcp}, nil, 0)

	if errorCode ~= nil and errorCode ~= "timeout" then
		self:_onReceiveError(errorCode)
		return false
	end

	if recvt[1] == self._tcp then
		return true
	end

	return false
end

--[[
	client:receive(pattern, prefix)

	Pattern can be any of the following:
	'*a': reads from the socket until the connection is closed. No end-of-line translation is performed;
	'*l': reads a line of text from the socket. The line is terminated by a LF character (ASCII 10), optionally preceded by a CR character (ASCII 13). The CR and LF characters are not included in the returned line. In fact, all CR characters are ignored by the pattern. This is the default pattern;
	number: causes the method to read a specified number of bytes from the socket.

	Prefix is an optional string to be concatenated to the beginning of any received data before return.

	If successful, the method returns the received pattern. 
	In case of error, the method returns nil followed by an error message which can be the string 'closed' in case the connection was closed before the transmission was completed or the string 'timeout' in case there was a timeout during the operation. 
	Also, after the error message, the function returns the partial result of the transmission.

	Important note: 
	This function was changed severely. 
	It used to support multiple patterns (but I have never seen this feature used) and now it doesn't anymore. 
	Partial results used to be returned in the same way as successful results. 
	This last feature violated the idea that all functions should return nil on error. Thus it was changed too.
--]]

function QTcpSocket:_readPackageSize()
	if self._readPackageState ~= QTcpSocket.ReadPackageSize then
		if DEBUG > 0 then
			assert(false, "QTcpSocket:_readPackageSize last package is not receive completed")
		end
		return false
	end

	local data, errorCode, partial = self._tcp:receive(QTcpSocket.PackageTitleSize)
	local receiveData = data
	if errorCode ~= nil then
		receiveData = partial
		if DEBUG > 0 then
			assert(data == nil, "receive with error:" .. errorCode .. ", but receive data is still have value")
		end
	end

	if receiveData ~= nil and string.len(receiveData) > 0 then
		if self._binaryTitle == nil or self._binaryTitle == "" then
			self._binaryTitle = receiveData
		else
			self._binaryTitle = self._binaryTitle .. receiveData
		end

		local binaryLength = string.len(self._binaryTitle)
		if binaryLength == QTcpSocket.PackageTitleSize then
			local n, value = string.unpack(self._binaryTitle, ((QTcpSocket.PackageTitleSize == 2) and ">H" or ">I"))
			self._binarySize = value
			self._readPackageState = QTcpSocket.ReadPackageData
			if DEBUG > 0 then
				printInfo("QTcpSocket:_readPackageSize received binary size:" .. tostring(self._binarySize))
			end
		elseif binaryLength > QTcpSocket.PackageTitleSize then
			self._binaryTitle = nil
			assert(false, "QTcpSocket:_readPackageSize title size is:" .. tostring(binaryLength) .. " larger than " .. tostring(QTcpSocket.PackageTitleSize))
		end
	end

	if errorCode ~= nil then
		self:_onReceiveError(errorCode)
		return false
	end	

	return true
end

function QTcpSocket:_readPackageData(size)
	if size <= 0 then
		return false
	end

	if self._readPackageState ~= QTcpSocket.ReadPackageData then
		if DEBUG > 0 then
			assert(false, "QTcpSocket:_readPackageData package title is not receive completed")
		end
		return false
	end


	local beginTime = q.time()
	local data, errorCode, partial = self._tcp:receive(size)
	local endTime = q.time()

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

--[[
	luaSocket error describing string in usocket.c:
	"host not found"
	"address already in use"
    "already connected"
    "permission denied"
    "connection refused"
    "closed"
    "timeout"
--]]
function QTcpSocket:_onReceiveError(errorCode)
	QLogFile:info("QTcpSocket: Received an error, errorCode " .. tostring(errorCode))
	QLogFile:debug(debug.traceback())

	if errorCode == "closed" then
		self:_close()
		-- @qinyuanji, we don't know connection closed is due to network issue or server's intention.
		-- To resolve the reconnection issue, we decide not to reconnect when session is explicitly closed
		-- QClient will decide if reconnects
		--self:connect() 

	elseif errorCode == "timeout" then
		-- if DEBUG > 0 then
		-- 	printInfo("QTcpSocket:_onReceiveError with error:" .. errorCode)
		-- end

	else
		if DEBUG > 0 then
			printInfo("QTcpSocket:_onReceiveError with error:" .. errorCode)
		end
	end
end

function QTcpSocket:_close(isManually)
	if self._updateScheduler ~= nil then
		scheduler.unscheduleGlobal(self._updateScheduler)
		self._updateScheduler = nil
	end

	if self._tcp ~= nil then
		self._tcp:close()
		self._state = QTcpSocket.State_Close

		if DEBUG > 0 then
			printInfo("QTcpSocket close socket. Is closed manually? " .. tostring(isManually))
    		printInfo(debug.traceback("", 2))
    	end
		
		self:dispatchEvent({name = QTcpSocket.EVENT_CONNECT_CLOSE, manually = isManually})
	end
end

return QTcpSocket