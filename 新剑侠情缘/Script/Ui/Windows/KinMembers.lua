local tbGrid = Ui:CreateClass("FamilyMemberItem");
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



local tbUi = Ui:CreateClass("KinMembers");


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
		["SortFun"] 	= "SortByName",
	},
	{
		["Name"]		= "Level",
		["SortState"] 	= 0,
		["SortFun"] 	= "SortByLevel",
	},
	{
		["Name"]		= "Post",
		["SortState"] 	= 0,
		["SortFun"] 	= "SortByPost",
	},
	{
		["Name"]		= "Contribution",
		["SortState"] 	= 0,
		["SortFun"] 	= "SortByContribution",
	},
	{
		["Name"]		= "Offline",
		["SortState"] 	= 0,
		["SortFun"] 	= "SortByOffline",
	},
	{
		["Name"]		= "ActiveValue",
		["SortState"] 	= 0,
		["SortFun"] 	= "SortByActivity",
	},
	{
		["Name"]		= "ChuangGong",
		["SortState"] 	= 0,
		["SortFun"] 	= "SortByChuangGong",
	},
}


function tbUi:Init()
	Kin:UpdateMemberList();
	Kin:UpdateApplyInfo();
	self:ClearSortState();
	self:UpdateMemberListInfo();
	--Kin:Ask4AllAuctionData();
	if Client:IsCloseIOSEntry() then
		self.pPanel:SetActive("BtnRedPaper", false)
	end
end

function tbUi:UpdateData(szType)
	if szType == "MemberList" then
		self:UpdateMemberListInfo();
	end
end

function tbUi:SortList(tbMemberList)
	local tbOnlineMembers = Kin:GetMemberState() or {};
	table.sort(tbMemberList, function (a, b)
		if a.nMemberId == me.dwID then
			return true;
		elseif b.nMemberId == me.dwID then
			return false;
		end

		local bHelpA = not not a.tbCommerceHelp or KinDinnerParty:IsKinMemberHelping(a)
		local bHelpB = not not b.tbCommerceHelp or KinDinnerParty:IsKinMemberHelping(b)
		if bHelpA == bHelpB then
			if tbOnlineMembers[a.nMemberId] and not tbOnlineMembers[b.nMemberId] then
				return true;
			elseif not tbOnlineMembers[a.nMemberId] and tbOnlineMembers[b.nMemberId] then
				return false;
			end

			if a.nCareer == b.nCareer then
				return a.nContribution > b.nContribution;
			else
				local nOrderA = Kin.Def.tbCareersOrder[a.nCareer] or math.huge
				local nOrderB = Kin.Def.tbCareersOrder[b.nCareer] or math.huge
				return nOrderA<nOrderB
			end
		else
			return bHelpA
		end
	end)
end

function tbUi:UpdateMemberListInfo(szSortFun,bIsDown)
	self.szCurSortFunc = szSortFun or self.szCurSortFunc
	if bIsDown~=nil then
		self.bCurIsDown = bIsDown
	end
	szSortFun = self.szCurSortFunc
	bIsDown = self.bCurIsDown

	local tbMemberList = Kin:GetMemberList() or {};
	if szSortFun == nil then
		self:SortList(tbMemberList);
	else
		local fSortFun = Kin:GetSortFunction(szSortFun);
		tbMemberList=fSortFun(tbMemberList,bIsDown);
	end

	local fnShowCommerceHelp = function (buttonObj)
		local nMemberId = buttonObj.root.tbMemberData.nMemberId;
		if buttonObj.root.tbMemberData.tbCommerceHelp then
			if nMemberId == me.dwID then
				Ui:OpenWindow("CommerceTaskPanel");
			else
				Ui:OpenWindow("CommerceHelpPanel", nMemberId);
			end
			return
		end
		if KinDinnerParty:IsKinMemberHelping(buttonObj.root.tbMemberData) then
			if nMemberId == me.dwID then
				Ui:OpenWindow("KinDPTaskPanel");
			else
				Ui:OpenWindow("KinDPTaskHelpPanel", nMemberId);
			end
			return
		end
	end

	local curSelectButton = nil;
	local fnOnSelect = function(buttonObj)
		if curSelectButton == buttonObj and not buttonObj.bSelf then
			Ui:OpenWindowAtPos("RightPopup", 0, -60,  "kin", buttonObj.tbMemberData)
		else
			curSelectButton = buttonObj;
		end
	end

	local nLeaderId = Kin:GetLeaderId()
	local tbOnlineMembers = Kin:GetMemberState() or {};
	local pScrollView = self.ScrollView
	local fnSetItem = function (itemObj, nIndex)
		pScrollView:CheckShowGridMax(itemObj, nIndex)
		local tbMemberData = tbMemberList[nIndex];
		local szCareerName = Kin.Def.Career_Name[tbMemberData.nCareer];
		if nLeaderId==tbMemberData.nMemberId then
			if Kin.Def.tbManagerCareers[tbMemberData.nCareer] then
				szCareerName = string.format("%s/%s", Kin.Def.Career_Name[Kin.Def.Career_Leader], szCareerName)
			else
				szCareerName = Kin.Def.Career_Name[Kin.Def.Career_Leader]
			end
		end

		itemObj.bSelf = tbMemberData.nMemberId == me.dwID;
		itemObj.pPanel:Button_SetSprite("Main", itemObj.bSelf and "BtnListThirdOwn" or "BtnListThirdNormal", 1);
		itemObj.pPanel:Label_SetText("Name", tbMemberData.szName);
		local nVipLevel = tbMemberData.nVipLevel
		if not nVipLevel or  nVipLevel == 0 then
			itemObj.pPanel:SetActive("VIP", false)
		else
			itemObj.pPanel:SetActive("VIP", true)
			itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end
		itemObj.pPanel:Label_SetText("Level", tbMemberData.nLevel);
		itemObj.pPanel:SetActive("PlayerTitle", tbMemberData.nHonorLevel > 0);
		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbMemberData.nHonorLevel)
		itemObj.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
		itemObj.pPanel:Label_SetText("Post", szCareerName);
		itemObj.pPanel:Label_SetText("Contribution", tbMemberData.nContribution);

		local bOnLine = tbOnlineMembers[tbMemberData.nMemberId];
		local szOnlineState = self:GetOnlineState(bOnLine, tbMemberData.nLastOnlineTime);
		itemObj.pPanel:Label_SetText("OnLine",  szOnlineState);

		itemObj.pPanel:Label_SetText("ActiveValue", tbMemberData.nActivity)

		local szFactionIcon = Faction:GetIcon(tbMemberData.nFaction);
		itemObj.pPanel:Sprite_SetSprite("Faction", szFactionIcon);

		itemObj.pPanel:SetActive("ChuangGong", false); 								

		local function fnChuangGong(buttonObj)
			local nHisLevel = buttonObj.root.tbMemberData.nLevel or 0;
			local nHisId = buttonObj.root.tbMemberData.nMemberId or 0
			local fnRequest
			if me.nLevel > nHisLevel then
				fnRequest = function ()
					ChuangGong:RequestSendChuangGong(nHisId, nHisLevel)
				end
				if ChuangGong:CheckMap() then
					fnRequest()
				else
					ChuangGong:GoSafe(fnRequest)
					Ui:CloseWindow("KinDetailPanel")
				end
			elseif me.nLevel < nHisLevel then
				fnRequest = function ()
					ChuangGong:RequestGetChuangGong(nHisId, nHisLevel)
				end
				if ChuangGong:CheckMap() then
					fnRequest()
				else
					ChuangGong:GoSafe(fnRequest)
					Ui:CloseWindow("KinDetailPanel")
				end
			else
				me.CenterMsg("双方等级差不足3级，无法传功")
			end
		end

		if bOnLine and me.dwID ~= tbMemberData.nMemberId then
			local tbParam = {
				nLevel = tbMemberData.nLevel,
				nVipLevel = tbMemberData.nVipLevel,
				nChuangGongTimes = tbMemberData.nChuangGongTimes,
				nChuangGongSendTimes = tbMemberData.nChuangGongSendTimes,
				nLastChuangGongSendTime = tbMemberData.nLastChuangGongSendTime,
			}
			itemObj.pPanel:SetActive("ChuangGong", ChuangGong:IsCanChuangGong(tbParam));  
		end

		itemObj.tbMemberData = tbMemberData;
		itemObj.ChuangGong.pPanel.OnTouchEvent = fnChuangGong; 							

		itemObj.pPanel:SetActive("Box", tbMemberData.tbCommerceHelp or KinDinnerParty:IsKinMemberHelping(tbMemberData));
		itemObj.Box.pPanel.OnTouchEvent = fnShowCommerceHelp;

		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	pScrollView:Update(tbMemberList, fnSetItem, 10, self.BackTop2, self.BackBottom2);

	local bRecruit = Kin:CheckMyAuthority(Kin.Def.Authority_EditRecuitInfo);
	self.pPanel:SetActive("BtnRecruit", bRecruit);
end

function tbUi:GetOnlineState(bOnline, nLastOnlineTime)
	if bOnline then
		return "在线";
	end

	if not Kin:CheckMyAuthority(Kin.Def.Authority_KickOut) then
		return "离线";
	end

	local nToday = Lib:GetLocalDay();
	local nLoginDay = Lib:GetLocalDay(nLastOnlineTime);
	if nToday == nLoginDay then
		return "今天";
	elseif nToday == nLoginDay + 1 then
		return "昨天";
	elseif nToday > nLoginDay + 1 and nToday < nLoginDay + 7 then
		return "2天前";
	else
		return "7天前";
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnQuitFamily()
	local tbKinBaseInfo, _ = Kin:GetBaseInfo();
	if not tbKinBaseInfo then
		me.CenterMsg("数据尚未加载成功");
		return;
	end

	if tbKinBaseInfo.nMasterId == me.dwID then
		me.CenterMsg("族长不可退出家族哦~");
		return;
	end

	local msg = Kin:HaveUnsentRedBags() and "少侠还有未发放的红包，确定退出家族吗？" or "是否确认退出家族？"
	msg = Kin:CanGetSalary() and "个人日均活跃影响最终获得的家族工资。[FFFE0D]退出家族后将会清空个人本周活跃，[-]确定要退出家族吗？" or msg

	local nJoinCD = Kin:GetJoinCD(me)
	if nJoinCD>0 then
		msg = string.format("%s\n[FFFE0D]%s之内不能进入其他家族[-]", msg, Lib:TimeDesc8(nJoinCD))
	end

	local fnAgree = function ()
		Kin:Quite();
		Ui:CloseWindow("MessageBox");
	end

	local fnClose = function ()
		Ui:CloseWindow("MessageBox");
	end

	Ui:OpenWindow("MessageBox", msg, {{fnAgree}, {fnClose}}, {"退出家族", "取消"});
end

function tbUi.tbOnClick:BtnApplyList()
	Ui:OpenWindow("KinApplyList");
	Ui:ClearRedPointNotify("ApplyList")
end

function tbUi.tbOnClick:BtnFamilyList()
	local bOnly4Show = true;
	Ui:OpenWindow("KinJoinPanel", bOnly4Show);
end

function tbUi.tbOnClick:BtnRecruit()
	local bCanEditRecuit = Kin:CheckMyAuthority(Kin.Def.Authority_EditRecuitInfo);
	if not bCanEditRecuit then
		me.CenterMsg("你无权查看招人条件");
		return;
	end

	Ui:OpenWindow("KinRecruit");
end

function tbUi.tbOnClick:BtnRedPaper()
	Ui:OpenWindow("RedBagPanel")
end

function tbUi.tbOnClick:FactionTitle()
	self:ChangeSortState("Faction");
end

function tbUi.tbOnClick:RankTitle()
	self:ChangeSortState("Rank");
end

function tbUi.tbOnClick:ActiveValueTitle()
	self:ChangeSortState("ActiveValue")
end

function tbUi.tbOnClick:MemberTitle()
	self:ChangeSortState("Member");
end

function tbUi.tbOnClick:LevelTitle()
	self:ChangeSortState("Level");
end

function tbUi.tbOnClick:PostTitle()
	self:ChangeSortState("Post");
end

function tbUi.tbOnClick:ContributionTitle()
	self:ChangeSortState("Contribution");
end

function tbUi.tbOnClick:OfflineTitle()
	self:ChangeSortState("Offline");
end

function tbUi.tbOnClick:ChuangGongTitle()
	self:ChangeSortState("ChuangGong");
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
	self:UpdateMemberListInfo(szBntInfo["SortFun"],false);

	tbSortStateArray[nIndex]["SortState"] = 2;
	self.pPanel:SetActive(szBntInfo["Name"].."Up", true);
	self.pPanel:SetActive(szBntInfo["Name"].."Down", false);
	self.pPanel:ChangePosition(szBntInfo["Name"], -7,0);
end

function tbUi:ChangeTitleToDown(szBntInfo,nIndex)
	self:UpdateMemberListInfo(szBntInfo["SortFun"],true);

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
		if v["Name"] == "Post" then
			self.pPanel:SetActive(v["Name"].."Down", true);
			self.pPanel:ChangePosition(v["Name"], -7, 0);
		end
	end
	self.szCurSortFunc = nil
	self.bCurIsDown = nil
end
