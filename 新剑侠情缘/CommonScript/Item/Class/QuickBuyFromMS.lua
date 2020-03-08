
local tbItem = Item:GetClass("QuickBuyFromMS");
function tbItem:OnUse()
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	if nItemId and nItemId > 0 then
		if Shop:CanSellWare(me, nItemId, 1) then
			return {szFirstName = "出售", fnFirst = "SellItem"}
		end
	end

	local nPrice = MarketStall:GetPriceInfo("item", nItemTemplateId);
	if not nPrice then
		return {};
	end

	return {
				bForceShow = true,
				szFirstName = "前往摆摊购买",
				fnFirst = function ()
					Ui:OpenWindow("MarketStallPanel", 1, nil, "item", nItemTemplateId);
					Ui:CloseWindow("ItemTips");
				end
			};
end
