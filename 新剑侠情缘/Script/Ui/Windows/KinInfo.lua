local tbGrid = Ui:CreateClass("FamilyInfoItem");
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



local tbUi = Ui:CreateClass("KinInfo");
local RepresentSetting = luanet.import_type("RepresentSetting");
local tbSortStateArray = {
		{
			["Name"]		= "Faction",
			["SortState"] 	= 0,
			["SortFun"] 	= "SortByFaction",
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
}

tbUi.nGroupState = nil;

function tbUi:Init()
	Kin:UpdateMemberList();
	Kin:UpdateApplyInfo();

	self:UpdateBaseFamilyInfo();
	self:ClearSortState();
	self:UpdateMemberListInfo();
end

function tbUi:UpdateData(szType)
	if szType == "BaseInfo" then
		self:UpdateBaseFamilyInfo();
	elseif szType == "MemberList" then
		self:UpdateMemberListInfo();
	end
end

function tbUi:GroupNotify(nQueryRet)
	-- iOS审核屏蔽
	if Client:IsCloseIOSEntry() then
		return;
	end

	tbUi.nGroupState = nQueryRet;
	self:UpdateQQGroupInfo();
	self:UpdateWeixinGroupInfo();
end

function tbUi:UpdateBaseFamilyInfo()
	local tbBaseInfo = Kin:GetBaseInfo() or {};
	self.pPanel:Label_SetText("FamilyName", tbBaseInfo.szName or "");
	self.pPanel:Label_SetText("FamilyLead", tbBaseInfo.szMasterName or "");
	self.pPanel:Label_SetText("FamilyLeader", Kin:GetLeaderName())
	self.pPanel:Label_SetText("FamilyLevel", tbBaseInfo.nLevel or "");
	self.pPanel:Label_SetText("FamilyMoney", tbBaseInfo.nFound or "");
	self.pPanel:Label_SetText("Prestige", tbBaseInfo.nPrestige or "");
	self.pPanel:Label_SetText("Camp", Npc.tbCampTypeName[tbBaseInfo.nKinCamp] or "");
	local CampColor = RepresentSetting.GetCampColor(tbBaseInfo.nKinCamp or 0);
	self.pPanel:Label_SetColor("Camp", CampColor.r * 255, CampColor.g * 255, CampColor.b * 255);

	local szMemberDesc = "";
	local szNewerDesc = "";
	if tbBaseInfo.nMemberCount then
		szMemberDesc = string.format("%d/%d", tbBaseInfo.nMemberCount, tbBaseInfo.nMaxMemberCount);
		szNewerDesc  = string.format("%d/%d", tbBaseInfo.nNewerCount, tbBaseInfo.nMaxNewerCount)
	end

	self.pPanel:Label_SetText("OfficialMembers", szMemberDesc);
	self.pPanel:Label_SetText("ProbationMember", szNewerDesc);

	self.pPanel:Label_SetText("TxtFamilyDeclare", tbBaseInfo.szPublicDeclare or "");
	self.pPanel:Label_SetText("TxtGroupInfo", "");
	self.pPanel:SetActive("BtnGroupOpt", false);
	self.pPanel:Label_SetText("TxtGroupTitle", "");
	self.pPanel:SetActive("BtnCall", false);

	self:UpdateQQGroupInfo();
	self:UpdateWeixinGroupInfo();
end

function tbUi:UpdateQQGroupInfo()
	if not Sdk:IsLoginByQQ() then
		return;
	end

	self.pPanel:Label_SetText("TxtGroupTitle", "家族Q群:  ");
	local tbBaseInfo = Kin:GetBaseInfo() or {};
	local szGroupName = tbBaseInfo.szGroupName or "暂未绑定群";
	szGroupName = ChatMgr:CutMsg(szGroupName, 6);
	self.pPanel:Label_SetText("TxtGroupInfo", szGroupName);

	if Kin:CheckMyAuthority(Kin.Def.Authority_BindGroup) then
		if Client:IsCloseIOSEntry() and not Sdk:IsPlatformInstalled(Sdk.ePlatform_QQ) then
			self.pPanel:SetActive("BtnGroupOpt", false);
		else
			self.pPanel:SetActive("BtnGroupOpt", true);
			if not tbBaseInfo.szGroupOpenId then
				self.pPanel:Label_SetText("TxtGroupOpt", "绑定");
			else
				self.pPanel:Label_SetText("TxtGroupOpt", "解绑");
			end
		end
	elseif tbBaseInfo.szGroupOpenId then
		self.pPanel:Label_SetText("TxtGroupOpt", "加入");
	else
		self.pPanel:SetActive("BtnGroupOpt", false);
	end

	if (tbUi.nGroupState == Sdk.eQQGroupRet_NotJoined or tbUi.nGroupState == Sdk.eQQGroupRet2_NotJoined) and tbBaseInfo.szGroupOpenId then
		self.pPanel:SetActive("BtnGroupOpt", true);
	elseif Kin:IsShowQQGroupCall() then
		self.pPanel:SetActive("BtnCall", Kin:CheckMyAuthority(Kin.Def.Authority_Recruit));
	end
end

function tbUi:UpdateWeixinGroupInfo()
	if not Sdk:IsLoginByWeixin() then
		return;
	end

	self.pPanel:Label_SetText("TxtGroupTitle", "微信群聊:  ");
	if not tbUi.nGroupState then
		self.pPanel:Label_SetText("TxtGroupInfo", "");
		self.pPanel:SetActive("BtnGroupOpt", false);
	elseif Sdk.eWXGroupRet_IDNotExist[tbUi.nGroupState] then
		self.pPanel:Label_SetText("TxtGroupInfo", "暂未绑定群");

		if Kin:CheckMyAuthority(Kin.Def.Authority_BindGroup) then
			self.pPanel:SetActive("BtnGroupOpt", true);
			self.pPanel:Label_SetText("TxtGroupOpt", "绑定");
		else
			self.pPanel:SetActive("BtnGroupOpt", false);
		end
	elseif tbUi.nGroupState == Sdk.eWXGroupRet_Suss then
		self.pPanel:Label_SetText("TxtGroupInfo", "已入群");
		self.pPanel:SetActive("BtnGroupOpt", true);
		self.pPanel:Label_SetText("TxtGroupOpt", "加入");
	elseif Sdk.eWXGroupRet_IDExist[tbUi.nGroupState] then
		self.pPanel:Label_SetText("TxtGroupInfo", "未入群");
		self.pPanel:SetActive("BtnGroupOpt", true);
		self.pPanel:Label_SetText("TxtGroupOpt", "加入");
	end
end

function tbUi:SortMemberList(tbMemberList)
	local nNow = GetTime()
	table.sort(tbMemberList, function (a, b)
		local bForbidA = a.nForbidTime and a.nForbidTime>nNow
		local bForbidB = b.nForbidTime and b.nForbidTime>nNow
		if a.nMemberId == me.dwID then
			return true;
		elseif b.nMemberId == me.dwID then
			return false
		elseif bForbidA~=bForbidB then
			return bForbidA
		elseif b.nMemberId == me.dwID then
			return false;
		else
			if a.nCareer == b.nCareer then
				return a.nLevel > b.nLevel;
			else
				local nOrderA = Kin.Def.tbCareersOrder[a.nCareer] or math.huge
				local nOrderB = Kin.Def.tbCareersOrder[b.nCareer] or math.huge
				return nOrderA<nOrderB
			end
		end
	end)
end

function tbUi:UpdateMemberListInfo(szSortFun,bIsDown)
	local tbMemberList = Kin:GetMemberList() or {};
	if szSortFun == nil then
		self:SortMemberList(tbMemberList);
	else
		local fSortFun = Kin:GetSortFunction(szSortFun);
		tbMemberList=fSortFun(tbMemberList,bIsDown);
	end

	local curMemberList = nil;
	local fnSelectItem = function (listObj)
		if curMemberList == listObj and not listObj.bSelf then
			Ui:OpenWindowAtPos("RightPopup", 0, -63,  "kin", listObj.tbItemData)
		else
			curMemberList = listObj;
		end
	end

	local nLeaderId = Kin:GetLeaderId()
	local nNow = GetTime()
	local pScrollView = self.ScrollView
	local fnSetItem = function (itemObj, nIdx)
		pScrollView:CheckShowGridMax(itemObj, nIdx)
		local tbMemberData = tbMemberList[nIdx];
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
		itemObj.pPanel:Label_SetText("Post", szCareerName or "");
		local szFactionIcon = Faction:GetIcon(tbMemberData.nFaction);
		itemObj.pPanel:Sprite_SetSprite("Faction", szFactionIcon);
		itemObj.tbItemData = tbMemberData;

		local bForbid = tbMemberData.nForbidTime and tbMemberData.nForbidTime>nNow
		itemObj.pPanel:SetActive("Gag", bForbid)
		itemObj.pPanel.OnTouchEvent = fnSelectItem;
	end

	pScrollView:Update(#tbMemberList, fnSetItem, 10, self.BackTop, self.BackBottom);

	local bCanSendMail = Kin:CheckMyAuthority(Kin.Def.Authority_Mail);
	self.pPanel:SetActive("BtnSendEmails", bCanSendMail);

	local bCanGrant = Kin:CheckMyAuthority(Kin.Def.Authority_GrantOlder);
	local bEditeTitle = Kin:CheckMyAuthority(Kin.Def.Authority_EditKinTitle);
	local bLeader = Kin:AmILeader()
	self.pPanel:SetActive("BtnPostManage", bCanGrant or bEditeTitle or bLeader);

	--local bRet = Kin:CheckMyAuthority(Kin.Def.Authority_ChangeCamp);
	self.pPanel:SetActive("BtnCamp", false);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnEdit()
	if not Kin:CheckMyAuthority(Kin.Def.Authority_EditPubilcDeclare) then
		me.CenterMsg("你没有权限编辑公告");
		return;
	end

	Ui:OpenWindow("KinDeclareEditor");
end

function tbUi.tbOnClick:BtnPostManage()
	self:ClearSortState();
	local tbMemberList = Kin:GetMemberList() or {};
	self:SortMemberList(tbMemberList);
	Ui:OpenWindow("KinMgrPanel");
end

function tbUi.tbOnClick:BtnSendEmails()
	Ui:OpenWindow("KinMailPanel");
end

function tbUi.tbOnClick:BtnBackFamily()
	if AutoFight:IsAuto() then
		AutoFight:StopAll();
		Timer:Register(Env.GAME_FPS * 1.3, function ()
			Kin:GoKinMap();
		end);
	else
		Kin:GoKinMap();
	end
	Ui:CloseWindow("KinDetailPanel");
end

function tbUi.tbOnClick:BtnGroupOpt()
	self:SelectQQGroupOpt();
	self:SelectWeixinGroupOpt();
end

function tbUi.tbOnClick:BtnCall()
	Kin:SendQQGroupInvitation();
end

function tbUi:SelectQQGroupOpt()
	if not Sdk:IsLoginByQQ() then
		return;
	end

	if not Sdk:IsPlatformInstalled(Sdk.ePlatform_QQ) then
		if not Client:IsCloseIOSEntry() then
			me.CenterMsg("您尚未安装QQ, 无法进行Q群相关的操作");
		end
		return;
	end

	local tbBaseInfo = Kin:GetBaseInfo() or {};
	if Kin:CheckMyAuthority(Kin.Def.Authority_BindGroup) then
		if not tbBaseInfo.szGroupOpenId then
			Kin:BindQQGroup(tbBaseInfo.szName);
		else
			me.MsgBox("是否确认解绑家族群?", { {"确定", function ()
				Kin:UnbindQQGroup(tbBaseInfo.szGroupOpenId, me.dwKinId, true);
			end}, {"取消"}});
		end
	elseif tbBaseInfo.szGroupOpenId then
		Kin:Ask2JoinGroup();
	end
end

function tbUi:SelectWeixinGroupOpt()
	if not Sdk:IsLoginByWeixin() then
		return;
	end

	if not Sdk:IsPlatformInstalled(Sdk.ePlatform_Weixin) then
		me.CenterMsg("您尚未安装微信, 无法进行相关的操作");
		return;
	end

	if not tbUi.nGroupState then
		me.CenterMsg("请求信息中, 请稍后..");
		return;
	end

	local tbBaseInfo = Kin:GetBaseInfo() or {};
	if Sdk.eWXGroupRet_IDNotExist[tbUi.nGroupState] then
		if Kin:CheckMyAuthority(Kin.Def.Authority_BindGroup) then
			Sdk:BindWeixinGroup(me.dwKinId, tbBaseInfo.szName or "剑侠情缘手游");
		else
			me.CenterMsg("您没有权限建群");
		end
	elseif tbUi.nGroupState == Sdk.eWXGroupRet_Suss then
		Sdk:JoinWeixinGroup(me.dwKinId);
	elseif Sdk.eWXGroupRet_IDExist[tbUi.nGroupState] then
		Sdk:JoinWeixinGroup(me.dwKinId);
	end
end

function tbUi.tbOnClick:BtnCamp()
    Ui:OpenWindow("FamilyCampPanel");
end

function tbUi.tbOnClick:FactionTitle()
	self:ChangeSortState("Faction");
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

function tbUi.tbOnClick:BtnChangeName()
	if not Kin:AmIMaster() then
		me.CenterMsg("只有族长可以更改家族名")
		return
	end
	Ui:OpenWindow("KinChangeName")
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
end
