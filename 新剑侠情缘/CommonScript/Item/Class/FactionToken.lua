local tbItem = Item:GetClass("FactionToken")
tbItem.tbShowIntroTimeFrame = 
{
     {nTimeFrame = "OpenDay279", szMsg = "\n凭[FFFE0D]150个[-]信物，可兑换一本门派绝学"};
}

function tbItem:OnClientUse(pItem)
    Ui:OpenWindow("ItemSelectPanel", pItem.dwTemplateId, pItem.dwId);
    Ui:CloseWindow("ItemTips");
    return 1;
end

function tbItem:OnSelectItem(pItem, tbChoose)
    return Item:GetClass("NeedChooseItem"):OnSelectItem(pItem, tbChoose)
end

function tbItem:GetIntrol(dwTemplateId)
    local tbInfo = KItem.GetItemBaseProp(dwTemplateId)
    if not tbInfo then
        return
    end

    local szMsg = tbInfo.szIntro;
    for _, tbShowIntro in ipairs(tbItem.tbShowIntroTimeFrame) do
        if GetTimeFrameState(tbShowIntro.nTimeFrame) == 1 then
            szMsg = szMsg .. tbShowIntro.szMsg;
        end
    end
    
    return szMsg;
end