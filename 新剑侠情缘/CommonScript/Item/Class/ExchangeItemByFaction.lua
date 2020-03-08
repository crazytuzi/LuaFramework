local tbItem = Item:GetClass("ExchangeItemByFaction")
tbItem.tbSetting = {
    [5410] = {  --道具模板id
        [1] = 3933, --门派对应兑换的道具id
        [2] = 4381,
        [3] = 4385,
        [4] = 4389,
        [5] = 4393,
        [6] = 4397,
        [7] = 4401,
        [8] = 4405,
        [9] = 4409,
        [10] = 4413,
        [11] = 4417,
        [12] = 4421,
        [13] = 5351,
        [14] = 5355,
        [15] = 6701,
        [16] = 7515,
        [17] = 8440,
        [18] = 9719,
        [19] = 10495,
        [20] = 11051,
        [21] = 11838,
    }
};

function tbItem:OnUse(pItem)
    local dwTemplateId = pItem.dwTemplateId
    local nExChangeId,szMsg = self:GetExhangeItemId(dwTemplateId, me.nFaction)
    if not nExChangeId then
        me.CenterMsg(szMsg)
        return
    end
    local tbRets = me.FindItemInPlayer(nExChangeId)
    if next(tbRets) then
        me.CenterMsg("你已经拥有该装备对应的外装")
        return
    end

    pItem.Delete(Env.LogWay_EquipExchage);
    local pNewItem = me.AddItem(nExChangeId, 1, nil, Env.LogWay_EquipExchage);
    Item:UseEquip(pNewItem.dwId, nil, Item.EQUIPPOS_WAIYI);
    local szName, nIcon, nView, nQuality = Item:GetItemTemplateShowInfo(nExChangeId, me.nFaction, me.nSex)
    me.CenterMsg(string.format("恭喜您获得了%s", szName) )
    return;
end

function tbItem:GetExhangeItemId(dwTemplateId, nFaction)
    local tbSetting = self.tbSetting[dwTemplateId]
    if not tbSetting then
        return false, "缺少对应的道具配置！"
    end
    local nExChangeId = tbSetting[nFaction]
    if not nExChangeId then
        return false, "当前门派尚无此类道具，请大侠敬请期待！"
    end
    return nExChangeId
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

    if me.GetVipLevel()<tbInfo.tbData.nVip then
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