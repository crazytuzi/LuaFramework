local CTcpClient = class("CTcpClient", CDelayCallBase)

function CTcpClient.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_ID = Utils.GetUniqueID()
	self.m_TcpObj = C_api.TcpClient.New()
	self.m_Callback = nil
	self.m_TimeoutTimer = nil
end

function CTcpClient.GetID(self)
	return self.m_ID
end

function CTcpClient.GetIP(self)
	if self.m_TcpObj then
		return self.m_TcpObj.serverIp
	end
end

function CTcpClient.GetPort(self)
	if self.m_TcpObj then
		return self.m_TcpObj.serverPort
	end
end

function CTcpClient.SetMaxProcess(self, iMax)
	if self.m_TcpObj then
		self.m_TcpObj.maxProcess = iMax
	end
end

function CTcpClient.SetCallback(self, cb)
	self.m_Callback = cb
end

function CTcpClient.OnCallback(self, ...)
	if self.m_TimeoutTimer then
		Utils.DelTimer(self.m_TimeoutTimer)
		self.m_TimeoutTimer = nil
	end 
	if self.m_Callback then
		self.m_Callback(...)
	end
end

function CTcpClient.Connect(self, ip, port, timeout)
	if not self.m_TcpObj then
		printerror("tcp obj is nil")
		return
	end
	local err
	if ip then
		self.m_TcpObj:SetCallback(callback(self, "OnCallback"))
		err = self.m_TcpObj:Connect(ip, port)
	else
		err = "tcp connect ip is nil !!!"
	end
	if self.m_TimeoutTimer then
		Utils.DelTimer(self.m_TimeoutTimer)
		self.m_TimeoutTimer = nil
	end
	if err then
		self:OnConnectError(err)
	else
		if timeout and timeout > 0 then
			self.m_TimeoutTimer = Utils.AddTimer(callback(self, "OnConnectError", "tcp connect timeout!!!"), timeout, timeout)
		end
	end
end

function CTcpClient.OnConnectError(self, err)
	print("CTcpClient.OnConnectError:"..err, self.m_TcpObj)
	if self.m_TcpObj then
		self.m_TcpObj:SetCallback(nil)
		self:OnCallback(enum.TcpEvent.ConnnectFail, nil) 
	end
end

function CTcpClient.IsConnected(self)
	if self.m_TcpObj then
		return self.m_TcpObj:IsConnected()
	else
		return false
	end
end

function CTcpClient.Send(self, pbdata)
	if self:IsConnected() then
		self.m_TcpObj:Send(pbdata)
	end
end

function CTcpClient.BatchSend(self, iLen, lDatas)
	if self:IsConnected() then
		local iD = Utils.GetUniqueID()
		local iCur = 1
		while iLen > 0 do
			local iCnt = math.min(1, iLen)
			local iNext= iCur + iCnt
			self.m_TcpObj:BatchSend(iCnt, unpack(lDatas, iCur, iNext-1))
			iCur = iNext
			iLen = iLen - iCnt
		end
	end
end

function CTcpClient.Release(self)
	self:StopDelayCall("Connect")
	self.m_Callback = nil
	if self.m_TcpObj then
		self.m_TcpObj:Release()
		self.m_TcpObj = nil
	end
end

return CTcpClient