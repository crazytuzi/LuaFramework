
local tbUi = Ui:CreateClass("PartnerGradeLevelup");

function tbUi:OnOpen(tbShowInfo)
	for i = 1, 4 do
		self.pPanel:Label_SetText("From" .. i, tbShowInfo[i][1]);
		self.pPanel:Label_SetText("To" .. i, tbShowInfo[i][2]);
		self.pPanel:Label_SetText("Add" .. i, string.format("(+%s)", tbShowInfo[i][2] - tbShowInfo[i][1]));
	end

	if self.nCloseTimer then
		Timer:Close(self.nCloseTimer);
		self.nCloseTimer = nil;
	end

	self.nCloseTimer = Timer:Register(Env.GAME_FPS * 20, function (self) self.nCloseTimer = nil; Ui:CloseWindow(self.UI_NAME); end, self);
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	if self.nCloseTimer then
		Timer:Close(self.nCloseTimer);
		self.nCloseTimer = nil;
	end
end
