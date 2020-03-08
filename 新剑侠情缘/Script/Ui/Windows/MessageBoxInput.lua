
local tbUi = Ui:CreateClass("MessageBoxInput");

tbUi.tbOnClick = {
	BtnOk = function (self)
		local bRemainOpen, _;

		if self.fnCallBack then
			local tbOKCallback = {self.fnCallBack,  self.Txt:GetText()}
			_, bRemainOpen = Lib:CallBack(tbOKCallback)
		end
		if not bRemainOpen then
			Ui:CloseWindow(self.UI_NAME);
		end
	end,

	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME);
	end
}

function tbUi:OnOpen(szContent, fnCallBack)
	self.pPanel:Label_SetText("TextInfo", szContent)
	self.fnCallBack = fnCallBack
	self.Txt:SetText("");
end

function tbUi:OnClose()
	self.fnCallBack = nil;
end