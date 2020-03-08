
local tbUi = Ui:CreateClass("ScreenRecord");

function tbUi:OnOpen()
	self.nTimer = Timer:Register(Env.GAME_FPS * 1, self.OnTimer, self);
	self.pPanel:Label_SetText("VideoTime", "00:00");
	self.nBeginTime = GetTime();
end

function tbUi:OnClose()
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end
	StopRecordScreen();
end

function tbUi:OnTimer()
	self.pPanel:Label_SetText("VideoTime", Lib:TimeDesc3(GetTime() - self.nBeginTime));
	return true;
end

tbUi.tbOnClick = 
{
	BtnStop = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end
}

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
		--{ UiNotify.emNOTIFY_SYNC_ITEM,			self.OnSyncItem },
	}
	return tbRegEvent;
end
