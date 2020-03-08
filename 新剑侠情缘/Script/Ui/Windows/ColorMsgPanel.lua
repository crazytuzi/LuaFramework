local tbUi = Ui:CreateClass("ColorMsgPanel");


function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_UPDATE_COLORMSG_COUNT, self.Update, self},
		{ UiNotify.emNOTIFY_WND_CLOSED, self.OnCloseEmotionLink, self},
		{ UiNotify.emNOTIFY_WND_OPENED, self.OnOpenShop, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	local nOpenLevel = ChatMgr:GetOpenLevel(ChatMgr.ChannelType.Color);
	if me.nLevel < nOpenLevel then
		me.CenterMsg(string.format("%d级后开放彩聊频道发言", nOpenLevel));
		return 0;
	end

	self:InitBtnVoiceInput();
	self:Update();
	self.pPanel:UIInput_SetCharLimit("InputField", ChatMgr.nMaxMsgLengh);
	local szDefaultTips = string.format("在此输入文字(%d)", ChatMgr.nMaxMsgLengh);
	self.pPanel:Input_SetDefaultText("InputField", szDefaultTips);
end

function tbUi:InitBtnVoiceInput()
	local fnCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime)
		szMsg = ChatMgr:CutMsg(szMsg);
		local bSucceed = false
		bSucceed = ChatMgr:SendMsg(ChatMgr.ChannelType.Color, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime);
		if bSucceed then
			me.CenterMsg("发送成功..");
			Ui:CloseWindow("ChatEmotionLink");
			Ui:CloseWindow(self.UI_NAME);
		end
	end

	local fnCheckVoiceSend = function ()
		return ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Color, "check", true);
	end

	local nVoiceTime = ChatMgr:GetMaxVoiceTime(ChatMgr.ChannelType.Color);
	self.pPanel:FlyCom_Init("BtnVoice", fnCallback, fnCheckVoiceSend, nVoiceTime);
end

function tbUi:OnClose()
	if self.pPanel:IsActive("BtnVoice") then
		local wndVoice = self.pPanel:FindChildTransform("BtnVoice");
		if wndVoice then
			local iflyCom = wndVoice:GetComponent("IFlyCom");
			if iflyCom then
				iflyCom:SendMessage("OnPress", false);
			end
		end
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:Update()
	local nColorTimes = me.GetUserValue(ChatMgr.COLOR_MSG_USER_VALUE_GROUP, ChatMgr.COLOR_MSG_USER_VALUE_KEY);
	self.pPanel:Label_SetText("TxtColorMsgCount", nColorTimes);
end

function tbUi:OnCloseEmotionLink(szWndName)
	if szWndName == "ChatEmotionLink" then
		self.pPanel:ChangePosition("Main", 175, 0);
	end
end

function tbUi:OnOpenShop(szWndName)
	if szWndName == "CommonShop" then
		Ui:CloseWindow(self.UI_NAME);
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("ChatEmotionLink");
	Ui:CloseWindow("ColorMsgPanel");
end

function tbUi.tbOnClick:BtnSend()
	local szMsg = self.pPanel:Input_GetText("InputField") or "";

	local bSucceed = ChatMgr:SendMsg(ChatMgr.ChannelType.Color, szMsg);
	if bSucceed then
		self.pPanel:Input_SetText("InputField", "");
		me.CenterMsg("发送成功..");
		Ui:CloseWindow("ChatEmotionLink");
		Ui:CloseWindow("ColorMsgPanel");
	end
end

function tbUi.tbOnClick:BtnEmotionLink()
	if Ui:WindowVisible("ChatEmotionLink") == 1 then
		Ui:CloseWindow("ChatEmotionLink");
	else
		self.pPanel:ChangePosition("Main", 175, 140);
		Ui:OpenWindow("ChatEmotionLink", self, nil, true);
	end
end

function tbUi.tbOnClick:BtnBuy()
	Ui:OpenWindow("CommonShop","Treasure", "tabAllShop", ChatMgr.nSpeakerColorItemId);
end
