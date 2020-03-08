local tbUi = Ui:CreateClass("WeddingEnterPanel");
function tbUi:OnOpen()
	Wedding:RequestWeddingMap()
end

function tbUi:OnOpenEnd()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	
	local tbAllWedding = Wedding:GetWeddingMap()
	local fnOnClick = function(itemObj)
		local nMapId = itemObj.nMapId
		if not nMapId then
			me.CenterMsg("未知婚礼", true)
			return
		end
		RemoteServer.OnWeddingRequest("ApplyEnterWedding", nMapId);
	end
	local fnSetItem = function(itemObj, nIdx)
		local tbWeddingInfo = tbAllWedding[nIdx]
		if tbWeddingInfo then
			local nMapId = tbWeddingInfo.nMapId
			local nWeddingLevel = tbWeddingInfo.nLevel
			local tbPlayerInfo = tbWeddingInfo.tbPlayer or {}
			local szBoyName = tbPlayerInfo[Gift.Sex.Boy] and tbPlayerInfo[Gift.Sex.Boy].szName or "神秘人"
			local szGirlName = tbPlayerInfo[Gift.Sex.Girl] and tbPlayerInfo[Gift.Sex.Girl].szName or "神秘人"
			local tbMapSetting = Wedding.tbWeddingLevelMapSetting[nWeddingLevel]
			local szWeddingName = tbMapSetting and tbMapSetting.szWeddingName or "婚礼"
			itemObj.pPanel:Label_SetText("Name1", szBoyName)
			itemObj.pPanel:Label_SetText("Name2", szGirlName)
			itemObj.pPanel:Label_SetText("Type", szWeddingName)
			itemObj["BtnApply"].nMapId = nMapId
			itemObj["BtnApply"].pPanel.OnTouchEvent = fnOnClick;
		end
	end
	self.ScrollView:Update(#tbAllWedding, fnSetItem);
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_SYNC_WEDDING_MAP, self.RefreshUi, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
}