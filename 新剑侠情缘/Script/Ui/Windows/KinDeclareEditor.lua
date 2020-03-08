local tbUi = Ui:CreateClass("KinDeclareEditor");

function tbUi:OnOpen()
	local tbBaseInfo = Kin:GetBaseInfo() or {};
	self.pPanel:Input_SetText("TxtFamilyDeclaration", tbBaseInfo.szPublicDeclare or "");
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("KinDeclareEditor");
end

function tbUi.tbOnClick:BtnSave()
	local szDeclare = self.pPanel:Input_GetText("TxtFamilyDeclaration");
	local tbKinBase = Kin:GetBaseInfo() or {};
	if Lib:Utf8Len(szDeclare) > Kin.Def.nMaxDeclareLength then
		me.CenterMsg("超过最大字数限制");
		return;
	end

	szDeclare = ChatMgr:Filter4CharString(szDeclare);

	if szDeclare ~= tbKinBase.szPublicDeclare then
		tbKinBase.szPublicDeclare = szDeclare;
		Kin:ChangePublicDeclare(szDeclare);

		UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "BaseInfo");
	end

	Ui:CloseWindow("KinDeclareEditor");
end
