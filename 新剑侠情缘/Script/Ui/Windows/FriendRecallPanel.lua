local tbUi = Ui:CreateClass("FriendRecallPanel")

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_UPDATE_RECALL_LIST, self.OnUpdateRecallList, self },
		{ UiNotify.emNOTIFY_UPDATE_RECALL_COUNT, self.UpdateRecalledCount, self },
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
	if not FriendRecall:IsInProcess() then
		return 0
	end
end

function tbUi:OnOpenEnd()
	self.pPanel:Button_SetCheck("BtnRule", true)
	self.pPanel:Toggle_SetChecked("BtnRule", true)
	self:ActiveRuleTab();
	if not version_tx then
		self.pPanel:SetActive("BtnRecall", false)
	else
		self.pPanel:SetActive("BtnRecall", true)
	end
end

function tbUi:ActiveRuleTab()
	self.pPanel:SetActive("RuleItem", true)
	self.pPanel:SetActive("FindItem", false)

	self:UpdateAwardInfo();
end

function tbUi:ActiveRecallTab()
	self.pPanel:SetActive("RuleItem", false)
	self.pPanel:SetActive("FindItem", true)

	self:UpdateRecalledCount();
	self:UpdateRecallList();
end

function tbUi:UpdateRecalledCount()
	local tbRecalledList = FriendRecall:GetRecalledList();
	self.FindItem.pPanel:Label_SetText("Tip", string.format(XT("剩余总召回次数：%d"), FriendRecall.Def.MAX_RECALLED_COUNT - Lib:CountTB(tbRecalledList) ))
end

function tbUi:UpdateAwardInfo()
	local tbAwardInfo = FriendRecall.AwardInfo
	if FriendRecall.bRecalled then
		tbAwardInfo = FriendRecall.RecalledAwardInfo
	end

	self.RuleItem.pPanel:Label_SetText("TxtDetail01", tbAwardInfo.szTitle);
	self.RuleItem.pPanel:Label_SetText("TxtDetail02", tbAwardInfo.szDesc);

	for nIndex=1,3 do
		local tbAward = tbAwardInfo.tbAward[nIndex]
		self.RuleItem.pPanel:SetActive("itemframe"..nIndex, tbAwardInfo.tbAward[nIndex] ~= nil);
		local tbItemframe = self.RuleItem["itemframe" .. nIndex]
		if tbItemframe and tbAwardInfo.tbAward[nIndex] then
			tbItemframe:SetItemByTemplate(tbAward[1], tbAward[2], me.nFaction);
			tbItemframe.fnClick = tbItemframe.DefaultClick;
		end
	end
end

function tbUi:OnUpdateRecallList()
	if self.pPanel:IsActive("FindItem") then
		self:UpdateRecallList();
	end
end

function tbUi:UpdateRecallList()
	--平台好友列表预处理
	local tbPlatFriendList = FriendShip:GetPlatFriendsInfo();
	local tbPlatFriendMap = {}
	for _,tbPlatFriendInfo in pairs(tbPlatFriendList) do
		tbPlatFriendMap[tbPlatFriendInfo.szOpenId] = tbPlatFriendInfo
	end

	local tbCanRecallList = FriendRecall:GetCanRecallList();
	local tbList = {};
	for nPlayerId,tbPlayerInfo in pairs(tbCanRecallList) do

		local tbData = FriendShip:GetFriendDataInfo(nPlayerId)
		if tbData then
			local tbInfo = 
			{
				nPlayerId = nPlayerId,
				szName = tbData.szName,
				nLevel = tbData.nLevel,
				nFaction = tbData.nFaction,
				nPortrait = tbData.nPortrait,
				nImity = tbData.nImity,
				nImityLevel = FriendShip:GetImityLevel(tbData.nImity),
				nType = tbPlayerInfo.nType,
				szAccount = tbPlayerInfo.szAccount,
				tbPlatFriendInfo = tbPlatFriendMap[tbPlayerInfo.szAccount],
			}
			table.insert(tbList, tbInfo);
		end
	end

	--先按亲密度排序
	local function fnImitySort(a,b)
		return a.nImity > b.nImity
	end

	table.sort(tbList, fnImitySort)

	--只显示亲密度前X个的召回信息
	for nIndex=#tbList, FriendRecall.Def.MAX_SHOW_CAN_RECALL_COUNT + 1,-1 do
		table.remove(tbList, nIndex);
	end

	local function fnSort(a,b)
		return a.nType < b.nType
	end

	table.sort(tbList, fnSort)

	local tbRecalledList = FriendRecall:GetRecalledList();
	local nRecalledCount = Lib:CountTB(tbRecalledList);

	local fnSetItem = function (tbItem, nIndex)
		local tbInfo = tbList[nIndex];
		tbItem.tbInfo = tbInfo;
		tbItem.nIndex = nIndex;

		tbItem.pPanel:Label_SetText("Name", tbInfo.szName);
		tbItem.pPanel:Label_SetText("lbLevel", tostring(tbInfo.nLevel));
		tbItem.pPanel:Label_SetText("IntimacyLevel", string.format(XT("亲密度等级：%d"), tbInfo.nImityLevel));
		tbItem.pPanel:Label_SetText("Relationship", self:GetRelationTypeName(tbInfo.nType))

		local szSprite, szAtlas = PlayerPortrait:GetPortraitIcon(tbInfo.nPortrait);
		if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
			tbItem.pPanel:Sprite_SetSprite("SpRoleHead", szSprite, szAtlas);
		end

		tbItem.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbInfo.nFaction));

		tbItem.BtnQQ.pPanel.OnTouchEvent = function()
			self:OnRecall(tbInfo);
		end

		tbItem.BtnWetChat.pPanel.OnTouchEvent = function()
			self:OnRecall(tbInfo);
		end

		local bNotRecalled = true;
		if tbRecalledList[tbInfo.nPlayerId] then
			bNotRecalled = false
		end

		tbItem.pPanel:SetActive("BtnQQ", Sdk:IsLoginByQQ() and bNotRecalled and (nRecalledCount < FriendRecall.Def.MAX_RECALLED_COUNT));
		tbItem.pPanel:SetActive("BtnWetChat", Sdk:IsLoginByWeixin() and bNotRecalled and (nRecalledCount < FriendRecall.Def.MAX_RECALLED_COUNT));
		
		tbItem.pPanel:SetActive("HaveSend", not bNotRecalled)
	end

	local nTotalCount = #tbList;
	self.FindItem.PartnersView:Update(nTotalCount, fnSetItem);
end

function tbUi:OnRecall(tbInfo)
	if tbInfo.tbPlatFriendInfo then
		FriendRecall:DoServerRecall(tbInfo)
	else
		FriendRecall:DoClientRecall(tbInfo)
	end
end

function tbUi:GetRelationTypeName(nType)

	if nType == FriendRecall.RecallType.TEACHER then
		return "师傅"
	elseif nType == FriendRecall.RecallType.STUDENT then
		return "徒弟"
	elseif nType == FriendRecall.RecallType.FIREND then
		return "好友"
	elseif nType == FriendRecall.RecallType.KIN then
		return "家族"
	else
		return ""
	end
end

tbUi.tbOnClick = 
{
	BtnRule = function (self)
		self:ActiveRuleTab()
	end,

	BtnRecall = function (self)
		self:ActiveRecallTab()
	end,

	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}