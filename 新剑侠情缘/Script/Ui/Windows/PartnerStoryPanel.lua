local tbUi = Ui:CreateClass("PartnerStoryPanel");

function tbUi:OnOpen(szStory)
	self.pPanel:Label_SetText("Story", szStory);
end

function tbUi:OnClose()
	self.pPanel:Label_SetText("Story", "");
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end
