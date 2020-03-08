
local tbUi = Ui:CreateClass("TaskNotice");
tbUi.tbTaskMsg = 
{
	[3302] = "点击头像打开角色信息界面，再点击[FFFE0D]空间[-]";
	[3303] = "选中目标，点击对方头像后选择[FFFE0D]玩家空间[-]";
	[3304] = "点击主界面中的[FFFE0D]江湖广场[-]";
}
tbUi.nMaxTime = 5;

function tbUi:OnOpen(szMsg, nTaskId)
	self.nMsgId = (self.nMsgId or 0) + 1;
	self.pPanel:Label_SetText("Msg", "");
	if self.nTimer then
		Timer:Close(self.nTimer)
		self.nTimer = nil;
	end

	self.pPanel:Label_SetText("Msg", self.tbTaskMsg[nTaskId] or szMsg);
	self.nTimer = Timer:Register(self.nMaxTime * Env.GAME_FPS, self.CloseMsg, self, self.nMsgId);
end

function tbUi:OnClose()
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