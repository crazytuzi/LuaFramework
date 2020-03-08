local tbUi = Ui:CreateClass("MaterialBoxPanel");
local tbAct = Activity.MaterialCollectAct
function tbUi:OnOpen()
	RemoteServer.MaterialCollectCall("SynMaterialData")
end

function tbUi:UpdateUi()
	for i=1, 9 do
		self["Item" ..i].pPanel:SetActive("Main", false)
	end
	local tbMaterialData = tbAct:GetMaterialData() or {}
	local tbCollect = tbMaterialData.tbCollect or {}
	local bCollectAward = tbMaterialData.bCollectAward
	local fnClick = function (itemObj)
		Ui:OpenWindow("ItemTips", "Item", nil, itemObj.nItemId, nil, nil, itemObj.nCount)		
	end
	for nIdx, v in ipairs(tbAct.tbCollect) do
		local itemObj = self["Item" ..nIdx]
		if itemObj then
			itemObj.pPanel:SetActive("Main", true)
			local nCount = tbCollect[v.nId] or 0
			itemObj:SetGenericItem({"Item", v.nShowItemId, nCount})
			local bGray = nCount <= 0 and true or false
			local szAtlas, szSprite = Item:GetIcon(v.nIconId);
			if bGray then
				itemObj.pPanel:Sprite_SetSpriteGray("ItemLayer", szSprite, szAtlas)
			else
				itemObj.pPanel:Sprite_SetSprite("ItemLayer", szSprite, szAtlas)
			end
			itemObj.nItemId = v.nShowItemId
			itemObj.nCount = nCount
			itemObj.fnClick = fnClick
		 	local nValue = tbAct:GetMaterialValue()
			self.pPanel:Label_SetText("RankingTxt", string.format("总价值：%d", nValue))
		end
	end
	local nCollectKind = tbAct:GetMaterialValueKind()
	self.pPanel:Sprite_SetFillPercent("Bar", math.min(nCollectKind / #tbAct.tbCollect, 1))
	self.pPanel:Label_SetText("BarPercent", string.format("%d/%d", nCollectKind, #tbAct.tbCollect))
	self.pPanel:Sprite_SetSprite("Box", bCollectAward and "BoxOpen" or "Box")
	local bRet = tbAct:CheckCollectAward(me)
	self.pPanel:SetActive("texiao_12", bRet and true or false)
	self.pPanel:SetActive("texiao_22", bRet and true or false)
	self.pPanel:SetActive("BoxMark2", bRet and true or false)
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
	BtnSee = function (self)
		Ui:CloseWindow(self.UI_NAME)
		Ui:OpenWindow("RankBoardPanel", "MaterialCollectAct")
	end;
	Box = function ()
		local bRet, szMsg = tbAct:CheckCollectAward(me)
		if not bRet then
			Ui:OpenWindow("ItemTips", "Item", nil, tbAct.nCollectFullShowItem)
			return
		end
		RemoteServer.MaterialCollectCall("GetCollectAward")
	end;
}