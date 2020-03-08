local tbUi = Ui:CreateClass("JueYaoTips")

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_WND_CLOSED, self.OnTipsClose, self},
    }
    return tbRegEvent;
end


function tbUi:OnOpenEnd(nJueYaoPos, nItemId, nItemTemplateId, tbRandomAttrib, bNotShowBtn)
    self.nJueYaoPos = nJueYaoPos
    self.nItemId = nItemId
    local tbBtnInfo = {}
    if nJueYaoPos then
        tbBtnInfo = {{"UnUse", "卸下"}, {"Upgrade", "修炼"}}
    elseif nItemId then
        tbBtnInfo = {{"Use", "装备"}, {"Decompose", "分解"}}
    end
    self.tbBtnInfo = tbBtnInfo
    for nIdx, tbInfo in ipairs(tbBtnInfo) do
        self.pPanel:SetActive("Btn" .. nIdx, tbInfo or false)
        self.pPanel:Button_SetText("Btn" .. nIdx, tbInfo[2] or "")
    end
    self.pPanel:SetActive("titlepur-16", false)
    self.pPanel:SetActive("Equipped", nJueYaoPos or false)
    local nStrengthLv = 0
    local nAttribIdx
    local bShowBtn = false
    if nJueYaoPos then
        nItemTemplateId = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nJueYaoPos].nCurItemTID)
        nStrengthLv = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nJueYaoPos].nStrengthLv)
        self.pPanel:SetActive("TxtEnhLevel", nJueYaoPos or false)
        nAttribIdx = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nJueYaoPos].nAttribIdx)
        bShowBtn = true
    elseif nItemId then
        local pItem = KItem.GetItemObj(nItemId)
        nItemTemplateId = pItem.dwTemplateId
        nJueYaoPos = pItem.nDetailType
        nAttribIdx = pItem.GetIntValue(ZhenFa.JUEYAO_ATT_INDEX)
        nStrengthLv = me.GetUserValue(ZhenFa.GROUP, ZhenFa.tbJueYao[nJueYaoPos].nStrengthLv)
        bShowBtn = true
    else
        local tbInfo = KItem.GetItemBaseProp(nItemTemplateId)
        nJueYaoPos = tbInfo.nDetailType
        nAttribIdx = tbRandomAttrib[1]
    end
    self.pPanel:Label_SetText("TxtEquipType", "诀要")
    self.pPanel:SetActive("TxtEnhLevel", nStrengthLv > 0)
    self.pPanel:Label_SetText("TxtEnhLevel", "+" .. nStrengthLv)
    self.itemframe:SetGenericItem({"Item", nItemTemplateId, 1})
    local nFightPower = ZhenFa.tbRealLevel[nItemTemplateId].nFightPower
    local nStrengthFP = ZhenFa:GetStrengthPower(nStrengthLv) or 0
    self.pPanel:Label_SetText("TxtFightPower", string.format("战力：%d", nFightPower + nStrengthFP))
    local tbBaseProp = KItem.GetItemBaseProp(nItemTemplateId)
    self.pPanel:Label_SetText("Rank", string.format("%d阶", tbBaseProp.nLevel))
    local szColor = Item:GetQualityColor(tbBaseProp.nQuality)
    self.pPanel:Label_SetText("TxtTitle", tbBaseProp.szName)
    self.pPanel:Label_SetColorByName("TxtTitle", szColor)
    self.pPanel:Label_SetText("TxtLevelLimit", string.format("等级需求：%d级", tbBaseProp.nRequireLevel))
    self:UpdateAttrib(nItemTemplateId, nJueYaoPos, nAttribIdx,nStrengthLv)
    self.nItemTemplateId = nItemTemplateId
    self.pPanel:SetActive("Btn1", bShowBtn and not bNotShowBtn)
    self.pPanel:SetActive("Btn2", bShowBtn and not bNotShowBtn)
end

function tbUi:UpdateAttrib(nItemTemplateId, nJueYaoPos, nAttribIdx, nStrengthLv)
    self.pPanel:SetActive("ScrollView", nJueYaoPos and nAttribIdx or false)
    if not nJueYaoPos or not nAttribIdx then
        return
    end
    local tbAllDesc      = {}
    local tbDesc         = ZhenFa.tbJueYao[nJueYaoPos].tbDesc
    local tbRandomAttrib = ZhenFa.tbAttribs[nJueYaoPos].tbRandomAttrib[nAttribIdx]
    local tbRealLevel    = ZhenFa.tbRealLevel[nItemTemplateId].tbLevel
    local tbBaseProp     = KItem.GetItemBaseProp(nItemTemplateId)
    local szColor        = Item:GetQualityColor(tbBaseProp.nQuality)
    for nGroupIdx, szSingleDesc in ipairs(tbDesc) do
        local tbItemDesc = {szSingleDesc}
        table.insert(tbAllDesc, tbItemDesc)
        local nGroupId      = tbRandomAttrib.tbAttribGroupId[nGroupIdx]
        local tbAttribInfo  = KItem.GetExternAttrib(nGroupId, tbRealLevel[nGroupIdx])
        local tbSAttribInfo = KItem.GetExternAttrib(nGroupId, tbRealLevel[nGroupIdx]+nStrengthLv)
        for nAttIdx, tbInfo in ipairs(tbAttribInfo) do
            local szMagicDesc = FightSkill:GetMagicDesc(tbInfo.szAttribName, tbInfo.tbValue)
            local tbAttDesc   = {szMagicDesc, szColor}
            if nStrengthLv > 0 then
                local nValue = 0
                for i = 1, 3 do
                    nValue = math.abs(tbSAttribInfo[nAttIdx].tbValue[i] - tbInfo.tbValue[i])
                    if nValue ~= 0 then
                        break
                    end
                end
                table.insert(tbAttDesc, string.format("[64DB00FF](修炼 + %d)", nValue))
            end
            table.insert(tbAllDesc, tbAttDesc)
        end
        table.insert(tbAllDesc, {""})
    end
    local fnInit = function (itemobj, nIdx)
        itemobj.pPanel:Label_SetText("Main", tbAllDesc[nIdx][1])
        if tbAllDesc[nIdx][2] then
            itemobj.pPanel:Label_SetColorByName("Main", tbAllDesc[nIdx][2])
        end
        itemobj.pPanel:Label_SetText("TextAdd", tbAllDesc[nIdx][3] or "")
    end
    local nCount = #tbAllDesc - 1
    self.ScrollView:Update(nCount, fnInit)
end

function tbUi:Btn1()
    local szFunc = self.tbBtnInfo[1][1]
    if not szFunc then
        return
    end
    self[szFunc](self)
end

function tbUi:Btn2()
    local szFunc = self.tbBtnInfo[2][1]
    if not szFunc then
        return
    end
    self[szFunc](self)
end

function tbUi:OnScreenClick(szClickUi)
    if szClickUi ~= "JueYaoTips" and szClickUi ~= "JueYaoCompareTips" then
        Ui:CloseWindow(self.UI_NAME)
    end
end

function tbUi:OnTipsClose(szWnd)
    if szWnd == "JueYaoTips" or szWnd == "JueYaoCompareTips" then
        Ui:CloseWindow(self.UI_NAME);
    end
end


function tbUi:UnUse()
    if not self.nJueYaoPos then
        return
    end
    Ui:CloseWindow(self.UI_NAME)
    RemoteServer.ZhenFaOnClientCall("TryUnEquip", self.nJueYaoPos)
end

function tbUi:Use()
    if self.nJueYaoPos then
        return
    end
    if not self.nItemId then
        return
    end
    Ui:CloseWindow(self.UI_NAME)
    Item:ClientUseItem(self.nItemId)
end

function tbUi:Upgrade()
    if not self.nJueYaoPos then
        return
    end
    Ui:CloseWindow(self.UI_NAME)
    Ui:OpenWindow("ZhenFaStrengthPanel", self.nJueYaoPos)
end

function tbUi:GetResultDesc()
    local tbResult = ZhenFa:GetDecomposeResult(self.nItemTemplateId, true)
    local tbDesc = {}
    for _, tbInfo in ipairs(tbResult) do
        local szName, _, _, nQuality = Item:GetItemTemplateShowInfo(tbInfo[1])
        local _, _, _, _, szColor = Item:GetQualityColor(nQuality)
        local szDesc = string.format("%d~%d本", tbInfo[3], tbInfo[4])
        table.insert(tbDesc, string.format("[-]%s[%s]%s", szDesc, szColor, szName))
        table.insert(tbDesc, "[-]和")
    end
    local szResult = "分解该诀要可以获得"
    for i = 1, #tbDesc - 1 do
        szResult = szResult .. tbDesc[i]
    end
    return szResult .. "[-]，是否要分解？"
end

function tbUi:Decompose()
    if self.nJueYaoPos then
        return
    end
    if not self.nItemId then
        return
    end
    local nItemId = self.nItemId
    local szUiName = self.UI_NAME
    local fnAgree = function ()
        Ui:CloseWindow(szUiName)
        RemoteServer.ZhenFaOnClientCall("TryDecompose", nItemId)
    end
    local szResult = self:GetResultDesc()
    me.MsgBox(szResult, {{"同意", fnAgree}, {"取消"}})
end

tbUi.tbOnClick =
{
    Btn1 = function (self)
        self:Btn1()
    end,
    Btn2 = function (self)
        self:Btn2()
    end,
}