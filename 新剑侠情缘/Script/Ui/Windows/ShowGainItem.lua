

local tbUi = Ui:CreateClass("ShowGainItem");

function tbUi:OnOpen(nItemTemplateId, nCount)
	self.pPanel:Tween_Play("Box", 0);
	self.pPanel:Tween_Play("itemframe", 0);
	self.itemframe:SetItemByTemplate(nItemTemplateId, nCount or 0, me.nFaction);
	self.itemframe.fnClick = self.itemframe.DefaultClick;

	if self.nCloseTimerId then
		Timer:Close(self.nCloseTimerId);
		self.nCloseTimerId = nil;
	end

	self.nCloseTimerId = Timer:Register(Env.GAME_FPS * 5, function ()
		self.nCloseTimerId = nil;
		Ui:CloseWindow("ShowGainItem");
	end)
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	if self.nCloseTimerId then
		Timer:Close(self.nCloseTimerId);
		self.nCloseTimerId = nil;
	end
end