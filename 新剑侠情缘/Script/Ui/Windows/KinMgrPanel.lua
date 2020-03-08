local tbUi = Ui:CreateClass("KinMgrPanel");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_KIN_DATA, self.UpdateData, self },
		{UiNotify.emNOTIFY_LEADER_INFO_CHANGE, self.RefreshLeaderInfo, self},
	};

	return tbRegEvent;
end

function tbUi:OnOpen()
end

function tbUi:OnOpenEnd()
	local bEditeTitle = Kin:CheckMyAuthority(Kin.Def.Authority_EditKinTitle)
	self.pPanel:SetActive("BtnTitlePage", bEditeTitle)

	local tbKinBaseInfo = Kin:GetBaseInfo()
	self.pPanel:SetActive("BtnPowerPage", tbKinBaseInfo.nMasterId==me.dwID)

	local bCanGrant = Kin:CheckMyAuthority(Kin.Def.Authority_GrantOlder);
	if bCanGrant or Kin:AmILeader() then
		self.tbOnClick.BtnCareerPage(self);
		self.pPanel:Toggle_SetChecked("BtnCareerPage", true);
	else
		self.tbOnClick.BtnTitlePage(self);
		self.pPanel:Toggle_SetChecked("BtnTitlePage", true);
	end
end

function tbUi:UpdateData(szType)
	if szType == "MemberList" then
		local bCanGrant = Kin:CheckMyAuthority(Kin.Def.Authority_GrantOlder);
		local bEditeTitle = Kin:CheckMyAuthority(Kin.Def.Authority_EditKinTitle);
		if not bCanGrant and not bEditeTitle then
			Ui:CloseWindow(self.UI_NAME);
			return;
		end

		self:Switch(self.szCurPage);
	end
end

local tbPageName = {
	["CareerPage"] = "BtnCareerPage",
	["PowerSettingPage"] = "BtnPowerPage",
	["TitleEditorPage"] = "BtnTitlePage",
}

function tbUi:Switch(szPage)
	self.szCurPage = szPage;

	for szPageName, _ in pairs(tbPageName) do
		if szPage == szPageName then
			self.pPanel:SetActive(szPageName, true);
			self[szPageName]:Init();
		else
			self.pPanel:SetActive(szPageName, false);
		end
	end
end

function tbUi:RefreshLeaderInfo()
	self:Switch("CareerPage")
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi:ResetToggle()
	self.pPanel:Toggle_SetChecked(tbPageName[self.szCurPage], true);
end

function tbUi.tbOnClick:BtnCareerPage()
	local bCanGrant = Kin:CheckMyAuthority(Kin.Def.Authority_GrantOlder);
	if not bCanGrant and not Kin:AmILeader() then
		me.CenterMsg("没有权限进行职位管理");
		self:ResetToggle();
		return;
	end

	self:Switch("CareerPage");
end

function tbUi.tbOnClick:BtnPowerPage()
	local tbKinBaseInfo, _ = Kin:GetBaseInfo();
	if tbKinBaseInfo.nMasterId ~= me.dwID then
		me.CenterMsg("只有族长能进行权限设置");
		self:ResetToggle();
		return;
	end

	self:Switch("PowerSettingPage");
end

function tbUi.tbOnClick:BtnTitlePage()
	local bEditeTitle = Kin:CheckMyAuthority(Kin.Def.Authority_EditKinTitle);
	if not bEditeTitle then
		me.CenterMsg("没有权限进行称谓编辑");
		self:ResetToggle();
		return;
	end

	self:Switch("TitleEditorPage");
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinMgrPanel");
end

