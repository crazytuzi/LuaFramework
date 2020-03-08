local tbUi = Ui:CreateClass("KinCareerEditor");

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
		{
			["Name"]		= "Contribution",
			["SortState"] 	= 0,
			["SortFun"] 	= "SortByContribution",
		},
}


local CareerFixName = {
	[Kin.Def.Authority_GrantLeader]		= "领  袖";
	[Kin.Def.Authority_GrantMaster]     = "族  长";
	[Kin.Def.Authority_GrantViceMaster] = "副族长";
	[Kin.Def.Authority_GrantCommander]  = "指  挥";
	[Kin.Def.Authority_GrantOlder]      = "长  老";
	[Kin.Def.Authority_GrantMascot]		= "家族宝贝";
}

local tbSortArray = {
	Kin.Def.Authority_GrantLeader,
	Kin.Def.Authority_GrantMaster,
	Kin.Def.Authority_GrantViceMaster,
	Kin.Def.Authority_GrantCommander,
	Kin.Def.Authority_GrantOlder,
	Kin.Def.Authority_GrantMascot,
}

local Authority2Career = {
	[Kin.Def.Authority_GrantLeader] 	= Kin.Def.Career_Leader;
	[Kin.Def.Authority_GrantMaster]     = Kin.Def.Career_Master;
	[Kin.Def.Authority_GrantViceMaster] = Kin.Def.Career_ViceMaster;
	[Kin.Def.Authority_GrantCommander]	= Kin.Def.Career_Commander;
	[Kin.Def.Authority_GrantOlder]      = Kin.Def.Career_Elder;
	[Kin.Def.Authority_GrantMascot]		= Kin.Def.Career_Mascot;
}

function tbUi:Init()
	Kin:UpdateMemberCareer();
	self:ClearSortState();
	self:InitSidebar();
end

function tbUi:SelectLightTxt(btnObj)
	for i = 1, #tbSortArray do
		local szBtnName = "BtnCareer" .. i;
		local bShowLight = (btnObj.nIdx == i);
		self[szBtnName].pPanel:SetActive("LightName", bShowLight);
		self[szBtnName].pPanel:SetActive("LightNumber", bShowLight);
	end
end

function tbUi:InitSidebar()
	local nIdx = 0;

	local fnSelectBtn = function (btnObj)
		self.nIdx = btnObj.nIdx;
		self:Update(btnObj.nCareer);
		self:SelectLightTxt(btnObj);
	end

	local tbMemberList = Kin:GetMemberList();
	local fnEqual = function (tbMember, nCareer)
		return tbMember.nCareer == nCareer;
	end

	for _, authority in ipairs(tbSortArray) do
		local nCareer = Authority2Career[authority]
		local nMaxCareer = Kin:GetCareerMaxCount(nCareer)
		local bClosed = Kin:IsCareerClosed(nCareer)
		if (not bClosed) and nMaxCareer>0 and Kin:CheckMyAuthority(authority) then
			nIdx = nIdx + 1;
			local btnObj = self["BtnCareer" .. nIdx];
			btnObj.nIdx = nIdx;
			btnObj.nCareer = nCareer

			local szName = CareerFixName[authority];
			btnObj.pPanel:Label_SetText("DarkName", szName);
			btnObj.pPanel:Label_SetText("LightName", szName);

			local nCareerCount = Lib:GetCountInTable(tbMemberList, fnEqual, btnObj.nCareer);
			if authority==Kin.Def.Authority_GrantLeader then
				nMaxCareer = 1
				nCareerCount = Kin:GetLeaderId()>0 and 1 or 0
			end
			local szNumber = string.format("%d/%d", nCareerCount, nMaxCareer);
			btnObj.pPanel:Label_SetText("LightNumber", szNumber);
			btnObj.pPanel:Label_SetText("DarkNumber", szNumber);
			btnObj.pPanel.OnTouchEvent = fnSelectBtn;
		end
	end

	for i = 1, #tbSortArray do
		self.pPanel:SetActive("BtnCareer" .. i, i <= nIdx);
	end

	if nIdx == 0 then
		self.ScrollView:Update(0, function() end);
		return;
	end

	local szCurBtn = "BtnCareer" .. (self.nIdx or 1);
	self[szCurBtn].pPanel:Toggle_SetChecked("Main", true);
	fnSelectBtn(self[szCurBtn]);
end

function tbUi:Update(nCareer,szSortFun,bIsDown)
	self.nCurCareer = nCareer;
	self.bIsDown = bIsDown
	self.szSortFun = szSortFun

	local tbMembers = Kin:GetMemberList();
	if szSortFun ~= nil then
		local fSortFun = Kin:GetSortFunction(szSortFun);
		tbMembers=fSortFun(tbMembers,bIsDown);
	end

	local tbItems = {};

	self.tbOrgMember = {};
	self.tbSelectMember = {};
	self.nCurMaxCareerCount = Kin:GetCareerMaxCount(nCareer);

	for _, tbMember in pairs(tbMembers) do
		if Kin:IsNormalCareer(tbMember.nCareer) then
			if tbMember.nCareer ~= Kin.Def.Career_Master then
				table.insert(tbItems, tbMember);
			elseif nCareer==Kin.Def.Career_Master or nCareer==Kin.Def.Career_Leader then
				table.insert(tbItems, tbMember);
			end
		end

		if nCareer==Kin.Def.Career_Leader then
			if tbMember.nMemberId==Kin:GetLeaderId() then
				self.tbOrgMember[tbMember.nMemberId] = 1
				self.tbSelectMember[tbMember.nMemberId] = true
			end
		else
			if tbMember.nCareer == nCareer then
				self.tbOrgMember[tbMember.nMemberId] = 1; -- 1为正常, 0为取消
				self.tbSelectMember[tbMember.nMemberId] = true;
			end
		end
	end

	local fnSelectItem = function (btnObj)
		if self.nCurMaxCareerCount<=0 then
			me.CenterMsg("3级家族后开放此职位")
			return
		end

		local bCheck = btnObj.pPanel:Toggle_GetChecked("Main");
		if bCheck and Lib:CountTB(self.tbSelectMember) >= self.nCurMaxCareerCount then
			btnObj.pPanel:Toggle_SetChecked("Main", false);
			me.CenterMsg("已达到职位最大上限, 请先取消其它选择");
			return;
		end

		if (nCareer~=Kin.Def.Career_Master and nCareer~=Kin.Def.Career_Leader) or not Kin:AmILeader() then
			local authority = Kin.Def.Career2Authority[btnObj.nCareer];
			if authority and not Kin:CheckMyAuthority(authority) then
				btnObj.pPanel:Toggle_SetChecked("Main", false);
				me.CenterMsg("没有权限改变对应职位");
				return;
			end
		end

		self.tbSelectMember[btnObj.nMemberId] = bCheck and btnObj.szName or nil;
		if self.tbOrgMember[btnObj.nMemberId] then
			self.tbOrgMember[btnObj.nMemberId] = bCheck and 1 or 0;
		end
	end

	local nLeaderId = Kin:GetLeaderId()
	local fnSetItem = function (itemObj, nIdx)
		local tbItem = tbItems[nIdx];
		itemObj.pPanel:Label_SetText("Name", tbItem.szName);
		local nVipLevel = tbItem.nVipLevel
		if not nVipLevel or  nVipLevel == 0 then
			itemObj.pPanel:SetActive("VIP", false)
		else
			itemObj.pPanel:SetActive("VIP", true)
			itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end

		local szCareerName = Kin.Def.Career_Name[tbItem.nCareer]
		if nLeaderId==tbItem.nMemberId then
			if Kin.Def.tbManagerCareers[tbItem.nCareer] then
				szCareerName = string.format("%s/%s", Kin.Def.Career_Name[Kin.Def.Career_Leader], szCareerName)
			else
				szCareerName = Kin.Def.Career_Name[Kin.Def.Career_Leader]
			end
		end

		local bShowLeaderStatus = false
		if nCareer==Kin.Def.Career_Leader then
			if tbItem.nMemberId==Kin:GetCandidateLeaderId() then
				bShowLeaderStatus = true
			end
		end
		itemObj.pPanel:SetActive("Leader", bShowLeaderStatus)
		itemObj.pPanel:SetActive("CheckBox", not bShowLeaderStatus)

		itemObj.pPanel:Label_SetText("Level", tbItem.nLevel);
		itemObj.pPanel:Label_SetText("Post", szCareerName);
		itemObj.pPanel:Label_SetText("Contribution", tbItem.nContribution);
		local szFactionIcon = Faction:GetIcon(tbItem.nFaction);
		itemObj.pPanel:Sprite_SetSprite("Faction", szFactionIcon);
		itemObj.pPanel:Toggle_SetChecked("CheckBox", self.tbSelectMember[tbItem.nMemberId] and true or false);
		itemObj.CheckBox.nMemberId = tbItem.nMemberId;
		itemObj.CheckBox.nCareer = tbItem.nCareer;
		itemObj.CheckBox.szName = tbItem.szName;
		itemObj.CheckBox.pPanel.OnTouchEvent = fnSelectItem;
	end

	self.ScrollView:Update(#tbItems, fnSetItem);

	self:UpdateCandidateLeader()
end

function tbUi:UpdateCandidateLeader()
	local szTip = ""
	local szName, szTimeLeft = Kin:GetCandidateLeaderInfo()
	if szName then
		szTip = string.format("[73cbd5]候选领袖：[FFFE0D]%s[-]  正式任命：[FFFE0D]%s[-][-]", szName, szTimeLeft)
	end
	self.pPanel:Label_SetText("Tip", szTip)
	self.pPanel:SetActive("BtnCancelAppointment", szName~=nil and Kin:AmILeader())
end


tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnCancelAppointment()
	Kin:CancelAppointLeader()
end

function tbUi.tbOnClick:BtnAppointment()
	if self.nCurCareer == Kin.Def.Career_Master then
		local tbBaseInfo = Kin:GetBaseInfo();
		local nSelectMaster, szName = next(self.tbSelectMember);
		if not nSelectMaster or not szName then
			me.CenterMsg("请先选择要被任命的成员");
			return;
		end
		if tbBaseInfo.nMasterId == nSelectMaster then
			me.CenterMsg("职位没有发生变化");
		else
			Kin:ChangeCareer(nSelectMaster, self.nCurCareer, tbBaseInfo.nMasterId, szName);
		end
		return;
	end

	local tbCancelMember = {};
	local tbChangeMember = {};
	for nMemberId, nFlag in pairs(self.tbOrgMember) do
		if nFlag == 0 then
			table.insert(tbCancelMember, nMemberId);
		end
	end

	for nMemberId, _ in pairs(self.tbSelectMember) do
		if self.tbOrgMember[nMemberId] ~= 1 then
			table.insert(tbChangeMember, nMemberId);
		end
	end

	if not next(tbCancelMember) and not next(tbChangeMember) then
		me.CenterMsg("职位没有发生变化");
		return;
	end

	local fnConfirm = function()
		if self.nCurCareer == Kin.Def.Career_Leader then
			Timer:Register(1, function ()
				Kin:AppointLeader(tbChangeMember[1])
			end)
		else
			Kin:ChangeCareers(self.nCurCareer, tbCancelMember, tbChangeMember);
		end
	end

	local bWarn, bCancelManager = Kin:ShouldSalaryWarn(tbCancelMember, tbChangeMember, self.nCurCareer)
	if Kin:WillSendSalaryIn24Hours() and bWarn then
		if bCancelManager then
			Ui:OpenWindow("MessageBox", "任职未满[FFFE0D]24小时[-]将无法获得工资，是否确定在此时替换职位成员？", { {fnConfirm},{}  }, {"确定", "取消"})
		else
			Ui:OpenWindow("MessageBox", "小提示：任职未满[FFFE0D]24小时[-]将无法获得工资", { {fnConfirm}, {}, }, {"确定任命", "取消"})
		end
	else
		fnConfirm()
	end
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

function tbUi.tbOnClick:ContributionTitle()
	self:ChangeSortState("Contribution");
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
	self:Update(self.nCurCareer,szBntInfo["SortFun"],false);

	tbSortStateArray[nIndex]["SortState"] = 2;
	self.pPanel:SetActive(szBntInfo["Name"].."Up", true);
	self.pPanel:SetActive(szBntInfo["Name"].."Down", false);
	self.pPanel:ChangePosition(szBntInfo["Name"], -7,0);
end

function tbUi:ChangeTitleToDown(szBntInfo,nIndex)
	self:Update(self.nCurCareer,szBntInfo["SortFun"],true);

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
