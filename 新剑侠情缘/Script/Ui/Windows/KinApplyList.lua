local tbUi = Ui:CreateClass("KinApplyList");

local tbSortStateArray = {
		{
			["Name"]		= "Faction",
			["SortState"] 	= 0,
			["SortFun"] 	= "SortByFaction",
		},
		{
			["Name"]		= "Rank",
			["SortState"] 	= 0,
			["SortFun"] 	= "SortByRank",
		},
		{
			["Name"]		= "Member",
			["SortState"] 	= 0,
			["SortFun"] 	= "SortByApplyName",
		},
		{
			["Name"]		= "Level",
			["SortState"] 	= 0,
			["SortFun"] 	= "SortByApplyLevel",
		},
}

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateData, self },
	};

	return tbRegEvent;
end


function tbUi:OnOpen()
	self:ClearSortState();
	self:UpdateApplyList();
	self:UpdateAutoRecruit()
	Kin:UpdateRecruitSetting()
end

function tbUi:UpdateData(szType)
	if szType == "ApplyList" then
		self:UpdateApplyList();
	elseif szType == "RecruitSetting" then
		self:UpdateAutoRecruit()
	end
end

function tbUi:UpdateAutoRecruit()
	local tbRecruitSetting = Kin:GetRecruitSetting() or {}
	self.pPanel:Toggle_SetChecked("ToggleAutoRecruit", not not tbRecruitSetting.bAutoRecruitNewer)
end

function tbUi:UpdateApplyList(szSortFun,bIsDown)
	local nNewerMaxLevel = Kin:GetCareerNewLevels()
	local bAutoRecruit = Kin:CheckMyAuthority(Kin.Def.Authority_EditRecuitInfo)
	local bShowAutoRecruit = nNewerMaxLevel>0 and bAutoRecruit
	self.pPanel:SetActive("ToggleAutoRecruit", bShowAutoRecruit)
	if bShowAutoRecruit then
		self.pPanel:Label_SetText("AutomaticReception", string.format("自动接收见习成员（等级 ≤ %d）", nNewerMaxLevel))
	end

	local tbApplyList = Kin:GetApplyerList() or {};

	if szSortFun ~= nil then
		local fSortFun = Kin:GetSortFunction(szSortFun);
		tbApplyList=fSortFun(tbApplyList,bIsDown);
	end

	local fnSetItem = function (itemObj, nIndex)
		local tbItemData = tbApplyList[nIndex];
		itemObj:Init(tbItemData);
	end

	self.ScrollView:Update(tbApplyList, fnSetItem);
	Kin:MarkCurApplyListSeen();
	Kin:UpdateRedPoint();
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnRefreshList()
	Kin:UpdateApplyInfo(true);
end

function tbUi.tbOnClick:BtnEmptyList()
	me.MsgBox("确定清空申请列表吗？",
	{
		{"确认", function ()
			Kin:CleanApplyList();
		end},
		{"取消"},
	});
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinApplyList");
end

function tbUi.tbOnClick:ToggleAutoRecruit()
	local tbRecruitSetting = Kin:GetRecruitSetting() or {};
	Kin:SetRecruitSetting(not tbRecruitSetting.bAutoRecruitNewer);
end

---------------------------------------------------------------------
local tbItem = Ui:CreateClass("KinApplyListItem");

function tbItem:Init(tbItemData)
	self.tbItemData = tbItemData;

	self.pPanel:Label_SetText("Name", tbItemData.szName);
	local nVipLevel = tbItemData.nVipLevel
	if not nVipLevel or  nVipLevel == 0 then
		self.pPanel:SetActive("VIP", false)
	else
		self.pPanel:SetActive("VIP", true)
		self.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
	end

	self.pPanel:Label_SetText("Level", tbItemData.nPlayerLevel);
	local szFactionIcon = Faction:GetIcon(tbItemData.nFaction);
	self.pPanel:Sprite_SetSprite("Faction", szFactionIcon);

	self.pPanel:SetActive("PlayerTitle", tbItemData.nHonorLevel > 0);
	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbItemData.nHonorLevel)
	self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);

	self.pPanel:Label_SetText("MessageTxt", tbItemData.szMsg or "")
end

tbItem.tbOnClick = tbItem.tbOnClick or {};

function tbItem.tbOnClick:BtnIgnore()
	if not Kin:CheckMyAuthority(Kin.Def.Authority_Recruit) then
		me.CenterMsg("你没有权限进行操作");
		return;
	end

	Kin:DisAgreeApply(self.tbItemData.nPlayerId);

	local tbApplyList = Kin:GetApplyerList();
	local nIndex = nil;
	for nIdx, tbData in ipairs(tbApplyList) do
		if tbData.nPlayerId == self.tbItemData.nPlayerId then
			nIndex = nIdx;
		end
	end

	if nIndex then
		table.remove(tbApplyList, nIndex);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "ApplyList");
	end

	Kin:UpdateRedPoint();
end

function tbItem.tbOnClick:BtnAgree()
	if not Kin:CheckMyAuthority(Kin.Def.Authority_Recruit) then
		me.CenterMsg("你没有权限进行操作");
		return;
	end

	Kin:AgreeApply(self.tbItemData.nPlayerId);

	local tbApplyList = Kin:GetApplyerList();
	local nIndex = nil;
	for nIdx, tbData in ipairs(tbApplyList) do
		if tbData.nPlayerId == self.tbItemData.nPlayerId then
			nIndex = nIdx;
		end
	end

	if nIndex then
		table.remove(tbApplyList, nIndex);
		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "ApplyList");
	end

	Kin:UpdateRedPoint();
end

function tbItem.tbOnClick:Message()
	Ui:OpenWindow("KinApplyViewMsgPanel", self.tbItemData.szName, self.tbItemData.szMsg, self.tbItemData.tbVoice)
end


function tbUi.tbOnClick:FactionTitle()
	self:ChangeSortState("Faction");
end

function tbUi.tbOnClick:RankTitle()
	self:ChangeSortState("Rank");
end

function tbUi.tbOnClick:MemberTitle()
	self:ChangeSortState("Member");
end

function tbUi.tbOnClick:LevelTitle()
	self:ChangeSortState("Level");
end

function tbUi:ChangeSortState(szBntName)
	for k,v in pairs(tbSortStateArray) do
		if v["Name"] == szBntName  then
			if v["SortState"] == 0 or v["SortState"] == 2 then
				self:ChangeTitleToDown(v,k);
			else
				self:ChangeTitleToUp(v,k);
			end
		else
			self:ChangeTitleToDefault(v,k);
		end
	end
end

function tbUi:ChangeTitleToDefault(szBntInfo,nIndex)
	tbSortStateArray[nIndex]["SortState"] = 0;
	self.pPanel:SetActive(szBntInfo["Name"].."Up", false);
	self.pPanel:SetActive(szBntInfo["Name"].."Down", false);
	self.pPanel:ChangePosition(szBntInfo["Name"], 0,0);
end

function tbUi:ChangeTitleToUp(szBntInfo,nIndex)
	self:UpdateApplyList(szBntInfo["SortFun"],false);

	tbSortStateArray[nIndex]["SortState"] = 2;
	self.pPanel:SetActive(szBntInfo["Name"].."Up", true);
	self.pPanel:SetActive(szBntInfo["Name"].."Down", false);
	self.pPanel:ChangePosition(szBntInfo["Name"], -7,0);
end

function tbUi:ChangeTitleToDown(szBntInfo,nIndex)
	self:UpdateApplyList(szBntInfo["SortFun"],true);

	tbSortStateArray[nIndex]["SortState"] = 1;
	self.pPanel:SetActive(szBntInfo["Name"].."Up", false);
	self.pPanel:SetActive(szBntInfo["Name"].."Down", true);
	self.pPanel:ChangePosition(szBntInfo["Name"], -7,0);
end


function tbUi:ClearSortState()
	for k,v in pairs(tbSortStateArray) do
		tbSortStateArray[k]["SortState"] = 0;
		self.pPanel:SetActive(v["Name"].."Up", false);
		self.pPanel:SetActive(v["Name"].."Down", false);
		self.pPanel:ChangePosition(v["Name"], 0, 0);
	end
end
