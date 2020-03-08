local tbUi = Ui:CreateClass("KinDetailPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateData, self },
		{ UiNotify.emNOTIFY_GROUP_INFO, self.GroupNotify, self },
		{ UiNotify.emNOTIFY_ONSYNC_DOMAIN_BASE,   self.UpdateData, self },

	};

	return tbRegEvent;
end

local tbContainerName = {
	["FamilyInfo"] = "BtnFamilyInfo",
	["FamilyMembers"] = "BtnFamilyMember",
	["FamilyBuilding"] = "BtnFamilyBuilding",
	["DomainBattleMain"] = "BtnDomainBattleMain",
}

function tbUi:OnOpen()
	if not Kin:HasKin() then
		me.CenterMsg("当前没有家族，请先加入一个家族");
		Ui:OpenWindow("KinJoinPanel");
		return 0;
	end

	Kin:SyncMascotOpenStatus()
	Kin:UpdateBaseInfo();
	Kin:UpdateRedPoint();
	Kin:UpdateMemberCareer();
	self.pPanel:SetActive("BtnDomainBattleMain", DomainBattle:UpdateDomainBattleInfo() and true or false)
		
	Guide.tbNotifyGuide:ClearNotifyGuide("KinJoin");
end

function tbUi:ToggleCheck(szTargetName)
	for szName, szBtnName in pairs(tbContainerName) do
		self.pPanel:Toggle_SetChecked(szBtnName, szName==szTargetName)
	end
end

function tbUi:OnOpenEnd(szContainerName)
	self.szCurContainer = szContainerName or self.szCurContainer or "FamilyInfo";
	self:SwitchContainer(self.szCurContainer);
	self:ToggleCheck(self.szCurContainer)
end

function tbUi:SwitchContainer(szContainerName)
	for szName, _ in pairs(tbContainerName) do
		if szContainerName == szName then
			self.szCurContainer = szContainerName;
			self.pPanel:SetActive(szName, true);
			self[szName]:Init();
		else
			self.pPanel:SetActive(szName, false);
		end
	end

	Kin:UpdateRedPoint();
end

function tbUi:OnClose()
	Kin:UpdateRedPoint();
end

function tbUi:GroupNotify(...)
	self.FamilyInfo:GroupNotify(...);
end

function tbUi:UpdateData(szType)
	if self.szCurContainer == "FamilyInfo" then
		self.FamilyInfo:UpdateData(szType);
	end

	if self.szCurContainer == "FamilyMembers" then
		self.FamilyMembers:UpdateData(szType);
	end

	if self.szCurContainer == "FamilyBuilding" and szType == "Building" then
		self.FamilyBuilding:Update();
	end

	if self.szCurContainer == "DomainBattleMain" then
		self.DomainBattleMain:RefreshUi();
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};


function tbUi.tbOnClick:BtnFamilyInfo()
	self:SwitchContainer("FamilyInfo");
end

function tbUi.tbOnClick:BtnFamilyMember()
	self:SwitchContainer("FamilyMembers");
end

function tbUi.tbOnClick:BtnFamilyBuilding()
	self:SwitchContainer("FamilyBuilding");
end

function tbUi.tbOnClick:BtnDomainBattleMain()
	self:SwitchContainer("DomainBattleMain");
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinDetailPanel");
end
