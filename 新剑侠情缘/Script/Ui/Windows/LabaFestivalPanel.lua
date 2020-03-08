local tbUi = Ui:CreateClass("LabaFestivalPanel");
local tbAct = Activity.LabaAct
function tbUi:OnOpen()
	tbAct:RequestMaterialData()
	self:RefreshUi()
end

function tbUi:RefreshUi()
	local tbData = tbAct:GetMaterialData()
	local tbMaterial = tbData.tbMaterial or {}
	local tbCommitMaterial = tbData.tbCommitMaterial or {}
	local nComposeCount = tbData.nComposeCount or 0
	local nComposeUpdateTime = tbData.nComposeUpdateTime or 0
	local nAssistCount = tbData.nAssistCount or 0

	local tbShowMaterial = tbAct:GetShowMaterial()
	local fnHelp = function(itemObj)
		RemoteServer.LabaActClientCall("AskAssist", itemObj.nId)
	end
	local fnCommit = function(itemObj)
		RemoteServer.LabaActClientCall("CommitMaterial", itemObj.nId)
	end
	local fnSetItem = function(itemObj, nIdx)
		local tbInfo = tbShowMaterial[nIdx] or {}
		local nId = tbInfo.nId or 0
		local tbMaterialInfo = tbAct.tbMaterial[nId] or {}
		local szName = tbMaterialInfo.szName or "-"
		itemObj.pPanel:Label_SetText("TxtItemName", szName)
		local nHave = tbMaterial[nId] or 0
		local szColor = nHave >= tbAct.nComposeNeed and "47FF47FF" or "FF7070FF"
		local szHave = string.format("[%s]%s/%s[-]", szColor, nHave, tbAct.nComposeNeed)
		itemObj.pPanel:Label_SetText("NumberRed", szHave)
		local bHave = (nHave >= tbAct.nComposeNeed)
		local bFinish = ((tbCommitMaterial[nId] or 0) >= tbAct.nComposeNeed)
		local bCanCommit = (nHave >= tbAct.nComposeNeed) and not bFinish
		local bNeedAssist = (not bHave and not bFinish)
		itemObj["BtnDelivery"].pPanel:SetActive("Main", bCanCommit)
		itemObj["BtnHelp"].pPanel:SetActive("Main", bNeedAssist)
		itemObj.pPanel:SetActive("Completed", bFinish)
		itemObj["BtnHelp"].nId = nId
		itemObj["BtnHelp"].pPanel.OnTouchEvent = fnHelp
		itemObj["BtnDelivery"].nId = nId
		itemObj["BtnDelivery"].pPanel.OnTouchEvent = fnCommit
	end
	self.ScrollView:Update(tbShowMaterial, fnSetItem)
	self.pPanel:Label_SetText("TxtSurplus", "当天剩余协助次数：")
	self.pPanel:Label_SetText("TxtNumber", tostring(tbAct.nMaxAssistCount - nAssistCount))
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{

		{ UiNotify.emNOTIFY_SYNC_LABA_ACT_MATERIAL_DATA, self.RefreshUi, self},

	};
	return tbRegEvent;
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnFriendAssistance = function (self)
		Ui:OpenWindow("LabaFestivalFriendPanel")
	end;
}
