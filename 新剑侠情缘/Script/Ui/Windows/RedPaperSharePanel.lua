local tbUi = Ui:CreateClass("RedPaperSharePanel");

function tbUi:OnOpen(szUrl)
	self.szUrl = szUrl;

	local bQQ = Sdk:IsLoginByQQ();
	self.pPanel:SetActive("BtnShareQQ", bQQ);
	self.pPanel:SetActive("Box", bQQ);
	self.pPanel:SetActive("BtnShareFriend", not bQQ);
	self.pPanel:SetActive("BtnShareFriendCircle", not bQQ);
	self.pPanel:SetActive("RedPaper", not bQQ);
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:RedPaper()
end

function tbUi.tbOnClick:BtnShareFriend()
	Ui:CloseWindow(self.UI_NAME);
	Sdk:TlogShare("Luckybag");
	Sdk:ShareUrl("WXSe", "收到一个红包", "《剑侠情缘》送您元宝一份，快打开看看吧！", "MSG_heart_send", self.szUrl);
end

function tbUi.tbOnClick:BtnShareFriendCircle()
	Ui:CloseWindow(self.UI_NAME);
	Sdk:TlogShare("Luckybag");
	Sdk:ShareUrl("WXMo", "收到一个红包", "《剑侠情缘》送您元宝一份，快打开看看吧！", "MSG_heart_send", self.szUrl);
end

function tbUi.tbOnClick:BtnShareQQ()
	Ui:CloseWindow(self.UI_NAME);
	Sdk:TlogShare("Luckybag");
	Sdk:ShareUrl("QQ", "收到一个元宝宝箱", "《剑侠情缘》送您元宝一份，快打开看看吧！", "MSG_heart_send", self.szUrl);
end