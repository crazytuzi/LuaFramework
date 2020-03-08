--选头衔的道具
local tbItem = Item:GetClass("QingRenJieTitleItem")
tbItem.tbTitle = {
    [5040] = true,
    [5041] = true,
    [5042] = true,
    [5043] = true,
    [5044] = true,
    [5045] = true,
    [5046] = true,
    [5047] = true,
    [5048] = true,
    [5049] = true,
}
function tbItem:OnClientUse(pItem)
    Ui:OpenWindow("QingRenJieTitlePanel", pItem.dwId)
    Ui:CloseWindow("ItemTips")
    return 1
end

function tbItem:OnRequestUse(pPlayer, nTitleId, nItemID)
    local pItem = KItem.GetItemObj(nItemID)
    if not pItem then
        return
    end

    if not self.tbTitle[nTitleId] then
        return
    end

    local nEndTime = pItem.GetIntValue(-9996)
    nEndTime = nEndTime > 0 and nEndTime or (GetTime()+24*60*60)
    if Item:Consume(pItem, 1) < 1 then
        pPlayer.CenterMsg("道具消耗失败，请重试")
        return
    end

    local tbAward = {{"AddTimeTitle", nTitleId, nEndTime}}
    pPlayer.SendAward(tbAward, true, true, Env.LogWay_QingRenJie)
    Log("QingRenJieTitleItem OnRequestUse", pPlayer.dwID, nTitleId)
end

--船票
local tbTicketItem = Item:GetClass("QingRenJieTicket")
function tbTicketItem:OnClientUse()
    Ui.HyperTextHandle:Handle("[url=npc:text, 95, 10]", 0, 0)
    Ui:CloseWindow("ItemTips")
    Ui:CloseWindow("ItemBox")
    return 1
end
