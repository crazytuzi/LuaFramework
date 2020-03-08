local tbItem = Item:GetClass("DrinkRentItem");

function tbItem:GetUseSetting()
	local fnFirst = function (  )
		AutoPath:AutoPathToNpc(DrinkHouse.tbRentDef.RENT_NPC_ID, DrinkHouse.tbRentDef.RENT_NPC_IN_MAP)
		Ui:CloseWindow("ItemTips")
		Ui:CloseWindow("ItemBox")
	end
	return {szFirstName = "使用", fnFirst = fnFirst};
end