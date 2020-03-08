local tbUi = Ui:CreateClass("LabaFestivalAssistPanel");
local tbAct = Activity.LabaAct
function tbUi:OnOpen(tbData, nShowId, nShowComposeCount)
	-- nShowId，nShowComposeCount为了打开连接显示单独材料信息的时候用到，协助完成回调
	self:RefreshUi(tbData, nShowId, nComposeCount)
end

function tbUi:RefreshUi(tbData, nShowId, nShowComposeCount)
	local fnAssist = function (itemObj)
		RemoteServer.LabaActClientCall("Assist", itemObj.dwID, itemObj.nId, nShowId, nShowComposeCount)
	end
	local dwID = tbData.dwID or 0
	local szName = tbData.szName or "-"
	self.pPanel:Label_SetText("Title", szName .."的协助")
	local tbLack = tbData.tbLack or {}
	local fnSetItem = function(itemObj, nIdx)
		local tbInfo = tbLack[nIdx]
		local nId = tbInfo.nId
		local nHave = tbInfo.nHave or 0
		local szColor = nHave >= tbAct.nComposeNeed and "47FF47FF" or "FF7070FF"
		local szHave = string.format("[%s]%s/%s[-]", szColor, nHave, tbAct.nComposeNeed)
		local tbMaterialInfo = tbAct.tbMaterial[nId] or {}
		local szMaterialName = tbMaterialInfo.szName or "-"
		itemObj.pPanel:Label_SetText("TxtItemName", szMaterialName);
		itemObj.pPanel:Label_SetText("NumberGreen", szHave);
		itemObj["BtnHelp"].dwID = dwID
		itemObj["BtnHelp"].nId = nId
		itemObj["BtnHelp"].pPanel.OnTouchEvent = fnAssist
	end
	self.ScrollView:Update(tbLack, fnSetItem)
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_SYNC_LABA_ACT_ASSIST_DATA, self.RefreshUi, self},

	};
	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
}