
local tbReadyGo = Ui:CreateClass("ReadyGo");

function tbReadyGo:OnOpen()
	self.nTimer = Timer:Register(Env.GAME_FPS * 4, self.OnTimer, self)
end

function tbReadyGo:OnTimer()
	self.nTimer = nil;
	Ui:CloseWindow(self.UI_NAME);
end

function tbReadyGo:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

