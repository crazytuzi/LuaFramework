local tbUi = Ui:CreateClass("WeddingProcessPanel");
function tbUi:OnOpen(nWeddingLevel, nCurProcess)
	self:Update(nWeddingLevel, nCurProcess)
end

function tbUi:Update(nWeddingLevel, nCurProcess)
	local tbWeddingSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
	if not tbWeddingSetting then
		return
	end
	self.pPanel:Label_SetText("Title", "流程")
	self.pPanel:Label_SetText("Title1", tbWeddingSetting.szWeddingName)
	local tbSchdule = tbWeddingSetting.tbSchdule
	local fnSetItem = function (itemObj, nIdx)
		itemObj.pPanel:Label_SetText("CashGiftTitle", tbSchdule[nIdx].szProcess)
		itemObj.pPanel:SetActive("Sprite", tbSchdule[nIdx].nProcess <= nCurProcess)
		local szSprite = tbSchdule[nIdx].nProcess == nCurProcess and "RedPaperBg2" or "RedPaperBg1"
		itemObj.pPanel:Sprite_SetSprite("Main", szSprite)
	end
	self.ScrollView:Update(tbSchdule, fnSetItem)
	local nGoIdx 
	for nIdx, v in ipairs(tbSchdule) do
		if v.nProcess == nCurProcess then
			nGoIdx = nIdx
			break
		end
	end
	if nGoIdx and nGoIdx >= 6 then
		self.ScrollView.pPanel:ScrollViewGoToIndex("Main", nGoIdx)
	end
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_WEDDING_PROCESS_CHANGE,	self.Update, self},
	};

	return tbRegEvent;
end

tbUi.tbOnClick = 
{
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME);
    end,
}