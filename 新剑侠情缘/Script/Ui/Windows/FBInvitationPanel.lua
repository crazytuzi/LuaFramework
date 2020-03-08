local tbUi = Ui:CreateClass("FBInvitationPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_XGSDK_CALLBACK, self.UpdateData, self },
	};

	return tbRegEvent;
end


function tbUi:OnOpen()
	Sdk:QueryFriendsInfo();

	self.tbSelect = {};
	self.tbCurPlayers = nil;
end

function tbUi:UpdateData(szType)
	if szType == "FBInviteInfo" then
		self.tbCurPlayers = nil;
		self:Update();
	end
end

function tbUi:OnOpenEnd()
	self:Update();
end

function tbUi:GetRandomPlayer()
	local tbAllFriendsInfo = Lib:RandomArray(Sdk:XGGetInvitableFriends());
	local tbRet = {};
	Lib:Tree(tbAllFriendsInfo)
	for i = 1, Sdk.Def.nFBInviteFriendsPriceCount do
		if tbAllFriendsInfo[i] then
			table.insert(tbRet, tbAllFriendsInfo[i]);
		end
	end
	return tbRet;
end

function tbUi:Update()
	if not self.tbCurPlayers then
		self.tbCurPlayers = self:GetRandomPlayer();
		for i, _ in ipairs(self.tbCurPlayers) do
			self.tbSelect[i] = false;
		end
	end

	local tbItems = self.tbCurPlayers;
	local fnSetItem = function (itemObj, nIdx, nIth, tbData)
		itemObj.pPanel:SetActive("FriendsItem" .. nIth, tbData and true or false);
		if not tbData then
			return;
		end

		itemObj.pPanel:Toggle_SetChecked("Toggle" .. nIth, self.tbSelect[nIdx] or false);
		itemObj.pPanel:Texture_SetUrlTexture("Head" .. nIth, tbData.thumbnail or "");
		itemObj.pPanel:Label_SetText("Name" .. nIth, tbData.name or "");
		itemObj["tbItem" .. nIth] = tbData;
		itemObj["nIdx" .. nIth] = nIdx;
	end
	local fnSetItems = function (itemObj, nIdx)
		local tbItem1 = tbItems[2 * nIdx - 1];
		local tbItem2 = tbItems[2 * nIdx];
		fnSetItem(itemObj, 2 * nIdx - 1, 1, tbItem1);
		fnSetItem(itemObj, 2 * nIdx, 2, tbItem2);
		itemObj.root = self;
	end

	self.ScrollView:Update(math.ceil(#tbItems / 2), fnSetItems);
	self:UpdateAllSelect();


	local nCurInviteCount = Sdk:GetFBInviteCount();
	self.pPanel:Label_SetText("AwardTxt", string.format("领取奖励%d/%d", nCurInviteCount, Sdk.Def.nFBInviteFriendsPriceCount));
	local nInviteDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_DAY);
	local nTakeRewardDay = me.GetUserValue(Sdk.Def.SDK_INFO_SAVEGROUP, Sdk.Def.SDK_INFO_FB_INVITE_PRICE_DAY);
	local bTooked = (nInviteDay == nTakeRewardDay) and (nCurInviteCount >= Sdk.Def.nFBInviteFriendsPriceCount);
	if bTooked then
		self.pPanel:Label_SetText("AwardTxt", "今日奖励已领取");
	end
end

function tbUi:UpdateAllSelect()
	local bAllSelect = true;
	for _, v in ipairs(self.tbSelect) do
		if not v then
			bAllSelect = false;
			break;
		end
	end
	self.pPanel:Toggle_SetChecked("AllSelect", bAllSelect);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnAward()
	if Sdk:GetFBInviteCount() < Sdk.Def.nFBInviteFriendsPriceCount then
		me.CenterMsg("邀请人数尚未达标，无法领取奖励");
		return;
	end

	Sdk:XGTakeFBInviteAward();
end

function tbUi.tbOnClick:BtnInvitation()
	local tbInvite = {};
	for nIth, bSelect in pairs(self.tbSelect or {}) do
		if bSelect and self.tbCurPlayers[nIth] then
			table.insert(tbInvite, self.tbCurPlayers[nIth]);
		end
	end

	if not next(tbInvite) then
		me.CenterMsg("您还没选中要邀请的好友");
		return;
	end

	Sdk:XGInviteFriends(tbInvite);
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:AllSelect()
	local bAllSelect = self.pPanel:Toggle_GetChecked("AllSelect");
	for i,v in ipairs(self.tbSelect) do
		self.tbSelect[i] = bAllSelect;
	end

	self:Update();
end

function tbUi.tbOnClick:BtnRefresh()
	self.tbCurPlayers = nil;
	self.tbSelect = {};
	self:Update();
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

local tbItem = Ui:CreateClass("FBInviteItem");

tbItem.tbOnClick = tbItem.tbOnClick or {};

function tbItem.tbOnClick:Toggle1()
	local root = self.root;
	root.tbSelect[self.nIdx1] = not root.tbSelect[self.nIdx1];
	root:UpdateAllSelect();
end

function tbItem.tbOnClick:Toggle2()
	local root = self.root;
	root.tbSelect[self.nIdx2] = not root.tbSelect[self.nIdx2];
	root:UpdateAllSelect();
end