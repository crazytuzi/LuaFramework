local tbUi = Ui:CreateClass("MaterialCollectPanel");
local tbAct = Activity.MaterialCollectAct
function tbUi:OnOpen()
	RemoteServer.MaterialCollectCall("SynMaterialData")
end
function tbUi:UpdateUi()
	local tbMaterialData = tbAct:GetMaterialData() or {}
	local nServerScore = tbMaterialData.nServerScore or 0
	local nDonateScore = tbMaterialData.nDonateScore or 0
	local nMaterialCount = tbAct:GetMaterialCount(me) or 0
	self.pPanel:Label_SetText("ExpPercent", nServerScore)
	self.pPanel:Label_SetText("GetIntegralTxt", string.format("已捐献积分：%d", nDonateScore))
	self.pPanel:Label_SetText("GetAlcoholTxt", string.format("已获美酒数：%d", nMaterialCount))
	local fnOnClick = function (itemObj)
		if not itemObj.nShowItemId then
			return 
		end
		Ui:OpenWindow("ItemTips", "Item", nil, itemObj.nShowItemId)
	end
	for nId, v in ipairs(tbAct.tbProcessAward) do
		local itemObj = self["Box" .. nId]
		if itemObj then
			itemObj.pPanel:SetActive("Main", true)
			itemObj.pPanel:Label_SetText("LabelCount", v.nScore)
			itemObj.pPanel:SetActive("BoxMark", v.nScore <= nServerScore and true or false)
			itemObj.nShowItemId = v.nShowItemId
			itemObj.pPanel.OnTouchEvent = fnOnClick;
		end
	end
	self.pPanel:Sprite_SetFillPercent("ExpBar", math.min(nServerScore / tbAct.nServerMaxScore, 1))
end

function tbUi:RegisterEvent()
    return {
        { UiNotify.emNOTIFY_ON_SYN_MATERIAL_COLLECT_DATA, self.UpdateUi, self },
    }
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end;
	BtnDonate = function ()
		local bRet, szMsg = tbAct:CheckCanDonate(me)
		if not bRet then
			me.CenterMsg(szMsg, true)
			return
		end
		RemoteServer.MaterialCollectCall("Donate")
	end;
}