
Require("CommonScript/Player/PlayerDef.lua");
local tbUi = Ui:CreateClass("HelperList");

tbUi.tbHonorInfo = Player.tbHonorLevelSetting;

function tbUi:OnOpen(fnOnSelect)
	self.fnOnSelect = fnOnSelect;
	self.List.pPanel:ScrollViewGoTop();

	if Helper:Update() then
		self:Update();
	end
end

function tbUi:OnClose()
	self.nSelectRoleId = nil;
end

function tbUi:Update()
	self.tbAllInfo = {};
	for _, tbInfo in ipairs(Helper.tbFriendList or {}) do
		table.insert(self.tbAllInfo, tbInfo);
	end

	for _, tbInfo in ipairs(Helper.tbStranger or {}) do
		table.insert(self.tbAllInfo, tbInfo);
	end

	for i = 1, (self.nOtherNpcCount or 0) do
		local tbInfo = {};
		tbInfo.szName = Player:GetRandomName();
		tbInfo.nLevel = me.nLevel;
		tbInfo.bIsNpc = true;
		tbInfo.nHonorLevel = 0;
		tbInfo.nImity = 0;
		tbInfo.nFaction = MathRandom(4);
		table.insert(self.tbAllInfo, tbInfo);
	end

	local function fnOnSelect(ItemObj)
		self:SelectHelper(ItemObj.tbHelperInfo);
	end

	local function fnSetItem(ItemObj, index)
		local tbInfo = self.tbAllInfo[index] or {};
	
		ItemObj.tbHelperInfo = tbInfo;
		ItemObj.pPanel:Label_SetText("lbLevel", tbInfo.nLevel or me.nLevel);
		ItemObj.pPanel:Label_SetText("Relationship", (tbInfo.nImity or 0) > 0 and "好友" or "陌生人");
		
		local szPortrait, szAltas = PlayerPortrait:GetSmallIcon(tbInfo.nPortrait)
		ItemObj.pPanel:Sprite_SetSprite("SpRoleHead", szPortrait, szAltas);

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel or 0)
		if not ImgPrefix then
			ItemObj.pPanel:Label_SetText("PlayerName2", tbInfo.szName or "--");
			ItemObj.pPanel:SetActive("PlayerName", false);
			ItemObj.pPanel:SetActive("PlayerName2", true);
		else
			ItemObj.pPanel:Label_SetText("PlayerName", tbInfo.szName or "--");
			ItemObj.pPanel:SetActive("PlayerName", true);
			ItemObj.pPanel:SetActive("PlayerName2", false);
			ItemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		end

		local szFactionIcon = Faction:GetIcon(tbInfo.nFaction);
		ItemObj.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon);

		local nAward = (tbInfo.nImity or 0) > 0 and Helper.FRIEND_JADE or Helper.STRANGER_JADE;
		if tbInfo.bIsNpc then
			nAward = 5;
		end
		ItemObj.pPanel:Label_SetText("AwardCount", nAward);
		ItemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.List:Update(self.tbAllInfo, fnSetItem);
end

function tbUi:OnGetStrangerList()
	self.nOtherNpcCount = Helper.MAX_LIST_COUNT - #Helper.tbFriendList - #Helper.tbStranger;
	self:Update();
end

function tbUi:OnGetSyncData(nRoleId)
	if not self.tbHelperInfo or nRoleId ~= self.tbHelperInfo.dwID then
		return;
	end

	self:DoSelect();
end

function tbUi:SelectHelper(tbHelperInfo)	
	self.tbHelperInfo = tbHelperInfo;

	if not tbHelperInfo.bIsNpc then
		RemoteServer.GetHelperSyncData(tbHelperInfo.dwID);
	else
		self:DoSelect(tbHelperInfo);
	end
end

function tbUi:DoSelect(tbHelperInfo)
	if not self.fnOnSelect then
		return;
	end
	
	self.fnOnSelect(tbHelperInfo or self.tbHelperInfo);
	self.tbHelperInfo = nil;
	Ui:CloseWindow("HelperList");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_HELPER_GET_STRANGER,	self.OnGetStrangerList},
        { UiNotify.emNOTIFY_HELPER_GET_SYNCDATA,	self.OnGetSyncData},
    };

    return tbRegEvent;
end


tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnBack = function (self)
	Ui:CloseWindow("HelperList");
end

tbUi.tbOnClick.BtnSkip = function (self)
	if self.fnOnSelect then
		Timer:Register(1, self.fnOnSelect);
	end

	Ui:CloseWindow("HelperList");
end
