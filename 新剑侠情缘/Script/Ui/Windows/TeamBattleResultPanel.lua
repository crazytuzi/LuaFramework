
local tbUi = Ui:CreateClass("TeamBattleResultPanel");

function tbUi:OnOpen(nFloor, tbResult, tbAward, nAddImityCount, nAwardItemCount, nAddHonor)
	self.nMyId = me.nLocalServerPlayerId or me.dwID
	self.nAddImityCount = nAddImityCount;
	self.tbPlayerInfo = {};
	for nPlayerId, tb in pairs(tbResult) do
		local tbInfo = {
			nPlayerId = nPlayerId;
			szName = tb[1],
			nPortrait = tb[2],
			nFaction = tb[3],
			nLevel = tb[4],
			nTeamBattleTotalKill = tb[5],
			nTeamBattleTotalDeath = tb[6],
		};
		
		if nPlayerId == self.nMyId then
			table.insert(self.tbPlayerInfo, 1, tbInfo);
		else
			table.insert(self.tbPlayerInfo, tbInfo);
		end
	end
	self.pPanel:Label_SetText("level", string.format("第%s层", nFloor));

	local szMsg = "";
	if nAwardItemCount > 0 then
		szMsg = string.format("达到%s层，获得%s点荣誉，自动兑换%s个宝箱", nFloor, nAddHonor, nAwardItemCount)
	else
		szMsg = string.format("达到%s层，获得%s点荣誉", nFloor, nAddHonor)
	end
	self.pPanel:Label_SetText("ContentTxt", szMsg);
	self.tbAward = tbAward;
	self:Update();
end

function tbUi:Update()
	for i = 1, 3 do
		local tbPlayerData = self.tbPlayerInfo[i];
		if not tbPlayerData then
			self.pPanel:SetActive("Player" .. i, false);
		else
			local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbPlayerData.nPortrait);
			self.pPanel:Sprite_SetSprite("SpRoleHead" .. i, szHead, szAtlas);
			self.pPanel:Label_SetText("lbLevel" .. i, tbPlayerData.nLevel);
			self.pPanel:Sprite_SetSprite("SpFaction" .. i, Faction:GetIcon(tbPlayerData.nFaction));

			self.pPanel:Label_SetText("name" .. i, tbPlayerData.szName);
			self.pPanel:Label_SetText("KillCount" .. i, tbPlayerData.nTeamBattleTotalKill);
			self.pPanel:Label_SetText("DeathCount" .. i, tbPlayerData.nTeamBattleTotalDeath);
			self.pPanel:Label_SetText("FriendTxt" .. i, string.format("+%s", self.nAddImityCount));

			self.pPanel:SetActive("FriendTxt" .. i, self.nMyId ~= tbPlayerData.nPlayerId);
			self.pPanel:SetActive("BtnReceive" .. i, self.nMyId ~= tbPlayerData.nPlayerId and not FriendShip:IsFriend(self.nMyId, tbPlayerData.nPlayerId));
			self.pPanel:Button_SetEnabled("BtnReceive" .. i, true);
		end
	end

	for i = 1, 3 do
		local tbInfo = self.tbAward[i];
		local itemframe = self["itemframe" .. i];
		if tbInfo then
			itemframe.pPanel:SetActive("Main", true);
			itemframe:SetGenericItem(tbInfo);
			itemframe.fnClick = itemframe.DefaultClick;
		else
			itemframe:Clear();
			itemframe.pPanel:SetActive("Main", false);
		end
	end
end

function tbUi:OnMakeFriend(nIdx)
	local tbPlayerData = self.tbPlayerInfo[nIdx];
	if not tbPlayerData then
		return;
	end

	FriendShip:RequetAddFriend(tbPlayerData.nPlayerId, nil, true);
	self.pPanel:Button_SetEnabled("BtnReceive" .. nIdx, false);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

for i = 1, 3 do
	tbUi.tbOnClick["BtnReceive" .. i] = function (self)
		self:OnMakeFriend(i);
	end
end
