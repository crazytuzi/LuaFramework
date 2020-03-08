local tbUi = Ui:CreateClass("AnniversaryTipPanel");

tbUi.fnDefaultClick = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

function tbUi:OnOpenEnd(tbData)
	-- { szText = , szBtnName = "", fnOnClick }
	local szBtnName = tbData.szBtnName 
	local szText = tbData.szText or ""
	self.fnOnClick = tbData.fnOnClick

	if szBtnName then
		self.pPanel:SetActive("Btn", true)
		self.pPanel:Label_SetText("BtnTxt", szBtnName)
	else
		self.pPanel:SetActive("Btn", false)
	end
	
	self.Txt:SetLinkText(szText)
	local tbTextSize = self.pPanel:Label_GetPrintSize("Txt");
	local tbSize = self.pPanel:Widget_GetSize("datagroup");
	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y);
	self.pPanel:DragScrollViewGoTop("datagroup");
	self.pPanel:UpdateDragScrollView("datagroup");
end


tbUi.tbOnClick = {};

tbUi.tbOnClick.Btn = function (self)
	local fnOnClick = self.fnOnClick or self.fnDefaultClick
	fnOnClick(self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

