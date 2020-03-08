local tbInputGroup = Ui:CreateClass("ChatInput");

tbInputGroup.szCacheMsg = tbInputGroup.szCacheMsg or "";

function tbInputGroup:Init(pChatLarge)
	self.pChatLarge = pChatLarge;
	self.bVoice = false;
	self:Update();

	if tbInputGroup.szCacheMsg ~= "" then
		self.pPanel:Input_SetText("InputField", tbInputGroup.szCacheMsg);
	end

	if Sdk:IsPCVersion() then
		self.pPanel:Input_SetReternKeyType("InputField", 2)
		self.pPanel:Input_SetHide("InputField", true)
	end

	self:InitBtnVoiceInput()
end

function tbInputGroup:InitBtnVoiceInput()
	local fnCallback = function (szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		szMsg = ChatMgr:CutMsg(szMsg);
		local bSucceed = false
		local bFriend = self.pChatLarge.nChannelId == ChatMgr.nChannelFriendName
		if bFriend then
			bSucceed = ChatMgr:SendPrivateMessage(self.pChatLarge.nNowChatFriendId, szMsg,uFileIdHigh,uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
		else
			bSucceed = ChatMgr:SendMsg(self.pChatLarge.nChannelId, szMsg, true, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId);
		end
		if bSucceed then
			self:UpdateCdExpression();
			if bFriend then
				self.pChatLarge:UpdateChatList()
			end
		end
	end

	local fnCheckVoiceSend = function ()
		return ChatMgr:CheckSendMsg(self.pChatLarge.nChannelId, "check", true);
	end

	local nVoiceTime = ChatMgr:GetMaxVoiceTime(self.pChatLarge.nChannelId);
	self.pPanel:FlyCom_Init("BtnVoiceInput", fnCallback, fnCheckVoiceSend, nVoiceTime);
end

function tbInputGroup:OnClose()
	if self.nCdTimer then
		Timer:Close(self.nCdTimer);
		self.nCdTimer = nil;
	end

	tbInputGroup.szCacheMsg = self.pPanel:Input_GetText("InputField") or "";

	if self.pPanel:IsActive("VoiceInput") and self.pPanel:IsActive("BtnVoiceInput") then
		local wndVoice = self.pPanel:FindChildTransform("BtnVoiceInput");
		if wndVoice then
			local iflyCom = wndVoice:GetComponent("IFlyCom");
			if iflyCom then
				iflyCom:SendMessage("OnPress", false);
			end
		end
	end

	if Sdk:IsPCVersion() then
		self.pPanel:Input_SetText("InputField", "");
		self:SelectInput(false)
	end
end

function tbInputGroup:OnChangeChannel()
	Ui.EndVoice(nil, true)
	self:Update();
	self:UpdateCdExpression();
	self:InitBtnVoiceInput()
end

function tbInputGroup:UpdateCdExpression()
	if self.nCdTimer then
		Timer:Close(self.nCdTimer);
		self.nCdTimer = nil;
	end

	local nCd = ChatMgr:GetCd(self.pChatLarge.nChannelId);
	local szDefaultTips = string.format("在此输入文字(%d)", ChatMgr.nMaxMsgLengh);
	if nCd <= 0 then
		self.pPanel:Input_SetDefaultText("InputField", szDefaultTips);
		return;
	end

	self.nLeftTime = nCd;
	self.pPanel:Input_SetDefaultText("InputField", string.format("%d秒后可发送消息", self.nLeftTime));
	self.nCdTimer = Timer:Register(Env.GAME_FPS, function ()
		self.nLeftTime = self.nLeftTime - 1;
		if self.nCdTimer and self.nLeftTime > 0 then
			self.pPanel:Input_SetDefaultText("InputField", string.format("%d秒后可发送消息", self.nLeftTime));
			return true;
		else
			self.pPanel:Input_SetDefaultText("InputField", szDefaultTips);
			self.nCdTimer = nil;
			self.nLeftTime = nil;
			return false;
		end
	end);
end

local tbCanInput = {
	[ChatMgr.ChannelType.Public] = true;
	[ChatMgr.ChannelType.Friend] = true;
	[ChatMgr.ChannelType.Kin]    = true;
	[ChatMgr.ChannelType.Nearby] = true;
	[ChatMgr.ChannelType.Team]   = true;
	[ChatMgr.nChannelFriendName] = true;
};

local tbShowBtnType = {
	["TypingInput"] = false,
	["VoiceInput"] = false,
	["MailDown"] = false,
	["UnableInput"] = true,
	["PrivateChat"] = false,
	["JoinFamily"] = false,
	["NotAllowChat"] = false,
	["UninputChat"] = false,
};
function tbInputGroup:ToggleShowButton(szBut)
	for k,v in pairs(tbShowBtnType) do
		if szBut == k then
			tbShowBtnType[k] = true
			self.pPanel:SetActive(k, true)
		else
			tbShowBtnType[k] = false
			self.pPanel:SetActive(k, false)
		end
	end
end

function tbInputGroup:Update()

	local nChannelId = self.pChatLarge.nChannelId;
	local bCanInput = tbCanInput[nChannelId] or false;
	if type(nChannelId) == "number" and nChannelId >= ChatMgr.nDynChannelBegin then
		bCanInput = true;
	end

	if nChannelId == ChatMgr.ChannelType.Kin then
		bCanInput = Kin:HasKin();
	elseif nChannelId == ChatMgr.ChannelType.Nearby then
		bCanInput = Map:CanNearbyChat(me.nMapTemplateId);
	elseif nChannelId == ChatMgr.ChannelType.Team then
		bCanInput = TeamMgr:HasTeam();
	elseif nChannelId == ChatMgr.ChannelType.Cross then
		bCanInput = ChatMgr:HasJoinedCrossChannel();
		self.bVoice = false; -- 主播频道不可发送语音
	elseif nChannelId == ChatMgr.nChannelFriendName then
		bCanInput = self.pChatLarge.nNowChatFriendId > 0
	end

	local nOpenLevel = ChatMgr:GetOpenLevel(nChannelId);
	local bLevelOpen = me.nLevel >= nOpenLevel;
	bCanInput = bCanInput and bLevelOpen;

	if bCanInput then
		if self.bVoice then
			self:ToggleShowButton("VoiceInput")
		else
			self.pPanel:UIInput_SetCharLimit("InputField", ChatMgr.nMaxMsgLengh);
			self:ToggleShowButton("TypingInput")
		end
	else
		if nChannelId == ChatMgr.nChannelMail then
			self:ToggleShowButton("MailDown")
		elseif nChannelId == ChatMgr.ChannelType.Private then
			self:ToggleShowButton("PrivateChat");
		elseif nChannelId == ChatMgr.ChannelType.Kin then
			self:ToggleShowButton("JoinFamily");
		elseif nChannelId == ChatMgr.ChannelType.Team then
			self:ToggleShowButton("NotAllowChat");
			self.pPanel:Label_SetText("TxtNotAllowChatInfo", "当前没有队伍");
		elseif nChannelId == ChatMgr.ChannelType.Nearby then
			self:ToggleShowButton("NotAllowChat");
			if Map:CanNearbyChat(me.nMapTemplateId) then
				local szMsg = string.format("%d级后可发言", nOpenLevel);
				self.pPanel:Label_SetText("TxtNotAllowChatInfo", szMsg);
			else
				self.pPanel:Label_SetText("TxtNotAllowChatInfo", "当前场景不允许使用附近频道");
			end
		elseif not bLevelOpen then
			self:ToggleShowButton("NotAllowChat");
			local szMsg = string.format("%d级后可发言", nOpenLevel);
			self.pPanel:Label_SetText("TxtNotAllowChatInfo", szMsg);
		elseif nChannelId == ChatMgr.ChannelType.Cross then
			self:ToggleShowButton("NotAllowChat");
			self.pPanel:Label_SetText("TxtNotAllowChatInfo", "收听主播频道后可发言");
		elseif nChannelId == ChatMgr.nChannelFriendName then
			self:ToggleShowButton("UninputChat");
		else
			self:ToggleShowButton("UnableInput");
		end
	end
end

function tbInputGroup:SelectInput(bSelected)
	self.pPanel:Input_Select("InputField", bSelected)
	if bSelected then
		local wndInput = self.pPanel:FindChildTransform("InputField");
		if wndInput then
			local cmpInput = wndInput:GetComponent("UIInput");
			if cmpInput then
				cmpInput.isSelected = true
			end
		end
	end
end

tbInputGroup.tbOnClick = tbInputGroup.tbOnClick or {};

function tbInputGroup.tbOnClick:BtnSend()
	-- 检查主题是否过期
	Lib:CallBack({ChatMgr.ChatDecorate.TryCheckValid,ChatMgr.ChatDecorate});

	local szMsg = self.pPanel:Input_GetText("InputField") or "";
	local nIndex = string.find(szMsg, "woshikamo");
	if nIndex then
		if szMsg == "woshikamo" then
			Ui.FTDebug.bShowDebugUI = true;
		end

		return;
	end

	local bSucceed = false
	local bPrivate = self.pChatLarge.nChannelId == ChatMgr.nChannelFriendName
	if bPrivate then
		bSucceed = ChatMgr:SendPrivateMessage(self.pChatLarge.nNowChatFriendId, szMsg)
	else
		bSucceed = ChatMgr:SendMsg(self.pChatLarge.nChannelId, szMsg);
	end
	if bSucceed then
		self.pPanel:Input_SetText("InputField", "");
		self:UpdateCdExpression();
		Ui:CloseWindow("ChatEmotionLink");
		if bPrivate then
			self.pChatLarge:UpdateChatList()
		end
	end
end

function tbInputGroup.tbOnClick:BtnAddLink()
	Ui:SwitchWindow("ChatEmotionLink", self);
end

function tbInputGroup.tbOnClick:BtnVoice()
	if self.pChatLarge.nChannelId == ChatMgr.ChannelType.Cross then
		me.CenterMsg("当前频道禁止使用语音");
		return;
	end

	self.bVoice = true;
	self:Update();

	Ui:CloseWindow("ChatEmotionLink");
end

function tbInputGroup.tbOnClick:BtnTyping()
	self.bVoice = false;
	self:Update();
end

function tbInputGroup.tbOnClick:BtnTypeAndLink(tbParam)
	self.bVoice = false;
	self:Update();
	tbParam = tbParam or {}
	Ui:OpenWindow("ChatEmotionLink", self, tbParam.szTab, tbParam.bBottom, tbParam.bShowGuide);
end

function tbInputGroup.tbOnClick:ColorChat()
	Ui:OpenWindow("ColorMsgPanel");
end

function tbInputGroup.tbOnClick:BtnDelete()
	local fnConfirm = function ()
		if Mail:DelAllNormalMail() then
			self.pChatLarge:ShowMails()
		end
	end
	me.MsgBox("将清空所有邮件（有附件的邮件不会清空），是否确认一键清空？", {{"确定", fnConfirm}, {"取消"}}, "DelMailTip")
end

function tbInputGroup.tbOnClick:BtnJoinFamily()
	Ui:OpenWindow("KinJoinPanel");
end

if Sdk:IsPCVersion() then
	tbInputGroup.tbOnSubmit = {}
	tbInputGroup.tbOnSelect = {}

	function tbInputGroup.tbOnSubmit:InputField()
		self:SelectInput(false)
	end

	function tbInputGroup.tbOnSelect:InputField(szWndName, bSelect)
		if bSelect then
			return
		end

		local szMsg = self.pPanel:Input_GetText("InputField") or "";
		if szMsg ~= "" then
			tbInputGroup.tbOnClick.BtnSend(self)
		end
	end
end
