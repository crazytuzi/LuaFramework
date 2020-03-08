local tbUi = Ui:CreateClass("ChatLargePanel");
local tbItemUi = Ui:CreateClass("ChatMsgItem");

local tbChannel = {
	ChatMgr.nChannelMail,
	ChatMgr.ChannelType.System,
	ChatMgr.ChannelType.Public,
	ChatMgr.ChannelType.Nearby,
	ChatMgr.ChannelType.Kin,
	ChatMgr.ChannelType.Team,
	ChatMgr.ChannelType.Friend,
	ChatMgr.ChannelType.Private,
};


local Channel2Name = {
	[ChatMgr.nChannelMail]        = "邮箱",
	[ChatMgr.ChannelType.System]  = "系统",
	[ChatMgr.ChannelType.Public]  = "世界",
	[ChatMgr.ChannelType.Nearby]  = "附近",
	[ChatMgr.ChannelType.Kin]     = "家族",
	[ChatMgr.ChannelType.Team]    = "队伍",
	[ChatMgr.ChannelType.Friend]  = "好友",
	[ChatMgr.ChannelType.Private] = "密聊",
	[ChatMgr.ChannelType.Cross]   = "主播",
	[ChatMgr.nChannelFriendName]  = "好友名字",
	[ChatMgr.nChannelBlackList]   = "黑名单",
};

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_CHAT_NEW_MSG, self.NewChatMsg },
		{ UiNotify.emNoTIFY_NEW_PRIVATE_MSG, self.NewFriendMsg },
		{ UiNotify.emNOTIFY_CHAT_DEL_PRIVATE, self.OnDelPrivateMsg },
		{ UiNotify.emNOTIFY_PRIVATE_MSG_NUM_CHANGE, self.UpdateFriendsMsgNum },
		{ UiNotify.emNOTIFY_NOTIFY_NEW_MAIL, self.UpdateMailsNum },
		{ UiNotify.emNOTIFY_SYNC_MAIL_DATA, self.ShowMails },
		{ UiNotify.emNOTIFY_MAP_LEAVE, self.Close},
		{ UiNotify.emNOTIFY_VOICE_PLAY_START, self.OnVoiceStart},
		{ UiNotify.emNOTIFY_VOICE_PLAY_END, self.OnVoiceEnd},
		{ UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE, self.OnDynChannelChange},
		{ UiNotify.emNOTIFY_CHAT_CROSS_HOST, self.OnCrossInfoChanged},
		{ UiNotify.emNOTIFY_UPDATE_RECALL_LIST, self.NewFriendMsg },
		{ UiNotify.emNOTIFY_NPCVOICE_PLAY_END, self.OnNpcVoiceEnd },
		{UiNotify.emNOTIFY_SHOW_CHAT_INPUT, self.OnShowChatInput, self},
	};


	return tbRegEvent;
end

local nChannelMaxCount = 11;

function tbUi:OnOpen(nChannelId, nFriendId, szParam, bAutoSelectInput)
	self.pPanel:SetActive("BtnClose", not ((InDifferBattle.bRegistNotofy and InDifferBattle.nState == 1) or QunYingHuiCross:IsChoosingFaction()) )

	--@_@
	--self.pPanel:SetActive("BtnClose", not ((InDifferBattle.bRegistNotofy and InDifferBattle.nState == 1) or QunYingHuiCross:IsChoosingFaction() or
	--Fuben.LingJueFengWeek.nState == 1 or ChangBaiZhiDian:IsChoosingFaction() ))

	if tbUi.nChannelId == ChatMgr.nChannelBlackList then
		tbUi.nChannelId = nil;
	end

	tbUi.nChannelId = nChannelId or tbUi.nChannelId or ChatMgr.ChannelType.Kin;
	self.tbChannel = {unpack(tbChannel)};

	--添加动态聊天频道
	local tbDynamicChannelIds = {};
	for nChannelId,tbChannelInfo in pairs(ChatMgr.tbDynamicChannel) do
		table.insert(tbDynamicChannelIds, nChannelId);
		Channel2Name[nChannelId] = tbChannelInfo.szName;
	end
	table.sort( tbDynamicChannelIds, function (a, b)
		return a < b
	end )
	for i,v in ipairs(tbDynamicChannelIds) do
		table.insert(self.tbChannel, v);
	end

	if self.nNowChatFriendId then
		 if not ChatMgr.RecentPrivateList[1] or ChatMgr.RecentPrivateList[1].dwID ~= self.nNowChatFriendId then
			 self.nNowChatFriendId = nil;
		end
	end
	self:UpdateFriendChatBtn()

	-- 添加主播频道，需求为放到所有频道最后
	if version_tx and ChatMgr:IsCrossHostChannelOpen() then
		table.insert(self.tbChannel, ChatMgr.ChannelType.Cross);
	end

	if nChannelId == ChatMgr.nChannelBlackList then
		table.insert(self.tbChannel, nChannelId);
	end

	if Kin:HasKin() then
		Kin:UpdateMemberCareer();
		Kin:UpdateBaseInfo()
	end

	ChatMgr.ChatDecorate:TryCheckValid()
	ChatMgr:AskCrossHostState();
	ChatMgr:CheckNamePrefixInfo();
end

function tbUi:OnOpenEnd(nChannelId, nFriendId, szParam, bAutoSelectInput, tbParam)
	if type(tbUi.nChannelId) == "number" and tbUi.nChannelId >= ChatMgr.nDynChannelBegin and not ChatMgr.tbDynamicChannel[tbUi.nChannelId] then
		tbUi.nChannelId = ChatMgr.ChannelType.Public;
	end

	self.ChatInput:Init(self);
	if bAutoSelectInput then
		self.ChatInput:SelectInput(bAutoSelectInput)
	end
	self:UpdateChannelBtn();
	self:UpdateMailsNum();
	self:UpdateFriendsMsgNum();

	if szParam == "AddTeamLink" then
		self:AddTeamLink();
	elseif szParam == "OpenEmotionLink" then
		self.ChatInput.tbOnClick.BtnTypeAndLink(self.ChatInput, tbParam)
	end

	self:SwitchChannel(tbUi.nChannelId);
	if nFriendId then
		self:ShowFriendChat(nFriendId, szParam)
	end
	ChatMgr:CheckUpdateStrangerState(); --每次重新登录第一次打开聊天会检查陌生人的状态信息
end

function tbUi:OnClose()
	if self.nUpdateHistoryNewMsgTimer then
		Timer:Close(self.nUpdateHistoryNewMsgTimer);
		self.nUpdateHistoryNewMsgTimer = nil;
	end
	self.latestMsgItemObj = nil;
	self.nCurMaxChatListItemCount = 0;
	self.ChatInput:OnClose();
end

tbUi.tbTouchReturnUi =
{
	["ChatSmall"] = true;
	["DreamlandPanel"] = true;
	["QYHChoicePanel"] = true;
	--["LJFSelectFactionPanel"] = true;
	--["ChangBaiZhiDianChoicePanel"] = true;
}

function tbUi:CheckScreenClickForbid()
	if QunYingHuiCross:IsChoosingFaction() then
		return true
	end
	return false
end

function tbUi:OnScreenClick(szTouchUi)
	if self.tbTouchReturnUi[szTouchUi] then
		return;
	end
	if self:CheckScreenClickForbid() then
		return
	end
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:Close()
	Ui:CloseWindow(self.UI_NAME);
end

local tbSpecialColorBtn = {
	[9] = true;
	[10] = true;
	[11] = true;
};

function tbUi:UpdateChannelBtn()
	self.tbChannel2BtnObj = {};

	local bHostOnline = ChatMgr:IsHostOnline();
	for i = 1, nChannelMaxCount do
		local nChannelId = self.tbChannel[i];
		if nChannelId then
			local btnObj = self["BtnChannel" .. i];
			local szChanelName = Channel2Name[nChannelId];
			if nChannelId ~= ChatMgr.nChannelMail then
				btnObj.pPanel:Label_SetText("TxtLight", szChanelName);
				btnObj.pPanel:Label_SetText("TxtDark", szChanelName);

				if tbSpecialColorBtn[i] then
					if bHostOnline and nChannelId == ChatMgr.ChannelType.Cross then
						btnObj.pPanel:Label_SetText("TxtLight", "");
						btnObj.pPanel:Label_SetText("TxtDark", "");
						btnObj.pPanel:Label_SetText("TxtLight2", "直播中");
						btnObj.pPanel:Label_SetText("TxtDark2", "直播中");
						btnObj.pPanel:Button_SetSprite("Main", "BtnListMainSpecialNormal", 1);
						btnObj.pPanel:Button_SetSprite("Main", "BtnListMainSpecialNormal", 2);
						btnObj.pPanel:Button_SetSprite("Main", "BtnListMainSpecialPress", 3);

						local bCheck = btnObj.pPanel:Button_GetCheck("Main");
						btnObj.pPanel:Sprite_SetSprite("Main", bCheck and "BtnListMainSpecialPress" or "BtnListMainSpecialNormal");
					else
						btnObj.pPanel:Label_SetText("TxtLight2", "");
						btnObj.pPanel:Label_SetText("TxtDark2", "");
						btnObj.pPanel:Button_SetSprite("Main", "BtnListMainNormal", 1);
						btnObj.pPanel:Button_SetSprite("Main", "BtnListMainNormal", 2);
						btnObj.pPanel:Button_SetSprite("Main", "BtnListMainPress", 3);

						local bCheck = btnObj.pPanel:Button_GetCheck("Main");
						btnObj.pPanel:Sprite_SetSprite("Main", bCheck and "BtnListMainPress" or "BtnListMainNormal");
					end
				end
			end

			btnObj.nChannelId = nChannelId;
			self.tbChannel2BtnObj[nChannelId] = btnObj;

			self.pPanel:SetActive("BtnChannel" .. i, true);
		else
			self.pPanel:SetActive("BtnChannel" .. i, false);
		end
	end
end

function tbUi:UpdateNew()
	for i = 1, nChannelMaxCount do
		local nChannelId = self.tbChannel[i];
		if nChannelId then
			local btnObj = self["BtnChannel" .. i];
			if nChannelId == ChatMgr.ChannelType.Public
				or nChannelId == ChatMgr.ChannelType.Nearby
				or nChannelId == ChatMgr.ChannelType.System
				or nChannelId >= ChatMgr.nDynChannelBegin
				then
				btnObj.pPanel:SetActive("New", false);
			elseif nChannelId ~= ChatMgr.nChannelMail
				and nChannelId ~= ChatMgr.ChannelType.Private
				and nChannelId ~= ChatMgr.nChannelFriendName
				then
				local bNew = ChatMgr.tbNewMsgChannel[btnObj.nChannelId] and true or false;
				btnObj.pPanel:SetActive("New", bNew);
				btnObj.pPanel:SetActive("lbMsgNum", false);
			end
		end
	end
end

function tbUi:NewFriendMsg(dwSender)
	self:UpdateFriendsMsgNum()
	if tbUi.nChannelId == ChatMgr.nChannelFriendName and self.nNowChatFriendId == dwSender then
		self:UpdateChatList();
	elseif tbUi.nChannelId == ChatMgr.ChannelType.Private then
		self:ShowPrivateList()
	end
end

function tbUi:OnDelPrivateMsg(dwRoleId)
	if self.nNowChatFriendId and self.nNowChatFriendId == dwRoleId then
		self.nNowChatFriendId = nil;
		self:UpdateFriendChatBtn();
		self:UpdateChannelBtn()
	end
end

function tbUi:UpdateFriendsMsgNum()
	local nNum = ChatMgr:GetUnReadPrivateMsgNum()
	local btnObjList = self.tbChannel2BtnObj[ChatMgr.ChannelType.Private]
	local btnObjPrivate = self.tbChannel2BtnObj[ChatMgr.nChannelFriendName] --
	if btnObjPrivate then
		btnObjPrivate.pPanel:SetActive("New", false)
	end
	if not btnObjList then
		return
	end

	if nNum > 0 then
		btnObjList.pPanel:SetActive("New", true)
		btnObjList.pPanel:SetActive("lbMsgNum", true)
		btnObjList.pPanel:Label_SetText("lbMsgNum", math.min(nNum, 99))

		if btnObjPrivate and self.nNowChatFriendId then
			local tbUnRead = ChatMgr.PrivateChatUnReadCache[self.nNowChatFriendId]
			if tbUnRead and next(tbUnRead) then
				btnObjPrivate.pPanel:SetActive("New", true)
				btnObjPrivate.pPanel:SetActive("lbMsgNum", true)
				btnObjPrivate.pPanel:Label_SetText("lbMsgNum", math.min(#tbUnRead, 99))
			end
		end
	else
		btnObjList.pPanel:SetActive("New", false)
	end
end

function tbUi:UpdateMailsNum()
	local btnMailObj = self.tbChannel2BtnObj[ChatMgr.nChannelMail]
	if not btnMailObj then
		return
	end
	local nNum = Mail:GetUnreadMailCount()
	if nNum > 0 then
		btnMailObj.pPanel:SetActive("New", true)
		btnMailObj.pPanel:SetActive("lbMsgNum", true)
		btnMailObj.pPanel:Label_SetText("lbMsgNum", math.min(nNum, 99))
	else
		btnMailObj.pPanel:SetActive("New", false)
	end
end

function tbUi:IsBrowsingHistory()
	if not self.tbCurChatListItemData or not next(self.tbCurChatListItemData) then
		return false;
	end

	if not self.latestMsgItemObj then
		return true;
	end

	-- 如果最新一条消息不可见的话，则视为在浏览历史消息
	return math.abs(self.latestMsgItemObj.pPanel:GetRealPosition("Main").x) > 1000;
end

function tbUi:NewChatMsg(nChannelId, tbMsg)
	ChatMgr.tbNewMsgChannel[tbUi.nChannelId] = false;
	self:UpdateNew();

	if nChannelId ~= tbUi.nChannelId then
		return;
	end

	if self:IsBrowsingHistory() and tbMsg.nSenderId ~= me.nLocalServerPlayerId then
		self:UpdateHistoryNewMsgInfo(false);
		return;
	end
	self:UpdateChatList(true);
end

function tbUi:SwitchChannel(nChannelId)
	if self.tbChannel[#self.tbChannel] == ChatMgr.nChannelBlackList
		and nChannelId ~= ChatMgr.nChannelBlackList then
		table.remove(self.tbChannel);
		self:UpdateChannelBtn();
	end

	if nChannelId == ChatMgr.ChannelType.Cross then
		ChatMgr:AskCrossHostInfo();
	end

	tbUi.nChannelId = nChannelId;
	if nChannelId == ChatMgr.nChannelBlackList then
		self:UpdateBlackList();
	elseif nChannelId == ChatMgr.nChannelMail then
		self:UpdateMailList()
	elseif nChannelId == ChatMgr.ChannelType.Private  then
		self:ShowPrivateList();
	else
		self:UpdateChatList(true);
	end

	ChatMgr.tbNewMsgChannel[nChannelId] = false;
	self.ChatInput:OnChangeChannel();
	self:UpdateNew();
	self:UpdateCrossInfo();
	self:UpdateHistoryNewMsgInfo(true);

	for btnChannelId, btnObj in pairs(self.tbChannel2BtnObj) do
		btnObj.pPanel:Toggle_SetChecked("Main", tbUi.nChannelId == btnChannelId);
	end
end

function tbUi:UpdateBlackList()
	self:ShowScrollView("BlackScrollView");

	local tbItems = FriendShip:GetBlackList();
	local fnDelete = function (btnObj)
		FriendShip:DelBlack(btnObj.nPlayerId);
		self:UpdateBlackList();
	end

	local fnSetItem = function (itemObj, nIndex)
		local tbItem = tbItems[nIndex];
		itemObj.pPanel:Label_SetText("Name", tbItem.szName)
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbItem.nHonorLevel)
		if ImgPrefix then
			itemObj.pPanel:SetActive("PlayerTitle", true);
			itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		else
			itemObj.pPanel:SetActive("PlayerTitle", false);
		end
		local szFactionIcon = Faction:GetIcon(tbItem.nFaction);
		itemObj.pPanel:Sprite_SetSprite("Faction", szFactionIcon);
		itemObj.pPanel:Label_SetText("Level", tbItem.nLevel);

		local szPortrait, szAtlas = PlayerPortrait:GetSmallIcon(tbItem.nPortrait)
		itemObj.pPanel:Sprite_SetSprite("TxtureHead", szPortrait, szAtlas);

		itemObj.BtnDelete.nPlayerId = tbItem.dwID;
		itemObj.BtnDelete.pPanel.OnTouchEvent = fnDelete;
	end

	self.BlackScrollView:Update(tbItems, fnSetItem);
end

function tbUi:UpdateChatList(bGoBottom)
	local szChatScrollViewName = "ChatScrollView";
	if tbUi.nChannelId == ChatMgr.ChannelType.Cross then
		szChatScrollViewName = "ChatScrollView2";
	end

	self:ShowScrollView(szChatScrollViewName);

	local tbItemData = ChatMgr:GetChannelChatData(tbUi.nChannelId) or {};
	if tbUi.nChannelId == ChatMgr.nChannelFriendName then
		tbItemData = ChatMgr:GetPrivateMsg(self.nNowChatFriendId) or {}
	end

	tbItemData = {unpack(tbItemData)};
	self.tbCurChatListItemData = tbItemData;

	local tbHeight = {};
	self.nCurMaxChatListItemCount = #tbItemData;
	self.latestMsgItemObj = nil;
	local fnSetItem = function (itemObj, nIndex)
		if nIndex == #tbItemData then
			self.latestMsgItemObj = itemObj;
		elseif self.latestMsgItemObj == itemObj then
			self.latestMsgItemObj = nil;
		end

		local tbMsg = tbItemData[nIndex];
		itemObj.tbMsg = tbMsg
		local bSystem = (tbMsg.nChannelType == ChatMgr.ChannelType.System);
		local bSelf = (tbMsg.nSenderId == me.nLocalServerPlayerId);
		local nItemHeight = nil;
		tbMsg.nPortrait = bSelf and me.nPortrait or tbMsg.nPortrait

		itemObj.pPanel:SetActive("SystemMsg", bSystem);
		itemObj.pPanel:SetActive("SelfMsg", bSelf and not bSystem);
		itemObj.pPanel:SetActive("OtherMsg", not bSelf and not bSystem);

		if bSystem then
			nItemHeight = tbItemUi.InitSystemMsg(itemObj, tbMsg);
		else
			local msgItem = bSelf and itemObj.SelfMsg or itemObj.OtherMsg;
			nItemHeight = msgItem:Init(tbMsg, tbUi.nChannelId);
		end

		if not tbHeight[nIndex] then
			tbHeight[nIndex] = nItemHeight;
			itemObj.pPanel:Widget_SetSize("Main", 416, nItemHeight);
			self[szChatScrollViewName]:UpdateItemHeight(tbHeight);
		end
	end

	local tbLastMsg = tbItemData[#tbItemData] or {};
	if tbLastMsg.nSenderId == me.nLocalServerPlayerId
		or self[szChatScrollViewName]:IsBottom()
		then
		bGoBottom = true;
	end

	self[szChatScrollViewName]:UpdateItemHeight({40}); -- 初始的最小ChatItem高度
	self[szChatScrollViewName]:Update(tbItemData, fnSetItem);
	if bGoBottom then
		self[szChatScrollViewName]:GoBottom();
	end
end

function tbUi:UpdateHistoryNewMsgInfo(bClear)
	if bClear then
		self.pPanel:SetActive("BtnMoreMsg", false);
		self.pPanel:SetActive("BtnMoreMsg2", false);
		self.nNewUnshowChatMsg = 0;
		return;
	end

	self.nNewUnshowChatMsg = self.nNewUnshowChatMsg + 1;
	self.pPanel:SetActive("BtnMoreMsg", tbUi.nChannelId ~= ChatMgr.ChannelType.Cross);
	self.pPanel:SetActive("BtnMoreMsg2", tbUi.nChannelId == ChatMgr.ChannelType.Cross);
	local szMsg = string.format("您有%d条未读消息", self.nNewUnshowChatMsg);
	if self.nNewUnshowChatMsg > 99 then
		szMsg = "您有99+条未读消息";
	end

	self.pPanel:Label_SetText("TxtMoreMsg", szMsg);
	self.pPanel:Label_SetText("TxtMoreMsg2", szMsg);

	if self.nUpdateHistoryNewMsgTimer then
		Timer:Close(self.nUpdateHistoryNewMsgTimer);
	end

	self.nUpdateHistoryNewMsgTimer = Timer:Register(7, function ()
		if self:IsBrowsingHistory() then
			return true;
		end

		self:UpdateChatList();
		self:UpdateHistoryNewMsgInfo(true);
		self.nUpdateHistoryNewMsgTimer = nil;
	end);
end

function tbUi:OnCrossInfoChanged()
	self:UpdateChannelBtn();
	self.ChatInput:Update();
	self:UpdateCrossInfo();
end

function tbUi:UpdateCrossInfo()
	local bCrossChannel = (tbUi.nChannelId == ChatMgr.ChannelType.Cross);
	self.pPanel:SetActive("Anchor", bCrossChannel);
	if not bCrossChannel then
		return;
	end

	self.pPanel:SetActive("BtnHostGroup", false);

	local bIsHost = ChatMgr:IsCrossHost(me);
	local bHasJoined, bJoinedHost = ChatMgr:HasJoinedCrossChannel();
	local szBtnText = "";
	if bHasJoined then
		szBtnText = bJoinedHost and "下播" or "退出";
	else
		szBtnText = bIsHost and "操作" or "收听";
	end
	self.pPanel:Button_SetText("BtnAnchor", szBtnText);

	local szHostNames, nHostId, szHeadUrl, bFollowing = ChatMgr:GetCurCrossHostInfo();
	local szHostInfo = "当前暂无主播";
	if szHostNames and szHostNames ~= "" then
		szHostInfo = string.format("正在直播：[c8fa00]%s[-]", szHostNames);
	end

	if not Lib:IsEmptyStr(szHeadUrl) then
		self.pPanel:SetActive("Head", true);
		self.pPanel:SetActive("CommonHead", false);
		self.pPanel:Texture_SetUrlTexture("Head", szHeadUrl, false);
	else
		self.pPanel:SetActive("Head", false);
		self.pPanel:SetActive("CommonHead", true);
	end

	self.pPanel:Toggle_SetChecked("BtnFollow", bFollowing or false);
	self.BtnFollow.pPanel:Label_SetText("BtnFolloweTxt", bFollowing and "已关注" or "未关注");
	self.pPanel:Label_SetText("AnchorTxt", szHostInfo);
end

function tbUi:UpdateMailList()
	self:ShowMails(); --这里面的GetMailData会去掉超时的
	Mail:RequestMailData()
end

function tbUi:ShowMails()
	local tbMails = Mail:GetMailData()

	self:ShowScrollView("MailScrollView")

	local nNow = GetTime()
	local fnTimeDesc = function (nTime)
		local nMinus = math.max(nTime - nNow, 0)
		if nMinus < 86400 then
			return string.format("剩余%d小时", math.ceil(nMinus / 3600))
		else
			return string.format("剩余%d天", math.ceil(nMinus / 86400))
		end
	end

	local fnSetItem = function (itemObj, nIndex)
		local tbMail = tbMails[nIndex];
		itemObj.tbMail = tbMail
		itemObj.pPanel:Sprite_SetSprite("Mail", tbMail.ReadFlag and "MailOpen" or "MailClose")
		itemObj.pPanel:Label_SetText("Title", tbMail.Title)

		if tbMail.tbAttach then
			itemObj.pPanel:SetActive("Tip", true)
			itemObj.pPanel:SetActive("Annex", true)
		else
			itemObj.pPanel:SetActive("Tip", false)
			itemObj.pPanel:SetActive("Annex", false)
		end
		if tbMail.RecyleTime then
			itemObj.pPanel:Label_SetText("Time", fnTimeDesc(tbMail.RecyleTime))
		else
			itemObj.pPanel:SetActive("Time", false)
		end

	end

	self.MailScrollView:Update(tbMails, fnSetItem);
    --@_@
	--Mail:UpdateShowedMailId();
end

function tbUi:ShowPrivateList()
	self:ShowScrollView("ScrollViewFriends")

	local tbRecentPrivate = ChatMgr.RecentPrivateList;

	local fnOnSelect = function (itemClass)
		itemClass.pPanel:Toggle_SetChecked("Main", true)
		self:ShowFriendChat(itemClass.tbRoleInfo.dwID,itemClass.tbRoleInfo.szName)
	end

	local fnSetItem = function (itemClass, index)
		local tbRoleInfo = tbRecentPrivate[index]
 		local tbFriendData = FriendShip:GetFriendDataInfo(tbRoleInfo.dwID)
 		if tbFriendData then
	 		tbRoleInfo = tbFriendData
	 	end
		itemClass:SetData(tbRoleInfo)
		itemClass.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.ScrollViewFriends:Update(tbRecentPrivate, fnSetItem);
end

function tbUi:ShowFriendChat(dwFriendId, szFriendName)
	self.nNowChatFriendId = dwFriendId
	if not szFriendName then
		local tbRoleInfo = 	FriendShip:GetFriendDataInfo(dwFriendId)
		if tbRoleInfo then
			szFriendName = tbRoleInfo.szName
		end
	end
	self.szCurTalkFriendName = szFriendName

	self:UpdateFriendChatBtn();
	self:UpdateChannelBtn()

	self:SwitchChannel(ChatMgr.nChannelFriendName)
end

--好友名如果出现也在插在密聊后 ,在插入黑名单前
function tbUi:UpdateFriendChatBtn()
	local nInsertIdx = #self.tbChannel;
	for nIdx, nChannel in ipairs(self.tbChannel) do
		if nChannel == ChatMgr.ChannelType.Private then
			nInsertIdx = nIdx + 1;
		end
	end

	if self.nNowChatFriendId
		and not FriendShip:IsHeInMyBlack(self.nNowChatFriendId)
		and self.nChannelId ~= ChatMgr.nChannelBlackList
		then --不在黑名单的
		local tbRoleInfo = ChatMgr:GetFriendOrPrivatePlayerData(self.nNowChatFriendId)
		if tbRoleInfo and tbRoleInfo.szName then
			self.szCurTalkFriendName = tbRoleInfo.szName
		end
		Channel2Name[ChatMgr.nChannelFriendName] = self.szCurTalkFriendName
		local nChannelId = self.tbChannel[nInsertIdx]
		if nChannelId ~= ChatMgr.nChannelFriendName then
			table.insert(self.tbChannel, nInsertIdx, ChatMgr.nChannelFriendName)
		end
	else
		if tbUi.nChannelId == ChatMgr.nChannelFriendName then
			tbUi.nChannelId = ChatMgr.ChannelType.Public
		end
		self.nNowChatFriendId = nil;
		if self.tbChannel[nInsertIdx] == ChatMgr.nChannelFriendName then
			table.remove(self.tbChannel, nInsertIdx);
		end
	end
end

local tbScrollViews = {
	"BlackScrollView",
	"ChatScrollView",
	"ChatScrollView2",
	"MailScrollView",
	"ScrollViewFriends",
};

function tbUi:ShowScrollView(szName)
	for _ , szScrollView in ipairs(tbScrollViews) do
		self.pPanel:SetActive(szScrollView, szName == szScrollView);
	end
end

function tbUi:AddTeamLink()
	if not TeamMgr:HasTeam() then
		return;
	end

	local szMsg = self.ChatInput.pPanel:Input_GetText("InputField") or "";
	local szTarget = TeamMgr:GetCurActivityInfo() or "";
	local szTeam = string.format("<申请入队 (%d/%d)>%s开组啦~！", #TeamMgr:GetTeamMember() + 1, TeamMgr.MAX_MEMBER_COUNT, szTarget);
	szMsg = string.gsub(szMsg, "^(<.+>)(.*)$", "%2");
	self.ChatInput.pPanel:Input_SetText("InputField", szTeam .. szMsg);
	ChatMgr:SetChatLink(ChatMgr.LinkType.Team, {me.nLocalServerPlayerId, TeamMgr:GetTeamId(), TeamMgr:GetCurActivityId()});
end

function tbUi:AddMsg2Input(szMsg)
	if not szMsg then
		return;
	end

	local nOpenLevel = ChatMgr:GetOpenLevel(tbUi.nChannelId);
	if me.nLevel < nOpenLevel then
		me.CenterMsg(string.format("当前频道需%d方可发言", nOpenLevel));
		return;
	end

	self.ChatInput.pPanel:Input_SetText("InputField", szMsg);
end

function tbUi:OnVoiceStart(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	for i = 0, 1000 do
		local itemObj = self.ChatScrollView.Grid["Item" .. i];
		if itemObj then
			if itemObj.tbMsg and (
				(uFileIdHigh ~= 0 and uFileIdLow ~= 0 and itemObj.tbMsg.uFileIdHigh == uFileIdHigh and itemObj.tbMsg.uFileIdLow == uFileIdLow) or
				(itemObj.tbMsg.szApolloVoiceId and itemObj.tbMsg.szApolloVoiceId ==  szApolloVoiceId) ) then
					self:PlayItemVoiceAni(itemObj, "PlayingVoice")
				break;
			end
		else
			break;
		end
	end
end

function tbUi:OnVoiceEnd(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	for i = 0, 1000 do
		local itemObj = self.ChatScrollView.Grid["Item" .. i];
		if itemObj then
			if itemObj.tbMsg and (
			(uFileIdHigh ~= 0 and uFileIdLow ~= 0 and itemObj.tbMsg.uFileIdHigh == uFileIdHigh and itemObj.tbMsg.uFileIdLow == uFileIdLow) or
			(itemObj.tbMsg.szApolloVoiceId and itemObj.tbMsg.szApolloVoiceId ==  szApolloVoiceId) )then
				self:PlayItemVoiceAni(itemObj, "PlayingVoice4")
				break;
			end
		else
			break;
		end
	end
end

function tbUi:OnNpcVoiceEnd(szNpcVoice, nNpcVoiceId)
	for i = 0, 1000 do
		local itemObj = self.ChatScrollView.Grid["Item" .. i];
		if itemObj then
			if itemObj.tbMsg and not Lib:IsEmptyStr(szNpcVoice) and itemObj.tbMsg.szClientVoice == szNpcVoice and itemObj.tbMsg.nClientVoiceID == nNpcVoiceId then
				self:PlayItemVoiceAni(itemObj, "PlayingVoice4")
				break;
			end
		else
			break;
		end
	end
end

function tbUi:PlayItemVoiceAni(itemObj, szAni)
	if itemObj.SelfMsg.pPanel:IsActive("Main") then
		itemObj.SelfMsg.pPanel:Sprite_Animation("Speaker", szAni, nil, 4);
	elseif itemObj.OtherMsg.pPanel:IsActive("Main") then
		itemObj.OtherMsg.pPanel:Sprite_Animation("Speaker", szAni, nil, 4);
	end
end

function tbUi:OnDynChannelChange()
	local delList = {}
	local nowChannelId = {}
	local bSelectRemoved = false
	for nIndex,nChannelId in pairs(self.tbChannel) do
		if type(nChannelId) == "number" and nChannelId >= ChatMgr.nDynChannelBegin and not ChatMgr.tbDynamicChannel[nChannelId] then
			table.insert(delList,nIndex)
			if nChannelId == tbUi.nChannelId then
				bSelectRemoved = true;
			end
		else
			nowChannelId[nChannelId] = true
		end
	end

	for _,nIndex in pairs(delList) do
		table.remove(self.tbChannel, nIndex)
	end

	for nChannelId,tbChannelInfo in pairs(ChatMgr.tbDynamicChannel) do
		if not nowChannelId[nChannelId] then
			table.insert(self.tbChannel, nChannelId);
			Channel2Name[nChannelId] = tbChannelInfo.szName;
		end
	end

	self:UpdateChannelBtn();
	if bSelectRemoved then
		self:SwitchChannel(ChatMgr.ChannelType.Public);
	end
end

function tbUi:OnShowChatInput()
	self.ChatInput:SelectInput(true)
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

for i = 1, nChannelMaxCount do
	tbUi.tbOnClick["BtnChannel" .. i] = function (self)
		local btnObj = self["BtnChannel" .. i];
		self:SwitchChannel(btnObj.nChannelId);
	end
end

function tbUi.tbOnClick:BtnAnchor()
	local bHasJoined, bHost = ChatMgr:HasJoinedCrossChannel();
	local bShowHostGroup = false;
	if bHasJoined then
		if bHost then
			me.MsgBox("确定要下播吗？", {{"确认", ChatMgr.LeaveCrossChannel, ChatMgr}, {"取消"}});
		else
			ChatMgr:LeaveCrossChannel();
		end
	else
		if ChatMgr:IsCrossHost(me) then
			local bShow = self.pPanel:IsActive("BtnHostGroup");
			bShowHostGroup = not bShow;
		else
			ChatMgr:JoinCrossChannel();
		end
	end
	self.pPanel:SetActive("BtnHostGroup", bShowHostGroup);
end

function tbUi.tbOnClick:BtnHostJoinListen()
	ChatMgr:JoinCrossChannel();
	self.pPanel:SetActive("BtnHostGroup", false);
end

function tbUi.tbOnClick:BtnHostJoinSpeak()
	local fnJoin = function ()
		ChatMgr:JoinCrossChannelHost();
	end

	me.MsgBox("确定要上播吗？", {{"确认", fnJoin}, {"取消"}});
	self.pPanel:SetActive("BtnHostGroup", false);
end

function tbUi.tbOnClick:BtnMore()
	Ui:OpenWindow("ChatHostList");
end

function tbUi.tbOnClick:BtnMoreMsg()
	self:UpdateChatList(true);
	self:UpdateHistoryNewMsgInfo(true);
end

tbUi.tbOnClick.BtnMoreMsg2 = tbUi.tbOnClick.BtnMoreMsg;

function tbUi.tbOnClick:BtnFollow()
	local szHostNames, nHostId, szHeadUrl, bFollowing = ChatMgr:GetCurCrossHostInfo();
	if nHostId then
		ChatMgr:FollowHostOpt(nHostId, not bFollowing);
	else
		me.CenterMsg("当前暂无主播");
	end
	self.pPanel:Toggle_SetChecked("BtnFollow", bFollowing or false);
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

-----------------------ChatMsgItem--------------------------------

function tbItemUi:Init(tbMsg, nChannelId)
	tbUi.nChannelId = nChannelId
	self.tbMsg = tbMsg;
	self:DealLink();

	local szMsg = string.format("[365888]%s[-]",
		tbMsg.szShowMsg or tbMsg.szMsg);
	self.pPanel:Label_SetText("TxtChatMsg", szMsg);
	self.pPanel:Label_SetText("Level", tbMsg.nLevel or "");

	local voiceSize = {x = 0, y = 0}

	if ((tbMsg.uFileIdHigh and tbMsg.uFileIdHigh > 0 and tbMsg.uFileIdLow and tbMsg.uFileIdLow > 0) or
	  tbMsg.szApolloVoiceId and tbMsg.szApolloVoiceId ~= "") or self.tbMsg.szClientVoice then

		self.pPanel:SetActive("VoiceNode", true);

		self.pPanel:Sprite_Animation("Speaker", "PlayingVoice4");

		local nVoiceTime = self.tbMsg.nClientVoiceTime or tbMsg.uVoiceTime or 0
		self.pPanel:Label_SetText("TxtVoiceTime", Lib:TimeDesc4(math.floor(nVoiceTime/1000)));

		local speakerSize = self.pPanel:Sprite_GetSize("Speaker")
		local voiceTimeSize = self.pPanel:Label_GetPrintSize("TxtVoiceTime");
		voiceSize.x = speakerSize.x + voiceTimeSize.x;
		voiceSize.y = math.max(speakerSize.y, voiceTimeSize.y);
	else
		self.pPanel:SetActive("VoiceNode", false);
	end

	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbMsg.nPortrait);
	self.pPanel:Sprite_SetSprite("Head", szHead, szAtlas);

	local nSex = tbMsg.nSex or ChatMgr:GetFriendOrPrivatePlayerData(tbMsg.nSenderId).nSex;
	local szNamePrefix = ChatMgr:GetNamePrefix(tbMsg.nNamePrefix, false, nChannelId, tbMsg.nFaction, tbMsg.nSenderId, nSex);
	self.pPanel:Label_SetText("TxtName", szNamePrefix .. tbMsg.szSenderName);

	local ChatDecorate = ChatMgr.ChatDecorate
	-- 头像边框
	local nHeadFrame = tbMsg.nHeadBg
	local bDefaultHeadFrame = not ChatDecorate.tbParts[nHeadFrame]
	self.pPanel:SetActive("HeadFrame",not bDefaultHeadFrame)
	if not bDefaultHeadFrame then
		local nHeadFrameIcon = not bDefaultHeadFrame and ChatDecorate:GetIcon(nSex,nHeadFrame) or ChatDecorate.Default[ChatDecorate.PartsType.HEAD_FRAME].nIcon
		local szHeadFrameAtlas, szHeadFrameSprite = Item:GetIcon(nHeadFrameIcon);
		self.pPanel:Sprite_SetSprite("HeadFrame", szHeadFrameSprite, szHeadFrameAtlas);
	end

--@_@
--[[
	local nHeadPartsId = bDefaultHeadFrame and ChatDecorate.Default[ChatDecorate.PartsType.HEAD_FRAME].nPartsID or nHeadFrame
	local nHeadEffectId = ChatDecorate:GetEffectId(nHeadPartsId)
	if nHeadEffectId > 0 then
		self.pPanel:ShowEffect("HeadFrame", nHeadEffectId, 1)
	else
		self.pPanel:HideEffect("HeadFrame")
	end
]]

	-- 泡泡
	local nBubble = tbMsg.nChatBg
	local bDefaultBubble = not ChatDecorate.tbParts[nBubble]
	local nBubbleIcon = not bDefaultBubble and ChatDecorate:GetIcon(nSex,nBubble) or ChatDecorate.Default[ChatDecorate.PartsType.BUBBLE].nIcon
	local szBubbleAtlas, szBubbleSprite = Item:GetIcon(nBubbleIcon);
	if szBubbleAtlas and szBubbleSprite then
		self.pPanel:Sprite_SetSprite("ChatFrame", szBubbleSprite,szBubbleAtlas);
	end

	local bSelf = (tbMsg.nSenderId == me.nLocalServerPlayerId);
	if nChannelId == ChatMgr.ChannelType.Kin and not bSelf then
		--- 家族聊天的头衔显示规则
		local bLeader = Kin:GetLeaderId()==tbMsg.nSenderId
		local tbCareerData = Kin:GetMemberCareer() or {};
		local nCareer = tbCareerData[tbMsg.nSenderId];
		local szKinTitle = ""
		if bLeader then
			szKinTitle = "领袖"
		else
			if nCareer and Kin.Def.tbManagerCareers[nCareer] then
				szKinTitle = Kin.Def.Career_Name[nCareer] or "";
			end
		end
		self.pPanel:Label_SetText("TxtSpecial", szKinTitle);
		self.pPanel:SetActive("TxtSpecial", false); -- 隐藏再显示, enable时些控件会重设位置
		self.pPanel:SetActive("TxtSpecial", true);
	elseif not bSelf then
		self.pPanel:SetActive("TxtSpecial", false);
	end

	local bColor = tbMsg.nChannelType == ChatMgr.ChannelType.Color;
	local bPublic = nChannelId == ChatMgr.ChannelType.Public;
	self.pPanel:SetActive("ChannelIcon", bPublic);
	if bPublic then
		self.pPanel:Sprite_SetSprite("ChannelIcon", bColor and "ColorChat" or "WorldChat");
	end

	if bSelf then
		self.pPanel:ChangePosition("InfoNode", bPublic and 0 or 50, 0);
	else
		self.pPanel:ChangePosition("InfoNode", bPublic and 50 or 0, 0);
	end

	local tbSize = self.pPanel:Label_GetPrintSize("TxtChatMsg");
	local msgPos = self.pPanel:GetPosition("TxtChatMsg");

	local nOffset = 2
	if bSelf then
		self.pPanel:ChangePosition("TxtChatMsg", -tbSize.x - 55, -voiceSize.y-nOffset);
	else
		self.pPanel:ChangePosition("TxtChatMsg", msgPos.x, -voiceSize.y-nOffset);
	end

	local nHeight = math.max(tbSize.y + voiceSize.y + 65, 80);

	local tbPos = self.pPanel:GetPosition("Main");
	self.pPanel:ChangePosition("Main", tbPos.x, nHeight/2 - 35);

	local tbChatFramePos = self.pPanel:GetPosition("ChatFrame");

	local nSizeWidth = math.max(tbSize.x + 45, voiceSize.x + 60)
	local nSizeHeight = tbSize.y + voiceSize.y + 25

	self.pPanel:Widget_SetSize("ChatFrame", nSizeWidth , nSizeHeight);

	return nHeight;
end

function tbItemUi:DealLink()
	local tbLinkInfo = self.tbMsg.tbLinkInfo or {};

		-- 处理红包链接时的变色
	if tbLinkInfo.nLinkType == ChatMgr.LinkType.KinRedBag then
		self.pPanel:Sprite_SetColor("ChatFrame", 251, 159, 60);
	else
		self.pPanel:Sprite_SetColor("ChatFrame", 255, 255, 255);
	end

	if tbLinkInfo.nLinkType == ChatMgr.LinkType.ClientVoice and not Lib:IsEmptyStr(tbLinkInfo.szClientVoice) then
		self.tbMsg.szClientVoice = tbLinkInfo.szClientVoice
		self.tbMsg.nClientVoiceTime = tbLinkInfo.nClientVoiceTime or 0
		self.tbMsg.nClientVoiceID = tbLinkInfo.nClientVoiceID
	end

	if not tbLinkInfo.nLinkType
		or not ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType]
		then
		self.TxtChatMsg.pPanel.OnTouchEvent = nil;
		return false;
	end

	tbLinkInfo.nSex = tbLinkInfo.nSex or ChatMgr:GetFriendOrPrivatePlayerData(self.tbMsg.nSenderId).nSex;
	self.TxtChatMsg.pPanel.OnTouchEvent = function (tbObj, id)
		ChatMgr:OnLinkClicked(tbLinkInfo);
	end

	self.tbMsg.szShowMsg = ChatMgr:DealMsgWithLinkColor(self.tbMsg.szMsg, tbLinkInfo);
end

local IconName = {
	[ChatMgr.SystemMsgType.System] = "SystemChat";
	[ChatMgr.SystemMsgType.Tip]   = "TipChat";
	[ChatMgr.SystemMsgType.Kin] = "FamilyChat";
	[ChatMgr.SystemMsgType.Team] = "TeamChat";
	[ChatMgr.SystemMsgType.Friend] = "FriendChat";
	[ChatMgr.SystemMsgType.Map] = "TipChat";
}

function tbItemUi.InitSystemMsg(itemObj, tbMsg)
	if tbMsg.nSenderId == ChatMgr.SystemMsgType.TimeTips then
		itemObj.pPanel:SetActive("TxtChatTime", true);
		itemObj.pPanel:SetActive("ChatTip", false);
		local bToday = (Lib:GetLocalDay() == Lib:GetLocalDay(tbMsg.nTime));
		local szFormate = bToday and "%H:%M" or "%m-%d %H:%M";
		itemObj.pPanel:Label_SetText("TxtChatTime", os.date(szFormate, tbMsg.nTime));
		local tbSize = itemObj.pPanel:Label_GetPrintSize("TxtChatTime");
		itemObj.pPanel:Widget_SetSize("ChatTime", tbSize.x + 20, 28);
		return math.max(tbSize.y + 5, 30);
	end

	itemObj.pPanel:SetActive("TxtChatTime", false);
	itemObj.pPanel:SetActive("ChatTip", true);

	local tbLinkInfo = tbMsg.tbLinkInfo;
	if tbLinkInfo and tbLinkInfo.nLinkType and ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType] then
		itemObj.TxtSystemMsg.pPanel.OnTouchEvent = function (tbObj, id)
			ChatMgr:OnLinkClicked(tbLinkInfo);
		end;
	end

	local spriteName = IconName[tbMsg.nSenderId];
	local szMsg      = ChatMgr:DealMsgWithLinkColor(tbMsg.szMsg, tbLinkInfo);
	itemObj.pPanel:Sprite_SetSprite("ChatTip", spriteName);

	szMsg = string.format("[2a4974]%s[-]", szMsg);
	itemObj.pPanel:Label_SetText("TxtSystemMsg", szMsg);

	local tbSize = itemObj.pPanel:Widget_GetSize("TxtSystemMsg");
	itemObj.pPanel:ChangePosition("ChatTip", -200, tbSize.y / 2 + 5);
	return math.max(tbSize.y + 15, 30);
end

tbItemUi.tbOnClick = tbItemUi.tbOnClick or {};

function tbItemUi.tbOnClick:Head(_, nPosX, nPosY)
	if self.tbMsg.nSenderId == me.nLocalServerPlayerId or self.tbMsg.nSenderId <= 0 then
		return;
	end
	local dwKinId = 0
	local nLevel = self.tbMsg.nLevel
	if tbUi.nChannelId == ChatMgr.ChannelType.Kin then
		dwKinId = me.dwKinId
	elseif tbUi.nChannelId == ChatMgr.ChannelType.Friend or tbUi.nChannelId == ChatMgr.nChannelFriendName then
		local tbData = ChatMgr:GetFriendOrPrivatePlayerData(self.tbMsg.nSenderId)
		dwKinId = tbData.dwKinId or 0
		nLevel = tbData.nLevel
	end

	local tbInfo = {
		dwRoleId = self.tbMsg.nSenderId;
		szName = self.tbMsg.szSenderName;
		nPortrait = self.tbMsg.nPortrait;
		nFaction = self.tbMsg.nFaction;
		nLevel = nLevel or 1;
		dwKinId = dwKinId
	}

	local szType = ChatMgr.tbChatRightPopupChannelType[tbUi.nChannelId]
	local tbPos = self.pPanel:GetRealPosition("Head")
	if szType then
		Ui:OpenWindowAtPos("RightPopup", -76, tbPos.y -322, szType, tbInfo);
	else
		Ui:OpenWindowAtPos("RightPopup", 155, -50, "ChatRoleSelect", tbInfo);
	end
end

function tbItemUi.tbOnClick:ChatFrame(uiObj)
	if ChatMgr:IsValidVoiceFileId(self.tbMsg.uFileIdHigh, self.tbMsg.uFileIdLow, self.tbMsg.szApolloVoiceId)  then
		ChatMgr:ClearAutoPlayVoice()
		ChatMgr:PlayVoice(self.tbMsg.nChannelType, self.tbMsg.uFileIdHigh, self.tbMsg.uFileIdLow, self.tbMsg.szApolloVoiceId)
	elseif self.tbMsg.szClientVoice then
		local bRet = ChatMgr:PlayNpcVoice(self.tbMsg.szClientVoice, self.tbMsg.nClientVoiceID)
		if bRet and self.pPanel:IsActive("Main") then
			self.pPanel:Sprite_Animation("Speaker", "PlayingVoice", nil, 4)
		end
	end
end

tbItemUi.tbOnLongPress = tbItemUi.tbOnLongPress or {};

function tbItemUi.tbOnLongPress:ChatFrame(_, nX, nY)
	Ui:OpenWindowAtPos("CopyTipPanel", nX, nY, function ()
		if Ui:WindowVisible("ChatLargePanel") == 1 then
			Ui("ChatLargePanel"):AddMsg2Input(self.tbMsg.szMsg);
		end
	end);
end

local tbMailGrid = Ui:CreateClass("MailGrid");

tbMailGrid.tbOnClick = {};

function tbMailGrid.tbOnClick:Btn()
	Ui:OpenWindow("MailDetailedPanel", self.tbMail)
	self.pPanel:Sprite_SetSprite("Mail", "MailOpen")
end

