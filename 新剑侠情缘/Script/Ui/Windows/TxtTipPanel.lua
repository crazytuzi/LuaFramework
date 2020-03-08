
local tbUi = Ui:CreateClass("TxtTipPanel");

function tbUi:OnOpen(szTips)
	self.pPanel:Label_SetText("Txt", szTips);

	if self.nCloseTimerId then
		Timer:Close(self.nCloseTimerId);
		self.nCloseTimerId = nil;
	end
	self.nCloseTimerId = Timer:Register(Env.GAME_FPS * 6, function (self)
		self.nCloseTimerId = nil;
		Ui:CloseWindow(self.UI_NAME);
	end, self)
end

function tbUi:OnClose(szTips)
	if self.nCloseTimerId then
		Timer:Close(self.nCloseTimerId);
		self.nCloseTimerId = nil;
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end