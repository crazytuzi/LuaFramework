function ZhenFa:OnDataChange()
    UiNotify.OnNotify(UiNotify.emNOTIFY_JUE_YAO_STATE_CHANGE)
    self:CheckRedpoint()
end

function ZhenFa:OnStrengthSuccess(bLvChange)
    UiNotify.OnNotify(UiNotify.emNOTIFY_ZHEN_FA_STRENGTH_RESULT, bLvChange)
end

function ZhenFa:ResetExternAttribC(nRemoveGroupId, nApplyGroupId, nApplyLevel)
    if nRemoveGroupId and nRemoveGroupId ~= nApplyGroupId then
        me.RemoveExternAttrib(nRemoveGroupId)
    end
    if nApplyGroupId and nApplyLevel then
        me.ApplyExternAttrib(nApplyGroupId, nApplyLevel)
    end
end

function ZhenFa:RefreshExternAttrib()
    for nPos, tbInfo in ipairs(self.tbJueYao) do
        local nItemTID = me.GetUserValue(self.GROUP, tbInfo.nCurItemTID)
        local nIdx     = me.GetUserValue(self.GROUP, tbInfo.nAttribIdx)
        if nItemTID > 0 and nIdx > 0 then
            local tbAttrib = self.tbAttribs[nPos].tbRandomAttrib[nIdx]
            for _, nGroupId in ipairs(tbAttrib.tbAttribGroupId or {}) do
                me.RemoveExternAttrib(nGroupId)
            end
            local nCurLv = me.GetUserValue(self.GROUP, tbInfo.nCurLevel)
            if nCurLv > 0 then
                local tbAttrib       = self.tbAttribs[nPos].tbRandomAttrib[nIdx]
                local tbLevelInfo    = self.tbRealLevel[nItemTID]
                local nAttribLevel   = tbLevelInfo.tbLevel[nCurLv]
                local nStrengthLevel = me.GetUserValue(self.GROUP, tbInfo.nStrengthLv)
                me.ApplyExternAttrib(tbAttrib.tbAttribGroupId[nCurLv], nAttribLevel + nStrengthLevel)
            end
        end
    end
end

function ZhenFa:CheckRedpoint()
    if GetTimeFrameState(self.OPEN_TF) ~= 1 then
        Ui:ClearRedPointNotify("Skill_ZhenFa")
        return
    end
    local tbHadPosJueYao = {}
    local tbItem = me.GetItemListInBag()
    for _, pItem in ipairs(tbItem) do
        if pItem.szClass == "JueYao" and pItem.nUseLevel <= me.nLevel then
            tbHadPosJueYao[pItem.nDetailType] = true
        end
    end
    for nPos, tbInfo in ipairs(self.tbJueYao) do
        local nItemTID = me.GetUserValue(self.GROUP, tbInfo.nCurItemTID)
        if nItemTID <= 0 and tbHadPosJueYao[nPos] then
            Ui:SetRedPointNotify("Skill_ZhenFa")
            return
        end
    end
    Ui:ClearRedPointNotify("Skill_ZhenFa")
end

function ZhenFa:OnLogin()
    self:RefreshExternAttrib()
    self:CheckRedpoint()
end

function ZhenFa:OpenJueYaoTips(tbPos, nItemTemplateId, nItemId, tbInfo)
    if nItemId or tbInfo.nJueYaoPos or tbInfo.tbRandomAtrrib then
        local nPos = 0
        if nItemId then
            local pItem = KItem.GetItemObj(nItemId)
            nItemTemplateId = pItem.dwTemplateId
        end
        if nItemTemplateId then
            local tbInfo = self.tbRealLevel[nItemTemplateId]
            if tbInfo and me.GetUserValue(self.GROUP, self.tbJueYao[tbInfo.nDetailType].nCurItemTID) > 0 then
                nPos = tbInfo.nDetailType
            end
        end
        if not tbInfo.nJueYaoPos and nPos and nPos > 0 then
            Ui:OpenWindowAtPos("JueYaoTips", -308, 234, nPos, nil, nil, nil, true);
            Ui:OpenWindowAtPos("JueYaoCompareTips", 140, 234, tbInfo.nJueYaoPos, nItemId, nItemTemplateId, tbInfo.tbRandomAtrrib);
        else
            tbPos.x = tbPos.x == -1 and -84 or tbPos.x
            tbPos.y = tbPos.y == -1 and 234 or tbPos.y
            Ui:OpenWindowAtPos("JueYaoTips", tbPos.x, tbPos.y, tbInfo.nJueYaoPos, nItemId, nItemTemplateId, tbInfo.tbRandomAtrrib);
        end
    else
        Ui:OpenWindowAtPos("ItemTips", tbPos.x, tbPos.y, "Item", nItemId, nItemTemplateId);
    end
end