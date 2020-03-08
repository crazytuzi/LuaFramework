local tbUi = Ui:CreateClass("WorldCupTransSelPanel")
local tbAct = Activity.WorldCupAct

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnChose = function(self)
		if not self.nSelectedItemId or self.nSelectedItemId <= 0 then
			me.CenterMsg("请选择徽章")
			return
		end
		if self.bFrom then
			tbAct.nTransFromItemId = self.nSelectedItemId
		else
			tbAct.nTransToItemId = self.nSelectedItemId
		end
		tbAct:OnUpdateTransferData()
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen(bFrom)
	self.bFrom = bFrom
	self.nSelectedItemId = nil
	self:Refresh()
	tbAct:UpdateData()
end

function tbUi:Refresh()
	local tbData = tbAct.tbData or {
		nPosition = 0,
		nScore = 0,
		tbItems = {},
	}
	self.tbData = tbData

	self.pPanel:Label_SetText("RankingTxt", string.format("排名：%s", tbData.nPosition>0 and tbData.nPosition or "未上榜"))
	self.pPanel:Label_SetText("ValueTxt", string.format("价值：%s", tbData.nScore>0 and tbData.nScore or "0"))

	local fnSetItem = function(itemObj, nIdx)
		for i=1, 4 do
			local nRealIdx = (nIdx - 1) * 4 + i
			local nItemId = tbAct.tbShowItems[nRealIdx]
			local szItem = "item"..i
			if nItemId then
				local nCount = tbData.tbItems[nItemId] or 0
				local bActivate = nCount > 0
				if bActivate then
					itemObj[szItem]:SetItemByTemplate(nItemId, nCount, nil, nil, {bShowCDLayer = not bActivate})
				else
					local _, nIcon, _, nQuality = Item:GetItemTemplateShowInfo(nItemId, me.nFaction, me.nSex)
					local szIconAtlas, szIconSprite = Item:GetIcon(nIcon)
					local pIFPanel = itemObj[szItem].pPanel
					pIFPanel:SetActive("ItemLayer", true)
					pIFPanel:Sprite_SetSpriteGray("ItemLayer", szIconSprite, szIconAtlas)
					pIFPanel:SetActive("CDLayer", true)
					pIFPanel:Sprite_SetGray("CDLayer", true)
					pIFPanel:SetActive("Color", true)
					pIFPanel:Sprite_SetGray("Color", true)
					pIFPanel:Label_SetText("LabelSuffix", "")

					itemObj[szItem].nTemplate = nItemId
					itemObj[szItem].nFaction = me.nFaction
				end
				itemObj[szItem].pPanel:SetActive("Select", self.nSelectedItemId == nItemId)
				itemObj[szItem].fnClick = function()
					Ui:OpenWindow("ItemTips", "Item", nil, nItemId)
					if not bActivate then
						me.CenterMsg("您未拥有此徽章，请选择已拥有的徽章进行转换！")
						return
					end
					if self.nSelectedItemId == nItemId then
						return
					end
					if self.pSelPanel then
						self.pSelPanel:SetActive("Select", false)
					end
					self.nSelectedItemId = nItemId
					self.pSelPanel = itemObj[szItem].pPanel
					self.pSelPanel:SetActive("Select", true)
				end
			end
			itemObj[szItem].pPanel:SetActive("Main", not not nItemId)
		end
	end
	self.ScrollView:Update(math.ceil(#tbAct.tbShowItems/4), fnSetItem)
end
