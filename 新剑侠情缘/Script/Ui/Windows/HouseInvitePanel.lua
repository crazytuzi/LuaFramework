-- 养护界面

local tbUi = Ui:CreateClass("HouseInvitePanel");
tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen()
	local nCurTime = GetTime();
	if not self.nRequestTime or self.nRequestTime + 10 < nCurTime then
		self.nRequestTime = nCurTime;
		House.tbFriendList = {};
		RemoteServer.TryGetHouseFriendList();
	end
	self:Refresh();
end

function tbUi:Refresh()
	local tbData = House.tbFriendList;
	local nCount = tbData and #tbData or 0;	
	if nCount <= 0 then
		self.pPanel:SetActive("Tip", true);
		self.pPanel:SetActive("ScrollView", false);
		return;
	end

	self.pPanel:SetActive("Tip", false);
	self.pPanel:SetActive("ScrollView", true);

	local fnSetFriend = function (tbPanel, nIndex)
		local tbFriendData = FriendShip:GetFriendDataInfo(tbData[nIndex].dwPlayerId);
		if tbFriendData then
			tbPanel:SetData({ tbData = tbFriendData, bCanInvite = tbData[nIndex].bCanInvite });
		end
	end
	self.ScrollView:Update(nCount, fnSetFriend);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_HOUSE_FRIEND_LIST, self.Refresh },
	};

	return tbRegEvent;
end

local tbGrid = Ui:CreateClass("HouseInvitePanelGrid");
tbGrid.tbOnClick = tbGrid.tbOnClick or {};

tbGrid.tbOnClick.BtnInvite = function (self)
	RemoteServer.InviteCheckIn(self.dwPlayerId);
end

function tbGrid:SetData(tbFriend)
	self.pPanel:SetActive("BtnInvite", tbFriend.bCanInvite);
	self.pPanel:SetActive("Txt", not tbFriend.bCanInvite);

	local tbData = tbFriend.tbData;
	self.dwPlayerId = tbData.dwID;

	self.pPanel:Label_SetText("lbRoleName", tbData.szName);
	self.pPanel:Label_SetText("lbLevel", tbData.nLevel);

	local SpFaction = Faction:GetIcon(tbData.nFaction);
	self.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);

	local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbData.nPortrait);
	self.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas);

	self.pPanel:SetActive("PlayerTitle", false);
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbData.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("PlayerTitle", true);
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
	end
end
