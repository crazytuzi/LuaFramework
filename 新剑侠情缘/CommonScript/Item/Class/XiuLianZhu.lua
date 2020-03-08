Require("CommonScript/Item/XiuLian.lua");

local tbItem = Item:GetClass("XiuLianZhu");
function tbItem:OnUse(pItem)
    local tbDef = XiuLian.tbDef;
    local bRet = XiuLian:CanBuyXiuLianDan(me);
    if bRet then
        me.CallClientScript("Ui:CloseWindow", "ItemTips");
        local nCount, tbDanItem = me.GetItemCountInBags(tbDef.nXiuLianDanID);
        if nCount > 0 and tbDanItem and tbDanItem[1] then
            me.CallClientScript("Ui:OpenWindow", "ItemTips", "Item", tbDanItem[1].dwId, tbDef.nXiuLianDanID);
        else
            me.CallClientScript("Ui:OpenWindow", "CommonShop", "Treasure", "tabAllShop", tbDef.nXiuLianDanID);
        end
    else
        me.CallClientScript("Ui:OpenWindow", "FieldPracticePanel");
    end
end

function tbItem:GetTip(pItem)
    local tbDan = Item:GetClass("XiuLianDan");
    local szMsg = "";
    local nCount = tbDan:GetOpenResidueCount(me);
    local nResidueTime = XiuLian:GetXiuLianResidueTime(me);
    local nMaxCount = tbDan:GetXiuLianMaxTime(me);
    szMsg = string.format("剩余累积修炼时间：[FFFE0D]%s[-]\n累积可使用修炼丹：[FFFE0D]%s/%d次[-]", Lib:TimeDesc(nResidueTime), nCount, nMaxCount);
    return szMsg;
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
    local tbDef = XiuLian.tbDef;
    local tbOpt = {szFirstName = "使用", fnFirst = "UseItem"};
    local bRet = XiuLian:CanBuyXiuLianDan(me);
    if bRet then
        tbOpt.szFirstName = "购买修炼丹";
        local nCount = me.GetItemCountInBags(tbDef.nXiuLianDanID);
        if nCount > 0 then
            tbOpt.szFirstName = "使用修炼丹";
        end
    end

    return tbOpt;
end