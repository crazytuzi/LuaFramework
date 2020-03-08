-- 好友协助养护界面

local tbUi = Ui:CreateClass("PlantHelpCurePanel");
tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnOpen()
	RemoteServer.TryGetFriendCanCure();
	self.pPanel:Label_SetText("Time", string.format("[92D2FF]剩余协助养护次数：[-]%d", DegreeCtrl:GetDegree(me, "PlantHelpCure")));
	self:Refresh();
end

function tbUi:Refresh()
	local tbData = HousePlant.tbFriendPlant;
	local nCount = tbData and #tbData or 0;	
	if nCount <= 0 then
		self.pPanel:SetActive("ScrollView", false);
		self.pPanel:SetActive("Tip", true);
		self.pPanel:SetActive("TopAndBotContrl", false)
		return;
	end

	self.pPanel:SetActive("TopAndBotContrl", true)
	self.pPanel:SetActive("Tip", false);
	self.pPanel:SetActive("ScrollView", true);

	local pScrollView = self.ScrollView
	local fnSetFriend = function (tbPanel, nIndex)
		pScrollView:CheckShowGridMax(tbPanel, nIndex)
		tbPanel:SetData(tbData[nIndex]);
	end
	pScrollView:Update(nCount, fnSetFriend, 5, self.BackTop, self.BackBottom);
	pScrollView:GoTop();
end

function tbUi:OnSyncData()
	self:Refresh();
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_FRIEND_PLANT, self.OnSyncData, self },
	};
	return tbRegEvent;
end


local tbGrid = Ui:CreateClass("PlantHelpCureGrid");
tbGrid.tbOnClick = tbGrid.tbOnClick or {};

tbGrid.tbOnClick.BtnVisit = function (self)
	RemoteServer.GotoLand(self.dwPlayerId);
end

tbGrid.tbOnDrag =
{
	Main = function (self, szWnd, nX, nY)
		self.pScrollView:OnDragList(nY)
	end	;
}

tbGrid.tbOnDragEnd =
{
	Main = function (self)
		self.pScrollView:OnDragEndList()
	end	;
}


function tbGrid:SetData(tbData)
	self.dwPlayerId = tbData.dwPlayerId;
	local tbFriend = FriendShip:GetFriendDataInfo(self.dwPlayerId);
	if tbFriend then
		self.pPanel:Label_SetText("Name", tbFriend.szName);
		self.pPanel:Label_SetText("lbLevel", tbFriend.nLevel);

		local SpFaction = Faction:GetIcon(tbFriend.nFaction);
		self.pPanel:Sprite_SetSprite("SpFaction",  SpFaction);

		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbFriend.nPortrait);
		self.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas);

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbFriend.nHonorLevel)
		self.pPanel:SetActive("PlayerTitle", false);
		if ImgPrefix then
			self.pPanel:SetActive("PlayerTitle", true);
			self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		end
	end
	
	local tbSetting = HousePlant.tbSickStateSetting[tbData.nState];
	self.pPanel:Label_SetText("State", tbSetting and tbSetting.szDesc or "--");
end