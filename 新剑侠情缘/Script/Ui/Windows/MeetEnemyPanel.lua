
local tbUi = Ui:CreateClass("MeetEnemyPanel");

function tbUi:OnOpen(tbRole)
	local szIcon, szIconAtlas = PlayerPortrait:GetSmallIcon(tbRole.nPortrait)
	self.pPanel:Sprite_SetSprite("SpRoleHead", szIcon, szIconAtlas); 
	self.pPanel:Label_SetText("lbLevel", tbRole.nLevel) 
	local szFactionIcon = Faction:GetIcon(tbRole.nFaction);
	self.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbRole.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("PlayerTitle", true);
		self.pPanel:Sprite_Animation("PlayerTitle",  ImgPrefix, Atlas);			

		self.pPanel:SetActive("TxtCaptainName", true)
		self.pPanel:SetActive("TxtCaptainName2", false)
		self.pPanel:Label_SetText("TxtCaptainName", tbRole.szName)
	else
		self.pPanel:SetActive("PlayerTitle", false);

		self.pPanel:SetActive("TxtCaptainName", false)
		self.pPanel:SetActive("TxtCaptainName2", true)
		self.pPanel:Label_SetText("TxtCaptainName2", tbRole.szName)
	end

	if FriendShip:IsHeIsMyEnemy(me.dwID, tbRole.dwID) then
		self.pPanel:Label_SetText("strengthenTip", "[fe6464]*对方是你的仇人[-1]")
	else
		self.pPanel:Label_SetText("strengthenTip", "[C8C8C8]*攻击后将会成为对方的仇人[-1]")
	end
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnAttack = function (self)
	Ui:CloseWindow(self.UI_NAME)
	RemoteServer.MapExploreAttackEnemy()
end

tbUi.tbOnClick.BtnLeave = function (self)
	Ui:CloseWindow(self.UI_NAME)
	MapExplore.bCanMove = true
	MapExplore:CheckLeave();
end