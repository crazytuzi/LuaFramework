
local tbUi = Ui:CreateClass("MessageBoxSelect");

tbUi.tbOnClick = {
	BtnOk = function (self, tbGameObj)
		local bRemainOpen, _;
		if self.fnOKCallback then
			local nSelIndex = self:GetSelIndex()
			_, bRemainOpen = Lib:CallBack({self.fnOKCallback,nSelIndex })
		end
		if not bRemainOpen then
			Ui:CloseWindow(self.UI_NAME);
		end
	end,
	BtnClose = function (self, tbGameObj)
		local nRet;
		if self.fnCancelCallback then
			nRet = Lib:CallBack({self.fnCancelCallback})
		end
		if nRet ~= 0 then
			Ui:CloseWindow(self.UI_NAME);
		end
	end,
}

function tbUi:GetSelIndex()
	for i=1,3 do
		if self.pPanel:Toggle_GetChecked("Btn" .. i)  then
			return i;
		end
	end
	return 1;
end

function tbUi:OnOpen(tbTexts, tbProc, tbBtnTxt)
	if #tbTexts == 0 or #tbTexts > 3 then
		Log("Error!!!! MessageBoxSelect")
		return 0
	end
	for i=1,3 do
		local szText = tbTexts[i]
		if szText then
			self.pPanel:SetActive("Btn" .. i, true)
			self.pPanel:Label_SetText(string.format("TextInfo%d1", i), szText)
			self.pPanel:Label_SetText(string.format("TextInfo%d2", i), szText)
		else
			self.pPanel:SetActive("Btn" .. i, false)
		end
	end

	if tbProc then
		self.fnOKCallback = tbProc[1];
		self.fnCancelCallback = tbProc[2];
	else
		self.fnOKCallback = nil;
		self.fnCancelCallback = nil;
	end

	tbBtnTxt = tbBtnTxt or {"确定", "取消"};

	self.pPanel:Label_SetText("TextOk", tbBtnTxt[1] or "确定");
	self.pPanel:Label_SetText("TextClose", tbBtnTxt[2] or "取消");
end

