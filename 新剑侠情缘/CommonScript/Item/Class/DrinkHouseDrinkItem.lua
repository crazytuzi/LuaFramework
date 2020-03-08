local tbItem = Item:GetClass("DrinkHouseDrinkItem");


function tbItem:OnUse( it )
	if DrinkHouse:InviteDrinkPopAvaliable(me) then
		me.CenterMsg("您已经使用过该道具了")
		return
	end
	me.SetUserValue(DrinkHouse.tbDef.SAVE_GROUP, DrinkHouse.tbDef.SAVE_KEY_DRINK_INVITE, 1)	
	me.CenterMsg("你获得了请酒功能，快去忘忧酒馆试试吧。", true)
	return 1;
end