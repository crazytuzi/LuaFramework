
FileServer.tbOpAfterConnect = FileServer.tbOpAfterConnect or {};
FileServer.tbOpReceiveFile = FileServer.tbOpReceiveFile or {};
FileServer.tbWaitingSendRespond = FileServer.tbWaitingSendRespond or {};
FileServer.szServerIp = "127.0.0.1";
FileServer.nServerPort = 5007;
FileServer.nSendFailedWatingTime = 3; -- 发送到服务器若3秒内不成功则视为失败
FileServer.nReceiveFailedWatingTime = 15; -- 下载文件超时时间

function FileServer:SetInfo(szIP, nPort)
	self.szServerIp = szIP;
	self.nServerPort = nPort;
end

function FileServer:OnConnect(nConnected)
	print("链接文件服务器:", nConnected);

	self.bConnecting = false

	for idx = #self.tbOpAfterConnect, 1, -1 do
		local tbSwitchInfo = self.tbOpAfterConnect[idx]
		local szFileServerIp, nFileServerPort = self:GetServerIp(tbSwitchInfo.bZone)
		if self.szCurConnectIp == szFileServerIp then
			tbSwitchInfo.fnCallBack(nConnected == 1);
			table.remove(self.tbOpAfterConnect, idx)
		end
	end

end

function FileServer:IsConnected()
	return KFileServer.IsConnected();
end

function FileServer:GetServerIp(bZone)
	local szFileServerIp = Login:GetFileServerFreeIp() or self.szServerIp;
	local nFileServerPort = self.nServerPort
	if bZone then
		szFileServerIp = self.szZoneFileIp or szFileServerIp
		nFileServerPort = self.nZoneFilePort or nFileServerPort
	end

	return szFileServerIp, nFileServerPort
end

function FileServer:ConnectServer(bZone)
	local szFileServerIp, nFileServerPort = self:GetServerIp(bZone)

	Log("FileServer:ConnectServer:", tostring(bZone), szFileServerIp, ":", nFileServerPort);
	KFileServer.ConnectFileServer(szFileServerIp, nFileServerPort);

	self.bConnecting = true
	self.szCurConnectIp = szFileServerIp
	self:ClearWaitingData()

	if not self.nCheckConnectTimer then
		self.nCheckConnectTimer = Timer:Register(Env.GAME_FPS, function ()
							
							if not Lib:IsEmptyTB(self.tbOpAfterConnect) and not self.bConnecting then
								local tbInfo = self.tbOpAfterConnect[1]
								local szIp, nPort = self:GetServerIp(tbInfo.bZone)

								if self:IsCanConnectToServer(szIp) or not self:IsConnected() then
									FileServer:ConnectServer(tbInfo.bZone)
								end
							end

							return true;
						end);
	end
end

function FileServer:CreateFileId()
	return KFileServer.CreateFileId()
end

function FileServer:SendVoiceFile(fileIdHigh, fileIdLow, szData, fnCallBack, bZone)
	self:CallWithConnected(bZone, function (bConnected)
		local bRet = false;
		if bConnected then
			bRet = KFileServer.SendVoiceFile(szData, fileIdHigh, fileIdLow);
		end

		if not fnCallBack then
			return;
		end

		local fnAfterSent = function (bResult)
			fnCallBack(bResult, {nRoleId = fileIdHigh, nMixFlag = fileIdLow});
		end

		if not bRet then
			fnAfterSent(false);
		else
			local nFileFlag = KFileServer.GetFileId(fileIdHigh, fileIdLow);
			FileServer:WaitingSendRespond(nFileFlag, fnAfterSent)
		end
	end);
end

function FileServer:WaitingSendRespond(nFileFlag, fnAfterSent)
	self.tbWaitingSendRespond[nFileFlag] = fnAfterSent;
	Timer:Register(Env.GAME_FPS * self.nSendFailedWatingTime, function ()
		if self.tbWaitingSendRespond[nFileFlag] then
			self.tbWaitingSendRespond[nFileFlag](false);
			self.tbWaitingSendRespond[nFileFlag] = nil;
		end
	end);
end

function FileServer:WaitingReceiveRespond(nFileFlag, fnCallBack)
	self.tbOpReceiveFile[nFileFlag] = fnCallBack;
	Timer:Register(Env.GAME_FPS * self.nReceiveFailedWatingTime, function ()
		if self.tbOpReceiveFile[nFileFlag] then
			self.tbOpReceiveFile[nFileFlag] = nil;
		end
	end);
end

function FileServer:OnVoiceFileSent(nFileFlag)
	if self.tbWaitingSendRespond[nFileFlag] then
		self.tbWaitingSendRespond[nFileFlag](true);
		self.tbWaitingSendRespond[nFileFlag] = nil;
	end
end

function FileServer:AskVoiceFile(tbFileId, fnCallBack, bZone)
	self:CallWithConnected(bZone, function (bConnected)
		if bConnected then
			local nFileFlag = KFileServer.AskVoiceFile(tbFileId.nRoleId, tbFileId.nMixFlag);
			if fnCallBack then
				self:WaitingReceiveRespond(nFileFlag, fnCallBack)
			end
		end
	end);
end

function FileServer:CallWithConnected(bZone, fnCallBack)
	local szFileServerIp, nFileServerPort = self:GetServerIp(bZone)
	local bCache = false

	if not FileServer:IsConnected() or self.bConnecting or szFileServerIp ~= self.szCurConnectIp then
		bCache = true
		table.insert(self.tbOpAfterConnect, {bZone = bZone, fnCallBack = fnCallBack})
		Log("CallWithConnected  Wait For Connected", tostring(bZone), tostring(self.szCurConnectIp), tostring(szFileServerIp))
	end

	if not FileServer:IsConnected() or (szFileServerIp ~= self.szCurConnectIp and self:IsCanConnectToServer(szFileServerIp))  then
		if not self.bConnecting then
			FileServer:ConnectServer(bZone);
		end
	elseif not bCache then
		fnCallBack(true);
	end
end

function FileServer:OnFileReceived(nFileFlag, ...)
	if self.tbOpReceiveFile[nFileFlag] then
		self.tbOpReceiveFile[nFileFlag](...);
		self.tbOpReceiveFile[nFileFlag] = nil;
	end
end

function FileServer:SendClientLog(szFilePath)
	self:CallWithConnected(false, function (bConnected)
		local bRet = false;
		if bConnected then
			if szFilePath then
				bRet = KFileServer.SendClientLog(szFilePath);
			else
				bRet = KFileServer.SendClientLog();
			end
		end

		if not fnCallBack then
			return;
		end

		local fnAfterSent = function (bResult)
			fnCallBack(bResult, {szFilePath});
		end

		if not bRet then
			fnAfterSent(false);
		end
	end);
end

function FileServer:OnClientLogRespond(nHighId, nLowId, szId)
	Log("OnClientLogRespond", nHighId, nLowId, szId)
	if szId ~= "0" then
		Ui:OpenWindow("MessageBox", string.format(XT("成功上报，ID: [ffff00]%s[-]\n请提供此ID给客服加快您问题的处理速度。"), szId),
				{ {} },
		 		{"确定"})
	else
		Ui:OpenWindow("MessageBox", XT("上报失败请稍后再试。"),
				{ {} },
		 		{"确定"})
	end
end

function FileServer:SyncZoneFileServer(szZoneFileIp, nZoneFilePort)
	Log("SyncZoneFileServer", szZoneFileIp, nZoneFilePort)
	self.szZoneFileIp = szZoneFileIp;
	self.nZoneFilePort = nZoneFilePort;
end

function FileServer:ClearWaitingData()
	for nFileFlag,fnCallBack in pairs(self.tbWaitingSendRespond) do
		fnCallBack(false)
	end

	self.tbWaitingSendRespond = {}
end

function FileServer:IsCanConnectToServer(szServerIp)
	if not self.szZoneFileIp then
		return true
	end

	if szServerIp ~= self.szCurConnectIp and self:IsConnected() then
		return Lib:IsEmptyTB(self.tbWaitingSendRespond) and Lib:IsEmptyTB(self.tbOpReceiveFile);
	end

	return true 
end
