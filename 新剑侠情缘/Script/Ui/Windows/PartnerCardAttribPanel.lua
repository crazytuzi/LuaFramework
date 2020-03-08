local tbUi = Ui:CreateClass("PartnerCardAttribPanel");
function tbUi:OnOpen(tbAttrib, pPlayerAsync)
	self["Container"]:RefreshData(tbAttrib, pPlayerAsync)
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end