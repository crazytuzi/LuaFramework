
local tbUi = Ui:CreateClass("Setting");

function tbUi:OnOpen()
end

tbUi.tbOnClick =  {}

function tbUi.tbOnClick:BtnBackToLogin()
	CloseServerConnect()
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow("Setting")
end