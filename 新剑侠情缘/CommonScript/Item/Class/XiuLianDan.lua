Require("CommonScript/Item/XiuLian.lua");
local tbDef = XiuLian.tbDef;

local tbItem = Item:GetClass("XiuLianDan");
tbItem.nExtAddResiduTime = 1;
tbItem.nSaveGroupID = 92;
tbItem.nSaveCount   = 1;
tbItem.nSaveTime    = 2;
tbItem.nSaveVersion = 3;

tbItem.szTimeUpdateTime = "4:00"; --每天更新的时间
tbItem.nMaxAddOpenCount = 4;

tbItem.tbVipExtCount = --VIP每天多少次
{
    {nMin = 0; nMax = 13, nCount = 1};
    {nMin = 14; nMax = 30, nCount = 2};
};

tbItem.tbShowTip = --显示Tip
{
    {
        nMin = 0,
        nMax = 10,
        szMsg = "使用后修炼珠增加[FFFE0D]30分钟[-]野外修炼时间，修炼丹[FFFE0D]每天4点[-]恢复[FFFE0D]1次[-]使用次数，最多可以累积[FFFE0D]3次[-]";
    };

    {
        nMin = 11,
        nMax = 13,
        szMsg = "使用后修炼珠增加[FFFE0D]30分钟[-]野外修炼时间，修炼丹[FFFE0D]每天4点[-]恢复[FFFE0D]1次[-]使用次数，最多可以累积[FFFE0D]3次[-]。\n升级尊14每天可使用次数增加[FFFE0D]1次[-]";
    };

    {
        nMin = 14,
        nMax = 30,
        szMsg = "使用后修炼珠增加[FFFE0D]30分钟[-]野外修炼时间，修炼丹[FFFE0D]每天4点[-]恢复[FFFE0D]2次[-]使用次数，最多可以累积[FFFE0D]6次[-]";
    };
};

tbItem.tbShowShopTip = --商店显示
{
    {
        nMin = 0,
        nMax = 10,
        szMsg = "使用后修炼珠增加[FFFE0D]30分钟[-]野外修炼时间，修炼丹[FFFE0D]每天4点[-]恢复[FFFE0D]1次[-]使用次数，最多可以累积[FFFE0D]3次[-]\n\n\n\n";
    };

    {
        nMin = 11,
        nMax = 13,
        szMsg = "使用后修炼珠增加[FFFE0D]30分钟[-]野外修炼时间，修炼丹[FFFE0D]每天4点[-]恢复[FFFE0D]1次[-]使用次数，最多可以累积[FFFE0D]3次[-]\n升级尊14每天可使用次数增加[FFFE0D]1次[-]\n";
    };

    {
        nMin = 14,
        nMax = 30,
        szMsg = "使用后修炼珠增加[FFFE0D]30分钟[-]野外修炼时间，修炼丹[FFFE0D]每天4点[-]恢复[FFFE0D]2次[-]使用次数，最多可以累积[FFFE0D]6次[-]\n\n\n\n";
    };
};

function tbItem:GetTip(pItem)
    local nCount = self:GetOpenResidueCount(me);
    local nMaxAddCount = self:GetXiuLianMaxTime(me)
    local szTip = string.format("累积可使用次数：%s/%d", nCount, nMaxAddCount);
    return szTip;
end

function tbItem:GetXiuLianMaxTime(pPlayer)
    local nPerAddCount = self:GetVIPCount(pPlayer);
    return tbItem.nMaxAddOpenCount * nPerAddCount;
end

function tbItem:GetIntrol(nTemplateId, nItemId)
    local szMsg = self:GetShowTipInfo(me, self.tbShowTip);
    if not szMsg then
        return;
    end

    return szMsg;
end

function tbItem:GetShowTipInfo(pPlayer, tbShowTip)
    local nVipLevel = pPlayer.GetVipLevel();
    for _, tbInfo in pairs(tbShowTip) do
        if tbInfo.nMin <= nVipLevel and nVipLevel <= tbInfo.nMax then
            return tbInfo.szMsg;
        end
    end
end

function tbItem:GetShopTip(pItem)
    local nVipLevel = me.GetVipLevel();
    local szTipShow = self:GetShowTipInfo(me, self.tbShowShopTip) or "";
    local nCount = self:GetOpenResidueCount(me);
    local szTip = string.format(szTipShow.."[FFFE0D]         累积可使用次数：%s[-]", nCount);
    return szTip;
end

function tbItem:GetVIPCount(pPlayer)
    local nVipLevel = pPlayer.GetVipLevel();
    for _, tbInfo in pairs(self.tbVipExtCount) do
        if tbInfo.nMin <= nVipLevel and nVipLevel <= tbInfo.nMax then
            return tbInfo.nCount;
        end
    end

    return 1;
end

function tbItem:GetOpenResidueCount(pPlayer)
    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(tbItem.nSaveGroupID, tbItem.nSaveTime);
    local nParseTodayTime = Lib:ParseTodayTime(tbItem.szTimeUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = 0;
    if nLastTime == 0 then
        nUpdateLastDay = nUpdateDay - 1;
    else
        nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));    
    end

    local nResidueCount = pPlayer.GetUserValue(tbItem.nSaveGroupID, tbItem.nSaveCount);
    local nAddDay = math.abs(nUpdateDay - nUpdateLastDay);
    local nVersion = pPlayer.GetUserValue(tbItem.nSaveGroupID, tbItem.nSaveVersion);
    if nVersion <= 0 then
        nResidueCount = 0;

        if MODULE_GAMESERVER then
            pPlayer.SetUserValue(tbItem.nSaveGroupID, tbItem.nSaveCount, 0);
        end
            
        if nAddDay ~= 0 then
            if MODULE_GAMESERVER then
                pPlayer.SetUserValue(tbItem.nSaveGroupID, tbItem.nSaveTime, 0);
            end
                
            nAddDay = 1;
        end

        if MODULE_GAMESERVER then
            pPlayer.SetUserValue(tbItem.nSaveGroupID, tbItem.nSaveVersion, 1);
        end    
    end
    
    if nAddDay == 0 then
        return nResidueCount;
    end

    local nPerAddCount = self:GetVIPCount(pPlayer);
    nResidueCount = nResidueCount + nAddDay * nPerAddCount;
    if nResidueCount <= 0 then
        nResidueCount = 1;
    end

    local nMaxAddCount = tbItem.nMaxAddOpenCount * nPerAddCount;
    nResidueCount = math.min(nResidueCount, nMaxAddCount);

    if MODULE_GAMESERVER then
        pPlayer.SetUserValue(tbItem.nSaveGroupID, tbItem.nSaveTime, nTime);
        pPlayer.SetUserValue(tbItem.nSaveGroupID, tbItem.nSaveCount, nResidueCount);
    end
    
    return nResidueCount;     
end

function tbItem:CheckXiuLianResiduTime(pPlayer, nAddResiduTime)
    local nResidueTime = XiuLian:GetXiuLianResidueTime(pPlayer);
    nResidueTime = nResidueTime + nAddResiduTime;
    if nResidueTime > tbDef.nMaxAddXiuLianTime then
        return false, "累积修炼时间已达上限";
    end

    local nCount = self:GetOpenResidueCount(pPlayer);
    if nCount <= 0 then
        return false, "少侠剩余可使用次数不足（次日4:00可用）";
    end

    return true, "";    
end

function tbItem:OnUse(it) 
    local nAddResiduTime = KItem.GetItemExtParam(it.dwTemplateId, self.nExtAddResiduTime);
    if nAddResiduTime <= 0 then
        Log("Error XiuLianDan AddResiduTime", nAddResiduTime);
        return;
    end

    local bRet, szMsg = self:CheckXiuLianResiduTime(me, nAddResiduTime);
    if not bRet then
        me.CenterMsg(szMsg);
        return;
    end

    local nCount = self:GetOpenResidueCount(me);
    nCount = nCount - 1;
    me.SetUserValue(tbItem.nSaveGroupID, tbItem.nSaveCount, nCount);

    XiuLian:AddXiuLianResiduTime(me, nAddResiduTime);
    me.CenterMsg(string.format("累积修炼时间增加了%s分钟[FFFE0D]（修炼珠）[-]", math.floor(nAddResiduTime / 60)));
    return 1;    
end