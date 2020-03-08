local tbUi = Ui:CreateClass("WeddingDatePanel");
function tbUi:OnOpen(nWeddingLevel)
	self.nWeddingLevel = nWeddingLevel
	self.nIdx = nil
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[self.nWeddingLevel]
	if not tbMapSetting then
		return
	end
	self.tbCanBook = Wedding:GetCanBookSchdule(self.nWeddingLevel)
	local fnOnClick = function(itemObj)
		self.nIdx = itemObj.nIdx
		Ui:CloseWindow(self.UI_NAME)
	end
	local fnSetItem = function(itemObj, nIdx)
		local nTime = self.tbCanBook[nIdx]
		local szTime = tbMapSetting.fnGetDateStr(nTime)
		itemObj.pPanel:Label_SetText("Date", szTime)
		itemObj.nIdx = nIdx
		itemObj.pPanel.OnTouchEvent = fnOnClick
	end
	self.ScrollView:Update(#self.tbCanBook, fnSetItem);
end

function tbUi:OnClose()
	UiNotify.OnNotify(UiNotify.emNOTIFY_WEDDING_DATE_SELECT_FINISH, self.tbCanBook[self.nIdx]);
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
}