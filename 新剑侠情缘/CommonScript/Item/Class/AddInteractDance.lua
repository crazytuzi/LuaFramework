local tbItem = Item:GetClass("AddInteractDance")

function tbItem:OnUse(pItem)
    local bRet, szMsg = ActionInteract:AddOptDance2(me) 
    if not bRet then
        me.CenterMsg(szMsg)
        return
    end
    me.CenterMsg("使用成功")
    return 1;
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
