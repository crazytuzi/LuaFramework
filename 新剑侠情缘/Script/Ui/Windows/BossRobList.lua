local tbUi = Ui:CreateClass("BossRobList");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_BOSS_DATA, self.UpdateRobList, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	Boss:UpdateRobList();
end

function tbUi:OnOpenEnd()
	--self:UpdateRobList();
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
	self.tbAllItemsPanel = nil;
	if self.nUpdateTimer then
		Timer:Close(self.nUpdateTimer);
		self.nUpdateTimer = nil;
	end
end

function tbUi:UpdateRobList(szType)
	if szType and szType ~= "RobList" then
		return;
	end

	local tbItems = Boss:GetRobList() or {};
	self.tbAllItemsPanel = {};
	local fnSetItem = function (itemObj, nIndex)
		local tbItem = tbItems[nIndex];
		itemObj:Init(tbItem);
		self.tbAllItemsPanel[itemObj] = tbItem;
	end

	self.ScrollView:Update(#tbItems, fnSetItem);
	self.ScrollView:GoBottom();

	if self.nUpdateTimer then
		Timer:Close(self.nUpdateTimer);
	end

	self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.UpdateRobTime, self);
end

function tbUi:UpdateRobTime()
	for pItem, tbItem in pairs(self.tbAllItemsPanel) do
		pItem:Init(tbItem);
	end
	return true;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("BossRobList");
end


local tbItem = Ui:CreateClass("BossRobItem");

function tbItem:Init(tbPlayerData)
	self.tbPlayerData = tbPlayerData;
	self.pPanel:Label_SetText("TxtScore", math.floor(tbPlayerData.nScore));

	local tbHonorInfo = Player.tbHonorLevelSetting[tbPlayerData.nHonorLevel];
	self.pPanel:SetActive("TxtName2", not tbHonorInfo);
	self.pPanel:SetActive("TxtName", tbHonorInfo and true);

	local szName = tbPlayerData.szName;
	if tbPlayerData.nServerId then
		szName = string.format("%s［%s］", szName, Sdk:GetServerDesc(tbPlayerData.nServerId));
	end

	self.pPanel:Label_SetText("TxtName", szName);
	self.pPanel:Label_SetText("TxtName2", szName);
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbPlayerData.nHonorLevel)
	self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix or "", Atlas);

	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbPlayerData.nPortrait);
	self.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);
	self.pPanel:Label_SetText("lbLevel", tbPlayerData.nLevel);
	self.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbPlayerData.nFaction));

	----tbPartner---------------
	for i = 1, 2 do
		local tbPartner = tbPlayerData.tbPartner and tbPlayerData.tbPartner[i];
		if tbPartner then
			self.pPanel:SetActive("PartnerPortrait" .. i, true);
			local nPartnerId, nLevel = unpack(tbPartner);
			self["PartnerPortrait" .. i]:SetPartnerById(nPartnerId, nLevel);
		else
			self.pPanel:SetActive("PartnerPortrait" .. i, false);
		end
	end

	local szRelation = "陌生人";
	local bRobEnable = true;
	if tbPlayerData.nPlayerId == me.dwID then
		szRelation = "自己";
		bRobEnable = false;
	elseif tbPlayerData.nKinId == me.dwKinId and me.dwKinId ~= 0 then
		szRelation = "家族";
		bRobEnable = false;
	elseif FriendShip:IsFriend(me.dwID, tbPlayerData.nPlayerId) then
		szRelation = "好友";
		bRobEnable = false;
	elseif FriendShip:IsHeIsMyEnemy(me.dwID, tbPlayerData.nPlayerId) then
		szRelation = "仇人";
	end

	if tbPlayerData.nServerId and tbPlayerData.nServerId ~= SERVER_ID then
		szRelation = "陌生人";
		bRobEnable = true;
	end

	self.pPanel:Label_SetText("TxtRelation", szRelation);
	self.pPanel:Button_SetEnabled("BtnFight", bRobEnable);

	self:SetRank(tbPlayerData.nRank);
	self:UpdateTime();
end

function tbItem:UpdateTime()
	local nLeftTime = self.tbPlayerData.nProtectRobTime - GetTime();
	local szBtnFight = nLeftTime > 0 and Lib:TimeDesc3(nLeftTime) or "抢 夺";
	self.pPanel:Label_SetText("TxtFightBtn", szBtnFight);
end

local tbRankExp = {
	{1, "ImgTop1"},
	{2, "ImgTop2"},
	{3, "ImgTop3"},
	{10, "ImgTop10"},
	{999, "ImgTopX"},
}

function tbItem:SetRank(nRank)
	for _, tbExp in ipairs(tbRankExp) do
		self.pPanel:SetActive(tbExp[2], false);
	end

	for _, tbExp in ipairs(tbRankExp) do
		if nRank <= tbExp[1] then
			self.pPanel:SetActive(tbExp[2], true);
			self.pPanel:Label_SetText("TxtTop10", nRank);
			self.pPanel:Label_SetText("TxtTopX", nRank);
			break;
		end
	end
end

tbItem.tbOnClick = tbItem.tbOnClick or {};

function tbItem.tbOnClick:BtnFight()
	local nLeftTime = self.tbPlayerData.nProtectRobTime - GetTime();
	if nLeftTime > 0 then
		me.CenterMsg(string.format("被抢夺的保护时间还剩下%d秒", nLeftTime));
		return;
	end

	Boss:Rob(self.tbPlayerData);
	Ui:CloseWindow("BossRobList");
end
