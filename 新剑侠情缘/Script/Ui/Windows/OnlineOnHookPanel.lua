local tbUi = Ui:CreateClass("OnlineOnHookPanel");

function tbUi:OnOpen()

end

tbUi.tbOnClick = {
	BtnEnd = function (self)
		OnHook:ChangeOnLineOnHook()
	end
}