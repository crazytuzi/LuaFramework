
local tbUi = Ui:CreateClass("SpecialTips");

function tbUi:OnOpen(szTxt)
	self.pPanel:Label_SetText("NegativeInformation", szTxt)
	self.nTimer = Timer:Register(Env.GAME_FPS * 10, self.OnTimer, self)
end

function tbUi:OnOpenEnd( )
	for i=1,9 do
		self.pPanel:Tween_Play(tostring(i))
	end
end

function tbUi:OnTimer()
	self.nTimer = nil;
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
end

