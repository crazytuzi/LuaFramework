
local ChannelColor = {
	[ChatMgr.ChannelType.Public] = "44ee76", --世界
	[ChatMgr.ChannelType.Nearby] = "ffffff", --附近
	[ChatMgr.ChannelType.Color]  = "00ffea", --彩聊
	[ChatMgr.ChannelType.Map]    = "ffaa00", --临时
	[ChatMgr.ChannelType.Team]   = "ff8adf", --队伍
	[ChatMgr.ChannelType.Kin]    = "68cff5", --家族
	[ChatMgr.nChannelFriendName] = "db25ff", --私聊
	[ChatMgr.ChannelType.System] = "f56161", --系统
	[ChatMgr.ChannelType.Friend] = "ffbbcc", --好友
	["SystemMsgTip"]             = "eacc00", --系统提示
};

ChatMgr.tbVoiceError =
{
	XT("请在手机设置中打开麦克风权限"),
	XT("没有说话或请检查是否开启录音权限"),
	XT("操作过快，请稍候再试"),
}

ChatMgr.tbNewMsgChannel = ChatMgr.tbNewMsgChannel or {};
ChatMgr.tbSpecialDynamicColor = ChatMgr.tbSpecialDynamicColor or {}

ChatMgr.tbChatEmotionMap = {}; -- 所有聊天可发送表情
ChatMgr.PrivateChatUnReadCache = ChatMgr.PrivateChatUnReadCache or {}; --根据好友id来存 ,每个玩家都有各自的未读消息
ChatMgr.PrivateChatReadCache = ChatMgr.PrivateChatReadCache or {};
ChatMgr.MAX_PRIVATE_LIST_NUM = 20
ChatMgr.MAX_PRIVATE_MSG_NUM = 50 ;--每个玩家最多保存50条
ChatMgr.RecentPrivateList = ChatMgr.RecentPrivateList or {} ; --保存最近的20个 id
ChatMgr.VOICE_REQUEST_TIME_OUT = 10 ;--语音文件下载超时时间

ChatMgr.VoiceInfo = ChatMgr.VoiceInfo or {};
ChatMgr.VoiceInfo.autoQueue = ChatMgr.VoiceInfo.autoQueue or {}
ChatMgr.tbDynamicChannel = ChatMgr.tbDynamicChannel or {}
ChatMgr.tbDynamicChannelIcon = ChatMgr.tbDynamicChannelIcon or {}
ChatMgr.ChatRoom = ChatMgr.ChatRoom or {}
local ChatRoomMgr = luanet.import_type("ChatRoomMgr");
local KGSpeechApi = luanet.import_type("KGSpeechApi.instance");

ChatMgr.bApolloVoice = false
ChatMgr.bApolloVoiceInit = false

ChatMgr.GVoiceCompleteCode =
{
	GV_ON_JOINROOM_SUCC = 1,
	GV_ON_QUITROOM_SUCC = 6,
	GV_ON_MESSAGE_KEY_APPLIED_SUCC = 7,
	GV_ON_UPLOAD_RECORD_DONE = 11,
	GV_ON_DOWNLOAD_RECORD_DONE = 13,
	GV_ON_STT_SUCC = 15,
	GV_ON_RSTT_SUCC = 18,
	GV_ON_PLAYFILE_DONE = 21,
	GV_ON_ROOM_OFFLINE = 22,
}

ChatMgr.GCloudVoiceErr =
{
	GCLOUD_VOICE_SUCC = 0,
}

ChatMgr.RoomType =
{
	Large = 1,
	Team =2,
	FM = 3,
}

ChatMgr.GVoiceMode =
{
	REALTIME_VOICE = 0,
	OFFLINE_VOICE = 1,
	STT_VOICE = 2,
	HI_REALTIME_VOICE = 4,
}

ChatMgr.tbLinkClickFns = {
	--	密聊时的自己的是不从服务器端接受的 直接从原数据处理
	[ChatMgr.LinkType.Position] = function (tbLinkInfo)
		local tbParam = tbLinkInfo.linkParam;
		if tbParam then
			local nMapId, nX, nY,nMapTemplateId = unpack(tbParam)
			AutoPath:GotoAndCall(nMapId, nX, nY,nil,nil,nMapTemplateId);
			return
		end

		if not tbLinkInfo.nMapId then
			return;
		end

		AutoPath:GotoAndCall(tbLinkInfo.nMapId, tbLinkInfo.nX, tbLinkInfo.nY,nil,nil,tbLinkInfo.nMapTemplateId);
	end;

	[ChatMgr.LinkType.Partner] = function (tbLinkInfo)
		if tbLinkInfo.linkParam then
			local nPartnerId = tbLinkInfo.linkParam
			local tbSkillInfo, pPartner = Partner:GetPartnerAllSkillInfo(me, nPartnerId);
			Ui:OpenWindow("PartnerDetail", me.GetPartnerInfo(nPartnerId), pPartner.GetAttribInfo(), tbSkillInfo);
			return
		end
		Ui:OpenWindow("PartnerDetail", tbLinkInfo.tbPartnerInfo, tbLinkInfo.tbPartnerAttribInfo, tbLinkInfo.tbPartnnerSkillInfo);
	end;
	[ChatMgr.LinkType.PartnerCard] = function (tbLinkInfo)
		local tbParams = tbLinkInfo.linkParam
		if tbLinkInfo.linkParam then
			Ui:OpenWindow("PartnerCardDetailTip", tbLinkInfo.linkParam.nCardId, nil, nil, tbLinkInfo.linkParam);
		elseif tbLinkInfo.tbParams then
			Ui:OpenWindow("PartnerCardDetailTip", tbLinkInfo.tbParams[1], nil, nil, tbLinkInfo.tbParams[2]);
		end
	end;

	[ChatMgr.LinkType.Item] = function (tbLinkInfo)
		local tbInfo = {
			nTemplate = tbLinkInfo.nTemplateId;
			nFaction = tbLinkInfo.nFaction;
			nSex = Player:Faction2Sex(tbLinkInfo.nFaction, tbLinkInfo.nSex);
			tbRandomAtrrib = tbLinkInfo.tbRandomAtrrib;
			tbStrValue = tbLinkInfo.tbStrValue;
		};

		if type(tbLinkInfo.linkParam) == "number" then
			tbInfo.nItemId = tbLinkInfo.linkParam;
		elseif type(tbLinkInfo.linkParam) == "table" then
			tbInfo.nItemId = tbLinkInfo.linkParam[1];
			tbInfo.nTemplate = tbLinkInfo.linkParam[2];
			tbInfo.nFaction = me.nFaction;
			tbInfo.nSex = me.nSex;
		end

		if not ChatMgr:ShowSpecialItem(tbInfo) then
			Item:ShowItemDetail(tbInfo);
		end
	end;

	[ChatMgr.LinkType.Team] = function (tbLinkInfo)
		TeamMgr:ApplyActivityTeam(tbLinkInfo.nActivityId, tbLinkInfo.nTeamId);
	end;

	[ChatMgr.LinkType.Achievement] = function (tbLinkInfo)
		local szName, nId, nLevel
		if tbLinkInfo.linkParam then
			nId    = math.floor(tbLinkInfo.linkParam / 100);
			nLevel = tbLinkInfo.linkParam - nId * 100;
			szName = me.szName
		elseif tbLinkInfo.szKind then
			nId    = Achievement:GetGroupKey(tbLinkInfo.szKind)
			nLevel = tbLinkInfo.nLevel
			szName = tbLinkInfo.szComName
		else
			local nAchievement = tbLinkInfo.dwAchievement;
			nId    = math.floor(nAchievement / 100);
			nLevel = math.floor(nAchievement % 100);
			szName = tbLinkInfo.szName or "";
		end

		Ui:OpenWindow("ChatAchievementPopup", nId, nLevel, szName);
	end;

	[ChatMgr.LinkType.KinDrink] = function ()
		Kin:GatherDrink()
	end;

	[ChatMgr.LinkType.KinQuestion] = function (tbLinkInfo)
		local tbQuestion = tbLinkInfo.tbQuestionData;
		if not tbQuestion  then
			return;
		end

		Ui:OpenWindow("KinAnswerPanel", tbQuestion);
	end;

	[ChatMgr.LinkType.Commerce] = function (tbLinkInfo)
		if not tbLinkInfo.dwPlayerID then
			return;
		end

		local dwPlayerID = tbLinkInfo.dwPlayerID;
		if dwPlayerID == me.dwID then
			Ui:OpenWindow("CommerceTaskPanel");
		else
			Ui:OpenWindow("CommerceHelpPanel", dwPlayerID);
		end
	end;

	[ChatMgr.LinkType.KinDPTaskHelp] = function (tbLinkInfo)
		if not tbLinkInfo.dwPlayerID then
			return;
		end

		local dwPlayerID = tbLinkInfo.dwPlayerID;
		if dwPlayerID == me.dwID then
			Ui:OpenWindow("KinDPTaskPanel");
		else
			Ui:OpenWindow("KinDPTaskHelpPanel", dwPlayerID);
		end
	end;

	[ChatMgr.LinkType.KinRedBag] = function(tbLinkInfo)
		local szId = tbLinkInfo.szId
		if not szId then return end
		Ui:OpenWindow("RedBagDetailPanel", "viewgrab", szId)
	end;

	[ChatMgr.LinkType.OpenUrl] = function(tbLinkInfo)
		if not tbLinkInfo.szUrl then
			return;
		end
		local szUrl = tbLinkInfo.szUrl
	    -- 链接中，对特殊字符进行转义，目前支持， $PlayerId$,$SeverId$,$ArenaId%$ 这三项
	    szUrl = string.gsub(szUrl, "%$PlayerId%$", me.dwID or 0);
	    szUrl = string.gsub(szUrl, "%$SeverId%$", Sdk:GetServerId() or 0);
	    szUrl = string.gsub(szUrl, "%$ArenaId%$", Sdk:GetAreaId() or 0);
		Sdk:OpenUrl(szUrl);
	end;

	[ChatMgr.LinkType.OpenWnd] = function(tbLinkInfo)
		local tbParams = tbLinkInfo.tbParams
		if not next(tbParams or {}) then return end
		Ui:OpenWindow(tbParams[1], unpack(tbParams, 2))
	end;
	[ChatMgr.LinkType.HyperText] = function (tbLinkInfo)
		if tbLinkInfo.linkParam and tbLinkInfo.linkParam.szHyperText then
			Ui.HyperTextHandle:Handle(tbLinkInfo.linkParam.szHyperText);
		end
	end;
	[ChatMgr.LinkType.OpenUrlLunTanJiuLou] = function(tbLinkInfo)
	    --local tbWebView = WebView:GetClass("LunTan");
   		--tbWebView:OpenUrlLunTan(tbLinkInfo.szParam);
	end;
	[ChatMgr.LinkType.OpenLabaActAssist] = function(tbLinkInfo)
		Activity.LabaAct:RequestPlayerAssistData(tbLinkInfo.dwID, tbLinkInfo.nId, tbLinkInfo.nComposeCount)
	end;
	[ChatMgr.LinkType.YXJQAct] = function(tbLinkInfo)
		Activity.YinXingJiQingAct:OpenQS(tbLinkInfo.dwID, tbLinkInfo.nIdx or 1)
	end;
};

function ChatMgr:OnLinkClicked(tbLinkInfo)
	if tbLinkInfo.nLinkType and ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType] then
		if me.IsInPrison() then
			me.CenterMsg("天罚期间无法使用此功能！");
			return;
		end

		ChatMgr.tbLinkClickFns[tbLinkInfo.nLinkType](tbLinkInfo);
	end
end

ChatMgr.tbSpecialItemFns = {
	MarriagePaper = function(tbInfo)
		local nItemId = tbInfo.nItemId
        local tbIntValue = tbInfo.tbRandomAtrrib or {}
        local tbData = nil
        if tbInfo.tbStrValue then
	        local tbStrValue = tbInfo.tbStrValue
	        tbData = {
	            szHusbandName = tbStrValue[Wedding.nMPHusbandNameIdx],
	            szWifeName = tbStrValue[Wedding.nMPWifeNameIdx],
	            szHusbandPledge = tbStrValue[Wedding.nMPHusbandPledgeIdx],
	            szWifePledge = tbStrValue[Wedding.nMPWifePledgeIdx],
	            nTimestamp = tbIntValue[Wedding.nMPTimestamp],
	            nLevel = tbIntValue[Wedding.nMPLevel],
	        }
	        nItemId = nil
	    end
        Ui:OpenWindow("MarriagePaperPanel", nItemId, tbData)
	end,
}

local tbLinkColor = {
	[ChatMgr.LinkType.None]        = "68cff5",
	[ChatMgr.LinkType.Item]        = "000000",  --道具
	[ChatMgr.LinkType.Position]    = "47f005",  --坐标
	[ChatMgr.LinkType.Partner]     = "000000",  --同伴
	[ChatMgr.LinkType.PartnerCard] = "6959CD",  --门客
	[ChatMgr.LinkType.Team]        = "47f005",  --队伍
	[ChatMgr.LinkType.Achievement] = "ffaa00",  --成就
	[ChatMgr.LinkType.KinDrink]    = "47f005",  --家族喝酒
	[ChatMgr.LinkType.KinQuestion] = "47f005",  --家族答题
	[ChatMgr.LinkType.Commerce]    = "47f005",  --商会求助
	[ChatMgr.LinkType.KinRedBag]   = "47f005",	--家族红包
	[ChatMgr.LinkType.OpenUrl]     = "1717ff",	--网址链接
	[ChatMgr.LinkType.OpenWnd]     = "47f005",	--打开UI
	[ChatMgr.LinkType.HyperText]   = "47f005",  --超文本
	[ChatMgr.LinkType.KinDPTaskHelp] = "47f005",  --家族聚餐任务求助
}

function ChatMgr:DealMsgWithLinkColor(szMsg, tbLinkInfo)
	if not tbLinkInfo or tbLinkInfo.nLinkType == ChatMgr.LinkType.None then
		return szMsg;
	end

	local szLinkColor = tbLinkColor[tbLinkInfo.nLinkType];
	if tbLinkInfo.nLinkType == ChatMgr.LinkType.Item then
		local nItemId = 0;
		local nTemplateId = tbLinkInfo.nTemplateId;
		local nQuality = nil;
		if type(tbLinkInfo.linkParam) == "number" then
			nItemId = tbLinkInfo.linkParam;
		elseif type(tbLinkInfo.linkParam) == "table" then
			nItemId = tbLinkInfo.linkParam[1];
			nTemplateId = tbLinkInfo.linkParam[2];
		end

		local pItem = KItem.GetItemObj(nItemId);
		if pItem then
			nTemplateId = pItem.dwTemplateId;
		end

		if tbLinkInfo.bIsEquip then
			local tbInfo = KItem.GetItemBaseProp(nTemplateId) or {};
			if tbInfo.szClass == "equip" or tbInfo.szClass == "PiFeng" then
				local tbClass = Item:GetClass(tbInfo.szClass);
				local _, nMaxQuality = tbClass:GetTipByTemplate(nTemplateId, tbLinkInfo.tbRandomAtrrib);
				nQuality = nMaxQuality;
			else
				nQuality = tbInfo.nQuality;
			end
		elseif nTemplateId then
			local tbInfo = KItem.GetItemBaseProp(nTemplateId) or {};
			nQuality = tbInfo.nQuality;
		end
		local _, _, _, _, szColor = Item:GetQualityColor(nQuality or 1);
		szLinkColor = szColor;
	elseif tbLinkInfo.nLinkType == ChatMgr.LinkType.Partner then
		local tbPartnerInfo = tbLinkInfo.tbPartnerInfo or {};
		if tbLinkInfo.linkParam then --密聊发聊天连接的数据和其他频道的数据不一样
			tbPartnerInfo = me.GetPartnerInfo(tbLinkInfo.linkParam) or {};
		end

		local _, nStarLevel = Partner:GetStarValue(tbPartnerInfo.nFightPower or 1);
		szLinkColor = Partner.tbFightPowerToTxtColor[nStarLevel] or "848484";
	elseif tbLinkInfo.nLinkType == ChatMgr.LinkType.PartnerCard then
		local tbParams = tbLinkInfo.tbParams or {}
		local nCardId = tbParams[1] or 0
		local nQuality = PartnerCard:GetQualityByCardId(nCardId)
		szLinkColor = PartnerCard.tbQualityToTxtColor[nQuality] or "848484";
	end
	local szLinkFormat = szLinkColor and string.format("[%s]%%1[-]%%2", szLinkColor);
	return szLinkFormat and string.gsub(szMsg, "(%<.+%>)(.*)", szLinkFormat) or szMsg;
end

function ChatMgr:Init()

	ChatMgr.tbChatEmotionList = LoadTabFile("Setting/Chat/ChatEmotionArray.tab", "d", nil, {"EmotionId"});

	local tbEmotionAtlas = LoadTabFile("Setting/EmotionSetting.tab", "ds", "EmotionId", {"EmotionId", "Atlas"});
	for _, tbInfo in ipairs(ChatMgr.tbChatEmotionList) do
		tbInfo.Atlas = tbEmotionAtlas[tbInfo.EmotionId].Atlas;
		ChatMgr.tbChatEmotionMap[tbInfo.EmotionId] = true;
	end

	self.ChatDataCache = self.ChatDataCache or {};
end

ChatMgr:Init();

function ChatMgr:ClearCache()
	self.ChatDataCache = {};
end

function ChatMgr:InitPrivateList()
	self.RecentPrivateList = {};
	self.PrivateChatUnReadCache = {};
 	self.PrivateChatReadCache = {};

	local tbSaveData = Client:GetPrivateMsgData()
	local tbData = tbSaveData.tbData
	if not tbData then
		return
	end

	for i, v in ipairs(tbData) do
		table.insert(self.RecentPrivateList, v[1])
		self.PrivateChatUnReadCache[v[1].dwID] = v[2]
		self.PrivateChatReadCache[v[1].dwID] = v[3]
	end

	self.nInitPrivateList = 0;
end

function ChatMgr:CheckUpdateStrangerState()
	local nNow = GetTime()
 	if not self.nInitPrivateList or nNow - self.nInitPrivateList < 3600 then
 		return
 	end

 	local tbCheckRoleIDs = {}
 	for i, v in ipairs(self.RecentPrivateList) do
 		local tbData = FriendShip:GetFriendDataInfo(v.dwID)
 		if not tbData then
			table.insert(tbCheckRoleIDs, v.dwID)
 		end
	end
	if next(tbCheckRoleIDs) then
		RemoteServer.RequestChatRoleBaseInfo(tbCheckRoleIDs)
	end

 	self.nInitPrivateList = nNow;
 end

function ChatMgr:SavePriveMsg()
	local tbSaveData = Client:GetPrivateMsgData()
	tbSaveData.tbData = nil;
	local tbSavePrivateMsgs = {}

	local PrivateChatUnReadCache = self.PrivateChatUnReadCache
	local PrivateChatReadCache 	 = self.PrivateChatReadCache

	for i, v in ipairs(self.RecentPrivateList) do
		local tbUnRead = PrivateChatUnReadCache[v.dwID] or {}
		local tbReaded = PrivateChatReadCache[v.dwID] or {}

		local nToTal = #tbUnRead + #tbReaded
		local nNeedDel = nToTal - self.MAX_PRIVATE_MSG_NUM
		if nNeedDel > 0 then
			for i2 = 1, #tbReaded do
				table.remove(tbReaded, 1)
				nNeedDel =  nNeedDel - 1;
				if nNeedDel == 0 then
					break;
				end
			end
			if nNeedDel > 0 then
				for i2 = 1, #tbUnRead do
					table.remove(tbUnRead, 1)
					nNeedDel =  nNeedDel - 1;
					if nNeedDel == 0 then
						break;
					end
				end
			end
		end

		table.insert(tbSavePrivateMsgs, {
			v,
			tbUnRead,
			tbReaded,
			})
	end

	tbSaveData.tbData = tbSavePrivateMsgs
	Client:SavePrivateMsgData()
end

function ChatMgr:CheckSavePrivateMsg()
	--只要有改变就最多60秒存一次
	if self.nTimerSavePrivate then
		return
	end
	self.nTimerSavePrivate = Timer:Register(Env.GAME_FPS * 60, function ()
		ChatMgr:SavePriveMsg();
		self.nTimerSavePrivate = nil;
	end)
end

function ChatMgr:IsValidVoiceMsg(nChannelType, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId)
	if (szApolloVoiceId and szApolloVoiceId ~= "") then
		return true
	end

	if uFileIdHigh and uFileIdHigh > 0 and uFileIdLow and  uFileIdLow > 0 and strFilePath and strFilePath ~= "" then
		if Lib:IsFileExsit(strFilePath) then
			return true
		end
	end

	return false
end

-- 过滤掉emoji 等 4字节的字符
function ChatMgr:Filter4CharString(szMsg)
	local tbWords = Lib:GetUft8Chars(szMsg);
	local tbValidWords = {};
	for _, c in pairs(tbWords) do
		if string.len(c) <= 3 then
			table.insert(tbValidWords, c);
		end
	end
	return table.concat(tbValidWords);
end

function ChatMgr:SendMsg(nChannelType, szMsg, bVoice, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
	if not ChatMgr:CheckSendMsg(nChannelType, szMsg, false, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId) then
		return false;
	end

	szMsg = ChatMgr:Filter4CharString(szMsg);

	local tbChatLink = self.tbChatLink or {};
	local nLinkType = tbChatLink.nLinkType;
	local linkParam = tbChatLink.linkParam;
	self.tbChatLink = nil;
	if not ChatMgr:CheckLinkAvailable(szMsg, nLinkType, linkParam) then
		nLinkType = 0;
		linkParam = 0;
	end

	if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(nChannelType, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId) then

		if szApolloVoiceId then
			SendChannelMessageWithApolloVoice(nChannelType, szMsg, nLinkType, linkParam, szApolloVoiceId, nVoiceTime)
		else
			local voiceData, dataLen = Lib:ReadFileBinary(strFilePath)
			if voiceData and dataLen > 0 then
				FileServer:SendVoiceFile(uFileIdHigh, uFileIdLow, voiceData, function (bRet)
					if bRet then
						SendChannelMessage(nChannelType, szMsg, nLinkType, linkParam, uFileIdHigh, uFileIdLow, nVoiceTime);
					else
						SendChannelMessage(nChannelType, szMsg, nLinkType, linkParam);
					end
				end,
				ChatMgr:IsNeedZoneFileServer(nChannelType))
			end
		end

	else

		if ChatMgr:CheckSendServer(nLinkType) then
			self:SendServerMsg(nChannelType, szMsg, nLinkType, linkParam)
		else
			SendChannelMessage(nChannelType, szMsg, nLinkType, linkParam);
		end
	end

	ChatMgr:DealAchievement(nChannelType, szMsg, bVoice);
	ChatMgr:InsertRecentSendMsg(szMsg, nLinkType, linkParam);

	--[[if version_tx and not Lib:IsEmptyStr(szMsg) and ReplaceLimitWords(szMsg) then
		Ui:ShowBlackMsg("少侠发送的信息中存在违禁词，已替换为“*”");
	end]]
	return true;
end

function ChatMgr:DealAchievement(nChannelId, szMsg, bVoice)
	if bVoice then
		Achievement:AddCount("Chat_Voice");
	end

	if string.find(szMsg, "#%d") then
		Achievement:AddCount("Chat_Emotion");
	end

	if nChannelId == ChatMgr.ChannelType.Public then
		Achievement:AddCount("Chat_World");
	end

	if nChannelId == ChatMgr.ChannelType.Color then
		Achievement:AddCount("Chat_Color");
	end

	if nChannelId == ChatMgr.ChannelType.Kin then
		Achievement:AddCount("Chat_Kin");
	end

	if ChatMgr.tbDynamicChannel[nChannelId] then
		if ChatMgr.tbDynamicChannel[nChannelId].szName == "门派" then
			Achievement:AddCount("Chat_School");
		end
	end
end

function ChatMgr:InsertRecentSendMsg(szMsg, nLinkType, linkParam)
	if not szMsg and string.len(szMsg) <= 1 then
		return;
	end

	local tbRecentMsg = Client:GetUserInfo("ChatMsgHistory");
	for nIdx, tbMsg in ipairs(tbRecentMsg) do
		if tbMsg[1] == szMsg then
			table.remove(tbRecentMsg, nIdx);
			break;
		end
	end

	table.insert(tbRecentMsg, 1, {szMsg, nLinkType, linkParam});
	if #tbRecentMsg > ChatMgr.nMaxMsgHistoryCount then
		table.remove(tbRecentMsg);
	end
	Client:SaveUserInfo();
end

function ChatMgr:GetRecentMsgs()
	return Client:GetUserInfo("ChatMsgHistory");
end

function ChatMgr:SetChatLink(nLinkType, linkParam)
	self.tbChatLink = self.tbChatLink or {};
	self.tbChatLink = {
		nLinkType = nLinkType;
		linkParam = linkParam;
	};
end

function ChatMgr:GetChannelEmotion(nChannelType, nSenderId)
	local szIcon = ChatMgr.tbDynamicChannelIcon[nChannelType]
	if szIcon then
		return szIcon
	end

	if nChannelType == ChatMgr.ChannelType.System then
		local nRealChannel = ChatMgr.SystemTypeChannel[nSenderId];
		if nRealChannel ~= ChatMgr.ChannelType.System then
			return ChatMgr.ChannelEmotion[nRealChannel] or "";
		end

		if nSenderId == ChatMgr.SystemMsgType.Tip then
			return ChatMgr.ChannelEmotion["SystemMsgTip"];
		end
	end

	return ChatMgr.ChannelEmotion[nChannelType] or "";
end

function ChatMgr:SetlDynamicChannelColor( nChannelType, szColor )
	self.tbSpecialDynamicColor[nChannelType] = szColor
end

function ChatMgr:GetChannelColor(nChannelType, nSenderId)
	if nChannelType >= self.nDynChannelBegin then
		return  self.tbSpecialDynamicColor[nChannelType] or self.DynamicColor
	end

	if nChannelType == ChatMgr.ChannelType.System then
		local nRealChannel = ChatMgr.SystemTypeChannel[nSenderId];
		if nRealChannel ~= ChatMgr.ChannelType.System then
			return ChannelColor[nRealChannel];
		end

		if nSenderId == ChatMgr.SystemMsgType.Tip then
			return ChannelColor["SystemMsgTip"];
		end
	end

	return ChannelColor[nChannelType];
end

function ChatMgr:GetChatSmallMsg()
	return ChatMgr:GetChannelChatData("chatSmall");
end

function ChatMgr:GetChannelChatData(nChannelType)
	if not self.ChatDataCache[nChannelType] then
		self.ChatDataCache[nChannelType] = {};
	end
	return self.ChatDataCache[nChannelType];
end

function ChatMgr:ParseLinkInfo(tbLinkInfo)
	if not tbLinkInfo
		or tbLinkInfo.nLinkType == ChatMgr.LinkType.None
		or not tbLinkInfo.nLinkParam
		then
		return tbLinkInfo;
	end

	local tbResult = ParseLinkData(tbLinkInfo.nLinkType, tbLinkInfo.nLinkParam, tbLinkInfo.byData);
	-- LuaPacker下来的链接, 解析成对应实际类型
	if tbResult and tbResult.nLinkType == ChatMgr.LinkType.LuaPacker then
		tbResult = tbResult.tbData;
	end
	return tbResult;
end

function ChatMgr:OnSyncChatOfflineData(tbData)
	for nChannelType, tbChannelData in pairs(tbData) do
		self.ChatDataCache[nChannelType] = tbChannelData;

		for nIdx, tbMsg in ipairs(tbChannelData) do
			--tbMsg.szMsg = ReplaceLimitWords(tbMsg.szMsg) or tbMsg.szMsg;
			tbMsg.tbLinkInfo = ChatMgr:ParseLinkInfo(tbMsg.tbLinkInfo);
			self:InsertTimeTips(tbChannelData, tbMsg, nIdx - 1);
		end
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG);

	if self.nColorUpdateTimer then
		Timer:Close(self.nColorUpdateTimer);
	end

	self.nColorUpdateTimer = Timer:Register(Env.GAME_FPS * ChatMgr.nColorMsgFreshTime, self.ColorUpdate, self);
	self:ColorUpdate();
end

function ChatMgr:ColorUpdate()
	local tbColorMsg = self:GetChannelChatData(ChatMgr.ChannelType.Color);
	local preColorMsg = self.tbCurColorMsg;

	self.tbCurColorMsg = table.remove(tbColorMsg, 1);
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_COLOR_MSG);

	if not self.tbCurColorMsg and not preColorMsg then
		self.nColorUpdateTimer = nil;
		return false;
	end

	return true;
end

function ChatMgr:GetColorMsg()
	return self.tbCurColorMsg or {};
end

function ChatMgr:InsertTimeTips(tbChatData, tbMsg, nIdx)
	if tbMsg.nChannelType ~= ChatMgr.ChannelType.Kin then
		return;
	end

	local tbLastMsg = tbChatData[nIdx] or {};
	if tbLastMsg.nTime and tbMsg.nTime < tbLastMsg.nTime + 10 * 60 then
		return;
	end

	table.insert(tbChatData, nIdx + 1, {
			nChannelType = ChatMgr.ChannelType.System,
			nSenderId = ChatMgr.SystemMsgType.TimeTips,
			szSenderName = "",
			nTime = tbMsg.nTime,
			-- szMsg = "", --os.date(szFormate, tbMsg.nTime),
		})
end

function ChatMgr:SpecialMsg(nChannelType, nSenderId, szSenderName, szMsg)
	--处理异步boss聊天消息
	if nChannelType == ChatMgr.ChannelType.System
		and nSenderId == ChatMgr.SystemMsgType.Boss
		then
		local tbBossChatData = ChatMgr:GetChannelChatData("Boss");
		table.insert(tbBossChatData, szMsg);

		-- 异步boss消息保留最近5条
		if #tbBossChatData > 5 then
			table.remove(tbBossChatData, 1);
		end

		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_BOSS_DATA, "BroadcastMsg");
		return true;
	end

	return false;
end


function ChatMgr:ClearColorFlag(szMsg)
	szMsg = string.gsub(szMsg or "", "(%[)", "%[ ");
	szMsg = string.gsub(szMsg or "", "(%])", " %]");
	return szMsg;
end

local IsPlayerEmotion = function (nEmotionId)
	if ChatMgr.tbChatEmotionMap[nEmotionId] then
		return true;
	end

	return ChatMgr.tbSpcialUserEmotion[nEmotionId];
end

function ChatMgr:FilterPlayerMsg(nChannelId, szMsg)
	if nChannelId == ChatMgr.ChannelType.System then
		return szMsg;
	end

	-- 过滤屏蔽字
	--szMsg = ReplaceLimitWords(szMsg) or szMsg;

	-- 处理颜色标签
	szMsg = ChatMgr:ClearColorFlag(szMsg);

	-- 过滤无效表情
	local tbMsg = Lib:SplitStr(szMsg, "#");
	for nIth, szStr in ipairs(tbMsg) do
		local szEmoId = string.match(szStr, "^%d%d?%d?");
		if szEmoId and not IsPlayerEmotion(tonumber(szEmoId)) then
			tbMsg[nIth] = " " .. szStr;
		end
	end

	szMsg = table.concat(tbMsg, "#");
	return szMsg;
end

function ChatMgr:OnChannelApolloTrans(nChannelType, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
	local nRealChannel = nChannelType;
	if nChannelType == ChatMgr.ChannelType.System then
		nRealChannel = ChatMgr:GetSystemMsgChannel(nSenderId);
	end

	if nChannelType == ChatMgr.ChannelType.Color then
		nRealChannel = ChatMgr.ChannelType.Public;
	end

	local tbChatData = self:GetChannelChatData(nRealChannel);
	if tbChatData then
		for _,tbMsg in pairs(tbChatData) do
			if tbMsg.szApolloVoiceId == szApolloVoiceId then
				tbMsg.szMsg = szMsg
				UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG, nRealChannel);
				break;
			end
		end
	end
end

function ChatMgr:OnChannelMessage(nChannelType, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nSexAndNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
	if ChatMgr:InBlackList(nChannelType, nSenderId) then
		return;
	end

	if ChatMgr:SpecialMsg(nChannelType, nSenderId, szSenderName, szMsg) then
		return;
	end

	-- 获取聊天前缀和性别. 将sex存在nSexAndNamePrefix高位。女0男1
	nSexAndNamePrefix = nSexAndNamePrefix or 0;
	local nNamePrefix = nSexAndNamePrefix % 128;
	local nSex = Player.SEX_FEMALE;
	if nSexAndNamePrefix >= 128 then
		nSex = Player.SEX_MALE;
	end

	if szApolloVoiceId and szApolloVoiceId ~= "" and szMsg and szMsg ~= "" then
		--apollo离线语音翻译返回结果
		self:OnChannelApolloTrans(nChannelType, nSenderId, szSenderName, nFaction, nPortrait, nLevel, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nNamePrefix, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
		ChatMgr:DealChatBubbleTalk(nChannelType, nSenderId, szMsg);
		return;
	end

	szMsg = ChatMgr:FilterPlayerMsg(nChannelType, szMsg) or szMsg;
	nSenderId, szSenderName = ChatMgr:SpecialRule4Senders(nChannelType, nSenderId, szSenderName);

	-- LuaPacker下来的链接, 解析成对应实际类型
	if tbLinkInfo and tbLinkInfo.nLinkType == ChatMgr.LinkType.LuaPacker then
		tbLinkInfo = tbLinkInfo.tbData;
	end
	if type(tbLinkInfo) == "table" then
		tbLinkInfo.nSex = tbLinkInfo.nSex or nSex;
	end

	local nNow = GetTime();
	local tbMsg = {};
	tbMsg.nChannelType = nChannelType;
	tbMsg.nSenderId = nSenderId;
	tbMsg.szSenderName = szSenderName;
	tbMsg.nNamePrefix = nNamePrefix;
	tbMsg.nHeadBg = nHeadBg;
	tbMsg.nChatBg = nChatBg;
	tbMsg.nPortrait = nPortrait;
	tbMsg.nFaction = nFaction;
	if nChannelType ~= DrinkHouse.nChannelId then
		tbMsg.nLevel = nLevel;
	end
	tbMsg.szMsg = szMsg;
	tbMsg.nTime = nNow;
	tbMsg.tbLinkInfo = tbLinkInfo;
	tbMsg.uFileIdHigh = uFileIdHigh;
	tbMsg.uFileIdLow = uFileIdLow;
	tbMsg.uVoiceTime = uVoiceTime;
	tbMsg.szApolloVoiceId = szApolloVoiceId;
	tbMsg.nSex = nSex;

	if szApolloVoiceId and szApolloVoiceId ~= "" then
		local fileIdHigh, fileIdLow = FileServer:CreateFileId()
		uFileIdHigh = fileIdHigh
		uFileIdLow = fileIdLow
		tbMsg.uFileIdHigh = fileIdHigh
		tbMsg.uFileIdLow = fileIdLow
	end

	local nRealChannel = nChannelType;
	if nChannelType == ChatMgr.ChannelType.System then
		nRealChannel = ChatMgr:GetSystemMsgChannel(nSenderId);
	end

	if nChannelType == ChatMgr.ChannelType.Color then
		nRealChannel = ChatMgr.ChannelType.Public;
		table.insert(self:GetChannelChatData(nChannelType), tbMsg)
	end

	local tbChatData = self:GetChannelChatData(nRealChannel);
	self:InsertTimeTips(tbChatData, tbMsg, #tbChatData);
	table.insert(tbChatData, tbMsg);

	if #tbChatData > ChatMgr.nMaxChannelMsgCount then
		table.remove(tbChatData, 1);
	end

	local tbChatSmallData = self:GetChannelChatData("chatSmall");
	if ChatMgr:CheckShowInSmall(nRealChannel) then
		table.insert(tbChatSmallData, tbMsg);
		-- 主界面聊天窗口只保留6条最近消息
		if #tbChatSmallData > 6 then
			table.remove(tbChatSmallData, 1);
		end
	end

	if nChannelType == ChatMgr.ChannelType.Color and not self.nColorUpdateTimer then
		self.nColorUpdateTimer = Timer:Register(Env.GAME_FPS * ChatMgr.nColorMsgFreshTime, self.ColorUpdate, self);
		self:ColorUpdate();
	end

	if szMsg and szMsg ~= "" then
		ChatMgr:DealChatBubbleTalk(nChannelType, nSenderId, szMsg);
	end

	ChatMgr:OnReceiveMsgTip(tbMsg);

	ChatMgr.tbNewMsgChannel[nRealChannel] = true;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG, nRealChannel, tbMsg);

	if ChatMgr:CheckVoiceRequestTimeOut() then
		if ChatMgr.VoiceInfo.curPlayVoice == nil and self.VoiceInfo.requestPlayVoice == nil then
			ChatMgr:AutoPlayNextVoice()
		end
	end

	if  self:CheckVoiceId(uFileIdHigh, uFileIdLow, szApolloVoiceId) and tbMsg.nSenderId ~= me.dwID and ChatMgr:CheckVoiceAutoEnable(nChannelType)  then
		ChatMgr:AddAutoPlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
		if ChatMgr.VoiceInfo.curPlayVoice == nil and self.VoiceInfo.requestPlayVoice == nil then
			ChatMgr:AutoPlayNextVoice()
		end
	end
end

function ChatMgr:CheckVoiceId(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if (szApolloVoiceId and szApolloVoiceId ~= "") then
		return true
	end

	if  uFileIdHigh and uFileIdHigh > 0 and uFileIdLow and uFileIdLow > 0 then
		return true
	end

	return false
end

function ChatMgr:OnReceiveMsgTip(tbMsg)
	if tbMsg.nChannelType == ChatMgr.ChannelType.Public and tbMsg.nSenderId == me.dwID then
		local tbChatData = self:GetChannelChatData(tbMsg.nChannelType);
		local nLeftPublicCount = ChatMgr:GetPublicChatLeftCount(me);
		local tbLeftCountTip = {
				nChannelType = ChatMgr.ChannelType.System,
				nSenderId = ChatMgr.SystemMsgType.Tip,
				szSenderName = "",
				nTime = GetTime(),
				szMsg = string.format("您在世界频道还有 [FFFE0D]%d次[-] 发言机会。", nLeftPublicCount),
			};
		table.insert(tbChatData, tbLeftCountTip);
	elseif tbMsg.nChannelType == ChatMgr.ChannelType.Cross and tbMsg.nSenderId == me.dwID then
		local tbChatData = self:GetChannelChatData(tbMsg.nChannelType);
		local nLeftCount = ChatMgr:GetCrossChatLeftCount(me);
		local tbLeftCountTip = {
				nChannelType = ChatMgr.ChannelType.System,
				nSenderId = ChatMgr.SystemMsgType.Tip,
				szSenderName = "",
				nTime = GetTime(),
				szMsg = string.format("您在主播频道还有 [FFFE0D]%d次[-] 发言机会。", nLeftCount),
			};
		table.insert(tbChatData, tbLeftCountTip);
	end
end

function ChatMgr:SpecialRule4Senders(nChannelId, nSenderId, szSenderName)
	if not version_tx or nChannelId ~= ChatMgr.ChannelType.Cross then
		return nSenderId, szSenderName;
	end

	local szServerName, bRealServer = Sdk:GetServerDesc(nSenderId);
	if ChatMgr:IsCrossHost(me) and bRealServer then
		szSenderName = string.format("%s（%s）", szSenderName, szServerName);
		return 0, szSenderName;
	elseif bRealServer then
		return 0, "来自其他服的神秘人";
	end
	return nSenderId, szSenderName;
end

function ChatMgr:DealChatBubbleTalk(nChannelId, nSenderId, szMsg)
	if nChannelId ~= ChatMgr.ChannelType.Nearby then
		return;
	end

	local pSenderNpc = me.GetNpc().GetNearbyNpcByPlayerId(nSenderId);
	if pSenderNpc then
		szMsg = ChatMgr:CutMsg(szMsg, ChatMgr.nMaxBubbleMsgLen);
		pSenderNpc.BubbleTalk(szMsg, tostring(ChatMgr.nBubbleLastingTime));
	end
end

function ChatMgr:InBlackList(nChannelType, nSenderId)
	if nChannelType == ChatMgr.ChannelType.System then
		return false;
	end

	return FriendShip:IsHeInMyBlack(nSenderId);
end

function ChatMgr:GetUnReadPrivateMsgNum()
	local nNUM = 0
	for k,v in pairs(ChatMgr.PrivateChatUnReadCache) do
		nNUM =  nNUM + #v
	end
	return nNUM
end

local function CheckInSertPrivateMsgTime(lastV, tbReaded, nTime)
	if not lastV or nTime - lastV.nTime >= 600 then
		table.insert(tbReaded,
		{
			nChannelType = ChatMgr.ChannelType.System,
			nSenderId = ChatMgr.SystemMsgType.TimeTips,
			szSenderName = "",
			nTime = nTime,
		});
	end
end

function ChatMgr:CheckSendServer(nLinkType)
	if nLinkType and nLinkType == ChatMgr.LinkType.PartnerCard then
		return true
	end
end

function ChatMgr:SendServerMsg(nChannelType, szMsg, nLinkType, linkParam)
	local szReplaceMsg = ReplaceLimitWords(szMsg)
	if szReplaceMsg then
		szMsg = szReplaceMsg
	end
	if nLinkType and nLinkType == ChatMgr.LinkType.PartnerCard then
		linkParam.tbAttribDesc = PartnerCard:GetShowCardAttribDesc(linkParam.nCardId)
	end
	RemoteServer.SendServerMsg(nChannelType, szMsg, nLinkType, linkParam)
end

function ChatMgr:SendServerPrivateMsg(dwReceive, szMsg, nLinkType, linkParam)
	local szReplaceMsg = ReplaceLimitWords(szMsg)
	if szReplaceMsg then
		szMsg = szReplaceMsg
	end
	if nLinkType and nLinkType == ChatMgr.LinkType.PartnerCard then
		linkParam.tbAttribDesc = PartnerCard:GetShowCardAttribDesc(linkParam.nCardId)
	end
	RemoteServer.SendServerPrivateMsg(dwReceive, szMsg, nLinkType, linkParam)
end

function ChatMgr:SendPrivateMessage(dwReceive, szMsg, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
	if FriendShip:IsHeInMyBlack(dwReceive) then
		me.CenterMsg("对方在您的黑名单中")
		return
	end
	if not FriendShip:IsFriend(me.dwID, dwReceive) and me.GetVipLevel() < ChatMgr.nPrivateVipLevelLimit then
		if not self.PrivateChatReadCache[dwReceive] or #self.PrivateChatReadCache[dwReceive] == 0 then
			me.CenterMsg(string.format("需要达到剑侠尊享%d级，才能密聊非好友", ChatMgr.nPrivateVipLevelLimit))
			return
		end
	end
	if not ChatMgr:CheckSendMsg(ChatMgr.ChannelType.Private, szMsg, false, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId) then
		return
	end

	--szMsg = ReplaceLimitWords(szMsg) or szMsg;
	szMsg = ChatMgr:Filter4CharString(szMsg);
	szMsg = ChatMgr:FilterPlayerMsg(ChatMgr.ChannelType.Private, szMsg)

	local tbChatLink = self.tbChatLink or {};
	local nLinkType = tbChatLink.nLinkType;
	local linkParam = tbChatLink.linkParam;
	if not ChatMgr:CheckLinkAvailable(szMsg, nLinkType, linkParam) then
		nLinkType = 0;
		linkParam = 0;
	end

	if ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(ChatMgr.ChannelType.Private, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId) then
		if szApolloVoiceId then
			SendPrivateMessageWithApolloVoice(dwReceive, szMsg, nLinkType, linkParam, szApolloVoiceId, nVoiceTime);
		else
			local voiceData, dataLen = Lib:ReadFileBinary(strFilePath)
			if voiceData and  dataLen > 0 then
				FileServer:SendVoiceFile(uFileIdHigh, uFileIdLow, voiceData, function (bRet)
					if bRet then
						SendPrivateMessage(dwReceive, szMsg, nLinkType, linkParam, uFileIdHigh, uFileIdLow, nVoiceTime)
					else
						SendPrivateMessage(dwReceive, szMsg, nLinkType, linkParam)
					end
				end,
				false)
			end
		end
	else
		uFileIdHigh = 0
		uFileIdLow = 0
		nVoiceTime = 0
		if ChatMgr:CheckSendServer(nLinkType) then
			self:SendServerPrivateMsg(dwReceive, szMsg, nLinkType, linkParam)
		else
			SendPrivateMessage(dwReceive, szMsg, nLinkType, linkParam)
		end
	end

	self:CachePrivateMsg(dwReceive, szMsg, tbChatLink, uFileIdHigh, uFileIdLow, szApolloVoiceId, nVoiceTime)

	return true
end

function ChatMgr:CachePrivateMsg(dwReceive, szMsg, tbChatLink, uFileIdHigh, uFileIdLow, szApolloVoiceId, nVoiceTime)
	Log("CachePrivateMsg", dwReceive, szMsg)
	local nNow = GetTime()
	local tbReaded = ChatMgr.PrivateChatReadCache[dwReceive] or {}
	local lastV = next(tbReaded) and tbReaded[#tbReaded];
	CheckInSertPrivateMsgTime(lastV, tbReaded, nNow)

	local tbCopySaveChatLink = Lib:CopyTB(tbChatLink)
	if tbCopySaveChatLink.nLinkType == ChatMgr.LinkType.Item and tbCopySaveChatLink.linkParam and tbCopySaveChatLink.linkParam[1] then --兼容密聊本地查看道具
		local pItem = KItem.GetItemObj(tbCopySaveChatLink.linkParam[1])
		if pItem then
			tbCopySaveChatLink.nTemplateId = pItem.dwTemplateId
			local tbRandomAtrrib = {}
			tbCopySaveChatLink.tbRandomAtrrib = tbRandomAtrrib
			tbCopySaveChatLink.linkParam = nil
			tbCopySaveChatLink.bIsEquip = pItem.IsEquip()
			for i=1,10 do
				local nVal = pItem.GetIntValue(i)
				if nVal ~= 0 then
					tbRandomAtrrib[i] = nVal
				end
			end
		end
	end

	table.insert(tbReaded, {
					nSenderId = me.nLocalServerPlayerId or me.dwID,
					szSenderName = me.szName,
					szMsg = szMsg,
					tbLinkInfo = tbCopySaveChatLink,
					uFileIdHigh = uFileIdHigh,
					uFileIdLow = uFileIdLow,
					szApolloVoiceId = szApolloVoiceId,
					uVoiceTime = nVoiceTime,
					nTime = nNow,
					nHeadBg = me.GetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, ChatMgr.CHAT_BACKGROUND_USERVAULE_HEAD),
					nChatBg = me.GetUserValue(ChatMgr.CHAT_BACKGROUND_USERVAULE_GROUP, ChatMgr.CHAT_BACKGROUND_USERVAULE_CHAT),
					nFaction = me.nFaction,
					nSex = me.nSex,
				});
	ChatMgr.PrivateChatReadCache[dwReceive] = tbReaded

	self:SortRecentPrivateList(dwReceive);
	self:CheckSavePrivateMsg()
	Achievement:AddCount("Chat_Private");
	ChatMgr:InsertRecentSendMsg(szMsg, tbChatLink.nLinkType, tbChatLink.linkParam);
end

--目前是点开就到最近聊天列表里去的
function ChatMgr:SortRecentPrivateList(dwRoleId, bOnline)
	if not dwRoleId then
		return false;
	end

	local RecentPrivateList = self.RecentPrivateList
	for i,v in ipairs(RecentPrivateList) do
		if v.dwID == dwRoleId then
			local tbData  = FriendShip:GetFriendDataInfo(dwRoleId)
			if tbData then
				v = Lib:CopyTB1(tbData)
			end
			if bOnline then
				v.nState = 2 ;
			end
			table.remove(RecentPrivateList, i)
			table.insert(RecentPrivateList, 1, v)
			return v
		end
	end

	if #RecentPrivateList >= self.MAX_PRIVATE_LIST_NUM then
		table.remove(RecentPrivateList)
	end

	local tbData  = FriendShip:GetFriendDataInfo(dwRoleId)
	if tbData then
		table.insert(RecentPrivateList, 1, Lib:CopyTB1(tbData))
		return tbData
	else
		--等从server同步完时会改
		table.insert(RecentPrivateList, 1, {
				dwID = dwRoleId,
				szName = "陌生人",
				nPortrait = 1,
				nLevel = 1,
				nHonorLevel = 0,
				nFaction = 1,
				nVipLevel = 0,
				nState = 2, -- 默认值是在线的，不在线发消息时会返回不在线同步
			})
		RemoteServer.RequestChatRoleBaseInfo({dwRoleId});
		return false
	end
end

function ChatMgr:DelPrivateChat(dwRoleId)
	for i,v in ipairs(self.RecentPrivateList) do
		if v.dwID == dwRoleId then
			table.remove(self.RecentPrivateList, i)
			self.PrivateChatUnReadCache[dwRoleId] = nil;
			self.PrivateChatReadCache[dwRoleId] = nil;
			UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_DEL_PRIVATE, dwRoleId)
			UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG)
			self:CheckSavePrivateMsg();
			return
		end
	end
end

function ChatMgr:RemoveRecentPrivateTarget(dwRoleId)
	for i,v in ipairs(self.RecentPrivateList) do
		if v.dwID == dwRoleId then
			table.remove(self.RecentPrivateList, i)
			return
		end
	end
end

function ChatMgr:OnPrivateApolloTrans(dwSender, nTime, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
	local tbPersonCache = ChatMgr.PrivateChatUnReadCache[dwSender] or {}
	local tbPersonReadedCache = ChatMgr.PrivateChatReadCache[dwSender] or {}

	for _,tbMsg in pairs(tbPersonCache) do
		if tbMsg.szApolloVoiceId == szApolloVoiceId then
			tbMsg.szMsg = szMsg
			UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG, dwSender);
			return;
		end
	end

	for _,tbMsg in pairs(tbPersonReadedCache) do
		if tbMsg.szApolloVoiceId == szApolloVoiceId then
			tbMsg.szMsg = szMsg
			UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG, dwSender);
			return;
		end
	end
end

function ChatMgr:OnPrivateMessage(dwSender, nTime, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId)
	if  FriendShip:IsHeInMyBlack(dwSender) then
		return
	end

	if szApolloVoiceId and szApolloVoiceId ~= "" and szMsg and szMsg ~= "" then
		--apollo离线语音翻译返回结果
		self:OnPrivateApolloTrans(dwSender, nTime, szMsg, uFileIdHigh, uFileIdLow, uVoiceTime, nHeadBg, nChatBg, tbLinkInfo, szApolloVoiceId);
		return;
	end

	if tbLinkInfo and tbLinkInfo.nLinkType == ChatMgr.LinkType.LuaPacker then
		tbLinkInfo.nLinkType = tbLinkInfo.tbData and tbLinkInfo.tbData.nLinkType;
		tbLinkInfo = tbLinkInfo.tbData;
	end
	if type(tbLinkInfo) == "table" then
		tbLinkInfo.nSex = ChatMgr:GetFriendOrPrivatePlayerData(dwSender).nSex;
	end

	-- 过滤屏蔽字
	--szMsg = ReplaceLimitWords(szMsg) or szMsg;

	local tbPersonCache = ChatMgr.PrivateChatUnReadCache[dwSender] or {}
	ChatMgr.PrivateChatUnReadCache[dwSender] = tbPersonCache

	local tbPersonReadedCache = ChatMgr.PrivateChatReadCache[dwSender] or {}

	--time没说要 --TODO 离线消息要不要存
	local tbMsg = {
		nSenderId = dwSender,
		nTime = nTime,
		szMsg = szMsg,
		tbLinkInfo = tbLinkInfo,
		uFileIdHigh = uFileIdHigh,
		uFileIdLow = uFileIdLow,
		szApolloVoiceId = szApolloVoiceId,
		uVoiceTime = uVoiceTime,
		nHeadBg = nHeadBg,
		nChatBg = nChatBg,
	}

	if szApolloVoiceId and szApolloVoiceId ~= "" then
		local fileIdHigh, fileIdLow = FileServer:CreateFileId()
		uFileIdHigh = fileIdHigh
		uFileIdLow = fileIdLow
		tbMsg.uFileIdHigh = fileIdHigh
		tbMsg.uFileIdLow = fileIdLow
	end

	--如果是离线消息的话， 最新的结果是最先收到的，
	if nTime <= GetTime() - 5 then
		table.insert(tbPersonCache, 1, tbMsg);
	else
		table.insert(tbPersonCache, tbMsg);
	end

	if #tbPersonReadedCache + #tbPersonCache > FriendShip.nMaxPrivateMessages then
		if #tbPersonReadedCache == 0 then
			table.remove(tbPersonCache, 1);
		else
			table.remove(tbPersonReadedCache, 1);
		end
	end

	self:SortRecentPrivateList(dwSender, true)

	UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG, dwSender);

	if self:IsValidVoiceFileId(uFileIdHigh, uFileIdLow, szApolloVoiceId) and tbMsg.nSenderId ~= me.dwID and ChatMgr:CheckVoiceAutoEnable(ChatMgr.ChannelType.Private)  then
		ChatMgr:AddAutoPlayVoice(ChatMgr.ChannelType.Private, uFileIdHigh, uFileIdLow, szApolloVoiceId)
	end

	self:CheckSavePrivateMsg()
end

function ChatMgr:OpenPrivateWindow(dwRoleId, tbPassData)
	--好友，附近，家族，排行榜
	assert(dwRoleId)
	local tbBlack = FriendShip:IsHeInMyBlack(dwRoleId)
	if tbBlack then
		local fnCallBack = function ()
			FriendShip:DelBlack(dwRoleId)
			ChatMgr:OpenPrivateWindow(dwRoleId, tbBlack)
		end
		Ui:OpenWindow("MessageBox",
		  string.format("[FFFE0D]%s[-] 在您的黑名单中，是否要解除对他的屏蔽且发起密聊？", tbBlack.szName),
		 { {fnCallBack},{} },
		 {"同意", "取消"});
		return
	end

	local tbData = self:SortRecentPrivateList(dwRoleId)
	if not tbData then
		tbData = tbPassData
		tbData.dwID = dwRoleId
	end

	if not tbData.szName then
		Log(debug.traceback())
		return
	end

	Ui:OpenWindow("ChatLargePanel", ChatMgr.nChannelFriendName, dwRoleId, tbData.szName)
end

function ChatMgr:OnPrivateChatOffline(dwRoleId)
	if FriendShip:GetFriendDataInfo(dwRoleId) then --好友相关的是实时同步的
		return
	end
	for i,v in ipairs(self.RecentPrivateList) do
		if v.dwID == dwRoleId then
			v.nState = 0;
			UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG)
			return
		end
	end
end

function ChatMgr:GetFriendOrPrivatePlayerData(dwRoleId)
	local tbPlayerData = FriendShip:GetFriendDataInfo(dwRoleId)

	if not tbPlayerData then
		for i,v in ipairs(self.RecentPrivateList) do
			if v.dwID == dwRoleId then
				tbPlayerData = v
				break
			end
		end
	end
	return tbPlayerData or {}
end

function ChatMgr:OnSynChatRoleBaseInfo(tbRoles)
	local bFind = false
	for i,v in ipairs(self.RecentPrivateList) do
		for i2, v2 in ipairs(tbRoles) do
			if v.dwID == v2.dwID then
				self.RecentPrivateList[i] = v2
				table.remove(tbRoles, i2)
				bFind = true
				break;
			end
		end
		if not next(tbRoles) then
			break;
		end
	end

	if bFind then
		UiNotify.OnNotify(UiNotify.emNoTIFY_NEW_PRIVATE_MSG) --这里是只是更新显示列表用
	end
end

--获取对应sender的消息时，会把对应未读消息转入已读消息内
function ChatMgr:GetPrivateMsg(dwSender)
	if  FriendShip:IsHeInMyBlack(dwSender) then
		ChatMgr.PrivateChatUnReadCache[dwSender] = nil;
		ChatMgr.PrivateChatReadCache[dwSender] = nil;
		return
	end
	local tbUnRead = ChatMgr.PrivateChatUnReadCache[dwSender] or {}
	local tbReaded = ChatMgr.PrivateChatReadCache[dwSender] or {}

	local tbRoleInfo = self:SortRecentPrivateList(dwSender)
	if not tbRoleInfo then
		return
	end
	local lastV = next(tbReaded) and tbReaded[#tbReaded];
	for i,v in ipairs(tbUnRead) do
		v.szSenderName = tbRoleInfo.szName;
		v.nPortrait    = tbRoleInfo.nPortrait;--加入头像信息
		v.nFaction     = tbRoleInfo.nFaction;
		CheckInSertPrivateMsgTime(lastV, tbReaded, v.nTime)
		table.insert(tbReaded, v)
		lastV = v;
	end
	ChatMgr.PrivateChatReadCache[dwSender] = tbReaded
	ChatMgr.PrivateChatUnReadCache[dwSender] = nil;
	UiNotify.OnNotify(UiNotify.emNOTIFY_PRIVATE_MSG_NUM_CHANGE)
	if next(tbUnRead) then
		self:CheckSavePrivateMsg();
	end

	return tbReaded
end

local tbSettingNameMap = {
	[ChatMgr.ChannelType.Public] = "CheckPublic";
	[ChatMgr.ChannelType.Nearby] = "CheckNearby";
	[ChatMgr.ChannelType.Team] = "CheckTeam";
	[ChatMgr.ChannelType.Kin] = "CheckKin";
	[ChatMgr.ChannelType.System] = "CheckSystem";
	[ChatMgr.ChannelType.Friend] = "CheckFriend";
	[ChatMgr.ChannelType.Map] = "CheckMap"
}

ChatMgr.tbVoiceAutoSettingNameMap = {
	[ChatMgr.ChannelType.Public] = "CheckPublicVoice";
	[ChatMgr.ChannelType.Nearby] = "CheckNearbyVoice";
	[ChatMgr.ChannelType.Team] = "CheckTeamVoice";
	[ChatMgr.ChannelType.Kin] = "CheckKinVoice";
	[ChatMgr.ChannelType.Friend] = "CheckFriendVoice";
}

function ChatMgr:CheckShowInSmall(nChannelId)
	local szIcon = ChatMgr.tbDynamicChannelIcon[nChannelId]
	if not Lib:IsEmptyStr(szIcon) then
		--如果动态频道有配小图标，则认为要显示到聊天小窗口中
		return true;
	end

	local szCheckName = tbSettingNameMap[nChannelId];
	local tbSetting = ChatMgr:GetSetting();
	return tbSetting[szCheckName];
end

function ChatMgr:CheckVoiceSendEnable()
	local tbSetting = ChatMgr:GetSetting();
	return not tbSetting["CheckTextVoice"];
end

function ChatMgr:CheckVoiceAutoEnable(nChannelId)
	local szCheckName = self.tbVoiceAutoSettingNameMap[nChannelId];
	if not szCheckName then
		return false
	end

	-- 正在主播中的主播不进行语音的自动播放
	if ChatMgr:IsCrossHost(me) and ChatMgr:HasJoinedCrossChannel() then
		return false;
	end

	local tbSetting = ChatMgr:GetSetting();
	return tbSetting[szCheckName];
end

function ChatMgr:GetSetting()
	local tbSetting = Client:GetUserInfo("ChatSetting");
	if not next(tbSetting) then
		tbSetting.CheckKin = true;
		tbSetting.CheckTeam = true;
		tbSetting.CheckPublic = true;
		tbSetting.CheckFriend = true;
		tbSetting.CheckNearby = true;
		tbSetting.CheckSystem = true;
		tbSetting.CheckTextVoice = false;
		tbSetting.TeamBubble = false;
		tbSetting.CheckKinVoice = true;
		tbSetting.CheckFriendVoice = true;
		tbSetting.CheckTeamVoice = true;
		tbSetting.CheckNearbyVoice = true;
		tbSetting.CheckPublicVoice = false;
	end
	if tbSetting.CheckPubVoice == nil then
		tbSetting.CheckPubVoice = true
		tbSetting.CheckMap = true
	end


	return tbSetting;
end

function ChatMgr:SaveSetting()
	Client:SaveUserInfo();
end

function  ChatMgr:CutMsg(szMsg, nLen)
	nLen = nLen or ChatMgr.nMaxMsgLengh;
	local nMsgLen = Lib:Utf8Len(szMsg);
	if nMsgLen > nLen then
		szMsg = Lib:CutUtf8(szMsg, nLen - 1) .. "…";
	else
		szMsg = Lib:CutUtf8(szMsg, nMsgLen);
	end
	return szMsg;
end

function ChatMgr:UpdateColorMsgCount()
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_COLORMSG_COUNT);
end

function ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow)
	return string.format("%s/voice/%u%u.voice", Ui.ToolFunction.LibarayPath, uFileIdHigh, uFileIdLow);
end

function ChatMgr:IsVoiceFileAvailable(uFileIdHigh, uFileIdLow)
	return Lib:IsFileExsit(ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
end

function ChatMgr:AddAutoPlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
	--实时语音麦克开启时不自动播放聊天语音
	if self.ChatRoom.bMicState then
		return
	end
	table.insert(self.VoiceInfo.autoQueue, {nChannelType = nChannelType, uFileIdHigh = uFileIdHigh, uFileIdLow = uFileIdLow, szApolloVoiceId = szApolloVoiceId});
end

function ChatMgr:ClearAutoPlayVoice()
	self.VoiceInfo.autoQueue  = {}
end

function ChatMgr:IsInAutoPlayQueue(uFileIdHigh, uFileIdLow)
	for _,fileInfo in pairs(self.VoiceInfo.autoQueue) do
		if fileInfo.uFileIdHigh == uFileIdHigh and fileInfo.uFileIdLow == uFileIdLow then
			return true
		end
	end

	return false
end

function ChatMgr:IsCurPlayVoice(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if not self.VoiceInfo.curPlayVoice then
		return false
	end

	if szApolloVoiceId then
		return szApolloVoiceId == self.VoiceInfo.curPlayVoice.szApolloVoiceId
	end

	return self.VoiceInfo.curPlayVoice.uFileIdHigh == uFileIdHigh and self.VoiceInfo.curPlayVoice.uFileIdLow == uFileIdLow
end

function ChatMgr:AutoPlayNextVoice()
	if  self.bStartedVoice then
		--当前正在录音
		return
	end

	if  self.VoiceInfo.curPlayVoice ~= nil then
		return
	end

	if self.VoiceInfo.szCurPlayNpcVoice ~= nil then
		return
	end

	if #self.VoiceInfo.autoQueue <= 0 then
		return false
	end

	local uFileIdHigh = self.VoiceInfo.autoQueue[1].uFileIdHigh
	local uFileIdLow = self.VoiceInfo.autoQueue[1].uFileIdLow
	local szApolloVoiceId = self.VoiceInfo.autoQueue[1].szApolloVoiceId
	local nChannelType = self.VoiceInfo.autoQueue[1].nChannelType

	if self.VoiceInfo.requestPlayVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.requestPlayVoice.uFileIdHigh, self.VoiceInfo.requestPlayVoice.uFileIdLow, self.VoiceInfo.requestPlayVoice.szApolloVoiceId)
		self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
		self.VoiceInfo.requestPlayVoice = nil
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_START, uFileIdHigh, uFileIdLow, szApolloVoiceId)

	if not ChatMgr:IsVoiceFileAvailable(uFileIdHigh, uFileIdLow) then
		self.VoiceInfo.requestPlayVoice = {uFileIdHigh = uFileIdHigh, uFileIdLow = uFileIdLow, szApolloVoiceId = szApolloVoiceId, nTime = GetTime()}

		local function OnDownLoaded()
			if #self.VoiceInfo.autoQueue > 0 and not self.VoiceInfo.curPlayVoice and
				((self.VoiceInfo.autoQueue[1].szApolloVoiceId and self.VoiceInfo.autoQueue[1].szApolloVoiceId == szApolloVoiceId) or
				(self.VoiceInfo.autoQueue[1].uFileIdHigh == uFileIdHigh and self.VoiceInfo.autoQueue[1].uFileIdLow == uFileIdLow))  then

				self.VoiceInfo.curPlayVoice = self.VoiceInfo.autoQueue[1]

				table.remove(self.VoiceInfo.autoQueue, 1)

				if szApolloVoiceId then
					local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
					if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
						self:OnStartPlayApolloVoice()
					end
					Log("OnDownLoaded PlayeVoiceFile", nRet)
				else
					Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
				end
			end

			self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
			self.VoiceInfo.requestPlayVoice = nil
		end

		if szApolloVoiceId then
			local nDownState = ChatMgr:GetVoiceDownloadState()
			Log("AutoPlayNextVoice GetVoiceDownloadState", nDownState)
			if nDownState == ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
				local nRet = ChatRoomMgr.DownloadVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szApolloVoiceId);
				Log("AutoPlayNextVoice DownloadVoiceFile", nRet)
				if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
					ChatMgr:OnStartGVoiceDownload();
					local requestPlayVoice = self.VoiceInfo.requestPlayVoice;

					requestPlayVoice.nDownLoadTimer = Timer:Register(Env.GAME_FPS, function ()

						local nState = ChatMgr:GetVoiceDownloadState()
						if nState == ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
							requestPlayVoice.nDownLoadTimer = nil
							OnDownLoaded()
							return false
						end

						return true
					end)
				end
			end
		else
			FileServer:AskVoiceFile({nRoleId = uFileIdHigh, nMixFlag = uFileIdLow}, function (szVoiceData)
				Lib:WriteFileBinary(ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szVoiceData)

				OnDownLoaded()
			end,
			ChatMgr:IsNeedZoneFileServer(nChannelType))
		end


		return false
	end

	self.VoiceInfo.curPlayVoice = self.VoiceInfo.autoQueue[1]

	table.remove(self.VoiceInfo.autoQueue, 1)

	self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
	self.VoiceInfo.requestPlayVoice = nil

	if szApolloVoiceId then
		local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
		if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
			self:OnStartPlayApolloVoice()
		end
		Log("AutoPlayNextVoice PlayeVoiceFile", nRet)
	else
		Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
	end
end

function ChatMgr:PlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if  self.bStartedVoice then
		--当前正在录音，加入自动播放队列
		self:AddAutoPlayVoice(nChannelType, uFileIdHigh, uFileIdLow, szApolloVoiceId)
		return
	end

	if self.VoiceInfo.requestPlayVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.requestPlayVoice.uFileIdHigh, self.VoiceInfo.requestPlayVoice.uFileIdLow, self.VoiceInfo.requestPlayVoice.szApolloVoiceId)
		self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
		self.VoiceInfo.requestPlayVoice = nil
	end

	if self.VoiceInfo.curPlayVoice then
		local curPlayVoice = self.VoiceInfo.curPlayVoice
		self:StopVoice();

		if (curPlayVoice.uFileIdHigh == uFileIdHigh and curPlayVoice.uFileIdLow == uFileIdLow) or
			(szApolloVoiceId and szApolloVoiceId == curPlayVoice.szApolloVoiceId) then
			return
		end
	elseif self.VoiceInfo.szCurPlayNpcVoice then
		self:StopVoice();
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_START, uFileIdHigh, uFileIdLow, szApolloVoiceId)

	if not ChatMgr:IsVoiceFileAvailable(uFileIdHigh, uFileIdLow) then
		self.VoiceInfo.requestPlayVoice = {uFileIdHigh = uFileIdHigh, uFileIdLow = uFileIdLow, szApolloVoiceId = szApolloVoiceId, nTime = GetTime()}

		local function OnDownLoaded()

			if  not self.VoiceInfo.curPlayVoice then
				self.VoiceInfo.curPlayVoice = {uFileIdHigh = uFileIdHigh, uFileIdLow = uFileIdLow, szApolloVoiceId = szApolloVoiceId}
				if szApolloVoiceId then
					local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
					if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
						self:OnStartPlayApolloVoice()
					end
					Log("PlayVoice PlayeVoiceFile", nRet)
				else
					Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
				end
			end

			self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
			self.VoiceInfo.requestPlayVoice = nil
		end

		if szApolloVoiceId then
			local nDownState = ChatMgr:GetVoiceDownloadState()
			Log("PlayVoice GetVoiceDownloadState", nDownState)
			if nDownState == ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
				local nRet = ChatRoomMgr.DownloadVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szApolloVoiceId);
				Log("PlayVoice DownloadVoiceFile", nRet)
				if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
					ChatMgr:OnStartGVoiceDownload();
					local requestPlayVoice = self.VoiceInfo.requestPlayVoice;

					requestPlayVoice.nDownLoadTimer = Timer:Register(Env.GAME_FPS, function ()

						local nState = ChatMgr:GetVoiceDownloadState()
						if nState == ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE then
							requestPlayVoice.nDownLoadTimer = nil
							OnDownLoaded()
							return false
						end

						return true
					end)
				end
			end
		else

			FileServer:AskVoiceFile({nRoleId = uFileIdHigh, nMixFlag = uFileIdLow}, function (szVoiceData)
				Lib:WriteFileBinary(ChatMgr:GetVoiceFilePath(uFileIdHigh, uFileIdLow), szVoiceData)

				OnDownLoaded()
			end,
			ChatMgr:IsNeedZoneFileServer(nChannelType))
		end

		return false
	end

	--如果StopVoice后立即播放，则PlayEnd异步事件会在这个函数后触发导致把curPlayVoice清掉
	self.bForceStartPlay = true
	self.VoiceInfo.curPlayVoice = {uFileIdHigh = uFileIdHigh, uFileIdLow = uFileIdLow, szApolloVoiceId = szApolloVoiceId}
	self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)
	self.VoiceInfo.requestPlayVoice = nil

	if szApolloVoiceId then
		local nRet = ChatRoomMgr.PlayeVoiceFile(self:GetVoiceFilePath(uFileIdHigh, uFileIdLow))
		if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
			self:OnStartPlayApolloVoice()
		end
		Log("PlayVoice PlayeVoiceFile", nRet)
	else
		Ui.UiManager.PlayVoice(uFileIdHigh, uFileIdLow)
	end
end


function ChatMgr:StopVoice()
	local bUseApolloVoice = ChatMgr:CheckUseApollo()
	if bUseApolloVoice then
		ChatRoomMgr.StopPlayVoiceFile()
	else
		Ui.UiManager.StopVoice()
	end

	if self.VoiceInfo.curPlayVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.curPlayVoice.uFileIdHigh, self.VoiceInfo.curPlayVoice.uFileIdLow, self.VoiceInfo.curPlayVoice.szApolloVoiceId)
	end

	if self.VoiceInfo.szCurPlayNpcVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_NPCVOICE_PLAY_END, self.VoiceInfo.szCurPlayNpcVoice, self.VoiceInfo.nCurPlayNpcVoiceId)
	end

	self.VoiceInfo.curPlayVoice = nil
	self.VoiceInfo.szCurPlayNpcVoice = nil
	self.VoiceInfo.nCurPlayNpcVoiceId = nil
end

function ChatMgr:OnVoicePlayStart()
	self.bForceStartPlay = false
	--[[ if ChatMgr.VoiceInfo.curPlayVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_START, ChatMgr.VoiceInfo.curPlayVoice.uFileIdHigh, ChatMgr.VoiceInfo.curPlayVoice.uFileIdLow, ChatMgr.VoiceInfo.curPlayVoice.szApolloVoiceId)
	 end]]
	 Ui:SetMusicVolume(0)
	 Ui:SetSoundEffect(0)
end

function ChatMgr:OnVoicePlayEnd()

	if self.bForceStartPlay then
		self.bForceStartPlay = false
		return
	end

	if self.VoiceInfo.curPlayVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_END, self.VoiceInfo.curPlayVoice.uFileIdHigh, self.VoiceInfo.curPlayVoice.uFileIdLow, self.VoiceInfo.curPlayVoice.szApolloVoiceId)
	end
	if self.VoiceInfo.szCurPlayNpcVoice then
		UiNotify.OnNotify(UiNotify.emNOTIFY_NPCVOICE_PLAY_END, self.VoiceInfo.szCurPlayNpcVoice, self.VoiceInfo.nCurPlayNpcVoiceId)
	end
	self:CheckMusicVolume()
	self.VoiceInfo.curPlayVoice = nil
	self.VoiceInfo.szCurPlayNpcVoice = nil
	self.VoiceInfo.nCurPlayNpcVoiceId = nil
	self:AutoPlayNextVoice()

end

function ChatMgr:OnVoiceRecordChangeVolume(nVolume)
	UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_RECORD_VOLUME_CHANG, nVolume)
end

function ChatMgr:OnVoicePlayChangeVolume(nVolume)
	UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_PLAY_VOLUME_CHANG, nVolume)
end

function ChatMgr:OnVoiceError(szError)
	Ui.EndVoice()

	local szErrorCode = string.match(szError, "^Err%((%d+)%):.*$")
	local nErrorCode = (szErrorCode and tonumber(szErrorCode)) or 1

	me.CenterMsg(ChatMgr.tbVoiceError[nErrorCode] or XT("未知错误"))
end

function ChatMgr:IsValidVoiceFileId(uFileIdHigh, uFileIdLow, szApolloVoiceId)
	if szApolloVoiceId then
		return szApolloVoiceId ~= ""
	end

	return uFileIdHigh and uFileIdHigh > 0 and uFileIdLow and uFileIdLow > 0
end

function ChatMgr:OnLogin(bIsReconnect)
	if not bIsReconnect then
		RemoteServer.ReportTextVoiceSetting(not ChatMgr:CheckVoiceSendEnable())
	end
	if version_tx then
		ChatRoomMgr.CreateEngine()
		ChatRoomMgr.ApplyMessageKey()
	end
end

function ChatMgr:OnLostConnect()
	self:ClearDynChannelInfo()
	self:LeaveCurChatRoom()
end

function ChatMgr:OnLeaveGame()
	self:ClearCache()
	self:SavePriveMsg();
	self:ClearDynChannelInfo()
	if ANDROID or IOS then
		self:ClearAutoPlayVoice()
		self:StopVoice()
	end

	self:LeaveCurChatRoom();
	self.bHasJoinedCrossChannel = nil;
	self.nNextCheckNamePrefixInfoTime = nil;

	self:CloseGFM()

	ChatRoomMgr.DestroyEngine();
end


function ChatMgr:CheckNamePrefixInfo()
	local nNow = GetTime();
	if self.nNextCheckNamePrefixInfoTime and self.nNextCheckNamePrefixInfoTime > nNow then
		return;
	end
	self.nNextCheckNamePrefixInfoTime = nNow + 60;

	if GetTimeFrameState(ChatMgr.szNamePrefixPowerTop10TimeFrame) ~= 1 then
		return;
	end
	RemoteServer.DoChatRequest("CheckPlayerNamePrefixInfo");
end

function ChatMgr:OnNamePrefixInfoChanged(nPrefixId)
	Ui:SetRedPointNotify("ChatNamePrefix");
end

function ChatMgr:SetCurrentNamePrefixInfo(nPrefixId)
	RemoteServer.DoChatRequest("SetCurrentNamePrefixInfo", nPrefixId);
end

function ChatMgr:OnSyncEnterChatChannel(...)
	local tbChannelList = {...}
	for _,tbInfo in pairs(tbChannelList) do
		self.tbDynamicChannel[tbInfo[1]] =
		{
			nId = tbInfo[1],
			szName = tbInfo[2],
		}
		self.tbDynamicChannelIcon[tbInfo[1]] = tbInfo[3]
	end


	UiNotify.OnNotify(UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE)
end

function ChatMgr:OnSyncLeaveChatChannel(nChannelId)
	self.tbDynamicChannel[nChannelId] = nil;
	UiNotify.OnNotify(UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE)
end

function ChatMgr:ClearDynChannelInfo()
	self.tbDynamicChannel = {}
	UiNotify.OnNotify(UiNotify.emNOTIFY_DYN_CHANNEL_CHANGE)
end

function ChatMgr:IsChatRoomAvailable()
	if self.ChatRoom.dwRoomHighId and self.ChatRoom.dwRoomLowId and
	  (self.ChatRoom.dwRoomHighId ~= 0 or
	  self.ChatRoom.dwRoomLowId ~= 0) then

		return true;
	end

	return false;
end

function ChatMgr:OnSyncEnterChatRoom(dwRoomHighId, dwRoomLowId, dwRoomHighKey, dwRoomLowKey, uBusinessId, nIsLarge, nPrivilege, uMemberId, tbUrl)
	Log("OnSyncEnterChatRoom", dwRoomHighId, dwRoomLowId, dwRoomHighKey, dwRoomLowKey, nIsLarge, nPrivilege, uMemberId);
	Lib:LogTB(tbUrl)

	if self.ChatRoom.dwRoomHighId == dwRoomHighId and self.ChatRoom.dwRoomLowId ==  dwRoomLowId then
		return
	end

	self:CloseGFM();

	self:LeaveCurChatRoom();

	self.ChatRoom.dwRoomHighId = dwRoomHighId;
	self.ChatRoom.dwRoomLowId = dwRoomLowId;

	self.ChatRoom.dwRoomHighKey = dwRoomHighKey;
	self.ChatRoom.dwRoomLowKey = dwRoomLowKey;

	self.ChatRoom.uBusinessId = uBusinessId;
	self.ChatRoom.nIsLarge = nIsLarge;
	self.ChatRoom.nPrivilege = nPrivilege;
	self.ChatRoom.uMemberId = uMemberId;
	self.ChatRoom.isEnterRoom = false;
	self.ChatRoom.bSpeakerState = false;
	self.ChatRoom.bMicState = false;

	for idx,szUrl in pairs(tbUrl) do
		if nIsLarge ~= 1 and string.sub(tbUrl[idx],1,string.len("udp://")) ~= "udp://" then
			tbUrl[idx] = "udp://" .. szUrl
		end
	end

	self.ChatRoom.tbUrl = tbUrl;

	Timer:Register(Env.GAME_FPS * 1, self.StartEnterRoom, self);
end

function ChatMgr:OnSyncLeaveChatRoom(dwRoomHighId, dwRoomLowId)
	if self.ChatRoom.dwRoomHighId ~= dwRoomHighId or
		self.ChatRoom.dwRoomLowId ~= dwRoomLowId then

		return
	end

	self:LeaveCurChatRoom();
end

function ChatMgr:LeaveCurChatRoom()
	Log("LeaveCurChatRoom", tostring(self:IsChatRoomAvailable()))

	if not self:IsChatRoomAvailable() then
		return
	end

	local nRoomType = ChatMgr.RoomType.Team;
	if self.ChatRoom.nIsLarge == 1 then
		nRoomType = ChatMgr.RoomType.Large;
	end

	local dwRoomHighId = self.ChatRoom.dwRoomHighId
	local dwRoomLowId = self.ChatRoom.dwRoomLowId

	self.ChatRoom.dwRoomHighId = 0;
	self.ChatRoom.dwRoomLowId = 0;

	self.ChatRoom.dwRoomHighKey = 0;
	self.ChatRoom.dwRoomLowKey = 0;

	self.ChatRoom.uBusinessId = 0;
	self.ChatRoom.nIsLarge = 0;
	self.ChatRoom.nPrivilege = 0;
	self.ChatRoom.uMemberId = 0;
	self.ChatRoom.isEnterRoom = false;
	self.ChatRoom.bSpeakerState = false;
	self.ChatRoom.bMicState = false;

	self.ChatRoom.tbUrl = {};

	self:CloseChatRoomSpeaker();
	self:CloseChatRoomMic();

	ChatRoomMgr.LeaveRoom(dwRoomHighId, dwRoomLowId, nRoomType);

	self:CheckMusicVolume();

	Ui:CloseWindow("HomeScreenVoice")
end


function ChatMgr:CheckMusicVolume()
	if self.ChatRoom.bMicState then
		self:ClearAutoPlayVoice();
		self:StopVoice();
	end

	if self.checkVolumeTimer then
		return
	end

	local function checkVolume()
		self.checkVolumeTimer = nil
		if self.ChatRoom.bSpeakerState or self.ChatRoom.bMicState or
			self.VoiceInfo.curPlayVoice or self.bStartedVoice or
			self.VoiceInfo.szCurPlayNpcVoice or self.ChatRoom.bGFM then

			Ui:SetMusicVolume(0)
			Ui:SetSoundEffect(0)
		else
			Ui:UpdateSoundSetting()
		end
	end

	self.checkVolumeTimer = Timer:Register(Env.GAME_FPS * 1, checkVolume);
end

function ChatMgr:OpenChatRoomSpeaker()
	if not self:IsChatRoomAvailable() then
		return
	end

	self.ChatRoom.bSpeakerState = ChatRoomMgr.OpenSpeaker();

	self:CheckMusicVolume();
end

function ChatMgr:CloseChatRoomSpeaker()
	if not self:IsChatRoomAvailable() then
		return
	end

	self.ChatRoom.bSpeakerState = ChatRoomMgr.CloseSpeaker();
	self:CheckMusicVolume();
end

function ChatMgr:CloseChatRoomTmp()
	self.ChatRoom.bSpeakerStateTmp = self.ChatRoom.bSpeakerState;
	self.ChatRoom.bMicStateTmp = self.ChatRoom.bMicState;
	self:CloseChatRoomSpeaker()
	self:CloseChatRoomMic()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_ROOM_STATUS);
end

function ChatMgr:RestoreChatRoomTmp()
	if self.ChatRoom.bSpeakerStateTmp then
		self:OpenChatRoomSpeaker()
	end

	if self.ChatRoom.bMicStateTmp then
		self:OpenChatRoomMic()
	end

	self.ChatRoom.bSpeakerStateTmp = false
	self.ChatRoom.bMicStateTmp = false
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_ROOM_STATUS);
end

function ChatMgr:OpenChatRoomMic()
	if not self:IsChatRoomAvailable() then
		return
	end

	--[[if ANDROID and Ui.ToolFunction.GetAndroidSdkLevel() >= 23 then
		me.CenterMsg("抱歉，当前系统版本不兼容，暂时不能使用！")
		return
	end]]

	self.ChatRoom.bMicState = ChatRoomMgr.OpenMic();
	self:CheckMusicVolume();
end

function ChatMgr:CloseChatRoomMic()
	if not self:IsChatRoomAvailable() then
		return
	end

	self.ChatRoom.bMicState = ChatRoomMgr.CloseMic();
	self:CheckMusicVolume();
end

function ChatMgr:ClearRoleChatMsg(dwRoleID)
	for nRealChannel,tbChatData in pairs(self.ChatDataCache) do

		for idx=#tbChatData,1, -1 do
			if tbChatData[idx].nSenderId == dwRoleID then
				table.remove(tbChatData,idx)
			end
		end

		UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_NEW_MSG, nRealChannel);
	end

end

function ChatMgr:StartEnterRoom()
	if not self:IsChatRoomAvailable() then
		return
	end
	if self.szGVoiceServerUrl and self.szGVoiceServerUrl ~= "" then
		ChatRoomMgr.SetServerInfo(self.szGVoiceServerUrl);
	end

	ChatRoomMgr.SetMode(ChatMgr.GVoiceMode.REALTIME_VOICE);

	local bHasJoined, bJoinedHost = ChatMgr:HasJoinedCrossChannel();
	if bHasJoined and bJoinedHost then
		--ChatRoomMgr.SetAnchorUsed(true);
		--ChatRoomMgr.SetMemberCount(1);
	end

	if IOS and not self.bInitFixApollo then
		ChatRoomMgr.OpenMic();
		self.bInitFixApollo = true
		Timer:Register(Env.GAME_FPS*2, function ()
				ChatRoomMgr.CloseMic();
			end)
	end

	local nRoomType = ChatMgr.RoomType.Team;
	if self.ChatRoom.nIsLarge == 1 then
		nRoomType = ChatMgr.RoomType.Large;
	end

	ChatRoomMgr.EnterRoom(self.ChatRoom.dwRoomHighId,
		self.ChatRoom.dwRoomLowId,
		nRoomType,
		self.ChatRoom.nPrivilege);
end

function ChatMgr:IsCanUseRoomMic()
	if not self:IsChatRoomAvailable() or not self.ChatRoom.isEnterRoom then
		return false
	end

	if self.ChatRoom.nIsLarge == 1 and self.ChatRoom.nPrivilege ~= ChatMgr.RoomPrivilege.emSpeaker then
		return false
	end

	--[[if ANDROID and Ui.ToolFunction.GetAndroidSdkLevel() >= 23 then
		return true, true
	end]]

	return true
end

function ChatMgr:IsCanUseRoomSpeaker()
	if not self:IsChatRoomAvailable() or not self.ChatRoom.isEnterRoom then
		return false
	end

	return true
end

function ChatMgr:OnEnterChatRoom()
	self.ChatRoom.isEnterRoom = true;

	ChatMgr:OpenChatRoomSpeaker();

	if Ui:WindowVisible("HomeScreenVoice") == 1 then
		local isMicAvailable, isTmpDisable = ChatMgr:IsCanUseRoomMic();
		UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_ROOM_STATUS, true, isMicAvailable, self:IsCanUseRoomSpeaker());
	else
		Ui:OpenWindow("HomeScreenVoice")
	end
end

function ChatMgr:CheckVoiceRequestTimeOut()
	if self.VoiceInfo.requestPlayVoice == nil then
		return true
	end

	if (self.VoiceInfo.requestPlayVoice.nTime + self.VOICE_REQUEST_TIME_OUT) > GetTime() then
		return false
	end

	if self.VoiceInfo.autoQueue[1] and ((self.VoiceInfo.autoQueue[1].uFileIdHigh == self.VoiceInfo.requestPlayVoice.uFileIdHigh and
		self.VoiceInfo.autoQueue[1].uFileIdLow == self.VoiceInfo.requestPlayVoice.uFileIdLow) or
		self.VoiceInfo.autoQueue[1].szApolloVoiceId and self.VoiceInfo.autoQueue[1].szApolloVoiceId == self.VoiceInfo.requestPlayVoice.szApolloVoiceId)  then

		table.remove(self.VoiceInfo.autoQueue, 1)
	end

	self:StopRequestApolloVoice(self.VoiceInfo.requestPlayVoice)

	self.VoiceInfo.requestPlayVoice = nil

	return true
end

function ChatMgr:IsApolloEnable()
	--[[if not Sdk:IsMsdk() then
		return false;
	end]]

	if ANDROID or IOS then
		return true;
	end

	return false;
end

function ChatMgr:GetMaxVoiceTime(nChannelType)
	if nChannelType == self.nChannelKinDecl then
		return self.MAX_KIN_DECL_TIME
	elseif nChannelType == self.nChannelKinApply then
		return self.MAX_KIN_APPLY_TIME
	end
	local tbVoiceTimeInfo = ChatMgr.tbMaxVoiceTimes[nChannelType]
	if not tbVoiceTimeInfo then
		return ChatMgr.MAX_VOICE_TIME_DEFAULT
	end

	local tbMyData = Kin:GetMyMemberData()
	local nCareer = tbMyData and tbMyData.nCareer or Kin.Def.Career_Normal
	local nVipLevel = me.GetVipLevel()

	local tbCareerTimes = tbVoiceTimeInfo.tbCareer or {}
	local tbVipTimes = tbVoiceTimeInfo.tbVip or {}

	local nVipTimes = nil
	for nNeedLevel,nTime in pairs(tbVipTimes) do
		if nVipLevel >= nNeedLevel and (not nVipTimes or nVipTimes < nTime) then
			nVipTimes = nTime
		end
	end

	return nVipTimes or tbCareerTimes[nCareer] or ChatMgr.MAX_VOICE_TIME_DEFAULT
end

function ChatMgr:OnSyncApolloVoice(bEnable)
	self.bApolloVoice = bEnable
end

function ChatMgr:OnApolloAuth(uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey)
	Log("OnApolloAuth", uMainId, szMainUrl1, szMainUrl2, uMainIp1, uMainIp2, uSlaveId, szSlaveUrl1, szSlaveUrl2, uSlaveIp1, uSlaveIp2, uExpireTime, szAuthKey)

	--[[local function delayAuth()
		ChatRoomMgr.CreateEngine();

		ChatRoomMgr.SetMode(ChatMgr.GVoiceMode.STT_VOICE);

		local nRet = ChatRoomMgr.SetAuthkey(szAuthKey);
		Log("SetAuthkey", nRet)
		nRet = ChatRoomMgr.SetServiceInfo(uMainIp1, uMainIp2, uSlaveIp1, uSlaveIp2, 80, 20000);
		Log("SetServiceInfo", nRet)

		self.bApolloVoiceInit = true
	end

	if IOS then
		--分支IOS版本 在loading 时候调用 auth会导致卡死,原因未知先加上一个延时
		--Timer:Register(Env.GAME_FPS*30, function ()
		--		delayAuth();
		--	end)
	else
		delayAuth();
	end]]
end

function ChatMgr:CheckUseApollo()
	Log("CheckUseApollo", tostring(self.bApolloVoice), tostring(self.bApolloVoiceInit))
	--[[if ANDROID and Ui.ToolFunction.GetAndroidSdkLevel() >= 23 then
		return false
	end]]

	if not self:CheckVoiceSendEnable() then
		return false
	end

	return self.bApolloVoice --[[and self.bApolloVoiceInit]]
end

function ChatMgr:StartApolloVoice(uFileIdHigh, uFileIdLow)
	--这个文件地址是临时的，等上传完毕获得szApolloFileId后再去下载一遍
	local szFilePath = self:GetVoiceFilePath(uFileIdHigh, uFileIdLow)
	Log("StartApolloVoice", szFilePath)

	local nRet = ChatRoomMgr.StartRecord(szFilePath, ChatMgr.GVoiceMode.STT_VOICE);
	Log("StartRecord", nRet)
	if nRet == ChatMgr.GCloudVoiceErr.GCLOUD_VOICE_SUCC then
		self:StartApolloMicTimer()
	end

	return nRet
end

function ChatMgr:StopApolloVoice()
	self:StopApolloMicTimer()
	local nRet = ChatRoomMgr.StopRecord();
	Log("StopApolloVoice", nRet)
end

function ChatMgr:StartApolloMicTimer()
	self:StopApolloMicTimer()
	self.nApolloMicTimer = Timer:Register(math.floor(Env.GAME_FPS*0.3), function ()
		local nVolume = ChatRoomMgr.GetMicLevel();
		nVolume = math.floor(nVolume*30 / 65535)
		UiNotify.OnNotify(UiNotify.emNOTIFY_VOICE_RECORD_VOLUME_CHANG, nVolume)
		return true
	end)
end

function ChatMgr:StopApolloMicTimer()
	if self.nApolloMicTimer then
		Timer:Close(self.nApolloMicTimer);
		self.nApolloMicTimer = nil
	end
end

function ChatMgr:StopRequestApolloVoice(requestPlayVoice)
	if requestPlayVoice and requestPlayVoice.nDownLoadTimer then
		Timer:Close(requestPlayVoice.nDownLoadTimer)
		requestPlayVoice.nDownLoadTimer = nil
	end
end

function ChatMgr:OnStartPlayApolloVoice()
	--[[if self.nPlayApolloVoiceTimer then
		return
	end

	self.nPlayApolloVoiceTimer = Timer:Register(Env.GAME_FPS, function ()

		local nState = ChatRoomMgr.GetPlayVoiceState();
		if nState == 0 then
			self:OnVoicePlayEnd()
			self.nPlayApolloVoiceTimer = nil
			return false
		end

		return true
	end)]]
end

function ChatMgr:IsNeedZoneFileServer(nChannelId)
	local tbChannelInfo = ChatMgr.NeedZoneFileServer[nChannelId]
	if not tbChannelInfo then
		return false
	end

	local nMapTemplateId = me.nMapTemplateId;
	if not nMapTemplateId then
		return false
	end

	if not tbChannelInfo[nMapTemplateId] then
		return false
	end

	return true
end

function ChatMgr:JoinCrossChannel()
	RemoteServer.DoChatRequest("JoinCrossChannel");
end

function ChatMgr:JoinCrossChannelHost()
	RemoteServer.DoChatRequest("JoinCrossChannelHost");
end

function ChatMgr:LeaveCrossChannel()
	RemoteServer.DoChatRequest("LeaveCrossChannel");
end

function ChatMgr:AskCrossHostInfo()
	RemoteServer.DoChatRequest("AskCrossHostInfo");
end

function ChatMgr:AskCrossHostState()
	RemoteServer.DoChatRequest("AskCrossHostState", self.bHasHost or false);
end

function ChatMgr:OnSynCrossHostState(bHasHost)
	self.bHasHost = bHasHost;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST);
end

function ChatMgr:IsHostOnline()
	return self.bHasHost or false;
end

function ChatMgr:OnSyncCrossChannelState(bJoined, nAuth)
	self.bHasJoinedCrossChannel = bJoined;
	self.nCrossChannelJoinedAuth = nAuth
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST);
end

function ChatMgr:OnSyncCurCrossHostInfo(tbHostInfo)
	self.tbCurHostInfo = tbHostInfo;
	self.bHasHost = next(tbHostInfo or {}) and true or false;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST);
end

function ChatMgr:GetCurCrossHostInfo()
	local tbCurHostInfo = self.tbCurHostInfo and self.tbCurHostInfo[1];
	if tbCurHostInfo then
		local tbFollowingMap = ChatMgr:GetCrossHostFollowMap(me);
		return tbCurHostInfo.szName, tbCurHostInfo.nPlayerId, tbCurHostInfo.szHeadUrl, tbFollowingMap[tbCurHostInfo.nPlayerId or 0];
	end
end

function ChatMgr:HasJoinedCrossChannel()
	return self.bHasJoinedCrossChannel or false, self.nCrossChannelJoinedAuth == ChatMgr.ChatCrossAuthType.emHost;
end

function ChatMgr:AskCrossHostListInfo()
	RemoteServer.DoChatRequest("Ask4CrossHostList", self.nHostInfoListVersion);
end

function ChatMgr:OnSynChatHostList(tbHostSchedule, tbHostScheduleDetail, nHostListVersion)
	self.tbHostListInfo = tbHostSchedule;
	for _, tbInfo in ipairs(self.tbHostListInfo) do
		local tbDetail = tbHostScheduleDetail[tbInfo.PlayerId];
		if tbDetail then
			tbInfo.Name = tbDetail.Name;
			tbInfo.HeadUrl = tbDetail.HeadUrl;
			tbInfo.Signature = tbDetail.Signature;
			tbInfo.DateDesc, tbInfo.TimeDesc = unpack(Lib:SplitStr(tbInfo.TimeDesc or "", "\\n"));
		end
	end

	self.nHostInfoListVersion = nHostListVersion;
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST, "HostList");
end

function ChatMgr:GetHostListInfo()
	local nNow = GetTime();
	local tbHostList = {};
	for _, tbInfo in ipairs(self.tbHostListInfo or {}) do
		if not tbInfo.TimeOut or tbInfo.TimeOut > nNow then
			table.insert(tbHostList, tbInfo);
		end
	end

	return tbHostList;
end

function ChatMgr:FollowHostOpt(nHostId, bFollow)
	RemoteServer.DoChatRequest("FollowHostOpt", nHostId, bFollow);
end

function ChatMgr:OnHostFollowChanged()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_CROSS_HOST, "HostList");
end

function ChatMgr:IsPlayingNpcVoice()
	return self.VoiceInfo and self.VoiceInfo.szCurPlayNpcVoice ~= nil
end

function ChatMgr.PlayHelpVoice(szVoicePath)
	if version_th then
		return
	end

	local tbUserSet = Ui:GetPlayerSetting();
	if tbUserSet.bMuteGuideVoice or tbUserSet.fSoundEffectVolume < 0.1 then
		--音效关闭时不播放
		return
	end

	ChatMgr:PlayNpcVoice(szVoicePath)
end

function ChatMgr:PlayNpcVoice(szVoicePath, nVoiceId)
	local data = ReadTxtFile(szVoicePath)
	if not data then
		return
	end

	self:StopVoice();

	--如果StopVoice后立即播放，则PlayEnd异步事件会在这个函数后触发导致把szCurPlayNpcVoice清掉
	self.bForceStartPlay = true
	self.VoiceInfo.szCurPlayNpcVoice = szVoicePath
	self.VoiceInfo.nCurPlayNpcVoiceId = nVoiceId

	Ui.UiManager.PlayVoiceFile(szVoicePath)
	return true
end

function ChatMgr:GetGVoiceParam()
	return self.szGVoiceAppId, self.szGVoiceAppKey, Sdk:GetUid();
end

function ChatMgr:OnTryReJoinRoom()
	self:StartEnterRoom();
end

function ChatMgr:OnSyncGVoiceParam(szGVoiceAppId, szGVoiceAppKey, szGVoiceServerUrl)
	self.szGVoiceAppId = szGVoiceAppId;
	self.szGVoiceAppKey = szGVoiceAppKey;
	self.szGVoiceServerUrl = szGVoiceServerUrl;
end

function ChatMgr:IsGFMEnable()
	return true;
end

function ChatMgr:IsGVideoEnable()
	return true;
end

function ChatMgr:GetGFMParam()
	local szUserName = (me and me.szName) or ""
	local szCharacterName = szUserName;
	local szCharacterId = tostring((me and me.dwID) or 0)
	local tbMyInfo = FriendShip:GetMyPlatInfo();
	local szHeadUrl = tbMyInfo.szHeadSmall or Sdk.szIconUrl;
	local szAreaId = tostring(Sdk:GetServerId())
	local szAreaName = tostring(Sdk:GetServerDesc(Sdk:GetServerId()))
	local nChannelId = tonumber(Sdk:GetCurPlatform())
	local nVipLevel = -1
	local nUserLevel = -1

	local nWindowX = 200
	local nWindowY = 200

	local nWindowMiddleX = 300
	local nWindowMiddleY = 300

	return szUserName, szCharacterId, szCharacterName, szHeadUrl, szAreaId, szAreaName, nChannelId, nVipLevel, nUserLevel,
		nWindowX, nWindowY, nWindowMiddleX, nWindowMiddleY
end

function ChatMgr:JoinRoomComplete(strRoomName, strMemberId, nCode)
	Log("JoinRoomComplete", strRoomName, strMemberId, nCode)
	if ChatMgr.GVoiceCompleteCode.GV_ON_JOINROOM_SUCC == nCode then
		if self:IsChatRoomAvailable() then
			ChatMgr:OnEnterChatRoom();
		end
	else
		if self:IsChatRoomAvailable() then
			local nRoomType = ChatMgr.RoomType.Team;
			if self.ChatRoom.nIsLarge == 1 then
				nRoomType = ChatMgr.RoomType.Large;
			end

			ChatRoomMgr.LeaveRoom(self.ChatRoom.dwRoomHighId, self.ChatRoom.dwRoomLowId, nRoomType);
		end
		ChatMgr:StartEnterRoom();
	end
end

function ChatMgr:QuitRoomComplete(strRoomName, strMemberId, nCode)
	Log("QuitRoomComplete", strRoomName, strMemberId, nCode)
	self.ChatRoom.bSpeakerState = false
	self.ChatRoom.bMicState = false
	self:CheckMusicVolume();
end

function ChatMgr:JoinGFMRoomComplete(strRoomID, strRoomName, nType, nCode)
	Log("JoinGFMRoomComplete", strRoomID, strRoomName, nType, nCode)
	self.ChatRoom.bGFM = true
	ChatRoomMgr.GFMOpenSpeaker()
	self:CheckMusicVolume();
end

function ChatMgr:QuitGFMRoomComplete(strRoomID, strRoomName, nType, nCode)
	Log("QuitGFMRoomComplete", strRoomID, strRoomName, nType, nCode)
	self.ChatRoom.bGFM = false
	self:CheckMusicVolume();
end

function ChatMgr:GFMGiftDialog( bIsShow )
	Log("GFMGiftDialog", tostring(bIsShow))
end

-- // ChatMgr:GFMGiftGiving(293, 1, 33, 666, "szAnchorId", "szRoomId", 2333, "szToken")
function ChatMgr:GFMGiftGiving(nGiftId, nGiftCount, nCoinId, nToTalScore, szAnchorId, szRoomId, nGiftPackId, szToken)
	Log("GFMGiftGiving", nGiftId, nGiftCount, nCoinId, nToTalScore, szAnchorId, szRoomId, nGiftPackId, szToken)
	RemoteServer.DoChatRequest("DoGFMGiftGiving", nGiftId, nGiftCount, nCoinId, nToTalScore, szAnchorId, szRoomId, nGiftPackId, szToken);
end

function ChatMgr:GFMConfirmPayEnd(nCode, szAnchorId, nGiftPackId, nGiftId, nGiftCount, nToTalScore, szToken)
	Log("GFMConfirmPayEnd", nCode, szAnchorId, nGiftPackId, nGiftId, nGiftCount, nToTalScore, szToken);
	ChatRoomMgr.GFMConfirmPayEnd(nCode, szAnchorId, nGiftPackId, nGiftId, nGiftCount, nToTalScore, szToken);
end

function ChatMgr:GFMUpdateBalance()
	local nGold = me.GetMoney("Gold");
	ChatRoomMgr.GFMSetBalance(nGold, ChatMgr.GFM_GOLD_MONEY_ID);
end

function ChatMgr:OnStartGVoiceDownload()
	self.nGVoiceDownloadState = -1
end

function ChatMgr:OnStatusUpdate(code, roomName, memberID)
	Log("ChatMgr:OnStatusUpdate", code, roomName, memberID)
end

function ChatMgr:GetVoiceDownloadState()
	return self.nGVoiceDownloadState or ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE
end

function ChatMgr:OnDownloadRecordFileComplete(nCode, strFilePath, strFileId)
	Log("OnDownloadRecordFileComplete", nCode, strFilePath, strFileId)
	self.nGVoiceDownloadState = ChatMgr.GVoiceCompleteCode.GV_ON_DOWNLOAD_RECORD_DONE
    Pandora:__DoAction({["type"] = "ReturnDownloadResult", ["result"] = nCode, ["filePath"] = strFilePath})
end

function ChatMgr:OnUploadReccordFileComplete(nCode, strFilePath, strFileId)
	Log("OnUploadReccordFileComplete", nCode, strFilePath, strFileId)

	if Ui.fnVoiceCallBack then
		if nCode ~= ChatMgr.GVoiceCompleteCode.GV_ON_UPLOAD_RECORD_DONE or not strFileId or strFileId == "" then
			me.CenterMsg("语音发送失败");
		else
			-- 暂时没有语音的翻译
			Ui.fnVoiceCallBack("", 0, 0, "", ChatRoomMgr.GetVoiceFileTime() * 1000, strFileId)
		end
	end

	Ui.fnVoiceCallBack = nil;
	Pandora:__DoAction({["type"] = "ReturnUploadResult", ["result"] = nCode, ["fileID"] = strFileId, ["filePath"] = strFilePath})
	Pandora:OnUploadReccordFileComplete(strFilePath)
end

function ChatMgr:OnPlayRecordFilComplete(nCode, strFilePath)
	Log("OnPlayRecordFilComplete", nCode, strFilePath)
	Pandora:OnPlayRecordFilComplete(nCode, strFilePath)
	self:OnVoicePlayEnd()
end

function ChatMgr:OnSwitchNpcGuideVoice()
	local tbUserSet = Ui:GetPlayerSetting();
	tbUserSet.bMuteGuideVoice = (not tbUserSet.bMuteGuideVoice)
	if tbUserSet.bMuteGuideVoice and ChatMgr:IsPlayingNpcVoice() then
		ChatMgr:StopVoice();
	end
end

function ChatMgr:ShowSpecialItem(tbInfo)
	local nItemId = tbInfo.nItemId or 0
	local nTemplateId = tbInfo.nTemplate or 0

	local szClass = ""
	local pItem = KItem.GetItemObj(nItemId)
	if pItem then
    	szClass = pItem.szClass
    end

    local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId)
    if tbBaseInfo then
	    szClass = tbBaseInfo.szClass
	end

	local fn = self.tbSpecialItemFns[szClass]
	if not fn then
		return false
	end

	fn(tbInfo)
	return true
end

function ChatMgr:StartGFM()
	if not version_tx then
		return
	end
	--[[if self.bStartGFM then
		return
	end

	self.bStartGFM = true]]

	if self:IsChatRoomAvailable() then
		self:LeaveCurChatRoom()
	end

	ChatRoomMgr.GFMShowLive()
end

function ChatMgr:CloseGFM()
	if not version_tx then
		return
	end
	--[[if not self.bStartGFM then
		return
	end

	self.bStartGFM = false]]

	ChatRoomMgr.GFMCloseLive()
end

function ChatMgr:GFMEntrySwitch()
	if Client:IsCloseIOSEntry() then
		return false
	end
	return true
end

function ChatMgr:OnApplyMessageKeyComplete(nCode)
	if nCode ~= ChatMgr.GVoiceCompleteCode.GV_ON_MESSAGE_KEY_APPLIED_SUCC then
	end
	Log("ChatMgr OnApplyMessageKeyComplete:", nCode)
end

ChatMgr.tbChatRightPopupChannelType = {};
function ChatMgr:SetChatRightPopupChannelType( nChannelId, szType )
	self.tbChatRightPopupChannelType[nChannelId] = szType
end
