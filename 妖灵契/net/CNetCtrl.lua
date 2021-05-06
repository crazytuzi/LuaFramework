local CNetCtrl = class("CNetCtrl", CCtrlBase)
local string = string
local ipairs = ipairs
local unpack = unpack
local table = table

function CNetCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ProtoHanlder = CNetProtoHandler.New()
	self.m_MaxPacketSize = 10 * 1024
	self.m_TestNetList = {}
	self.m_TestNetObj = nil
	self.m_MainNetObj = nil
	self.m_TestConnectTimer = nil
	self.m_ProtoCache = {}
	self.m_IsNeedCache = {}
	self.m_LastIPAndPort= {}
	self.m_WaitConnect = {}
	self.m_HasAutoReconnect = false
	self.m_IsClientActive = true
	self.m_BigPackets = {}
	self.m_TestCnt = 0

	self.m_CurProtoData = nil
	--协议记录相关(实现战斗录像等功能)
	self.m_Records = {}
	self.m_RecordType = nil
	self:ResetReceiveRecord()
	self.m_Sessions = {}
end

function CNetCtrl.SessionResponse(self, iSession)
	local timer = self.m_Sessions[iSession]
	if timer then
		Utils.DelTimer(timer) 
	end
	if iSession == netdefines.C2GS_BY_NAME["C2GSOpenShop"] then
		g_NotifyCtrl:HideConnect()
	end
	self.m_Sessions[iSession] = nil
end

function CNetCtrl.IsValidSession(self, iSession, iTime)
	if self.m_Sessions[iSession] then
		return false
	else
		netother.C2GSClientSession(iSession)
		iTime = iTime or 1
		self.m_Sessions[iSession] = Utils.AddTimer(callback(self, "SessionResponse", iSession), iTime, iTime)
		return true
	end
end

function CNetCtrl.IsConnecting(self)
	local iCnt = 0
	for ip, ports in pairs(self.m_WaitConnect) do
		if ports and next(ports) then
			return true
		end
	end
	return false
end

function CNetCtrl.Connect(self, ip, ports)
	if not ip then
		g_NotifyCtrl:FloatMsg("请求ip为空")
		return
	end
	if not ports then
		g_NotifyCtrl:FloatMsg("请求ports为空")
		return
	end
	self.m_WaitConnect[ip] = table.copy(ports)
	self.m_TestCnt = 0
	self:ConnectNext()
end

function CNetCtrl.Disconnect(self)
	if self.m_MainNetObj then
		self.m_ProtoHanlder:ProcessSendList(self.m_MainNetObj)
		self.m_MainNetObj:Release()
		self.m_MainNetObj = nil
	end
	self.m_WaitConnect = {}
end

function CNetCtrl.ConnectNext(self)
	if self.m_TestNetObj then
		print("删除Test连接", self.m_TestNetObj:GetIP(), self.m_TestNetObj:GetPort())
		self.m_TestNetObj:Release()
		self.m_TestNetObj = nil
	end
	for ip, ports in pairs(self.m_WaitConnect) do
		local port = table.randomvalue(ports)
		if port then
			local oTcpClient = CTcpClient.New()
			oTcpClient:SetCallback(function(...) 
				local objip = oTcpClient:GetIP()
				local objport = oTcpClient:GetPort()
				if not (objip and objport) then
					print("ip, port不存在", objip, objport, iEventType)
					g_NotifyCtrl:FloatMsg("网络已断开")
					self.m_MainNetObj = nil
					g_NotifyCtrl:HideConnect()
					self:AutoReconnect()
					return 
				end
				local len = select("#", ...) / 2
				for i = 1, len do
					local idx = 2 * i
					self:OnSocketEvent(oTcpClient, select(idx-1, ...), select(idx, ...))
				end
			end)
			print("Test连接", ip, port)
			self.m_TestNetObj = oTcpClient
			oTcpClient:DelayCall(0, "Connect", ip, port, 3)
			self.m_TestCnt = self.m_TestCnt + 1
			if self.m_TestCnt > 1 then
				g_LoginCtrl:ShowLoginTips("正在连接服务器, 重试"..(self.m_TestCnt-1))
			end
			local index = table.index(ports, port)
			table.remove(ports, index)
			return true
		end
	end
	g_NotifyCtrl:FloatMsg("连接失败，请检查网络")
	g_LoginCtrl:HideLoginTips()
	return false
end

function CNetCtrl.GetNetObj(self)
	return self.m_MainNetObj
end

function CNetCtrl.OnSocketEvent(self, oTcpClient, iEventType, sData)
	if iEventType == enum.TcpEvent.ConnnectSuccess then
		if self.m_MainNetObj then
			self.m_MainNetObj:Release()
			self.m_MainNetObj = nil
		end
		if self.m_TestNetObj and self.m_TestNetObj:GetID() == oTcpClient:GetID() then
			self.m_TestNetObj = nil
		end
		self.m_HasAutoReconnect = false
		self.m_MainNetObj = oTcpClient
		self.m_LastIPAndPort = {ip=oTcpClient:GetIP(), port=oTcpClient:GetPort()}
		self.m_WaitConnect = {}
		g_NotifyCtrl:HideConnect()
	elseif iEventType == enum.TcpEvent.ConnnectFail then
		local ports = self.m_WaitConnect[oTcpClient:GetIP()]
		if self.m_MainNetObj and self.m_MainNetObj:GetID() == oTcpClient:GetID() then
			self.m_MainNetObj = nil
		end
		oTcpClient:Release()
		local bNext = false
		if ports and next(ports) then
			bNext = self:ConnectNext()
		end
		if not bNext then
			g_LoginCtrl:HideLoginTips()
			if self.m_HasAutoReconnect or g_LoginCtrl:HasReconnectInfo() then
				self:ReconnectConfirm()
			else
				main.ResetGame({"CLoginView", "CQRCodeLoginView"})
				local oView = CLoginView:GetView()
				if oView then
					oView:CheckShowPage()
				else
					CLoginView:ShowView()
				end
			end
		end
	elseif iEventType == enum.TcpEvent.ReceiveMessage then
		if self.m_MainNetObj:GetID() == oTcpClient:GetID() then
			self:Receive(sData)
		end
	elseif iEventType == enum.TcpEvent.Exception then
		g_LoginCtrl:HideLoginTips()
		self:Disconnect()
		local bAutoConnect = (not self.m_HasAutoReconnect) and self:AutoReconnect()
		if not bAutoConnect then
			self:CheckShowLogin()
		end
	end
	self:OnEvent(define.Net.Event_Sockect)
end

function CNetCtrl.CheckShowLogin(self)
	if not CLoginView:GetView() then
		local args ={
			title = "连接失败",
			msg = "服务器已断开",
			okCallback = function() g_LoginCtrl:Logout() end,
			okStr = "确定",
			forceConfirm = true,
			hideCancel = true
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	end
end

function CNetCtrl.ReconnectConfirm(self)
	g_LoginCtrl:HideLoginTips()
	local args ={
		title = "网络断开",
		msg = "已断开游戏服务器，需要重新连接",
		okCallback = function() g_LoginCtrl:Reconnect() end,
		okStr = "重连",
		cancelCallback = function() g_LoginCtrl:Logout() end,
		forceConfirm = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CNetCtrl.AutoReconnect(self)
	print("CNetCtrl.AutoReconnect开始重连")
	self.m_ProtoHanlder:Clear()
	if g_LoginCtrl:HasLoginInfo() or g_LoginCtrl:HasReconnectInfo() then
		g_LoginCtrl:Reconnect()
		self.m_HasAutoReconnect = true
		return true
	end
end

--大包协议
function CNetCtrl.ReceiveBigPacket(self, type, total, index, data)
	local dPacket = self.m_BigPackets[type] 
	if not dPacket then
		dPacket = {}
	end
	dPacket[index] = data
	
	local bComplete = true
	for i=1, total do
		if not dPacket[i] then
			bComplete = false
			break
		end
	end
	if bComplete then
		local sMergeData = table.concat(dPacket, "")
		self:ProtoHandlerCheck(type, sMergeData)
		self.m_BigPackets[type] = nil
	else
		self.m_BigPackets[type] = dPacket
	end
end

function CNetCtrl.ProtoHandlerCheck(self, iPbType, sData)
	if self.m_ProtoHanlder:IsPriorType(iPbType) or (self.m_ProtoHanlder:IsCanProcess() and self.m_ProtoHanlder:IsEmpty()) then
		self:ProcessProto(iPbType, sData)
	else
		self.m_ProtoHanlder:PushProto(iPbType, sData)
	end
end

function CNetCtrl.Receive(self, sData)
	self.m_CurProtoData = sData
	local iPbType = IOTools.ReadNumber(sData, 2) 
	self:ProcessRecord(iPbType, sData)
	sData = string.sub(sData, 3)
	self:ProtoHandlerCheck(iPbType, sData)
end

function CNetCtrl.ProcessRecord(self, iPbType, sData)
	if not self.m_RecordType then
		return
	end
	local dRecordInfo = data.netdata.RECORD[self.m_RecordType]
	local typeInfo = netdefines.GS2C[iPbType]
	if typeInfo then
		local sMainType, sSubType= unpack(typeInfo)
		local dSubInfo = dRecordInfo[sMainType]
		if dSubInfo then
			if dSubInfo.all_flag or dSubInfo[sSubType] then
				table.insert(self.m_Records, sData)
				return
			end
		end
	end
end

function CNetCtrl.ProcessProto(self, iPbType, sData)
	local typeInfo = netdefines.GS2C[iPbType]
	if typeInfo then
		local sMainType, sSubType= unpack(typeInfo, 1, 2)
		local pbdata, errormsg = protobuf.decode(sSubType, sData)
		if pbdata then
			if self:IsBanProto(sMainType, sSubType) then
				print("屏蔽协议", sMainType, sSubType)
				return
			end
			if self:CheckCacheProto(sMainType, sSubType, pbdata) then
				return
			end
			if not self:IsBanPrint(sMainType, sSubType) then
				table.print(pbdata, "-->Net Receive: "..sMainType.."."..sSubType)
			end
			local oWatch = g_TimeCtrl:StartWatch()
			self:ProtoCall(sMainType, sSubType, pbdata)
			local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
			self.m_ProtoHanlder:CostTime(iElapsedMS)
		else
			editor.error(string.format("pbtype:%s, maintype:%s, errmsg:%s", iPbType, sMainType, errormsg))
		end
	else
		editor.error("netdefines GS2C undefined", iPbType)
	end

end

function CNetCtrl.ProtoCall(self, sMainType, sSubType, pbdata)
	local s = "net"..sMainType
	local m = getgloalvar(s)
	if m then
		local func = m[sSubType]
		if func then
			xxpcall(func, pbdata)
		else
			editor.error("CNetCtrl.ProtoCall func err:", sSubType)
		end
	else
		editor.error("CNetCtrl.ProtoCall module err:", s)
	end
end

--缓存协议
function CNetCtrl.SetCacheProto(self, sBanType, bCached)
	local dBan = data.netdata.BAN.proto[sBanType]
	for sMainType, v in pairs(dBan) do
		if type(v) == "table" then
			if not self.m_IsNeedCache[sMainType] then
				self.m_IsNeedCache[sMainType] = {}
			end
			for sSubType, _ in pairs(v) do
				local list = self.m_IsNeedCache[sMainType][sSubType] or {}
				local idx = table.index(list, sBanType)
				if bCached then
					if not idx then
						table.insert(list, sBanType)
					end
				else
					if idx then
						table.remove(list, idx)
					end
				end
				self.m_IsNeedCache[sMainType][sSubType] = list
			end
		end
	end
end

function CNetCtrl.ClearCacheProto(self, sBanType, bCall)
	local list = self.m_ProtoCache[sBanType]
	if not list then
		return
	end
	table.print(list, string.format("%s 执行缓存协议:%d %s", sBanType, #list, tostring(bCall)))
	if bCall then
		for i, one in ipairs(list) do
			self:ProtoCall(unpack(one, 1, 3))
		end
	end
	self.m_ProtoCache[sBanType] = nil
end

function CNetCtrl.CheckCacheProto(self, sMainType, sSubType, pbdata)
	if self.m_IsNeedCache[sMainType] then
		local list = self.m_IsNeedCache[sMainType][sSubType]
		if list and #list > 0 then
			print("缓存协议", sMainType, sSubType)
			for _, sBanType in pairs(list) do
				local caches = self.m_ProtoCache[sBanType] or {}
				table.insert(caches, {sMainType, sSubType, pbdata})
				self.m_ProtoCache[sBanType] = caches
			end
			return true
		end
	end
	return false
end

function CNetCtrl.Send(self, sMainType, sSubType, t)
	if not self.m_MainNetObj then
		return
	end
	
	if table.index(data.netdata.SESSIONLIST, sSubType) then
		if not self:IsValidSession(netdefines.C2GS_BY_NAME[sSubType]) then
			return
		end
	end
	
	local iPbType = netdefines.C2GS_BY_NAME[sSubType]
	if not iPbType then
		printerror("netdefines没有找到"..sSubType)
		return
	end
	self:Check(sMainType, sSubType, t)
	if not self:IsBanPrint(sMainType, sSubType) then
		table.print(t, "<--Net Send: "..sMainType.."."..sSubType)
	end
	local sPbType = string.char(math.floor(iPbType/256))..string.char((iPbType%256))
	local sEncode = protobuf.encode(sSubType, t)
	
	if #sEncode > self.m_MaxPacketSize then
		self:SendBigPacket(iPbType, sEncode)
	else
		local sData = sPbType..sEncode
		self.m_ProtoHanlder:PushSendData(sData)
	end
end

function CNetCtrl.Check(self, sMainType, sSubType, t)
	if sMainType == "other" and sSubType == "C2GSCallback" then
		if t and t.sessionidx then
			t.sessionidx = tostring(t.sessionidx)
		elseif t and t.sessionidx == nil then
			printerror("C2GSCallback sessionidx 不能为空")
			return
		end
	end
end

function CNetCtrl.SendBigPacket(self, iType, sEncode)
	local iMax = self.m_MaxPacketSize
	local iPbType = netdefines.C2GS_BY_NAME["C2GSBigPacket"]
	local sPbType = string.char(math.floor(iPbType/256))..string.char((iPbType%256))
	local iLen = math.ceil(#sEncode / iMax)
	for i=1, iLen do
		local sSubData = string.sub(sEncode, (i-1)*iMax+1, i*iMax)
		local t = {type=iType,total=iLen,index=i,data=sSubData}
		local sEncode = protobuf.encode("C2GSBigPacket", t)
		local sData = sPbType..sEncode
		self.m_MainNetObj:Send(sData)
	end
end

function CNetCtrl.IsBanProto(self, sMainType, sSubType)
	local dBan = data.netdata.BAN.proto[sMainType]
	if dBan and dBan.func() and dBan[sSubType] then
		return true
	end
	return false
end

function CNetCtrl.IsBanPrint(self, sMainType, sSubType)
	if not Utils.g_IsLog then
		return true
	end
	local dBan = data.netdata.BAN.print[sMainType]
	if dBan and dBan[sSubType] then
		return true
	end
	return false
end

function CNetCtrl.DecodeMaskData(self, dOri, sType)
	local dRet = {}
	local lKey = data.netdata.PBKEYS[sType]
	if lKey then
		local lShiftOp = MathBit.lShiftOp
		local andOp = MathBit.andOp
		local sMask = dOri.mask
		if sMask then
			local iTotalLen = string.len(sMask)
			local iIdx = iTotalLen
			local andOP = MathBit.andOP
			local lShiftOp = MathBit.lShiftOp
			while iIdx > 0 do
				local iSubLen = math.min(iIdx, 4)
				local iSubMask = tonumber("0x"..string.sub(sMask, iIdx - iSubLen, iIdx))
				local right = 1
				local iBitLen = lShiftOp(iSubLen, 2)
				local iBitStartIdx = lShiftOp((iTotalLen-iIdx), 2) - 1
				for i=1, iBitLen do
					local iBitIdx = iBitStartIdx + i
					if iBitIdx > 0 and andOp(iSubMask, right) > 0 then
						local sKey = lKey[iBitIdx]
						if sKey then
							dRet[sKey] = dOri[sKey]
						else
							printerror("DecodeMask err!", sType, sMask, iBitIdx)
							break
						end
					end
					right = lShiftOp(right, 1)
				end
				iIdx = iIdx - iSubLen
			end
			table.print(dRet, "CNetCtrl解析mask: "..sType)
			return dRet
		end
	end
	return dOri
end

function CNetCtrl.Update(self)
	self.m_ProtoHanlder:ProcessSendList(self.m_MainNetObj)
	local oHandler = self.m_ProtoHanlder 
	if not oHandler:IsEmpty() then
		while oHandler:IsCanProcess() do
			local iPbType, sData = oHandler:PopProto()
			if iPbType and sData then
				self:ProcessProto(iPbType, sData)
			else
				return
			end
		end
	end
end

function CNetCtrl.ResetReceiveRecord(self)
	self.m_RecordList = nil
	self.m_CurRecordIdx = 1
	self.m_RecordData = nil
	self.m_ReceiveRecordInitCnt = nil
end


--协议录像 start
function CNetCtrl.SetRecordType(self, sType)
	if self.m_RecordType == sType then
		return
	end
	if sType then
		self.m_Records = {self.m_CurProtoData}
	else
		self.m_Records = {}
	end
	self.m_RecordType = sType
end

function CNetCtrl.IsRecord(self)
	return self.m_RecordType ~= nil
end

function CNetCtrl.GetRecordFilePath(self, sKey)
	return IOTools.GetPersistentDataPath("/netrecord/"..sKey)
end

function CNetCtrl.SaveRecordsToLocal(self, sKey, dData)
	print("保存"..sKey, #self.m_Records, g_AttrCtrl.pid)
	local path = self:GetRecordFilePath(sKey)
	dData.record_pid = g_AttrCtrl.pid
	local dSave = {records=self.m_Records, data=dData}
	IOTools.SaveJsonFile(path, dSave)
	return path
end

function CNetCtrl.LoadRecordsFromLocal(self, sKey)
	local path
	if string.find(sKey, "/") then
		path = sKey
	else
		path = self:GetRecordFilePath(sKey)
	end
	return IOTools.LoadJsonFile(path)
end

function CNetCtrl.PlayRecord(self, sKey)
	local dData = self:LoadRecordsFromLocal(sKey)
	if dData and #dData.records > 0 then
		print("播放录像:", sKey,"长度:",#dData.records, "录像者id:",dData.record_pid)
		self.m_RecordData = dData.data or {}
		for i, v in ipairs(dData.records) do
			-- print("协议编号: ", i)
			self:Receive(v)
		end
	else
		print("录像为空:", sKey)
	end
end

function CNetCtrl.GetRecordValue(self, sKey)
	if self.m_RecordData then
		return self.m_RecordData[sKey]
	end
end

function CNetCtrl.GetRecordData(self)
	return self.m_RecordData
end

function CNetCtrl.IsProtoRocord(self)
	return self.m_RecordData ~= nil
end

function CNetCtrl.SaveRecordsToServer(self, sKey, dData)
	local path = self:SaveRecordsToLocal(sKey, dData)
	g_QiniuCtrl:UploadFile(sKey, path, enum.QiniuType.None, callback(self, "OnUploadResult", path))
end

function CNetCtrl.OnUploadResult(self, path, key, sucess)
	if sucess then
		g_NotifyCtrl:FloatMsg("上传成功")
	else
		g_NotifyCtrl:FloatMsg("上传失败")
	end
	IOTools.Delete(path)
end

function CNetCtrl.GetRecordsFromServer(self, sKey)

end

function CNetCtrl.CutRecord(self, dRecord, iStart, iEnd)
	local dNew = {data=dRecord.dData}
	local lRecords = {}
	for i, v in ipairs(dRecord.records) do
		if i < iStart or i > iEnd then
			table.insert(lRecords, v)
		end
	end
	dNew["records"] = lRecords
	IOTools.SaveJsonFile(self:GetRecordFilePath("剪切后录像"), dNew)
end

--协议录像 end
return CNetCtrl