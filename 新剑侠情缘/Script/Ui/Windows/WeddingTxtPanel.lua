
local tbUi = Ui:CreateClass("WeddingTxtPanel");

tbUi.nMaxTime = 5;

function tbUi:OnOpen(szMsg)
	self.nMsgId = (self.nMsgId or 0) + 1;
	self.pPanel:Label_SetText("Txt", "");
	self:CloseTimer()
	
	self.pPanel:Label_SetText("Txt", szMsg);
	self.pPanel:SetActive("Texiao", true)
	self.nTimer = Timer:Register(self.nMaxTime * Env.GAME_FPS, self.CloseMsg, self, self.nMsgId);
end

function tbUi:OnClose()
	self:CloseTimer()
end

function tbUi:CloseTimer()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

function tbUi:CloseMsg(nMsgId)
	if self.nMsgId ~= nMsgId then
		return;
	end
	
	self.nTimer = nil
	Ui:CloseWindow(self.UI_NAME);
end