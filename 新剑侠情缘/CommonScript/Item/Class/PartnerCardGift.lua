local tbItem = Item:GetClass("PartnerCardGift");

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	local tbBelongCard = PartnerCard:GetBelongCardIdOwn(me, nItemTemplateId)
	local nBelongCardId = tbBelongCard[1]
	local tbSetting = {
        szFirstName = "赠送",
        fnFirst = function()
            Ui:OpenWindow("GiftSystem", nBelongCardId, nil, "PartnerCard")
            Ui:CloseWindow("ItemTips")
        end,
    }
	return tbSetting
end