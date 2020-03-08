local tbUi = Ui:CreateClass("WeddingSendPromisePanel");

function tbUi:OnOpen(nTime)
	self.pPanel:Label_SetText("Label", "发送")
	self:CloseTimer()
	if not nTime or nTime <= 0 then
		Wedding:TryDestroyUi(self.UI_NAME)
		return
	end
	self.nWaitTime = nTime
	self.pPanel:Label_SetText("Time", string.format("(%d秒)", self.nWaitTime))
	self.nTimer = Timer:Register(Env.GAME_FPS, self.UpdateTime, self)

	local szTip = "在此输入你的宣言（%d字以下）"
	local nWord = Wedding.nPromiseMax
	if version_vn then
		nWord = Wedding.nVNPromiseMax
	elseif version_th then
		nWord = Wedding.nPromiseMax
	end
	self.pPanel:Label_SetText("TxtTitle", string.format(szTip, nWord + 1))
end

function tbUi:UpdateTime()
	if self.nWaitTime <= 0 then
		self.nTimer = nil
		Wedding:TryDestroyUi(self.UI_NAME)
		return false
	end
	self.nWaitTime = self.nWaitTime - 1
	self.pPanel:Label_SetText("Time", string.format("(%d秒)", self.nWaitTime))
	return true
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:CloseTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil
	end
end

tbUi.tbOnClick = {
	BtnSend = function (self)
		local szPromise = self.TxtTitle:GetText()
		if not szPromise or szPromise == "" then
			me.CenterMsg("请输入你的誓言")
			return 
		end
		if ReplaceLimitWords(szPromise) then
			me.CenterMsg("誓言含有敏感字符，请修改后重试！")
			return 
		end
		RemoteServer.OnWeddingRequest("TrySendPromise", szPromise);
	end;
}
