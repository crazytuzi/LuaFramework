local tbUi = Ui:CreateClass("FriendRankPanel");

function tbUi:Init()
	local szTitle = Sdk:IsLoginByQQ() and "QQ好友" or "微信好友";
	szTitle = Sdk:HasEfunRank() and "FB好友" or szTitle;

	self.pPanel:Label_SetText("Title", szTitle);
	self:Update();

	if Sdk:HasEfunRank() then
		Sdk:QueryFriendsInfo();
	end

	if version_xm then
		self.pPanel:SetActive("BtnInviteFriend", false);
		self.pPanel:SetActive("BtnOnekeyFriend", false);
	end

	self.pPanel:SetActive("BtnReunion", version_tx and FriendRecall:IsInProcess());
end

function tbUi:Update()
	local tbFriendsInfo = FriendShip:GetPlatFriendsInfo() or {};
	local tbFirstInfo = tbFriendsInfo[1] or {};
	if not tbFirstInfo.nPower then
		Sdk:QueryRankServerInfo();
	end

	table.sort(tbFriendsInfo, function (a, b)
		if a.nPower == b.nPower then
			if a.nLevel == b.nLevel then
				return a.szNickName < b.szNickName;
			end
			return a.nLevel > b.nLevel;
		end
		return a.nPower > b.nPower;
	end);

	local tbServerMap = Client:GetDirFileData("ServerMap" .. Sdk:GetCurPlatform());
	local pScrollView = self.ScrollViewFriendsRank
	local fnSetItem = function (itemObj, idx)
		pScrollView:CheckShowGridMax(itemObj, idx)
		local tbItem = tbFriendsInfo[idx];

		if idx < 4 then
			itemObj.pPanel:SetActive("RankLabel", false)
			itemObj.pPanel:SetActive("RankIcon", true)
			itemObj.pPanel:Sprite_SetSprite("RankIcon", "Rank_top" .. idx)
		else
			itemObj.pPanel:SetActive("RankLabel", true)
			itemObj.pPanel:SetActive("RankIcon", false)
			itemObj.pPanel:Label_SetText("RankLabel", idx)
		end

		itemObj.pPanel:Texture_SetUrlTexture("Head", tbItem.szHeadSmall, false);
		itemObj.pPanel:Label_SetText("Col3Name", ChatMgr:CutMsg(tbItem.szNickName, 10));
		local szSerName = tbServerMap[tbItem.nServerId or 0]
		if szSerName then
			szSerName = string.format("[9effe9]%s[-1]", szSerName)
			if tbItem.nServerId == SERVER_ID then
				szSerName = szSerName .. "\n(同服)"
			end
		else
			szSerName = "其它大区"
		end
		itemObj.pPanel:Label_SetText("Service", szSerName);
		itemObj.pPanel:Toggle_SetChecked("Main", false);

		local szName = "";
		if tbItem.szName and tbItem.szName ~= "" then
			if version_tx then
				szName = string.format("%s  %d级", tbItem.szName, tbItem.nLevel or 0);
			else
				szName = string.format("%s Lv.%d", tbItem.szName, tbItem.nLevel or 0);
			end
		end
		itemObj.pPanel:Label_SetText("Col4Name", szName);
		itemObj.pPanel:Label_SetText("Col4Num", tbItem.nPower or 0);

		local bShowGameCenter = Sdk.Def.tbPlatformIcon[tbItem.nLaunchPlat or 0] and not Sdk:IsOuterChannel();
		itemObj.pPanel:SetActive("GameCenter", tbItem.nLaunchPlat == Sdk.ePlatform_QQ and bShowGameCenter);
		itemObj.pPanel:SetActive("GameCenterIcon2", tbItem.nLaunchPlat == Sdk.ePlatform_Weixin and bShowGameCenter);

		local bShowQQVip = tbItem.nQQVipType and tbItem.nQQVipType ~= Player.QQVIP_NONE and not Sdk:IsOuterChannel();
		itemObj.pPanel:SetActive("QQicon", bShowQQVip);
		if bShowQQVip then
			itemObj.pPanel:Sprite_SetSprite("QQicon", tbItem.nQQVipType == Player.QQVIP_VIP and "QQvip" or "QQsvip");
		end

		local bGiven = FriendShip:GetFriendPresentGiven(tbItem.szOpenId);
		itemObj.pPanel:SetActive("HaveGive", bGiven);
		itemObj.pPanel:SetActive("BtnGive", not bGiven and tbItem.szOpenId ~= Sdk:GetUid());

		itemObj.BtnGive.pPanel.OnTouchEvent = function ()
			local tbMyInfo = FriendShip:GetMyPlatInfo();
			Sdk:SendFriendRankGift(tbItem.szOpenId, tbItem.nServerId, tbItem.nPlayerId, tbMyInfo.szNickName or me.szName);
		end;

		local fnTouchWXIcon = function ()
			if bShowGameCenter then
				local tbPos = itemObj.pPanel:GetRealPosition("Main");
				Ui:OpenWindowAtPos("TxtWeixinGameCenter", tbPos.x, tbPos.y - 35);
			end
		end

		itemObj.GameCenterIcon2.pPanel.OnTouchEvent = fnTouchWXIcon;
	end

	pScrollView:Update(tbFriendsInfo, fnSetItem, 7, self.BackTop3, self.BackBottom3);
end


tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnInviteFriend()
	if Sdk:IsLoginByQQ() then
		Sdk:TlogShare("Invite");
		Sdk:ShareUrl("QQ");
	elseif Sdk:IsLoginByWeixin() then
		Sdk:TlogShare("Invite");
		Sdk:ShareUrl("WX");
	elseif Sdk:HasEfunRank() then
		Ui:OpenWindow("FBInvitationPanel");
	else
		me.CenterMsg("无法邀请好友");
	end
end

function tbUi.tbOnClick:BtnOnekeyFriend()
	local tbInviteList = {}
	local tbFriendsInfo = FriendShip:GetPlatFriendsInfo() or {};
	for i,v in ipairs(tbFriendsInfo) do
		if v.nServerId == SERVER_ID then
			if not FriendShip:IsFriend(me.dwID, v.nPlayerId) and me.dwID ~= v.nPlayerId then
				table.insert(tbInviteList, v.nPlayerId)
			end
		end
	end

	if not next(tbInviteList) then
		me.CenterMsg("当前已没有可邀请好友")
		return
	end

	for i,nPlayerId in ipairs(tbInviteList) do
		if not FriendShip:IsRequestedAdd(me.dwID, nPlayerId) then
			RemoteServer.RequestAddFriend(nPlayerId)
		end
	end
	me.CenterMsg("添加好友请求已发出")
end

function tbUi.tbOnClick:BtnReunion()
	Ui:OpenWindow("FriendRecallPanel")
end


local tbFriendsRankGrid = Ui:CreateClass("FriendsRankGrid");
tbFriendsRankGrid.tbOnDrag =
{
	Main = function (self, szWnd, nX, nY)
		self.pScrollView:OnDragList(nY)
	end	;
}

tbFriendsRankGrid.tbOnDragEnd =
{
	Main = function (self)
		self.pScrollView:OnDragEndList()
	end	;
}