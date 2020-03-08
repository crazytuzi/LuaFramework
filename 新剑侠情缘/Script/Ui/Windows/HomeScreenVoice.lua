local tbUi = Ui:CreateClass("HomeScreenVoice");
function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CHAT_ROOM_STATUS, self.OnChatRoomStatusChange, self },
		{ UiNotify.emNOTIFY_ON_HOME_TASK_FOLD, self.OnFold, self },
	};

	return tbRegEvent;
end

function tbUi:OnOpenEnd()
	self:UpdateChatRoomStatus();
end

function tbUi:OnChatRoomStatusChange(isAvailable, isMicAvailable, isSpeakerAvailable)
	self:UpdateChatRoomStatus()
end

function tbUi:UpdateChatRoomStatus()
	local isAvailable = ChatMgr.ChatRoom.isEnterRoom;
	if isAvailable then
		self.pPanel:SetActive("BtnEarphone", true);
		self.pPanel:SetActive("BtnMicrophone", true);
		self.pPanel:Toggle_SetChecked("BtnEarphone", not ChatMgr.ChatRoom.bSpeakerState);
		self.pPanel:Toggle_SetChecked("BtnMicrophone", not ChatMgr.ChatRoom.bMicState);
		local isMicAvailable, isTmpDisable = ChatMgr:IsCanUseRoomMic();
		if not isMicAvailable then
			self.pPanel:SetActive("BtnMicrophone", false);
		end
	else
		self.pPanel:SetActive("BtnEarphone", false);
		self.pPanel:SetActive("BtnMicrophone", false);
	end
end

function tbUi:OnFold(bFold)
	local szAni = bFold and "HomeScreenVoiceRetract" or "HomeScreenVoiceStretch";
	self.pPanel:PlayUiAnimation(szAni, false, false, {});
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnEarphone = function (self)
	local isSpeakerAvailable = ChatMgr:IsCanUseRoomSpeaker();
	if not isSpeakerAvailable then
		self.pPanel:Toggle_SetChecked("BtnEarphone", true);
		return
	end

	local bChecked = self.pPanel:Toggle_GetChecked("BtnEarphone");

	if bChecked then
		ChatMgr:CloseChatRoomSpeaker();
	else
		ChatMgr:OpenChatRoomSpeaker();
	end
end

tbUi.tbOnClick.BtnMicrophone = function (self)
	local isMicAvailable, isTmpDisable = ChatMgr:IsCanUseRoomMic();

	if isTmpDisable then
		self.pPanel:Toggle_SetChecked("BtnMicrophone", true);
		me.CenterMsg("抱歉，当前系统版本不兼容，暂时不能使用！")
		return
	end

	if not isMicAvailable then
		self.pPanel:Toggle_SetChecked("BtnMicrophone", true);
		me.CenterMsg("你没有发言权限");
		return
	end

	local bChecked = self.pPanel:Toggle_GetChecked("BtnMicrophone");

	if bChecked then
		ChatMgr:CloseChatRoomMic();
	else
		ChatMgr:OpenChatRoomMic();
	end
end
