
local tbUi = Ui:CreateClass("TextSelectPanel");

function tbUi:OnOpen(tbInfo, fnOnSelect)
	local nLength = 169 + math.ceil(#tbInfo / 2) * 60;
	self.pPanel:Widget_SetSize("Bg", 420, nLength);
	self.fnOnSelect = fnOnSelect;
	self.nSelect = 0;
	for i = 1, 14 do
		self.pPanel:SetActive("TitleItem" .. i, tbInfo[i] and true or false);
		self.pPanel:Toggle_SetChecked("TitleItem" .. i, false);
		self.pPanel:Button_SetText("TitleItem" .. i, tbInfo[i]);
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnSelete = function (self)
	self.fnOnSelect(self.nSelect);
	Ui:CloseWindow(self.UI_NAME);
end

for i = 1, 14 do
	tbUi.tbOnClick["TitleItem" .. i] = function (self)
		self.nSelect = i;
	end
end