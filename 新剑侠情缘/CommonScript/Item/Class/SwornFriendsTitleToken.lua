local tbItem = Item:GetClass("SwornFriendsTitleToken")

-- quick use不能使用OnClientUse
function tbItem:OnUse(it)
	if not SwornFriends:IsConnectedState(me) then
		me.CenterMsg("你没有结拜，无法使用")
		return
	end

    me.CallClientScript("Ui:CloseWindow", "QuickUseItem")
	me.CallClientScript("Ui:CloseWindow", "ItemTips")
	me.CallClientScript("Ui:CloseWindow", "ItemBox")
	me.CallClientScript("Ui:OpenWindow", "SwornFriendsPersonalTitlePanel", true)
end
