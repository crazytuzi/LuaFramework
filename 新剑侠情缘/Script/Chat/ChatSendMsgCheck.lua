
local tbFunCheckSend = {
	[ChatMgr.ChannelType.Color] = function ( ... )
		local nColorTimes = me.GetUserValue(ChatMgr.COLOR_MSG_USER_VALUE_GROUP, ChatMgr.COLOR_MSG_USER_VALUE_KEY);
		local bHasCount = nColorTimes > 0;
		if not bHasCount then
			Ui:OpenWindow("CommonShop","Treasure", "tabAllShop", ChatMgr.nSpeakerColorItemId);
		end
		return bHasCount, "您在彩聊频道的发言次数不足。";
	end;

	[ChatMgr.ChannelType.Team] = function ()
		local bHasTeam = TeamMgr:HasTeam();
		return bHasTeam, "请先加入队伍";
	end;

	[ChatMgr.ChannelType.Kin] = function ()
		local bHasKin = Kin:HasKin();
		return bHasKin, "请先加入家族";
	end;

	[ChatMgr.ChannelType.Public] = function ()
		local bHasCount = ChatMgr:GetPublicChatLeftCount(me) > 0;
		if not bHasCount then
			Ui:OpenWindow("CommonShop","Treasure", "tabAllShop", ChatMgr.nSpeakerPublicItemId);
		end
		return bHasCount, "您在世界频道的发言次数不足。";
	end;

	[ChatMgr.ChannelType.Cross] = function ()
		if not version_tx then
			return false, "当前版本不存在该频道";
		end

		if not ChatMgr:HasJoinedCrossChannel() then
			return false, "收听主播频道后才可发言";
		end

		local bHasCount = ChatMgr:GetCrossChatLeftCount(me) > 0;
		if not bHasCount then
			Ui:OpenWindow("CommonShop","Treasure", "tabAllShop", ChatMgr.nSpeakerCrossItemId);
		end
		return bHasCount, "您在主播频道的发言次数不足。";
	end;

	[ChatMgr.ChannelType.Private] = function ()
		return true;
	end;

	[ChatMgr.ChannelType.Friend] = function ()
		return true;
	end;

	[ChatMgr.ChannelType.Nearby] = function ()
		return Map:CanNearbyChat(me.nMapTemplateId), "此地图不可附近聊天";
	end;
};

function ChatMgr:GetCd(nChannelType)
	if nChannelType == ChatMgr.nChannelFriendName then
		nChannelType = ChatMgr.ChannelType.Private
	end
	if not me.tbLastChatCDTimes then
		me.tbLastChatCDTimes = {};
	end

	local now = GetTime();
	if not me.tbLastChatCDTimes[nChannelType] then
		return 0;
	end

	local nLeftTime = me.tbLastChatCDTimes[nChannelType] - now;
	return nLeftTime;
end

function ChatMgr:GetOpenLevel(nChannelType)
	local tbChannelSetting = self.tbChannelSetting[nChannelType] or {};
	return tbChannelSetting.nLevel or 0;
end

function ChatMgr:CheckSendMsg(nChannelType, szMsg, bOnlyCheck, uFileIdHigh, uFileIdLow, strFilePath, nVoiceTime, szApolloVoiceId)
	if nChannelType == ChatMgr.nChannelFriendName then
		nChannelType = ChatMgr.ChannelType.Private
	end
	local tbChannelSetting = self.tbChannelSetting[nChannelType];
	if not tbChannelSetting and nChannelType < self.nDynChannelBegin  then
		Log("Wrong channel Id:", nChannelType, szMsg);
		return false;
	end

	if nVoiceTime and nVoiceTime < 1000 then
		me.CenterMsg("语音输入时间过短");
		return false;
	end

	local isValidVoice = ChatMgr:CheckVoiceSendEnable() and ChatMgr:IsValidVoiceMsg(nChannelType, uFileIdHigh, uFileIdLow, strFilePath, szApolloVoiceId)

	if (not szMsg or szMsg == "") and not isValidVoice  then
		me.CenterMsg("请输入聊天内容");
		return false;
	end

	if tbChannelSetting and me.nLevel < tbChannelSetting.nLevel then
		me.CenterMsg(string.format("%d级后开放%s发言", tbChannelSetting.nLevel, tbChannelSetting.szChannelName));
		return false;
	end

	if Lib:Utf8Len(szMsg) > ChatMgr.nMaxMsgLengh then
		me.CenterMsg("聊天字数超出上限");
		return false;
	end

	local nLeftTime = self:GetCd(nChannelType);
	if nLeftTime > 0 then
		me.CenterMsg(string.format("%s还需%d秒后才能再发言", tbChannelSetting and tbChannelSetting.szChannelName or "", nLeftTime));
		return false;
	end

	local bRet = true
	local szReason = ""
	if tbFunCheckSend[nChannelType] then
		bRet, szReason = tbFunCheckSend[nChannelType]();
	end
	if not bRet then
		me.CenterMsg(szReason);
	elseif not bOnlyCheck then
		if tbChannelSetting then
			local nCd = tbChannelSetting.nCd
			if nChannelType == ChatMgr.ChannelType.Public then
				local nVipNeedLevel, nVIpCdTime = unpack(Recharge.tbVipExtSetting["public_chat"])
				if me.GetVipLevel() >= nVipNeedLevel then
					nCd = nVIpCdTime
				end
			end
			me.tbLastChatCDTimes[nChannelType] = GetTime() + nCd;
		elseif nChannelType == DrinkHouse.nChannelId then
			me.tbLastChatCDTimes[nChannelType] = GetTime() + DrinkHouse.tbDef.CHAT_SEND_CD;
		else
			me.tbLastChatCDTimes[nChannelType] = 0;
		end

	end
	return bRet;
end

-----------------------------------------------------------------------------------------------------
local tbFunCheckLink = {
	[ChatMgr.LinkType.Item] = function (szMsg, linkInfo)
		local szName = "";
		local nItemId = linkInfo;
		local nTemplateId = 0;
		if type(linkInfo) == "table" then
			nItemId = linkInfo[1];
			nTemplateId = linkInfo[2];
		end

		if nItemId and nItemId ~= 0 then
			local pItem = KItem.GetItemObj(nItemId);
			szName = pItem and Item:GetDBItemShowInfo(pItem);
		else
			szName = Item:GetItemTemplateShowInfo(nTemplateId, me.nFaction, me.nSex);
		end

		local szItemName = string.match(szMsg, "^<(.+)%>");
		return szItemName == szName;
	end;

	[ChatMgr.LinkType.Position] = function (szMsg, linkParam)
		local szMapName, nPosX, nPosY = string.match(szMsg, "%<(.+)%((%d+),(%d+)%)%>");
		local nMapTemplateId = (type(linkParam) == "table") and linkParam[4];

		if nMapTemplateId and Map:IsHouseMap(nMapTemplateId) then
			return true;
		end

		if ImperialTomb:GetMapType(nMapTemplateId) then
		 	return true;
		end

		return nMapTemplateId and szMapName == Map:GetMapDescInChat(nMapTemplateId);
	end;

	[ChatMgr.LinkType.Partner] = function (szMsg, nPartnerId)
		local szPartner = string.match(szMsg, "^%<(.+)%>");
		local tbPartnerInfo = me.GetPartnerInfo(nPartnerId);
		return tbPartnerInfo and (tbPartnerInfo.szName == szPartner);
	end;
	[ChatMgr.LinkType.PartnerCard] = function (szMsg, tbCard)
		local nCardId = tbCard and tbCard.nCardId
		local tbCardInfo = PartnerCard:GetCardInfo(nCardId or 0)
		if  not tbCardInfo then
			return
		end
		local bHave = PartnerCard:IsHaveCard(me, nCardId)
		if not bHave then
			return
		end
		local szCardName = string.match(szMsg, "^%<(.+)%>");
		return tbCardInfo.szName == szCardName;
	end;

	[ChatMgr.LinkType.Team] = function (szMsg, linkParam)
		local szTeamInfo = string.match(szMsg, "^%<(.+)%>");
		return szTeamInfo and linkParam[2] == TeamMgr:GetTeamId();
	end;

	[ChatMgr.LinkType.Achievement] = function (szMsg, nParam)
		local szParam = string.match(szMsg, "^%<(.+)%>")
		if not szParam then
			return
		end

		local nId     = math.floor(nParam / 100);
		local nLevel  = math.floor(nParam % 100);
		local szKind  = Achievement:GetKindById(nId);
		if not szKind then
			return
		end

		local szTitle = Achievement:GetTitleAndDesc(szKind, nLevel)
		szTitle = string.format("成就：%s", szTitle)
		if szTitle ~= szParam then
			return
		end

		return Achievement:CheckCompleteLevel(me, szKind, nLevel)
	end;
}

function ChatMgr:CheckLinkAvailable(szMsg, nLinkType, linkParam)
	if not tbFunCheckLink[nLinkType] then
		return false;
	end

	return tbFunCheckLink[nLinkType](szMsg, linkParam);
end
