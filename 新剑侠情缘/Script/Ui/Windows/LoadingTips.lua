
local tbUi = Ui:CreateClass("LoadingTips");
function tbUi:OnOpen(szTips, nTimeout, fnTimeout)
	self.fnTimeout = fnTimeout;

	if self.nTimeoutTimer then
		Timer:Close(self.nTimeoutTimer);
	end

	szTips = szTips or "连接中..";
	self.pPanel:Label_SetText("Label", szTips);

	nTimeout = nTimeout or 5;
	self.nTimeoutTimer = Timer:Register(Env.GAME_FPS * nTimeout, self.OnTimeout, self);
end

function tbUi:OnTimeout()
	if PlayerEvent.bLogin then
		RemoteServer.DoReconnect();
	end
	self.nTimeoutTimer = nil;

	if self.fnTimeout then
		self.fnTimeout();
	end
end

function tbUi:OnClose()
	if self.nTimeoutTimer then
		Timer:Close(self.nTimeoutTimer);
	end

	self.nTimeoutTimer = nil;
end
