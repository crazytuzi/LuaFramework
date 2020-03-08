
local tbUi = Ui:CreateClass("InputBox");

tbUi.tbOnClick = {
	BtnCenter = function (self)
		local bRemainOpen, _;
		if self.fnCallBack then
			local tbOKCallback = {self.fnCallBack,  self.Input:GetText()}
			_, bRemainOpen = Lib:CallBack(tbOKCallback)
		end
		if not bRemainOpen then
			Ui:CloseWindow(self.UI_NAME);
		end
	end,

	BtnTClose = function (self)
		Ui:CloseWindow(self.UI_NAME);
	end
}

function tbUi:OnOpen(szTitle, fnCallBack, bShowClose)
	self.pPanel:Label_SetText("Title", szTitle)
	self.fnCallBack = fnCallBack
	self.Input:SetText("")
	self.pPanel:SetActive("BtnTClose", bShowClose and true or false);
end
