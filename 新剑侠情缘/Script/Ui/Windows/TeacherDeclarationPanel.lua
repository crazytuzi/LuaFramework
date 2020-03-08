local tbUi = Ui:CreateClass("TeacherDeclarationPanel")

function tbUi:OnOpen()
	local tbMainInfo = TeacherStudent:GetMainInfo()
	local szNotice = TeacherStudent:GetTeacherNotice(tbMainInfo and tbMainInfo.tbSettings.szNotice or "")
	self.szOrgNotice = szNotice
	self.pPanel:Input_SetText("TxtFamilyDeclaration", szNotice)
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:BtnSave()
	local szDeclare = self.pPanel:Input_GetText("TxtFamilyDeclaration")
	if Lib:Utf8Len(szDeclare) > TeacherStudent.Def.nTeacherDeclarationMax then
		me.CenterMsg("超过最大字数限制")
		return
	end

	szDeclare = ChatMgr:Filter4CharString(szDeclare)

	if szDeclare~="" and szDeclare~=self.szOrgNotice then
		TeacherStudent:ChangeTeacherNotice(szDeclare)
	end

	Ui:CloseWindow(self.UI_NAME)
end
