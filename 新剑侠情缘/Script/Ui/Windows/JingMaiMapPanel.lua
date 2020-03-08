
local tbUi = Ui:CreateClass("JingMaiMapPanel");

function tbUi:OnOpen()

end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end