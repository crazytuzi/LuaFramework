local tbUi = Ui:CreateClass("PrisonRemainTimePanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_MAP_LEAVE, self.Close, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpenEnd()
	self.pPanel:Label_SetText("RemainTime", "");
	self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.Update, self);
end

function tbUi:Update()
	if not me.CanPushPrison() then
		self.pPanel:Label_SetText("RemainTime", "00:00:00");
		me.SendBlackBoardMsg("天罚期限已到，您可与万金财对话离开此地");
		return true;
	end
	local nLeftTime = me.GetPrisonLeftTime();
	local szDesc = Lib:TimeDesc3(nLeftTime);
	self.pPanel:Label_SetText("RemainTime", szDesc);
	return true;
end

function tbUi:OnClose()
	if self.nUpdateTimer then
		Timer:Close(self.nUpdateTimer);
		self.nUpdateTimer = nil;
	end
end

function tbUi:Close()
	Ui:CloseWindow(self.UI_NAME);
end