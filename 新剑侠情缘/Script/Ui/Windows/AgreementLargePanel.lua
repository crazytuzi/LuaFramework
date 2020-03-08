
local tbUi = Ui:CreateClass("AgreementLargePanel");
tbUi.tbAgreeTxt = {
};

function tbUi:OnOpen()
	local szFile1 = ReadTxtFile("Setting/Agreement/Agreement.txt");
	local szFile2 = ReadTxtFile("Setting/Agreement/Agreement2.txt");
	local fnFile1, nRet1 = loadstring("return {"..szFile1.."}")
	local fnFile2, nRe2 = loadstring("return {"..szFile2.."}")
	if not fnFile1 then
		print("reason", nRet1, nRe2)
	end
	self.tbAgreeTxt = {fnFile1(), fnFile2()}
end

function tbUi:OnOpenEnd()
	self.nCurPage1 = 1;
	self.nCurPage2 = 1;

	local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
	if tbInfo[1] then
		self.pPanel:SetActive("Toggle1", false);
		self.pPanel:SetActive("Toggle2", false);
		self.pPanel:Button_SetEnabled("BtnSure", true);
		self.pPanel:Button_SetSprite("BtnSure", "BtnMain_01");
	else
		self.pPanel:SetActive("Toggle1", true);
		self.pPanel:SetActive("Toggle2", true);
		self.pPanel:Toggle_SetChecked("Toggle1", false);
		self.pPanel:Toggle_SetChecked("Toggle2", false);
	end

	self:Update();
end

function tbUi:Update()
	self.pPanel:Label_SetText("Pages1", string.format("%d/%d", self.nCurPage1, #self.tbAgreeTxt[1]))
	self.pPanel:Label_SetText("Pages2", string.format("%d/%d", self.nCurPage2, #self.tbAgreeTxt[2]))

	self.TxtDesc1:SetLinkText(self.tbAgreeTxt[1][self.nCurPage1]);
	self.TxtDesc2:SetLinkText(self.tbAgreeTxt[2][self.nCurPage2]);

	for i = 1, 2 do
		local tbTextSize = self.pPanel:Label_GetPrintSize("TxtDesc"..i);
		local tbSize = self.pPanel:Widget_GetSize("datagroup"..i);
		self.pPanel:Widget_SetSize("datagroup"..i, tbSize.x, 50 + tbTextSize.y);
		self.pPanel:DragScrollViewGoTop("datagroup"..i);
		self.pPanel:UpdateDragScrollView("datagroup"..i);
	end
	self:UpdateButtonState()
end

function tbUi:UpdateButtonState()
	if self.pPanel:Toggle_GetChecked("Toggle1") and self.pPanel:Toggle_GetChecked("Toggle2") then
		self.pPanel:Button_SetEnabled("BtnSure", true)
		self.pPanel:Button_SetSprite("BtnSure", "BtnMain_01");
	else
		self.pPanel:Button_SetEnabled("BtnSure", false)
		self.pPanel:Button_SetSprite("BtnSure", "BtnMain_04");
	end
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnSure = function (self)
	local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
	local bFirstAgree = not tbInfo[1];
	tbInfo[1] = true
	Client:SaveUserInfo()
	Ui:CloseWindow(self.UI_NAME);

	if bFirstAgree then
		Ui:OpenWindow("NoticePanel");
	end
end

tbUi.tbOnClick.Toggle1 = function (self)
	self:UpdateButtonState()
end
tbUi.tbOnClick.Toggle2 = function (self)
	self:UpdateButtonState()
end

tbUi.tbOnClick.BtnLeft1 = function (self)
	self.nCurPage1 = math.max(1 , self.nCurPage1 - 1 )
	self:Update()
end

tbUi.tbOnClick.BtnRight1 = function (self)
	self.nCurPage1 = math.min(#self.tbAgreeTxt[1] , self.nCurPage1 + 1 )
	self:Update()
end

tbUi.tbOnClick.BtnLeft2 = function (self)
	self.nCurPage2 = math.max(1 , self.nCurPage2 - 1 )
	self:Update()
end

tbUi.tbOnClick.BtnRight2 = function (self)
	self.nCurPage2 = math.min(#self.tbAgreeTxt[2] , self.nCurPage2 + 1 )
	self:Update()
end

