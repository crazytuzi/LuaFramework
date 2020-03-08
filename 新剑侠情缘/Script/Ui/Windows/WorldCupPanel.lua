local tbUi = Ui:CreateClass("WorldCupPanel")
local tbAct = Activity.WorldCupAct

tbUi.tbOnClick = {
    BtnClose = function(self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    Box = function(self)
        tbAct:GainReward()
    end,
    BoxMark2 = function(self)
        me.CenterMsg(self.bGainReward and "已领取过了" or "没达到领取条件")
    end,
    BtnGuess = function(self)
        Ui:OpenWindow("WorldCupGuessPanel")
        Ui:CloseWindow(self.UI_NAME)
    end,
}

function tbUi:OnOpen()
    self:Refresh()
    tbAct:UpdateData()
end

function tbUi:Refresh()
    local tbData = tbAct.tbData or {
        nPosition = 0,
        nScore = 0,
        tbItems = {},
        bGainReward = true,
    }
    self.bGainReward = tbData.bGainReward

    self.pPanel:Label_SetText("RankingTxt", string.format("排名：%s", tbData.nPosition>0 and tbData.nPosition or "未上榜"))
    self.pPanel:Label_SetText("ValueTxt", string.format("价值：%s", tbData.nScore>0 and tbData.nScore or "0"))
    local nCur = Lib:CountTB(tbData.tbItems)
    local nTotal = Lib:CountTB(tbAct.tbShowItems)
    self.pPanel:Label_SetText("ProgressTxt", string.format("%d/%d", nCur, nTotal))
    local bCanGain = nCur>=nTotal and not tbData.bGainReward
    self.pPanel:SetActive("BoxMark2", not bCanGain)
    self.pPanel:SetActive("texiao_12", bCanGain)
    self.pPanel:SetActive("texiao_22", bCanGain)
    local nPercent = math.max(0, nCur/nTotal)
    self.pPanel:Sprite_SetFillPercent("Bar", nPercent)

    local fnSetItem = function(itemObj, nIdx)
        for i=1, 4 do
            local nRealIdx = (nIdx-1)*4+i
            local nItemId = tbAct.tbShowItems[nRealIdx]
            local szItem = "item"..i
            if nItemId then
                local nCount = tbData.tbItems[nItemId] or 0
                local bActivate = nCount>0
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
                itemObj[szItem].fnClick = itemObj[szItem].DefaultClick
            end
            itemObj[szItem].pPanel:SetActive("Main", not not nItemId)
        end
    end
    self.ScrollView:Update(math.ceil(#tbAct.tbShowItems/4), fnSetItem)
end
