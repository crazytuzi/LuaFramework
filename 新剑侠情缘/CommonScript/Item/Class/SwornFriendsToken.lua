local tbItem = Item:GetClass("SwornFriendsToken")

-- quick use不能使用OnClientUse
function tbItem:OnUse(it)
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
    me.CallClientScript("SwornFriends:AutoPathToNpc", SwornFriends.Def.nCityNpcId, SwornFriends.Def.nCityMapId)
end
