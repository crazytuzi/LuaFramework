local szClassName = "NeedChooseItem"
local tbItem = Item:GetClass(szClassName)

function tbItem:LoadSetting()
    local tbSetting = Lib:LoadTabFile("Setting/Item/Other/ChooseItem.tab", {TemplateId = 1, Faction = 0, ChooseItem = 1, Num = 1, Level = 1, CheckLimit = 1, ThisNeedCount = 1}) -- CheckLimit 检查小号
    assert(tbSetting, "[NeedChooseItem LoadSetting Fail]")

    self.tbSetting = {}
    for nIndex, tbInfo in ipairs(tbSetting) do
        local nTemplateId = tbInfo.TemplateId
        self.tbSetting[nTemplateId] = self.tbSetting[nTemplateId] or {}
        for nFaction = 1, Faction.MAX_FACTION_COUNT do
            self.tbSetting[nTemplateId][nFaction] = self.tbSetting[nTemplateId][nFaction] or {}
            if tbInfo.Faction == 0 or nFaction == tbInfo.Faction then
                local tbChooseInfo = {nNum = math.max(1, tbInfo.Num), szTimeFrame = tbInfo.TimeFrame, nLevel = tbInfo.Level, bLimit = tbInfo.CheckLimit > 0, nThisNeedCount = tbInfo.ThisNeedCount}
                tbChooseInfo.nIndex = nIndex;
                self.tbSetting[nTemplateId][nFaction][tbInfo.ChooseItem] = tbChooseInfo
            end
        end
    end
end

function tbItem:CheckCanChoose(pPlayer, tbInfo)
    if not Lib:IsEmptyStr(tbInfo.szTimeFrame) and GetTimeFrameState(tbInfo.szTimeFrame) ~= 1 then
        return false
    end

    if pPlayer.nLevel < tbInfo.nLevel then
        return false
    end

    if MODULE_GAMESERVER then
        if tbInfo.bLimit and MarketStall:CheckIsLimitPlayer(me) then
            return false
        end
    end

    return true
end

function tbItem:Get4ChooseList(nTemplateId)
    local tbAll4Choose = self.tbSetting[nTemplateId]
    if not tbAll4Choose then
        return
    end

    local tb4Choose = {}
    for nItemTemplateId, tbInfo in pairs(tbAll4Choose[me.nFaction] or {}) do
        if self:CheckCanChoose(me, tbInfo) then
            tb4Choose[nItemTemplateId] = {nNum = tbInfo.nNum, szTimeFrame = tbInfo.szTimeFrame, nThisNeedCount = tbInfo.nThisNeedCount, nIndex = tbInfo.nIndex};
        end
    end
    return tb4Choose
end

function tbItem:OnSelectItem(pItem, tbChoose)
    --[[if pItem.szClass ~= szClassName then
        return
    end]]
    if not tbChoose or not next(tbChoose) then
        return
    end

    local dwTemplateId  = pItem.dwTemplateId
    local nCanChooseNum = tonumber(KItem.GetItemExtParam(dwTemplateId, 1))
    local nNeedCount    = tonumber(KItem.GetItemExtParam(dwTemplateId, 2))

    if nNeedCount > 0 then
        if me.GetItemCountInAllPos(dwTemplateId) < nNeedCount then
            return
        end
    else
        nNeedCount = 1
    end

    local tb4Choose = self:Get4ChooseList(dwTemplateId)
    if not tb4Choose then
        return
    end

    local tbAward     = {}
    local nChoosedNum = 0;
    local nCurAllNeedCount = 0;
    local nCurExtNeedCount = 0;
    for nTemplateId, nCNum in pairs(tbChoose) do
        local tbItemChoose = tb4Choose[nTemplateId];
        if not tbItemChoose then
            me.CenterMsg("选择列表中存在未开放道具");
            return;
        end

        local nNum = tbItemChoose.nNum;
        if not nNum or nNum <= 0 then
            me.CenterMsg("选择列表中存在未开放道具")
            return
        end
        if nCNum > nNum then
            me.CenterMsg("超过可选数量")
            return
        end

        nChoosedNum = nChoosedNum + nCNum;
        nCurAllNeedCount = nCurAllNeedCount + nCNum * tbItemChoose.nThisNeedCount;
        if tbItemChoose.nThisNeedCount <= 0 then
            nCurExtNeedCount = nNeedCount;
        end
            
        table.insert(tbAward, {"Item", nTemplateId, nCNum})
    end

    if nCurAllNeedCount > 0 then
        nCurAllNeedCount = nCurAllNeedCount + nCurExtNeedCount;
        if me.GetItemCountInAllPos(dwTemplateId) < nCurAllNeedCount then
            me.CenterMsg(string.format("道具数量不足%s个", nCurAllNeedCount));
            return
        end

        nNeedCount = nCurAllNeedCount;
    end    

    if nChoosedNum ~= nCanChooseNum then
        me.CenterMsg(string.format("请重新选择%d个道具", nCanChooseNum))
        return
    end

    if next(tbAward) then
        me.SendAward(tbAward, true, false, Env.LogWay_ChooseItem, dwTemplateId)
    end

    return nNeedCount
end

function tbItem:OpenWindow(nUiX, nUiY, nTID, nID)
    local tb4Choose = self:Get4ChooseList(nTID)
    if not tb4Choose then
        me.CenterMsg("没有可选道具")
        return
    end

    me.CallClientScript("Ui:OpenWindowAtPos", "ItemSelectPanel", nUiX, nUiY, nTID, nID, tb4Choose)
end

------------------------------client------------------------------
function tbItem:TryOpenUi(nUiX, nUiY, nTID, nID, bJumpGift, bForceTips)
    local tbAll4Choose = self.tbSetting[nTID]
    if not tbAll4Choose then
        return
    end
    if not bJumpGift then
        local tbInfo = Gift:GetMailGiftItemInfo(nTID)
        if bForceTips or (tbInfo and me.GetVipLevel() >= tbInfo.tbData.nVip) then
            Ui:OpenWindowAtPos("ItemTips", nUiX, nUiY, "Item", nID, nTID, me.nFaction)
            return
        end
    end

    for nItemTemplateId, tbInfo in pairs(tbAll4Choose[me.nFaction] or {}) do
        if self:CheckCanChoose(me, tbInfo) then
            if tbInfo.bLimit then
                RemoteServer.TryOpenSelectItemUi(nUiX, nUiY, nTID, nID)
                return
            end
        end
    end
    Ui:OpenWindowAtPos("ItemSelectPanel", nUiX, nUiY, nTID, nID)
end

function tbItem:OnClientUse(pItem)
    self:TryOpenUi(0, 0, pItem.dwTemplateId, pItem.dwId, true)
    return 1
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbRet = {
        szFirstName = "使用",
        fnFirst = "UseItem",
    }
    local tbInfo = Gift:GetMailGiftItemInfo(nTemplateId)
    if not tbInfo then
        return tbRet
    end

    if me.GetVipLevel() < tbInfo.tbData.nVip then
        return tbRet
    end

    tbRet = {
        szFirstName = "赠送",
        fnFirst = function()
            Ui:OpenWindow("GiftSystem")
            Ui:CloseWindow("ItemTips")
        end,
        szSecondName = "使用",
        fnSecond = "UseItem",
    }
    return tbRet
end

tbItem:LoadSetting()