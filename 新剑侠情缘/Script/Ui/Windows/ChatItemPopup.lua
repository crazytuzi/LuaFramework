local tbUi = Ui:CreateClass("ChatItemPopup");

function tbUi:OnOpen(nSenderId, szMsg)
	self.nSenderId = nSenderId;
	self.szMsg = szMsg;
end

function tbUi:OnScreenClick()
	Ui:CloseWindow("ChatItemPopup");
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnCopy()
	if self.szMsg then
		Ui.ToolFunction.CopyText(self.szMsg);
	end
	Ui:CloseWindow("ChatItemPopup");
end

function tbUi.tbOnClick:BtnBlock()
	FriendShip:BlackHim(self.nSenderId);
	Ui:CloseWindow("ChatItemPopup");
end

