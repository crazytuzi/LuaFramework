
local tbUi = Ui:CreateClass("AgreementPanel");
tbUi.tbAgreeTxt = {
};

function tbUi:OnCreate()
	local szFile1 = ReadTxtFile("Setting/Agreement/Agreement.txt");
	local fnFile1, nRet1 = loadstring("return {"..szFile1.."}")
	if not fnFile1 then
		Log("Error reason!!!!!", nRet1, nRe2)
		return 0
	end
	self.tbAgreeTxt = fnFile1();
end

function tbUi:OnOpenEnd()
	self.nCurPage =  1;
	self:Update();
	
	local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
	if tbInfo[1] then
		self.pPanel:Button_SetText("BtnSure", "关闭")
		self.pPanel:SetActive("BtnRefuse", false)
	else
		self.pPanel:Button_SetText("BtnSure", "接受")
		self.pPanel:SetActive("BtnRefuse", true)
	end
end

function tbUi:Update()
	self.pPanel:Label_SetText("Pages", string.format("%d/%d", self.nCurPage, #self.tbAgreeTxt))

	local szCurMsg = self.tbAgreeTxt[self.nCurPage];
	self.TxtDesc:SetLinkText(szCurMsg);

	local tbTextSize = self.pPanel:Label_GetPrintSize("TxtDesc");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnSure = function (self)
	local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
	tbInfo[1] = true
	Client:SaveUserInfo()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnRefuse = function (self)
	local fnYes = function ()
		Sdk:DirectExit();	
	end

	me.MsgBox("您确认要拒绝用户协议吗？拒绝后将直接退出客户端，无法进入游戏哦",{
		{"确认", fnYes},
		{"取消"}
		})
	
end

tbUi.tbOnClick.BtnLeft = function (self)
	self.nCurPage = math.max(1 , self.nCurPage - 1 )
	self:Update()
end

tbUi.tbOnClick.BtnRight = function (self)
	self.nCurPage = math.min(#self.tbAgreeTxt , self.nCurPage + 1 )
	self:Update()
end