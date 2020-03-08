
local tbUi = Ui:CreateClass("TextSelectPanel2");

function tbUi:OnOpen(tbInfo, fnCallBack)
	if #tbInfo ~= 4 or not fnCallBack then
		return 0;
	end

	self.pPanel:Label_SetText("Title", tbInfo[1]);
	self.pPanel:Label_SetText("Content", tbInfo[2]);
	self.pPanel:Label_SetText("Title1", tbInfo[3]);
	self.pPanel:Label_SetText("Title2", tbInfo[4]);

	self.pPanel:Label_SetText("Name1", "点击输入");
	self.pPanel:Label_SetText("Name2", "点击输入");
	self.pPanel:Input_SetText("Name1", "");
	self.pPanel:Input_SetText("Name2", "");
	self.fnCallBack = fnCallBack;
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnCancel = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnSure = function (self)
	local szText1 = self.pPanel:Input_GetText("Name1");
	local szText2 = self.pPanel:Input_GetText("Name2");
	local _, bRemainOpen = Lib:CallBack({self.fnCallBack, szText1, szText2});
	if not bRemainOpen then
		Ui:CloseWindow(self.UI_NAME);
	end
end