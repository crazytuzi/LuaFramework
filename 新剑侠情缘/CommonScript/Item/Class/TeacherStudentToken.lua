local tbItem = Item:GetClass("TeacherStudentToken")

tbItem.nMapId = 1000
tbItem.nNpcId = 1839
function tbItem:OnClientUse(it)
	Ui:CloseWindow("ItemTips")
	Ui:CloseWindow("ItemBox")
    SwornFriends:AutoPathToNpc(self.nNpcId, self.nMapId)
    return 1
end
