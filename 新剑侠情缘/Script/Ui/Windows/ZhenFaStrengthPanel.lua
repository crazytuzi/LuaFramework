local tbUi = Ui:CreateClass("ZhenFaStrengthPanel")
function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_ZHEN_FA_STRENGTH_RESULT, self.OnStrengthResult, self }
    }

    return tbRegEvent
end

function tbUi:OnOpen(nOpenPos)
    self.tbShowPos = {}
    self.nCurIdx = 1
    for nPos, tbInfo in ipairs(ZhenFa.tbJueYao) do
        if me.GetUserValue(ZhenFa.GROUP, tbInfo.nCurItemTID) > 0 then
            table.insert(self.tbShowPos, nPos)
        end
        if nOpenPos == nPos then
            self.nCurIdx = #self.tbShowPos
        end
    end
    if not next(self.tbShowPos) then
        me.CenterMsg("没有装备的诀要")
        return 0
    end
    self:ResetCurInfo()
    self.pPanel:SetActive("TeXiao_fanshu_CT", true)
    self.pPanel:SetActive("TeXiao_fanshu", false)
    self.pPanel:SetActive("StrengthenSuccess", false)
    self.pPanel:Button_SetEnabled("BtnPractice", true)
end

function tbUi:OnOpenEnd()
    self:UpdateJueyaoList()
    self:UpdateJueyaoContent()
    self.pPanel:Toggle_SetChecked("StrengthenItem" .. self.nCurIdx, true)
end

function tbUi:OnClose()
    if self.nSuccessTXTimer then
        Timer:Close(self.nSuccessTXTimer)
        self.nSuccessTXTimer = nil
    end
    if self.nLongPressTimer then
        Timer:Close(self.nLongPressTimer)
        self.nLongPressTimer = nil
    end
end

function tbUi:ResetCurInfo()
    self.nCurPos = self.tbShowPos[self.nCurIdx]
    self.tbUseMaterail = {}
    self.nNewLvNeedExp = 0
    local nStrengthLv = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[self.nCurPos].nStrengthLv)
    if nStrengthLv < ZhenFa:GetStrengthMaxLv() then
        self.nNewLvNeedExp = ZhenFa:GetStrengthNeedExp(nStrengthLv + 1) - me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[self.nCurPos].nCurExp)
    end
    self:UpdateMaterial()
end

function tbUi:UpdateJueyaoList()
    for i = 1, 6 do
        local nPos = self.tbShowPos[i]
        self.pPanel:SetActive("StrengthenItem" .. i, nPos or false)
        if nPos then
            local nItemTID       = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nPos].nCurItemTID)
            local nStrengthLv    = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nPos].nStrengthLv)
            local nCurExp        = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nPos].nCurExp)
            local nMaxExp        = ZhenFa:GetStrengthNeedExp(nStrengthLv + 1)
            local nStrengthMaxLv = ZhenFa:GetStrengthMaxLv()
            local nPlayerMaxLv   = ZhenFa:GetPlayerStrengthMaxLv(me)
            local bMaxLv         = nStrengthLv >= math.min(nPlayerMaxLv, nStrengthMaxLv)
            if not bMaxLv and nMaxExp then
                local nPercent = math.floor(nCurExp*100/nMaxExp)
                self.pPanel:Label_SetText("TxtStren" .. i, string.format("修炼等级：%d（%d%%）", nStrengthLv, math.min(nPercent, 100)))
            else
                self.pPanel:Label_SetText("TxtStren" .. i, string.format("修炼等级：%d（满级）", nStrengthLv))
            end
            local szName = Item:GetItemTemplateShowInfo(nItemTID)
            self.pPanel:Label_SetText("TxtName" .. i, szName)
            self["itemframe" .. i]:SetItemByTemplate(nItemTID)
        end
    end
end

function tbUi:CheckMaxLv()
    local tbJueYaoInfo   = ZhenFa.tbJueYao[self.nCurPos]
    local nStrengthLv    = me.GetUserValue(ZhenFa.GROUP, tbJueYaoInfo.nStrengthLv)
    local nStrengthMaxLv = ZhenFa:GetStrengthMaxLv()
    local nPlayerMaxLv   = ZhenFa:GetPlayerStrengthMaxLv(me)
    return nStrengthLv >= math.min(nPlayerMaxLv, nStrengthMaxLv)
end

function tbUi:UpdateJueyaoContent()
    local tbJueYaoInfo   = ZhenFa.tbJueYao[self.nCurPos]
    local nItemTID       = me.GetUserValue(ZhenFa.GROUP, tbJueYaoInfo.nCurItemTID)
    local nStrengthLv    = me.GetUserValue(ZhenFa.GROUP, tbJueYaoInfo.nStrengthLv)
    local nAttribIdx     = me.GetUserValue(ZhenFa.GROUP, tbJueYaoInfo.nAttribIdx)
    local bStrengthMaxLv = self:CheckMaxLv()
    self.pPanel:Label_SetText("TxtCurStrenLevel", string.format("修炼+%d", nStrengthLv))
    self.pPanel:SetActive("TxtNextStrenLevel", nStrengthLv + 1 <= ZhenFa:GetStrengthMaxLv())
    self.pPanel:Label_SetText("TxtNextStrenLevel", string.format("修炼+%d", nStrengthLv + 1))

    self.pPanel:SetActive("strengthendata", not bStrengthMaxLv)
    self.pPanel:SetActive("TxtBreakThrough", bStrengthMaxLv)
    self.pPanel:SetActive("BtnPractice", not bStrengthMaxLv)
    if bStrengthMaxLv then
        self.pPanel:Label_SetText("TxtBreakThrough", "该诀要修练等级已满")
        return
    end


    local tbDesc = tbJueYaoInfo.tbDesc
    local tbRandomAttrib = ZhenFa.tbAttribs[self.nCurPos].tbRandomAttrib[nAttribIdx]
    local tbRealLevel    = ZhenFa.tbRealLevel[nItemTID].tbLevel
    for nGroupIdx = 1, 3 do
        local szDesc = tbDesc[nGroupIdx]
        self.pPanel:SetActive("AttribWidget" .. nGroupIdx, szDesc or false)
        if szDesc then
            self.pPanel:Label_SetText("AttribTitle" .. nGroupIdx, szDesc)

            local nGroupId     = tbRandomAttrib.tbAttribGroupId[nGroupIdx]
            local tbAttribInfo = KItem.GetExternAttrib(nGroupId, tbRealLevel[nGroupIdx] + nStrengthLv)
            local szAttName, szAttValue = FightSkill:GetMagicDescSplit(tbAttribInfo[1].szAttribName, tbAttribInfo[1].tbValue)
            self.pPanel:Label_SetText("TxtProbName" .. nGroupIdx, szAttName)
            self.pPanel:Label_SetText("TxtProbCur" .. nGroupIdx, szAttValue)

            local tbSAttribInfo = KItem.GetExternAttrib(nGroupId, tbRealLevel[nGroupIdx] + nStrengthLv + 1)
            if tbSAttribInfo then
                local _, szSAttValue = FightSkill:GetMagicDescSplit(tbSAttribInfo[1].szAttribName, tbSAttribInfo[1].tbValue)
                self.pPanel:Label_SetText("TxtProbNext" .. nGroupIdx, szSAttValue)
                local nValue = 0
                for i = 1, 3 do
                    nValue = math.abs(tbSAttribInfo[1].tbValue[i] - tbAttribInfo[1].tbValue[i])
                    if tbSAttribInfo[1].tbValue[i] ~= tbAttribInfo[1].tbValue[i] then
                        break
                    end
                end
                self.pPanel:Label_SetText("TxtExtent" .. nGroupIdx, nValue)
            end
        end
    end
end

function tbUi:UpdateMaterial(nIdx)
    local nStrengthLv = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[self.nCurPos].nStrengthLv)
    self.pPanel:SetActive("Condition", nStrengthLv < ZhenFa:GetStrengthMaxLv())
    self.pPanel:SetActive("Progress", nStrengthLv < ZhenFa:GetStrengthMaxLv())
    if nStrengthLv >= ZhenFa:GetStrengthMaxLv() then
        return
    end
    for i = 1, 3 do
        local nCount = self.tbUseMaterail[i] or 0
        if not nIdx or nIdx == i then
            local nItemTID    = ZhenFa.tbDecomposeInfo[i].nItemTID
            local nMyCount    = me.GetItemCountInAllPos(nItemTID)
            local tbItemFrame = self["CostItem" .. i]
            if nMyCount > 0 then
                tbItemFrame:SetItemByTemplate(nItemTID)
            else
                local _, nIcon = Item:GetItemTemplateShowInfo(nItemTID, me.nFaction, me.nSex)
                local szIconAtlas, szIconSprite = Item:GetIcon(nIcon)
                tbItemFrame.pPanel:SetActive("ItemLayer", true)
                tbItemFrame.pPanel:Sprite_SetSpriteGray("ItemLayer", szIconSprite, szIconAtlas)
                tbItemFrame.pPanel:SetActive("CDLayer", true)
                tbItemFrame.pPanel:Sprite_SetGray("CDLayer", true)
                tbItemFrame.pPanel:SetActive("Color", true)
                tbItemFrame.pPanel:Sprite_SetGray("Color", true)
            end
            tbItemFrame.pPanel:SetActive("LabelSuffix", nMyCount > 0)
            tbItemFrame.pPanel:Label_SetText("LabelSuffix", string.format("%d/%d", nCount, nMyCount))
        end

        self.pPanel:SetActive("Reduce" .. i, nCount > 0)
    end

    local nCurExp = 0
    for nIdx, nCount in pairs(self.tbUseMaterail) do
        local nItemTID = ZhenFa.tbDecomposeInfo[nIdx].nItemTID
        local nExp = KItem.GetItemExtParam(nItemTID, 1)
        nCurExp = nCurExp + nCount * nExp
    end
    local nMaxExp = ZhenFa:GetStrengthNeedExp(nStrengthLv + 1)
    nCurExp = nCurExp + me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[self.nCurPos].nCurExp)
    self.pPanel:Sprite_SetFillPercent("Bar", math.min(nCurExp/nMaxExp, 1))
    self.pPanel:Label_SetText("Label", string.format("%d/%d", nCurExp, nMaxExp))
end

function tbUi:SelectIdx(nIdx)
    if not self.tbShowPos[nIdx] then
        return
    end
    if self.nCurIdx == nIdx then
        return
    end

    self.nCurIdx = nIdx
    self:ResetCurInfo()
    self:UpdateJueyaoContent()
end

function tbUi:AddMaterial(nIdx, nNum)
    if self:CheckMaxLv() then
        return
    end
    nNum = nNum or 1
    self.tbUseMaterail[nIdx] = self.tbUseMaterail[nIdx] or 0
    local nCount = me.GetItemCountInAllPos(ZhenFa.tbDecomposeInfo[nIdx].nItemTID)
    if self.tbUseMaterail[nIdx] >= nCount then
        return
    end

    local nCurExp = 0
    for i, nCount in pairs(self.tbUseMaterail) do
        local nItemTID = ZhenFa.tbDecomposeInfo[i].nItemTID
        local nExp = KItem.GetItemExtParam(nItemTID, 1)
        nCurExp = nCurExp + nCount * nExp
    end
    if nCurExp >= self.nNewLvNeedExp then
        me.CenterMsg("你已经放入足够的修炼道具")
        return
    end
    local nUseNum = 1
    if nNum then
        local nItemTID = ZhenFa.tbDecomposeInfo[nIdx].nItemTID
        local nExp     = KItem.GetItemExtParam(nItemTID, 1)
        nUseNum = math.ceil((self.nNewLvNeedExp - nCurExp)/nExp)
        nUseNum = math.min(nUseNum, nNum)
    end
    self.tbUseMaterail[nIdx] = self.tbUseMaterail[nIdx] + nUseNum
    self:UpdateMaterial()
    return nUseNum == nNum
end

function tbUi:StartAddMaterialPerSecond(nIdx)
    if self.nLongPressTimer then
        Timer:Close(self.nLongPressTimer)
        self.nLongPressTimer = nil
    end
    if not self.bIsPress then
        return
    end
    self.nLongPressTimer = Timer:Register(nIdx + 1, function ()
        local bRet = self:AddMaterial(nIdx, 1)
        if not bRet then
            self.nLongPressTimer = nil
        end
        return bRet
    end)
end

function tbUi:OnPress(bIsPress, nIdx)
    local tbJueYaoInfo   = ZhenFa.tbJueYao[self.nCurPos]
    local nStrengthLv    = me.GetUserValue(ZhenFa.GROUP, tbJueYaoInfo.nStrengthLv)
    local nStrengthMaxLv = ZhenFa:GetStrengthMaxLv()
    local nPlayerMaxLv   = ZhenFa:GetPlayerStrengthMaxLv(me)
    local bStrengthMaxLv = nStrengthLv >= math.min(nPlayerMaxLv, nStrengthMaxLv)
    if self:CheckMaxLv() then
        return
    end

    self.bIsPress = bIsPress
    self:StartAddMaterialPerSecond(nIdx)
end

function tbUi:ReduceMaterial(nIdx)
    self.tbUseMaterail[nIdx] = self.tbUseMaterail[nIdx] or 0
    if self.tbUseMaterail[nIdx] <= 0 then
        return
    end
    self.tbUseMaterail[nIdx] = self.tbUseMaterail[nIdx] - 1
    self:UpdateMaterial()
end

function tbUi:TryStrength()
    local tbJYInfo = ZhenFa.tbJueYao[self.nCurPos]
    local nStrengthLv = me.GetUserValue(ZhenFa.GROUP, tbJYInfo.nStrengthLv)
    local nPlayerMaxLv = ZhenFa:GetPlayerStrengthMaxLv(me)
    local nSystemMaxLv = ZhenFa:GetStrengthMaxLv()
    if nStrengthLv >= nSystemMaxLv or nStrengthLv >= nPlayerMaxLv then
        return
    end

    local nMaterialExp = 0
    for nIdx, nConsume in pairs(self.tbUseMaterail) do
        local nItemTID = ZhenFa.tbDecomposeInfo[nIdx].nItemTID
        local tbInfo = KItem.GetItemBaseProp(nItemTID)
        if not tbInfo or tbInfo.szClass ~= "JueYaoMaterial" then
            me.CenterMsg("不能使用该道具强化")
            return
        end
        local nExp = KItem.GetItemExtParam(nItemTID, 1)
        local nCount = me.GetItemCountInAllPos(nItemTID)
        if nConsume > nCount then
            me.CenterMsg("道具数量不足，请重试")
            return
        end
        nMaterialExp = nMaterialExp + nExp * nConsume
    end
    if nMaterialExp == 0 then
        me.CenterMsg("请选择修炼道具")
        return
    end

    local nCurExp = me.GetUserValue(ZhenFa.GROUP, tbJYInfo.nCurExp) + nMaterialExp
    local nFinalLv = nStrengthLv
    for nLvTmp = nStrengthLv + 1, math.min(nPlayerMaxLv, nSystemMaxLv) do
        local nNeed = nCurExp - ZhenFa:GetStrengthNeedExp(nLvTmp)
        if nNeed < 0 then
            break
        end
        nCurExp = nNeed
        nFinalLv = nFinalLv + 1
    end
    if nFinalLv > nPlayerMaxLv or nFinalLv > nSystemMaxLv then
        me.CenterMsg("选择的道具过多，请重新选择")
        return
    end
    local tbConsume = {}
    for nIdx, nConsume in pairs(self.tbUseMaterail) do
        local nItemTID = ZhenFa.tbDecomposeInfo[nIdx].nItemTID
        tbConsume[nItemTID] = nConsume
    end
    RemoteServer.ZhenFaOnClientCall("TryStrength", self.nCurPos, tbConsume)
    self.pPanel:Button_SetEnabled("BtnPractice", false)
end

function tbUi:OnStrengthResult(bLevelChange)
    self.pPanel:SetActive("TeXiao_fanshu_CT", false)
    self.pPanel:SetActive("TeXiao_fanshu", false)
    self.pPanel:SetActive("TeXiao_fanshu", true)
    if self.nSuccessTXTimer then
        Timer:Close(self.nSuccessTXTimer)
        self.nSuccessTXTimer = nil
    end
    self.pPanel:Button_SetEnabled("BtnPractice", true)
    self:ResetCurInfo()
    self:UpdateJueyaoList()
    if bLevelChange then
        self:UpdateJueyaoContent()
        self.nSuccessTXTimer = Timer:Register(Env.GAME_FPS * 2, function ()
            self.nSuccessTXTimer = nil
            self.pPanel:SetActive("StrengthenSuccess", false)
            self.pPanel:SetActive("StrengthenSuccess", true)
        end)
    end

    Timer:Register( math.floor(Env.GAME_FPS * 0.2), function ()
        Ui:PlayUISound(8014)
    end)
    Timer:Register( math.floor(Env.GAME_FPS * 1.65), function ()
        Ui:PlayUISound(8014)
    end)
end

tbUi.tbOnClick = {
    BtnClose = function (self)
        Ui:CloseWindow(self.UI_NAME)
    end,
    BtnPractice = function (self)
        self:TryStrength()
    end,
}
for i = 1, 6 do
    tbUi.tbOnClick["StrengthenItem" .. i] = function (self)
        self:SelectIdx(i)
    end
end
for i = 1, 3 do
    tbUi.tbOnClick["Reduce" .. i] = function (self)
        self:ReduceMaterial(i)
    end
    tbUi.tbOnClick["CostItem" .. i] = function (self, szBtnName, bIsPress)
        self:AddMaterial(i)
    end
end

tbUi.tbOnPress = {}
for i = 1, 3 do
    tbUi.tbOnPress["CostItem" .. i] = function (self, szBtnName, bIsPress)
        self:OnPress(bIsPress, i)
    end
end