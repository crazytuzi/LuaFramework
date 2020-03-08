local tbUi = Ui:CreateClass("WeddingBookDetailPanel");
function tbUi:OnOpen(nWeddingLevel)
	self.nWeddingLevel = nWeddingLevel
	Wedding:RequestSynSchedule()
end

function tbUi:OnOpenEnd(nWeddingLevel)
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local nWeddingLevel = self.nWeddingLevel
	local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	if not tbMapSetting then
		return 
	end
	local tbBook = Wedding:GetHadBook(nWeddingLevel)
	local bHadBook = next(tbBook)
	self.pPanel:SetActive("Tip", not bHadBook)
	self.pPanel:SetActive("ScrollView", bHadBook)
	local fnSetItem = function(itemObj, nIdx)
		local nTime = tbBook[nIdx].nTime
		local tbDetail = tbBook[nIdx].tbDetail
		local tbPlayerBookInfo = tbDetail[1]
		if tbPlayerBookInfo then
			local szTime = tbMapSetting.fnGetDateStr(nTime or 0)
			itemObj.pPanel:Label_SetText("Time", szTime)
			local tbPlayerInfo = tbPlayerBookInfo.tbPlayerInfo or {}
			local szBoyName = tbPlayerInfo[Gift.Sex.Boy] and tbPlayerInfo[Gift.Sex.Boy].szName or ""
			local szGirlName = tbPlayerInfo[Gift.Sex.Girl] and tbPlayerInfo[Gift.Sex.Girl].szName or ""
			itemObj.pPanel:Label_SetText("Name1", szBoyName)
			itemObj.pPanel:Label_SetText("Name2", szGirlName)
		end
	end
	self.ScrollView:Update(#tbBook, fnSetItem);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_WEDDING_SCHEDULE, self.RefreshUi, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
}