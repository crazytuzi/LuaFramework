
local tbUi = Ui:CreateClass("SetNumber");

function tbUi:OnOpenEnd(szTitle, szTips, nCurNumber, nMinNumber, nMaxNumber, fnOK, fnCancel)
	self.pPanel:Label_SetText("Title", szTitle);
	self.pPanel:Label_SetText("Tips", szTips);
	self.pPanel:Label_SetText("Number", nCurNumber);
	self.nMinNumber = nMinNumber;
	self.nMaxNumber = nMaxNumber;
	self.fnOK = fnOK;
	self.fnCancel = fnCancel;
end

function tbUi:UpdateNumber(nNumber)
	local nResult = math.max(math.min(nNumber or 0, self.nMaxNumber), self.nMinNumber);
	self.pPanel:Label_SetText("Number", nResult);
	return nResult;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	if self.fnCancel then
		self.fnCancel(tonumber(self.pPanel:Label_GetText("Number")) or 0);
	end
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnOk = function (self)
	if self.fnOK then
		self.fnOK(tonumber(self.pPanel:Label_GetText("Number")) or 0);
	end
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnNumber = function (self)
	local function fnUpdate(nInput)
		local nResult = self:UpdateNumber(nInput);
		return nResult;
	end
	Ui:OpenWindow("NumberKeyboard", fnUpdate);
end

tbUi.tbOnClick.BtnMinus = function (self)
	local nCurNumber = tonumber(self.pPanel:Label_GetText("Number")) or 0;
	self:UpdateNumber(nCurNumber - 1);
end

tbUi.tbOnClick.BtnPlus = function (self)
	local nCurNumber = tonumber(self.pPanel:Label_GetText("Number")) or 0;
	self:UpdateNumber(nCurNumber + 1);
end

