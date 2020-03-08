local tbUi = Ui:CreateClass("KinTitleEditor");

function tbUi:Init()
	self.tbItemsData = Kin:GetTitleSettingData();

	local fnSetItem = function (itemObj, nIndex)
		local tbItemData = self.tbItemsData[nIndex];
		local szCareerName = Kin.Def.Career_Name[tbItemData.nCareer];
		itemObj.pPanel:Label_SetText("TxMemberName", tbItemData.szName);
		local nVipLevel = tbItemData.nVipLevel
		if not nVipLevel or  nVipLevel == 0 then
			itemObj.pPanel:SetActive("VIP", false)
		else
			itemObj.pPanel:SetActive("VIP", true)
			itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end

		itemObj.pPanel:Label_SetText("TxtCareer", szCareerName);
		if version_vn or version_th then
			itemObj.pPanel:UIInput_SetCharLimit("TxtTitle", Kin.Def.nMaxKinTitleLen);
		elseif not version_tx then
			itemObj.pPanel:UIInput_SetCharLimit("TxtTitle", 0);
		end
		itemObj.pPanel:Input_SetText("TxtTitle", tbItemData.szKinTitle or szCareerName);
		itemObj.nIndex = nIndex;
		itemObj.RootObj = self;
	end

	self.ScrollView:Update(self.tbItemsData, fnSetItem);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

local TitleSettingCarrer = {
	[Kin.Def.Career_Elite] = Kin.Def.Career_Elite,
	[Kin.Def.Career_Normal] = Kin.Def.Career_Normal,
	[Kin.Def.Career_New]    = Kin.Def.Career_New,
	[Kin.Def.Career_Retire] = Kin.Def.Career_Retire,
};

function tbUi.tbOnClick:BtnSaveChange()
	local tbSpeialTitle = {};
	local tbCommonTitle = {};
	local tbSpMap, tbCoMap = Kin:GetTitleSettingMap();

	local nLeaderId = Kin:GetLeaderId()
	local szLeaderTitle = ""
	for _, tbData in pairs(self.tbItemsData) do
		if TitleSettingCarrer[tbData.nCareer] then
			if tbData.szKinTitle ~= tbCoMap[tbData.nCareer] then
				tbCommonTitle[tbData.nCareer] = tbData.szKinTitle;
			end
		else
			if tbData.szKinTitle ~= tbSpMap[tbData.nMemberId] then
				if tbData.nCareer==Kin.Def.Career_Leader then
					szLeaderTitle = tbData.szKinTitle
				else
					tbSpeialTitle[tbData.nMemberId] = tbData.szKinTitle;
				end
			end
		end
	end

	RemoteServer.OnKinRequest("SetKinTitle", tbSpeialTitle, tbCommonTitle, szLeaderTitle);
end

local tbEditorItem = Ui:CreateClass("KinTitleEditItem");

tbEditorItem.tbOnSelect = {};

function tbEditorItem.tbOnSelect:TxtTitle(szWndName, bSelect)
	-- Log("TxtTitle tbOnSelect", szWndName, tostring(bSelect));
	if bSelect then
		return
	end

	local szTitle = self.pPanel:Input_GetText("TxtTitle");
	local tbItemData = self.RootObj.tbItemsData[self.nIndex];
	local nCareer = tbItemData.nCareer
	local bTitleAvailable = CheckNameAvailable(szTitle) and (not Kin:IsCareerTitleForbidden(nCareer, szTitle))
	if version_tx or version_th or version_kor then
		if szTitle == "" or Lib:Utf8Len(szTitle) > Kin.Def.nMaxKinTitleLen or not bTitleAvailable then
			if not bTitleAvailable then
				me.CenterMsg(string.format("[%s]称谓不合法", szTitle));
			end
			local szCareerName = Kin.Def.Career_Name[nCareer];
			self.pPanel:Input_SetText("TxtTitle", tbItemData.szKinTitle or szCareerName);
		else
			tbItemData.szKinTitle = szTitle;
		end
	else
		if szTitle == "" or string.len(szTitle) > Kin.Def.nMaxKinTitleLen or not bTitleAvailable then
			if not bTitleAvailable then
				me.CenterMsg(string.format("[%s]称谓不合法", szTitle));
			end
			local szCareerName = Kin.Def.Career_Name[nCareer];
			self.pPanel:Input_SetText("TxtTitle", tbItemData.szKinTitle or szCareerName);
		else
			tbItemData.szKinTitle = szTitle;
		end
	end
end
